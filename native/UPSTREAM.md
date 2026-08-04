# Supported upstream

The files in `native/overlay/crengine/` replace the corresponding paths in an
exact CREngine checkout at `b32a88ff`, as recorded by official KOReader
`v2026.07.1`.

They are kept as normal source files rather than one opaque patch so changes,
tests, and review happen in this repository. `scripts/sync-to-koreader.sh`
copies them into a disposable/external KOReader build checkout after verifying
all upstream revisions.
