local htmlEntities = module("vrp", "lib/htmlEntities")
local lang = vRP.lang

-- a basic gunshop implementation
local GunShop = class("GunShop", vRP.Extension)

-- PRIVATE METHODS

local function menu_gunshop(self)
  local function m_buy(menu, id)
    local user = menu.user

    local weapon = menu.data.weapons[id]
    local price = weapon[2]
    local price_ammo = weapon[3]

    -- get player weapons to not rebuy the body
    local weapons = vRP.EXT.PlayerState.remote.getWeapons(user.source)

    -- prompt amount
    local amount = parseInt(user:prompt(lang.gunshop.prompt_ammo({weapon[1]}),""))
    if amount >= 0 then
      local total = math.ceil(price_ammo*amount)

      if not weapons[string.upper(id)] then -- add body price if not already owned
        total = total+price
      end

      -- payment
      if user:tryPayment(total) then
        vRP.EXT.PlayerState.remote._giveWeapons(user.source,{
          [id] = {ammo=amount}
        })

        vRP.EXT.Base.remote._notify(user.source,lang.money.paid({total}))
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("gunshop", function(menu)
    menu.title = lang.gunshop.title({htmlEntities.encode(menu.data.type)})
    menu.css.header_color = "rgba(255,0,0,0.75)"

    -- add weapons
    for id,weapon in pairs(menu.data.weapons) do
      if id ~= "_config" then -- ignore config property
        menu:addOption(weapon[1], m_buy, lang.gunshop.info({weapon[2],weapon[3],weapon[4]}), id)
      end
    end
  end)
end

-- METHODS

function GunShop:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/gunshops") 

  self:log(#self.cfg.gunshops.." gunshops")

  menu_gunshop(self)
end

-- EVENT
GunShop.event = {}

function GunShop.event:playerSpawn(user, first_spawn)
  -- load gunshops

  if first_spawn then
    for k,v in pairs(self.cfg.gunshops) do
      local gtype,x,y,z = table.unpack(v)
      local group = self.cfg.gunshop_types[gtype]

      if group then
        local gcfg = group._config

        local menu
        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            menu = user:openMenu("gunshop", {type = gtype, weapons = group}) 
          end
        end

        local function leave(user)
          user:closeMenu(menu)
        end

        vRP.EXT.Map.remote._addBlip(user.source,x,y,z,gcfg.blipid,gcfg.blipcolor,lang.gunshop.title({gtype}))
        vRP.EXT.Map.remote._addMarker(user.source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

        user:setArea("vRP:gunshop"..k,x,y,z,1,1.5,enter,leave)
      end
    end
  end
end

vRP:registerExtension(GunShop)
