
-- define all language properties

local lang = {
  common = {
    welcome = "Welcome. Use the phone keys to use the menu.~n~last login: {1}",
    no_player_near = "~r~No player near you.",
    invalid_value = "~r~Invalid value.",
    invalid_name = "~r~Invalid name.",
    not_found = "~r~Not found.",
    request_refused = "~r~Request refused.",
    wearing_uniform = "~r~Be careful, you are wearing a uniform.",
    not_allowed = "~r~Not allowed."
  },
  weapon = {
    pistol = "Pistol"
  },
  survival = {
    starving = "starving",
    thirsty = "thirsty"
  },
  money = {
    display = "{1} <span class=\"symbol\">$</span>",
    given = "Given ~r~{1}$.",
    received = "Received ~g~{1}$.",
    not_enough = "~r~Not enough money.",
    paid = "Paid ~r~{1}$.",
    give = {
      title = "Give money",
      description = "Give money to the nearest player.",
      prompt = "Amount to give:"
    }
  },
  inventory = {
    title = "Inventory",
    description = "Open the inventory.",
    iteminfo = "({1})<br /><br />{2}<br /><em>{3} kg</em>",
    info_weight = "weight {1}/{2} kg",
    give = {
      title = "Give",
      description = "Give items to the nearest player.",
      prompt = "Amount to give (max {1}):",
      given = "Given ~r~{1} ~s~{2}.",
      received = "Received ~g~{1} ~s~{2}.",
    },
    trash = {
      title = "Trash",
      description = "Destroy items.",
      prompt = "Amount to trash (max {1}):",
      done = "Trashed ~r~{1} ~s~{2}."
    },
    missing = "~r~Missing {2} {1}.",
    full = "~r~Inventory full.",
    chest = {
      title = "Chest",
      already_opened = "~r~This chest is already opened by someone else.",
      full = "~r~Chest full.",
      take = {
        title = "Take",
        prompt = "Amount to take (max {1}):"
      },
      put = {
        title = "Put",
        prompt = "Amount to put (max {1}):"
      }
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
      deposited = "~r~{1}$~s~ deposited."
    },
    withdraw = {
      title = "Withdraw",
      description = "bank to wallet",
      prompt = "Enter amount of money to withdraw:",
      withdrawn = "~g~{1}$ ~s~withdrawn.",
      not_enough = "~r~You don't have enough money in bank."
    }
  },
  business = {
    title = "Chamber of Commerce",
    directory = {
      title = "Directory",
      description = "Business directory.",
      dprev = "> Prev",
      dnext = "> Next",
      info = "<em>capital: </em>{1} $<br /><em>owner: </em>{2} {3}<br /><em>registration n°: </em>{4}<br /><em>phone: </em>{5}"
    },
    info = {
      title = "Business info",
      info = "<em>name: </em>{1}<br /><em>capital: </em>{2} $<br /><em>capital transfer: </em>{3} $<br /><br/>Capital transfer is the amount of money transfered for a business economic period, the maximum is the business capital."
    },
    addcapital = {
      title = "Add capital",
      description = "Add capital to your business.",
      prompt = "Amount to add to the business capital:",
      added = "~r~{1}$ ~s~added to the business capital."
    },
    launder = {
      title = "Money laundering",
      description = "Use your business to launder dirty money.",
      prompt = "Amount of dirty money to launder (max {1} $): ",
      laundered = "~g~{1}$ ~s~laundered.",
      not_enough = "~r~Not enough dirty money."
    },
    open = {
      title = "Open business",
      description = "Open your business, minimum capital is {1} $.",
      prompt_name = "Business name (can't change after, max {1} chars):",
      prompt_capital = "Initial capital (min {1})",
      created = "~g~Business created."
      
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
      info = "<em>Name: </em>{1}<br /><em>First name: </em>{2}<br /><em>Age: </em>{3}<br /><em>Registration n°: </em>{4}<br /><em>Phone: </em>{5}<br /><em>Address: </em>{7}, {6}"
    }
  },
  police = {
    title = "Police",
    wanted = "Wanted rank {1}",
    not_handcuffed = "~r~Not handcuffed",
    cloakroom = {
      title = "Cloakroom",
      uniform = {
        title = "Uniform",
        description = "Put uniform."
      }
    },
    pc = {
      title = "PC",
      searchreg = {
        title = "Registration search",
        description = "Search identity by registration.",
        prompt = "Enter registration number:"
      },
      closebusiness = {
        title = "Close business",
        description = "Close business of the nearest player.",
        request = "Are you sure to close the business {3} owned by {1} {2} ?",
        closed = "~g~Business closed."
      },
      trackveh = {
        title = "Track vehicle",
        description = "Track a vehicle by its registration number.",
        prompt_reg = "Enter registration number:",
        prompt_note = "Enter a tracking note/reason:",
        tracking = "~b~Tracking started.",
        track_failed = "~b~Tracking of {1}~s~ ({2}) ~n~~r~Failed.",
        tracked = "Tracked {1} ({2})"
      },
      records = {
        show = {
          title = "Show records",
          description = "Show police records by registration number."
        },
        delete = {
          title = "Clear records",
          description = "Clear police records by registration number.",
          deleted = "~b~Police records deleted"
        }
      }
    },
    menu = {
      handcuff = {
        title = "Handcuff",
        description = "Handcuff/unhandcuff nearest player."
      },
      putinveh = {
        title = "Put in vehicle",
        description = "Put the nearest handcuffed player in the nearest vehicle, as passenger."
      },
      getoutveh = {
        title = "Get out vehicle",
        description = "Get out of vehicle the nearest handcuffed player."
      },
      askid = {
        title = "Ask ID",
        description = "Ask ID card from the nearest player.",
        request = "Do you want to give your ID card ?",
        request_hide = "Hide the ID card.",
        asked = "Asking ID..."
      },
      check = {
        title = "Check player",
        description = "Check money, inventory and weapons of the nearest player.",
        request_hide = "Hide the check report.",
        info = "<em>money: </em>{1} $<br /><br /><em>inventory: </em>{2}<br /><br /><em>weapons: </em>{3}",
        checked = "You have being checked."
      },
      seize = {
        seized = "Seized {2} ~r~{1}",
        weapons = {
          title = "Seize weapons",
          description = "Seize nearest player weapons",
          seized = "~b~Your weapons have been seized."
        },
        items = {
          title = "Seize illegals",
          description = "Seize illegal items",
          seized = "~b~Your illegal stuff has been seized."
        }
      },
      jail = {
        title = "Jail",
        description = "Jail/UnJail nearest player in/from the nearest jail.",
        not_found = "~r~No jail found.",
        jailed = "~b~Jailed.",
        unjailed = "~b~Unjailed.",
        notify_jailed = "~b~You have been jailed.",
        notify_unjailed = "~b~You have been unjailed."
      },
      fine = {
        title = "Fine",
        description = "Fine the nearest player.",
        fined = "~b~Fined ~s~{2} $ for ~b~{1}.",
        notify_fined = "~b~You have been fined ~s~ {2} $ for ~b~{1}.",
        record = "[Fine] {2} $ for {1}"
      },
      store_weapons = {
        title = "Store weapons",
        description = "Store your weapons in your inventory."
      }
    },
    identity = {
      info = "<em>Name: </em>{1}<br /><em>First name: </em>{2}<br /><em>Age: </em>{3}<br /><em>Registration n°: </em>{4}<br /><em>Phone: </em>{5}<br /><em>Business: </em>{6}<br /><em>Business capital: </em>{7} $<br /><em>Address: </em>{9}, {8}"
    }
  },
  emergency = {
    menu = {
      revive = {
        title = "Reanimate",
        description = "Reanimate the nearest player.",
        not_in_coma = "~r~Not in coma."
      }
    }
  },
  phone = {
    title = "Phone",
    directory = {
      title = "Directory",
      description = "Open the phone directory.",
      add = {
        title = "> Add",
        prompt_number = "Enter the phone number to add:",
        prompt_name = "Enter the entry name:",
        added = "~g~Entry added."
      },
      sendsms = {
        title = "Send SMS",
        prompt = "Enter the message (max {1} chars):",
        sent = "~g~ Sent to n°{1}.",
        not_sent = "~r~ n°{1} unavailable."
      },
      sendpos = {
        title = "Send position",
      },
      remove = {
        title = "Remove"
      }
    },
    sms = {
      title = "SMS History",
      description = "Received SMS history.",
      info = "<em>{1}</em><br /><br />{2}",
      notify = "SMS~b~ {1}:~s~ ~n~{2}"
    },
    smspos = {
      notify = "SMS-Position ~b~ {1}"
    },
    service = {
      title = "Service",
      description = "Call a service or an emergency number.",
      prompt = "If needed, enter a message for the service:",
      ask_call = "Received {1} call, do you take it ? <em>{2}</em>",
      taken = "~r~This call is already taken."
    },
    announce = {
      title = "Announce",
      description = "Post an announce visible to everyone for a few seconds.",
      item_desc = "{1} $<br /><br/>{2}",
      prompt = "Announce content (10-1000 chars): "
    }
  },
  emotes = {
    title = "Emotes",
    clear = {
      title = "> Clear",
      description = "Clear all running emotes."
    }
  },
  home = {
    buy = {
      title = "Buy",
      description = "Buy a home here, price is {1} $.",
      bought = "~g~Bought.",
      full = "~r~The place is full.",
      have_home = "~r~You already have a home."
    },
    sell = {
      title = "Sell",
      description = "Sell your home for {1} $",
      sold = "~g~Sold.",
      no_home = "~r~You don't have a home here."
    },
    intercom = {
      title = "Intercom",
      description = "Use the intercom to enter in a home.",
      prompt = "Number:",
      not_available = "~r~Not available.",
      refused = "~r~Refused to enter.",
      prompt_who = "Say who you are:",
      asked = "Asking...",
      request = "Someone wants to open your home door: <em>{1}</em>"
    },
    slot = {
      leave = {
        title = "Leave"
      },
      ejectall = {
        title = "Eject all",
        description = "Eject all home visitors, including you, and close the home."
      }
    },
    wardrobe = {
      title = "Wardrobe",
      save = {
        title = "> Save",
        prompt = "Save name:"
      }
    },
    gametable = {
      title = "Game table",
      bet = {
        title = "Start bet",
        description = "Start a bet with players near you, the winner will be randomly selected.",
        prompt = "Bet amount:",
        request = "[BET] Do you want to bet {1} $ ?",
        started = "~g~Bet started."
      }
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
    sell = {
      title = "Sell",
      description = "Sell vehicles."
    },
    rent = {
      title = "Rent",
      description = "Rent a vehicle for the session (until you disconnect)."
    },
    store = {
      title = "Store",
      description = "Put your current vehicle in the garage."
    }
  },
  vehicle = {
    title = "Vehicle",
    no_owned_near = "~r~No owned vehicle near.",
    trunk = {
      title = "Trunk",
      description = "Open the vehicle trunk."
    },
    detach_trailer = {
      title = "Detach trailer",
      description = "Detach trailer."
    },
    detach_towtruck = {
      title = "Detach tow truck",
      description = "Detach tow truck."
    },
    detach_cargobob = {
      title = "Detach cargobob",
      description = "Detach cargobob."
    },
    lock = {
      title = "Lock/unlock",
      description = "Lock or unlock the vehicle."
    },
    engine = {
      title = "Engine on/off",
      description = "Start or stop the engine."
    },
    asktrunk = {
      title = "Ask open trunk",
      asked = "~g~Asking...",
      request = "Do you want to open the trunk ?"
    },
    replace = {
      title = "Replace vehicle",
      description = "Replace on ground the nearest vehicle."
    },
    repair = {
      title = "Repair vehicle",
      description = "Repair the nearest vehicle."
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
  },
  cloakroom = {
    title = "Cloakroom ({1})",
    undress = {
      title = "> Undress"
    }
  },
  itemtr = {
    informer = {
      title = "Illegal Informer",
      description = "{1} $",
      bought = "~g~Position sent to your GPS."
    }
  },
  mission = {
    blip = "Mission ({1}) {2}/{3}",
    display = "<span class=\"name\">{1}</span> <span class=\"step\">{2}/{3}</span><br /><br />{4}",
    cancel = {
      title = "Cancel mission"
    }
  },
  aptitude = {
    title = "Aptitudes",
    description = "Show aptitudes.",
    lose_exp = "Aptitude ~b~{1}/{2} ~r~-{3} ~s~exp.",
    earn_exp = "Aptitude ~b~{1}/{2} ~g~+{3} ~s~exp.",
    level_down = "Aptitude ~b~{1}/{2} ~r~lose level ({3}).",
    level_up = "Aptitude ~b~{1}/{2} ~g~level up ({3}).",
    display = {
      group = "{1}: ",
      aptitude = "{1} LVL {3} EXP {2}"
    }
  }
}

return lang
