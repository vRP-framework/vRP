-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.police then return end

local lang = vRP.lang
local htmlEntities = module("vrp", "lib/htmlEntities")

-- this module define some police tools and functions
local Police = class("Police", vRP.Extension)

-- SUBCLASS

Police.User = class("User")

-- insert a police record (will do a save)
--- record: text for one line 
function Police.User:insertPoliceRecord(record)
  table.insert(self.police_records, record)
  self:savePoliceRecords()
end

function Police.User:savePoliceRecords()
  -- save records
  vRP:setCData(self.cid, "vRP:police:records", msgpack.pack(self.police_records))
end

-- PRIVATE METHODS

-- menu: police_pc records
local function menu_police_pc_records(self)
  local function m_add(menu)
    local user = menu.user
    local tuser = menu.data.tuser

    local record = user:prompt(lang.police.pc.records.add.prompt(), "")
    if record and string.len(record) > 0 then
      tuser:insertPoliceRecord(record)
      user:actualizeMenu()
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  local function m_delete(menu)
    local user = menu.user
    local tuser = menu.data.tuser

    local index = parseInt(user:prompt(lang.police.pc.records.delete.prompt(), ""))
    if index > 0 and index <= #tuser.police_records then
      table.remove(tuser.police_records, index)
      tuser:savePoliceRecords()

      user:actualizeMenu()
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("police_pc.records", function(menu)
    menu.title = lang.police.pc.records.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    local tuser = menu.data.tuser

    -- add records
    for i, record in ipairs(tuser.police_records) do
      menu:addOption("#"..i, nil, htmlEntities.encode(record))
    end

    menu:addOption(lang.police.pc.records.add.title(), m_add)
    menu:addOption(lang.police.pc.records.delete.title(), m_delete)
  end)
end

-- menu: police pc
local function menu_police_pc(self)
  -- search identity by registration
  local function m_searchreg(menu)
    local user = menu.user


    local reg = user:prompt(lang.police.pc.searchreg.prompt(),"")
    local cid = vRP.EXT.Identity:getByRegistration(reg)
    if cid then
      local identity = vRP.EXT.Identity:getIdentity(cid)
      if identity then
        local smenu = user:openMenu("identity", {cid = cid})
        menu:listen("remove", function(menu) menu.user:closeMenu(smenu) end)
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.not_found())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.not_found())
    end
  end

  -- show police records by registration
  local function m_police_records(menu)
    local user = menu.user

    local reg = user:prompt(lang.police.pc.searchreg.prompt(),"")
    local tuser
    local cid = vRP.EXT.Identity:getByRegistration(reg)
    if cid then tuser = vRP.users_by_cid[cid] end

    if tuser then
      local smenu = user:openMenu("police_pc.records", {tuser = tuser})
      menu:listen("remove", function(menu) menu.user:closeMenu(smenu) end)
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.not_found())
    end
  end

  -- close business of an arrested owner
  local function m_closebusiness(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,5)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      local identity = nuser.identity

      local business = vRP.EXT.Business:getBusiness(nuser.cid)

      if identity and business then
        if user:request(lang.police.pc.closebusiness.request({identity.name,identity.firstname,business.name}),15) then
          vRP.EXT.Business:closeBusiness(nuser.cid)
          vRP.EXT.Base.remote._notify(user.source,lang.police.pc.closebusiness.closed())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  -- track vehicle
  local function m_trackveh(menu)
    local user = menu.user

    local reg = user:prompt(lang.police.pc.trackveh.prompt_reg(),"")

    local tuser
    local cid = vRP.EXT.Identity:getByRegistration(reg)
    if cid then tuser = vRP.users_by_cid[cid] end

    if tuser then
      local note = user:prompt(lang.police.pc.trackveh.prompt_note(),"")
      -- begin veh tracking
      vRP.EXT.Base.remote._notify(user.source,lang.police.pc.trackveh.tracking())
      local seconds = math.random(self.cfg.trackveh.min_time,self.cfg.trackveh.max_time)

      SetTimeout(seconds*1000,function()
        local ok,x,y,z = vRP.EXT.Garage.remote.getAnyOwnedVehiclePosition(tuser.source)
        if ok then -- track success
          vRP.EXT.Phone:sendServiceAlert(nil, self.cfg.trackveh.service,x,y,z,lang.police.pc.trackveh.tracked({reg,note}))
        else
          vRP.EXT.Base.remote._notify(user.source,lang.police.pc.trackveh.track_failed({reg,note})) -- failed
        end
      end)
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.not_found())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("police_pc", function(menu)
    menu.title = lang.police.pc.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    menu:addOption(lang.police.pc.searchreg.title(), m_searchreg, lang.police.pc.searchreg.description())
    menu:addOption(lang.police.pc.trackveh.title(), m_trackveh, lang.police.pc.trackveh.description())
    menu:addOption(lang.police.pc.records.title(), m_police_records, lang.police.pc.records.description())
    menu:addOption(lang.police.pc.closebusiness.title(), m_closebusiness, lang.police.pc.closebusiness.description())
  end)
end

-- menu: police fine
local function menu_police_fine(self)
  local function m_fine(menu, name)
    local user = menu.user
    local tuser = menu.data.tuser

    local amount = self.cfg.fines[name]
    if amount then
      if tuser:tryFullPayment(amount) then
        tuser:insertPoliceRecord(lang.police.menu.fine.record({name,amount}))
        vRP.EXT.Base.remote._notify(user.source,lang.police.menu.fine.fined({name,amount}))
        vRP.EXT.Base.remote._notify(tuser.source,lang.police.menu.fine.notify_fined({name,amount}))

        user:closeMenu(menu)
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("police.fine", function(menu)
    menu.title = lang.police.menu.fine.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    local money = menu.data.money

    for _,fine in ipairs(self.sorted_fines) do -- add fines in function of money available
      local name, amount = fine[1], fine[2]

      if amount <= money then
        menu:addOption(name, m_fine, amount, name)
      end
    end
  end)
end

-- menu: police check
local function menu_police_check(self)
  vRP.EXT.GUI:registerMenuBuilder("police.check", function(menu)
    menu.title = lang.police.menu.check.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    local tuser = menu.data.tuser

    local wallet = tuser:getWallet()
    local items = clone(tuser:getInventory())

    -- add worn weapons to items
    local weapons = vRP.EXT.PlayerState.remote.getWeapons(tuser.source)
    for id, weapon in pairs(weapons) do
      local b_id = "wbody|"..id
      local b_amount = items[b_id] or 0
      items[b_id] = b_amount+1

      if weapon.ammo > 0 then
        local a_id = "wammo|"..id
        local a_amount = items[a_id] or 0
        items[a_id] = a_amount+weapon.ammo
      end
    end

    -- general info
    menu:addOption(lang.police.menu.check.info.title(), nil, lang.police.menu.check.info.description({wallet}))

    -- items
    for fullid, amount in pairs(items) do
      local citem = vRP.EXT.Inventory:computeItem(fullid)
      if citem then
        menu:addOption(htmlEntities.encode(citem.name), nil, lang.inventory.iteminfo({amount,citem.description, string.format("%.2f",citem.weight)}))
      end
    end
  end)
end

-- menu: police
local function menu_police(self)
  local function m_handcuff(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      self.remote._toggleHandcuff(nuser.source)
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_drag(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      local followed = self.remote.getFollowedPlayer(nuser.source)
      if followed ~= user.source then -- drag
        if self.remote.isHandcuffed(nuser.source) then  -- check handcuffed
          self.remote._followPlayer(nuser.source, user.source)
        else
          vRP.EXT.Base.remote._notify(user.source,lang.police.not_handcuffed())
        end
      else -- stop follow
        self.remote._followPlayer(nuser.source)
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_putinveh(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      if self.remote.isHandcuffed(nuser.source) then  -- check handcuffed
        self.remote._putInNearestVehicleAsPassenger(nuser.source, 5)
      else
        vRP.EXT.Base.remote._notify(user.source,lang.police.not_handcuffed())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_getoutveh(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      if self.remote.isHandcuffed(nuser.source) then  -- check handcuffed
        vRP.EXT.Garage.remote._ejectVehicle(nuser.source)
      else
        vRP.EXT.Base.remote._notify(user.source,lang.police.not_handcuffed())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_askid(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      vRP.EXT.Base.remote._notify(user.source,lang.police.menu.askid.asked())
      if nuser:request(lang.police.menu.askid.request(),15) then
        user:openMenu("identity", {cid = nuser.cid})
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.request_refused())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_check(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,5)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      if self.remote.isHandcuffed(nuser.source) then  -- check handcuffed
        user:openMenu("police.check", {tuser = nuser})
        vRP.EXT.Base.remote._notify(nuser.source,lang.police.menu.check.checked())
      else
        vRP.EXT.Base.remote._notify(user.source,lang.police.not_handcuffed())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_seize(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,5)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      if nuser:hasPermission("police.seizable") then
        if self.remote.isHandcuffed(nuser.source) then  -- check handcuffed
          -- weapons
          local weapons = vRP.EXT.PlayerState.remote.replaceWeapons(nuser.source, {})

          for k,v in pairs(weapons) do 
            -- convert weapons to parametric weapon items
            user:tryGiveItem("wbody|"..k, 1)
            if v.ammo > 0 then
              user:tryGiveItem("wammo|"..k, v.ammo)
            end
          end


          -- items
          local inventory = nuser:getInventory()

          for _,key in pairs(self.cfg.seizable_items) do -- transfer seizable items
            local sub_items = {key} -- single item

            if string.sub(key,1,1) == "*" then -- seize all parametric items of this id
              local id = string.sub(key,2)
              sub_items = {}
              for fullid in pairs(inventory) do
                if splitString(fullid, "|")[1] == id then -- same parametric item
                  table.insert(sub_items, fullid) -- add full idname
                end
              end
            end

            for _,fullid in pairs(sub_items) do
              local amount = nuser:getItemAmount(fullid)
              if amount > 0 then
                local citem = vRP.EXT.Inventory:computeItem(fullid)
                if citem then -- do transfer
                  if nuser:tryTakeItem(fullid,amount) then
                    user:tryGiveItem(fullid,amount)
                  end
                end
              end
            end
          end

          vRP.EXT.Base.remote._notify(nuser.source,lang.police.menu.seize.seized())
        else
          vRP.EXT.Base.remote._notify(user.source,lang.police.not_handcuffed())
        end
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_jail(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,5)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      if self.remote.isJailed(nuser.source) then
        self.remote._unjail(nuser.source)
        vRP.EXT.Base.remote._notify(nuser.source,lang.police.menu.jail.notify_unjailed())
        vRP.EXT.Base.remote._notify(user.source,lang.police.menu.jail.unjailed())
      else -- find the nearest jail
        local x,y,z = vRP.EXT.Base.remote.getPosition(nuser.source)
        local d_min = 1000
        local v_min = nil
        for k,v in pairs(self.cfg.jails) do
          local dx,dy,dz = x-v[1],y-v[2],z-v[3]
          local dist = math.sqrt(dx*dx+dy*dy+dz*dz)

          if dist <= d_min and dist <= 15 then -- limit the research to 15 meters
            d_min = dist
            v_min = v
          end

          -- jail
          if v_min then
            self.remote._jail(nuser.source,v_min[1],v_min[2],v_min[3],v_min[4])
            vRP.EXT.Base.remote._notify(nuser.source,lang.police.menu.jail.notify_jailed())
            vRP.EXT.Base.remote._notify(user.source,lang.police.menu.jail.jailed())
          else
            vRP.EXT.Base.remote._notify(user.source,lang.police.menu.jail.not_found())
          end
        end
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  local function m_fine(menu)
    local user = menu.user

    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,5)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      local money = nuser:getWallet()+nuser:getBank()
      user:openMenu("police.fine", {tuser = nuser, money = money})
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("police", function(menu)
    local user = menu.user
    menu.title = lang.police.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    if user:hasPermission("police.askid") then
      menu:addOption(lang.police.menu.askid.title(), m_askid, lang.police.menu.askid.description())
    end

    if user:hasPermission("police.handcuff") then
      menu:addOption(lang.police.menu.handcuff.title(), m_handcuff, lang.police.menu.handcuff.description())
    end

    if user:hasPermission("police.drag") then
      menu:addOption(lang.police.menu.drag.title(), m_drag, lang.police.menu.drag.description())
    end

    if user:hasPermission("police.putinveh") then
      menu:addOption(lang.police.menu.putinveh.title(), m_putinveh, lang.police.menu.putinveh.description())
    end

    if user:hasPermission("police.getoutveh") then
      menu:addOption(lang.police.menu.getoutveh.title(), m_getoutveh, lang.police.menu.getoutveh.description())
    end

    if user:hasPermission("police.check") then
      menu:addOption(lang.police.menu.check.title(), m_check, lang.police.menu.check.description())
    end

    if user:hasPermission("police.seize") then
      menu:addOption(lang.police.menu.seize.title(), m_seize, lang.police.menu.seize.description())
    end

    if user:hasPermission("police.jail") then
      menu:addOption(lang.police.menu.jail.title(), m_jail, lang.police.menu.jail.description())
    end

    if user:hasPermission("police.fine") then
      menu:addOption(lang.police.menu.fine.title(), m_fine, lang.police.menu.fine.description())
    end
  end)
end

local function define_items(self)
  local function m_bulletproof_vest_wear(menu)
    local user = menu.user
    local fullid = menu.data.fullid

    if user:tryTakeItem(fullid, 1) then -- take vest
      vRP.EXT.PlayerState.remote._setArmour(user.source, 100)

      local namount = user:getItemAmount(fullid)
      if namount > 0 then
        user:actualizeMenu()
      else
        user:closeMenu(menu)
      end
    end
  end

  local function i_bulletproof_vest_menu(args, menu)
    menu:addOption(lang.item.bulletproof_vest.wear.title(), m_bulletproof_vest_wear)
  end

  vRP.EXT.Inventory:defineItem("bulletproof_vest", lang.item.bulletproof_vest.name(), lang.item.bulletproof_vest.description(), i_bulletproof_vest_menu, 1.5)
end

-- targets: map of wanted users
-- listeners: map of user
function listen_wanted(self, targets, listeners)
  local Map = vRP.EXT.Map

  for target in pairs(targets) do
    local x,y,z = vRP.EXT.Base.remote.getPosition(target.source)
    local ment = clone(self.cfg.wanted.map_entity)
    ment[2].player = target.source
    ment[2].title = lang.police.wanted({self:getUserWantedLevel(target)})

    for listener in pairs(listeners) do
      Map.remote._setEntity(listener.source, "vRP:police:wanted:"..target.id, ment[1], ment[2])
    end
  end
end

-- targets: map of wanted users
-- listeners: map of user
function unlisten_wanted(self, targets, listeners)
  local Map = vRP.EXT.Map

  for target in pairs(targets) do
    for listener in pairs(listeners) do
      Map.remote._removeEntity(listener.source, "vRP:police:wanted:"..target.id)
    end
  end
end

-- METHODS

function Police:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/police")

  -- sort fines
  self.sorted_fines = {}
  for name, amount in pairs(self.cfg.fines) do
    table.insert(self.sorted_fines, {name, amount})
  end
  table.sort(self.sorted_fines, function(a,b) return a[2] < b[2] end)

  self:log(#self.cfg.pcs.." PCs "..#self.cfg.jails.." jails "..#self.sorted_fines.." fines")

  self.wantedlvl_users = {} -- map of user => wanted level
  self.wanted_listeners = {} -- map of user

  -- items
  define_items(self)

  -- menu
  menu_police_pc_records(self)
  menu_police_pc(self)
  menu_police_fine(self)
  menu_police_check(self)
  menu_police(self)

  -- main menu
  local function m_police(menu)
    menu.user:openMenu("police")
  end

  local function m_store_weapons(menu)
    local user = menu.user

    local weapons = vRP.EXT.PlayerState.remote.replaceWeapons(user.source, {})
    for k,v in pairs(weapons) do
      -- convert weapons to parametric weapon items
      user:tryGiveItem("wbody|"..k, 1)
      if v.ammo > 0 then
        user:tryGiveItem("wammo|"..k, v.ammo)
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    if menu.user:hasPermission("police.menu") then
      menu:addOption(lang.police.title(), m_police)
    end

    if menu.user:hasPermission("player.store_weapons") then
      menu:addOption(lang.police.menu.store_weapons.title(), m_store_weapons, lang.police.menu.store_weapons.description())
    end
  end)


  -- task: wanted listening
  local function task_wanted()
    local listeners = vRP.EXT.Group:getUsersByPermission("police.wanted")

    local wanted_listeners = {} -- new wanted listeners
    for _,listener in pairs(listeners) do
      wanted_listeners[listener] = true
    end

    -- added listeners
    local added = {}
    for listener in pairs(wanted_listeners) do
      if not self.wanted_listeners[listener] then
        added[listener] = true
      end
    end

    -- deleted listeners
    local deleted = {}
    for listener in pairs(self.wanted_listeners) do
      if not wanted_listeners[listener] then
        deleted[listener] = true
      end
    end

    self.wanted_listeners = wanted_listeners -- update

    listen_wanted(self, self.wantedlvl_users, added)
    unlisten_wanted(self, self.wantedlvl_users, deleted)

    SetTimeout(5000, task_wanted)
  end

  async(function()
    task_wanted()
  end)
end

function Police:getUserWantedLevel(user)
  return self.wantedlvl_users[user] or 0
end

-- EVENT
Police.event = {}

function Police.event:characterLoad(user)
  -- load records
  local sdata = vRP:getCData(user.cid, "vRP:police:records")
  user.police_records = (sdata and string.len(sdata) > 0 and msgpack.unpack(sdata) or {})
end

function Police.event:playerSpawn(user, first_spawn)
  if first_spawn then
    local menu
    local function enter(user)
      if user:hasPermission("police.pc") then
        menu = user:openMenu("police_pc")
      end
    end

    local function leave(user)
      if menu then
        user:closeMenu(menu)
      end
    end

    -- build police PCs
    for k,v in pairs(self.cfg.pcs) do
      local x,y,z = table.unpack(v)

      local ment = clone(self.cfg.pc_map_entity)
      ment[2].title = lang.police.pc.title()
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

      user:setArea("vRP:police:pc:"..k,x,y,z,1,1.5,enter,leave)
    end
  end
end

function Police.event:playerLeave(user)
  self.wantedlvl_users[user] = nil
  unlisten_wanted(self, {[user] = true}, self.wanted_listeners)
end

-- TUNNEL
Police.tunnel = {}

-- receive wanted level
function Police.tunnel:updateWantedLevel(level)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local was_wanted = (self:getUserWantedLevel(user) > 0)
    local is_wanted = (level > 0)
    local lvl_changed = level ~= self:getUserWantedLevel(user)

    if lvl_changed then
      -- send wanted to listening service
      if not was_wanted and is_wanted then -- add to wanted
        self.wantedlvl_users[user] = level

        listen_wanted(self, {[user] = level}, self.wanted_listeners)

        -- alert
        local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
        vRP.EXT.Phone:sendServiceAlert(nil, self.cfg.wanted.service,x,y,z,lang.police.wanted({level}))
      elseif was_wanted and not is_wanted then -- remove from wanted
        self.wantedlvl_users[user] = nil
        unlisten_wanted(self, {[user] = true}, self.wanted_listeners)
      elseif is_wanted then -- level changed
        self.wantedlvl_users[user] = level
        listen_wanted(self, {[user] = level}, self.wanted_listeners)
      end
    end
  end
end

vRP:registerExtension(Police)
