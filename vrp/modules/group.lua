
-- this module describe the group/permission system

-- group functions are used on connected players only
-- multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique

-- api

local cfg = require("resources/vrp/cfg/groups")
local groups = cfg.groups
local users = cfg.users
local selectors = cfg.selectors

-- get groups keys of a connected user
function vRP.getUserGroups(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then 
    if data.groups == nil then
      data.groups = {} -- init groups
    end

    return data.groups
  else
    return {}
  end
end

-- add a group to a connected user
function vRP.addUserGroup(user_id,group)
  if not vRP.hasGroup(user_id,group) then
    local user_groups = vRP.getUserGroups(user_id)
    local ngroup = groups[group]
    if ngroup then
      -- copy group list to prevent iteration while removing
      local _user_groups = {}
      for k,v in pairs(user_groups) do
        _user_groups[k] = v
      end

      for k,v in pairs(_user_groups) do -- remove all groups with the same gtype
        local kgroup = groups[k]
        if kgroup and kgroup._config and ngroup._config and kgroup._config.gtype == ngroup._config.gtype then
          vRP.removeUserGroup(user_id,k)
        end
      end

      -- add group
      user_groups[group] = true
      if ngroup._config and ngroup._config.onjoin then
        ngroup._config.onjoin(source) -- call join callback
      end
    end
  end
end

-- get user group by type
-- return group name or an empty string
function vRP.getUserGroupByType(user_id,gtype)
  local user_groups = vRP.getUserGroups(user_id)
  for k,v in pairs(user_groups) do
    local kgroup = groups[k]
    if kgroup then
      if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
        return k
      end
    end
  end

  return ""
end

-- return list of connected users by group
function vRP.getUsersByGroup(group)
  local users = {}

  for k,v in pairs(vRP.rusers) do
    if vRP.hasGroup(tonumber(k),group) then table.insert(users, tonumber(k)) end
  end

  return users
end

-- return list of connected users by permission
function vRP.getUsersByPermission(perm)
  local users = {}

  for k,v in pairs(vRP.rusers) do
    if vRP.hasPermission(tonumber(k),perm) then table.insert(users, tonumber(k)) end
  end

  return users
end

-- remove a group from a connected user
function vRP.removeUserGroup(user_id,group)
  local user_groups = vRP.getUserGroups(user_id)
  local groupdef = groups[group]
  if groupdef and groupdef._config and groupdef._config.onleave then
    local source = vRP.getUserSource(user_id)
    if source ~= nil then
      groupdef._config.onleave(source) -- call leave callback
    end
  end

  user_groups[group] = nil -- remove reference
end

-- check if the user has a specific group
function vRP.hasGroup(user_id,group)
  local user_groups = vRP.getUserGroups(user_id)
  return (user_groups[group] ~= nil)
end

-- check if the user has a specific permission
function vRP.hasPermission(user_id, perm)
  local user_groups = vRP.getUserGroups(user_id)
  for k,v in pairs(user_groups) do
    local group = groups[k]
    if group then
      for l,w in pairs(group) do -- for each group permission
        if l ~= "_config" and w == perm then return true end
      end
    end
  end

  return false
end

-- GROUP SELECTORS

local function ch_select(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRP.addUserGroup(user_id, choice)
    vRP.closeMenu(player)
  end
end

-- build menus
local selector_menus = {}
for k,v in pairs(selectors) do
  local menu = {name=k, css={top="75px",header_color="rgba(255,154,24,0.75)"}}
  for l,w in pairs(v) do
    if l ~= "_config" then
      menu[w] = {ch_select}
    end
  end

  selector_menus[k] = menu
end

local function build_client_selectors(source)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(selectors) do
      local gcfg = v._config
      local menu = selector_menus[k]

      if gcfg and menu then
        local x = gcfg.x
        local y = gcfg.y
        local z = gcfg.z

        local function selector_enter()
          local user_id = vRP.getUserId(source)
          if user_id ~= nil and (gcfg.permission == nil or vRP.hasPermission(user_id,gcfg.permission)) then
            vRP.openMenu(source,menu) 
          end
        end

        local function selector_leave()
          vRP.closeMenu(source)
        end

        vRPclient.addBlip(source,{x,y,z,gcfg.blipid,gcfg.blipcolor,k})
        vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,255,154,24,125,150})

        vRP.setArea(source,"vRP:gselector:"..k,x,y,z,1,1.5,selector_enter,selector_leave)
      end
    end
  end
end

-- events

-- player spawn
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
  -- first spawn
  if first_spawn then
    -- add selectors 
    build_client_selectors(source)

    -- add groups on user join 
    local user = users[user_id]
    if user ~= nil then
      for k,v in pairs(user) do
        vRP.addUserGroup(user_id,v)
      end
    end

    -- add default group user
    vRP.addUserGroup(user_id,"user")
  end

  -- call group onspawn callback at spawn
  local user_groups = vRP.getUserGroups(user_id)
  for k,v in pairs(user_groups) do
    local group = groups[k]
    if group and group._config and group._config.onspawn then
      group._config.onspawn(source)
    end
  end
end)
