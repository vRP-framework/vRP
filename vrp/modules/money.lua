
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
local config = require("resources/vrp/cfg/money")
q_init_user:bind("@wallet",config.open_wallet)
q_init_user:bind("@bank",config.open_bank)

-- API

-- get money
function vRP.getMoney(user_id)
  q_get_wallet:bind("@user_id",user_id)
  local r = q_get_wallet:query()
  if r:fetch() then
    local v = r:getValue(0)
    r:close()
    return v
  else
    return 0
  end
end

-- set money
function vRP.setMoney(user_id,value)
  q_set_wallet:bind("@user_id",user_id)
  q_set_wallet:bind("@wallet",value)
  q_set_wallet:execute()

  -- update client display
  local source = vRP.getUserSource(user_id)
  if source ~= nil then
    vRPclient.setProgressBarText(source,{"vRP:money",value.." $"})
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
  if r:fetch() then
    local v = r:getValue(0)
    r:close()
    return v
  else
    return 0
  end
end

-- set bank money
function vRP.setBankMoney(user_id,value)
  q_set_bank:bind("@user_id",user_id)
  q_set_bank:bind("@bank",value)
  q_set_bank:execute()
end

-- give bank money
function vRP.giveBankMoney(user_id,amount)
  local money = vRP.getBankMoney(user_id)
  vRP.setBankMoney(user_id,money+amount)
end

-- try a withdraw
-- return true or false (withdrawn if true)
function vRP.tryWithdraw(user_id,amount)
  local money = vRP.getBankMoney(user_id)
  if money >= amount then
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
  if vRP.tryPayment(user_id,amount) then
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

-- temporary money display
AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRPclient.setProgressBar(source,{"vRP:money","botright",vRP.getMoney(user_id).." $",0,0,0,100})
  end
end)
