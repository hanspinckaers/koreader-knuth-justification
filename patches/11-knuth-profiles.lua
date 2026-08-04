if rawget(_G, "G_KNUTH_CRE_API") ~= 1 then
    return
end

local userpatch = require("userpatch")

local setting_names = {
    "line_breaking_mode",
    "page_center_nearly_full",
    "justification_word_spacing",
    "justification_letter_spacing",
    "justification_tracking_smoothness",
    "justification_tolerance",
    "justification_hyphen_penalty",
    "justification_line_penalty",
    "justification_hyphen_demerits",
    "justification_line_limits",
}

userpatch.registerPatchPluginFunc("profiles", function(plugin)
    local original = plugin.getProfileFromCurrentBookSettings
    plugin.getProfileFromCurrentBookSettings = function(self, new_name)
        local profile = original(self, new_name)
        if not self.ui.rolling then
            return profile
        end
        for _, name in ipairs(setting_names) do
            local value = self.document.configurable[name]
            if value ~= nil then
                table.insert(profile.settings.order, name)
                profile[name] = value
            end
        end
        return profile
    end
end)
