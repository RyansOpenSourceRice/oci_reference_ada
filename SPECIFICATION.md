# Specification (the what)

SemVer per crate. SPARK Silver (`SPARK_Mode => On`) on all library units.
GNATprove `--level=2` must report zero mediums/highs on every crate.

Fail-closed size bounds (DoS resistance): oversize inputs return
invalid/empty, never an exception, never truncation.

## OCI.Reference (`oci-reference`)

- `Max_Length : Positive` discriminant bounds all outputs. Zero-length input
  is invalid (`Valid = False`), never an exception.
- `Parse (Input : String; Result : out Reference; Valid : out Boolean)`:
  - `Pre`: `Input'Length <= 8_192`, `Result.Max_Length > 0`.
    Longer input is invalid (fail-closed).
  - Grammar: `[registry[:port]/]path[:tag][@digest]`, digest =
    `algorithm ":" hex` (algorithm per `Is_Algo_Char`, hex run >= 32).
  - Input is normalized to a 1-based buffer internally, so slices with
    arbitrary `'First` are accepted.
  - `Post`: `Valid` implies `Length (Result) > 0` and
    `Length (Result) <= Result.Max_Length`.
- Queries: `Length`, `Has_Digest`, `Is_Valid_Digest (Digest : String)`.
  `Is_Valid_Digest` accepts any bounds; `Post`: true implies
  `Digest'Length` in `8 .. Max_Digest_Length (256)`.
- `Tag_Or_Default (Ref, Tag : out String, Len : out Natural)`: explicit tag
  when present, else `"latest"`. `Tag` is blank-filled first, so `Len = 0`
  (empty ref, or buffer too small for even the default) is never an
  exception. `Pre`: `Tag'Length > 0`.

## OCI.Image.Manifest (`oci-image-manifest`)

- `Max_Doc_Length : constant := 65_536` (64 KiB). Realistic manifests
  (<= 128 layers x ~200 B/descriptor) fit; larger docs are invalid
  (fail-closed, keeps the work buffer stack-allocatable for proof).
- `Validate (Doc : String; Result : out Validation)`:
  structural check only (no JSON library dependency v0.1):
  - `Pre`: `Doc'Length <= Max_Doc_Length`.
  - `schemaVersion` present and `= 2` (compact or spaced form).
  - `mediaType` equals `Manifest_Media_Type`
    (`application/vnd.oci.image.manifest.v1+json`).
  - A valid digest token appears at/after the `"config"` key
    (`Config_Ok`); further digest tokens count as layers
    (`Layers_Count`, capped at `Max_Layers = 128`).
- `Valid (V : Validation)`: schema + media type + config + >= 1 layer.
- Digest strings validated by `OCI.Reference.Is_Valid_Digest`.

## OCI.Layer.Apply (`oci-layer-apply`)

- Pure planning only (no filesystem writes):
  - `Max_Path_Length : constant := 4_096` (Linux `PATH_MAX`); longer
    paths are never whiteouts/opaque (fail-closed).
  - `Apply_Order (Count : Natural; Order : out Order_Array)`:
    `Pre: Count <= Max_Layers (128)`,
    `Post: (for all I in 1 .. Count => Order (I) = I)` (base-first).
  - `Is_Whiteout (Path : String) return Boolean`: true iff basename starts
    with `.wh.`.
  - `Opaque_Dir (Path : String) return Boolean`: true iff basename is
    exactly `.wh..wh..opq` (which is also whiteout-shaped).
  - `Chain` descriptor list: `Empty_Chain`, `Chain_Append (Parent, Diff)`
    with `Pre: Is_Valid_Digest (Diff)` and room check, `To_String`.
    NOTE: this is the canonical descriptor list, not the hashed ChainID;
    `sha256` over the chain arrives with the future SHA-256 crate.
- `Post` on all planners: outputs bounded by inputs (no allocation beyond
  caller-provided buffers / bounded records).

## Compatibility

- Toolchain: Alire 2.1.1, `gnat_native=16.1.0`, `gprbuild=26.0.1`,
  `gnatprove=16.1.0` via `alr get` (index crate, not a toolchain
  component). PATH must include `~/.local/share/alire/toolchains/*/bin`
  and `~/ada-tools/gnatprove_16.1.0_*/bin`.
- Cross-crate reuse is via GPR `with` on relative paths; Alire index
  dependencies are added at publish time (Alire 2.x manifest format —
  the 1.x `[dependencies]` key is rejected by `alr` 2.1).
- Branches: `main` (protected) + `dev` (integration); squash-merge; linear history.
