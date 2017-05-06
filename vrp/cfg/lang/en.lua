
-- define all language properties

local lang = {
  common = {
    no_player_near = "No player near you.",
    invalid_value = "Invalid value.",
    invalid_name = "Invalid name."
  },
  survival = {
    starving = "starving",
    thirsty = "thirsty"
  },
  money = {
    given = "Given {1} $.",
    received = "Received {1} $.",
    not_enough = "Not enough money.",
    paid = "Paid {1} $.",
    give = {
      title = "Give money",
      description = "Give money to the nearest player.",
      prompt = "Amount to give:"
    }
  },
  inventory = {
    title = "Inventory",
    description = "Open the inventory.",
    iteminfo = "({1})<br /><br />{2}",
    give = {
      title = "Give",
      description = "Give items to the nearest player.",
      prompt = "Amount to give (max {1}):",
      given = "Given {1} {2}.",
      received = "Received {1} {2}.",
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
  },
  business = {
    title = "Chamber of Commerce",
    directory = {
      title = "Directory",
      description = "Business directory.",
      dprev = "> Prev",
      dnext = "> Next",
      info = "<em>capital: </em>{1} $<br /><em>owner: </em>{2} {3}<br /><em>registration n°: </em>{4}"
    },
    info = {
      title = "Business info",
      info = "<em>name: </em>{1}<br /><em>capital: </em>{2} $<br /><em>capital transfer: </em>{3} $<br /><br/>Capital transfer is the amount of money transfered for a business economic period, the maximum is the business capital."
    },
    addcapital = {
      title = "Add capital",
      description = "Add capital to your business.",
      prompt = "Amount to add to the business capital:",
      added = "{1} $ added to the business capital."
    },
    launder = {
      title = "Money laundering",
      description = "Use your business to launder dirty money.",
      prompt = "Amount of dirty money to launder (max {1} $): ",
      laundered = "{1} $ laundered.",
      not_enough = "Not enough dirty money."
    },
    open = {
      title = "Open business",
      description = "Open your business, minimum capital is {1} $.",
      prompt_name = "Business name (can't change after, max {1} chars):",
      prompt_capital = "Initial capital (min {1})",
      created = "Business created."
      
    }
  },
  cityhall = {
    title = "City Hall",
    identity = {
      title = "New identity",
      description = "Create a new identity, cost = {1} $.",
      prompt_firstname = "Enter your firstname:",
      prompt_name = "Enter your name:",
      prompt_age = "Enter your age:",
    },
    menu = {
      title = "Identity",
      info = "<em>Name: </em>{1}<br /><em>First name: </em>{2}<br /><em>Age: </em>{3}<br /><em>Registration n°: </em>{4}"
    }
  },
  garage = {
    title = "Garage ({1})",
    owned = {
      title = "Owned",
      description = "Owned vehicles."
    },
    buy = {
      title = "Buy",
      description = "Buy vehicles.",
      info = "{1} $<br /><br />{2}"
    },
    store = {
      title = "Store",
      description = "Put your current vehicle in the garage."
    }
  },
  gunshop = {
    title = "Gunshop ({1})",
    prompt_ammo = "Amount of ammo to buy for the {1}:",
    info = "<em>body: </em> {1} $<br /><em>ammo: </em> {2} $/u<br /><br />{3}"
  },
  market = {
    title = "Market ({1})",
    prompt = "Amount of {1} to buy:",
    info = "{1} $<br /><br />{2}"
  },
  skinshop = {
    title = "Skinshop"
  }
}

return lang
