local items = {}

local function bvest_choices(args)
  local choices = {}

  choices["Wear"] = {function(player, choice)
    local user_id = vRP.getUserId(player)
    if user_id then
      if vRP.tryGetInventoryItem(user_id, args[1], 1, true) then -- take vest
        vRPclient._setArmour(player, 100)
      end
    end
  end}

  return choices
end

items["bulletproof_vest"] = {"Bulletproof Vest", "A handy protection.", bvest_choices, 1.5}

return items
