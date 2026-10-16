# Design (the why)

## Monorepo with three Alire crates (exception to §18 recorded here)

Preferences §18 prefers several smaller repos. This repo is a deliberate,
documented exception: three parser crates (`oci-reference`,
`oci-image-manifest`, `oci-layer-apply`) live in one GitHub repo to avoid
flooding the internet with 300-line repos, each with its own CI/issue
tracker/release train. Each crate keeps its own SemVer, so a bug fix in the
reference parser does not force a version bump of the manifest crate. If a
crate grows its own ecosystem, it extracts with zero code changes. Expected
to change in the future — revisit when any crate earns independence.

Root-directory overflow note (§29 soft budget): root holds the required
planning docs plus 3 crate dirs, `docs/`, `.github/`. Overflow is intentional
(monorepo of related crates), not accumulation.

## GitHub, not GitLab (exception to §27 recorded here)

Owner routing: GitHub is for libraries, GitLab is for projects. This is a
library, so GitHub is canonical. CI is GitHub Actions; generated API docs go
to GitHub Pages.

## Why SPARK Silver, not full SPARK

Silver (data-flow + information-flow + key proofs, no pointers/aliasing
traps) fits string-slicing parsers: strong enough to prove absence of
runtime errors in `Parse` paths, cheap enough to keep CI fast and to hold
the subset across all three crates. Gold-level proof (full functional
correctness) is a per-crate future decision, not today's gate.

## Why pure planning for Layer.Apply v0.1

Filesystem mutation + tar/gzip extraction is a runtime concern with a large
test surface (mounts, permissions, root). v0.1 exposes pure functions
(ordering, whiteout detection, digest-chain checks) that GNATprove can
verify without fixtures. Extraction is a later, separately-scoped crate.

## Error pattern

Ada/SPARK idiom: contracts (`Pre`/`Post`) + `Valid : out Boolean`, no
exceptions on bad input, exceptions only on caller contract violation
(zero-length buffer, `Max_Length = 0`). One pattern everywhere.

## Skips with reasons

- `container` (Trivy): no container image ships. Skip.
- `dynamic` (Nyx): pure parser library, no runtime to probe. Documented skip
  per operator decision 2026-10-16.
- `reliability` (Plumbline): no LLM/agent code. Skip.
