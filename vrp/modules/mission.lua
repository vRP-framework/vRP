-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.mission then return end

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
----- onenter: (optional) see Map.User:setArea
----- onleave: (optional) see Map.User:setArea
----- map_entity: (optional) a simple PoI by default
function Mission.User:startMission(mission)
  self:stopMission()
  if #mission.steps > 0 then
    self.mission_step = 0
    self.mission = mission

    vRP:triggerEvent("playerMissionStart", self)

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
      local radius, height = step.radius or 1, step.height or 1.5
      local ment = clone(step.map_entity) or {"PoI", {blip_id = 1, blip_color = 5, marker_id = 1, color = {255,226,0,125}, scale = {0.7*radius,0.7*radius,0.33*height}}}

      vRP:triggerEvent("playerMissionStep", self)

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
    vRP.EXT.Map.remote._removeEntity(self.source,"vRP:mission")
    self:removeArea("vRP:mission")

    vRP:triggerEvent("playerMissionStop", self)

    self.mission_step = nil
    self.mission = nil
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

function Mission.event:playerMissionStart(user)
  if self.cfg.default_display then
    vRP.EXT.GUI.remote._setDiv(user.source,"mission",self.cfg.display_css,"")
  end
end

function Mission.event:playerMissionStep(user)
  if self.cfg.default_display then
    local step = user.mission.steps[user.mission_step]
    vRP.EXT.GUI.remote._setDivContent(user.source,"mission",lang.mission.display({user.mission.name,user.mission_step-1,#user.mission.steps,step.text}))
  end
end

function Mission.event:playerMissionStop(user)
  if self.cfg.default_display then
    vRP.EXT.GUI.remote._removeDiv(user.source, "mission")
  end
end

vRP:registerExtension(Mission)
