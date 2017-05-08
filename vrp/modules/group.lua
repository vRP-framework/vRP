
-- this module describe the group/permission system

-- group functions are used on connected players only
-- multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique

-- api

local cfg = require("resources/vrp/cfg/groups")
local groups = cfg.groups
local users = cfg.users

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
      for k,v in pairs(user_groups) do -- remove all groups with the same gtype
        local kgroup = groups[k]
        if kgroup and kgroup._config and ngroup._config and kgroup._config.gtype == ngroup._config.gtype then
          vRP.removeUserGroup(user_id,k)
        end
      end

      -- add group
      user_groups[group] = true
    end
  end
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

-- player spawn
AddEventHandler("vRP:playerSpawned", function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then -- call group onspawn callback at spawn
    local user_groups = vRP.getUserGroups(user_id)
    for k,v in pairs(user_groups) do
      local group = groups[k]
      if group and group._config and group._config.onspawn then
        group._config.onspawn(source)
      end
    end
  end
end)

-- user join
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  -- add groups on user join 
  local user = users[user_id]
  if user then
    for k,v in pairs(user) do
      vRP.addUserGroup(user_id,v)
    end
  end

  -- add default group user
  vRP.addUserGroup(user_id,"user")
end)
