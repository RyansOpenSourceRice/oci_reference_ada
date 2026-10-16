# AGENTS.md

Validated subset of the owner's global preferences for this repo. Full source:
owner's `ryans-agentic-coding-preferences` (local clone + ontology); query it
with snippet-only lookups, never paste whole files here.

## Scope

Applies to this repo only (owned). First name only in shared artifacts.
Library license: Apache-2.0. SemVer per crate. `main` + `dev`, squash-merge,
linear history, protected `main` with required checks.

## Gates on every change

1. `pre-commit run --all-files` (Betterleaks, Codespell, hygiene, Ada format).
2. `alr build` + `alr test` for all three crates.
3. `gnatprove -P <crate>.gpr --level=2` (Silver) clean.
4. OpenGrep SAST clean. CHANGELOG updated as part of the change.

## Out of scope (do not build, do not document)

- `CAS.Index`, container runtime, registry client, filesystem extraction.
- Linux capabilities — total exclusion.
- Meta-crate / SDK without explicit operator permission.

## Docs

README (users) / DESIGN (why) / SPECIFICATION (what) stay separate.
`docs/` holds generated API reference (GitHub Pages).
