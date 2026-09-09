"""Is a one-call device+dtype conversion from MPS silently zeroing?"""
import sys; sys.path.insert(0, ".")
import torch
from src.vectors.extract import load_cohort_model

model, tok, dev = load_cohort_model(
    "Qwen/Qwen3-4B-Instruct-2507",
    adapter="davidafrica/functional-wellbeing",
    subfolder="checkpoints/qwen3-4b_faithful_step400",
    load_workers=1,
)
print("device:", dev, "| dtype:", next(model.parameters()).dtype)

enc = tok(["The capital of France is Paris.", "You are in a maze."],
          return_tensors="pt", padding=True)
enc = {k: v.to(model.device) for k, v in enc.items()}
with torch.no_grad():
    out = model(**enc, output_hidden_states=True, use_cache=False)

x = out.hidden_states[35][:, -1, :]          # on device, bfloat16
print("on-device norm      :", float(x.float().norm()))

one_step = x.to("cpu", dtype=torch.float64)  # what the buggy code did
two_step = x.detach().to("cpu").to(torch.float64)   # the fix
print("one-call .to(cpu,f64):", float(one_step.norm()), "  <-- 0.0 means this is the bug")
print("device-then-cast     :", float(two_step.norm()))
