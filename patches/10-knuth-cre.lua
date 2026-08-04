local expected_version = "v2026.07.1"
local version = require("version"):getCurrentRevision()

if version ~= expected_version then
    io.stderr:write(string.format(
        "Knuth CREngine overlay disabled: expected %s, found %s\n",
        expected_version, tostring(version)))
    return
end

local module_name = "libs/libkoreader-cre"
if package.loaded[module_name] then
    error("Knuth CREngine overlay loaded too late: stock CREngine is already active")
end

local library_path = "./libs/libkoreader-cre-knuth-page-v2026.07.1.so"
local loader, err = package.loadlib(library_path, "luaopen_cre")
if not loader then
    error("Unable to load Knuth CREngine overlay: " .. tostring(err))
end

package.preload[module_name] = loader
G_KNUTH_CRE_API = 2
G_KNUTH_CRE_RELEASE = expected_version
