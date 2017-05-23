local lang = vRP.lang

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

local q_init = vRP.sql:prepare([[
CREATE TABLE IF NOT EXISTS vrp_user_moneys(
  user_id INTEGER,
  wallet INTEGER,
  bank INTEGER,
  CONSTRAINT pk_user_moneys PRIMARY KEY(user_id),
  CONSTRAINT fk_user_moneys_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);
]])
q_init:execute()

local q_init_user = vRP.sql:prepare("INSERT IGNORE INTO vrp_user_moneys(user_id,wallet,bank) VALUES(@user_id,@wallet,@bank)")
local q_get_wallet = vRP.sql:prepare("SELECT wallet FROM vrp_user_moneys WHERE user_id = @user_id")
local q_set_wallet = vRP.sql:prepare("UPDATE vrp_user_moneys SET wallet = @wallet WHERE user_id = @user_id")
local q_get_bank = vRP.sql:prepare("SELECT bank FROM vrp_user_moneys WHERE user_id = @user_id")
local q_set_bank = vRP.sql:prepare("UPDATE vrp_user_moneys SET bank = @bank WHERE user_id = @user_id")


-- load config
local cfg = require("resources/vrp/cfg/money")
q_init_user:bind("@wallet",cfg.open_wallet)
q_init_user:bind("@bank",cfg.open_bank)

-- API

-- get money
function vRP.getMoney(user_id)
  q_get_wallet:bind("@user_id",user_id)
  local r = q_get_wallet:query()
  local v = 0
  if r:fetch() then
    v = r:getValue(0)
  end

  r:close()
  return v
end

-- set money
function vRP.setMoney(user_id,value)
  q_set_wallet:bind("@user_id",user_id)
  q_set_wallet:bind("@wallet",value)
  q_set_wallet:execute()

  -- update client display
  local source = vRP.getUserSource(user_id)
  if source ~= nil then
    vRPclient.setDivContent(source,{"money",lang.money.display({value})})
  end
end

-- try a payment
-- return true or false (debited if true)
function vRP.tryPayment(user_id,amount)
  local money = vRP.getMoney(user_id)
  if money >= amount then
    vRP.setMoney(user_id,money-amount)
    return true
  else
    return false
  end
end

-- give money
function vRP.giveMoney(user_id,amount)
  local money = vRP.getMoney(user_id)
  vRP.setMoney(user_id,money+amount)
end

-- get bank money
function vRP.getBankMoney(user_id)
  q_get_bank:bind("@user_id",user_id)
  local r = q_get_bank:query()
  local v = 0
  if r:fetch() then
    v = r:getValue(0)
  end

  r:close()
  return v
end

-- set bank money
function vRP.setBankMoney(user_id,value)
  q_set_bank:bind("@user_id",user_id)
  q_set_bank:bind("@bank",value)
  q_set_bank:execute()
end

-- give bank money
function vRP.giveBankMoney(user_id,amount)
  if amount > 0 then
    local money = vRP.getBankMoney(user_id)
    vRP.setBankMoney(user_id,money+amount)
  end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function vRP.tryWithdraw(user_id,amount)
  local money = vRP.getBankMoney(user_id)
  if amount > 0 and money >= amount then
    vRP.setBankMoney(user_id,money-amount)
    vRP.giveMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true or false (deposited if true)
function vRP.tryDeposit(user_id,amount)
  if amount > 0 and vRP.tryPayment(user_id,amount) then
    vRP.giveBankMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- events, init user account at connection
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  q_init_user:bind("@user_id",user_id) -- create if not exists player money account
  q_init_user:execute()
end)

-- money hud
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- add money display
    vRPclient.setDiv(source,{"money",cfg.display_css,lang.money.display({vRP.getMoney(user_id)})})
  end
end)

local function ch_give(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId(nplayer)
        if nuser_id ~= nil then
          -- prompt number
          vRP.prompt(player,lang.money.give.prompt(),"",function(player,amount)
            local amount = tonumber(amount)
            if amount > 0 and vRP.tryPayment(user_id,amount) then
              vRP.giveMoney(nuser_id,amount)
              vRPclient.notify(player,{lang.money.given({amount})})
              vRPclient.notify(nplayer,{lang.money.received({amount})})
            else
              vRPclient.notify(player,{lang.money.not_enough()})
            end
          end)
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end

-- add player give money to main menu
AddEventHandler("vRP:buildMainMenu",function(player) 
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local choices = {}
    choices[lang.money.give.title()] = {ch_give, lang.money.give.description()}

    vRP.buildMainMenu(player,choices)
  end
end)
