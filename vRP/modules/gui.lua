local Tools = require("resources/vRP/lib/Tools")
local ids = Tools.newIDGenerator()

local client_menus = {}

-- open dynamic menu to client
-- menudef: .name and choices as key/callback
function vRP.openMenu(source,menudef)
  local menudata = {}
  menudata.choices = {}

  -- send menudata to client
  -- choices
  for k,v in pairs(menudef) do
    if k ~= "name" and k ~= "onclose" then
      table.insert(menudata.choices,k)
    end
  end
  
  -- name
  menudata.name = menudef.name or "Menu"

  -- set new id
  menudata.id = ids:gen() 

  -- add client menu
  client_menus[source] = {id = menudata.id, def = menudef}

  -- openmenu
  vRPclient.openMenuData(source,{menudata})
end

-- server api for clients

function tvRP.closeMenu(id)
  print("close menu "..id)
  local menu = client_menus[source]
  if menu and menu.id == id then

    -- call callback
    if menu.def.onclose then
      menu.def.onclose()
    end

    ids:free(id)
    client_menus[source] = nil
  end
end

function tvRP.validMenuChoice(id,choice)
  print("valid menu "..id.." choice "..choice)
  local menu = client_menus[source]
  if menu and menu.id == id then
    -- call choice callback
    local cb = menu.def[choice]
    if cb then
      cb(choice)
    end
  end
end
