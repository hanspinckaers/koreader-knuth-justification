-- Compatibility tombstone for the earlier overlay package.
-- The core build installs the combined CREngine as libs/libkoreader-cre.so.
-- Do not preload the old side-by-side module.
G_KNUTH_CRE_API = nil
G_KNUTH_CRE_RELEASE = nil
