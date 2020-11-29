
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
    not_allowed = "~r~Not allowed.",
    must_wait = "~r~Must wait {1} seconds before being able to perform this action.",
    menu = {
      title = "Menu"
    }
  },
  characters = {
    title = "[Characters]",
    character = {
      title = "#{1}: {2} {3}",
      error = "~r~Invalid character."
    },
    create = {
      title = "Create",
      error = "~r~Couldn't create a new character."
    },
    delete = {
      title = "Delete",
      prompt = "Character id to delete ?",
      error = "~r~Couldn't delete character #{1}."
    }
  },
  admin = {
    title = "Admin",
    call_admin = {
      title = "Call admin",
      prompt = "Describe your problem: ",
      notify_taken = "An admin took your ticket.",
      notify_already_taken = "Ticket already taken.",
      request = "Admin ticket (user_id = {1}) take/TP to ?: {2}"
    },
    tptocoords = {
      title = "TpToCoords",
      prompt = "Coords x,y,z: "
    },
    tptomarker = {
      title = "TpToMarker"
    },
    noclip = {
      title = "Noclip"
    },
    coords = {
      title = "Coords",
      hint = "Copy the coordinates using Ctrl-A Ctrl-C"
    },
    custom_upper_emote = {
      title = "Custom upper emote",
      prompt = "Animation sequence ('dict anim optional_loops' per line): "
    },
    custom_full_emote = {
      title = "Custom full emote"
    },
    custom_emote_task = {
      title = "Custom emote task",
      prompt = "Task name: "
    },
    custom_sound = {
      title = "Custom sound",
      prompt = "Sound 'dict name': "
    },
    custom_model = {
      title = "Custom model",
      prompt = "Model hash or name: "
    },
    custom_audiosource = {
      title = "Custom AudioSource",
      prompt = "Audio source: name=url, omit url to delete the named source."
    },
    users = {
      title = "Users",
      by_id = {
        title = "> By id",
        prompt = "User id: "
      },
      user = {
        title = "#{1}: {2}",
        info = {
          title = "Info",
          description = "<em>Endpoint: </em>{1}<br /><em>Source: </em>{2}<br /><em>Last login: </em>{3}<br /><em>Character id: </em>{4}<br /><em>Banned: </em>{5}<br /><em>Whitelisted: </em>{6}<br /><br />(valid to update)"
        },
        kick = {
          title = "Kick",
          prompt = "Reason: "
        },
        ban = {
          title = "Ban",
          prompt = "Reason: "
        },
        unban = {
          title = "Unban"
        },
        whitelist = {
          title = "Whitelist user"
        },
        unwhitelist = {
          title = "Un-whitelist user"
        },
        tptome = {
          title = "TpToMe"
        },
        tpto = {
          title = "TpTo"
        },
        groups = {
          title = "Groups",
          description = "{1}<br /><br />(valid to update)"
        },
        group_add = {
          title = "Add group",
          prompt = "Group to add: "
        },
        group_remove = {
          title = "Remove group",
          prompt = "Group to remove: "
        },
        give_money = {
          title = "Give money",
          prompt = "Amount: "
        },
        give_item = {
          title = "Give item",
          prompt = "Full id: ",
          prompt_amount = "Amount: ",
          notify_failed = "Invalid item or inventory is full."
        }
      }
    }
  },
  weapon = {
    -- weapon translation by GTA 5 weapon name (lower case)
    pistol = "Pistol"
  },
  item = {
    medkit = {
      name = "Medical Kit",
      description = "Used to reanimate unconscious people."
    },
    repairkit = {
      name = "Repair Kit",
      description = "Used to repair vehicles."
    },
    dirty_money = {
      name = "Dirty money",
      description = "Illegally earned money."
    },
    money = {
      name = "Money",
      description = "Packed money.",
      unpack = {
        title = "Unpack",
        prompt = "How much to unpack ? (max {1})"
      }
    },
    money_binder = {
      name = "Money binder",
      description = "Used to bind 1000$ of money.",
      bind = {
        title = "Bind money"
      }
    },
    wbody = {
      name = "{1} body",
      description = "Weapon body of {1}.",
      equip = {
        title = "Equip"
      }
    },
    wammo = {
      name = "{1} ammo",
      name_box = "{1} ammo x{2}",
      description = "Weapon ammo for {1}.",
      load = {
        title = "Load",
        prompt = "Amount to load ? (max {1})"
      },
      open = {
        title = "Open"
      }
    },
    bulletproof_vest = {
      name = "Bulletproof Vest",
      description = "A handy protection.",
      wear = {
        title = "Wear"
      }
    }
  },
  edible = {
    liquid = {
      action = "Drink",
      notify = "~b~Drinking {1}."
    },
    solid = {
      action = "Eat",
      notify = "~o~Eating {1}."
    },
    drug = {
      action = "Take",
      notify = "~g~Taking {1}."
    }
  },
  survival = {
    starving = "starving",
    thirsty = "thirsty",
    coma_display = [[You are in a coma, you can give up on life <span class="key">[JUMP]</span> or wait for help (min <span class="countdown" data-duration="{1}"></span>).<br /> <span class="countdown" data-duration="{2}"></span> remaining.]]
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
    },
    transformer_recipe = "{1} $<br />"
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
    },
    transformer_recipe = "{2} {1}<br />"
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
    identity = {
      title = "Business",
      info = "<em>name: </em>{1}<br /><em>capital: </em>{2} $"
    },
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
  identity = {
    title = "Identity",
    citizenship = {
      title = "Citizenship",
      info = "<em>Name: </em>{1}<br /><em>First name: </em>{2}<br /><em>Age: </em>{3}<br /><em>Registration n°: </em>{4}<br /><em>Phone: </em>{5}",
    },
    cityhall = {
      title = "City Hall",
      new_identity = {
        title = "New identity",
        description = "Create a new identity, cost = {1} $.",
        prompt_firstname = "Enter your firstname:",
        prompt_name = "Enter your name:",
        prompt_age = "Enter your age:",
      }
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
        title = "Records",
        description = "Manage police records by registration number.",
        add = {
          title = "Add",
          prompt = "New record:"
        },
        delete = {
          title = "Delete",
          prompt = "Record id to delete ?"
        }
      }
    },
    menu = {
      handcuff = {
        title = "Handcuff",
        description = "Handcuff/unhandcuff nearest player."
      },
      drag = {
        title = "Drag",
        description = "Make the nearest player follow/unfollow you."
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
        description = "Check wallet, inventory and weapons of the nearest player.",
        checked = "~b~You have been checked.",
        info = {
          title = "Info",
          description = "<em>Wallet: </em>{1} $"
        }
      },
      seize = {
        seized = "~b~Your weapons and illegal items have been seized.",
        title = "Seize weapons/illegals",
        description = "Seize nearest player weapons and illegal items."
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
      },
      call = {
        title = "Call",
        not_reached = "~r~ n°{1} not reached."
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
    },
    call = {
      ask = "Accept call from {1} ?",
      notify_to = "Calling~b~ {1}...",
      notify_from = "Receive call from ~b~ {1}...",
      notify_refused = "Call to ~b~ {1}... ~r~ refused."
    },
    hangup = {
      title = "Hang up",
      description = "Hang up the phone (shutdown current call)."
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
    address = {
      title = "Address",
      info = "{1}, {2}"
    },
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
    },
    radio = {
      title = "Radio",
      off = {
        title = "> turn off"
      }
    }
  },
  garage = {
    title = "Garage ({1})",
    owned = {
      title = "Owned",
      description = "Owned vehicles.",
      already_out = "This vehicle is already out.",
      force_out = {
        request = "This vehicle is already out, do you want to pay a {1} $ fee to fetch it ?"
      }
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
      description = "Put your current vehicle in the garage.",
      too_far = "The vehicle is too far away.",
      wrong_garage = "The vehicle can't be stored in this garage.",
      stored = "Vehicle stored."
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
      description = "Lock or unlock the vehicle.",
      locked = "Vehicle locked.",
      unlocked = "Vehicle unlocked."
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
  shop = {
    title = "Shop ({1})",
    prompt = "Amount of {1} to buy:",
    info = "{1} $<br /><br />{2}"
  },
  skinshop = {
    title = "Skinshop",
    info = {
      title = "Info",
      description = "Select a skin part below.<br /><br /><em>Current price: </em>{1} $"
    },
    model = "Model",
    texture = "Texture",
    palette = "Palette",
    color_primary = "Primary color",
    color_secondary = "Secondary color",
    opacity = "Opacity",
    select_description = "{1}/{2} (left/right to select)"
  },
  cloakroom = {
    title = "Cloakroom ({1})",
    undress = {
      title = "> Undress"
    }
  },
  transformer = {
    recipe_description = [[{1}<br /><br />{2}<div style="color: rgb(0,255,125)">=></div>{3}]],
    empty_bar = "empty"
  },
  hidden_transformer = {
    informer = {
      title = "Illegal Informer",
      description = "{1} $",
      bought = "~g~Position sent to your GPS."
    }
  },
  mission = {
    title = "Mission ({1}) {2}/{3}",
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
      group = "{1}",
      aptitude = "{1} LVL {3} EXP {2}"
    },
    transformer_recipe = "[EXP] {3} {1}/{2}<br />"
  },
  radio = {
    title = "Radio ON/OFF",
    description = "Allow to speak with [TEAM TEXT CHAT] and broadcast a GPS signal when ON."
  },
  profiler = {
    title_server = "[Profiler:server]",
    title_client = "[Profiler:client]",
    prompt_resources = "Resource names to profile (line/space separated; empty for all) ?",
    prompt_duration = "Duration (seconds) ?",
    prompt_stack_depth = "Stack dump depth ? A higher value can help to locate hotpots more precisely.",
    prompt_aggregate = "Aggregate profiles (yes/no) ? If yes, it will aggregate all profiles into a single one instead of one per resource.",
    prompt_report = "Profiler report (copy with Ctrl-A Ctrl-C)."
  }
}

return lang
