
local items = {}

items["medkit"] = {"Medical Kit","Used to reanimate unconscious people.",nil,0.5}
items["dirty_money"] = {"Dirty money","Illegally earned money.",nil,0}
items["repairkit"] = {"Repair Kit","Used to repair vehicles.",nil,0.5}

-- money
items["money"] = {"Money","Packed money.",function(args)
  local choices = {}
  local idname = args[1]

  choices["Unpack"] = {function(player,choice,mod)
    local user_id = vRP.getUserId(player)
    if user_id then
      local amount = vRP.getInventoryItemAmount(user_id, idname)
      local ramount = vRP.prompt(player, "How much to unpack ? (max "..amount..")", "")
      ramount = parseInt(ramount)
      if vRP.tryGetInventoryItem(user_id, idname, ramount, true) then -- unpack the money
        vRP.giveMoney(user_id, ramount)
        vRP.closeMenu(player)
      end
    end
  end}

  return choices
end,0}

-- money binder
items["money_binder"] = {"Money binder","Used to bind 1000$ of money.",function(args)
  local choices = {}
  local idname = args[1]

  choices["Bind money"] = {function(player,choice,mod) -- bind the money
    local user_id = vRP.getUserId(player)
    if user_id then
      local money = vRP.getMoney(user_id)
      if money >= 1000 then
        if vRP.tryGetInventoryItem(user_id, idname, 1, true) and vRP.tryPayment(user_id,1000) then
          vRP.giveInventoryItem(user_id, "money", 1000, true)
          vRP.closeMenu(player)
        end
      else
        vRPclient._notify(player,vRP.lang.money.not_enough())
      end
    end
  end}

  return choices
end,0}

-- parametric weapon items
-- give "wbody|WEAPON_PISTOL" and "wammo|WEAPON_PISTOL" to have pistol body and pistol bullets

local get_wname = function(weapon_id)
  local name = string.gsub(weapon_id,"WEAPON_","")
  name = string.upper(string.sub(name,1,1))..string.lower(string.sub(name,2))
  -- lang translation support, ex: weapon.pistol = "Pistol", by default use the native name
  return vRP.lang.weapon[string.lower(name)]({}, name)
end

--- weapon body
local wbody_name = function(args)
  return get_wname(args[2]).." body"
end

local wbody_desc = function(args)
  return ""
end

local wbody_choices = function(args)
  local choices = {}
  local fullidname = joinStrings(args,"|")

  choices["Equip"] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id then
      if vRP.tryGetInventoryItem(user_id, fullidname, 1, true) then -- give weapon body
        local weapons = {}
        weapons[args[2]] = {ammo = 0}
        vRPclient._giveWeapons(player, weapons)

        vRP.closeMenu(player)
      end
    end
  end}

  return choices
end

local wbody_weight = function(args)
  return 0.75
end

items["wbody"] = {wbody_name,wbody_desc,wbody_choices,wbody_weight}

--- weapon ammo
local wammo_name = function(args)
  return get_wname(args[2]).." ammo"
end

local wammo_desc = function(args)
  return ""
end

local wammo_choices = function(args)
  local choices = {}
  local fullidname = joinStrings(args,"|")

  choices["Load"] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id then
      local amount = vRP.getInventoryItemAmount(user_id, fullidname)
      local ramount = vRP.prompt(player, "Amount to load ? (max "..amount..")", "")
      ramount = parseInt(ramount)

      local uweapons = vRPclient.getWeapons(player)
      if uweapons[args[2]] then -- check if the weapon is equiped
        if vRP.tryGetInventoryItem(user_id, fullidname, ramount, true) then -- give weapon ammo
          local weapons = {}
          weapons[args[2]] = {ammo = ramount}
          vRPclient._giveWeapons(player, weapons,false)
          vRP.closeMenu(player)
        end
      end
    end
  end}

  return choices
end

local wammo_weight = function(args)
  return 0.01
end

items["wammo"] = {wammo_name,wammo_desc,wammo_choices,wammo_weight}

return items
