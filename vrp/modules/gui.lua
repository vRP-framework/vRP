local Tools = module("lib/Tools")

local cfg = module("cfg/gui")

-- MENU

local menu_ids = Tools.newIDGenerator()
local client_menus = {}
local rclient_menus = {}

-- open dynamic menu to client
-- menudef: .name and choices as key/{callback,description} (optional element html description) 
-- menudef optional: .css{ .top, .header_color }
function vRP.openMenu(source,menudef)
  local menudata = {}
  menudata.choices = {}

  -- send menudata to client
  -- choices
  for k,v in pairs(menudef) do
    if k ~= "name" and k ~= "onclose" and k ~= "css" then
      table.insert(menudata.choices,{k,v[2]})
    end
  end

  -- sort choices per entry name
  table.sort(menudata.choices, function(a,b)
    return string.upper(a[1]) < string.upper(b[1])
  end)
  
  -- name
  menudata.name = menudef.name or "Menu"
  menudata.css = menudef.css or {}

  -- set new id
  menudata.id = menu_ids:gen() 

  -- add client menu
  client_menus[menudata.id] = {def = menudef, source = source}
  rclient_menus[source] = menudata.id

  -- openmenu
  vRPclient._openMenuData(source, menudata)
end

-- force close player menu
function vRP.closeMenu(source)
  vRPclient._closeMenu(source)
end

-- PROMPT

local prompts = {}

-- prompt textual (and multiline) information from player
-- return entered text
function vRP.prompt(source,title,default_text)
  local r = async()
  prompts[source] = r

  vRPclient._prompt(source, title,default_text)

  return r:wait()
end

-- REQUEST

local request_ids = Tools.newIDGenerator()
local requests = {}

-- ask something to a player with a limited amount of time to answer (yes|no request)
-- time: request duration in seconds
-- return true (yes) or false (no)
function vRP.request(source,text,time)
  local r = async()

  local id = request_ids:gen()
  local request = {source = source, cb_ok = r, done = false}
  requests[id] = request

  vRPclient.request(source,id,text,time) -- send request to client

  -- end request with a timeout if not already ended
  SetTimeout(time*1000,function()
    if not request.done then
      request.cb_ok(false) -- negative response
      request_ids:free(id)
      requests[id] = nil
    end
  end)

  return r:wait()
end


-- GENERIC MENU BUILDER

local menu_builders = {}

-- register a menu builder function
--- name: menu type name
--- builder(add_choices, data) (callback, with custom data table)
---- add_choices(choices) (callback to call once to add the built choices to the menu)
function vRP.registerMenuBuilder(name, builder)
  local mbuilders = menu_builders[name]
  if not mbuilders then
    mbuilders = {}
    menu_builders[name] = mbuilders
  end

  table.insert(mbuilders, builder)
end

-- build a menu
--- name: menu name type
--- data: custom data table
-- return built choices
function vRP.buildMenu(name, data)
  local r = async()

  -- the task will return the built choices even if they aren't complete
  local choices = {}

  local mbuilders = menu_builders[name]
  if mbuilders then
    local count = #mbuilders

    for k,v in pairs(mbuilders) do -- trigger builders
      -- get back the built choices
      local done = false
      local function add_choices(bchoices)
        if not done then -- prevent a builder to add things more than once
          done = true

          if bchoices then
            for k,v in pairs(bchoices) do
              choices[k] = v
            end
          end

          count = count-1
          if count == 0 then -- end of build
            r(choices)
          end
        end
      end

      v(add_choices, data) -- trigger
    end

    return r:wait()
  end

  return {}
end

-- MAIN MENU

-- open the player main menu
function vRP.openMainMenu(source)
  local menudata = vRP.buildMenu("main", {player = source})
  menudata.name = "Main menu"
  menudata.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
  vRP.openMenu(source,menudata) -- open the generated menu
end

-- SERVER TUNNEL API

function tvRP.closeMenu(id)
  local source = source
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


