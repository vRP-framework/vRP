-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.group then return end

local lang = vRP.lang

-- this module define the group/permission system (per character)

-- multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique

local Group = class("Group", vRP.Extension)

-- SUBCLASS

Group.User = class("User")

function Group.User:hasGroup(name)
  return self.cdata.groups[name] ~= nil
end

-- return map of groups
function Group.User:getGroups()
  return self.cdata.groups
end

function Group.User:addGroup(name)
  if not self:hasGroup(name) then
    local groups = self:getGroups()
    local cfg = vRP.EXT.Group.cfg

    local ngroup = cfg.groups[name]
    if ngroup then
      if ngroup._config and ngroup._config.gtype ~= nil then 
        -- copy group list to prevent iteration while removing
        local _groups = {}
        for k,v in pairs(groups) do
          _groups[k] = v
        end

        for k,v in pairs(_groups) do -- remove all groups with the same gtype
          local kgroup = cfg.groups[k]
          if kgroup and kgroup._config and ngroup._config and kgroup._config.gtype == ngroup._config.gtype then
            self:removeGroup(k)
          end
        end
      end

      -- add group
      groups[name] = true
      if ngroup._config and ngroup._config.onjoin then
        ngroup._config.onjoin(self) -- call join callback
      end

      -- trigger join event
      local gtype = nil
      if ngroup._config then
        gtype = ngroup._config.gtype
      end

      vRP:triggerEvent("playerJoinGroup", self, name, gtype)
    end
  end
end

function Group.User:removeGroup(name)
  local groups = self:getGroups()

  local cfg = vRP.EXT.Group.cfg
  local group = cfg.groups[name]
  if group and group._config and group._config.onleave then
    group._config.onleave(self) -- call leave callback
  end

  -- trigger leave event
  local gtype = nil
  if group and group._config then
    gtype = group._config.gtype
  end

  groups[name] = nil -- remove reference

  vRP:triggerEvent("playerLeaveGroup", self, name, gtype)
end

-- get user group by type
-- return group name or nil
function Group.User:getGroupByType(gtype)
  local groups = self:getGroups()
  local cfg = vRP.EXT.Group.cfg

  for k,v in pairs(groups) do
    local kgroup = cfg.groups[k]
    if kgroup then
      if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
        return k
      end
    end
  end
end

-- check if the user has a specific permission
function Group.User:hasPermission(perm)
  local fchar = string.sub(perm,1,1)

  if fchar == "!" then -- special function permission
    local _perm = string.sub(perm,2,string.len(perm))
    local params = splitString(_perm,".")
    if #params > 0 then
      local fperm = vRP.EXT.Group.func_perms[params[1]]
      if fperm then
        return fperm(self, params) or false
      else
        return false
      end
    end
  else -- regular plain permission
    local cfg = vRP.EXT.Group.cfg
    local groups = self:getGroups()

    -- precheck negative permission
    local nperm = "-"..perm
    for name in pairs(groups) do
      local group = cfg.groups[name]
      if group then
        for l,w in pairs(group) do -- for each group permission
          if l ~= "_config" and w == nperm then return false end
        end
      end
    end

    -- check if the permission exists
    for name in pairs(groups) do
      local group = cfg.groups[name]
      if group then
        for l,w in pairs(group) do -- for each group permission
          if l ~= "_config" and w == perm then return true end
        end
      end
    end
  end

  return false
end

-- check if the user has a specific list of permissions (all of them)
function Group.User:hasPermissions(perms)
  for _,perm in pairs(perms) do
    if not self:hasPermission(perm) then
      return false
    end
  end

  return true
end

-- PRIVATE METHODS

-- menu: group_selector
local function menu_group_selector(self)
  local function m_select(menu, group_name)
    local user = menu.user

    user:addGroup(group_name)
    user:closeMenu(menu)
  end

  vRP.EXT.GUI:registerMenuBuilder("group_selector", function(menu)
    menu.title = menu.data.name
    menu.css.header_color = "rgba(255,154,24,0.75)"

    for k,group_name in pairs(menu.data.groups) do
      if k ~= "_config" then
        local title = self:getGroupTitle(group_name)
        if title then
          menu:addOption(title, m_select, nil, group_name)
        end
      end
    end
  end)
end

-- menu: admin users user
local function menu_admin_users_user(self)
  local function m_groups(menu, value, mod, index)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    local groups = ""
    if tuser and tuser:isReady() then
      for group in pairs(tuser.cdata.groups) do
        groups = groups..group.." "
      end
    end

    menu:updateOption(index, nil, lang.admin.users.user.groups.description({groups}))
  end

  local function m_addgroup(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local group = user:prompt(lang.admin.users.user.group_add.prompt(),"")
      tuser:addGroup(group)
    end
  end

  local function m_removegroup(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local group = user:prompt(lang.admin.users.user.group_remove.prompt(),"")
      tuser:removeGroup(group)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      menu:addOption(lang.admin.users.user.groups.title(), m_groups, lang.admin.users.user.groups.description())

      if user:hasPermission("player.group.add") then
        menu:addOption(lang.admin.users.user.group_add.title(), m_addgroup)
      end
      if user:hasPermission("player.group.remove") then
        menu:addOption(lang.admin.users.user.group_remove.title(), m_removegroup)
      end
    end
  end)
end

-- METHODS

function Group:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/groups")
  self.func_perms = {}

  -- register not fperm (negate another fperm)
  self:registerPermissionFunction("not", function(user, params)
    return not user:hasPermission("!"..table.concat(params, ".", 2))
  end)

  -- register group fperm
  self:registerPermissionFunction("group", function(user, params)
    local group = params[2]
    if group then
      return user:hasGroup(group)
    end

    return false
  end)

  -- menu
  menu_group_selector(self)
  menu_admin_users_user(self)

  -- identity gtypes display
  vRP.EXT.GUI:registerMenuBuilder("identity", function(menu)
    local tuser = vRP.users_by_cid[menu.data.cid]
    if tuser then
      for gtype, title in pairs(self.cfg.identity_gtypes) do
        local group_name = tuser:getGroupByType(gtype)
        if group_name then
          local gtitle = self:getGroupTitle(group_name)
          if gtitle then
            menu:addOption(title, nil, gtitle)
          end
        end
      end
    end
  end)

  -- task: group count display
  if next(self.cfg.count_display_permissions) then
    Citizen.CreateThread(function()
      while true do
        Citizen.Wait(self.cfg.count_display_interval*1000)

        -- display
        local content = ""
        for _, dperm in ipairs(self.cfg.count_display_permissions) do
          local count = #self:getUsersByPermission(dperm[1])
          local img = dperm[2]

          content = content.."<div><img src=\""..img.."\" />"..count.."</div>"
        end

        vRP.EXT.GUI.remote.setDivContent(-1, "group_count_display", content)
      end
    end)
  end
end

-- return users list
function Group:getUsersByGroup(name)
  local users = {}

  for _,user in pairs(vRP.users) do
    if user:isReady() and user:hasGroup(name) then 
      table.insert(users, user) 
    end
  end

  return users
end

-- return users list
function Group:getUsersByPermission(perm)
  local users = {}

  for _,user in pairs(vRP.users) do
    if user:isReady() and user:hasPermission(perm) then 
      table.insert(users, user) 
    end
  end

  return users
end

-- return title or nil
function Group:getGroupTitle(group_name)
  local group = self.cfg.groups[group_name]
  if group and group._config then
    return group._config.title
  end
end

-- register a special permission function
-- name: name of the permission -> "!name.[...]"
-- callback(user, params) 
--- params: params (strings) of the permissions, ex "!name.param1.param2" -> ["name", "param1", "param2"]
--- should return true or false/nil
function Group:registerPermissionFunction(name, callback)
  if self.func_perms[name] then
    self:log("WARNING: re-registered permission function \""..name.."\"")
  end
  self.func_perms[name] = callback
end

-- EVENT

Group.event = {}

function Group.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- init group selectors
    for k,v in pairs(self.cfg.selectors) do
      local gcfg = v._config

      if gcfg then
        local x = gcfg.x
        local y = gcfg.y
        local z = gcfg.z

        local menu
        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            menu = user:openMenu("group_selector", {name = k, groups = v}) 
          end
        end

        local function leave(user)
          if menu then
            user:closeMenu(menu)
          end
        end

        local ment = clone(gcfg.map_entity)
        ment[2].title = k
        ment[2].pos = {x,y,z-1}
        vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

        user:setArea("vRP:gselector:"..k,x,y,z,1,1.5,enter,leave)
      end
    end

    -- group count display
    if next(self.cfg.count_display_permissions) then
      vRP.EXT.GUI.remote.setDiv(user.source, "group_count_display", self.cfg.count_display_css, "")
    end
  end

  -- call group onspawn callback at spawn

  local groups = user:getGroups()

  for name in pairs(groups) do
    local group = self.cfg.groups[name]
    if group and group._config and group._config.onspawn then
      group._config.onspawn(user)
    end
  end
end

function Group.event:characterLoad(user)
  if not user.cdata.groups then -- init groups table
    user.cdata.groups = {}
  end

  -- add config user forced groups
  local groups = self.cfg.users[user.id]
  if groups then
    for _,group in ipairs(groups) do
      user:addGroup(group)
    end
  end

  -- add default groups
  for _, group in ipairs(self.cfg.default_groups) do
    user:addGroup(group)
  end
end

vRP:registerExtension(Group)
