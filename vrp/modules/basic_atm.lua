
-- a basic ATM implementation

local cfg = require("resources/vRP/cfg/atms")
local atms = cfg.atms

local function atm_choice_deposit()
  vRP.prompt(source,"Enter amount of money for deposit:","",function(v)
    v = tonumber(v)

    if v > 0 then
      local user_id = vRP.getUserId(source)
      if user_id ~= nil then
        if vRP.tryDeposit(user_id,v) then
          vRPclient.notify(source,{v.." $ deposited."})
        else
          vRPclient.notify(source,{"You don't have enough money."})
        end
      end
    else
      vRPclient.notify(source,{"Invalid value."})
    end
  end)
end

local function atm_choice_withdraw()
  print("choose withdraw")
  vRP.prompt(source,"Enter amount of money to withdraw:","",function(v)
    v = tonumber(v)

    if v > 0 then
      local user_id = vRP.getUserId(source)
      if user_id ~= nil then
        if vRP.tryWithdraw(user_id,v) then
          vRPclient.notify(source,{v.." $ withdrawn."})
        else
          vRPclient.notify(source,{"You don't have enough money in bank."})
        end
      end
    else
      vRPclient.notify(source,{"Invalid value."})
    end
  end)
end

local atm_menu = {
  name="ATM",
  css={top = "75px", header_color="rgba(0,255,125,0.75)"}
}

atm_menu["Deposit"] = {atm_choice_deposit,"wallet to bank"}
atm_menu["Withdraw"] = {atm_choice_withdraw,"bank to wallet"}

local function atm_enter()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    atm_menu["Info"] = {function()end,"bank: "..vRP.getBankMoney(user_id).." $"}
    vRP.openMenu(source,atm_menu) 
  end
end

local function atm_leave()
  vRP.closeMenu(source)
end

local function build_client_atms(source)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(atms) do
      local x,y,z = table.unpack(v)

      vRPclient.addBlip(source,{x,y,z,108,4,"ATM"})
      vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

      vRP.setArea(source,"vRP:atm"..k,x,y,z,0.7,1.5,atm_enter,atm_leave)
    end
  end
end

AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil and vRP.isFirstSpawn(user_id) then
    build_client_atms(source)
  end
end)
