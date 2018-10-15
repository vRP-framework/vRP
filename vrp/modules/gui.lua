local Tools = module("vrp", "lib/Tools")
local EventDispatcher = module("vrp", "lib/EventDispatcher")

local cfg = module("cfg/gui")

-- Menu
local Menu = class("Menu", EventDispatcher)

function Menu:__construct(name, title, data)
  EventDispatcher.__construct(self)

  self.title = title
  self.name = name
  self.data = data
  self.css = {} -- {.top, .header_color}
  self.options = {}

  self.closed = false
  self.close_callbacks = {}
end

function Menu:triggerClose()
  if not self.closed then
    self.closed = true

    -- trigger close event
    self:triggerEvent("close", self)
  end
end

function Menu:triggerOption(id, mod)
  local option = self.options[id]
  if option then
    option[2](self, option[4], mod)
  end
end

-- add option
-- title: option title
-- action(menu, value, mod): select callback
--- value: option value
--- mod: action modulation
---- -1: left
---- 0: valid
---- 1: right
-- description: (optional) option description, a string or a callback
--- callback(menu, value): should return a string or nil
-- value: (optional) option value, option index by default
function Menu:addOption(title, action, description, value)
  table.insert(self.options, {title, action, description, value or #self.options+1})
end

-- Extension

local GUI = class("GUI", vRP.Extension)

-- SUBCLASS

GUI.User = class("User")

function GUI.User:__construct()
  self.menu_stack = {} -- stack of {name, data, menu}
  self.request_ids = Tools.newIDGenerator()
  self.requests = {}
end

-- return current menu or nil
function GUI.User:getCurrentMenu()
  local size = #self.menu_stack 
  if size > 0 then
    return self.menu_stack[size]
  end
end

-- open menu (build and open menu)
-- data: (optional)
-- return menu
function GUI.User:openMenu(name, data)
  -- copy data
  local cdata = {}
  for k,v in pairs(data or {}) do
    cdata[k] = v
  end

  -- add user property
  data.user = self

  -- build menu
  local menu = vRP.EXT.GUI:buildMenu(name, data)

  -- prepare network data
  local netdata = {
    options = {},
    title = menu.title,
    css = menu.css
  }

  -- titles
  for k,v in pairs(menu.options) do
    -- compute description
    local desc = v[3]
    if type(desc) == "function" then
      desc = desc(self, v[4])
    elseif not desc then
      desc = ""
    end

    netdata.options[k] = {v[1], desc} -- title, description
  end

  -- add to stack, mark as current
  table.insert(self.menu_stack, menu)
  menu.stack_index = #self.menu_stack

  -- open client menu
  vRP.EXT.GUI.remote._openMenu(self.source, netdata)

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
  if not menu then menu = self:getCurrentMenu() end

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
      local size = #self.menu_stack
      if size > 0 then
        local prev_menu = self.menu_stack[size]
        self:openMenu(prev_menu.name, prev_menu.data)
      end
    end
  end
end

-- prompt textual (and multiline) information from player
-- return entered text
function GUI.User:prompt(title, default_text)
  local r = async()
  self.prompt_r = r

  vRP.EXT.GUI._prompt(self.source, title, default_text)

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
  requests[id] = request

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

  self.menu_builders = {}
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
--- name: menu name type
--- data: custom data table
-- return built menu
function GUI:buildMenu(name, data)
  local menu = Menu(name, "<"..name..">", data)

  local mbuilders = self.menu_builders[name]

  if mbuilders then
    for _,builder in ipairs(mbuilders) do -- trigger builders
      builder(menu)
    end
  end

  return menu
end

-- EVENT
GUI.event = {}

function GUI.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- load additional css using the div api
    self.remote._setDiv(user.source, "additional_css",".div_additional_css{ display: none; }\n\n"..self.cfg.css,"")

    -- send peer config
    self.remote._setPeerConfiguration(user.source, self.cfg.voip_peer_configuration)

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
  for i=#user.menu_stack,1,-1 do
    user.menu_stack[i]:triggerClose()
  end
end

-- TUNNEL
GUI.tunnel = {}

-- close current menu
function GUI.tunnel:closeMenu()
  local user = vRP.users_by_source[source]

  if user then
    user:closeMenu()
  end
end

function GUI.tunnel:validMenuChoice(id, mod)
  local user = vRP.users_by_source[source]

  if user then
    local menu = user:getCurrentMenu()
    if menu then
      menu:triggerOption(id, tonumber(mod))
    end
  end
end

-- receive prompt result
function GUI.tunnel:promptResult(text)
  local user = vRP.users_by_source[source]
  
  if user then
    if text == nil then
      text = ""
    end

    if self.prompt_r then
      self.prompt_r(text)
      self.prompt_r = nil
    end
  end
end

-- receive request result
function GUI.tunnel:requestResult(id,ok)
  local user = vRP.users_by_source[source]

  if user then
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
  if user then
    user:openMenu("main")
  end
end

-- VoIP

function GUI.tunnel:signalVoicePeer(player, data)
  self.remote._signalVoicePeer(player, source, data)
end

vRP:registerExtension(GUI)
