-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.business then return end

local htmlEntities = module("lib/htmlEntities")
local lang = vRP.lang

-- module describing business system (company, money laundering)
local Business = class("Business", vRP.Extension)

-- PRIVATE METHODS

-- menu: commerce chamber directory
local function menu_commerce_chamber_directory(self)
  local function m_page(menu, page)
    local user = menu.user
    menu.data.page = page
    user:actualizeMenu()
  end

  vRP.EXT.GUI:registerMenuBuilder("commerce_chamber.directory", function(menu)
    local user = menu.user
    local page = menu.data.page
    if page < 0 then page = 0 end

    menu.title = lang.business.directory.title().." ("..page..")"
    menu.css.header_color = "rgba(240,203,88,0.75)"

    local rows = vRP:query("vRP/get_business_page", {b = page*10, n = 10})
    for _,row in ipairs(rows) do
      -- get owner identity
      local identity = vRP.EXT.Identity:getIdentity(row.character_id)
      if identity then
        menu:addOption(htmlEntities.encode(row.name), nil, lang.business.directory.info({row.capital,htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.registration,identity.phone}))
      end
    end

    menu:addOption(lang.business.directory.dnext(), m_page, nil, page+1)
    if page > 0 then
      menu:addOption(lang.business.directory.dprev(), m_page, nil, page-1)
    end
  end)
end

-- menu: commerce chamber
local function menu_commerce_chamber(self)
  local function m_add_capital(menu)
    local user = menu.user

    local amount = parseInt(user:prompt(lang.business.addcapital.prompt(),""))
    if amount > 0 then
      if user:tryPayment(amount) then
        vRP:execute("vRP/add_capital", {character_id = user.cid, capital = amount})
        vRP.EXT.Base.remote._notify(user.source,lang.business.addcapital.added({amount}))
        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  local function m_launder(menu)
    local user = menu.user

    local business = self:getBusiness(user.cid) -- update business data
    -- compute launder capacity
    local launder_left = math.min(business.capital-business.laundered,user:getItemAmount("dirty_money")) 
    local amount = parseInt(user:prompt(lang.business.launder.prompt({launder_left}),""..launder_left))
    if amount > 0 and amount <= launder_left then
      if user:tryTakeItem("dirty_money",amount,nil,true) then
        -- add laundered amount
        vRP:execute("vRP/add_laundered", {character_id = user.cid, laundered = amount})
        -- give laundered money
        user:giveWallet(amount)
        vRP.EXT.Base.remote._notify(user.source,lang.business.launder.laundered({amount}))
        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source,lang.business.launder.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  local function m_open(menu)
    local user = menu.user

    local name = user:prompt(lang.business.open.prompt_name({30}),"")
    if string.len(name) >= 2 and string.len(name) <= 30 then
      name = sanitizeString(name, self.sanitizes.business_name[1], self.sanitizes.business_name[2])
      local capital = parseInt(user:prompt(lang.business.open.prompt_capital({self.cfg.minimum_capital}),""..self.cfg.minimum_capital))
      if capital >= self.cfg.minimum_capital then
        if user:tryPayment(capital) then
          vRP:execute("vRP/create_business", {
            character_id = user.cid,
            name = name,
            capital = capital,
            time = os.time()
          })

          vRP.EXT.Base.remote._notify(user.source,lang.business.open.created())
          user:actualizeMenu()
        else
          vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_name())
    end
  end

  local function m_directory(menu)
    local smenu = menu.user:openMenu("commerce_chamber.directory", {page = 0})
    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  vRP.EXT.GUI:registerMenuBuilder("commerce_chamber", function(menu)
    menu.title = lang.business.title()
    menu.css.header_color = "rgba(240,203,88,0.75)"

    local user = menu.user

    local business = self:getBusiness(user.cid)
    if business then -- have a business
      -- business info
      menu:addOption(lang.business.info.title(), nil, lang.business.info.info({htmlEntities.encode(business.name), business.capital, business.laundered}))

      -- add capital
      menu:addOption(lang.business.addcapital.title(), m_add_capital, lang.business.addcapital.description())

      -- money laundered
      menu:addOption(lang.business.launder.title(), m_launder, lang.business.launder.description())
    else -- doesn't have a business
      menu:addOption(lang.business.open.title(), m_open, lang.business.open.description({self.cfg.minimum_capital}))
    end

    -- business list
    menu:addOption(lang.business.directory.title(), m_directory, lang.business.directory.description())
  end)
end

-- METHODS

function Business:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/business")
  self.sanitizes = module("cfg/sanitizes")

  self:log(#self.cfg.commerce_chambers.." commerce chambers")

  async(function()
    -- sql
    vRP:prepare("vRP/business_tables",[[
    CREATE TABLE IF NOT EXISTS vrp_character_business(
      character_id INTEGER,
      name VARCHAR(30),
      description TEXT,
      capital INTEGER,
      laundered INTEGER,
      reset_timestamp INTEGER,
      CONSTRAINT pk_character_business PRIMARY KEY(character_id),
      CONSTRAINT fk_character_business_characters FOREIGN KEY(character_id) REFERENCES vrp_characters(id) ON DELETE CASCADE
    );
    ]])

    vRP:prepare("vRP/create_business","INSERT IGNORE INTO vrp_character_business(character_id,name,description,capital,laundered,reset_timestamp) VALUES(@character_id,@name,'',@capital,0,@time)")
    vRP:prepare("vRP/delete_business","DELETE FROM vrp_character_business WHERE character_id = @character_id")
    vRP:prepare("vRP/get_business","SELECT name,description,capital,laundered,reset_timestamp FROM vrp_character_business WHERE character_id = @character_id")
    vRP:prepare("vRP/add_capital","UPDATE vrp_character_business SET capital = capital + @capital WHERE character_id = @character_id")
    vRP:prepare("vRP/add_laundered","UPDATE vrp_character_business SET laundered = laundered + @laundered WHERE character_id = @character_id")
    vRP:prepare("vRP/get_business_page","SELECT character_id,name,description,capital FROM vrp_character_business ORDER BY capital DESC LIMIT @b,@n")
    vRP:prepare("vRP/reset_transfer","UPDATE vrp_character_business SET laundered = 0, reset_timestamp = @time WHERE character_id = @character_id")

    -- init
    vRP:execute("vRP/business_tables")
  end)

  -- items
  vRP.EXT.Inventory:defineItem("dirty_money", lang.item.dirty_money.name(), lang.item.dirty_money.description(), nil, 0)

  -- menu

  menu_commerce_chamber_directory(self)
  menu_commerce_chamber(self)

  vRP.EXT.GUI:registerMenuBuilder("identity", function(menu)
    local business = self:getBusiness(menu.data.cid)

    if business then
      menu:addOption(lang.business.identity.title(), nil, lang.business.identity.info({htmlEntities.encode(business.name), business.capital}))
    end
  end)
end


-- return character business data or nil
function Business:getBusiness(character_id)
  local rows = vRP:query("vRP/get_business", {character_id = character_id})
  local business = rows[1]

  -- when a business is fetched from the database, check for update of the laundered capital transfer capacity
  if business and os.time() >= business.reset_timestamp+self.cfg.transfer_reset_interval*60 then
    vRP:execute("vRP/reset_transfer", {character_id = character_id, time = os.time()})
    business.laundered = 0
  end

  return business
end

-- close the business of a character
function Business:closeBusiness(character_id)
  vRP:execute("vRP/delete_business", {character_id = character_id})
end

-- EVENT
Business.event = {}

function Business.event:playerSpawn(user, first_spawn)
  if first_spawn then
    for k,v in pairs(self.cfg.commerce_chambers) do
      local x,y,z = table.unpack(v)

      local menu
      local function enter(user)
        menu = user:openMenu("commerce_chamber")
      end

      local function leave(user)
        if menu then
          user:closeMenu(menu)
        end
      end

      local ment = clone(self.cfg.commerce_chamber_map_entity)
      ment[2].title = lang.business.title()
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

      user:setArea("vRP:business:"..k,x,y,z,1,1.5,enter,leave)
    end
  end
end

vRP:registerExtension(Business)
