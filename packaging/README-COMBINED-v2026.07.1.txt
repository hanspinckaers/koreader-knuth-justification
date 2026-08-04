KOReader v2026.07.1 integrated Kindle package
Page-level Knuth justification + fractional best kerning + Literata

Install
-------
1. Extract this archive onto the Kindle USB root.
2. Merge and replace files when prompted. Do not delete your existing
   koreader directory first; that preserves settings and reading history.
3. Fully restart KOReader through KUAL.
4. Open a reflowable document.
5. Open the normal bottom text-settings menu. Set Font to Literata, Font Size
   to 16 pt, Font Kerning to Best, Kerning Precision to High, and Page-level
   Justification to page-level. Its complete Knuth tuning controls are directly
   beside that setting.
6. Enable Hanging punctuation under the normal Typography rules menu.

There is no Knuth plugin and no plugin menu in this build. Page-level layout,
its settings, profile persistence and the matching fractional-kerning engine
are integrated into KOReader itself.

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
- normal core settings for page-level mode and every Knuth tuning parameter

This package installs its matching combined engine as the normal
libs/libkoreader-cre.so. An official KOReader update will replace it, so install
a new matching integrated package when upgrading KOReader.
