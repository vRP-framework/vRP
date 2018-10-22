local lang = vRP.lang

-- mission system module
local Mission = class("Mission", vRP.Extension)

-- SUBCLASS

Mission.User = class("User")

-- start a mission for a player
--- mission: 
---- name: mission name
---- steps: ordered list of
----- text
----- position: {x,y,z}
----- onenter: see Map.User:setArea
----- onleave: (optional) see Map.User:setArea
----- blipid, blipcolor (optional)
function Mission.User:startMission(mission)
  self:stopMission()
  if #mission.steps > 0 then
    self.mission_step = 0
    self.mission = mission
    vRP.EXT.GUI.remote._setDiv(self.source,"mission",vRP.EXT.Mission.cfg.display_css,"")
    self:nextMissionStep() -- do first step
  end
end

-- end the current player mission step
function Mission.User:nextMissionStep()
  if self.mission then -- if in a mission
    -- increase step
    self.mission_step = self.mission_step+1
    if self.mission_step > #self.mission.steps then -- check mission end
      self:stopMission()
    else -- mission step
      local step = self.mission.steps[self.mission_step]
      local x,y,z = table.unpack(step.position)
      local blipid = 1
      local blipcolor = 5
      local onleave = function() end
      if step.blipid then blipid = step.blipid end
      if step.blipcolor then blipcolor = step.blipcolor end
      if step.onleave then onleave = step.onleave end

      -- display
      vRP.EXT.GUI.remote._setDivContent(self.source,"mission",lang.mission.display({self.mission.name,self.mission_step-1,#self.mission.steps,step.text}))

      -- blip/route
      local id = vRP.EXT.Map.remote.setNamedBlip(self.source, "vRP:mission", x,y,z, blipid, blipcolor, lang.mission.blip({self.mission.name,self.mission_step,#self.mission.steps}))
      vRP.EXT.Map.remote._setBlipRoute(self.source,id)

      -- map trigger
      vRP.EXT.Map.remote._setNamedMarker(self.source,"vRP:mission", x,y,z-1,0.7,0.7,0.5,255,226,0,125,150)
      self:setArea("vRP:mission",x,y,z,1,1.5,step.onenter,step.onleave)
    end
  end
end

-- stop the player mission
function Mission.User:stopMission()
  if self.mission then
    self.mission_step = nil
    self.mission = nil

    vRP.EXT.Map.remote._removeNamedBlip(self.source,"vRP:mission")
    vRP.EXT.Map.remote._removeNamedMarker(self.source,"vRP:mission")
    vRP.EXT.GUI.remote._removeDiv(self.source,"mission")
    self:removeArea("vRP:mission")
  end
end

-- check if the player has a mission
function Mission.User:hasMission()
  return self.mission ~= nil
end

-- METHODS

function Mission:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("cfg/mission")

  -- main menu cancel mission

  local function m_cancel(menu)
    menu.user:stopMission()
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.mission.cancel.title(), m_cancel)
  end)
end

vRP:registerExtension(Mission)
