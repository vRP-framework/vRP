local htmlEntities = module("lib/htmlEntities")

local Admin = class("Admin", vRP.Extension)

-- STATIC

local m_list_css = [[
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

local function m_list_close(menu)
  vRP.EXT.GUI.remote._removeDiv(menu.user.source, "user_list")
  menu.player_list = nil
end

local function m_list(menu)
  local user = menu.user

  if user:hasPermission("player.list") then
    if menu.player_list then -- hide
      m_list_close(menu)
    else -- show
      local content = ""
      for id,user in pairs(vRP.users) do
--        local identity = vRP.getUserIdentity(k)
        content = content.."<br />"..user.id.." => <span class=\"pseudo\">"..user.name.."</span> <span class=\"endpoint\">"..user.endpoint.."</span>"
        if identity then
          content = content.." <span class=\"name\">"..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).."</span> <span class=\"reg\">"..identity.registration.."</span> <span class=\"phone\">"..identity.phone.."</span>"
        end
      end

      vRP.EXT.GUI.remote._setDiv(user.source, "user_list", m_list_css, content)
      menu.player_list = true
    end
  end
end

local function m_whitelist(menu)
  local user = menu.user
  if user:hasPermission("player.whitelist") then
    local id = user:prompt("User id to whitelist: ","")
    id = parseInt(id)
    vRP:setWhitelisted(id,true)
    vRP.EXT.Base.remote._notify(user.source, "whitelisted user "..id)
  end
end

local function m_unwhitelist(menu)
  local user = menu.user
  if user:hasPermission("player.unwhitelist") then
    local id = user:prompt("User id to un-whitelist: ","")
    id = parseInt(id)
    vRP:setWhitelisted(id,false)
    vRP.EXT.Base.remote._notify(user.source, "un-whitelisted user "..id)
  end
end

local function m_addgroup(menu)
  local user = menu.user
  if user:hasPermission("player.group.add") then
    local id = user:prompt("User id: ","") 
    id = parseInt(id) 
    local tuser = vRP.users[id]
    if tuser then
      local group = user:prompt("Group to add: ","")
      if group then
        tuser:addGroup(group)
        vRP.EXT.Base.remote._notify(user.source, group.." added to user "..id)
      end
    end
  end
end

local function m_removegroup(menu)
  local user = menu.user
  if user:hasPermission("player.group.remove") then
    local id = user:prompt("User id: ","")
    id = parseInt(id) 
    local tuser = vRP.users[id]
    if tuser then
      local group = user:prompt("Group to remove: ","")
      if group then
        tuser:removeGroup(group)
        vRP.EXT.Base.remote._notify(user.source, group.." removed from user "..id)
      end
    end
  end
end

local function m_kick(menu)
  local user = menu.user
  if user:hasPermission("player.kick") then
    local id = user:prompt("User id to kick: ","")
    id = parseInt(id)
    local tuser = vRP.users[id]
    if tuser then
      local reason = user:prompt("Reason: ","")
      vRP:kick(tuser,reason)
      vRP.EXT.Base.remote._notify(user.source, "kicked user "..id)
    end
  end
end

local function m_ban(menu)
  local user = menu.user
  if user:hasPermission("player.ban") then
    local id = user:prompt("User id to ban: ","")
    id = parseInt(id) 
    local tuser = vRP.users[id]

    if tuser then -- online
      local reason = user:prompt("Reason: ","")
      vRP:ban(tuser,reason)
    else -- offline
      vRP:setBanned(id,true)
    end

    vRP.EXT.Base.remote._notify(user.source, "banned user "..id)
  end
end

local function m_unban(menu)
  local user = menu.user
  if user:hasPermission("player.unban") then
    local id = user:prompt("User id to unban: ","")
    id = parseInt(id) 
    vRP:setBanned(id,false)
    vRP.EXT.Base.remote._notify(user.source, "un-banned user "..id)
  end
end

local function m_emote(menu, upper)
  local user = menu.user
  if user:hasPermission("player.custom_emote") then
    local content = user:prompt("Animation sequence ('dict anim optional_loops' per line): ","")
    local seq = {}
    for line in string.gmatch(content,"[^\n]+") do
      local args = {}
      for arg in string.gmatch(line,"[^%s]+") do
        table.insert(args,arg)
      end

      table.insert(seq,{args[1] or "", args[2] or "", args[4] or 1})
    end

    vRP.EXT.Base.remote._playAnim(user.source, upper, seq, false)
  end
end

local function m_emote_task(menu)
  local user = menu.user
  if user:hasPermission("player.custom_emote") then
    local content = user:prompt("Task name: ","")
    local seq = {task = content or ""}

    vRP.EXT.Base.remote._playAnim(user.source, false, seq, false)
  end
end

local function m_model(menu)
  local user = menu.user
  if user:hasPermission("player.custom_model") then
    local model = user:prompt("Model hash or name: ","")
    local hash = tonumber(model)
    local custom = {}
    if hash then
      custom.modelhash = hash
    else
      custom.model = model
    end

    vRP.EXT.PlayerState.remote._setCustomization(user.source, custom)
  end
end

local function m_sound(menu)
  local user = menu.user
  if user:hasPermission("player.custom_sound") then
    local content = user:prompt("Sound 'dict name': ","")
    local args = {}
    for arg in string.gmatch(content,"[^%s]+") do
      table.insert(args,arg)
    end
    vRP.EXT.Base.remote._playSound(user.source, args[1] or "", args[2] or "")
  end
end

local function m_coords(menu)
  local user = menu.user
  local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
  user:prompt("Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z)
end

local function m_tptome(menu)
  local user = menu.user
  local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
  local id = parseInt(user:prompt("User id:",""))
  local tuser = vRP.users[id]
  if tuser then
    vRP.EXT.Base.remote._teleport(tuser.source,x,y,z)
  end
end

local function m_tpto(menu)
  local user = menu.user
  local id = parseInt(user:prompt("User id:",""))
  local tuser = vRP.users[id]
  if tuser then
    vRP.EXT.Base.remote._teleport(user.source, vRP.EXT.Base.remote.getPosition(tuser.source))
  end
end

local function m_tptocoords(menu)
  local user = menu.user
  local fcoords = user:prompt("Coords x,y,z:","")
  local coords = {}
  for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
    table.insert(coords,tonumber(coord))
  end

  vRP.EXT.Base.remote._teleport(user.source, coords[1] or 0, coords[2] or 0, coords[3] or 0)
end

local function m_givemoney(menu)
  local user = menu.user
  if user:hasPermission("player.givemoney") then 
    local amount = parseInt(user:prompt("Amount:",""))
    user:giveWallet(amount)
  end
end

local function m_giveitem(menu)
  local user = menu.user
  local fullid = user:prompt("Full id:","") or ""
  local amount = parseInt(user:prompt("Amount:",""))
  if not user:tryGiveItem(fullid, amount) then
    vRP.EXT.Base.remote._notify(user.source, "invalid item or inventory full")
  end
end

local function m_calladmin(menu)
  local user = menu.user
  local desc = user:prompt("Describe your problem:","") or ""
  local answered = false

  local admins = {} 
  for id,user in pairs(vRP.users) do
    -- check admin
    if user:isReady() and user:hasPermission("admin.tickets") then
      table.insert(admins, user)
    end
  end

  -- send notify and alert to all admins
  for _,admin in pairs(admins) do
    async(function()
      local ok = admin:request("Admin ticket (user_id = "..user.id..") take/TP to ?: "..htmlEntities.encode(desc), 60)
      if ok then -- take the call
        if not answered then
          -- answer the call
          vRP.EXT.Base.remote._notify(user.source,"An admin took your ticket.")
          vRP.EXT.Base.remote._teleport(admin.source, vRP.EXT.Base.remote.getPosition(user.source))
          answered = true
        else
          vRP.EXT.Base.remote._notify(admin.source,"Ticket already taken.")
        end
      end
    end)
  end
end

local m_display_custom_css = [[
.div_customization_display{ 
  margin: auto; 
  padding: 8px; 
  width: 500px; 
  margin-top: 80px; 
  background: black; 
  color: white; 
  font-weight: bold;
}
]]

local function m_display_custom_close(menu)
  menu.custom_display = nil
  vRP.EXT.GUI.remote._removeDiv(menu.user.source,"customization_display")
end

local function m_display_custom(menu)
  local user = menu.user


  if menu.custom_display then -- hide
    m_display_custom_close(menu)
  else -- show
    local custom = vRP.EXT.PlayerState.remote.getCustomization(user.source)
    local content = ""
    for k,v in pairs(custom) do
      content = content..k.." => "..json.encode(v).."<br />" 
    end

    menu.custom_display = true
    vRP.EXT.GUI.remote._setDiv(user.source,"customization_display", m_display_custom_css, content)
  end
end

local function m_noclip(menu)
  vRP.EXT.Admin.remote._toggleNoclip(menu.user.source)
end

local function m_audiosource(menu)
  local user = menu.user

  local infos = splitString(user:prompt("Audio source: name=url, omit url to delete the named source.", ""), "=")
  local name = infos[1]
  local url = infos[2]

  if name and string.len(name) > 0 then
    if url and string.len(url) > 0 then
      local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
      vRP.EXT.Audio.remote._setAudioSource(-1,"vRP:admin:"..name,url,0.5,x,y,z,125)
    else
      vRP.EXT.Audio.remote._removeAudioSource(-1,"vRP:admin:"..name)
    end
  end
end

-- METHODS

function Admin:__construct()
  vRP.Extension.__construct(self)

  -- main menu
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption("Admin", function(menu)
      menu.user:openMenu("admin")
    end)
  end)

  -- admin menu
  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    local user = menu.user

    menu.title = "Admin"
    menu.css.header_color = "rgba(200,0,0,0.75)"

    if user:hasPermission("player.calladmin") then
      menu:addOption("Call admin", m_calladmin)
    end
    if user:hasPermission("player.list") then
      menu:addOption("User list", m_list, "Show/hide user list.")
      menu:listen("close", m_list_close)
    end
    if user:hasPermission("player.kick") then
      menu:addOption("Kick", m_kick)
    end
    if user:hasPermission("player.ban") then
      menu:addOption("Ban", m_ban)
    end
    if user:hasPermission("player.unban") then
      menu:addOption("Unban", m_unban)
    end
    if user:hasPermission("player.whitelist") then
      menu:addOption("Whitelist user", m_whitelist)
    end
    if user:hasPermission("player.unwhitelist") then
      menu:addOption("Un-whitelist user", m_unwhitelist)
    end
    if user:hasPermission("player.group.add") then
      menu:addOption("Add group", m_addgroup)
    end
    if user:hasPermission("player.group.remove") then
      menu:addOption("Remove group", m_removegroup)
    end
    if user:hasPermission("player.tptome") then
      menu:addOption("TpToMe", m_tptome)
    end
    if user:hasPermission("player.tpto") then
      menu:addOption("TpTo", m_tpto)
    end
    if user:hasPermission("player.tpto") then
      menu:addOption("TpToCoords", m_tptocoords)
    end
    if user:hasPermission("player.noclip") then
      menu:addOption("Noclip", m_noclip)
    end
    if user:hasPermission("player.coords") then
      menu:addOption("Coords", m_coords)
    end
    if user:hasPermission("player.givemoney") then
      menu:addOption("Give money", m_givemoney)
    end
    if user:hasPermission("player.giveitem") then
      menu:addOption("Give item", m_giveitem)
    end
    if user:hasPermission("player.custom_emote") then
      menu:addOption("Custom upper emote", m_emote, nil, true)
    end
    if user:hasPermission("player.custom_emote") then
      menu:addOption("Custom full emote", m_emote, nil, false)
    end
    if user:hasPermission("player.custom_emote") then
      menu:addOption("Custom emote task", m_emote_task)
    end
    if user:hasPermission("player.custom_model") then
      menu:addOption("Custom model", m_model)
    end
    if user:hasPermission("player.custom_sound") then
      menu:addOption("Custom sound", m_sound)
    end
    if user:hasPermission("player.custom_sound") then
      menu:addOption("Custom audiosource", m_audiosource)
    end
    if user:hasPermission("player.display_custom") then
      menu:addOption("Display customization", m_display_custom)
      menu:listen("close", m_display_custom_close)
    end
  end)

  -- admin god mode task
  local function task_god()
    SetTimeout(10000, task_god)

    for _,user in pairs(vRP.EXT.Group:getUsersByPermission("admin.god")) do
      user:setVital("water", 1)
      user:setVital("food", 1)
      vRP.EXT.PlayerState.remote._setHealth(user.source, 200)
    end
  end
  task_god()
end

vRP:registerExtension(Admin)
