local htmlEntities = module("vrp", "lib/htmlEntities")
local lang = vRP.lang

-- a basic item shop implementation

local Shop = class("Shop", vRP.Extension)

-- PRIVATE METHODS

local function menu_shop(self)
  local function m_buy(menu, fullid)
    local user = menu.user
    local items = menu.data.items

    local citem = vRP.EXT.Inventory:computeItem(fullid)
    local price = items[fullid]

    if citem then
      local amount = parseInt(user:prompt(lang.shop.prompt({htmlEntities.encode(citem.name)}),""))
      if amount > 0 then
        -- payment
        if user:tryPayment(amount*price,true) then
          if user:tryGiveItem(fullid,amount,true) then
            user:tryPayment(amount*price)
            user:tryGiveItem(fullid,amount)
            vRP.EXT.Base.remote._notify(user.source,lang.money.paid({amount*price}))
          else
            vRP.EXT.Base.remote._notify(user.source,lang.inventory.full())
          end
        else
          vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("shop", function(menu)
    menu.title = lang.shop.title({htmlEntities.encode(menu.data.type)})
    menu.css.header_color = "rgba(0,255,125,0.75)"

    -- add items
    for fullid,price in pairs(menu.data.items) do
      if fullid ~= "_config" then
        local citem = vRP.EXT.Inventory:computeItem(fullid)
        if citem then
          menu:addOption(htmlEntities.encode(citem.name), m_buy, lang.shop.info({price,citem.description}), fullid)
        end
      end
    end
  end)
end

-- METHODS

function Shop:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/shops")
  self:log(#self.cfg.shops.." shops")

  menu_shop(self)
end

-- EVENT
Shop.event = {}

function Shop.event:playerSpawn(user, first_spawn)
  if first_spawn then
    for k,v in pairs(self.cfg.shops) do
      local gtype,x,y,z = table.unpack(v)
      local group = self.cfg.shop_types[gtype]

      if group then
        local gcfg = group._config

        local menu
        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            user:openMenu("shop", {type = gtype, items = group}) 
          end
        end

        local function leave(user)
          user:closeMenu(menu)
        end

        vRP.EXT.Map.remote._addBlip(user.source,x,y,z,gcfg.blipid,gcfg.blipcolor,lang.shop.title({gtype}))
        vRP.EXT.Map.remote._addMarker(user.source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

        user:setArea("vRP:shop:"..k,x,y,z,1,1.5,enter,leave)
      end
    end
  end
end

vRP:registerExtension(Shop)
