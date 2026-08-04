if rawget(_G, "G_KNUTH_CRE_API") ~= 2 then
    return
end

local userpatch = require("userpatch")

userpatch.registerPatchPluginFunc("profiles", function(plugin)
    local original = plugin.getProfileFromCurrentBookSettings
    plugin.getProfileFromCurrentBookSettings = function(self, new_name)
        local profile = original(self, new_name)
        if not self.ui.rolling then
            return profile
        end
        local value = self.document.configurable.font_fractional_positioning
        if value ~= nil then
            table.insert(profile.settings.order, "font_fractional_positioning")
            profile.font_fractional_positioning = value
        end
        return profile
    end
end)
