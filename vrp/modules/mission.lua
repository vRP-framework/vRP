local lang = vRP.lang

-- mission system module
local Mission = class("Mission", vRP.Extension)

-- SUBCLASS

Mission.User = class("User")

-- start a mission for a player
--- mission: 
---- name: mission name
---- steps: ordered list of
----- text: (html)
----- position: {x,y,z}
----- radius: (optional) area radius (affect default PoI)
----- height: (optional) area height (affect default PoI)
----- onenter: see Map.User:setArea
----- onleave: (optional) see Map.User:setArea
----- map_entity: (optional) a simple PoI by default
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
      local radius, height = 1, 1.5
      local onleave = function() end
      if step.onleave then onleave = step.onleave end
      if step.radius then radius = step.radius end
      if step.height then height = step.height end
      local ment = {"PoI", {blip_id = 1, blip_color = 5, marker_id = 1, color = {255,226,0,125}, scale = {0.7*radius,0.7*radius,0.5*height}}}
      if step.map_entity then ment = step.map_entity end

      -- display
      vRP.EXT.GUI.remote._setDivContent(self.source,"mission",lang.mission.display({self.mission.name,self.mission_step-1,#self.mission.steps,step.text}))

      -- map entity/route
      ment[2].title = lang.mission.title({self.mission.name,self.mission_step,#self.mission.steps})
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote.setEntity(self.source, "vRP:mission", ment[1], ment[2])
      vRP.EXT.Map.remote._commandEntity(self.source, "vRP:mission", "setBlipRoute")

      -- map trigger
      self:setArea("vRP:mission",x,y,z,radius,height,step.onenter,step.onleave)
    end
  end
end

-- stop the player mission
function Mission.User:stopMission()
  if self.mission then
    self.mission_step = nil
    self.mission = nil

    vRP.EXT.Map.remote._removeEntity(self.source,"vRP:mission")
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

-- EVENT
Mission.event = {}

function Mission.event:characterUnload(user)
  user:stopMission()
end

vRP:registerExtension(Mission)
