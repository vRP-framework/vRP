
function tvRP.openMenuData(menudata)
  SendNUIMessage({act="open_menu", menudata = menudata})
end

-- gui menu events
RegisterNUICallback("test",function(data,cb)
  SendNUIMessage({act="test"})
  tvRP.notify("menuevent")
  if data.act == "close" then
    vRPserver.closeMenu({data.id})
  elseif data.act == "valid" then
    vRPserver.validMenuChoice({data.id,data.choice})
  end
end)

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
