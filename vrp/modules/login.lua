-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.login then return end

local lang = vRP.lang
local htmlEntities = module("lib/htmlEntities")

local Login = class("Login", vRP.Extension)

-- PRIVATE METHODS

-- menu: admin user user
local function menu_admin_users_user(self)
  local function m_info(menu, value, mod, index)
    local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]
    local end_timestamp, reason = self:checkBanned(id)
    menu:updateOption(index, nil, lang.login.info.description({
      self:isWhitelisted(id) and "true" or "false", -- whitelisted
      end_timestamp and "until "..os.date("!%d/%m/%Y %H:%M", end_timestamp).." UTC" or "false",
      htmlEntities.encode(reason or "") -- reason
    }))
  end
  local function m_ban(menu)
    local id = menu.data.id
    local tuser = vRP.users[id]
    -- duration
    local duration, suffix = menu.user:prompt(lang.login.ban.prompt_duration(), "-1"):match("(%-?%d+)([smhd]?)")
    duration = tonumber(duration) or 0
    if suffix == "m" then duration = duration*60
    elseif suffix == "h" then duration = duration*3600
    elseif suffix == "d" then duration = duration*3600*24 end
    -- reason
    local reason = menu.user:prompt(lang.login.ban.prompt_reason(), "")
    -- ban
    if tuser then -- online
      self:ban(tuser, duration, reason)
    else -- offline
      local end_timestamp = duration < 0 and 2^31-1 or os.time()+duration
      self:setBanned(id, end_timestamp, reason)
    end
  end
  local function m_unban(menu)
    self:setBanned(menu.data.id, 0)
  end
  local function m_whitelist(menu)
    self:setWhitelisted(menu.data.id, true)
  end
  local function m_unwhitelist(menu)
    self:setWhitelisted(menu.data.id, false)
  end

  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]

    menu:addOption(lang.login.info.title(), m_info, lang.login.info.description())
    if user:hasPermission("player.ban") then
      menu:addOption(lang.login.ban.title(), m_ban)
    end
    if user:hasPermission("player.unban") then
      menu:addOption(lang.login.unban.title(), m_unban)
    end
    if user:hasPermission("player.whitelist") then
      menu:addOption(lang.login.whitelist.title(), m_whitelist)
    end
    if user:hasPermission("player.unwhitelist") then
      menu:addOption(lang.login.unwhitelist.title(), m_unwhitelist)
    end
  end)
end

-- METHODS

function Login:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp", "cfg/login")
  -- menu
  menu_admin_users_user(self)
  -- DB
  vRP:prepare("Login/tables", [[
CREATE TABLE IF NOT EXISTS vrp_login_users(
  user_id INTEGER,
  whitelisted BOOLEAN,
  ban_end INTEGER,
  ban_reason TEXT,
  CONSTRAINT pk_login_users PRIMARY KEY(user_id),
  CONSTRAINT fk_login_users_vrp FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);
  ]])
  vRP:prepare("Login/init_user", "INSERT IGNORE INTO vrp_login_users(user_id, whitelisted, ban_end, ban_reason) VALUES(@user_id, false, 0, '')")
  vRP:prepare("Login/get_banned", "SELECT ban_end, ban_reason FROM vrp_login_users WHERE user_id = @user_id")
  vRP:prepare("Login/set_banned", "UPDATE vrp_login_users SET ban_end = @end_timestamp, ban_reason = @reason WHERE user_id = @user_id")
  vRP:prepare("Login/get_whitelisted", "SELECT whitelisted FROM vrp_login_users WHERE user_id = @user_id")
  vRP:prepare("Login/set_whitelisted", "UPDATE vrp_login_users SET whitelisted = @whitelisted WHERE user_id = @user_id")
  async(function() vRP:execute("Login/tables") end)
end

-- return (end_timestamp, reason) if banned or nil
function Login:checkBanned(user_id)
  local rows = vRP:query("Login/get_banned", {user_id = user_id})
  if #rows > 0 and os.time() < rows[1].ban_end then
    return rows[1].ban_end, rows[1].ban_reason
  end
end

-- end_timestamp: POSIX timestamp (0: not banned, 2^32-1: banned "forever")
-- reason: (optional)
function Login:setBanned(user_id, end_timestamp, reason)
  vRP:execute("Login/set_banned", {user_id = user_id, end_timestamp = end_timestamp, reason = reason or ""})
end

function Login:isWhitelisted(user_id)
  local rows = vRP:query("Login/get_whitelisted", {user_id = user_id})
  if #rows > 0 then return rows[1].whitelisted else return false end
end

function Login:setWhitelisted(user_id, whitelisted)
  vRP:execute("Login/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
end

-- duration: in seconds (-1: ban "forever")
-- reason: (optional)
function Login:ban(user, duration, reason)
  local end_timestamp = duration < 0 and 2^31-1 or os.time()+duration
  self:setBanned(user.id, end_timestamp, reason)
  vRP:kick(user, "Banned (until "..os.date("!%d/%m/%Y %H:%M", end_timestamp).." UTC): "..(reason or ""))
end

-- EVENT

Login.event = {}
function Login.event:playerJoin(user)
  vRP:execute("Login/init_user", {user_id = user.id})
end

vRP:registerExtension(Login)

-- RAW EVENT

AddEventHandler("playerConnecting", function(name, setMessage, deferrals)
  local source = source
  local self = vRP.EXT.Login
  deferrals.defer()
  Citizen.Wait(0)
  deferrals.update("Authentication...")
  local user_id = vRP:authUser(source)
  if user_id then
    self:log(vRP.getPlayerName(source).." ("..vRP.getPlayerEndpoint(source)..") joined (user_id = "..user_id..")")
    deferrals.update("Checking banned...")
    local end_timestamp, reason = self:checkBanned(user_id)
    if not end_timestamp then
      deferrals.update("Checking whitelisted...")
      if not self.cfg.whitelist or self:isWhitelisted(user_id) then
        -- allowed
        Citizen.Wait(0)
        deferrals.done()
      else
        self:log(name.." ("..vRP.getPlayerEndpoint(source)..") rejected: not whitelisted (user_id = "..user_id..")")
        Citizen.Wait(0)
        deferrals.done("Not whitelisted (user_id = "..user_id..").")
      end
    else
      self:log(name.." ("..vRP.getPlayerEndpoint(source)..") rejected: banned (user_id = "..user_id..")")
      Citizen.Wait(0)
      deferrals.done("Banned (user_id = "..user_id..", until "..os.date("!%d/%m/%Y %H:%M", end_timestamp).." UTC): "..reason)
    end
  else
    self:log(name.." ("..vRP.getPlayerEndpoint(source)..") rejected: identification error")
    Citizen.Wait(0)
    deferrals.done("Authentication failed.")
  end
end)
