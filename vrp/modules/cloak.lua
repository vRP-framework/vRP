-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.cloak then return end

local lang = vRP.lang

-- cloak system (uniform, disguise, etc)
local Cloak = class("Cloak", vRP.Extension)

-- SUBCLASS
Cloak.User = class("User")

-- cloak: skin customization
function Cloak.User:setCloak(cloak)
  if not self.cdata.pre_cloak then -- not cloaked
    self.cdata.pre_cloak = vRP.EXT.PlayerState.remote.getCustomization(self.source) -- save
  else -- already cloaked, revert to pre_cloak first
    vRP.EXT.PlayerState.remote.setCustomization(self.source, self.cdata.pre_cloak)
  end

  vRP.EXT.PlayerState.remote._setCustomization(self.source, cloak) -- set
end

function Cloak.User:removeCloak()
  if self.cdata.pre_cloak then
    vRP.EXT.PlayerState.remote._setCustomization(self.source, self.cdata.pre_cloak) -- restore
    self.cdata.pre_cloak = nil
  end
end

function Cloak.User:hasCloak()
  return self.cdata.pre_cloak ~= nil
end

-- PRIVATE METHODS

-- menu: cloakroom
local function menu_cloakroom(self)
  local function m_cloak(menu, kcloak)
    local user = menu.user
    local cloak = menu.data.cloaks[kcloak]

    local cfg = menu.data.cloaks._config
    if cfg and cfg.not_uniform then
      vRP.EXT.PlayerState.remote._setCustomization(user.source, cloak)
    else
      user:setCloak(cloak)
    end
  end

  local function m_remove(menu)
    menu.user:removeCloak()
  end

  vRP.EXT.GUI:registerMenuBuilder("cloakroom", function(menu)
    menu.title = lang.cloakroom.title({menu.data.type})
    menu.css.header_color="rgba(0,125,255,0.75)"

    -- add cloaks
    for k,v in pairs(menu.data.cloaks) do
      if k ~= "_config" then
        menu:addOption(k, m_cloak, nil, k)
      end
    end
    
    -- remove cloak option
    local cfg = menu.data.cloaks._config
    if not cfg or not cfg.not_uniform then
      menu:addOption(lang.cloakroom.undress.title(), m_remove)
    end
  end)
end

-- METHODS

function Cloak:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/cloakrooms")
  self:log(#self.cfg.cloakrooms.." cloakrooms")

  menu_cloakroom(self)
end

-- EVENT
Cloak.event = {}

function Cloak.event:playerSpawn(user, first_spawn)
  if first_spawn then
    for k,v in pairs(self.cfg.cloakrooms) do
      local gtype,x,y,z = table.unpack(v)
      local cloakroom = self.cfg.cloakroom_types[gtype]
      if cloakroom then
        local gcfg = cloakroom._config or {}

        local menu
        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            if gcfg.not_uniform then -- not a uniform cloakroom
              if user:hasCloak() then
                vRP.EXT.Base.remote._notify(user.source,lang.common.wearing_uniform())
              end
            end

            menu = user:openMenu("cloakroom", {type = gtype, cloaks = cloakroom})
          end
        end

        local function leave(user)
          if menu then
            user:closeMenu(menu)
          end
        end

        local ment = clone(gcfg.map_entity)
        ment[2].title = lang.cloakroom.title({gtype})
        ment[2].pos = {x,y,z-1}
        vRP.EXT.Map.remote._addEntity(user.source,ment[1], ment[2])

        user:setArea("vRP:cfg:cloakroom:"..k,x,y,z,1,1.5,enter,leave)
      end
    end
  end
end

vRP:registerExtension(Cloak)
