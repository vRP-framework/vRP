
-- periodic player state update

-- update_wait : prevent sending update before receiving spawn data
local update_wait = false
AddEventHandler("playerSpawned",function()
  update_wait = true
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(30000)

    if update_wait then
      update_wait = false
      Citizen.Wait(10000)
    end

    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    vRPserver.updatePos({x,y,z})
    vRPserver.updateWeapons({tvRP.getWeapons()})
    vRPserver.updateCustomization({tvRP.getCustomization()})
  end
end)

-- WEAPONS

-- def
local weapon_types = {
  "WEAPON_KNIFE",
  "WEAPON_NIGHTSTICK",
  "WEAPON_HAMMER",
  "WEAPON_BAT ",
  "WEAPON_GOLFCLUB",
  "WEAPON_CROWBAR",
  "WEAPON_PISTOL",
  "WEAPON_COMBATPISTOL",
  "WEAPON_APPISTOL",
  "WEAPON_PISTOL50",
  "WEAPON_MICROSMG",
  "WEAPON_SMG ",
  "WEAPON_ASSAULTSMG",
  "WEAPON_ASSAULTRIFLE",
  "WEAPON_CARBINERIFLE",
  "WEAPON_ADVANCEDRIFLE",
  "WEAPON_MG",
  "WEAPON_COMBATMG",
  "WEAPON_PUMPSHOTGUN ",
  "WEAPON_SAWNOFFSHOTGUN",
  "WEAPON_ASSAULTSHOTGUN",
  "WEAPON_BULLPUPSHOTGUN",
  "WEAPON_STUNGUN ",
  "WEAPON_SNIPERRIFLE ",
  "WEAPON_HEAVYSNIPER ",
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
  "WEAPON_MOLOTOV ",
  "WEAPON_FIREEXTINGUISHER",
  "WEAPON_PETROLCAN ",
  "WEAPON_DIGISCANNER",
  "WEAPON_BRIEFCASE",
  "WEAPON_BRIEFCASE_02",
  "WEAPON_BALL",
  "WEAPON_FLARE"
}

function tvRP.getWeaponTypes()
  return weapon_types
end

function tvRP.getWeapons()
  local player = GetPlayerPed(-1)

  local weapons = {}
  for k,v in pairs(weapon_types) do
    local hash = GetHashKey(v)
    if HasPedGotWeapon(player,hash) then
      local weapon = {}
      weapons[v] = weapon

      weapon.ammo = GetAmmoInPedWeapon(player,hash)
    end
  end

  return weapons
end

function tvRP.giveWeapons(weapons,clear_before)
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
  
  -- send weapons update
  vRPserver.updateWeapons({tvRP.getWeapons()})
end

-- PLAYER CUSTOMIZATION

function tvRP.getCustomization()
  local ped = GetPlayerPed(-1)

  local custom = {}

  custom.modelhash = GetEntityModel(ped)

  for i=0,20 do -- index limit to 20
    custom[i] = {GetPedDrawableVariation(ped,i), GetPedTextureVariation(ped,i), GetPedPaletteVariation(ped,i)}
  end

  return custom
end

function tvRP.setCustomization(custom) -- indexed [drawable,texture,palette] components plus .modelhash or .model
  if custom then
    local ped = GetPlayerPed(-1)
    local mhash = nil

    if custom.modelhash ~= nil then
      mhash = custom.modelhash
    elseif custom.model ~= nil then
      mhash = GetHashKey(custom.model)
    end

    if mhash ~= nil then
      local i = 0
      while not HasModelLoaded(mhash) and i < 1000 do
        RequestModel(mhash)
        Citizen.Wait(10)
      end

      if HasModelLoaded(mhash) then
        SetPlayerModel(PlayerId(), mhash)
        SetModelAsNoLongerNeeded(mhash)
      end
    end

    ped = GetPlayerPed(-1)

    for k,v in pairs(custom) do
      if k ~= "model" and k ~= "modelhash" then
        SetPedComponentVariation(ped,tonumber(k),v[1],v[2],v[3])
      end
    end
  end
end


