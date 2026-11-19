"""Questionnaire usability pilot: do open-weight models give usable questionnaire data?

Participant-facing text lives in `messages/`, the protocol in `config/pilot.yaml`, and the
models in `config/models.yaml`. Run with::

    uv run --env-file .env python -m src.pilot.run

Modules: `config` (load + validate), `solver` (walks one session), `scorer` (parses
answers, classifies the response), `task` (the Inspect task), `mock` (scripted fake
participant for dry runs), `run` (loops over models, prints a summary table).
"""
