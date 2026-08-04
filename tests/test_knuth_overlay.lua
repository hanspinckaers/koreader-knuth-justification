package.preload = package.preload or {}
package.loaded = package.loaded or {}
local original_require = require
function require(name)
    if package.loaded[name] ~= nil then return package.loaded[name] end
    if package.preload[name] then
        local value = package.preload[name](name)
        if value == nil then value = true end
        package.loaded[name] = value
        return value
    end
    return original_require(name)
end

local function reset(name)
    package.loaded[name] = nil
    package.preload[name] = nil
end

-- Exact-version loader registration without loading the ARM binary on the host.
local loaded_path
local loaded_symbol
package.loadlib = function(path, symbol)
    loaded_path = path
    loaded_symbol = symbol
    return function() return {} end
end
package.preload.version = function()
    return { getCurrentRevision = function() return "v2026.07.1" end }
end
dofile("patches/10-knuth-cre.lua")
assert(G_KNUTH_CRE_API == 1)
assert(G_KNUTH_CRE_RELEASE == "v2026.07.1")
assert(loaded_path == "./libs/libkoreader-cre-knuth-v2026.07.1.so")
assert(loaded_symbol == "luaopen_cre")
assert(type(package.preload["libs/libkoreader-cre"]) == "function")

-- A later official version must fall back to stock CREngine.
G_KNUTH_CRE_API = nil
G_KNUTH_CRE_RELEASE = nil
package.preload["libs/libkoreader-cre"] = nil
reset("version")
package.preload.version = function()
    return { getCurrentRevision = function() return "v2026.08" end }
end
dofile("patches/10-knuth-cre.lua")
assert(G_KNUTH_CRE_API == nil)
assert(package.preload["libs/libkoreader-cre"] == nil)

-- Profiles extension preserves the official method and appends plugin settings.
G_KNUTH_CRE_API = 1
local profile_patch
reset("userpatch")
package.preload.userpatch = function()
    return {
        registerPatchPluginFunc = function(name, callback)
            assert(name == "profiles")
            profile_patch = callback
        end,
    }
end
dofile("patches/11-knuth-profiles.lua")
assert(type(profile_patch) == "function")
local profiles = {
    ui = { rolling = true },
    document = { configurable = {
        line_breaking_mode = 1,
        page_center_nearly_full = 1,
        justification_word_spacing = { 33, 50 },
    } },
    getProfileFromCurrentBookSettings = function(_, name)
        return { settings = { name = name, order = { "font_size" } }, font_size = 16 }
    end,
}
profile_patch(profiles)
local profile = profiles:getProfileFromCurrentBookSettings("book")
assert(profile.settings.order[1] == "font_size")
assert(profile.line_breaking_mode == 1)
assert(profile.page_center_nearly_full == 1)
assert(profile.justification_word_spacing[1] == 33)

-- Minimal plugin lifecycle and native-property application.
local actions = {}
package.preload.dispatcher = function()
    return { registerAction = function(_, name, action) actions[name] = action end }
end
package.preload["ui/event"] = function()
    return { new = function(_, name) return { name = name } end }
end
package.preload["ui/widget/notification"] = function()
    return { notify = function() end }
end
package.preload["ui/uimanager"] = function()
    return { show = function() end }
end
package.preload["ui/widget/container/widgetcontainer"] = function()
    local base = {}
    function base:extend(class)
        class.__index = class
        setmetatable(class, { __index = self })
        function class:new(value)
            value = value or {}
            setmetatable(value, class)
            if value.init then value:init() end
            return value
        end
        return class
    end
    return base
end
package.preload.util = function()
    local function deepcopy(value)
        if type(value) ~= "table" then return value end
        local result = {}
        for key, item in pairs(value) do result[key] = deepcopy(item) end
        return result
    end
    local function equals(a, b)
        if type(a) ~= type(b) then return false end
        if type(a) ~= "table" then return a == b end
        for key, value in pairs(a) do if not equals(value, b[key]) then return false end end
        for key in pairs(b) do if a[key] == nil then return false end end
        return true
    end
    return { tableDeepCopy = deepcopy, tableEquals = equals }
end
package.preload.gettext = function()
    local gettext = { pgettext = function(_, text) return text end }
    return setmetatable(gettext, { __call = function(_, text) return text end })
end
package.preload["ffi/util"] = function()
    return { template = function(text) return text end }
end

G_reader_settings = {
    readSetting = function() return nil end,
    saveSetting = function() end,
}
local properties = {}
local saved = {}
local config = {
    readSetting = function(_, name) return saved[name] end,
    saveSetting = function(_, name, value) saved[name] = value end,
}
saved.copt_line_breaking_mode = 1
saved.copt_justification_word_spacing = { 29, 47 }
local document = {
    configurable = {},
    _document = { setIntProperty = function(_, name, value) properties[name] = value end },
}
local ui = {
    rolling = {},
    document = document,
    doc_settings = config,
    menu = { registerToMainMenu = function() end },
    handleEvent = function() end,
}
local plugin_class = dofile("plugins/knuthjustification.koplugin/main.lua")
local plugin = plugin_class:new{ ui = ui }
plugin:onReadSettings(config)
assert(properties["crengine.style.line.breaking.mode"] == 1)
assert(properties["crengine.style.justify.space.shrink.percent"] == 29)
assert(properties["crengine.style.justify.space.stretch.percent"] == 47)
assert(properties["crengine.page.center.nearly.full"] == 1)
assert(actions.line_breaking_mode.event == "SetLineBreakingMode")
assert(actions.page_center_nearly_full.event == "SetPageCenterNearlyFull")

print("Knuth official overlay tests passed")
