-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.atm then return end

local lang = vRP.lang

-- a basic ATM implementation

local ATM = class("ATM", vRP.Extension)

-- METHODS

function ATM:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/atms")

  local function play_atm_enter(user)
    vRP.EXT.Base.remote._playAnim(user.source,false,{{"amb@prop_human_atm@male@enter","enter"},{"amb@prop_human_atm@male@idle_a","idle_a"}},false)
  end

  local function play_atm_exit(user)
    vRP.EXT.Base.remote._playAnim(user.source,false,{{"amb@prop_human_atm@male@exit","exit"}},false)
  end

  local function atm_choice_deposit(menu)
    local user = menu.user

    play_atm_enter(user) --anim
    local v = parseInt(user:prompt(lang.atm.deposit.prompt(),""))
    play_atm_exit(user)

    if v > 0 then
      if user:tryDeposit(v) then
        vRP.EXT.Base.remote._notify(user.source,lang.atm.deposit.deposited({v}))
        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  local function atm_choice_withdraw(menu)
    local user = menu.user

    play_atm_enter(user)
    local v = parseInt(user:prompt(lang.atm.withdraw.prompt(),""))
    play_atm_exit(user) --anim

    if v > 0 then
      if user:tryWithdraw(v) then
        vRP.EXT.Base.remote._notify(user.source,lang.atm.withdraw.withdrawn({v}))
        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source,lang.atm.withdraw.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end


  vRP.EXT.GUI:registerMenuBuilder("ATM", function(menu)
    menu.title = lang.atm.title()
    menu.css.header_color="rgba(0,255,125,0.75)"

    menu:addOption(lang.atm.info.title(), nil, lang.atm.info.bank({menu.user:getBank()}))
    menu:addOption(lang.atm.deposit.title(),atm_choice_deposit,lang.atm.deposit.description())
    menu:addOption(lang.atm.withdraw.title(),atm_choice_withdraw,lang.atm.withdraw.description())
  end)
end

-- EVENT
ATM.event = {}

function ATM.event:playerSpawn(user, first_spawn)
  -- build client ATMs
  if first_spawn then 
    local menu
    local function enter(user)
      menu = user:openMenu("ATM")
    end

    local function leave(user)
      user:closeMenu(menu)
    end

    for k,v in pairs(self.cfg.atms) do
      local x,y,z = table.unpack(v)

      local ment = clone(self.cfg.atm_map_entity)
      ment[2].title = lang.atm.title()
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote._addEntity(user.source,ment[1],ment[2])

      user:setArea("vRP:atm:"..k,x,y,z,1,1.5,enter,leave)
    end
  end
end

vRP:registerExtension(ATM)
