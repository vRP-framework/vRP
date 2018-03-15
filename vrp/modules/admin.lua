local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")

-- this module define some admin menu functions

local player_lists = {}

local function ch_list(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.list") then
    if player_lists[player] then -- hide
      player_lists[player] = nil
      vRPclient._removeDiv(player,{"user_list"})
    else -- show
      local content = ""
      for k,v in pairs(vRP.rusers) do
        local source = vRP.getUserSource(k)
        local identity = vRP.getUserIdentity(k)
        if source then
          content = content.."<br />"..k.." => <span class=\"pseudo\">"..vRP.getPlayerName(source).."</span> <span class=\"endpoint\">"..vRP.getPlayerEndpoint(source).."</span>"
          if identity then
            content = content.." <span class=\"name\">"..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).."</span> <span class=\"reg\">"..identity.registration.."</span> <span class=\"phone\">"..identity.phone.."</span>"
          end
        end
      end

      player_lists[player] = true
      local css = [[
.div_user_list{ 
  margin: auto; 
  padding: 8px; 
  width: 650px; 
  margin-top: 80px; 
  background: black; 
  color: white; 
  font-weight: bold; 
  font-size: 1.1em;
} 

.div_user_list .pseudo{ 
  color: rgb(0,255,125);
}

.div_user_list .endpoint{ 
  color: rgb(255,0,0);
}

.div_user_list .name{ 
  color: #309eff;
}

.div_user_list .reg{ 
  color: rgb(0,125,255);
}
              
.div_user_list .phone{ 
  color: rgb(211, 0, 255);
}
            ]]
      vRPclient._setDiv(player, "user_list", css, content)
    end
  end
end

local function ch_whitelist(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.whitelist") then
    local id = vRP.prompt(player,"User id to whitelist: ","")
    id = parseInt(id)
    vRP.setWhitelisted(id,true)
    vRPclient._notify(player, "whitelisted user "..id)
  end
end

local function ch_unwhitelist(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.unwhitelist") then
    local id = vRP.prompt(player,"User id to un-whitelist: ","")
    id = parseInt(id)
    vRP.setWhitelisted(id,false)
    vRPclient._notify(player, "un-whitelisted user "..id)
  end
end

local function ch_addgroup(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.group.add") then
    local id = vRP.prompt(player,"User id: ","") 
    id = parseInt(id)
    local group = vRP.prompt(player,"Group to add: ","")
    if group then
      vRP.addUserGroup(id,group)
      vRPclient._notify(player, group.." added to user "..id)
    end
  end
end

local function ch_removegroup(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.group.remove") then
    local id = vRP.prompt(player,"User id: ","")
    id = parseInt(id)
    local group = vRP.prompt(player,"Group to remove: ","")
    if group then
      vRP.removeUserGroup(id,group)
      vRPclient._notify(player, group.." removed from user "..id)
    end
  end
end

local function ch_kick(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.kick") then
    local id = vRP.prompt(player,"User id to kick: ","")
    id = parseInt(id)
    local reason = vRP.prompt(player,"Reason: ","")
    local source = vRP.getUserSource(id)
    if source then
      vRP.kick(source,reason)
      vRPclient._notify(player, "kicked user "..id)
    end
  end
end

local function ch_ban(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.ban") then
    local id = vRP.prompt(player,"User id to ban: ","")
    id = parseInt(id)
    local reason = vRP.prompt(player,"Reason: ","")
    local source = vRP.getUserSource(id)
    if source then
      vRP.ban(source,reason)
      vRPclient._notify(player, "banned user "..id)
    end
  end
end

local function ch_unban(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.unban") then
    local id = vRP.prompt(player,"User id to unban: ","")
    id = parseInt(id)
    vRP.setBanned(id,false)
    vRPclient._notify(player, "un-banned user "..id)
  end
end

local function ch_emote(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.custom_emote") then
    local content = vRP.prompt(player,"Animation sequence ('dict anim optional_loops' per line): ","")
    local seq = {}
    for line in string.gmatch(content,"[^\n]+") do
      local args = {}
      for arg in string.gmatch(line,"[^%s]+") do
        table.insert(args,arg)
      end

      table.insert(seq,{args[1] or "", args[2] or "", args[3] or 1})
    end

    vRPclient._playAnim(player, true,seq,false)
  end
end

local function ch_sound(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"player.custom_sound") then
    local content = vRP.prompt(player,"Sound 'dict name': ","")
      local args = {}
      for arg in string.gmatch(content,"[^%s]+") do
        table.insert(args,arg)
      end
      vRPclient._playSound(player, args[1] or "", args[2] or "")
  end
end

local function ch_coords(player,choice)
  local x,y,z = vRPclient.getPosition(player)
  vRP.prompt(player,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z)
end

local function ch_tptome(player,choice)
  local x,y,z = vRPclient.getPosition(player)
  local user_id = vRP.prompt(player,"User id:","")
  local tplayer = vRP.getUserSource(tonumber(user_id))
  if tplayer then
    vRPclient._teleport(tplayer,x,y,z)
  end
end

local function ch_tpto(player,choice)
  local user_id = vRP.prompt(player,"User id:","")
  local tplayer = vRP.getUserSource(tonumber(user_id))
  if tplayer then
    vRPclient._teleport(player, vRPclient.getPosition(tplayer))
  end
end

local function ch_tptocoords(player,choice)
  local fcoords = vRP.prompt(player,"Coords x,y,z:","")
  local coords = {}
  for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
    table.insert(coords,tonumber(coord))
  end

  vRPclient._teleport(player, coords[1] or 0, coords[2] or 0, coords[3] or 0)
end

local function ch_givemoney(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    local amount = vRP.prompt(player,"Amount:","")
    amount = parseInt(amount)
    vRP.giveMoney(user_id, amount)
  end
end

local function ch_giveitem(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    local idname = vRP.prompt(player,"Id name:","")
    idname = idname or ""
    local amount = vRP.prompt(player,"Amount:","")
    amount = parseInt(amount)
    vRP.giveInventoryItem(user_id, idname, amount,true)
  end
end

local function ch_calladmin(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    local desc = vRP.prompt(player,"Describe your problem:","") or ""
    local answered = false
    local players = {}
    for k,v in pairs(vRP.rusers) do
      local player = vRP.getUserSource(tonumber(k))
      -- check user
      if vRP.hasPermission(k,"admin.tickets") and player then
        table.insert(players,player)
      end
    end

    -- send notify and alert to all listening players
    for k,v in pairs(players) do
      async(function()
        local ok = vRP.request(v,"Admin ticket (user_id = "..user_id..") take/TP to ?: "..htmlEntities.encode(desc), 60)
        if ok then -- take the call
          if not answered then
            -- answer the call
            vRPclient._notify(player,"An admin took your ticket.")
            vRPclient._teleport(v, vRPclient.getPosition(player))
            answered = true
          else
            vRPclient._notify(v,"Ticket already taken.")
          end
        end
      end)
    end
  end
end

local player_customs = {}

local function ch_display_custom(player, choice)
  local custom = vRPclient.getCustomization(player)
  if player_customs[player] then -- hide
    player_customs[player] = nil
    vRPclient._removeDiv(player,"customization")
  else -- show
    local content = ""
    for k,v in pairs(custom) do
      content = content..k.." => "..json.encode(v).."<br />" 
    end

    player_customs[player] = true
    vRPclient._setDiv(player,"customization",".div_customization{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content)
  end
end

local function ch_noclip(player, choice)
  vRPclient._toggleNoclip(player)
end

local function ch_audiosource(player, choice)
  local infos = splitString(vRP.prompt(player, "Audio source: name=url, omit url to delete the named source.", ""), "=")
  local name = infos[1]
  local url = infos[2]

  if name and string.len(name) > 0 then
    if url and string.len(url) > 0 then
      local x,y,z = vRPclient.getPosition(player)
      vRPclient._setAudioSource(-1,"vRP:admin:"..name,url,0.5,x,y,z,125)
    else
      vRPclient._removeAudioSource(-1,"vRP:admin:"..name)
    end
  end
end

vRP.registerMenuBuilder("main", function(add, data)
  local user_id = vRP.getUserId(data.player)
  if user_id then
    local choices = {}

    -- build admin menu
    choices["Admin"] = {function(player,choice)
      local menu  = vRP.buildMenu("admin", {player = player})
      menu.name = "Admin"
      menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
      menu.onclose = function(player) vRP.openMainMenu(player) end -- nest menu

      if vRP.hasPermission(user_id,"player.list") then
        menu["@User list"] = {ch_list,"Show/hide user list."}
      end
      if vRP.hasPermission(user_id,"player.whitelist") then
        menu["@Whitelist user"] = {ch_whitelist}
      end
      if vRP.hasPermission(user_id,"player.group.add") then
        menu["@Add group"] = {ch_addgroup}
      end
      if vRP.hasPermission(user_id,"player.group.remove") then
        menu["@Remove group"] = {ch_removegroup}
      end
      if vRP.hasPermission(user_id,"player.unwhitelist") then
        menu["@Un-whitelist user"] = {ch_unwhitelist}
      end
      if vRP.hasPermission(user_id,"player.kick") then
        menu["@Kick"] = {ch_kick}
      end
      if vRP.hasPermission(user_id,"player.ban") then
        menu["@Ban"] = {ch_ban}
      end
      if vRP.hasPermission(user_id,"player.unban") then
        menu["@Unban"] = {ch_unban}
      end
      if vRP.hasPermission(user_id,"player.noclip") then
        menu["@Noclip"] = {ch_noclip}
      end
      if vRP.hasPermission(user_id,"player.custom_emote") then
        menu["@Custom emote"] = {ch_emote}
      end
      if vRP.hasPermission(user_id,"player.custom_sound") then
        menu["@Custom sound"] = {ch_sound}
      end
      if vRP.hasPermission(user_id,"player.custom_sound") then
        menu["@Custom audiosource"] = {ch_audiosource}
      end
      if vRP.hasPermission(user_id,"player.coords") then
        menu["@Coords"] = {ch_coords}
      end
      if vRP.hasPermission(user_id,"player.tptome") then
        menu["@TpToMe"] = {ch_tptome}
      end
      if vRP.hasPermission(user_id,"player.tpto") then
        menu["@TpTo"] = {ch_tpto}
      end
      if vRP.hasPermission(user_id,"player.tpto") then
        menu["@TpToCoords"] = {ch_tptocoords}
      end
      if vRP.hasPermission(user_id,"player.givemoney") then
        menu["@Give money"] = {ch_givemoney}
      end
      if vRP.hasPermission(user_id,"player.giveitem") then
        menu["@Give item"] = {ch_giveitem}
      end
      if vRP.hasPermission(user_id,"player.display_custom") then
        menu["@Display customization"] = {ch_display_custom}
      end
      if vRP.hasPermission(user_id,"player.calladmin") then
        menu["@Call admin"] = {ch_calladmin}
      end

      vRP.openMenu(player,menu)
    end}

    add(choices)
  end
end)

-- admin god mode
function task_god()
  SetTimeout(10000, task_god)

  for k,v in pairs(vRP.getUsersByPermission("admin.god")) do
    vRP.setHunger(v, 0)
    vRP.setThirst(v, 0)

    local player = vRP.getUserSource(v)
    if player ~= nil then
      vRPclient._setHealth(player, 200)
    end
  end
end

task_god()
