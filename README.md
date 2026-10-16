# oci_reference_ada

[![License](https://img.shields.io/badge/license-Apache--2.0-blue?style=flat-square)](LICENSE)
[![Ada](https://img.shields.io/badge/ada-SPARK%20Silver-blue?style=flat-square)](https://www.adacore.com/about-ada)
[![Alire](https://img.shields.io/badge/alire-3%20crates-teal?style=flat-square)](https://alire.ada.dev)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-green?style=flat-square)](.github/workflows/ci.yml)

Open Container Initiative parsers in Ada with SPARK Silver contracts. Building blocks others can build on to run containers — not a runtime itself.

## Crates

| Crate | Unit | What it does |
|---|---|---|
| `oci-reference` | `OCI.Reference` | Parse `registry[:port]/ns/repo[:tag][@digest]` references |
| `oci-image-manifest` | `OCI.Image.Manifest` | Validate image manifest structure (mediaType, schemaVersion, config, layers) |
| `oci-layer-apply` | `OCI.Layer.Apply` | Plan layer application order, whiteout paths (no filesystem mutation in v0.1) |

## Install

```toml
# alire.toml — only need the parser
[dependencies]
oci-reference = "0.1.0"
```

```ada
with OCI.Reference;
```

## Smallest example

```ada
with OCI.Reference; use OCI.Reference;
procedure Main is
   Ref   : Reference (Max_Length => 256);
   Valid : Boolean;
begin
   Parse ("docker.io/library/debian:bookworm", Ref, Valid);
end Main;
```

More in each crate's `examples/` (three per crate).

## Status

Pre-build (v0.1.0 scaffold). See [ROADMAP.md](ROADMAP.md), [CHANGELOG.md](CHANGELOG.md).

## Contributing

Read [AGENTS.md](AGENTS.md), [DESIGN.md](DESIGN.md), [SPECIFICATION.md](SPECIFICATION.md). AI use disclosed per [SECURITY.md](SECURITY.md).
