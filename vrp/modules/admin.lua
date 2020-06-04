-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.admin then return end

local htmlEntities = module("lib/htmlEntities")

local lang = vRP.lang

local Admin = class("Admin", vRP.Extension)

-- STATIC

-- PRIVATE METHODS

-- menu: admin user user
local function menu_admin_users_user(self)
  local function m_info(menu, value, mod, index)
    local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]

    menu:updateOption(index, nil, lang.admin.users.user.info.description({
      htmlEntities.encode(tuser and tuser.endpoint or "offline"), -- endpoint
      tuser and tuser.source or "offline", -- source
      tuser and tuser.last_login or "offline", -- last login
      tuser and tuser.cid or "none", -- character id
      vRP:isBanned(id) and "true" or "false", -- banned
      vRP:isWhitelisted(id) and "true" or "false" -- whitelisted
    }))
  end

  local function m_kick(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local reason = user:prompt(lang.admin.users.user.kick.prompt(),"")
      vRP:kick(tuser,reason)
    end
  end

  local function m_ban(menu)
    local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]

    if tuser then -- online
      local reason = user:prompt(lang.admin.users.user.ban.prompt(),"")
      vRP:ban(tuser,reason)
    else -- offline
      vRP:setBanned(id,true)
    end
  end

  local function m_unban(menu)
    local user = menu.user
    local id = menu.data.id

    vRP:setBanned(id,false)
  end

  local function m_whitelist(menu)
    local user = menu.user
    local id = menu.data.id

    vRP:setWhitelisted(id,true)
  end

  local function m_unwhitelist(menu)
    local user = menu.user
    local id = menu.data.id

    vRP:setWhitelisted(id,false)
  end

  local function m_tptome(menu)
    local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]

    if tuser then
      local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
      vRP.EXT.Base.remote._teleport(tuser.source,x,y,z)
    end
  end

  local function m_tpto(menu)
    local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]

    if tuser then
      vRP.EXT.Base.remote._teleport(user.source, vRP.EXT.Base.remote.getPosition(tuser.source))
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]

    if tuser then -- online
      menu.title = lang.admin.users.user.title({id, tuser.name})
    else
      menu.title = lang.admin.users.user.title({id, htmlEntities.encode("<offline>")})
    end

    menu.css.header_color = "rgba(200,0,0,0.75)"

    menu:addOption(lang.admin.users.user.info.title(), m_info, lang.admin.users.user.info.description())

    if tuser and user:hasPermission("player.kick") then
      menu:addOption(lang.admin.users.user.kick.title(), m_kick)
    end

    if user:hasPermission("player.ban") then
      menu:addOption(lang.admin.users.user.ban.title(), m_ban)
    end
    if user:hasPermission("player.unban") then
      menu:addOption(lang.admin.users.user.unban.title(), m_unban)
    end
    if user:hasPermission("player.whitelist") then
      menu:addOption(lang.admin.users.user.whitelist.title(), m_whitelist)
    end
    if user:hasPermission("player.unwhitelist") then
      menu:addOption(lang.admin.users.user.unwhitelist.title(), m_unwhitelist)
    end
    if tuser and user:hasPermission("player.tptome") then
      menu:addOption(lang.admin.users.user.tptome.title(), m_tptome)
    end
    if tuser and user:hasPermission("player.tpto") then
      menu:addOption(lang.admin.users.user.tpto.title(), m_tpto)
    end
  end)
end

-- menu: admin users
local function menu_admin_users(self)
  local function m_user(menu, id)
    menu.user:openMenu("admin.users.user", {id = id})
  end
  
  local function m_by_id(menu)
    local id = parseInt(menu.user:prompt(lang.admin.users.by_id.prompt(),""))
    menu.user:openMenu("admin.users.user", {id = id})
  end

  vRP.EXT.GUI:registerMenuBuilder("admin.users", function(menu)
    local user = menu.user

    menu.title = lang.admin.users.title()
    menu.css.header_color = "rgba(200,0,0,0.75)"

    menu:addOption(lang.admin.users.by_id.title(), m_by_id)

    for id, user in pairs(vRP.users) do
      menu:addOption(lang.admin.users.user.title({id, htmlEntities.encode(user.name)}), m_user, nil, id)
    end
  end)
end

-- menu: admin
local function menu_admin(self)
  local function m_users(menu)
    menu.user:openMenu("admin.users")
  end

  local function m_emote(menu, upper)
    local user = menu.user
    local content = user:prompt(lang.admin.custom_upper_emote.prompt(),"")
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

  local function m_emote_task(menu)
    local user = menu.user
    local content = user:prompt(lang.admin.custom_emote_task.prompt(),"")
    local seq = {task = content or ""}

    vRP.EXT.Base.remote._playAnim(user.source, false, seq, false)
  end

  local function m_sound(menu)
    local user = menu.user
    local content = user:prompt(lang.admin.custom_sound.prompt(),"")
    local args = {}
    for arg in string.gmatch(content,"[^%s]+") do
      table.insert(args,arg)
    end
    vRP.EXT.Base.remote._playSound(user.source, args[1] or "", args[2] or "")
  end

  local function m_coords(menu)
    local user = menu.user
    local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
    user:prompt(lang.admin.coords.hint(),x..","..y..","..z)
  end

  local function m_tptocoords(menu)
    local user = menu.user
    local fcoords = user:prompt(lang.admin.tptocoords.prompt(),"")
    local coords = {}
    for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
      table.insert(coords,tonumber(coord))
    end

    vRP.EXT.Base.remote._teleport(user.source, coords[1] or 0, coords[2] or 0, coords[3] or 0)
  end

  local function m_tptomarker(menu)
    self.remote._teleportToMarker(menu.user.source)
  end

  local function m_calladmin(menu)
    local user = menu.user
    local desc = user:prompt(lang.admin.call_admin.prompt(),"") or ""
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
        local ok = admin:request(lang.admin.call_admin.request({user.id, htmlEntities.encode(desc)}), 60)
        if ok then -- take the call
          if not answered then
            -- answer the call
            vRP.EXT.Base.remote._notify(user.source,lang.admin.call_admin.notify_taken())
            vRP.EXT.Base.remote._teleport(admin.source, vRP.EXT.Base.remote.getPosition(user.source))
            answered = true
          else
            vRP.EXT.Base.remote._notify(admin.source,lang.admin.call_admin.notify_already_taken())
          end
        end
      end)
    end
  end

  local function m_noclip(menu)
    self.remote._toggleNoclip(menu.user.source)
  end

  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    local user = menu.user

    menu.title = lang.admin.title()
    menu.css.header_color = "rgba(200,0,0,0.75)"

    if user:hasPermission("player.calladmin") then
      menu:addOption(lang.admin.call_admin.title(), m_calladmin)
    end
    if user:hasPermission("player.list") then
      menu:addOption(lang.admin.users.title(), m_users)
    end
    if user:hasPermission("player.tpto") then
      menu:addOption(lang.admin.tptomarker.title(), m_tptomarker)
    end
    if user:hasPermission("player.tpto") then
      menu:addOption(lang.admin.tptocoords.title(), m_tptocoords)
    end
    if user:hasPermission("player.noclip") then
      menu:addOption(lang.admin.noclip.title(), m_noclip)
    end
    if user:hasPermission("player.coords") then
      menu:addOption(lang.admin.coords.title(), m_coords)
    end
    if user:hasPermission("player.custom_emote") then
      menu:addOption(lang.admin.custom_upper_emote.title(), m_emote, nil, true)
    end
    if user:hasPermission("player.custom_emote") then
      menu:addOption(lang.admin.custom_full_emote.title(), m_emote, nil, false)
    end
    if user:hasPermission("player.custom_emote") then
      menu:addOption(lang.admin.custom_emote_task.title(), m_emote_task)
    end
    if user:hasPermission("player.custom_sound") then
      menu:addOption(lang.admin.custom_sound.title(), m_sound)
    end
  end)
end

-- METHODS

function Admin:__construct()
  vRP.Extension.__construct(self)

  menu_admin(self)
  menu_admin_users(self)
  menu_admin_users_user(self)

  -- main menu
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption("Admin", function(menu)
      menu.user:openMenu("admin")
    end)
  end)

  -- admin god mode task
  local function task_god()
    SetTimeout(10000, task_god)

    if vRP.EXT.Group then
      for _,user in pairs(vRP.EXT.Group:getUsersByPermission("admin.god")) do
        user:setVital("water", 1)
        user:setVital("food", 1)
        vRP.EXT.PlayerState.remote._setHealth(user.source, 200)
      end
    end
  end
  task_god()
end

vRP:registerExtension(Admin)
