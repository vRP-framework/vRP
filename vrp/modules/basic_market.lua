-- a basic market implementation

local cfg = require("resources/vRP/cfg/markets")
local mitems = cfg.items
local markets = cfg.markets

local market_menu = {
  name="Market",
  css={top = "75px", header_color="rgba(0,255,125,0.75)"}
}

-- build market items
local function build_market_menu()
  local kitems = {}

  -- item choice
  local market_choice = function(player,choice)
    local idname = kitems[choice][1]
    local item = vRP.items[idname]
    local price = kitems[choice][2]

    if item then
      -- prompt amount
      vRP.prompt(player,"Amount of "..item.name.." to buy:","",function(player,amount)
        local amount = tonumber(amount)
        if amount > 0 then
          local user_id = vRP.getUserId(player)
          if user_id ~= nil and vRP.tryPayment(user_id,amount*price) then
            vRP.giveInventoryItem(user_id,idname,amount)
            vRPclient.notify(player,{"Paid "..(amount*price).." $ for "..amount.." "..item.name.."."})
          else
            vRPclient.notify(player,{"Not enough money."})
          end
        else
          vRPclient.notify(player,{"Invalid amount."})
        end
      end)
    end
  end

  -- add item options
  for k,v in pairs(mitems) do
    local item = vRP.items[k]
    if item then
      kitems[item.name] = {k,math.max(v,0)} -- idname/price
      market_menu[item.name] = {market_choice,v.." $<br /><br />"..item.description}
    end
  end
end

local function market_enter()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.openMenu(source,market_menu) 
  end
end

local function market_leave()
  vRP.closeMenu(source)
end

local first_build = true

local function build_client_markets(source)
  -- prebuild the market menu once
  if first_build then
    build_market_menu()
    first_build = false
  end

  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(markets) do
      local x,y,z = table.unpack(v)

      vRPclient.addBlip(source,{x,y,z,52,2,"Market"})
      vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

      vRP.setArea(source,"vRP:market"..k,x,y,z,1,1.5,market_enter,market_leave)
    end
  end
end

AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil and vRP.isFirstSpawn(user_id) then
    build_client_markets(source)
  end
end)
