
-- define some basic home components

-- CHEST

local function chest_create(owner_id, stype, sid, config, x, y, z, player)
  local chest_enter = function(player,area)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and user_id == owner_id then
      vRP.openChest(player, "u"..owner_id.."home", config.weight or 200,nil,nil,nil)
    end
  end


  local chest_leave = function(player,area)
    -- close twice (chest can be nested)
    vRP.closeMenu(player)
    vRP.closeMenu(player)
  end

  local nid = "vRP:home:slot"..stype..sid..":chest"
  vRPclient.setNamedMarker(player,{nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})
  vRP.setArea(player,nid,x,y,z,1,1.5,chest_enter,chest_leave)
end

local function chest_destroy(owner_id, stype, sid, config, x, y, z, player)
  local nid = "vRP:home:slot"..stype..sid..":chest"
  vRPclient.removeNamedMarker(player,{nid})
  vRP.removeArea(player,nid)
end

vRP.defHomeComponent("chest", chest_create, chest_destroy)
