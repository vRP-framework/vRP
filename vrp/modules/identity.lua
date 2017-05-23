local htmlEntities = require("resources/vrp/lib/htmlEntities")

local cfg = require("resources/vrp/cfg/identity")
local lang = vRP.lang

-- this module describe the identity system

-- init sql
local q_init = vRP.sql:prepare([[
CREATE TABLE IF NOT EXISTS vrp_user_identities(
  user_id INTEGER,
  registration VARCHAR(20),
  phone VARCHAR(20),
  firstname VARCHAR(50),
  name VARCHAR(50),
  age INTEGER,
  CONSTRAINT pk_user_identities PRIMARY KEY(user_id),
  CONSTRAINT fk_user_identities_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE,
  INDEX(registration),
  INDEX(phone)
);
]])

q_init:execute()

local q_get_user = vRP.sql:prepare("SELECT * FROM vrp_user_identities WHERE user_id = @user_id")
local q_init_user = vRP.sql:prepare("INSERT IGNORE INTO vrp_user_identities(user_id,registration,phone,firstname,name,age) VALUES(@user_id,@registration,@phone,@firstname,@name,@age)")
local q_update_user = vRP.sql:prepare("UPDATE vrp_user_identities SET firstname = @firstname, name = @name, age = @age, registration = @registration, phone = @phone WHERE user_id = @user_id")
local q_get_userbyreg = vRP.sql:prepare("SELECT user_id FROM vrp_user_identities WHERE registration = @registration")
local q_get_userbyphone = vRP.sql:prepare("SELECT user_id FROM vrp_user_identities WHERE phone = @phone")

-- api

-- get user identity
function vRP.getUserIdentity(user_id)
  local identity = nil

  q_get_user:bind("@user_id",user_id)
  local r = q_get_user:query()
  if r:fetch() then
    identity = r:getRow()
  end

  r:close()

  return identity
end

-- return user_id by registration or nil
function vRP.getUserByRegistration(registration)
  local user_id = nil

  q_get_userbyreg:bind("@registration",registration)
  local r = q_get_userbyreg:query()
  if r:fetch() then
    user_id = r:getValue(0)
  end
  r:close()

  return user_id
end

-- return user_id by phone or nil
function vRP.getUserByPhone(phone)
  local user_id = nil

  q_get_userbyphone:bind("@phone",phone)
  local r = q_get_userbyphone:query()
  if r:fetch() then
    user_id = r:getValue(0)
  end
  r:close()

  return user_id
end

function vRP.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=0,#format-1 do
    if format[i] == "D" then number = number..string.char(zbyte+math.random(0,9)) 
    elseif format[i] == "L" then number = number..string.char(abyte+math.random(0,25)) 
    else number = number..format[i] end
  end

  return number
end

-- generate a unique registration number
function vRP.generateRegistrationNumber()
  local exists = true
  local registration = nil 

  while exists do
    -- generate registration number
    registration = vRP.generateStringNumber("DDDLLL")

    q_get_userbyreg:bind("@registration",registration)
    exists = false
    local r = q_get_userbyreg:query()
    if r:fetch() then
      exists = true
    end
    r:close()
  end

  return registration
end

-- generate a unique phone number (0DDDDD, D => digit)
function vRP.generatePhoneNumber()
  local exists = true
  local phone = nil 

  while exists do
    -- generate registration number
    phone = vRP.generateStringNumber(cfg.phone_format)

    q_get_userbyphone:bind("@phone",phone)
    exists = false
    local r = q_get_userbyphone:query()
    if r:fetch() then
      exists = true
    end
    r:close()
  end

  return phone
end

-- events, init user identity at connection
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  local identity = vRP.getUserIdentity(user_id)
  if identity == nil then
    q_init_user:bind("@user_id",user_id) -- create if not exists player identity
    q_init_user:bind("@registration",vRP.generateRegistrationNumber())
    q_init_user:bind("@phone",vRP.generatePhoneNumber())
    q_init_user:bind("@firstname","John")
    q_init_user:bind("@name","Smith")
    q_init_user:bind("@age",math.random(25,40))
    q_init_user:execute()
  end
end)

-- city hall menu

local cityhall_menu = {name=lang.cityhall.title(),css={top="75px", header_color="rgba(0,125,255,0.75)"}}

local function ch_identity(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRP.prompt(player,lang.cityhall.identity.prompt_firstname(),"",function(player,firstname)
      if string.len(firstname) >= 2 and string.len(firstname) < 50 then
        vRP.prompt(player,lang.cityhall.identity.prompt_name(),"",function(player,name)
          if string.len(name) >= 2 and string.len(name) < 50 then
            vRP.prompt(player,lang.cityhall.identity.prompt_age(),"",function(player,age)
              age = tonumber(age)
              if age >= 16 and age <= 150 then
                if vRP.tryPayment(user_id,cfg.new_identity_cost) then
                  local registration = vRP.generateRegistrationNumber()
                  local phone = vRP.generatePhoneNumber()

                  q_update_user:bind("@user_id",user_id)
                  q_update_user:bind("@firstname",firstname)
                  q_update_user:bind("@name",name)
                  q_update_user:bind("@age",age)
                  q_update_user:bind("@registration",registration)
                  q_update_user:bind("@phone",phone)
                  q_update_user:execute()

                  -- update client registration
                  vRPclient.setRegistrationNumber(player,{registration})

                  vRPclient.notify(player,{lang.money.paid({cfg.new_identity_cost})})
                else
                  vRPclient.notify(player,{lang.money.not_enough()})
                end
              else
                vRPclient.notify(player,{lang.common.invalid_value()})
              end
            end)
          else
            vRPclient.notify(player,{lang.common.invalid_value()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.invalid_value()})
      end
    end)
  end
end

cityhall_menu[lang.cityhall.identity.title()] = {ch_identity,lang.cityhall.identity.description({cfg.new_identity_cost})}

local function cityhall_enter()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.openMenu(source,cityhall_menu) 
  end
end

local function cityhall_leave()
  vRP.closeMenu(source)
end

local function build_client_cityhall(source) -- build the city hall area/marker/blip
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    local x,y,z = table.unpack(cfg.city_hall)

    vRPclient.addBlip(source,{x,y,z,cfg.blip[1],cfg.blip[2],lang.cityhall.title()})
    vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

    vRP.setArea(source,"vRP:cityhall",x,y,z,1,1.5,cityhall_enter,cityhall_leave)
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  -- send registration number to client at spawn
  local identity = vRP.getUserIdentity(user_id)
  if identity then
    vRPclient.setRegistrationNumber(source,{identity.registration or "000AAA"})
  end

  -- first spawn, build city hall
  if first_spawn then
    build_client_cityhall(source)
  end
end)

-- player identity menu

-- add identity to main menu
AddEventHandler("vRP:buildMainMenu",function(player) 
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local identity = vRP.getUserIdentity(user_id)

    if identity then
      -- generate identity content
      -- get address
      local address = vRP.getUserAddress(user_id)
      local home = ""
      local number = ""
      if address then
        home = address.home
        number = address.number
      end

      local content = lang.cityhall.menu.info({htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.age,identity.registration,identity.phone,home,number})
      local choices = {}
      choices[lang.cityhall.menu.title()] = {function()end, content}

      vRP.buildMainMenu(player,choices)
    end
  end
end)
