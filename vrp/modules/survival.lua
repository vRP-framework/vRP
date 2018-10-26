local lang = vRP.lang

local Survival = class("Survival", vRP.Extension)

-- SUBCLASS

Survival.User = class("User")

function Survival.User:getVital(name)
  return self.cdata.vitals[name]
end

function Survival.User:setVital(name, value)
  if vRP.EXT.Survival.vitals[name] then -- exists
    local overflow

    -- clamp
    if value < 0 then
      value = 0 
      overflow = value
    elseif value > 1 then 
      value = 1
      overflow = value-1
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
  self.vitals = {} -- map of name => {default_value}

  self:registerVital("water", 1)
  self:registerVital("food", 0.75)

  -- items
  vRP.EXT.Inventory:defineItem("medkit", lang.item.medkit.title(), lang.item.medkit.description(), nil, 0.5)

  -- water/food task increase
  local function task_update()
    SetTimeout(60000, task_update)

    for id,user in pairs(vRP.users) do
      user:varyVital("water", -self.cfg.water_per_minute)
      user:varyVital("food", -self.cfg.food_per_minute)
    end
  end

  task_update()
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

    if self.cfg.vital_display then
      local GUI = vRP.EXT.GUI

      local water = user:getVital("water")
      local food = user:getVital("food")

      GUI.remote._setProgressBar(user.source,"vRP:Survival:food","minimap",(food == 0) and lang.survival.starving() or "",255,153,0,food)
      GUI.remote._setProgressBar(user.source,"vRP:Survival:water","minimap",(water == 0) and lang.survival.thirsty() or "",0,125,255,water)
    end
  end

end

function Survival.event:playerStateLoaded(user)
  -- check coma, kill if in coma
  if self.remote.isInComa(user.source) then
    self.remote._killComa(user.source)
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
      GUI.remote._setProgressBarText(user.source, "vRP:Survival:water", (water == 0) and lang.survival.thirsty() or "")
    elseif vital == "food" then
      local value = user:getVital(vital)
      GUI.remote._setProgressBarValue(user.source, "vRP:Survival:food", value)
      GUI.remote._setProgressBarText(user.source, "vRP:Survival:food", (food == 0) and lang.survival.starving() or "")
    end
  end
end

function Survival.event:playerVitalOverflow(user, vital, overflow)
  if vital == "water" or vital == "food" then
    if overflow < 0 then
      self.remote._varyHealth(user.source, -overflow*100*self.cfg.overflow_damage_factor)
    end
  end
end

-- TUNNEL
Survival.tunnel = {}

function Survival.tunnel:consume(water, food)
  local user = vRP.users_by_source[source]

  if user then
    if water then
      user:varyVital("water", -water)
    end

    if food then
      user:varyVital("food", -food)
    end
  end
end

--[[
-- EMERGENCY

---- revive
local revive_seq = {
  {"amb@medic@standing@kneel@enter","enter",1},
  {"amb@medic@standing@kneel@idle_a","idle_a",1},
  {"amb@medic@standing@kneel@exit","exit",1}
}

local choice_revive = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    local nplayer = vRPclient.getNearestPlayer(player,10)
      local nuser_id = vRP.getUserId(nplayer)
      if nuser_id then
        if vRPclient.isInComa(nplayer) then
            if vRP.tryGetInventoryItem(user_id,"medkit",1,true) then
              vRPclient._playAnim(player,false,revive_seq,false) -- anim
              SetTimeout(15000, function()
                vRPclient._varyHealth(nplayer,50) -- heal 50
              end)
            end
          else
            vRPclient._notify(player,lang.emergency.menu.revive.not_in_coma())
          end
      else
        vRPclient._notify(player,lang.common.no_player_near())
      end
  end
end,lang.emergency.menu.revive.description()}

-- add choices to the main menu (emergency)
vRP.registerMenuBuilder("main", function(add, data)
  local user_id = vRP.getUserId(data.player)
  if user_id then
    local choices = {}
    if vRP.hasPermission(user_id,"emergency.revive") then
      choices[lang.emergency.menu.revive.title()] = choice_revive
    end

    add(choices)
  end
end)

--]]

vRP:registerExtension(Survival)
