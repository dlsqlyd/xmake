--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2018, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        menuconf.lua
--

-- load modules
local log       = require("ui/log")
local view      = require("ui/view")
local rect      = require("ui/rect")
local panel     = require("ui/panel")
local event     = require("ui/event")
local action    = require("ui/action")
local curses    = require("ui/curses")
local button    = require("ui/button")
local object    = require("ui/object")

-- define module
local menuconf = menuconf or panel()

-- init menuconf
function menuconf:init(name, bounds)

    -- init panel
    panel.init(self, name, bounds)

    -- init configs
    self._CONFIGS = {}
end

-- on event
function menuconf:event_on(e)
 
    -- select config
    if e.type == event.ev_keyboard then
        if e.key_name == "Down" then
            return self:select_next()
        elseif e.key_name == "Up" then
            return self:select_prev()
        elseif e.key_name == "Enter" or e.key_name == " " then
            self:_do_select()
            return true
        end
    elseif e.type == event.ev_command and e.command == "cm_enter" then
        self:_do_select()
        return true
    end   
end

-- load configs
function menuconf:load(configs)

    -- clear the views first
    self:clear()

    -- insert configs
    self._CONFIGS = configs
    for _, config in ipairs(configs) do
        self:_do_insert(config)
    end

    -- select the first item
    self:select(self:first())

    -- invalidate
    self:invalidate()
end

-- do insert a config item
function menuconf:_do_insert(config)

    -- init a config item view
    local item = button:new("menuconf.config." .. self:count(), rect:new(0, self:count(), self:width(), 1), tostring(config))

    -- attach this config
    item:extra_set("config", config)

    -- insert this config item
    self:insert(item)
end

-- do select the current config
function menuconf:_do_select()

    -- TODO

    -- get the current config
    local config = self:current()
    if self:current() then
        config = self:current():extra("config")
    end

    -- do action: on selected
    self:action_on(action.ac_on_selected)
end

-- init config object
--
-- kind
--  - {kind = "number/boolean/string/choice/menu"}
--
-- description
--  - {description = "config item description"}
--  - {description = {"config item description", "line2", "line3", "more description ..."}}
--
-- boolean config
--  - {name = "...", kind = "boolean", value = true, default = true, description = "boolean config item", new = true/false}
--
-- number config
--  - {name = "...", kind = "number", value = 10, default = 0, description = "number config item", new = true/false}
--
-- string config
--  - {name = "...", kind = "string", value = "xmake", default = "", description = "string config item", new = true/false}
--
-- choice config
--  - {name = "...", kind = "choice", value = "...", default = "...", description = "choice config item", values = {1, 2, 3, 4, 5}}
--
-- menu config
--  - {name = "...", kind = "menu", description = "menu config item", configs = {...}}
--
local config = config or object {new = true}

-- to string
function config:__tostring()

    -- get text (first line in description)
    local text = self.description or ""
    if type(text) == "table" then
        text = text[1] or ""
    end

    -- get value
    local value = self.value or self.default

    -- update text
    if self.kind == "boolean" or (not self.kind and type(value) == "boolean") then -- boolean config?
        text = (value and "[*] " or "[ ] ") .. text
    elseif self.kind == "number" or (not self.kind and type(value) == "number") then -- number config?
        text = "(" .. tostring(value or 0) .. ") " .. text
    elseif self.kind == "string" or (not self.kind and type(value) == "string") then -- string config?
        text = "(" .. tostring(value or "") .. ") " .. text
    elseif self.kind == "choice" then -- choice config?
        text = "    " .. text .. " (" .. tostring(value or "") .. ")" .. "  --->"
    elseif self.kind == "menu" then -- menu config?
        text = "    " .. text .. "  --->"
    end

    -- new config?
    if self.new and self.kind ~= "choice" and self.kind ~= "menu" then
        text = text .. " (NEW)"
    end

    -- ok
    return text
end

-- save config objects
menuconf.config  = menuconf.config or config
menuconf.menu    = menuconf.menu or config { kind = "menu", configs = {} }
menuconf.number  = menuconf.number or config { kind = "number", default = 0 }
menuconf.string  = menuconf.string or config { kind = "string", default = "" }
menuconf.choice  = menuconf.choice or config { kind = "choice", values = {} }
menuconf.boolean = menuconf.boolean or config { kind = "boolean", default = false }

-- return module
return menuconf