
-- phone module
local lang = vRP.lang

-- api

function vRP.sendSMS(user_id, dest_id, msg)
end

-- build phone menu

local function ch_directory(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data and data.phone_directory then
      -- build directory menu
      local menu = {name=lang.phone.directory.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

      local ch_add = function(player, choice) -- add to directory
      end

      local ch_remove = function(player, choice) -- remove directory entry
      end

      local ch_sendsms = function(player, choice) -- send sms to directory entry
      end

      local ch_entry = function(player, choice) -- directory entry
        -- build entry menu
        local menu = {name=choice,css={top="75px",header_color="rgba(0,125,255,0.75)"}}

        menu[lang.phone.directory.sendsms.title()] = {ch_sendsms}
        menu[lang.phone.directory.remove.title()] = {ch_remove}
      end

      menu[lang.phone.directory.add.title()] = {ch_add}

      for k,v in pairs(data.phone_directory) do -- add directory  entries (name -> number)
        menu[k] = {ch_entry,v}
      end
    end
  end
end

local function ch_sms(player,choice)
end

local function ch_service(player,choice)
end

local phone_menu = {name=lang.phone.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

phone_menu[lang.phone.directory.title()] = {ch_directory,lang.phone.directory.description()}
phone_menu[lang.phone.sms.title()] = {ch_sms,lang.phone.sms.description()}
phone_menu[lang.phone.service.title()] = {ch_service,lang.phone.service.description()}
