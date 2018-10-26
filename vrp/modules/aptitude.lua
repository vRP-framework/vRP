
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

function Aptitude.User:levelUp(group, aptitude)
  local Aptitude = vRP.EXT.Aptitude

  local exp = self:getExp(group,aptitude)
  local next_level = math.floor(Aptitude:expToLevel(exp))+1
  local next_exp = Aptitude:levelToExp(next_level)
  local add_exp = next_exp-exp
  self:varyExp(group, aptitude, add_exp)
end

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

function Aptitude.User:setExp(group, aptitude, amount)
  local exp = self:getExp(group, aptitude)
  self:varyExp(group, aptitude, amount-exp)
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

  -- menu

  local m_aptitude_css = [[
.div_user_aptitudes{
margin: auto;
padding: 8px;
width: 500px;
margin-top: 80px;
background: black;
color: white;
font-weight: bold;
}

.div_user_aptitudes .dprogressbar{
width: 100%;
height: 20px;
}
  ]]

  local function m_aptitude_close(menu)
    vRP.EXT.GUI.remote._removeDiv(menu.user.source, "user_aptitudes")
    menu.aptitudes_opened = nil
  end

  local function m_aptitude(menu)
    local user = menu.user

    -- display aptitudes
    if menu.aptitudes_opened then -- hide
      m_aptitude_close(menu)
    else -- show
      local content = ""
      local aptitudes = user:getAptitudes()
      for k,v in pairs(aptitudes) do
        -- display group
        content = content..lang.aptitude.display.group({self:getGroupTitle(k)}).."<br />"
        for l,w in pairs(v) do
          local def = self:getAptitude(k,l)
          if def then
            -- display aptitude
            local exp = aptitudes[k][l]
            local flvl = self:expToLevel(exp)
            local lvl = math.floor(flvl)
            local percent = math.floor((flvl-lvl)*100)
            content = content.."<div class=\"dprogressbar\" data-value=\""..(percent/100).."\" data-color=\"rgba(0,125,255,0.7)\" data-bgcolor=\"rgba(0,125,255,0.3)\">"..lang.aptitude.display.aptitude({def[1], exp, lvl, percent}).."</div>"
          end
        end
      end

      vRP.EXT.GUI.remote._setDiv(user.source,"user_aptitudes",m_aptitude_css, content)
      menu.aptitudes_opened = true
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.aptitude.title(), m_aptitude, lang.aptitude.description())
    menu:listen("close", m_aptitude_close)
  end)
end

function Aptitude:defineGroup(group, title)
  self.groups[group] = {_title = title}
end

-- max_exp: -1 => infinite
function Aptitude:defineAptitude(group, aptitude, title, init_exp, max_exp)
  local vgroup = self.groups[group]
  if vgroup then
    vgroup[aptitude] = {title,init_exp,max_exp}
  end
end

function Aptitude:getAptitude(group, aptitude)
  local vgroup = self.groups[group]
  if vgroup then
    return vgroup[aptitude]
  end
end

function Aptitude:getGroupTitle(group)
  local vgroup = self.groups[group]
  if vgroup then
    return vgroup._title
  else
    return ""
  end
end

-- return float
function Aptitude:expToLevel(exp)
  return (math.sqrt(1+8*exp/self.exp_step)-1)/2
end

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
