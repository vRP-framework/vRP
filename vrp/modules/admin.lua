local htmlEntities = require("resources/vrp/lib/htmlEntities")

-- this module define some admin menu functions

local player_lists = {}

local function ch_list(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.list") then
    if player_lists[player] then -- hide
      player_lists[player] = nil
      vRPclient.removeDiv(player,{"user_list"})
    else -- show
      local content = ""
      for k,v in pairs(vRP.rusers) do
        local source = vRP.getUserSource(k)
        local identity = vRP.getUserIdentity(k)
        if source ~= nil then
          content = content.."<br />["..k.."] => "..GetPlayerName(k)
          if identity then
            content = content.." "..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).." "..identity.registration
          end
        end
      end

      player_lists[player] = true
      vRPclient.setDiv(player,{"user_list",".div_user_list{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content})
    end
  end
end

local function ch_whitelist(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.whitelist") then
    vRP.prompt(player,"User id to whitelist: ","",function(player,id)
      id = tonumber(id)
      vRP.setWhitelisted(id,true)
      vRPclient.notify(player,{"whitelisted user "..id})
    end)
  end
end

local function ch_unwhitelist(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.unwhitelist") then
    vRP.prompt(player,"User id to un-whitelist: ","",function(player,id)
      id = tonumber(id)
      vRP.setWhitelisted(id,false)
      vRPclient.notify(player,{"un-whitelisted user "..id})
    end)
  end
end

local function ch_addgroup(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.group.add") then
    vRP.prompt(player,"User id: ","",function(player,id)
      id = tonumber(id)
      vRP.prompt(player,"Group to add: ","",function(player,group)
        vRP.addUserGroup(id,group)
        vRPclient.notify(player,{group.." added to user "..id})
      end)
    end)
  end
end

local function ch_removegroup(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.group.remove") then
    vRP.prompt(player,"User id: ","",function(player,id)
      id = tonumber(id)
      vRP.prompt(player,"Group to remove: ","",function(player,group)
        vRP.removeUserGroup(id,group)
        vRPclient.notify(player,{group.." removed from user "..id})
      end)
    end)
  end
end

local function ch_kick(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.kick") then
    vRP.prompt(player,"User id to kick: ","",function(player,id)
      id = tonumber(id)
      vRP.prompt(player,"Reason: ","",function(player,reason)
        local source = vRP.getUserSource(id)
        if source ~= nil then
          vRP.kick(source,reason)
          vRPclient.notify(player,{"kicked user "..id})
        end
      end)
    end)
  end
end

local function ch_ban(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.ban") then
    vRP.prompt(player,"User id to ban: ","",function(player,id)
      id = tonumber(id)
      vRP.prompt(player,"Reason: ","",function(player,reason)
        local source = vRP.getUserSource(id)
        if source ~= nil then
          vRP.ban(source,reason)
          vRPclient.notify(player,{"banned user "..id})
        end
      end)
    end)
  end
end

local function ch_unban(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.unban") then
    vRP.prompt(player,"User id to unban: ","",function(player,id)
      id = tonumber(id)
      vRP.setBanned(id,false)
      vRPclient.notify(player,{"un-banned user "..id})
    end)
  end
end

AddEventHandler("vRP:buildMainMenu",function(player)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local choices = {}

    if vRP.hasPermission(user_id,"player.list") then
      choices["@User list"] = {ch_list,"Show/hide user list."}
    end
    if vRP.hasPermission(user_id,"player.whitelist") then
      choices["@Whitelist user"] = {ch_whitelist}
    end
    if vRP.hasPermission(user_id,"player.group.add") then
      choices["@Add group"] = {ch_addgroup}
    end
    if vRP.hasPermission(user_id,"player.group.remove") then
      choices["@Remove group"] = {ch_removegroup}
    end
    if vRP.hasPermission(user_id,"player.unwhitelist") then
      choices["@Un-whitelist user"] = {ch_unwhitelist}
    end
    if vRP.hasPermission(user_id,"player.kick") then
      choices["@Kick"] = {ch_kick}
    end
    if vRP.hasPermission(user_id,"player.ban") then
      choices["@Ban"] = {ch_ban}
    end
    if vRP.hasPermission(user_id,"player.unban") then
      choices["@Unban"] = {ch_unban}
    end

    vRP.buildMainMenu(player,choices)
  end
end)
