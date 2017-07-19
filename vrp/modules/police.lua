
-- this module define some police tools and functions
local lang = vRP.lang
local cfg = module("cfg/police")

-- police records

-- insert a police record for a specific user
--- line: text for one line (can be html)
function vRP.insertPoliceRecord(user_id, line)
  if user_id ~= nil then
    vRP.getUData(user_id, "vRP:police_records", function(data)
      local records = data..line.."<br />"
      vRP.setUData(user_id, "vRP:police_records", records)
    end)
  end
end

-- police PC

local menu_pc = {name=lang.police.pc.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

-- search identity by registration
local function ch_searchreg(player,choice)
  vRP.prompt(player,lang.police.pc.searchreg.prompt(),"",function(player, reg)
    vRP.getUserByRegistration(reg, function(user_id)
      if user_id ~= nil then
        vRP.getUserIdentity(user_id, function(identity)
          if identity then
            -- display identity and business
            local name = identity.name
            local firstname = identity.firstname
            local age = identity.age
            local phone = identity.phone
            local registration = identity.registration
            local bname = ""
            local bcapital = 0
            local home = ""
            local number = ""

            vRP.getUserBusiness(user_id, function(business)
              if business then
                bname = business.name
                bcapital = business.capital
              end

              vRP.getUserAddress(user_id, function(address)
                if address then
                  home = address.home
                  number = address.number
                end

                local content = lang.police.identity.info({name,firstname,age,registration,phone,bname,bcapital,home,number})
                vRPclient.setDiv(player,{"police_pc",".div_police_pc{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",content})
              end)
            end)
          else
            vRPclient.notify(player,{lang.common.not_found()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.not_found()})
      end
    end)
  end)
end

-- show police records by registration
local function ch_show_police_records(player,choice)
  vRP.prompt(player,lang.police.pc.searchreg.prompt(),"",function(player, reg)
    vRP.getUserByRegistration(reg, function(user_id)
      if user_id ~= nil then
        vRP.getUData(user_id, "vRP:police_records", function(content)
          vRPclient.setDiv(player,{"police_pc",".div_police_pc{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",content})
        end)
      else
        vRPclient.notify(player,{lang.common.not_found()})
      end
    end)
  end)
end

-- delete police records by registration
local function ch_delete_police_records(player,choice)
  vRP.prompt(player,lang.police.pc.searchreg.prompt(),"",function(player, reg)
    vRP.getUserByRegistration(reg, function(user_id)
      if user_id ~= nil then
        vRP.setUData(user_id, "vRP:police_records", "")
        vRPclient.notify(player,{lang.police.pc.records.delete.deleted()})
      else
        vRPclient.notify(player,{lang.common.not_found()})
      end
    end)
  end)
end

-- close business of an arrested owner
local function ch_closebusiness(player,choice)
  vRPclient.getNearestPlayer(player,{5},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRP.getUserIdentity(nuser_id, function(identity)
        vRP.getUserBusiness(nuser_id, function(business)
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
        end)
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end

-- track vehicle
local function ch_trackveh(player,choice)
  vRP.prompt(player,lang.police.pc.trackveh.prompt_reg(),"",function(player, reg) -- ask reg
    vRP.getUserByRegistration(reg, function(user_id)
      if user_id ~= nil then
        vRP.prompt(player,lang.police.pc.trackveh.prompt_note(),"",function(player, note) -- ask note
          -- begin veh tracking
          vRPclient.notify(player,{lang.police.pc.trackveh.tracking()})
          local seconds = math.random(cfg.trackveh.min_time,cfg.trackveh.max_time)
          SetTimeout(seconds*1000,function()
            local tplayer = vRP.getUserSource(user_id)
            if tplayer ~= nil then
              vRPclient.getAnyOwnedVehiclePosition(tplayer,{},function(ok,x,y,z)
                if ok then -- track success
                  vRP.sendServiceAlert(nil, cfg.trackveh.service,x,y,z,lang.police.pc.trackveh.tracked({reg,note}))
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
  end)
end

menu_pc[lang.police.pc.searchreg.title()] = {ch_searchreg,lang.police.pc.searchreg.description()}
menu_pc[lang.police.pc.trackveh.title()] = {ch_trackveh,lang.police.pc.trackveh.description()}
menu_pc[lang.police.pc.records.show.title()] = {ch_show_police_records,lang.police.pc.records.show.description()}
menu_pc[lang.police.pc.records.delete.title()] = {ch_delete_police_records, lang.police.pc.records.delete.description()}
menu_pc[lang.police.pc.closebusiness.title()] = {ch_closebusiness,lang.police.pc.closebusiness.description()}

menu_pc.onclose = function(player) -- close pc gui
  vRPclient.removeDiv(player,{"police_pc"})
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
--[[
-- veh at position version
local choice_putinveh = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
        if handcuffed then
          vRPclient.getNearestOwnedVehicle(player, {10}, function(ok,vtype,name) -- get nearest owned vehicle
            if ok then
              vRPclient.getOwnedVehiclePosition(player, {vtype}, function(x,y,z)
                vRPclient.putInVehiclePositionAsPassenger(nplayer,{x,y,z}) -- put player in vehicle
              end)
            else
              vRPclient.notify(player,{lang.vehicle.no_owned_near()})
            end
          end)
        else
          vRPclient.notify(player,{lang.police.not_handcuffed()})
        end
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end,lang.police.menu.putinveh.description()}
--]]

local choice_putinveh = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
        if handcuffed then
          vRPclient.putInNearestVehicleAsPassenger(nplayer, {5})
        else
          vRPclient.notify(player,{lang.police.not_handcuffed()})
        end
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end,lang.police.menu.putinveh.description()}

local choice_getoutveh = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
        if handcuffed then
          vRPclient.ejectVehicle(nplayer, {})
        else
          vRPclient.notify(player,{lang.police.not_handcuffed()})
        end
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end,lang.police.menu.getoutveh.description()}

---- askid
local choice_askid = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRPclient.notify(player,{lang.police.menu.askid.asked()})
      vRP.request(nplayer,lang.police.menu.askid.request(),15,function(nplayer,ok)
        if ok then
          vRP.getUserIdentity(nuser_id, function(identity)
            if identity then
              -- display identity and business
              local name = identity.name
              local firstname = identity.firstname
              local age = identity.age
              local phone = identity.phone
              local registration = identity.registration
              local bname = ""
              local bcapital = 0
              local home = ""
              local number = ""

              vRP.getUserBusiness(nuser_id, function(business)
                if business then
                  bname = business.name
                  bcapital = business.capital
                end

                vRP.getUserAddress(nuser_id, function(address)
                  if address then
                    home = address.home
                    number = address.number
                  end

                  local content = lang.police.identity.info({name,firstname,age,registration,phone,bname,bcapital,home,number})
                  vRPclient.setDiv(player,{"police_identity",".div_police_identity{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",content})
                  -- request to hide div
                  vRP.request(player, lang.police.menu.askid.request_hide(), 1000, function(player,ok)
                    vRPclient.removeDiv(player,{"police_identity"})
                  end)
                end)
              end)
            end
          end)
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
      vRPclient.notify(nplayer,{lang.police.menu.check.checked()})
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

local choice_seize_weapons = {function(player, choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player, {5}, function(nplayer)
      local nuser_id = vRP.getUserId(nplayer)
      if nuser_id ~= nil and vRP.hasPermission(nuser_id, "police.seizable") then
        vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
          if handcuffed then
            vRPclient.getWeapons(nplayer,{},function(weapons)
              for k,v in pairs(weapons) do -- display seized weapons
                -- vRPclient.notify(player,{lang.police.menu.seize.seized({k,v.ammo})})
                -- convert weapons to parametric weapon items
                vRP.giveInventoryItem(user_id, "wbody|"..k, 1, true)
                if v.ammo > 0 then
                  vRP.giveInventoryItem(user_id, "wammo|"..k, v.ammo, true)
                end
              end

              -- clear all weapons
              vRPclient.giveWeapons(nplayer,{{},true})
              vRPclient.notify(nplayer,{lang.police.menu.seize.weapons.seized()})
            end)
          else
            vRPclient.notify(player,{lang.police.not_handcuffed()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, lang.police.menu.seize.weapons.description()}

local choice_seize_items = {function(player, choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player, {5}, function(nplayer)
      local nuser_id = vRP.getUserId(nplayer)
      if nuser_id ~= nil and vRP.hasPermission(nuser_id, "police.seizable") then
        vRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
          if handcuffed then
            for k,v in pairs(cfg.seizable_items) do -- transfer seizable items
              local amount = vRP.getInventoryItemAmount(nuser_id,v)
              if amount > 0 then
                local item = vRP.items[v]
                if item then -- do transfer
                  if vRP.tryGetInventoryItem(nuser_id,v,amount,true) then
                    vRP.giveInventoryItem(user_id,v,amount,false)
                    vRPclient.notify(player,{lang.police.menu.seize.seized({item.name,amount})})
                  end
                end
              end
            end

            vRPclient.notify(nplayer,{lang.police.menu.seize.items.seized()})
          else
            vRPclient.notify(player,{lang.police.not_handcuffed()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, lang.police.menu.seize.items.description()}

-- toggle jail nearest player
local choice_jail = {function(player, choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player, {5}, function(nplayer)
      local nuser_id = vRP.getUserId(nplayer)
      if nuser_id ~= nil then
        vRPclient.isJailed(nplayer, {}, function(jailed)
          if jailed then -- unjail
            vRPclient.unjail(nplayer, {})
            vRPclient.notify(nplayer,{lang.police.menu.jail.notify_unjailed()})
            vRPclient.notify(player,{lang.police.menu.jail.unjailed()})
          else -- find the nearest jail
            vRPclient.getPosition(nplayer,{},function(x,y,z)
              local d_min = 1000
              local v_min = nil
              for k,v in pairs(cfg.jails) do
                local dx,dy,dz = x-v[1],y-v[2],z-v[3]
                local dist = math.sqrt(dx*dx+dy*dy+dz*dz)

                if dist <= d_min and dist <= 15 then -- limit the research to 15 meters
                  d_min = dist
                  v_min = v
                end

                -- jail
                if v_min then
                  vRPclient.jail(nplayer,{v_min[1],v_min[2],v_min[3],v_min[4]})
                  vRPclient.notify(nplayer,{lang.police.menu.jail.notify_jailed()})
                  vRPclient.notify(player,{lang.police.menu.jail.jailed()})
                else
                  vRPclient.notify(player,{lang.police.menu.jail.not_found()})
                end
              end
            end)
          end
        end)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, lang.police.menu.jail.description()}

local choice_fine = {function(player, choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player, {5}, function(nplayer)
      local nuser_id = vRP.getUserId(nplayer)
      if nuser_id ~= nil then
        local money = vRP.getMoney(nuser_id)+vRP.getBankMoney(nuser_id)

        -- build fine menu
        local menu = {name=lang.police.menu.fine.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

        local choose = function(player,choice) -- fine action
          local amount = cfg.fines[choice]
          if amount ~= nil then
            if vRP.tryFullPayment(nuser_id, amount) then
              vRP.insertPoliceRecord(nuser_id, lang.police.menu.fine.record({choice,amount}))
              vRPclient.notify(player,{lang.police.menu.fine.fined({choice,amount})})
              vRPclient.notify(nplayer,{lang.police.menu.fine.notify_fined({choice,amount})})
              vRP.closeMenu(player)
            else
              vRPclient.notify(player,{lang.money.not_enough()})
            end
          end
        end

        for k,v in pairs(cfg.fines) do -- add fines in function of money available
          if v <= money then
            menu[k] = {choose,v}
          end
        end

        -- open menu
        vRP.openMenu(player, menu)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, lang.police.menu.fine.description()}

local choice_store_weapons = {function(player, choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getWeapons(player,{},function(weapons)
      for k,v in pairs(weapons) do
        -- convert weapons to parametric weapon items
        vRP.giveInventoryItem(user_id, "wbody|"..k, 1, true)
        if v.ammo > 0 then
          vRP.giveInventoryItem(user_id, "wammo|"..k, v.ammo, true)
        end
      end

      -- clear all weapons
      vRPclient.giveWeapons(player,{{},true})
    end)
  end
end, lang.police.menu.store_weapons.description()}

-- add choices to the menu
vRP.registerMenuBuilder("main", function(add, data)
  local player = data.player

  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local choices = {}

    -- build police menu
    choices[lang.police.title()] = {function(player,choice)
      local menu = {name=lang.police.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

      if vRP.hasPermission(user_id,"police.handcuff") then
        menu[lang.police.menu.handcuff.title()] = choice_handcuff
      end

      if vRP.hasPermission(user_id,"police.putinveh") then
        menu[lang.police.menu.putinveh.title()] = choice_putinveh
      end

      if vRP.hasPermission(user_id,"police.getoutveh") then
        menu[lang.police.menu.getoutveh.title()] = choice_getoutveh
      end

      if vRP.hasPermission(user_id,"police.askid") then
        menu[lang.police.menu.askid.title()] = choice_askid
      end

      if vRP.hasPermission(user_id,"police.check") then
        menu[lang.police.menu.check.title()] = choice_check
      end

      if vRP.hasPermission(user_id,"police.seize.weapons") then
        menu[lang.police.menu.seize.weapons.title()] = choice_seize_weapons
      end

      if vRP.hasPermission(user_id,"police.seize.items") then
        menu[lang.police.menu.seize.items.title()] = choice_seize_items
      end

      if vRP.hasPermission(user_id,"police.jail") then
        menu[lang.police.menu.jail.title()] = choice_jail
      end

      if vRP.hasPermission(user_id,"police.fine") then
        menu[lang.police.menu.fine.title()] = choice_fine
      end

      if vRP.hasPermission(user_id, "police.store_weapons") then
        menu[lang.police.menu.store_weapons.title()] = choice_store_weapons
      end

      vRP.openMenu(player,menu)
    end}

    add(choices)
  end
end)

local function build_client_points(source)
  -- PC
  for k,v in pairs(cfg.pcs) do
    local x,y,z = table.unpack(v)
    vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,125,255,125,150})
    vRP.setArea(source,"vRP:police:pc"..k,x,y,z,1,1.5,pc_enter,pc_leave)
  end
end

-- build police points
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    build_client_points(source)
  end
end)

-- WANTED SYNC

local wantedlvl_players = {}

function vRP.getUserWantedLevel(user_id)
  return wantedlvl_players[user_id] or 0
end

-- receive wanted level
function tvRP.updateWantedLevel(level)
  local player = source
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local was_wanted = (vRP.getUserWantedLevel(user_id) > 0)
    wantedlvl_players[user_id] = level
    local is_wanted = (level > 0)

    -- send wanted to listening service
    if not was_wanted and is_wanted then
      vRPclient.getPosition(player, {}, function(x,y,z)
        vRP.sendServiceAlert(nil, cfg.wanted.service,x,y,z,lang.police.wanted({level}))
      end)
    end

    if was_wanted and not is_wanted then
      vRPclient.removeNamedBlip(-1, {"vRP:wanted:"..user_id}) -- remove wanted blip (all to prevent phantom blip)
    end
  end
end

-- delete wanted entry on leave
AddEventHandler("vRP:playerLeave", function(user_id, player)
  wantedlvl_players[user_id] = nil
  vRPclient.removeNamedBlip(-1, {"vRP:wanted:"..user_id})  -- remove wanted blip (all to prevent phantom blip)
end)

-- display wanted positions
local function task_wanted_positions()
  local listeners = vRP.getUsersByPermission("police.wanted")
  for k,v in pairs(wantedlvl_players) do -- each wanted player
    local player = vRP.getUserSource(tonumber(k))
    if player ~= nil and v ~= nil and v > 0 then
      vRPclient.getPosition(player, {}, function(x,y,z)
        for l,w in pairs(listeners) do -- each listening player
          local lplayer = vRP.getUserSource(w)
          if lplayer ~= nil then
            vRPclient.setNamedBlip(lplayer, {"vRP:wanted:"..k,x,y,z,cfg.wanted.blipid,cfg.wanted.blipcolor,lang.police.wanted({v})})
          end
        end
      end)
    end
  end

  SetTimeout(5000, task_wanted_positions)
end
task_wanted_positions()
