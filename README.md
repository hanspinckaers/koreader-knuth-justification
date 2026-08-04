# KOReader Knuth justification

Experimental page-aware Knuth/Plass justification for reflowable documents in
KOReader. The project is deliberately separate from a KOReader fork: this
repository is the source of truth for the Lua plugin, startup patches, native
CREngine overlay, tests, and release packaging.

## Current release base

- KOReader: `v2026.07.1` (`9192014d8bd82a91dc1012473be0f238dedfdb54`)
- koreader-base: `6e4bc81a`
- CREngine: `b32a88ff`
- Target: Kindle 4/5 ARM userspace

The native library is version-locked. It is loaded under a separate filename,
so the official `libs/libkoreader-cre.so` is never overwritten. On a KOReader
version mismatch, the startup patch declines to load the overlay and KOReader
falls back to its stock CREngine.

## Layout

- `plugin/` — menu, per-book persistence, defaults, and profile-compatible events
- `patches/` — early native-loader patch and Profiles bridge
- `native/overlay/` — patched CREngine files copied over the exact upstream base
- `tests/` — Lua lifecycle/property tests
- `scripts/` — reproducible synchronization, verification, build, and packaging

## Development checkout

Start with an exact recursive checkout of the supported KOReader release, then
apply this repository's files:

```sh
git clone --recursive --branch v2026.07.1 https://github.com/koreader/koreader.git koreader-v2026.07.1
./scripts/sync-to-koreader.sh /path/to/koreader-v2026.07.1
```

The sync script refuses a different KOReader or CREngine commit.

## Install

Install official KOReader `v2026.07.1`, then merge a release overlay's
`koreader/` directory into the existing installation and fully restart KOReader.
The controls appear under **Top menu → Knuth justification**.

## License

GPL-3.0-or-later. The native files are derived from KOReader's CREngine and
retain the same license.
