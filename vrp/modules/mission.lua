
-- mission system module
local lang = vRP.lang
local cfg = module("cfg/mission")

-- start a mission for a player
--- mission_data: 
---- name: Mission name
---- steps: ordered list of
----- text
----- position: {x,y,z}
----- onenter(player,area)
----- onleave(player,area) (optional)
----- blipid, blipcolor (optional)
function vRP.startMission(player, mission_data)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local tmpdata = vRP.getUserTmpTable(user_id)
    
    vRP.stopMission(player)
    if #mission_data.steps > 0 then
      tmpdata.mission_step = 0
      tmpdata.mission_data = mission_data
      vRPclient.setDiv(player,{"mission",cfg.display_css,""})
      vRP.nextMissionStep(player) -- do first step
    end
  end
end

-- end the current player mission step
function vRP.nextMissionStep(player)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local tmpdata = vRP.getUserTmpTable(user_id)
    if tmpdata.mission_step ~= nil then -- if in a mission
      -- increase step
      tmpdata.mission_step = tmpdata.mission_step+1
      if tmpdata.mission_step > #tmpdata.mission_data.steps then -- check mission end
        vRP.stopMission(player)
      else -- mission step
        local step = tmpdata.mission_data.steps[tmpdata.mission_step]
        local x,y,z = table.unpack(step.position)
        local blipid = 1
        local blipcolor = 5
        local onleave = function(player, area) end
        if step.blipid then blipid = step.blipid end
        if step.blipcolor then blipcolor = step.blipcolor end
        if step.onleave then onleave = step.onleave end

        -- display
        vRPclient.setDivContent(player,{"mission",lang.mission.display({tmpdata.mission_data.name,tmpdata.mission_step-1,#tmpdata.mission_data.steps,step.text})})

        -- blip/route
        vRPclient.setNamedBlip(player, {"vRP:mission", x,y,z, blipid, blipcolor, lang.mission.blip({tmpdata.mission_data.name,tmpdata.mission_step,#tmpdata.mission_data.steps})},function(id)
          vRPclient.setBlipRoute(player,{id})
        end) 

        -- map trigger
        vRPclient.setNamedMarker(player,{"vRP:mission", x,y,z-1,0.7,0.7,0.5,255,226,0,125,150})
        vRP.setArea(player,"vRP:mission",x,y,z,1,1.5,step.onenter,step.onleave)
      end
    end
  end
end

-- stop the player mission
function vRP.stopMission(player)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local tmpdata = vRP.getUserTmpTable(user_id)
    tmpdata.mission_step = nil
    tmpdata.mission_data = nil

    vRPclient.removeNamedBlip(player,{"vRP:mission"})
    vRPclient.removeNamedMarker(player,{"vRP:mission"})
    vRPclient.removeDiv(player,{"mission"})
    vRP.removeArea(player,"vRP:mission")
  end
end

-- check if the player has a mission
function vRP.hasMission(player)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local tmpdata = vRP.getUserTmpTable(user_id)
    if tmpdata.mission_step ~= nil then
      return true
    end
  end

  return false
end

-- MAIN MENU
vRP.registerMenuBuilder("main", function(add, data)
  local player = data.player
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local choices = {}

    -- build admin menu
    choices[lang.mission.cancel.title()] = {function(player,choice)
      vRP.stopMission(player)
    end}

    add(choices)
  end
end)
