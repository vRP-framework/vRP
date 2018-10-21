local htmlEntities = module("vrp", "lib/htmlEntities")
local lang = vRP.lang

-- a basic market implementation

local Market = class("Market", vRP.Extension)

-- PRIVATE METHODS

local function menu_market(self)
  local function m_buy(menu, fullid)
    local user = menu.user
    local items = menu.data.items

    local citem = vRP.EXT.Inventory:computeItem(fullid)
    local price = items[fullid]

    if citem then
      local amount = parseInt(user:prompt(lang.market.prompt({htmlEntities.encode(citem.name)}),""))
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

  vRP.EXT.GUI:registerMenuBuilder("market", function(menu)
    menu.title = lang.market.title({htmlEntities.encode(menu.data.type)})
    menu.css.header_color = "rgba(0,255,125,0.75)"

    -- add items
    for fullid,price in pairs(menu.data.items) do
      local citem = vRP.EXT.Inventory:computeItem(fullid)
      if citem then
        menu:addOption(htmlEntities.encode(citem.name), m_buy, lang.market.info({price,citem.description}), fullid)
      end
    end
  end)
end

-- METHODS

function Market:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/markets")
  self:log(#self.cfg.markets.." markets")

  menu_market(self)
end

-- EVENT
Market.event = {}

function Market.event:playerSpawn(user, first_spawn)
  if first_spawn then
    for k,v in pairs(self.cfg.markets) do
      local gtype,x,y,z = table.unpack(v)
      local group = self.cfg.market_types[gtype]

      if group then
        local gcfg = group._config

        local menu
        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            user:openMenu("market", {type = gtype, items = group}) 
          end
        end

        local function leave(user)
          user:closeMenu(menu)
        end

        vRP.EXT.Map.remote._addBlip(user.source,x,y,z,gcfg.blipid,gcfg.blipcolor,lang.market.title({gtype}))
        vRP.EXT.Map.remote._addMarker(user.source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

        user:setArea("vRP:market:"..k,x,y,z,1,1.5,enter,leave)
      end
    end
  end
end

vRP:registerExtension(Market)
