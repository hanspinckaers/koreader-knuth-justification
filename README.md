# KOReader Knuth justification

Experimental page-level Knuth/Plass justification for reflowable documents in
KOReader. Every page receives a shared optimized word-space baseline; paragraph
break candidates are scored against that page texture. Hyphenation is free and
hanging punctuation participates in the same optical-width metric.

The project is deliberately separate from a KOReader fork: this
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

With an already configured `build-kindle4` tree, build and package the complete
overlay from this repository with:

```sh
./scripts/build-kindle-overlay.sh /path/to/koreader-v2026.07.1
```

The renderer first discovers real page membership, then performs at most two
page-target refinement passes. It stops early when page boundaries and weighted
word-space targets converge exactly.

Run the host-side plugin and native objective tests with LuaJIT or Lua 5.1:

```sh
./scripts/test.sh
```

Validate a packaged overlay, optionally against the stock official module's
undefined-symbol ABI, with:

```sh
./scripts/validate-overlay.sh overlay.zip /path/to/official/libkoreader-cre.so
```

## Install

Install official KOReader `v2026.07.1`, then merge a release overlay's
`koreader/` directory into the existing installation and fully restart KOReader.
The controls appear under **Top menu → Page-level Knuth justification**.

## Integrated fractional-kerning build

`combined/` adds CREngine PR #685 at `e229b669`, the four-level Kerning
Precision UI, legacy setting migration, the complete Literata variable family,
and all page-level Knuth controls directly in KOReader's normal document
settings. The combined engine is installed as the normal CREngine library; this
variant does not load or use the Knuth plugin or startup preload patch. It is
packaged as a complete official Kindle installation rather than a small overlay:

```sh
./scripts/build-combined-kindle.sh /path/to/koreader-v2026.07.1 \
    /path/to/koreader-kindle-v2026.07.1.zip
```

This integrated package is separate from the historical page-only plugin
release. The page-only variant continues to preserve stock official kerning.

## License

GPL-3.0-or-later. The native files are derived from KOReader's CREngine and
retain the same license.
