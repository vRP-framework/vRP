local Tools = module("lib/Tools")

local cfg = module("cfg/gui")

-- Menu
local Menu = class("Menu")

function Menu:__construct()
  self.title = "menu"
  self.css = {} -- {.top, .header_color}
  self.options = {}

-- .onclose(user) will be called when the menu is closed
end

-- add option
-- title: option title
-- action(user, value, mod): select callback
--- value: option value
--- mod: action modulation
---- -1: left
---- 0: valid
---- 1: right
-- description: (optional) option description, a string or a callback
--- callback(user, value): should return a string or nil
-- value: (optional) option value
function Menu:addOption(title, action, description, value)
  table.insert(self.options, {title, action, description, value})
end


-- Extension

local GUI = class("GUI", vRP.Extension)

-- SUBCLASS

GUI.User = class("User")

function GUI.User:__construct()
  self.menu = nil -- current menu
  self.menu_stack = {} -- stack of {name, data}
  self.request_ids = Tools.newIDGenerator()
  self.requests = {}
end

-- open menu (build and open menu)
function GUI.User:openMenu(name, data)
  -- copy data
  local cdata = {}
  for k,v in pairs(cdata) do
    cdata[k] = v
  end

  -- add user property
  data.user = self

  -- build menu
  local menu = vRP.EXT.GUI:buildMenu(name, data)

  -- prepare network data
  local data = {
    options = {},
    title = menu.title,
    css = menu.css
  }

  -- titles
  for k,v in pairs(menu.options) do
    data.options[k] = title
  end

  -- add to stack, mark as current
  table.insert(self.menu_stack, {name, data})
  self.menu = menu

  -- open client menu
  vRP.EXT.GUI.remote._openMenu(self.source, data)
end

-- force close current menu
function GUI.User:closeMenu()
  vRP.EXT.GUI.remote._closeMenu(self.source)
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
-- builder(menu, data): callback to modify the menu
--- data: passed data to build the menu
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
  local menu = Menu()
  menu.title = "<"..name..">"

  local mbuilders = self.menu_builders[name]

  if mbuilders then
    for _,builder in ipairs(mbuilders) do -- trigger builders
      builder(menu, data)
    end
  end

  return menu
end

-- TUNNEL
GUI.tunnel = {}

function GUI.tunnel:closeMenu()
  local user = vRP.users_by_source[source]

  if user then
    if user.menu then
      if user.menu.onclose then
        user.menu.onclose(user)
      end
    local menu = client_menus[id]
    if menu and menu.source == source then

      -- call callback
      if menu.def.onclose then
        menu.def.onclose(source)
      end

      menu_ids:free(id)
      client_menus[id] = nil
      rclient_menus[source] = nil
    end
  end
end

function tvRP.validMenuChoice(id,choice,mod)
  local source = source
  local menu = client_menus[id]
  if menu and menu.source == source then
    -- call choice callback
    local ch = menu.def[choice]
    if ch then
      local cb = ch[1]
      if cb then
        cb(source,choice,mod)
      end
    end
  end
end

-- receive prompt result
function tvRP.promptResult(text)
  if text == nil then
    text = ""
  end

  local prompt = prompts[source]
  if prompt ~= nil then
    prompts[source] = nil
    prompt(text)
  end
end

-- receive request result
function tvRP.requestResult(id,ok)
  local request = requests[id]
  if request and request.source == source then -- end request
    request.done = true -- set done, the timeout will not call the callback a second time
    request.cb_ok(not not ok) -- callback
    request_ids:free(id)
    requests[id] = nil
  end
end

-- open the general player menu
function tvRP.openMainMenu()
  vRP.openMainMenu(source)
end


-- STATIC MENUS

local function build_client_static_menus(source)
  local user_id = vRP.getUserId(source)
  if user_id then
    for k,v in pairs(cfg.static_menus) do
      local mtype,x,y,z = table.unpack(v)
      local smenu = cfg.static_menu_types[mtype]

      if smenu then
        local function smenu_enter(source)
          local user_id = vRP.getUserId(source)
          if user_id ~= nil and vRP.hasPermissions(user_id,smenu.permissions or {}) then
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
  end
end

-- events
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- load additional css using the div api
    vRPclient._setDiv(source,"additional_css",".div_additional_css{ display: none; }\n\n"..cfg.css,"")

    -- load static menus
    build_client_static_menus(source)
  end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
  -- force close opened menu on leave
  local id = rclient_menus[source]
  if id then
    local menu = client_menus[id]
    if menu and menu.source == source then
      -- call callback
      if menu.def.onclose then
        menu.def.onclose(source)
      end

      menu_ids:free(id)
      client_menus[id] = nil
      rclient_menus[source] = nil
    end
  end
end)

-- VoIP

function tvRP.signalVoicePeer(player, data)
  vRPclient._signalVoicePeer(player, source, data)
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- send peer config
    vRPclient._setPeerConfiguration(source, cfg.voip_peer_configuration)
  end
end)


