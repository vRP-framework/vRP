-- this module describe the identity system

local htmlEntities = module("lib/htmlEntities")

local lang = vRP.lang

local Identity = class("Identity", vRP.Extension)

-- SUBCLASS

Identity.User = class("User")

-- STATIC

function Identity.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

-- METHODS

function Identity:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/identity")
  self.sanitizes = module("cfg/sanitizes")

  async(function()
    -- init sql
    vRP:prepare("vRP/identity_tables", [[
    CREATE TABLE IF NOT EXISTS vrp_character_identities(
      character_id INTEGER,
      registration VARCHAR(20),
      phone VARCHAR(20),
      firstname VARCHAR(50),
      name VARCHAR(50),
      age INTEGER,
      CONSTRAINT pk_character_identities PRIMARY KEY(character_id),
      CONSTRAINT fk_character_identities_characters FOREIGN KEY(character_id) REFERENCES vrp_characters(id) ON DELETE CASCADE,
      INDEX(registration),
      INDEX(phone)
    );
    ]])

    vRP:prepare("vRP/get_character_identity","SELECT * FROM vrp_character_identities WHERE character_id = @character_id")
    vRP:prepare("vRP/init_character_identity","INSERT IGNORE INTO vrp_character_identities(character_id,registration,phone,firstname,name,age) VALUES(@character_id,@registration,@phone,@firstname,@name,@age)")
    vRP:prepare("vRP/update_character_identity","UPDATE vrp_character_identities SET firstname = @firstname, name = @name, age = @age, registration = @registration, phone = @phone WHERE character_id = @character_id")
    vRP:prepare("vRP/get_characterbyreg","SELECT character_id FROM vrp_character_identities WHERE registration = @registration")
    vRP:prepare("vRP/get_characterbyphone","SELECT character_id FROM vrp_character_identities WHERE phone = @phone")

    vRP:execute("vRP/identity_tables")
  end)

  -- city hall menu
  local function m_identity(menu)
    local user = menu.user

    local firstname = user:prompt(lang.cityhall.identity.prompt_firstname(),"")
    if string.len(firstname) >= 2 and string.len(firstname) < 50 then
      firstname = sanitizeString(firstname, self.sanitizes.name[1], self.sanitizes.name[2])
      local name = user:prompt(lang.cityhall.identity.prompt_name(),"")
      if string.len(name) >= 2 and string.len(name) < 50 then
        name = sanitizeString(name, self.sanitizes.name[1], self.sanitizes.name[2])
        local age = user:prompt(lang.cityhall.identity.prompt_age(),"")
        age = parseInt(age)
        if age >= 16 and age <= 150 then
          if user:tryPayment(self.cfg.new_identity_cost) then
            local registration = self:generateRegistrationNumber()
            local phone = self:generatePhoneNumber()

            user.identity.firstname = firstname
            user.identity.name = name
            user.identity.age = age
            user.identity.registration = registration
            user.identity.phone = phone

            vRP:execute("vRP/update_character_identity", {
              character_id = user.cid,
              firstname = firstname,
              name = name,
              age = age,
              registration = registration,
              phone = phone
            })

            vRP:triggerEvent("characterIdentityUpdate", user)
            vRP.EXT.Base.remote._notify(user.source,lang.money.paid({self.cfg.new_identity_cost}))
          else
            vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
          end
        else
          vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("cityhall", function(menu)
    menu.title = lang.cityhall.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    menu:addOption(lang.cityhall.identity.title(), m_identity, lang.cityhall.identity.description({self.cfg.new_identity_cost}))
  end)

  -- add identity to main menu
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    -- generate identity content
    -- get address
    local address = menu.user.address
    local home = ""
    local number = ""
    if address then
      home = address.home
      number = address.number
    end
  
    local identity = menu.user.identity

    local content = lang.cityhall.menu.info({htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.age,identity.registration,identity.phone,home,number})
    menu:addOption(lang.cityhall.menu.title(), nil, content)
  end)
end

-- identity access (online and offline characters)
-- return identity or nil
function Identity:getIdentity(cid)
  local user = vRP.users_by_cid[cid]
  if user then
    return user.identity
  else
    local rows = vRP:query("vRP/get_character_identity", {character_id = cid})
    return rows[1]
  end
end

-- return character_id or nil
function Identity:getByRegistration(registration)
  local rows = vRP:query("vRP/get_characterbyreg", {registration = registration or ""})
  if #rows > 0 then
    return rows[1].character_id
  end
end

-- return character_id or nil
function Identity:getByPhone(phone)
  local rows = vRP:query("vRP/get_characterbyphone", {phone = phone or ""})
  if #rows > 0 then
    return rows[1].character_id
  end
end

-- return a unique registration number
function Identity:generateRegistrationNumber()
  local character_id
  local registration = ""
  -- generate registration number
  repeat
    registration = Identity.generateStringNumber("DDDLLL")
    character_id = self:getByRegistration(registration)
  until not character_id

  return registration
end

-- return a unique phone number
function Identity:generatePhoneNumber()
  local character_id = nil
  local phone = ""

  -- generate phone number
  repeat
    phone = Identity.generateStringNumber(self.cfg.phone_format)
    character_id = self:getByPhone(phone)
  until not character_id

  return phone
end

-- EVENT

Identity.event = {}

function Identity.event:characterLoad(user)
  -- load identity
  local rows = vRP:query("vRP/get_character_identity", {character_id = user.cid})
  if #rows > 0 then -- loaded
    user.identity = rows[1]
  else -- create
    user.identity = {
      registration = self:generateRegistrationNumber(),
      phone = self:generatePhoneNumber(),
      firstname = self.cfg.random_first_names[math.random(1,#self.cfg.random_first_names)],
      name = self.cfg.random_last_names[math.random(1,#self.cfg.random_last_names)],
      age = math.random(18,40)
    }

    vRP:execute("vRP/init_character_identity", {
      character_id = user.cid,
      registration = user.identity.registration,
      phone = user.identity.phone,
      firstname = user.identity.firstname,
      name = user.identity.name,
      age = user.identity.age
    })
  end

  vRP:triggerEvent("characterIdentityUpdate", user)
end

function Identity.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- build city hall
    local menu
    local function enter(user)
      menu = user:openMenu("cityhall")
    end

    local function leave(user)
      user:closeMenu(menu)
    end

    local x,y,z = table.unpack(self.cfg.city_hall)

    vRP.EXT.Map.remote._addBlip(user.source,x,y,z,self.cfg.blip[1],self.cfg.blip[2],lang.cityhall.title())
    vRP.EXT.Map.remote._addMarker(user.source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
    user:setArea("vRP:cityhall",x,y,z,1,1.5,enter,leave)
  end
end

function Identity.event:characterIdentityUpdate(user)
  -- send registration number to client at spawn
  self.remote._setRegistrationNumber(user.source, user.identity.registration)
end

vRP:registerExtension(Identity)
