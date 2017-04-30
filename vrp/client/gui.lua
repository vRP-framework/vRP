-- MENU

function tvRP.openMenuData(menudata)
  SendNUIMessage({act="open_menu", menudata = menudata})
end

function tvRP.closeMenu()
  SendNUIMessage({act="close_menu"})
end


-- gui menu events
RegisterNUICallback("menu",function(data,cb)
  if data.act == "close" then
    vRPserver.closeMenu({data.id})
  elseif data.act == "valid" then
    vRPserver.validMenuChoice({data.id,data.choice})
  end
end)

-- PROGRESS BAR

-- create/update a progress bar
function tvRP.setProgressBar(name,anchor,text,r,g,b,value)
  local pbar = {name=name,anchor=anchor,text=text,r=r,g=g,b=b,value=value}

  -- default values
  if pbar.value == nil then pbar.value = 0 end

  SendNUIMessage({act="set_pbar",pbar = pbar})
end

-- set progress bar value in percent
function tvRP.setProgressBarValue(name,value)
  SendNUIMessage({act="set_pbar_val", name = name, value = value})
end

-- set progress bar text
function tvRP.setProgressBarText(name,text)
  SendNUIMessage({act="set_pbar_text", name = name, text = text})
end

-- remove a progress bar
function tvRP.removeProgressBar(name)
  SendNUIMessage({act="remove_pbar", name = name})
end

-- gui controls (from cellphone)
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsControlJustPressed(3,172) then SendNUIMessage({act="event",event="UP"}) end
    if IsControlJustPressed(3,173) then SendNUIMessage({act="event",event="DOWN"}) end
    if IsControlJustPressed(3,174) then SendNUIMessage({act="event",event="LEFT"}) end
    if IsControlJustPressed(3,175) then SendNUIMessage({act="event",event="RIGHT"}) end
    if IsControlJustPressed(3,176) then SendNUIMessage({act="event",event="SELECT"}) end
    if IsControlJustPressed(3,177) then SendNUIMessage({act="event",event="CANCEL"}) end
  end
end)

