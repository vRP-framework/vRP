
-- this module define some police tools and functions
local lang = vRP.lang
local cfg = require("resources/vrp/cfg/police")

-- police cloakroom

local menu_cloak = {name=lang.police.cloakroom.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

menu_cloak[lang.police.cloakroom.uniform.title()] = {function(player, choice)
  vRPclient.setCustomization(player,{cfg.uniform_customization})
end,lang.police.cloakroom.uniform.description()}

local function cloakroom_enter(source,area)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil and vRP.hasPermission(user_id,"police.cloakroom") then
    vRP.openMenu(source,menu_cloak)
  end
end

local function cloakroom_leave(source,area)
  vRP.closeMenu(source)
end

-- police PC

local menu_pc = {name=lang.police.pc.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

-- search identity by registration
local function ch_searchreg(player,choice)
  vRP.prompt(player,lang.police.pc.searchreg.prompt(),"",function(player, reg)
    local user_id = vRP.getUserByRegistration(reg)
    if user_id ~= nil then
      local identity = vRP.getUserIdentity(user_id)
      if identity then
        -- display identity and business
        local name = identity.name
        local firstname = identity.firstname
        local age = identity.age
        local phone = identity.phone
        local registration = identity.registration
        local bname = ""
        local bcapital = 0

        local business = vRP.getUserBusiness(user_id)
        if business then 
          bname = business.name
          bcapital = business.capital
        end

        local content = lang.police.identity.info({name,firstname,age,registration,phone,bname,bcapital})
        vRPclient.setDiv(player,{"police_identity",".div_police_identity{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",content})
      else
        vRPclient.notify(player,{lang.common.not_found()})
      end
    else
      vRPclient.notify(player,{lang.common.not_found()})
    end
  end)
end

-- close business of an arrested owner
local function ch_closebusiness(player,choice)
  vRPclient.getNearestPlayer(player,{5},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      local identity = vRP.getUserIdentity(nuser_id)
      local business = vRP.getUserBusiness(nuser_id)
      if identity and business then
        vRP.request(player,lang.police.pc.closebusiness.request({identity.name,identity.firstname,business.name}),15,function(player,ok)
          if ok then
            vRP.closeBusiness(nuser_id)
            vRPclient.notify(player,{lang.police.pc.closebusiness.closed()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end

-- track vehicle
local function ch_trackveh(player,choice)
  vRP.prompt(player,lang.police.pc.trackveh.prompt_reg(),"",function(player, reg) -- ask reg
    local user_id = vRP.getUserByRegistration(reg)
    if user_id ~= nil then
      vRP.prompt(player,lang.police.pc.trackveh.prompt_note(),"",function(player, note) -- ask note
        -- begin veh tracking
        vRPclient.notify(player,{lang.police.pc.trackveh.tracking()})
        local seconds = math.random(cfg.trackveh.min_time,cfg.trackveh.max_time)
        SetTimeout(seconds*1000,function()
          local tplayer = vRP.getUserSource(user_id)
          if tplayer ~= nil then
            vRPclient.getOwnedVehiclePosition(tplayer,{},function(ok,x,y,z)
              if ok then -- track success
                vRP.sendServiceAlert(cfg.trackveh.service,x,y,z,lang.police.pc.trackveh.tracked({reg,note}))
              else
                vRPclient.notify(player,{lang.police.pc.trackveh.track_failed({reg,note})}) -- failed
              end
            end)
          else
            vRPclient.notify(player,{lang.police.pc.trackveh.track_failed({reg,note})}) -- failed
          end
        end)
      end)
    else
      vRPclient.notify(player,{lang.common.not_found()})
    end
  end)
end

menu_pc[lang.police.pc.searchreg.title()] = {ch_searchreg,lang.police.pc.searchreg.description()}
menu_pc[lang.police.pc.trackveh.title()] = {ch_trackveh,lang.police.pc.trackveh.description()}
menu_pc[lang.police.pc.closebusiness.title()] = {ch_closebusiness,lang.police.pc.closebusiness.description()}

menu_pc.onclose = function(player) -- close pc gui
  vRPclient.removeDiv(player,{"police_identity"})
end

local function pc_enter(source,area)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil and vRP.hasPermission(user_id,"police.pc") then
    vRP.openMenu(source,menu_pc)
  end
end

local function pc_leave(source,area)
  vRP.closeMenu(source)
end

-- main menu choices

---- handcuff
local choice_handcuff = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRPclient.toggleHandcuff(nplayer,{})
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end,lang.police.menu.handcuff.description()}

---- putinveh
local choice_putinveh = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRPclient.putInNearestVehicleAsPassenger(nplayer,{5})
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end,lang.police.menu.putinveh.description()}

---- askid
local choice_askid = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRP.notify(player,{lang.police.menu.askid.asked()})
      vRP.request(nplayer,lang.police.menu.askid.request(),15,function(nplayer,ok)
        if ok then
          local identity = vRP.getUserIdentity(nuser_id)
          if identity then
            -- display identity and business
            local name = identity.name
            local firstname = identity.firstname
            local age = identity.age
            local phone = identity.phone
            local registration = identity.registration
            local bname = ""
            local bcapital = 0

            local business = vRP.getUserBusiness(nuser_id)
            if business then 
              bname = business.name
              bcapital = business.capital
            end

            local content = lang.police.identity.info({name,firstname,age,registration,phone,bname,bcapital})
            vRPclient.setDiv(player,{"police_identity",".div_police_identity{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",content})
            -- request to hide div
            vRP.request(player, lang.police.menu.askid.request_hide(), 1000, function(player,ok)
              vRPclient.removeDiv(player,{"police_identity"})
            end)
          end
        else
          vRPclient.notify(player,{lang.common.request_refused()})
        end
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end, lang.police.menu.askid.description()}

---- police check
local choice_check = {function(player,choice)
  vRPclient.getNearestPlayer(player,{5},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRP.notify(player,{lang.police.menu.check.checked()})
      vRPclient.getWeapons(nplayer,{},function(weapons)
        -- prepare display data (money, items, weapons)
        local money = vRP.getMoney(nuser_id)
        local items = ""
        local data = vRP.getUserDataTable(nuser_id)
        if data and data.inventory then
          for k,v in pairs(data.inventory) do 
            local item = vRP.items[k]
            if item then
              items = items.."<br />"..item.name.." ("..v.amount..")"
            end
          end
        end

        local weapons_info = ""
        for k,v in pairs(weapons) do
          weapons_info = weapons_info.."<br />"..k.." ("..v.ammo..")"
        end

        vRPclient.setDiv(player,{"police_check",".div_police_check{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",lang.police.menu.check.info({money,items,weapons_info})})
        -- request to hide div
        vRP.request(player, lang.police.menu.check.request_hide(), 1000, function(player,ok)
          vRPclient.removeDiv(player,{"police_check"})
        end)
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end, lang.police.menu.check.description()}

-- add choices to the menu
AddEventHandler("vRP:buildMainMenu",function(player) 
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local choices = {}
    if vRP.hasPermission(user_id,"police.handcuff") then
      choices[lang.police.menu.handcuff.title()] = choice_handcuff
    end

    if vRP.hasPermission(user_id,"police.putinveh") then
      choices[lang.police.menu.putinveh.title()] = choice_putinveh
    end

    if vRP.hasPermission(user_id,"police.askid") then
      choices[lang.police.menu.askid.title()] = choice_askid
    end

    if vRP.hasPermission(user_id,"police.check") then
      choices[lang.police.menu.check.title()] = choice_check
    end

    vRP.buildMainMenu(player,choices)
  end
end)

local function build_client_points(source)
  -- cloakroom
  local x,y,z = table.unpack(cfg.cloakroom)
  vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,125,255,125,150})
  vRP.setArea(source,"vRP:police:cloakroom",x,y,z,1,1.5,cloakroom_enter,cloakroom_leave)

  -- PC
  x,y,z = table.unpack(cfg.pc)
  vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,125,255,125,150})
  vRP.setArea(source,"vRP:police:pc",x,y,z,1,1.5,pc_enter,pc_leave)
end

-- build police points
AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil and vRP.isFirstSpawn(user_id) then
    build_client_points(source)
  end
end)
