-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.survival then return end

local lang = vRP.lang

local Survival = class("Survival", vRP.Extension)

-- SUBCLASS

Survival.User = class("User")

-- return vital value (0-1) or nil
function Survival.User:getVital(name)
  return self.cdata.vitals[name]
end

-- set vital
-- value: 0-1
function Survival.User:setVital(name, value)
  if vRP.EXT.Survival.vitals[name] then -- exists
    local overflow

    -- clamp
    if value < 0 then
      overflow = value
      value = 0 
    elseif value > 1 then 
      overflow = value-1
      value = 1
    end

    -- set
    local pvalue = self.cdata.vitals[name]
    self.cdata.vitals[name] = value

    if pvalue ~= value then
      vRP:triggerEvent("playerVitalChange", self, name)
    end

    if overflow then
      vRP:triggerEvent("playerVitalOverflow", self, name, overflow)
    end
  end
end

function Survival.User:varyVital(name, value)
  self:setVital(name, self:getVital(name)+value)
end

-- METHODS

function Survival:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/survival")
  self.vitals = {} -- registered vitals, map of name => {default_value}

  self:registerVital("water", 1)
  self:registerVital("food", 0.75)

  -- items
  vRP.EXT.Inventory:defineItem("medkit", lang.item.medkit.name(), lang.item.medkit.description(), nil, 0.5)

  -- water/food task increase
  local function task_update()
    SetTimeout(60000, task_update)

    for id,user in pairs(vRP.users) do
      if user:isReady() then
        user:varyVital("water", -self.cfg.water_per_minute)
        user:varyVital("food", -self.cfg.food_per_minute)
      end
    end
  end

  task_update()

  -- menu
  -- EMERGENCY

  local revive_seq = {
    {"amb@medic@standing@kneel@enter","enter",1},
    {"amb@medic@standing@kneel@idle_a","idle_a",1},
    {"amb@medic@standing@kneel@exit","exit",1}
  }

  local function m_revive(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end
    if nuser then
      if self.remote.isInComa(nuser.source) then
        if user:tryTakeItem("medkit",1) then
          vRP.EXT.Base.remote._playAnim(user.source,false,revive_seq,false) -- anim
          SetTimeout(15000, function()
            self.remote._varyHealth(nuser.source,50) -- heal 50
          end)
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.emergency.menu.revive.not_in_coma())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  -- add choices to the main menu (emergency)
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    if menu.user:hasPermission("emergency.revive") then
      menu:addOption(lang.emergency.menu.revive.title(), m_revive, lang.emergency.menu.revive.description())
    end
  end)
end

-- default_value: (optional) default vital value, 0 by default
function Survival:registerVital(name, default_value)
  self.vitals[name] = {default_value or 0}
end

-- EVENT

Survival.event = {}

function Survival.event:characterLoad(user)
  -- init vitals
  if not user.cdata.vitals then
    user.cdata.vitals = {}
  end

  for name,vital in pairs(self.vitals) do
    if not user.cdata.vitals[name] then
      user.cdata.vitals[name] = vital[1]
    end
  end
end

function Survival.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setPolice(user.source, self.cfg.police)
    self.remote._setFriendlyFire(user.source, self.cfg.pvp)
    self.remote._setConfig(user.source, lang.survival.coma_display())

    if self.cfg.vital_display then
      local GUI = vRP.EXT.GUI

      local water = user:getVital("water")
      local food = user:getVital("food")

      GUI.remote._setProgressBar(user.source,"vRP:Survival:food", self.cfg.vital_display_anchor, (food == 0) and lang.survival.starving() or "",255,153,0,food)
      GUI.remote._setProgressBar(user.source,"vRP:Survival:water", self.cfg.vital_display_anchor, (water == 0) and lang.survival.thirsty() or "",0,125,255,water)
    end
  end
end

function Survival.event:playerDeath(user)
  -- reset vitals
  for name,vital in pairs(self.vitals) do
    user:setVital(name, vital[1])
  end
end

function Survival.event:playerVitalChange(user, vital)
  if self.cfg.vital_display then
    local GUI = vRP.EXT.GUI

    if vital == "water" then
      local value = user:getVital(vital)
      GUI.remote._setProgressBarValue(user.source, "vRP:Survival:water", value)
      GUI.remote._setProgressBarText(user.source, "vRP:Survival:water", (value == 0) and lang.survival.thirsty() or "")
    elseif vital == "food" then
      local value = user:getVital(vital)
      GUI.remote._setProgressBarValue(user.source, "vRP:Survival:food", value)
      GUI.remote._setProgressBarText(user.source, "vRP:Survival:food", (value == 0) and lang.survival.starving() or "")
    end
  end
end

function Survival.event:playerVitalOverflow(user, vital, overflow)
  if vital == "water" or vital == "food" then
    if overflow < 0 then
      self.remote._varyHealth(user.source, overflow*100*self.cfg.overflow_damage_factor)
    end
  end
end

-- TUNNEL
Survival.tunnel = {}

function Survival.tunnel:consume(water, food)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    if water then
      user:varyVital("water", -water)
    end

    if food then
      user:varyVital("food", -food)
    end
  end
end

vRP:registerExtension(Survival)
