local function play_eat(player)
  local seq = {
    {"mp_player_inteat@burger", "mp_player_int_eat_burger_enter",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_burger",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_burger_fp",1},
    {"mp_player_inteat@burger", "mp_player_int_eat_exit_burger",1}
  }

  vRPclient.playAnim(player,{true,seq,false})
end

-- idname = {name,description,choices}
local items = {
  ["fruit_peche"] = {"Pêche","Une pêche.",function(args) return {
    ["Manger"] = {function(player,choice)
      local user_id = vRP.getUserId(player)
      if user_id ~= nil then
        if vRP.tryGetInventoryItem(user_id,"fruit_peche",1) then
          vRP.varyHunger(user_id,-10)
          vRP.varyThirst(user_id,-10)
          vRPclient.notify(player,{"~o~ Mange une pêche."})
          play_eat(player)
          vRP.closeMenu(player)
        end
      end
    end,0.15} 
  } end
  },
  ["gold_ore"] = {"Minerais d'Or","",nil,1},
  ["gold_processed"] = {"Or traité","",nil,1.2},
  ["gold_ingot"] = {"Lingot d'Or","",nil,12},
  ["gold_catalyst"] = {"Catalyseur d'Or","Utilisé pour transformer l'Or traité en Lingot d'Or.",nil,0.1},
  ["weed"] = {"Feuille de canabis", "", nil, 0.05},
  ["weed_processed"] = {"Canabis traité", "", nil, 0.1},
  ["demineralized_water"] = {"Eau déminéralisée (1L)","",nil,1}
}

return items
