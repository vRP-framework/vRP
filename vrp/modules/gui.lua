-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.gui then return end

local IDManager = module("vrp", "lib/IDManager")
local htmlEntities = module("vrp", "lib/htmlEntities")
local EventDispatcher = module("vrp", "lib/EventDispatcher")
local lang = vRP.lang

-- Menu
local Menu = class("Menu", EventDispatcher)

function Menu:__construct(user, name, data)
  EventDispatcher.__construct(self)

  self.user = user
  self.name = name
  self.data = data -- build data 
end

-- dispatcher events:
--- close(menu)
--- remove(menu)
--- select(menu, id)
function Menu:listen(name, callback)
  if name == "select" then
    if not self.event_listeners["select"] then
      if self.user:getMenu() == self then -- is current menu
        vRP.EXT.GUI.remote._setMenuSelectEvent(self.user.source, true)
      end
    end
  end

  EventDispatcher.listen(self, name, callback)
end

function Menu:initialize()
  self.title = htmlEntities.encode("<"..self.name..">")
  self.options = {}
  self.css = {} -- {.header_color}
  self.closed = false
end

function Menu:serializeNet()
  -- prepare network data
  local data = {
    options = {},
    title = self.title,
    css = self.css,
    select_event = (self.event_listeners["select"] ~= nil)
  }

  -- titles
  for k,v in pairs(self.options) do
    data.options[k] = {v[1], v[3]} -- title, description
  end

  return data
end

function Menu:triggerClose()
  if not self.closed then
    self.closed = true

    -- trigger close event
    self:triggerEvent("close", self)
  end
end

function Menu:triggerSelect(id)
  if self.options[id] then
    self:triggerEvent("select", self, id)
  end
end

function Menu:triggerOption(id, mod)
  local option = self.options[id]
  if option and option[2] then
    option[2](self, option[4], mod, id)
  end
end

-- update menu option
-- title: (optional) as Menu:addOption
-- description: (optional) as Menu:addOption
-- will trigger client update if current menu
function Menu:updateOption(id, title, description)
  local option = self.options[id]
  if option then
    if title then option[1] = title end
    if description then option[3] = description end

    if self.user:getMenu() == self then -- current menu
      vRP.EXT.GUI.remote._updateMenuOption(self.user.source, id, title, description)
    end
  end
end

-- add option
-- title: option title (html)
-- action(menu, value, mod, index): (optional) select callback
--- value: option value
--- mod: action modulation
---- -1: left
---- 0: valid
---- 1: right
-- description: (optional) option description (html)
--- callback(menu, value): should return a string or nil
-- value: (optional) option value, can be anything, option index by default
-- index: (optional) by default the option is added at the end, but an index can be used to insert the option
function Menu:addOption(title, action, description, value, index)
  if index then
    table.insert(self.options, index, {title, action, description, value or #self.options+1})
  else
    table.insert(self.options, {title, action, description, value or #self.options+1})
  end
end

-- Extension

local GUI = class("GUI", vRP.Extension)

-- SUBCLASS

GUI.User = class("User")

function GUI.User:__construct()
  self.menu_stack = {} -- stack of menus
  self.request_ids = IDManager()
  self.requests = {}
end

-- return current menu or nil
function GUI.User:getMenu()
  local size = #self.menu_stack 
  if size > 0 then
    return self.menu_stack[size]
  end
end

-- open menu (build and open menu)
-- data: (optional) menu build data 
-- return menu
function GUI.User:openMenu(name, data)
  local menu = Menu(self, name, data or {})

  -- build menu
  menu:initialize()
  vRP.EXT.GUI:buildMenu(menu)

  -- add to stack, mark as current
  table.insert(self.menu_stack, menu)
  menu.stack_index = #self.menu_stack

  -- open client menu
  vRP.EXT.GUI.remote._openMenu(self.source, menu:serializeNet())

  -- trigger close on previous menu if exists
  local size = #self.menu_stack
  if size > 1 then
    local prev_menu = self.menu_stack[size-1]
    prev_menu:triggerClose()
  end

  return menu
end

-- close menu
-- menu: (optional) menu to close, if nil, will close the current menu
function GUI.User:closeMenu(menu)
  if not menu then menu = self:getMenu() end

  if menu and self.menu_stack[menu.stack_index] == menu then -- valid menu
    menu:triggerClose() -- close event
    menu:triggerEvent("remove", menu) -- remove event

    local current = (menu.stack_index == #self.menu_stack)
    if current then -- current client menu, close event
      vRP.EXT.GUI.remote._closeMenu(self.source)
    end

    -- decrement next menu stack indexes
    for i=menu.stack_index+1,#self.menu_stack do
      local nmenu = self.menu_stack[i]
      nmenu.stack_index = nmenu.stack_index-1
    end

    -- remove from stack
    table.remove(self.menu_stack, menu.stack_index)

    -- re-open previous menu
    if current then
      self:actualizeMenu()
    end
  end
end

-- close and rebuild current menu (no remove)
-- menu is rebuilt, listeners are kept
function GUI.User:actualizeMenu()
  local menu = self:getMenu()
  if menu then
    menu:triggerClose()
    menu:initialize()
    vRP.EXT.GUI:buildMenu(menu)
    vRP.EXT.GUI.remote._openMenu(self.source, menu:serializeNet())
  end
end

-- close all menus
function GUI.User:closeMenus()
  repeat
    self:closeMenu()
  until not self:getMenu()
end

-- prompt textual (and multiline) information from player
-- return entered text
function GUI.User:prompt(title, default_text)
  local r = async()
  self.prompt_r = r

  vRP.EXT.GUI.remote._prompt(self.source, title, default_text)

  return r:wait()
end

-- REQUEST

-- ask something to a player with a limited amount of time to answer (yes|no request)
-- time: request duration in seconds
-- return true (yes) or false (no)
function GUI.User:request(text, time)
  local r = async()

  local id = self.request_ids:gen()
  local request = {r = r, done = false}
  self.requests[id] = request

  vRP.EXT.GUI.remote._request(self.source,id,text,time) -- send request to client

  -- end request with a timeout if not already ended
  SetTimeout(time*1000,function()
    if not request.done then
      request.r(false) -- negative response
      self.request_ids:free(id)
      self.requests[id] = nil
    end
  end)

  return r:wait()
end

-- METHODS

function GUI:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/gui")
  self.menu_builders = {} -- map of name => callbacks list

  self:registerMenuBuilder("main", function(menu)
    menu.title = lang.common.menu.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"
  end)
end

-- MENU

-- GENERIC MENU BUILDER

-- register a menu builder function
-- name: menu type name
-- builder(menu): callback to modify the menu
function GUI:registerMenuBuilder(name, builder)
  local mbuilders = self.menu_builders[name]
  if not mbuilders then
    mbuilders = {}
    self.menu_builders[name] = mbuilders
  end

  table.insert(mbuilders, builder)
end

-- build a menu
function GUI:buildMenu(menu)
  local mbuilders = self.menu_builders[menu.name]

  if mbuilders then
    for _,builder in ipairs(mbuilders) do -- trigger builders
      builder(menu)
    end
  end
end

-- EVENT
GUI.event = {}

function GUI.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- load additional css using the div api
    self.remote._setDiv(user.source, "additional_css",".div_additional_css{ display: none; }\n\n"..self.cfg.css,"")

    -- load static menus
    --[[
    for k,v in pairs(self.cfg.static_menus) do
      local mtype,x,y,z = table.unpack(v)
      local smenu = self.cfg.static_menu_types[mtype]

      if smenu then
        local function smenu_enter(user)
          if vRP.hasPermissions(user_id,smenu.permissions or {}) then
            -- build static menu
            local menu = vRP.buildMenu("static:"..k, {player=source})
            menu.name=v.title
            menu.css={top="75px",header_color="rgba(255,226,0,0.75)"}

            -- open
            vRP.openMenu(source,menu) 
          end
        end

        local function smenu_leave(source)
          vRP.closeMenu(source)
        end

        vRPclient._addBlip(source,x,y,z,smenu.blipid,smenu.blipcolor,smenu.title)
        vRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,255,226,0,125,150)

        vRP.setArea(source,"vRP:static_menu:"..k,x,y,z,1,1.5,smenu_enter,smenu_leave)
      end
    end
    --]]
  end
end

function GUI.event:playerLeave(user)
  user:closeMenus()
end

function GUI.event:characterUnload(user)
  user:closeMenus()
end

-- TUNNEL
GUI.tunnel = {}

-- close current menu
function GUI.tunnel:closeMenu()
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    user:closeMenu()
  end
end

function GUI.tunnel:triggerMenuOption(id, mod)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local menu = user:getMenu()
    if menu then
      menu:triggerOption(id, mod)
    end
  end
end

function GUI.tunnel:triggerMenuSelect(id)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local menu = user:getMenu()
    if menu then
      menu:triggerSelect(id)
    end
  end
end

-- receive prompt result
function GUI.tunnel:promptResult(text)
  local user = vRP.users_by_source[source]
  
  if user and user:isReady() then
    local r = user.prompt_r
    if r then
      user.prompt_r = nil
      r(text or "")
    end
  end
end

-- receive request result
function GUI.tunnel:requestResult(id,ok)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local request = user.requests[id]
    if request then -- end request
      request.done = true -- set done, the timeout will not call the callback a second time
      request.r(not not ok) -- callback
      user.request_ids:free(id)
      user.requests[id] = nil
    end
  end
end

-- open the general player menu
function GUI.tunnel:openMainMenu()
  local user = vRP.users_by_source[source]
  if user and user:isReady() then
    user:openMenu("main")
  end
end

vRP:registerExtension(GUI)
