KOReader v2026.07.1 all-in-one Kindle package
Page-level Knuth justification + fractional best kerning + Literata

Install
-------
1. Extract this archive onto the Kindle USB root.
2. Merge and replace files when prompted. Do not delete your existing
   koreader directory first; that preserves settings and reading history.
3. Fully restart KOReader through KUAL.
4. Open a reflowable document.
5. Open Top menu > Page-level Knuth justification and select either:

   Literata 16 pt · Best/High · Greedy
   Literata 16 pt · Best/High · Page-level

Both comparison presets use the bundled Literata family, 16 pt, Best HarfBuzz
kerning, High fractional precision, forced justification, hanging punctuation,
and identical spacing limits. The second preset additionally enables page-level
Knuth optimization.

Included
--------
- complete official KOReader v2026.07.1 Kindle package and KUAL launcher
- live CREngine PR #685 head e229b669 (fractional positioning strength)
- page-level Knuth refinement with weighted baseline word spacing
- free automatic, explicit, consecutive and final-adjacent hyphenation
- hanging-punctuation-aware optical metrics
- Literata upright and italic variable fonts from Google Fonts, under OFL-1.1
- legacy 4/8/16/32/64 kerning-setting migration
- Profiles support for both Knuth and fractional-kerning settings

The stock official libkoreader-cre.so remains present. A version-locked startup
patch loads the bundled combined engine under a separate filename. After an
official KOReader update, the old engine refuses to load and KOReader safely
falls back to stock until a matching combined package is installed.
