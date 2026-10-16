# Security

## Reporting

Open a private security advisory on GitHub or contact the maintainer. Do not
file public issues for vulnerabilities. 100-day fix SLA framing: triage on
report, fix window communicated in the advisory.

## AI use and model disclosure

Vibe-coded with OpenCode (Muse Spark). Parser logic reviewed against the OCI
distribution-spec and image-spec grammars; GNATprove Silver run in CI on every
push. No third-party model output is executed — all Ada sources are
human-gated before merge to `main`.

## Scanners

Pre-commit (Betterleaks + Codespell + hygiene), OpenGrep SAST in CI.
Scanners use synthetic fixtures only; no real credentials verified.
Cloud-hosted LLMs fix problems encountered while working, never hunt.
