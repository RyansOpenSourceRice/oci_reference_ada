# Roadmap

Living document. Updated as part of the change that shifts direction.

## Building now (v0.1.x)

- `OCI.Reference`: full distribution-spec reference grammar, digest validation (`sha256:` hex 64).
- `OCI.Image.Manifest`: schemaVersion/mediaType/config/layers structural validation.
- `OCI.Layer.Apply`: apply-order planning + whiteout (`.wh.`) path detection, pure functions only.

## Explicitly not building

- `CAS.Index` (content-addressable index) — parked; separate responsibility boundary.
- Linux capabilities — not considered for build or documentation. Total exclusion.
- Container runtime, extraction to filesystem, networking, registry client.
- Meta-crate re-exporting all three — ships only when a consumer needs it.

## Future (may split monorepo)

If a crate grows its own ecosystem, it extracts to its own repo with zero code changes (move crate dir + manifest). See DESIGN.md.
