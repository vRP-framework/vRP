
-- module describing business system (company, money laundering)

local cfg = require("resources/vrp/cfg/business")
local htmlEntities = require("resources/vrp/lib/htmlEntities")
local lang = vRP.lang

-- sql
local q_init = vRP.sql:prepare([[
CREATE TABLE IF NOT EXISTS vrp_user_business(
  user_id INTEGER,
  name VARCHAR(30),
  description TEXT,
  capital INTEGER,
  laundered INTEGER,
  reset_timestamp INTEGER,
  CONSTRAINT pk_user_business PRIMARY KEY(user_id),
  CONSTRAINT fk_user_business_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);
]])
q_init:execute()

local q_create_business = vRP.sql:prepare("INSERT IGNORE INTO vrp_user_business(user_id,name,description,capital,laundered,reset_timestamp) VALUES(@user_id,@name,'',@capital,0,@time)")
local q_delete_business = vRP.sql:prepare("DELETE FROM vrp_user_business WHERE user_id = @user_id")
local q_get_business = vRP.sql:prepare("SELECT name,description,capital,laundered,reset_timestamp FROM vrp_user_business WHERE user_id = @user_id")
local q_add_capital = vRP.sql:prepare("UPDATE vrp_user_business SET capital = capital + @capital WHERE user_id = @user_id")
local q_add_laundered = vRP.sql:prepare("UPDATE vrp_user_business SET laundered = laundered + @laundered WHERE user_id = @user_id")
local q_get_page = vRP.sql:prepare("SELECT user_id,name,description,capital FROM vrp_user_business ORDER BY capital DESC LIMIT @b,@n")
local q_reset_transfer = vRP.sql:prepare("UPDATE vrp_user_business SET laundered = 0, reset_timestamp = @time WHERE user_id = @user_id")

-- api

-- get user business data or nil
function vRP.getUserBusiness(user_id)
  local business = nil
  if user_id ~= nil then
    q_get_business:bind("@user_id",user_id)
    local r = q_get_business:query()
    if r:fetch() then
      business = r:getRow()
    end

    r:close()
  end

  -- when a business is fetched from the database, check for update of the laundered capital transfer capacity
  if business and os.time() >= business.reset_timestamp+cfg.transfer_reset_interval*60 then
    q_reset_transfer:bind("@user_id",user_id)
    q_reset_transfer:bind("@time",os.time())
    q_reset_transfer:execute()

    business.laundered = 0
  end

  return business
end

-- close the business of an user
function vRP.closeBusiness(user_id)
  q_delete_business:bind("@user_id",user_id)
  q_delete_business:execute()
end

-- business interaction

-- page start at 0
local function open_business_directory(player,page) -- open business directory with pagination system
  if page < 0 then page = 0 end

  local menu = {name=lang.business.directory.title().." ("..page..")",css={top="75px",header_color="rgba(240,203,88,0.75)"}}

  q_get_page:bind("@b",page*10)
  q_get_page:bind("@n",10)
  local r = q_get_page:query()
  r = r:toTable()
  for k,v in pairs(r) do
    local row = v

    if row.user_id ~= nil then
      -- get owner identity
      local identity = vRP.getUserIdentity(row.user_id)

      if identity then
        menu[htmlEntities.encode(row.name)] = {function()end, lang.business.directory.info({row.capital,htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.registration,identity.phone})}
      end
    end
  end

  menu[lang.business.directory.dnext()] = {function() open_business_directory(player,page+1) end}
  menu[lang.business.directory.dprev()] = {function() open_business_directory(player,page-1) end}

  vRP.openMenu(player,menu)
end

local function business_enter()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    -- build business menu
    local menu = {name=lang.business.title(),css={top="75px",header_color="rgba(240,203,88,0.75)"}}

    local business = vRP.getUserBusiness(user_id)
    if business then -- have a business
      -- business info
      menu[lang.business.info.title()] = {function(player,choice)
      end, lang.business.info.info({htmlEntities.encode(business.name), business.capital, business.laundered})}

      -- add capital
      menu[lang.business.addcapital.title()] = {function(player,choice)
        vRP.prompt(player,lang.business.addcapital.prompt(),"",function(player,amount)
          amount = tonumber(amount)
          if amount > 0 then
            if vRP.tryPayment(user_id,amount) then
              q_add_capital:bind("@user_id",user_id)
              q_add_capital:bind("@capital",amount)
              q_add_capital:execute()

              vRPclient.notify(player,{lang.business.addcapital.added({amount})})
            else
              vRPclient.notify(player,{lang.money.not_enough()})
            end
          else
            vRPclient.notify(player,{lang.common.invalid_value()})
          end
        end)
      end,lang.business.addcapital.description()}

      -- money laundered
      menu[lang.business.launder.title()] = {function(player,choice)
        business = vRP.getUserBusiness(user_id) -- update business data
        local launder_left = math.min(business.capital-business.laundered,vRP.getInventoryItemAmount(user_id,"dirty_money")) -- compute launder capacity
        vRP.prompt(player,lang.business.launder.prompt({launder_left}),""..launder_left,function(player,amount)
          amount = tonumber(amount)
          if amount > 0 and amount <= launder_left then
            if vRP.tryGetInventoryItem(user_id,"dirty_money",amount) then
              -- add laundered amount
              q_add_laundered:bind("@user_id",user_id)
              q_add_laundered:bind("@laundered",amount)
              q_add_laundered:execute()

              -- give laundered money
              vRP.giveMoney(user_id,amount)
              vRPclient.notify(player,{lang.business.launder.laundered({amount})})
            else
              vRPclient.notify(player,{lang.business.launder.not_enough()})
            end
          else
            vRPclient.notify(player,{lang.common.invalid_value()})
          end
        end)
      end,lang.business.launder.description()}

    else -- doesn't have a business
      menu[lang.business.open.title()] = {function(player,choice)
        vRP.prompt(player,lang.business.open.prompt_name({30}),"",function(player,name)
          if string.len(name) >= 2 and string.len(name) <= 30 then
            vRP.prompt(player,lang.business.open.prompt_capital({cfg.minimum_capital}),""..cfg.minimum_capital,function(player,capital)
              capital = tonumber(capital)
              if capital >= cfg.minimum_capital then
                if vRP.tryPayment(user_id,capital) then
                  q_create_business:bind("@user_id",user_id)
                  q_create_business:bind("@name",name)
                  q_create_business:bind("@capital",capital)
                  q_create_business:bind("@time",os.time())
                  q_create_business:execute()
                  vRPclient.notify(player,{lang.business.open.created()})
                  vRP.closeMenu(player) -- close the menu to force update business info
                else
                  vRPclient.notify(player,{lang.money.not_enough()})
                end
              else
                vRPclient.notify(player,{lang.common.invalid_value()})
              end
            end)
          else
            vRPclient.notify(player,{lang.common.invalid_name()})
          end
        end)
      end,lang.business.open.description({cfg.minimum_capital})}
    end

    -- business list
    menu[lang.business.directory.title()] = {function(player,choice)
      open_business_directory(player,0)
    end,lang.business.directory.description()}

    -- open menu
    vRP.openMenu(source,menu) 
  end
end

local function business_leave()
  vRP.closeMenu(source)
end

local function build_client_business(source) -- build the city hall area/marker/blip
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(cfg.commerce_chambers) do
      local x,y,z = table.unpack(v)

      vRPclient.addBlip(source,{x,y,z,cfg.blip[1],cfg.blip[2],lang.business.title()})
      vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

      vRP.setArea(source,"vRP:business",x,y,z,1,1.5,business_enter,business_leave)
    end
  end
end


AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  -- first spawn, build business
  if first_spawn then
    build_client_business(source)
  end
end)


