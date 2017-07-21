
-- module describing business system (company, money laundering)

local cfg = module("cfg/business")
local htmlEntities = module("lib/htmlEntities")
local lang = vRP.lang

local sanitizes = module("cfg/sanitizes")

-- sql
MySQL.createCommand("vRP/business_tables",[[
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

MySQL.createCommand("vRP/create_business","INSERT IGNORE INTO vrp_user_business(user_id,name,description,capital,laundered,reset_timestamp) VALUES(@user_id,@name,'',@capital,0,@time)")
MySQL.createCommand("vRP/delete_business","DELETE FROM vrp_user_business WHERE user_id = @user_id")
MySQL.createCommand("vRP/get_business","SELECT name,description,capital,laundered,reset_timestamp FROM vrp_user_business WHERE user_id = @user_id")
MySQL.createCommand("vRP/add_capital","UPDATE vrp_user_business SET capital = capital + @capital WHERE user_id = @user_id")
MySQL.createCommand("vRP/add_laundered","UPDATE vrp_user_business SET laundered = laundered + @laundered WHERE user_id = @user_id")
MySQL.createCommand("vRP/get_business_page","SELECT user_id,name,description,capital FROM vrp_user_business ORDER BY capital DESC LIMIT @b,@n")
MySQL.createCommand("vRP/reset_transfer","UPDATE vrp_user_business SET laundered = 0, reset_timestamp = @time WHERE user_id = @user_id")

-- init
MySQL.query("vRP/business_tables")

-- api

-- cbreturn user business data or nil
function vRP.getUserBusiness(user_id, cbr)
  local task = Task(cbr)

  if user_id ~= nil then
    MySQL.query("vRP/get_business", {user_id = user_id}, function(rows, affected)
      local business = rows[1]

      -- when a business is fetched from the database, check for update of the laundered capital transfer capacity
      if business and os.time() >= business.reset_timestamp+cfg.transfer_reset_interval*60 then
        MySQL.query("vRP/reset_transfer", {user_id = user_id, time = os.time()})
        business.laundered = 0
      end

      task({business})
    end)
  else
    task()
  end
end

-- close the business of an user
function vRP.closeBusiness(user_id)
  MySQL.query("vRP/close_business", {user_id = user_id})
end

-- business interaction

-- page start at 0
local function open_business_directory(player,page) -- open business directory with pagination system
  if page < 0 then page = 0 end

  local menu = {name=lang.business.directory.title().." ("..page..")",css={top="75px",header_color="rgba(240,203,88,0.75)"}}

  MySQL.query("vRP/get_business_page", {b = page*10, n = 10}, function(rows, affected)
    local count = 0
    for k,v in pairs(rows) do
      count = count+1
      local row = v

      if row.user_id ~= nil then
        -- get owner identity
        vRP.getUserIdentity(row.user_id,function(identity)
          if identity then
            menu[htmlEntities.encode(row.name)] = {function()end, lang.business.directory.info({row.capital,htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.registration,identity.phone})}
          end

          -- check end, open menu
          count = count-1
          if count == 0 then
            menu[lang.business.directory.dnext()] = {function() open_business_directory(player,page+1) end}
            menu[lang.business.directory.dprev()] = {function() open_business_directory(player,page-1) end}

            vRP.openMenu(player,menu)
          end
        end)
      end
    end
  end)
end

local function business_enter()
  local source = source

  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    -- build business menu
    local menu = {name=lang.business.title(),css={top="75px",header_color="rgba(240,203,88,0.75)"}}

    vRP.getUserBusiness(user_id, function(business)
      if business then -- have a business
        -- business info
        menu[lang.business.info.title()] = {function(player,choice)
        end, lang.business.info.info({htmlEntities.encode(business.name), business.capital, business.laundered})}

        -- add capital
        menu[lang.business.addcapital.title()] = {function(player,choice)
          vRP.prompt(player,lang.business.addcapital.prompt(),"",function(player,amount)
            amount = parseInt(amount)
            if amount > 0 then
              if vRP.tryPayment(user_id,amount) then
                MySQL.query("vRP/add_capital", {user_id = user_id, capital = amount})
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
          vRP.getUserBusiness(user_id, function(business) -- update business data
            local launder_left = math.min(business.capital-business.laundered,vRP.getInventoryItemAmount(user_id,"dirty_money")) -- compute launder capacity
            vRP.prompt(player,lang.business.launder.prompt({launder_left}),""..launder_left,function(player,amount)
              amount = parseInt(amount)
              if amount > 0 and amount <= launder_left then
                if vRP.tryGetInventoryItem(user_id,"dirty_money",amount,false) then
                  -- add laundered amount
                  MySQL.query("vRP/add_laundered", {user_id = user_id, laundered = amount})
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
          end)
        end,lang.business.launder.description()}
      else -- doesn't have a business
        menu[lang.business.open.title()] = {function(player,choice)
          vRP.prompt(player,lang.business.open.prompt_name({30}),"",function(player,name)
            if string.len(name) >= 2 and string.len(name) <= 30 then
              name = sanitizeString(name, sanitizes.business_name[1], sanitizes.business_name[2])
              vRP.prompt(player,lang.business.open.prompt_capital({cfg.minimum_capital}),""..cfg.minimum_capital,function(player,capital)
                capital = parseInt(capital)
                if capital >= cfg.minimum_capital then
                  if vRP.tryPayment(user_id,capital) then
                    MySQL.query("vRP/create_business", {
                      user_id = user_id,
                      name = name,
                      capital = capital,
                      time = os.time()
                    })

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
    end)
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

      vRP.setArea(source,"vRP:business"..k,x,y,z,1,1.5,business_enter,business_leave)
    end
  end
end


AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  -- first spawn, build business
  if first_spawn then
    build_client_business(source)
  end
end)


