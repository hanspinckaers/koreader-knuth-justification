if rawget(_G, "G_KNUTH_CRE_API") ~= 1 then
    return { disabled = true }
end

local Dispatcher = require("dispatcher")
local Event = require("ui/event")
local Notification = require("ui/widget/notification")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local util = require("util")
local _ = require("gettext")
local C_ = _.pgettext
local T = require("ffi/util").template

local KnuthJustification = WidgetContainer:extend{
    name = "knuthjustification",
    is_doc_only = true,
}

local options = {
    {
        name = "line_breaking_mode",
        event = "SetLineBreakingMode",
        title = _("Optimized justification"),
        default = 0,
        values = { 0, 1 },
        labels = { C_("Line breaking", "greedy"), C_("Line breaking", "optimized") },
        properties = { "crengine.style.line.breaking.mode" },
    },
    {
        name = "page_center_nearly_full",
        event = "SetPageCenterNearlyFull",
        title = _("Center nearly full pages"),
        default = 1,
        values = { 0, 1 },
        labels = { _("off"), _("on") },
        properties = { "crengine.page.center.nearly.full" },
        direct_toggle = true,
    },
    {
        name = "justification_word_spacing",
        event = "SetJustificationWordSpacing",
        title = _("Word-space limits"),
        default = { 33, 50 },
        values = { { 25, 35 }, { 33, 50 }, { 40, 75 } },
        labels = {
            C_("Justification spacing", "tight"),
            C_("Justification spacing", "balanced"),
            C_("Justification spacing", "loose"),
        },
        properties = {
            "crengine.style.justify.space.shrink.percent",
            "crengine.style.justify.space.stretch.percent",
        },
        left_text = _("Max −"), left_min = 0, left_max = 100, left_step = 1, left_hold_step = 5,
        right_text = _("Max +"), right_min = 0, right_max = 200, right_step = 1, right_hold_step = 5,
        unit = "%",
        info = _([[Maximum contraction and expansion of every adjustable word space, as percentages of its natural width. Every adjustable gap on a line receives the same width.]]),
    },
    {
        name = "justification_letter_spacing",
        event = "SetJustificationLetterSpacing",
        title = _("Letter-space limits"),
        default = { 1, 0 },
        values = { { 0, 0 }, { 1, 0 }, { 1, 1 } },
        labels = {
            C_("Letter spacing", "off"),
            C_("Letter spacing", "never expand"),
            C_("Letter spacing", "bidirectional"),
        },
        properties = {
            "crengine.style.justify.tracking.shrink.percent",
            "crengine.style.justify.tracking.stretch.percent",
        },
        left_text = _("Max −"), left_min = 0, left_max = 20, left_step = 1, left_hold_step = 2,
        right_text = _("Max +"), right_min = 0, right_max = 20, right_step = 1, right_hold_step = 2,
        unit = "%",
        info = _([[Maximum negative and positive line-wide microtracking. “Never expand” permits contraction but keeps positive tracking disabled.]]),
    },
    {
        name = "justification_tracking_smoothness",
        event = "SetJustificationTrackingSmoothness",
        title = _("Letter-space smoothness"),
        default = 50,
        values = { 0, 25, 50, 100 },
        labels = {
            C_("Adjacent-line letter spacing", "off"),
            C_("Adjacent-line letter spacing", "strict"),
            C_("Adjacent-line letter spacing", "smooth"),
            C_("Adjacent-line letter spacing", "relaxed"),
        },
        properties = { "crengine.style.justify.tracking.delta.max.bp" },
        value_min = 0, value_max = 1000, value_step = 5, value_hold_step = 25,
        info = _([[Maximum change in normalized letter spacing between consecutive justified lines, stored in basis points. 50 means 0.50 percentage points.]]),
    },
    {
        name = "justification_tolerance",
        event = "SetJustificationTolerance",
        title = _("Fit tolerance"),
        default = { 100, 200 },
        values = { { 50, 100 }, { 100, 200 }, { 200, 500 } },
        labels = {
            C_("Fit tolerance", "strict"),
            C_("Fit tolerance", "balanced"),
            C_("Fit tolerance", "forgiving"),
        },
        properties = {
            "crengine.style.justify.pretolerance",
            "crengine.style.justify.tolerance",
        },
        left_text = _("Before hyphens"), left_min = 0, left_max = 10000, left_step = 10, left_hold_step = 100,
        right_text = _("With hyphens"), right_min = 0, right_max = 10000, right_step = 10, right_hold_step = 100,
        info = _([[Pretolerance is used by the first pass without automatic hyphenation. Tolerance is used by later passes with hyphenation.]]),
    },
    {
        name = "justification_hyphen_penalty",
        event = "SetJustificationHyphenPenalty",
        title = _("Hyphen penalties"),
        default = { 50, 50 },
        values = { { 25, 25 }, { 50, 50 }, { 100, 100 } },
        labels = {
            C_("Hyphen penalty", "frequent"),
            C_("Hyphen penalty", "balanced"),
            C_("Hyphen penalty", "rare"),
        },
        properties = {
            "crengine.style.justify.hyphen.penalty",
            "crengine.style.justify.explicit.hyphen.penalty",
        },
        left_text = _("Automatic"), left_min = 0, left_max = 100000, left_step = 10, left_hold_step = 100,
        right_text = _("Explicit"), right_min = 0, right_max = 100000, right_step = 10, right_hold_step = 100,
        info = _([[Cost of a break at an automatically inserted hyphen and at a hyphen already present in the text.]]),
    },
    {
        name = "justification_line_penalty",
        event = "SetJustificationLinePenalty",
        title = _("Line-quality penalties"),
        default = { 10, 10000 },
        values = { { 10, 5000 }, { 10, 10000 }, { 10, 20000 } },
        labels = {
            C_("Line quality", "relaxed"),
            C_("Line quality", "balanced"),
            C_("Line quality", "smooth"),
        },
        properties = {
            "crengine.style.justify.line.penalty",
            "crengine.style.justify.adjacent.demerits",
        },
        left_text = _("Line"), left_min = 0, left_max = 10000, left_step = 1, left_hold_step = 10,
        right_text = _("Adjacent fit"), right_min = 0, right_max = 100000, right_step = 100, right_hold_step = 1000,
        info = _([[Base line penalty and extra demerits for neighbouring lines whose spacing classes differ sharply.]]),
    },
    {
        name = "justification_hyphen_demerits",
        event = "SetJustificationHyphenDemerits",
        title = _("Repeated-hyphen penalties"),
        default = { 10000, 5000 },
        values = { { 1000, 500 }, { 10000, 5000 }, { 20000, 10000 } },
        labels = {
            C_("Repeated hyphens", "allow"),
            C_("Repeated hyphens", "balanced"),
            C_("Repeated hyphens", "avoid"),
        },
        properties = {
            "crengine.style.justify.double.hyphen.demerits",
            "crengine.style.justify.final.hyphen.demerits",
        },
        left_text = _("Consecutive"), left_min = 0, left_max = 100000, left_step = 100, left_hold_step = 1000,
        right_text = _("Before ending"), right_min = 0, right_max = 100000, right_step = 100, right_hold_step = 1000,
        info = _([[Extra demerits for consecutive hyphenated lines and for a hyphen immediately before the final line.]]),
    },
    {
        name = "justification_line_limits",
        event = "SetJustificationLineLimits",
        title = _("Emergency & ending"),
        default = { 6, 33 },
        values = { { 6, 0 }, { 6, 33 }, { 8, 50 } },
        labels = {
            C_("Paragraph ending", "natural"),
            C_("Paragraph ending", "balanced"),
            C_("Paragraph ending", "long"),
        },
        properties = {
            "crengine.style.justify.emergency.stretch.percent",
            "crengine.style.justify.last.line.min.percent",
        },
        left_text = _("Emergency"), left_min = 0, left_max = 100, left_step = 1, left_hold_step = 5,
        right_text = _("Ending min"), right_min = 0, right_max = 100, right_step = 1, right_hold_step = 5,
        unit = "%",
        info = _([[Emergency stretch is used only when normal passes fail. Ending minimum prefers a final line at least this percentage of the measure.]]),
    },
}

local options_by_name = {}
for _, option in ipairs(options) do
    options_by_name[option.name] = option
end

local function copy(value)
    return type(value) == "table" and util.tableDeepCopy(value) or value
end

local function same(a, b)
    if type(a) == "table" and type(b) == "table" then
        return util.tableEquals(a, b)
    end
    return a == b
end

local function formatValue(option, value)
    if type(value) == "table" then
        if option.unit == "%" then
            return T("%1% / %2%", value[1], value[2])
        end
        return T("%1 / %2", value[1], value[2])
    end
    if option.name == "justification_tracking_smoothness" then
        return value == 0 and _("off") or string.format("%.2f%%", value / 100)
    end
    if option.direct_toggle then
        return value == 1 and _("on") or _("off")
    end
    return tostring(value)
end

function KnuthJustification:onDispatcherRegisterActions()
    for _, option in ipairs(options) do
        Dispatcher:registerAction(option.name, {
            category = "string",
            event = option.event,
            title = option.title,
            args = option.values,
            toggle = option.labels,
            configurable = { name = option.name, values = option.values },
            rolling = true,
        })
    end
end

function KnuthJustification:init()
    self.values = {}
    self:onDispatcherRegisterActions()
    if self.ui.rolling and self.ui.document and self.ui.document._document then
        self.ui.menu:registerToMainMenu(self)
    end
end

function KnuthJustification:readValue(config, option)
    local value = config:readSetting("copt_" .. option.name)
    if value == nil then
        value = G_reader_settings:readSetting("copt_" .. option.name)
    end
    if value == nil then
        value = option.default
    end
    if type(option.default) == "table" then
        if type(value) ~= "table" or type(value[1]) ~= "number" or type(value[2]) ~= "number" then
            value = option.default
        end
    elseif type(value) ~= "number" then
        value = option.default
    end
    return copy(value)
end

function KnuthJustification:applyOption(option, value)
    if not self.ui.document or not self.ui.document._document then return end
    if #option.properties == 1 then
        self.ui.document._document:setIntProperty(option.properties[1], value)
    else
        self.ui.document._document:setIntProperty(option.properties[1], value[1])
        self.ui.document._document:setIntProperty(option.properties[2], value[2])
    end
end

function KnuthJustification:onReadSettings(config)
    if not self.ui.rolling or not self.ui.document._document then return end
    for _, option in ipairs(options) do
        local value = self:readValue(config, option)
        self.values[option.name] = value
        self.ui.document.configurable[option.name] = copy(value)
        self:applyOption(option, value)
    end
end

function KnuthJustification:setValue(name, value, quiet)
    local option = options_by_name[name]
    if not option then return end
    value = copy(value)
    self.values[name] = value
    self.ui.document.configurable[name] = copy(value)
    self.ui.doc_settings:saveSetting("copt_" .. name, copy(value))
    self:applyOption(option, value)
    self.ui:handleEvent(Event:new("UpdatePos"))
    if not quiet then
        Notification:notify(T(_("%1: %2"), option.title, formatValue(option, value)))
    end
    return true
end

function KnuthJustification:makeDefault(name, value)
    G_reader_settings:saveSetting("copt_" .. name, copy(value))
    Notification:notify(T(_("Default %1: %2"), options_by_name[name].title,
        formatValue(options_by_name[name], value)))
end

function KnuthJustification:showPairWidget(option)
    local DoubleSpinWidget = require("ui/widget/doublespinwidget")
    local value = self.values[option.name]
    UIManager:show(DoubleSpinWidget:new{
        title_text = option.title,
        info_text = option.info,
        width_factor = 0.8,
        left_text = option.left_text,
        left_value = value[1],
        left_min = option.left_min,
        left_max = option.left_max,
        left_step = option.left_step,
        left_hold_step = option.left_hold_step,
        right_text = option.right_text,
        right_value = value[2],
        right_min = option.right_min,
        right_max = option.right_max,
        right_step = option.right_step,
        right_hold_step = option.right_hold_step,
        left_default = option.default[1],
        right_default = option.default[2],
        unit = option.unit,
        keep_shown_on_apply = true,
        callback = function(left, right)
            self:setValue(option.name, { left, right })
        end,
        extra_text = _("Set as default"),
        extra_callback = function(left, right)
            self:makeDefault(option.name, { left, right })
        end,
    })
end

function KnuthJustification:showSingleWidget(option)
    local SpinWidget = require("ui/widget/spinwidget")
    UIManager:show(SpinWidget:new{
        title_text = option.title,
        info_text = option.info,
        width_factor = 0.7,
        value = self.values[option.name],
        value_min = option.value_min,
        value_max = option.value_max,
        value_step = option.value_step,
        value_hold_step = option.value_hold_step,
        default_value = option.default,
        keep_shown_on_apply = true,
        callback = function(widget)
            self:setValue(option.name, widget.value)
        end,
        extra_text = _("Set as default"),
        extra_callback = function(widget)
            self:makeDefault(option.name, widget.value)
        end,
    })
end

function KnuthJustification:getPresetMenu(option)
    local menu = {}
    for i, preset in ipairs(option.values) do
        table.insert(menu, {
            text = option.labels[i],
            radio = true,
            checked_func = function()
                return same(self.values[option.name], preset)
            end,
            callback = function()
                self:setValue(option.name, preset)
            end,
        })
    end
    table.insert(menu, {
        text_func = function()
            return T(_("Custom… (%1)"), formatValue(option, self.values[option.name]))
        end,
        separator = true,
        callback = function()
            if type(option.default) == "table" then
                self:showPairWidget(option)
            else
                self:showSingleWidget(option)
            end
        end,
    })
    return menu
end

function KnuthJustification:getMenuTable()
    local menu = {
        {
            text = _("Use optimized paragraph breaking"),
            checked_func = function()
                return self.values.line_breaking_mode == 1
            end,
            callback = function()
                self:setValue("line_breaking_mode",
                    self.values.line_breaking_mode == 1 and 0 or 1)
            end,
            separator = true,
        },
    }
    for i = 2, #options do
        local option = options[i]
        if option.direct_toggle then
            table.insert(menu, {
                text = option.title,
                checked_func = function()
                    return self.values[option.name] == 1
                end,
                callback = function()
                    self:setValue(option.name,
                        self.values[option.name] == 1 and 0 or 1)
                end,
                separator = true,
            })
        else
            table.insert(menu, {
                text_func = function()
                    return T(_("%1: %2"), option.title, formatValue(option, self.values[option.name]))
                end,
                enabled_func = function()
                    return self.values.line_breaking_mode == 1
                end,
                sub_item_table_func = function()
                    return self:getPresetMenu(option)
                end,
            })
        end
    end
    table.insert(menu, {
        text = _("Hanging punctuation is controlled under Typography rules and is included in optimized line-width calculations."),
        enabled = false,
        separator = true,
    })
    return menu
end

function KnuthJustification:addToMainMenu(menu_items)
    menu_items.knuth_justification = {
        text_func = function()
            local state = self.values.line_breaking_mode == 1 and _("on") or _("off")
            return T(_("Knuth justification (%1)"), state)
        end,
        sorting_hint = "typeset",
        sub_item_table_func = function()
            return self:getMenuTable()
        end,
    }
end

function KnuthJustification:onSetLineBreakingMode(value)
    return self:setValue("line_breaking_mode", value)
end

function KnuthJustification:onSetPageCenterNearlyFull(value)
    return self:setValue("page_center_nearly_full", value)
end

function KnuthJustification:onSetJustificationWordSpacing(value)
    return self:setValue("justification_word_spacing", value)
end

function KnuthJustification:onSetJustificationLetterSpacing(value)
    return self:setValue("justification_letter_spacing", value)
end

function KnuthJustification:onSetJustificationTrackingSmoothness(value)
    return self:setValue("justification_tracking_smoothness", value)
end

function KnuthJustification:onSetJustificationTolerance(value)
    return self:setValue("justification_tolerance", value)
end

function KnuthJustification:onSetJustificationHyphenPenalty(value)
    return self:setValue("justification_hyphen_penalty", value)
end

function KnuthJustification:onSetJustificationLinePenalty(value)
    return self:setValue("justification_line_penalty", value)
end

function KnuthJustification:onSetJustificationHyphenDemerits(value)
    return self:setValue("justification_hyphen_demerits", value)
end

function KnuthJustification:onSetJustificationLineLimits(value)
    return self:setValue("justification_line_limits", value)
end

return KnuthJustification
