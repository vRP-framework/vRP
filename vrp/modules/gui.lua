local Tools = require("resources/vrp/lib/Tools")
local ids = Tools.newIDGenerator()

-- MENU

local client_menus = {}

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
  
  -- name
  menudata.name = menudef.name or "Menu"
  menudata.css = menudef.css or {}

  -- set new id
  menudata.id = ids:gen() 

  -- add client menu
  client_menus[menudata.id] = {def = menudef, source = source}

  -- openmenu
  vRPclient.openMenuData(source,{menudata})
end

-- force close player menu
function vRP.closeMenu(source)
  vRPclient.closeMenu(source,{})
end

-- PROMPT

local prompts = {}

-- prompt textual (and multiline) information from player
function vRP.prompt(source,title,default_text,cb_result)
  prompts[source] = cb_result

  vRPclient.prompt(source,{title,default_text})
end

-- SERVER TUNNEL API

function tvRP.closeMenu(id)
  local menu = client_menus[id]
  if menu and menu.source == source then

    -- call callback
    if menu.def.onclose then
      menu.def.onclose(source)
    end

    ids:free(id)
    client_menus[id] = nil
  end
end

function tvRP.validMenuChoice(id,choice)
  local menu = client_menus[id]
  if menu and menu.source == source then
    -- call choice callback
    local cb = menu.def[choice][1]
    if cb then
      cb(source,choice)
    end
  end
end

-- receive prompt result
function tvRP.promptResult(text)
  local prompt = prompts[source]
  if prompt ~= nil then
    prompt(source,text)
    prompts[source] = nil
  end
end
