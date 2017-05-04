local htmlEntities = require("resources/vrp/lib/htmlEntities")

local cfg = require("resources/vrp/cfg/identity")

-- this module describe the identity system

-- init sql
local q_init = vRP.sql:prepare([[
CREATE TABLE IF NOT EXISTS vrp_user_identities(
  user_id INTEGER,
  registration VARCHAR(50),
  firstname VARCHAR(50),
  name VARCHAR(50),
  age INTEGER,
  CONSTRAINT pk_user_identities PRIMARY KEY(user_id),
  CONSTRAINT fk_user_identities_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE,
  INDEX(registration)
);
]])

q_init:execute()

local q_get_user = vRP.sql:prepare("SELECT * FROM vrp_user_identities WHERE user_id = @user_id")
local q_init_user = vRP.sql:prepare("INSERT IGNORE INTO vrp_user_identities(user_id,registration,firstname,name,age) VALUES(@user_id,@registration,@firstname,@name,@age)")
local q_update_user = vRP.sql:prepare("UPDATE vrp_user_identities SET firstname = @firstname, name = @name, age = @age, registration = @registration WHERE user_id = @user_id")
local q_get_userbyreg = vRP.sql:prepare("SELECT user_id FROM vrp_user_identities WHERE registration = @registration")

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

-- generate a unique registration number (DDDLLL, D => digit, L => letter)
function vRP.generateRegistrationNumber()
  local exists = true
  local registration = nil 

  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  while exists do
    -- generate registration number
    registration = string.char(abyte+math.random(0,25),abyte+math.random(0,25),abyte+math.random(0,25))
    registration = registration..string.char(zbyte+math.random(0,9),zbyte+math.random(0,9),zbyte+math.random(0,9))

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

function vRP.updateIdentity(user_id, firstname, name, age)
  q_update_user:bind("@user_id",user_id)

  if string.len(firstname) >= 50 then firstname = string.sub(firstname,1,50) end
  if string.len(name) >= 50 then name = string.sub(name,1,50) end

  q_update_user:bind("@firstname",name)
  q_update_user:bind("@name",name)
  q_update_user:bind("@age",age)

  q_update_user:execute()
end

-- events, init user identity at connection
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  local identity = vRP.getUserIdentity(user_id)
  if identity == nil then
    q_init_user:bind("@user_id",user_id) -- create if not exists player identity
    q_init_user:bind("@registration",vRP.generateRegistrationNumber())
    q_init_user:bind("@firstname","John")
    q_init_user:bind("@name","Smith")
    q_init_user:bind("@age",math.random(25,40))
    q_init_user:execute()
  end
end)

-- city hall menu

local cityhall_menu = {name="City Hall",css={top="75px", header_color="rgba(0,125,255,0.75)"}}

local function ch_identity(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRP.prompt(player,"Enter your first name: ","",function(player,firstname)
      if string.len(firstname) >= 2 and string.len(firstname) < 50 then
        vRP.prompt(player,"Enter your name: ","",function(player,name)
          if string.len(name) >= 2 and string.len(name) < 50 then
            vRP.prompt(player,"Enter your age: ","",function(player,age)
              age = tonumber(age)
              if age >= 16 and age <= 150 then
                if vRP.tryPayment(user_id,cfg.new_identity_cost) then
                  local registration = vRP.generateRegistrationNumber()

                  q_update_user:bind("@user_id",user_id)
                  q_update_user:bind("@firstname",firstname)
                  q_update_user:bind("@name",name)
                  q_update_user:bind("@age",age)
                  q_update_user:bind("@registration",registration)
                  q_update_user:execute()

                  vRPclient.notify(player,{"Paid "..cfg.new_identity_cost.." $"})
                else
                  vRPclient.notify(player,{"Not enough money."})
                end
              else
                vRPclient.notify(player,{"Bad age."})
              end
            end)
          else
            vRPclient.notify(player,{"Bad name."})
          end
        end)
      else
        vRPclient.notify(player,{"Bad first name."})
      end
    end)
  end
end

cityhall_menu["New identity"] = {ch_identity,"Create a new identity, cost "..cfg.new_identity_cost.." $."}

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

    vRPclient.addBlip(source,{x,y,z,181,4,"City Hall"})
    vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

    vRP.setArea(source,"vRP:cityhall",x,y,z,1,1.5,cityhall_enter,cityhall_leave)
  end
end

AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    -- send registration number to client at spawn
    local identity = vRP.getUserIdentity(user_id)
    if identity then
      vRPclient.setRegistrationNumber(source,{identity.registration or "000AAA"})
    end

    -- first spawn, build city hall
    if vRP.isFirstSpawn(user_id) then
      build_client_cityhall(source)
    end
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
      local content = "<em>Name: </em>"..htmlEntities.encode(identity.name).."<br /><em>First name: </em>"..htmlEntities.encode(identity.firstname).."<br /><em>Age: </em>"..identity.age.."<br /><em>Registration n°: </em>"..identity.registration
      local choices = {}
      choices["Identity"] = {function()end, content}

      vRP.buildMainMenu(player,choices)
    end
  end
end)
