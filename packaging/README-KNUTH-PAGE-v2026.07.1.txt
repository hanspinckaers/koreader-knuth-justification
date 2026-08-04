Page-level Knuth justification overlay for official KOReader v2026.07.1 (Kindle)

Install
-------
1. Install the official KOReader v2026.07.1 Kindle release.
2. Extract this archive onto the Kindle USB root and merge the koreader folder.
3. Fully restart KOReader.
4. Open a reflowable document and use Top menu > Page-level Knuth justification.

The overlay does not replace the official libs/libkoreader-cre.so. An early
startup patch loads the bundled version-locked engine under a separate name.
If KOReader is not exactly v2026.07.1, the overlay refuses to load and KOReader
falls back to its stock CREngine. Install a newly matched overlay after an
official update.

Included features
-----------------
- page-level word-spacing optimization with bounded refinement passes
- one weighted baseline word gap shared by the paragraphs on each page
- free automatic and explicit hyphenation, including repeated hyphens
- hanging-punctuation-aware optical width and word-spacing metrics
- equal word spacing with fractional remainder handled by microtracking
- preservation of forced chapter/page boundaries across rerenders
- optional centering of nearly full pages
- current-book settings captured by the official Profiles plugin

This overlay intentionally preserves stock v2026.07.1 kerning behavior. It does
not include the separate, unmerged fractional-kerning PR.

Uninstall
---------
Remove these overlay-owned paths and restart KOReader:

  koreader/libs/libkoreader-cre-knuth-page-v2026.07.1.so
  koreader/patches/10-knuth-cre.lua
  koreader/patches/11-knuth-profiles.lua
  koreader/plugins/knuthjustification.koplugin/
