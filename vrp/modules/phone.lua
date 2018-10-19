
local lang = vRP.lang
local htmlEntities = module("lib/htmlEntities")

-- basic phone module

local Phone = class("Phone", vRP.Extension)

-- SUBCLASS

Phone.User = class("User")

-- send an sms from an user to a phone number
-- return true on success
function Phone.User:sendSMS(phone, msg)
  local cfg = vRP.EXT.Phone.cfg

  if string.len(msg) > cfg.sms_size then -- clamp sms
    sms = string.sub(msg,1,cfg.sms_size)
  end

  local cid, uid = vRP.EXT.Identity:getByPhone(phone)
  if cid then
    local tuser = vRP.users[uid]
    if tuser and tuser.cid == cid then
      local from = tuser:getPhoneDirectoryName(self.identity.phone).." ("..self.identity.phone..")"

      vRP.EXT.Base.remote._notify(tuser.source,lang.phone.sms.notify({from, msg}))
      vRP.EXT.GUI.remote._playAudioSource(tuser.source, cfg.sms_sound, 0.5)
      tuser:addSMS(self.identity.phone, msg)
      return true
    end
  end
end

function Phone.User:addSMS(phone, msg)
  if #self.phone_sms >= vRP.EXT.Phone.cfg.sms_history then -- remove last sms of the table
    table.remove(self.phone_sms)
  end

  table.insert(self.phone_sms,1,{phone,msg}) -- insert new sms at first position {phone,message}
end

-- get directory name by number for a specific user
function Phone.User:getPhoneDirectoryName(phone)
  return self.phone_directory[phone] or "unknown"
end

-- call from a user to a phone number
-- return true if the communication is established
function Phone.User:phoneCall(phone)
  local cfg = vRP.EXT.Phone.cfg

  local cid, uid = vRP.EXT.Identity:getByPhone(phone)
  if cid then
    local tuser = vRP.users[uid]
    if tuser and tuser.cid == cid then
      local to = self:getPhoneDirectoryName(phone).." ("..phone..")"
      local from = tuser:getPhoneDirectoryName(self.identity.phone).." ("..self.identity.phone..")"

      vRP.EXT.Phone.remote._hangUp(self.source) -- hangup phone of the caller
      vRP.EXT.Phone.remote._setCallWaiting(self.source, tuser.source, true) -- make caller to wait the answer

      -- notify
      vRP.EXT.Base.remote._notify(self.source,lang.phone.call.notify_to({to}))
      vRP.EXT.Base.remote._notify(tuser.source,lang.phone.call.notify_from({from}))

      -- play dialing sound
      vRP.EXT.GUI.remote._setAudioSource(self.source, "vRP:phone:dialing", cfg.dialing_sound, 0.5)
      vRP.EXT.GUI.remote._setAudioSource(tuser.source, "vRP:phone:dialing", cfg.ringing_sound, 0.5)

      local ok = false

      -- send request to called
      if tuser:request(lang.phone.call.ask({from}), 15) then -- accepted
        vRP.EXT.Phone.remote._hangUp(tuser.source) -- hangup phone of the receiver
        vRP.EXT.GUI.remote._connectVoice(tuser.source, "phone", self.source) -- connect voice
        ok = true
      else -- refused
        vRP.EXT.Base.remote._notify(self.source,lang.phone.call.notify_refused({to})) 
        vRP.EXT.Phone.remote._setCallWaiting(self.source, tuser.source, false) 
      end

      -- remove dialing sound
      vRP.EXT.GUI.remote._removeAudioSource(self.source, "vRP:phone:dialing")
      vRP.EXT.GUI.remote._removeAudioSource(tuser.source, "vRP:phone:dialing")

      return ok
    end
  end
end

-- send an smspos from an user to a phone number
-- return true on success
function Phone.User:sendSMSPos(phone, x,y,z)
  local cfg = vRP.EXT.Phone.cfg

  local cid, uid = vRP.EXT.Identity:getByPhone(phone)
  if cid then
    local tuser = vRP.users[uid]
    if tuser and tuser.cid == cid then
      local from = tuser:getPhoneDirectoryName(self.identity.phone).." ("..self.identity.phone..")"
      vRP.EXT.GUI.remote._playAudioSource(tuser.source, cfg.sms_sound, 0.5)
      vRP.EXT.Base.remote._notify(tuser.source,lang.phone.smspos.notify({from})) -- notify
      -- add position for 5 minutes
      local bid = vRP.EXT.Map.remote.addBlip(tuser.source,x,y,z,162,37,from)
      SetTimeout(cfg.smspos_duration*1000,function()
        vRP.EXT.Map.remote._removeBlip(tuser.source,{bid})
      end)

      return true
    end
  end
end

-- PRIVATE METHODS

-- menu: phone directory entry
local function menu_phone_directory_entry(self)
  local function m_remove(menu) -- remove directory entry
    phone_directory[name] = nil
    vRP.closeMenu(player) -- close entry menu (removed)
  end

  local function m_sendsms(menu) -- send sms to directory entry
    local msg = vRP.prompt(player,lang.phone.directory.sendsms.prompt({cfg.sms_size}),"")
    msg = sanitizeString(msg,sanitizes.text[1],sanitizes.text[2])
    if vRP.sendSMS(user_id, phone, msg) then
      vRPclient._notify(player,lang.phone.directory.sendsms.sent({phone}))
    else
      vRPclient._notify(player,lang.phone.directory.sendsms.not_sent({phone}))
    end
  end

  local function m_sendpos(menu) -- send current position to directory entry
    local x,y,z = vRPclient.getPosition(player)
    if vRP.sendSMSPos(user_id, phone, x,y,z) then
      vRPclient._notify(player,lang.phone.directory.sendsms.sent({phone}))
    else
      vRPclient._notify(player,lang.phone.directory.sendsms.not_sent({phone}))
    end
  end

  local function m_call(menu) -- call player
    if not vRP.phoneCall(user_id, phone) then
      vRPclient._notify(player,lang.phone.directory.call.not_reached({phone}))
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("phone.directory.entry", function(menu)
    menu.title = htmlEntities.encode(menu.user:getPhoneDirectoryName(menu.data.phone))
    menu.css.header_color = "rgba(0,125,255,0.75)"

    menu:addOption(lang.phone.directory.call.title(), m_call)
    menu:addOption(lang.phone.directory.sendsms.title(), m_sendsms)
    menu:addOption(lang.phone.directory.sendpos.title(), m_sendpos)
    menu:addOption(lang.phone.directory.remove.title(), m_remove)
  end)
end

-- menu: phone directory
local function menu_phone_directory(self)
  local function m_add(menu) -- add to directory
    local phone = vRP.prompt(player,lang.phone.directory.add.prompt_number(),"")
    local name = vRP.prompt(player,lang.phone.directory.add.prompt_name(),"")
    name = sanitizeString(tostring(name),sanitizes.text[1],sanitizes.text[2])
    phone = sanitizeString(tostring(phone),sanitizes.text[1],sanitizes.text[2])
    if #name > 0 and #phone > 0 then
      phone_directory[name] = phone -- set entry
      vRPclient._notify(player, lang.phone.directory.add.added())
    else
      vRPclient._notify(player, lang.common.invalid_value())
    end
  end

  local function m_entry(menu, value) 
    menu.user:openMenu("phone.directory.entry", {phone = value})
  end

  vRP.EXT.GUI:registerMenuBuilder("phone.directory", function(menu)
    menu.title = lang.phone.directory.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    menu:addOption(lang.phone.directory.add.title(), m_add)

    for phone, name in pairs(menu.user.phone_directory) do -- add directory entries
      menu:addOption(htmlEntities.encode(name), m_entry, nil, phone)
    end
  end)
end

-- menu: phone sms
local function menu_phone_sms(self)
  local function m_respond(menu, value)
    local phone = value

    -- answer to sms
    local msg = vRP.prompt(player,lang.phone.directory.sendsms.prompt({cfg.sms_size}),"")
    msg = sanitizeString(msg,sanitizes.text[1],sanitizes.text[2])
    if vRP.sendSMS(user_id, phone, msg) then
      vRPclient._notify(player,lang.phone.directory.sendsms.sent({phone}))
    else
      vRPclient._notify(player,lang.phone.directory.sendsms.not_sent({phone}))
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("phone.sms", function(menu)
    menu.title = lang.phone.sms.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    -- add all SMS
    for i,sms in pairs(menu.user.phone_sms) do
      local from = menu.user:getPhoneDirectoryName(sms[1]).." ("..sms[1]..")"

      menu:addOption("#"..i.." "..from, m_respond,
        lang.phone.sms.info({from,htmlEntities.encode(sms[2])}), sms[1])
    end
  end)
end

-- menu: phone service
local function menu_phone_service(self)
  local function m_alert(menu, value) -- alert a service
    local service = value

    local x,y,z = vRPclient.getPosition(player)
    local msg = vRP.prompt(player,lang.phone.service.prompt(),"")
    msg = sanitizeString(msg,sanitizes.text[1],sanitizes.text[2])
    vRPclient._notify(player,service.notify) -- notify player
    vRP.sendServiceAlert(player,choice,x,y,z,msg) -- send service alert (call request)
  end

  vRP.EXT.GUI:registerMenuBuilder("phone.service", function(menu)
    menu.title = lang.phone.service.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    for k,service in pairs(self.cfg.services) do
      menu:addOption(k, m_alert, nil, service)
    end
  end)
end

-- menu: phone announce
local function menu_phone_announce(self)
  -- build announce menu
  local announce_menu = {name=lang.phone.announce.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

  -- nest menu
  announce_menu.onclose = function(player) vRP.openMenu(player, phone_menu) end

  local function ch_announce_alert(player,choice) -- alert a announce
    local announce = announces[choice]
    local user_id = vRP.getUserId(player)
    if announce and user_id then
      if not announce.permission or vRP.hasPermission(user_id,announce.permission) then
        local msg = vRP.prompt(player,lang.phone.announce.prompt(),"")
        msg = sanitizeString(msg,sanitizes.text[1],sanitizes.text[2])
        if string.len(msg) > 10 and string.len(msg) < 1000 then
          if announce.price <= 0 or vRP.tryPayment(user_id, announce.price) then -- try to pay the announce
            vRPclient._notify(player, lang.money.paid({announce.price}))

            msg = htmlEntities.encode(msg)
            msg = string.gsub(msg, "\n", "<br />") -- allow returns

            -- send announce to all
            local users = vRP.getUsers()
            for k,v in pairs(users) do
              vRPclient._announce(v,announce.image,msg)
            end
          else
            vRPclient._notify(player, lang.money.not_enough())
          end
        else
          vRPclient._notify(player, lang.common.invalid_value())
        end
      else
        vRPclient._notify(player, lang.common.not_allowed())
      end
    end
  end

  for k,v in pairs(announces) do
    announce_menu[k] = {ch_announce_alert,lang.phone.announce.item_desc({v.price,v.description or ""})}
  end

  local function ch_announce(player, choice)
    vRP.openMenu(player,announce_menu)
  end

  local function ch_hangup(player, choice)
    vRPclient._phoneHangUp(player)
  end
end

-- menu: phone
local function menu_phone(self)
  local function m_directory(menu)
    menu.user:openMenu("phone.directory")
  end

  local function m_sms(menu)
    menu.user:openMenu("phone.sms")
  end

  local function m_service(menu)
    menu.user:openMenu("phone.service")
  end

  vRP.EXT.GUI:registerMenuBuilder("phone", function(menu)
    menu.title = lang.phone.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"
  end)
end

-- METHODS

function Phone:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/phone")
  self.sanitizes = module("cfg/sanitizes")

  -- directory menu


  phone_menu[lang.phone.directory.title()] = {ch_directory,lang.phone.directory.description()}
  phone_menu[lang.phone.sms.title()] = {ch_sms,lang.phone.sms.description()}
  phone_menu[lang.phone.service.title()] = {ch_service,lang.phone.service.description()}
  phone_menu[lang.phone.announce.title()] = {ch_announce,lang.phone.announce.description()}
  phone_menu[lang.phone.hangup.title()] = {ch_hangup,lang.phone.hangup.description()}

  -- add phone menu to main menu

  vRP.registerMenuBuilder("main", function(add, data)
    local player = data.player
    local choices = {}
    choices[lang.phone.title()] = {function() vRP.openMenu(player,phone_menu) end}

    local user_id = vRP.getUserId(player)
    if user_id and vRP.hasPermission(user_id, "player.phone") then
      add(choices)
    end
  end)
end


-- Send a service alert to all service listeners
--- sender: user or nil (optional, if not nil, it is a call request alert)
--- service_name: service name
--- x,y,z: coordinates
--- msg: alert message
function Phone:sendServiceAlert(sender, service_name,x,y,z,msg)
  local service = self.cfg.services[service_name]
  local answered = false
  if service then
    local targets = {}
    for _,user in pairs(vRP.users) do
      if user:hasPermission(service.alert_permission) then
        table.insert(targets, user)
      end
    end

    -- send notify and alert to all targets
    for _,user in pairs(targets) do
      vRP.EXT.Base.remote._notify(user.source,service.alert_notify..msg)
      -- add position for service.time seconds
      local bid = vRP.EXT.Map.remote.addBlip(user.source,x,y,z,service.blipid,service.blipcolor,"("..service_name..") "..msg)
      SetTimeout(service.alert_time*1000,function()
        vRP.EXT.Map.remote._removeBlip(user.source,bid)
      end)

      -- call request
      if sender then
        async(function()
          local ok = user:request(lang.phone.service.ask_call({service_name, htmlEntities.encode(msg)}), 30)
          if ok then -- take the call
            if not answered then
              -- answer the call
              vRP.EXT.Base.remote._notify(sender.source,service.answer_notify)
              vRP.EXT.Map.remote._setGPS(user.source,x,y)
              answered = true
            else
              vRP.EXT.Base.remote._notify(user.source,lang.phone.service.taken())
            end
          end
        end)
      end
    end
  end
end


