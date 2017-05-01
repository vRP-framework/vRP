-- a basic gunshop implementation

local cfg = require("resources/vRP/cfg/gunshops")
local weapons = cfg.weapons
local gunshops = cfg.gunshops

local gunshop_menu = {
  name="Gunshop",
  css={top = "75px", header_color="rgba(255,0,0,0.75)"}
}

-- build gunshop items
local function build_gunshop_menu()
  local kitems = {}

  -- item choice
  local gunshop_choice = function(player,choice)
    local weapon = kitems[choice][1]
    local price = kitems[choice][2]
    local price_ammo = kitems[choice][3]

    if weapon then
      -- get player weapons to not rebuy the body
      vRPclient.getWeapons(player,{},function(weapons)
        -- prompt amount
        vRP.prompt(player,"Amount of ammo to buy for the "..choice.." :","",function(player,amount)
          local amount = tonumber(amount)
          if amount >= 0 then
            local user_id = vRP.getUserId(player)
            local total = math.ceil(cast(double,price_ammo)*cast(double,amount))
            
            if weapons[string.upper(weapon)] == nil then -- add body price if not already owned
              total = total+price
            end

            -- payment
            if user_id ~= nil and vRP.tryPayment(user_id,total) then
              vRPclient.giveWeapons(player,{{
                [weapon] = {ammo=amount}
              }})

              vRPclient.notify(player,{"Paid total of "..total.." $."})
            else
              vRPclient.notify(player,{"Not enough money."})
            end
          else
            vRPclient.notify(player,{"Invalid amount."})
          end
        end)
      end)
    end
  end

  -- add item options
  for k,v in pairs(weapons) do
    kitems[v[1]] = {k,math.max(v[2],0),math.max(v[3],0)} -- idname/price/price_ammo
    gunshop_menu[v[1]] = {gunshop_choice,"body &nbsp;"..v[2].." $<br />ammo &nbsp;"..v[3].." $/u<br /><br />"..v[4]} -- add description
  end
end

local function gunshop_enter()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.openMenu(source,gunshop_menu) 
  end
end

local function gunshop_leave()
  vRP.closeMenu(source)
end

local first_build = true

local function build_client_gunshops(source)
  -- prebuild the gunshop menu once
  if first_build then
    build_gunshop_menu()
    first_build = false
  end

  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(gunshops) do
      local x,y,z = table.unpack(v)

      vRPclient.addBlip(source,{x,y,z,313,1,"Gunshop"})
      vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

      vRP.setArea(source,"vRP:gunshop"..k,x,y,z,1,1.5,gunshop_enter,gunshop_leave)
    end
  end
end

AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil and vRP.isFirstSpawn(user_id) then
    build_client_gunshops(source)
  end
end)
