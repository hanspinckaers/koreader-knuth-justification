local function read(path)
    local file = assert(io.open(path, "rb"))
    local contents = assert(file:read("*a"))
    file:close()
    return contents
end

local options = read("combined/frontend/ui/data/creoptions.lua")
local readerfont = read("combined/frontend/apps/reader/modules/readerfont.lua")
local credocument = read("combined/frontend/document/credocument.lua")
local profiles = read("combined/plugins/profiles.koplugin/main.lua")
local packager = read("scripts/package-combined-kindle.sh")
local formatter = read("combined/native/overlay/crengine/src/lvtextfm.cpp")

assert(options:find('name = "line_breaking_mode"', 1, true))
assert(options:find('name_text = _("Page-level Justification")', 1, true))
assert(options:find('values = {0, 1, 2, 3}', 1, true))
assert(options:find('name_text = _("Kerning Precision")', 1, true))
assert(options:find('default_value = {1, 0}', 1, true))
assert(not options:find("Raster Target", 1, true))
assert(not options:find("Font Sharpness", 1, true))

assert(readerfont:find("setLineBreakingMode", 1, true))
assert(readerfont:find("setJustificationWordSpacing", 1, true))
assert(readerfont:find("setJustificationLetterSpacing(self.configurable.justification_letter_spacing)", 1, true))
assert(readerfont:find("setJustificationTrackingSmoothness(self.configurable.justification_tracking_smoothness)", 1, true))
assert(readerfont:find("justification_hyphen_penalty = { 0, 0 }", 1, true))
assert(readerfont:find("justification_hyphen_demerits = { 0, 0 }", 1, true))
assert(credocument:find('"crengine.style.line.breaking.mode"', 1, true))
assert(credocument:find('"crengine.page.center.nearly.full"', 1, true))
assert(formatter:find("knuthTrackingMagnitudeCost", 1, true))
assert(formatter:find("optical_slack", 1, true))

local fontman = read("combined/native/overlay/crengine/src/lvfntman.cpp")
assert(fontman:find("knuthDistributedTrackingX64", 1, true))
assert(fontman:find("tracking_width_done_x64", 1, true))

assert(profiles:find('"line_breaking_mode"', 1, true))
assert(profiles:find('"font_fractional_positioning"', 1, true))
assert(profiles:find('"center_nearly_full_pages"', 1, true))

assert(packager:find('koreader/libs/libkoreader%-cre%.so'))
assert(not packager:find("knuthjustification.koplugin", 1, true))

print("combined core integration tests passed")
