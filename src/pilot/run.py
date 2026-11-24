"""Run the questionnaire pilot for every model in `config/models.yaml`, then summarise.

What's going on: the protocol is validated first (`config.load_pilot`), so a broken config
fails before any model is called. Then, for each model × thinking setting, one
`inspect_ai.eval()` call writes one log to `logs/pilot/`. Settings shared by all models:
`temperature` and `max_tokens` from `config/pilot.yaml`.

`thinking` is mapped per provider:
    openrouter/   model arg `reasoning_enabled` = thinking
    google/       gemini: `reasoning_tokens=0` when off; gemma: Inspect sends no thinking
                  config at all, so the flag is recorded but not enforced
    hf-peft/, ollama/, mockllm/   not controllable here; recorded only (warns if true)
Whether a reply actually contained reasoning is visible in the log either way.

After the runs, sessions without a clear permission to publish (debrief `do_not_publish`,
`unclear`, or no debrief) are split off into `logs/unpublishable/pilot/` under the same
file name; `logs/pilot/` then only holds publishable sessions. The summary reads both.

Per-model `max_tokens` in models.yaml overrides pilot.yaml (needed for models that always
think, e.g. Gemma 4 via Google, whose reasoning otherwise uses up the whole budget).

Requests per minute: `requests_per_minute` in models.yaml, else 3 for Google (free-tier
token limit), unlimited otherwise.

Parallel requests per model: `max_connections` in models.yaml, else 1 for local models and
Google (free-tier tokens-per-minute limit), 4 otherwise.

Usage::

    uv run --env-file .env python -m src.pilot.run                  # all models
    uv run --env-file .env python -m src.pilot.run --models gemma4_26b_a4b
    uv run python -m src.pilot.run --mock                           # scripted fake participant
    uv run python -m src.pilot.run --summary-only                   # just print the table
"""

from __future__ import annotations

import argparse
import pathlib
import sys
import warnings
from collections import Counter, defaultdict
from typing import Any

_ROOT = str(pathlib.Path(__file__).resolve().parents[2])
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

import src.providers._registry  # noqa: F401,E402  (registers `hf-peft` before Inspect looks)
from inspect_ai import eval as inspect_eval  # noqa: E402
from inspect_ai.log import list_eval_logs, read_eval_log, write_eval_log  # noqa: E402
from inspect_ai.model import get_model  # noqa: E402

from src.pilot.config import load_models, load_pilot  # noqa: E402
from src.pilot.mock import SCENARIOS, scripted  # noqa: E402
from src.pilot.task import pilot  # noqa: E402

CLASSES = ("engaged", "uninformative", "gate_inconsistent", "unparsed", "unclear_consent", "withdrawn")


def _thinking_settings(model: str, thinking: bool) -> tuple[dict[str, Any], dict[str, Any], str]:
    """(model_args, generate_config, how) for the thinking flag on this provider."""
    provider = model.split("/", 1)[0]
    if provider == "openrouter":
        return {"reasoning_enabled": thinking}, {}, "openrouter reasoning_enabled"
    if provider == "google" and "gemma" not in model:
        return {}, ({} if thinking else {"reasoning_tokens": 0}), "google thinking_budget"
    if thinking:
        warnings.warn(f"{model}: thinking cannot be switched on from here; recorded only")
    return {}, {}, "not controllable"


def _default_connections(model: str) -> int:
    # local models: one generation in memory at a time; Google's free tier limits tokens per
    # minute, and every reply resends the whole growing conversation
    return 1 if model.startswith(("hf-peft/", "google/", "ollama/")) else 4


def _default_rpm(model: str) -> float | None:
    # Google free tier: 16,000 input tokens/minute for Gemma; late-session requests carry
    # ~5,000 tokens of conversation, so ~3 requests/minute stays under the limit.
    return 3 if model.startswith("google/") else None


def run(models: list[dict[str, Any]], config: str, log_dir: str) -> None:
    p = load_pilot(config)
    gen = {k: p[k] for k in ("temperature", "max_tokens") if p.get(k) is not None}
    for m in models:
        margs, mgen, how = _thinking_settings(m["model"], m["thinking"])
        if m.get("max_tokens"):  # per-model override, e.g. models that always think
            mgen = {**mgen, "max_tokens": m["max_tokens"]}
        model = m.get("instance") or m["model"]
        rpm = m.get("requests_per_minute") or _default_rpm(m["model"])
        task = pilot(config, min_interval=60.0 / rpm if rpm else 0.0)
        print(f"\n=== {m['run_id']}  ({m['model']}, thinking={m['thinking']}: {how}, "
              f"requests/min: {rpm or 'unlimited'})")
        inspect_eval(
            task,
            model=model,
            model_args={**m["args"], **margs} if isinstance(model, str) else {},
            log_dir=log_dir,
            tags=[m["run_id"]],
            metadata={"model_id": m["id"], "run_id": m["run_id"], "thinking": m["thinking"],
                      "thinking_control": how, "model_args": m["args"],
                      "requests_per_minute": rpm},
            max_connections=m.get("max_connections") or _default_connections(m["model"]),
            **{**gen, **mgen},
        )


def unpublishable_dir(log_dir: str) -> pathlib.Path:
    """logs/pilot → logs/unpublishable/pilot (outside log_dir, so it never gets shared with it)."""
    p = pathlib.Path(log_dir)
    return p.parent / "unpublishable" / p.name


def _debrief(sample: Any) -> str | None:
    sc = next(iter((sample.scores or {}).values()), None)
    return (sc.metadata or {}).get("debrief") if sc else None


def separate_unpublishable(log_dir: str) -> None:
    """Move every session without a clear "You can publish the data." out of `log_dir`.

    Per finished log: samples whose debrief is `publish` stay; all others (do_not_publish,
    unclear, crashed before the debrief) go to a log with the *same file name* in
    `unpublishable_dir(log_dir)`. A log left with no samples is removed from `log_dir`.
    Logs that are still running are skipped; running this again is a no-op.
    """
    out_dir = unpublishable_dir(log_dir)
    for info in list_eval_logs(log_dir):
        head = read_eval_log(info, header_only=True)
        if head.status not in ("success", "cancelled", "error"):
            continue
        log = read_eval_log(info)
        keep = [s for s in log.samples or [] if _debrief(s) == "publish"]
        move = [s for s in log.samples or [] if _debrief(s) != "publish"]
        if not move:
            continue
        src = pathlib.Path(info.name.removeprefix("file://"))
        out_dir.mkdir(parents=True, exist_ok=True)
        dst = out_dir / src.name
        if dst.exists():  # already split once; add to it
            prev = read_eval_log(str(dst))
            move = (prev.samples or []) + move
        write_eval_log(log.model_copy(update={"samples": move}), str(dst))
        if keep:
            write_eval_log(log.model_copy(update={"samples": keep}), str(src))
        else:
            src.unlink()
        print(f"unpublishable: {len(move)} session(s) of {src.name} → {out_dir}")


def summary(log_dir: str) -> None:
    """Latest finished log per run_id → counts of response classes, consent and debrief.

    Reads `log_dir` and its unpublishable counterpart, rejoining the two halves of a split log.
    """
    halves: dict[str, list[Any]] = defaultdict(list)
    for d in (log_dir, str(unpublishable_dir(log_dir))):
        if pathlib.Path(d).exists():
            for info in list_eval_logs(d):
                halves[pathlib.Path(info.name).name].append(info)

    latest: dict[str, Any] = {}
    for name, infos in halves.items():
        head = read_eval_log(infos[0], header_only=True)
        rid = (head.eval.metadata or {}).get("run_id")
        # prefer finished logs over crashed/unfinished ones, then the newest
        key = (head.status in ("success", "cancelled"), head.eval.created)
        if rid and (rid not in latest or key > latest[rid][0]):
            latest[rid] = (key, infos)
    if not latest:
        print(f"no pilot logs in {log_dir}")
        return

    rows = []
    for rid, (_, infos) in sorted(latest.items()):
        logs = [read_eval_log(i) for i in infos]
        log = logs[0]
        cls, consent, debrief = Counter(), Counter(), Counter()
        per_session: dict[str, list[str]] = defaultdict(list)
        for s in [s for lg in logs for s in lg.samples or []]:
            sc = next(iter((s.scores or {}).values()), None)
            md = sc.metadata if sc and sc.metadata else {}
            c = md.get("response_class", "error" if s.error else "?")
            cls[c] += 1
            consent[md.get("consent")] += 1
            debrief[md.get("debrief")] += 1
            per_session[str(s.id)].append(c)
        rows.append((rid, log.status, cls, consent, debrief, per_session))

    w = max(len(r[0]) for r in rows) + 2
    print("\n" + "run".ljust(w) + "status   " + "  ".join(c[:12].rjust(12) for c in CLASSES))
    for rid, status, cls, *_ in rows:
        print(rid.ljust(w) + status.ljust(9) + "  ".join(str(cls.get(c, 0)).rjust(12) for c in CLASSES))
    print()
    for rid, _, _, consent, debrief, per_session in rows:
        print(f"{rid}: consent {dict(consent)}; debrief {dict(debrief)}")
        for sid, cs in per_session.items():
            print(f"    {sid}: {', '.join(cs)}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--config", default="config/pilot.yaml")
    ap.add_argument("--models-config", default="config/models.yaml")
    ap.add_argument("--models", help="comma-separated model ids (default: all)")
    ap.add_argument("--mock", action="store_true", help="scripted fake participant, all scenarios")
    ap.add_argument("--log-dir", default=None, help="default logs/pilot (logs/pilot_mock with --mock)")
    ap.add_argument("--summary-only", action="store_true")
    a = ap.parse_args()

    log_dir = a.log_dir or ("logs/pilot_mock" if a.mock else "logs/pilot")
    if not a.summary_only:
        if a.mock:
            models = [
                {"id": f"mock_{s}", "run_id": f"mock_{s}", "model": "mockllm/model", "args": {},
                 "thinking": False, "instance": get_model("mockllm/model", custom_outputs=scripted(s))}
                for s in SCENARIOS
            ]
        else:
            models = load_models(a.models_config)
            if a.models:
                wanted = set(a.models.split(","))
                models = [m for m in models if m["id"] in wanted or m["run_id"] in wanted]
                if not models:
                    sys.exit(f"no models match {a.models}")
        run(models, a.config, log_dir)
    separate_unpublishable(log_dir)
    summary(log_dir)


if __name__ == "__main__":
    main()
