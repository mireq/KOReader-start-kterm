local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Device = require("device")
local logger = require("logger")
local commands = require("commands")
local _ = require("gettext")


local Kterm = WidgetContainer:new{
    name = "kindle_start_kterm",
    is_doc_only = false,
}

function Kterm:onDispatcherRegisterActions()
    Dispatcher:registerAction("startkterm_action", {category="none", event="StartKterm", title=_("Start Kterm"), general=true,})
end

function Kterm:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function Kterm:addToMainMenu(menu_items)
    menu_items.start_kterm = {
        text = _("Start Kterm"),
        sorting_hint = "more_tools",
        callback = function()
            self:startKterm("")
        end,
    }
    for key, command in pairs(commands) do
        menu_items['start_kterm_' .. key] = {
            text = command.text,
            sorting_hint = "more_tools",
            callback = function()
                self:startKterm(" " .. command.command)
            end,
        }
    end
end

function Kterm:startKterm(args)
    require("ffi/input"):closeAll()
    os.execute("killall -CONT awesome")
    os.execute("LD_LIBRARY_PATH= /mnt/us/extensions/kterm/bin/kterm.sh" .. args)
    os.execute("killall -STOP awesome")
    if Device.touch_dev ~= nil then
        Device.input.open(Device.touch_dev)
    end
    Device.input.open("fake_events")
    UIManager:nextTick(function() UIManager:setDirty("all", "full") end)
end

function Kterm:onStartKterm()
    self:startKterm("")
end


return Kterm
