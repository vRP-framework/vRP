-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.player_state then return end

local PlayerState = class("PlayerState", vRP.Extension)

-- STATIC

PlayerState.weapon_types = {
  "WEAPON_KNIFE",
  "WEAPON_STUNGUN",
  "WEAPON_FLASHLIGHT",
  "WEAPON_NIGHTSTICK",
  "WEAPON_HAMMER",
  "WEAPON_BAT",
  "WEAPON_GOLFCLUB",
  "WEAPON_CROWBAR",
  "WEAPON_PISTOL",
  "WEAPON_COMBATPISTOL",
  "WEAPON_APPISTOL",
  "WEAPON_PISTOL50",
  "WEAPON_MICROSMG",
  "WEAPON_SMG",
  "WEAPON_ASSAULTSMG",
  "WEAPON_ASSAULTRIFLE",
  "WEAPON_CARBINERIFLE",
  "WEAPON_ADVANCEDRIFLE",
  "WEAPON_MG",
  "WEAPON_COMBATMG",
  "WEAPON_PUMPSHOTGUN",
  "WEAPON_SAWNOFFSHOTGUN",
  "WEAPON_ASSAULTSHOTGUN",
  "WEAPON_BULLPUPSHOTGUN",
  "WEAPON_STUNGUN",
  "WEAPON_SNIPERRIFLE",
  "WEAPON_HEAVYSNIPER",
  "WEAPON_REMOTESNIPER",
  "WEAPON_GRENADELAUNCHER",
  "WEAPON_GRENADELAUNCHER_SMOKE",
  "WEAPON_RPG",
  "WEAPON_PASSENGER_ROCKET",
  "WEAPON_AIRSTRIKE_ROCKET",
  "WEAPON_STINGER",
  "WEAPON_MINIGUN",
  "WEAPON_GRENADE",
  "WEAPON_STICKYBOMB",
  "WEAPON_SMOKEGRENADE",
  "WEAPON_BZGAS",
  "WEAPON_MOLOTOV",
  "WEAPON_FIREEXTINGUISHER",
  "WEAPON_PETROLCAN",
  "WEAPON_DIGISCANNER",
  "WEAPON_BRIEFCASE",
  "WEAPON_BRIEFCASE_02",
  "WEAPON_BALL",
  "WEAPON_FLARE"
}

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.state_ready = false
  self.update_interval = 30
  self.mp_models = {} -- map of model hash

  -- update task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.update_interval*1000)

      if self.state_ready then
        local x,y,z = vRP.EXT.Base:getPosition()

        self.remote._update({
          position = {x=x,y=y,z=z},
          heading = GetEntityHeading(GetPlayerPed(-1)),
          weapons = self:getWeapons(),
          customization = self:getCustomization(),
          health = self:getHealth(),
          armour = self:getArmour()
        })
      end
    end
  end)
end

-- WEAPONS

-- get player weapons 
-- return map of name => {.ammo}
function PlayerState:getWeapons()
  local player = GetPlayerPed(-1)

  local ammo_types = {} -- remember ammo type to not duplicate ammo amount

  local weapons = {}
  for k,v in pairs(PlayerState.weapon_types) do
    local hash = GetHashKey(v)
    if HasPedGotWeapon(player,hash) then
      local weapon = {}
      weapons[v] = weapon

      local atype = Citizen.InvokeNative(0x7FEAD38B326B9F74, player, hash)
      if ammo_types[atype] == nil then
        ammo_types[atype] = true
        weapon.ammo = GetAmmoInPedWeapon(player,hash)
      else
        weapon.ammo = 0
      end
    end
  end

  return weapons
end

-- replace weapons (combination of getWeapons and giveWeapons)
-- weapons: map of name => {.ammo}
--- ammo: (optional)
-- return previous weapons
function PlayerState:replaceWeapons(weapons)
  local old_weapons = self:getWeapons()
  self:giveWeapons(weapons, true)
  return old_weapons
end

-- weapons: map of name => {.ammo}
--- ammo: (optional)
function PlayerState:giveWeapons(weapons, clear_before)
  local player = GetPlayerPed(-1)

  -- give weapons to player

  if clear_before then
    RemoveAllPedWeapons(player,true)
  end

  for k,weapon in pairs(weapons) do
    local hash = GetHashKey(k)
    local ammo = weapon.ammo or 0

    GiveWeaponToPed(player, hash, ammo, false)
  end
end

-- set player armour (0-100)
function PlayerState:setArmour(amount)
  SetPedArmour(GetPlayerPed(-1), amount)
end

function PlayerState:getArmour()
  return GetPedArmour(GetPlayerPed(-1))
end

-- amount: 100-200 ?
function PlayerState:setHealth(amount)
  SetEntityHealth(GetPlayerPed(-1), math.floor(amount))
end

function PlayerState:getHealth()
  return GetEntityHealth(GetPlayerPed(-1))
end

--[[
function tvRP.dropWeapon()
  SetPedDropsWeapon(GetPlayerPed(-1))
end
--]]

-- PLAYER CUSTOMIZATION

-- get number of drawables for a specific part
function PlayerState:getDrawables(part)
  local args = splitString(part, ":")
  local index = parseInt(args[2])

  if args[1] == "prop" then
    return GetNumberOfPedPropDrawableVariations(GetPlayerPed(-1),index)
  elseif args[1] == "drawable" then
    return GetNumberOfPedDrawableVariations(GetPlayerPed(-1),index)
  elseif args[1] == "overlay" then
    return GetNumHeadOverlayValues(index)
  end
end

-- get number of textures for a specific part and drawable
function PlayerState:getDrawableTextures(part,drawable)
  local args = splitString(part, ":")
  local index = parseInt(args[2])

  if args[1] == "prop" then
    return GetNumberOfPedPropTextureVariations(GetPlayerPed(-1),index,drawable)
  elseif args[1] == "drawable" then
    return GetNumberOfPedTextureVariations(GetPlayerPed(-1),index,drawable)
  end
end

-- get player skin customization
-- return custom parts
function PlayerState:getCustomization()
  local ped = GetPlayerPed(-1)

  local custom = {}

  custom.modelhash = GetEntityModel(ped)

  -- ped parts
  for i=0,20 do -- index limit to 20
    custom["drawable:"..i] = {GetPedDrawableVariation(ped,i), GetPedTextureVariation(ped,i), GetPedPaletteVariation(ped,i)}
  end

  -- props
  for i=0,10 do -- index limit to 10
    custom["prop:"..i] = {GetPedPropIndex(ped,i), math.max(GetPedPropTextureIndex(ped,i),0)}
  end

  custom.hair_color = {GetPedHairColor(ped), GetPedHairHighlightColor(ped)}

  for i=0,12 do
    local ok, index, ctype, pcolor, scolor, opacity = GetPedHeadOverlayData(ped, i)
    if ok then
      custom["overlay:"..i] = {index, pcolor, scolor, opacity}
    end
  end

  return custom
end

-- set partial customization (only what is set is changed)
-- custom: indexed customization parts ("foo:arg1:arg2...")
--- "modelhash": number, model hash
--- or "model": string, model name
--- "drawable:<index>": {drawable,texture,palette} ped components
--- "prop:<index>": {prop_index, prop_texture}
--- "hair_color": {primary, secondary}
--- "overlay:<index>": {overlay_index, primary color, secondary color, opacity}
function PlayerState:setCustomization(custom) 
  local r = async()

  Citizen.CreateThread(function() -- new thread
    if custom then
      local ped = GetPlayerPed(-1)
      local mhash = nil

      -- model
      if custom.modelhash then
        mhash = custom.modelhash
      elseif custom.model then
        mhash = GetHashKey(custom.model)
      end

      if mhash then
        local i = 0
        while not HasModelLoaded(mhash) and i < 10000 do
          RequestModel(mhash)
          Citizen.Wait(10)
        end

        if HasModelLoaded(mhash) then
          -- changing player model remove weapons, armour and health, so save it

          vRP:triggerEventSync("playerModelSave")

          local weapons = self:getWeapons()
          local armour = self:getArmour()
          local health = self:getHealth()

          SetPlayerModel(PlayerId(), mhash)

          self:giveWeapons(weapons,true)
          self:setArmour(armour)
          self:setHealth(health)

          vRP:triggerEventSync("playerModelRestore")

          SetModelAsNoLongerNeeded(mhash)
        end
      end

      ped = GetPlayerPed(-1)

      local is_mp = self.mp_models[GetEntityModel(ped)]

      if is_mp then
        -- face blend data
        local face = (custom["drawable:0"] and custom["drawable:0"][1]) or GetPedDrawableVariation(ped,0)
        SetPedHeadBlendData(ped, face, face, 0, face, face, 0, 0.5, 0.5, 0.0, false)
      end

      -- drawable, prop, overlay
      for k,v in pairs(custom) do
        local args = splitString(k, ":")
        local index = parseInt(args[2])

        if args[1] == "prop" then
          if v[1] < 0 then
            ClearPedProp(ped,index)
          else
            SetPedPropIndex(ped,index,v[1],v[2],true)
          end
        elseif args[1] == "drawable" then
          SetPedComponentVariation(ped,index,v[1],v[2],v[3] or 2)
        elseif args[1] == "overlay" and is_mp then
          local ctype = 0
          if index == 1 or index == 2 or index == 10 then ctype = 1
          elseif index == 5 or index == 8 then ctype = 2 end

          SetPedHeadOverlay(ped, index, v[1], v[4] or 1.0)
          SetPedHeadOverlayColor(ped, index, ctype, v[2] or 0, v[3] or 0)
        end
      end

      if custom.hair_color and is_mp then
        SetPedHairColor(ped, table.unpack(custom.hair_color))
      end
    end

    r()
  end)

  return r:wait()
end

-- EVENT

PlayerState.event = {}

function PlayerState.event:playerDeath()
  self.state_ready = false
end

-- TUNNEL
PlayerState.tunnel = {}

function PlayerState.tunnel:setStateReady(state)
  self.state_ready = state
end

function PlayerState.tunnel:setConfig(update_interval, mp_models)
  self.update_interval = update_interval

  for _, model in pairs(mp_models) do
    local hash
    if type(model) == "string" then
      hash = GetHashKey(model)
    else
      hash = model
    end

    self.mp_models[hash] = true
  end
end

PlayerState.tunnel.getWeapons = PlayerState.getWeapons
PlayerState.tunnel.replaceWeapons = PlayerState.replaceWeapons
PlayerState.tunnel.giveWeapons = PlayerState.giveWeapons
PlayerState.tunnel.setArmour = PlayerState.setArmour
PlayerState.tunnel.getArmour = PlayerState.getArmour
PlayerState.tunnel.setHealth = PlayerState.setHealth
PlayerState.tunnel.getHealth = PlayerState.getHealth
PlayerState.tunnel.getDrawables = PlayerState.getDrawables
PlayerState.tunnel.getDrawableTextures = PlayerState.getDrawableTextures
PlayerState.tunnel.getCustomization = PlayerState.getCustomization
PlayerState.tunnel.setCustomization = PlayerState.setCustomization

vRP:registerExtension(PlayerState)
