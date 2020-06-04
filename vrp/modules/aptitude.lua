-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.aptitude then return end

local lang = vRP.lang
-- define aptitude system (AKA. education, skill system)

-- exp notes:
-- levels are defined by the amount of xp
-- with a step of 5: 5|15|30|50|75
-- total exp for a specific level, exp = step*lvl*(lvl+1)/2
-- level for a specific exp amount, lvl = (sqrt(1+8*exp/step)-1)/2

local Aptitude = class("Aptitude", vRP.Extension)

-- SUBCLASS

Aptitude.User = class("User")

-- return user aptitudes table
function Aptitude.User:getAptitudes()
  return self.cdata.aptitudes
end

-- vary experience of an aptitude
function Aptitude.User:varyExp(group, aptitude, amount)
  local Aptitude = vRP.EXT.Aptitude
  local apt = Aptitude:getAptitude(group, aptitude)

  if apt then
    local aptitudes = self:getAptitudes()

    -- apply variation
    local exp = aptitudes[group][aptitude]
    local level = math.floor(Aptitude:expToLevel(exp)) -- save level before variation

    --- vary
    exp = exp+amount
    --- clamp
    if exp < 0 then exp = 0 
    elseif apt[3] >= 0 and exp > apt[3] then exp = apt[3] end

    aptitudes[group][aptitude] = exp

    -- info notify
    local group_title = Aptitude:getGroupTitle(group)
    local aptitude_title = apt[1]

    --- exp
    if amount < 0 then
      vRP.EXT.Base.remote._notify(self.source,lang.aptitude.lose_exp({group_title,aptitude_title,-1*amount}))
    elseif amount > 0 then
      vRP.EXT.Base.remote._notify(self.source,lang.aptitude.earn_exp({group_title,aptitude_title,amount}))
    end
    --- level up/down
    local new_level = math.floor(Aptitude:expToLevel(exp))
    local diff = new_level-level
    if diff < 0 then
      vRP.EXT.Base.remote._notify(self.source,lang.aptitude.level_down({group_title,aptitude_title,new_level}))
    elseif diff > 0 then
      vRP.EXT.Base.remote._notify(self.source,lang.aptitude.level_up({group_title,aptitude_title,new_level}))
    end
  end
end

-- level up an aptitude
function Aptitude.User:levelUp(group, aptitude)
  local Aptitude = vRP.EXT.Aptitude

  local exp = self:getExp(group,aptitude)
  local next_level = math.floor(Aptitude:expToLevel(exp))+1
  local next_exp = Aptitude:levelToExp(next_level)
  local add_exp = next_exp-exp
  self:varyExp(group, aptitude, add_exp)
end

-- level down an aptitude
function Aptitude.User:levelDown(group, aptitude)
  local Aptitude = vRP.EXT.Aptitude

  local exp = self:getExp(group,aptitude)
  local prev_level = math.floor(Aptitude:expToLevel(exp))-1
  local prev_exp = Aptitude:levelToExp(prev_level)
  local add_exp = prev_exp-exp
  self:varyExp(group, aptitude, add_exp)
end

function Aptitude.User:getExp(group, aptitude)
  local aptitudes = self:getAptitudes()

  local vgroup = aptitudes[group]
  if vgroup then
    return vgroup[aptitude]
  end
end

-- set aptitude experience
function Aptitude.User:setExp(group, aptitude, amount)
  local exp = self:getExp(group, aptitude)
  self:varyExp(group, aptitude, amount-exp)
end

-- PRIVATE METHODS

-- menu: aptitudes
local function menu_aptitudes(self)
  vRP.EXT.GUI:registerMenuBuilder("aptitudes", function(menu)
    local user = menu.user
    menu.title = lang.aptitude.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    local aptitudes = user:getAptitudes()
    for k,v in pairs(aptitudes) do -- each group
      local content = ""

      for l,w in pairs(v) do -- each aptitude
        local def = self:getAptitude(k,l)
        if def then
          -- display aptitude
          local exp = aptitudes[k][l]
          local flvl = self:expToLevel(exp)
          local lvl = math.floor(flvl)
          local percent = math.floor((flvl-lvl)*100)
          content = content.."<div style=\"width: 500px; height: 25px; margin-bottom: 3px;\" class=\"dprogressbar\" data-value=\""..(percent/100).."\" data-color=\"rgba(0,125,255,0.7)\" data-bgcolor=\"rgba(0,125,255,0.3)\">"..lang.aptitude.display.aptitude({def[1], exp, lvl, percent}).."</div>"
        end
      end

      menu:addOption(lang.aptitude.display.group({self:getGroupTitle(k)}), nil, content)
    end
  end)
end

-- METHODS

function Aptitude:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/aptitudes") 
  self.exp_step = 5

  self.groups = {} -- aptitudes groups

  -- load config aptitudes
  for k,v in pairs(self.cfg.gaptitudes) do
    self:defineGroup(k,v._title or "")
    for l,w in pairs(v) do
      if l ~= "_title" then
        self:defineAptitude(k,l,w[1],w[2],w[3])
      end
    end
  end

  -- special aptitude permission
  local function fperm_aptitude(user, params)
    if #params == 4 then -- decompose group.aptitude.operator
      local group = params[2]
      local aptitude = params[3]
      local op = params[4]

      local alvl = math.floor(self:expToLevel(user:getExp(group,aptitude)))

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
  end

  vRP.EXT.Group:registerPermissionFunction("aptitude", fperm_aptitude)

  -- menu

  menu_aptitudes(self)

  local function m_aptitude(menu)
    menu.user:openMenu("aptitudes")
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.aptitude.title(), m_aptitude, lang.aptitude.description())
  end)

  -- transformer processor

  vRP.EXT.Transformer:registerProcessor("aptitudes", function(user, reagents, products) -- on display
    local r_info, p_info = "", ""

    if products then
      for apt,exp in pairs(products) do
        local parts = splitString(apt,".")
        if #parts == 2 then
          local def = self:getAptitude(parts[1],parts[2])
          if def then
            p_info = p_info..lang.aptitude.transformer_recipe({self:getGroupTitle(parts[1]), def[1], exp})
          end
        end
      end
    end

    return r_info, p_info
  end, function(user, reagents, products) -- on check
    return true
  end, function(user, reagents, products) -- on process
    if products then
      -- give exp
      for apt,amount in pairs(products) do
        local parts = splitString(apt,".")
        if #parts == 2 then
          user:varyExp(parts[1],parts[2],amount)
        end
      end
    end
  end)
end

-- define aptitude group
function Aptitude:defineGroup(group, title)
  self.groups[group] = {_title = title}
end

-- define aptitude
-- max_exp: -1 => infinite
function Aptitude:defineAptitude(group, aptitude, title, init_exp, max_exp)
  local vgroup = self.groups[group]
  if vgroup then
    vgroup[aptitude] = {title,init_exp,max_exp}
  end
end

-- get aptitude definition
function Aptitude:getAptitude(group, aptitude)
  local vgroup = self.groups[group]
  if vgroup then
    return vgroup[aptitude]
  end
end

-- get aptitude group title
-- return string
function Aptitude:getGroupTitle(group)
  local vgroup = self.groups[group]
  if vgroup then
    return vgroup._title
  else
    return ""
  end
end

-- convert experience to level
-- return float
function Aptitude:expToLevel(exp)
  return (math.sqrt(1+8*exp/self.exp_step)-1)/2
end

-- convert level to experience
-- return integer
function Aptitude:levelToExp(lvl)
  return math.floor((self.exp_step*lvl*(lvl+1))/2)
end

-- EVENT
Aptitude.event = {}

function Aptitude.event:characterLoad(user)
  -- init aptitudes

  if not user.cdata.aptitudes then
    user.cdata.aptitudes = {}
  end

  local aptitudes = user.cdata.aptitudes

  for gid,group in pairs(self.groups) do
    if not aptitudes[gid] then -- each group
      aptitudes[gid] = {}
    end

    local gaptitudes = aptitudes[gid]

    for id,def in pairs(group) do -- each aptitude
      if id ~= "_title" and not gaptitudes[id] then
        gaptitudes[id] = def[2] -- init exp
      end
    end
  end
end

function Aptitude.event:playerDeath(user)
  if self.cfg.lose_aptitudes_on_death then
    -- re-init aptitudes
    user.cdata.aptitudes = {}

    local aptitudes = user.cdata.aptitudes

    for gid,group in pairs(self.groups) do
      if not aptitudes[gid] then -- each group
        aptitudes[gid] = {}
      end

      local gaptitudes = aptitudes[gid]

      for id,def in pairs(group) do -- each aptitude
        if id ~= "_title" and not gaptitudes[id] then
          gaptitudes[id] = def[2] -- init exp
        end
      end
    end
  end
end

vRP:registerExtension(Aptitude)
