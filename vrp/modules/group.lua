
-- this module define the group/permission system (per character)

-- multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique

local Group = class("Group", vRP.Extension)

-- SUBCLASS

Group.User = class("User")

function Group.User:hasGroup(name)
  return self.cdata.groups[name] ~= nil
end

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
  local groupdef = cfg.groups[group]
  if groupdef and groupdef._config and groupdef._config.onleave then
    groupdef._config.onleave(self) -- call leave callback
  end

  -- trigger leave event
  local gtype = nil
  if groupdef._config then
    gtype = groupdef._config.gtype 
  end
  vRP:triggerEvent("playerLeaveGroup", self, name, gtype)

  groups[name] = nil -- remove reference
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

  --[[
  if fchar == "@" then -- special aptitude permission
    local _perm = string.sub(perm,2,string.len(perm))
    local parts = splitString(_perm,".")
    if #parts == 3 then -- decompose group.aptitude.operator
      local group = parts[1]
      local aptitude = parts[2]
      local op = parts[3]

      local alvl = math.floor(vRP.expToLevel(vRP.getExp(user_id,group,aptitude)))

      local fop = string.sub(op,1,1)
      if fop == "<" then  -- less (group.aptitude.<x)
        local lvl = parseInt(string.sub(op,2,string.len(op)))
        if alvl < lvl then return true end
      elseif fop == ">" then -- greater (group.aptitude.>x)
        local lvl = parseInt(string.sub(op,2,string.len(op)))
        if alvl > lvl then return true end
      else -- equal (group.aptitude.x)
        local lvl = parseInt(string.sub(op,1,string.len(op)))
        if alvl == lvl then return true end
      end
    end
  elseif fchar == "#" then -- special item permission
    local _perm = string.sub(perm,2,string.len(perm))
    local parts = splitString(_perm,".")
    if #parts == 2 then -- decompose item.operator
      local item = parts[1]
      local op = parts[2]

      local amount = vRP.getInventoryItemAmount(user_id, item)

      local fop = string.sub(op,1,1)
      if fop == "<" then  -- less (item.<x)
        local n = parseInt(string.sub(op,2,string.len(op)))
        if amount < n then return true end
      elseif fop == ">" then -- greater (item.>x)
        local n = parseInt(string.sub(op,2,string.len(op)))
        if amount > n then return true end
      else -- equal (item.x)
        local n = parseInt(string.sub(op,1,string.len(op)))
        if amount == n then return true end
      end
    end
    --]]
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

-- METHODS

function Group:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/groups")
  self.func_perms = {}

  -- register not fperm (negate another fperm)
  self:registerPermissionFunction("not", function(user, params)
    return not user:hasPermission("!"..table.concat(params, ".", 2))
  end)

  --[[
  vRP.registerPermissionFunction("is", function(user_id, parts)
    local param = parts[2]
    if param == "inside" then
      local player = vRP.getUserSource(user_id)
      if player then
        return vRPclient.isInside(player)
      end
    elseif param == "invehicle" then
      local player = vRP.getUserSource(user_id)
      if player then
        return vRPclient.isInVehicle(player)
      end
    end
  end)
  --]]
end

-- return list users by group
function Group:getUsersByGroup(name)
  local users = {}

  for _,user in pairs(vRP.users) do
    if user:hasGroup(name) then 
      table.insert(users, user) 
    end
  end

  return users
end

-- return list users by permission
function Group:getUsersByPermission(perm)
  local users = {}

  for _,user in pairs(vRP.users) do
    if user:hasPermission(perm) then 
      table.insert(users, user) 
    end
  end

  return users
end


-- register a special permission function
-- name: name of the permission -> "!name.[...]"
-- callback(user, params) 
--- params: params (strings) of the permissions, ex "!name.param1.param2" -> ["name", "param1", "param2"]
--- should return true or false/nil
function Group:registerPermissionFunction(name, callback)
  self.func_perms[name] = callback
end

-- EVENT

Group.event = {}

function Group.event:playerSpawn(user)
  -- call group onspawn callback at spawn
  local groups = user:getGroups()

  for name in pairs(groups) do
    local group = self.cfg.groups[name]
    if group and group._config and group._config.onspawn then
      group._config.onspawn(user)
    end
  end
end

function Group.event:loadCharacter(user)
  if not user.cdata.groups then -- init groups table
    user.cdata.groups = {}
  end

  -- add config user forced groups
  local groups = self.cfg.users[user.id]
  if groups then
    for _,group in pairs(groups) do
      user:addGroup(group)
    end
  end

  -- add default group user
  user:addGroup("user")
end

vRP:registerExtension(Group)

--[[
-- GROUP SELECTORS

-- build menus
local selector_menus = {}
for k,v in pairs(selectors) do
  local kgroups = {}

  local function ch_select(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id then
      local gname = kgroups[choice]
      if gname then
        vRP.addUserGroup(user_id, gname)
        vRP.closeMenu(player)
      end
    end
  end

  local menu = {name=k, css={top="75px",header_color="rgba(255,154,24,0.75)"}}
  for l,w in pairs(v) do
    if l ~= "_config" then
      local title = vRP.getGroupTitle(w)
      kgroups[title] = w
      menu[title] = {ch_select}
    end
  end

  selector_menus[k] = menu
end

local function build_client_selectors(source)
  local user_id = vRP.getUserId(source)
  if user_id then
    for k,v in pairs(selectors) do
      local gcfg = v._config
      local menu = selector_menus[k]

      if gcfg and menu then
        local x = gcfg.x
        local y = gcfg.y
        local z = gcfg.z

        local function selector_enter(source)
          local user_id = vRP.getUserId(source)
          if user_id ~= nil and vRP.hasPermissions(user_id,gcfg.permissions or {}) then
            vRP.openMenu(source,menu) 
          end
        end

        local function selector_leave(source)
          vRP.closeMenu(source)
        end

        vRPclient._addBlip(source,x,y,z,gcfg.blipid,gcfg.blipcolor,k)
        vRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,255,154,24,125,150)

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

end)

--]]
