
-- define all language properties

local lang = {
  common = {
    no_player_near = "No player near you.",
    invalid_value = "Invalid value."
  },
  survival = {
    starving = "starving",
    thirsty = "thirsty"
  },
  money = {
    given = "Given {1} $.",
    received = "Received {1} $.",
    not_enough = "Not enough money.",
    give = {
      title = "Give money",
      description = "Give money to the nearest player.",
      prompt = "Amount:"
    }
  },
  atm = {
    title = "ATM",
    info = {
      title = "Info",
      bank = "bank: {1} $"
    },
    deposit = {
      title = "Deposit",
      description = "wallet to bank",
      prompt = "Enter amount of money for deposit:",
      deposited = "{1} $ deposited."
    },
    withdraw = {
      title = "Withdraw",
      description = "bank to wallet",
      prompt = "Enter amount of money to withdraw:",
      withdrawn = "{1} $ withdrawn.",
      not_enough = "You don't have enough money in bank."
    }
  }
}

return lang
