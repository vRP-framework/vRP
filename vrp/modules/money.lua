local lang = vRP.lang

-- Money module, wallet/bank
local Money = class("Money", vRP.Extension)

-- SUBCLASS

Money.User = class("User")

function Money.User:getWallet()
  return self.cdata.wallet
end

function Money.User:getBank()
  return self.cdata.bank
end

function Money.User:setWallet(amount)
  if self.cdata.wallet ~= amount then
    self.cdata.wallet = amount
    vRP:triggerEvent("playerMoneyUpdate", self)
  end
end

function Money.User:setBank(amount)
  if self.cdata.bank ~= amount then
    self.cdata.bank = amount
    vRP:triggerEvent("playerMoneyUpdate", self)
  end
end

function Money.User:giveBank(amount)
  self:setBank(self:getBank()+math.abs(amount))
end

function Money.User:giveWallet(amount)
  self:setWallet(self:getWallet()+math.abs(amount))
end

-- try a payment (with wallet)
-- return true if debited or false
function Money.User:tryPayment(amount)
  local money = self:getWallet()
  if amount >= 0 and money >= amount then
    self:setWallet(money-amount)
    return true
  else
    return false
  end
end

-- try a withdraw (from bank)
-- return true if withdrawn or false
function Money.User:tryWithdraw(amount)
  local money = self:getBank()
  if amount >= 0 and money >= amount then
    self:setBank(money-amount)
    self:giveWallet(amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true if deposited or false
function Money.User:tryDeposit(amount)
  if self:tryPayment(amount) then
    self:giveBank(amount)
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- return true if debited or false
function Money.User:tryFullPayment(amount)
  local money = self:getWallet()
  if money >= amount then -- enough, simple payment
    return self:tryPayment(amount)
  else  -- not enough, withdraw -> payment
    if self:tryWithdraw(amount-money) then -- withdraw to complete amount
      return self:tryPayment(amount)
    end
  end

  return false
end

-- METHODS

function Money:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/money")

  local function m_give(menu)
    local user = menu.user
    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      -- prompt number
      local amount = parseInt(user:prompt(lang.money.give.prompt(),""))
      if amount > 0 and self:tryPayment(amount) then
        nuser:giveWallet(amount)
        vRP.EXT.Base.remote._notify(user.source,lang.money.given({amount}))
        vRP.EXT.Base.remote._notify(nuser.source,lang.money.received({amount}))
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  -- add give money to main menu
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.money.give.title(), m_give, lang.money.give.description())
  end)
end

-- EVENT
Money.event = {}

function Money.event:characterLoad(user)
  -- init character money

  if not user.cdata.wallet then
    user.cdata.wallet = self.cfg.open_wallet
  end

  if not user.cdata.bank then
    user.cdata.bank = self.cfg.open_bank
  end

  vRP:triggerEvent("playerMoneyUpdate", user)
end

function Money.event:playerSpawn(user, first_spawn)
  -- add money display
  if self.cfg.money_display and first_spawn then
    vRP.EXT.GUI.remote._setDiv(user.source,"money",self.cfg.display_css,lang.money.display({user:getWallet()}))
  end
end

function Money.event:playerMoneyUpdate(user)
  if self.cfg.money_display then
    -- update money
    vRP.EXT.GUI.remote._setDivContent(user.source,"money",lang.money.display({user:getWallet()}))
  end
end

vRP:registerExtension(Money)
