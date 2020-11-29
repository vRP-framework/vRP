

local lang = {
  common = {
    welcome = "Bienvenue. Utilise les touches du téléphone pour les menus.~n~dernière connexion: {1}",
    no_player_near = "~r~Pas de joueur à proximité.",
    invalid_value = "~r~Valeur incorrecte.",
    invalid_name = "~r~Nom incorrect.",
    not_found = "~r~Non trouvé.",
    request_refused = "~r~Requête refusée.",
    wearing_uniform = "~r~Attention, vous portez un uniforme.",
    not_allowed = "~r~Non autorisé.",
    must_wait = "~r~Vous devez attendre {1} secondes avant de pouvoir effectuer cette action.",
    menu = {
      title = "Menu"
    }
  },
  characters = {
    title = "[Personnages]",
    character = {
      title = "#{1}: {2} {3}",
      error = "~r~Personnage invalide."
    },
    create = {
      title = "Créer",
      error = "~r~Impossible de créer un nouveau personnage."
    },
    delete = {
      title = "Supprimer",
      prompt = "Id du personnage à supprimer ?",
      error = "~r~Impossible de supprimer le personnage #{1}."
    }
  },
  admin = {
    title = "Admin",
    call_admin = {
      title = "Appeler un admin",
      prompt = "Décrivez votre problème: ",
      notify_taken = "Un admin a pris votre ticket.",
      notify_already_taken = "Ticket déjà pris.",
      request = "Ticket admin (user_id = {1}) prendre/TP ?: {2}"
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
      hint = "Copie des coordonnées avec Ctrl-A Ctrl-C"
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
        title = "> Par id",
        prompt = "User id: "
      },
      user = {
        title = "#{1}: {2}",
        info = {
          title = "Info",
          description = "<em>Endpoint: </em>{1}<br /><em>Source: </em>{2}<br /><em>Dernière connexion: </em>{3}<br /><em>Id personnage: </em>{4}<br /><em>Bannis: </em>{5}<br /><em>Whitelisté: </em>{6}<br /><br />(valider pour mettre à jour)"
        },
        kick = {
          title = "Kick",
          prompt = "Raison: "
        },
        ban = {
          title = "Ban",
          prompt = "Raison: "
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
          title = "Groupes",
          description = "{1}<br /><br />(valider pour mettre à jour)"
        },
        group_add = {
          title = "Ajouter groupe",
          prompt = "Groupe à ajouter: "
        },
        group_remove = {
          title = "Retirer groupe",
          prompt = "Groupe à retiré: "
        },
        give_money = {
          title = "Donner de l'argent",
          prompt = "Quantité: "
        },
        give_item = {
          title = "Donner des objets",
          prompt = "Full id: ",
          prompt_amount = "Quantité: ",
          notify_failed = "Objet invalide ou inventaire plein."
        }
      }
    }
  },
  weapon = {
    -- weapon translation by GTA 5 weapon name (lower case)
    pistol = "Pistolet"
  },
  item = {
    medkit = {
      name = "Trousse de secours",
      description = "Utilisé pour réanimer des personnes inconscientes."
    },
    repairkit = {
      name = "Kit de réparation",
      description = "Utilisé pour réparer des véhicules."
    },
    dirty_money = {
      name = "Argent sale",
      description = "Argent obtenu illégalement."
    },
    money = {
      name = "Argent",
      description = "Paquet d'argent.",
      unpack = {
        title = "Défaire",
        prompt = "Montant à défaire ? (max {1})"
      }
    },
    money_binder = {
      name = "Paqueteur de billets",
      description = "Utilisé pour créer des paquets de 1000.",
      bind = {
        title = "Faire un paquet"
      }
    },
    wbody = {
      name = "Corps de {1}",
      description = "Corps d'arme de {1}.",
      equip = {
        title = "Equiper"
      }
    },
    wammo = {
      name = "Munitions de {1}",
      name_box = "Munitions de {1} x{2}",
      description = "Munitions d'arme pour {1}.",
      load = {
        title = "Charger",
        prompt = "Montant à charger ? (max {1})"
      },
      open = {
        title = "Ouvrir"
      }
    },
    bulletproof_vest = {
      name = "Gilet pare-balles",
      description = "Une protection utile.",
      wear = {
        title = "Mettre"
      }
    }
  },
  edible = {
    liquid = {
      action = "Boire",
      notify = "~b~Boit {1}."
    },
    solid = {
      action = "Manger",
      notify = "~o~Mange {1}."
    },
    drug = {
      action = "Prendre",
      notify = "~g~Prend {1}."
    }
  },

  survival = {
    starving = "Affamé",
    thirsty = "Assoiffé",
    coma_display = [[Vous êtes dans le coma, vous pouvez abandonner et mourir <span class="key">[SAUTER]</span> ou attendre de l'aide (min <span class="countdown" data-duration="{1}"></span>).<br /> <span class="countdown" data-duration="{2}"></span> restante(s).]]
  },
  money = {
    display = "{1} <span class=\"symbol\">$</span>",
    given = "Vous avez donné ~r~{1}$.",
    received = "Vous avez reçu ~g~{1}$.",
    not_enough = "~r~Pas assez d'argent.",
    paid = "Payé ~r~{1}$.",
    give = {
      title = "Donner de l'argent",
      description = "Donner de l'argent au joueur le plus proche.",
      prompt = "Montant à donner:"
    },
    transformer_recipe = "{1} $<br />"
  },
  inventory = {
    title = "Inventaire",
    description = "Ouvrir l'inventaire.",
    iteminfo = "({1})<br /><br />{2}<br /><em>{3} kg</em>",
    info_weight = "poids {1}/{2} kg",
    give = {
      title = "Donner",
      description = "Donner un objet au joueur le plus proche.",
      prompt = "Quantité à donner (max {1}):",
      given = "Vous avez donné ~r~{1} ~s~{2}.",
      received = "Vous avez reçu ~g~{1} ~s~{2}.",
    },
    trash = {
      title = "Jeter",
      description = "Jeter un objet.",
      prompt = "Quantité à jeter (max {1}):",
      done = "Jeté ~r~{1} ~s~{2}."
    },
    missing = "~r~Manque {2} {1}.",
    full = "~r~Inventaire plein.",
    chest = {
      title = "Coffre",
      already_opened = "~r~Ce coffre est déjà ouvert par quelqu'un d'autre.",
      full = "~r~Coffre plein.",
      take = {
        title = "Prendre",
        prompt = "Quantité à prendre (max {1}):"
      },
      put = {
        title = "Mettre",
        prompt = "Quantité à mettre (max {1}):"
      }
    },
    transformer_recipe = "{2} {1}<br />"
  },
  atm = {
    title = "Distributeur de billets",
    info = {
      title = "Info",
      bank = "Banque: {1} $"
    },
    deposit = {
      title = "Dépot",
      description = "Déposez de l'argent sur votre compte",
      prompt = "Entrez le montant à déposer:",
      deposited = "Vous avez déposé ~r~{1}$~s~."
    },
    withdraw = {
      title = "Retirer",
      description = "Retirez de l'argent de votre compte",
      prompt = "Entrez le montant à retirer:",
      withdrawn = "Vous avez retiré ~g~{1}$ ~s~.",
      not_enough = "~r~Vous n'avez pas assez d'argent sur votre compte."
    }
  },
  business = {
    title = "Chambre de commerce",
    identity = {
      title = "Entreprise",
      info = "<em>Nom: </em>{1}<br /><em>Capital: </em>{2} $"
    },
    directory = {
      title = "Annuaire",
      description = "Annuaire des entreprises",
      dprev = "> Précédent",
      dnext = "> Suivant",
      info = "<em>Capital: </em>{1} $<br /><em>Propriétaire: </em>{2} {3}<br /><em>Immatriculation: </em>{4}<br /><em>Téléphone: </em>{5}"
    },
    info = {
      title = "Information sur l'entreprise",
      info = "<em>Nom: </em>{1}<br /><em>Capital: </em>{2} $<br /><em>Capital de transfert: </em>{3} $<br /><br/>Le capital de transfert représente la quantité d'argent transférée pour une période. Le maximum ne peut pas dépasser le capital de l'entreprise."
    },
    addcapital = {
      title = "Ajout de capital",
      description = "Augmentez le capital de votre entreprise.",
      prompt = "Montant à ajouter à votre capital:",
      added = "~r~{1}$ ~s~ ajoutés au capital de votre entreprise."
    },
    launder = {
      title = "Blanchiment d'argent",
      description = "Utilisez votre entreprise pour blanchir de l'argent.",
      prompt = "Montant d'argent sale à blanchir (max {1} $): ",
      laundered = "~g~{1}$ ~s~ blanchis.",
      not_enough = "~r~Pas assez d'argent sale."
    },
    open = {
      title = "Ouvrir une entreprise",
      description = "Ouvrez votre entreprise, le capital minimum est de {1} $.",
      prompt_name = "Nom de l'entreprise (ne peut pas être modifié ultérieurement, maximum {1} chars):",
      prompt_capital = "Capital initial (min {1})",
      created = "~g~Entreprise créée."
      
    }
  },
  identity = {
    title = "Identité",
    citizenship = {
      title = "Citoyenneté",
      info = "<em>Nom: </em>{1}<br /><em>Prénom: </em>{2}<br /><em>Age: </em>{3}<br /><em>N° d'immatriculation: </em>{4}<br /><em>Téléphone: </em>{5}",
    },
    cityhall = {
      title = "Hôtel de ville",
      new_identity = {
        title = "Nouvelle identité",
        description = "Creez une nouvelle identité, frais de création = {1} $.",
        prompt_firstname = "Entrez votre prénom:",
        prompt_name = "Entrez votre nom de famille:",
        prompt_age = "Entrez votre âge:"
      },
    }
  },
  police = {
    title = "Police",
    wanted = "Recherché rang {1}",
    not_handcuffed = "~r~Pas menotté.",
    cloakroom = {
      title = "Vestiaire",
      uniform = {
        title = "Uniforme",
        description = "Mettre l'uniforme."
      }
    },
    pc = {
      title = "PC",
      searchreg = {
        title = "Recherche immatriculation",
        description = "Recherche d'identité par immatriculation.",
        prompt = "Entrez l'immatriculation:"
      },
      closebusiness = {
        title = "Fermer l'entreprise",
        description = "Fermer l'entreprise du joueur le plus proche",
        request = "Êtes vous sûr de vouloir fermer l'entreprise {3} gérée par {1} {2} ?",
        closed = "~g~Entreprise fermée."
      },
      trackveh = {
        title = "Localisation de véhicule",
        description = "Localisation de véhicule par immatriculation.",
        prompt_reg = "Entrez l'immatriculation:",
        prompt_note = "Entrez une note ou une raison:",
        tracking = "~b~Localisation commencée.",
        track_failed = "~b~Recherche de {1}~s~ ({2}) ~n~~r~Echouée.",
        tracked = "{1} ({2}) localisé."
      },
      records = {
        title = "Casier judiciaire",
        description = "Gérer casier judiciaire par immatriculation.",
        add = {
          title = "Ajouter",
          prompt = "Nouvel enregistrement:"
        },
        delete = {
          title = "Supprimer",
          prompt = "Id d'enregistrement à supprimer ?"
        }
      }
    },
    menu = {
      handcuff = {
        title = "Menotter",
        description = "Menotter/démenotter le joueur le plus proche."
      },
      drag = {
        title = "Traîner",
        description = "Traîner/arrêter de traîner le joueur le plus proche."
      },
      putinveh = {
        title = "Mettre dans le véhicule",
        description = "Mettre le joueur menotté le plus proche dans le véhicule le plus proche vous appartenant."
      },
      getoutveh = {
        title = "Sortir du véhicule",
        description = "Sortir du véhicule le joueur menotté le plus proche."
      },
      askid = {
        title = "Demander les papiers",
        description = "Demander les papiers d'identité du joueur le plus proche.",
        request = "Voulez vous montrer vos papiers d'identité ?",
        request_hide = "Fermer les informations d'identité.",
        asked = "Demande des papiers..."
      },
      check = {
        title = "Fouiller le joueur",
        description = "Fouiller le portefeuille, les objets et les armes du joueur le plus proche.",
        checked = "~b~Vous avez été fouillé.",
        info = {
          title = "Info",
          description = "<em>Portefeuille: </em>{1} $"
        }
      },
      seize = {
        seized = "~b~Vos armes et objets illégaux ont été saisis.",
        title = "Saisir armes/illégaux",
        description = "Saisir les armes et objets illégaux du joueur à proximité."
      },
      jail = {
        title = "Prison",
        description = "Mettre en prison/libérer le joueur le plus proche dans la prison la plus proche.",
        not_found = "~r~Pas de prison trouvée.",
        jailed = "~b~Emprisonné.",
        unjailed = "~b~Libéré.",
        notify_jailed = "~b~Vous avez été emprisonné.",
        notify_unjailed = "~b~Vous avez été libéré."
      },
      fine = {
        title = "Amende",
        description = "Mettre une amende au joueur le plus proche.",
        fined = "~b~Vous avez mis une amende de ~s~{2} $ pour ~b~{1}.",
        notify_fined = "~b~Vous avez été condamné à une amende de~s~ {2} $ pour~b~ {1}.",
        record = "[Amende] {2} $ pour {1}"
      },
      store_weapons = {
        title = "Ranger ses armes",
        description = "Ranger ses armes dans son inventaire."
      }
    }
  },
  emergency = {
    menu = {
      revive = {
        title = "Réanimer",
        description = "Réanimer le joueur le plus proche.",
        not_in_coma = "~r~Le joueur n'est pas dans le coma."
      }
    }
  },
  phone = {
    title = "Téléphone",
    directory = {
      title = "Répertoire",
      description = "Ouvrir le Répertoire.",
      add = {
        title = "> Ajouter",
        prompt_number = " Entrez le n° de téléphone à ajouter:",
        prompt_name = "Entrez un nom associé au n° de téléphone:",
        added = "~g~N° de téléphone ajouté."
      },
      sendsms = {
        title = "Envoyer un SMS",
        prompt = " Entrez le message à envoyer (max {1} chars):",
        sent = "~g~ Envoyé au n°{1}.",
        not_sent = "~r~ n°{1} non disponible."
      },
      sendpos = {
        title = "Envoi de la position",
      },
      remove = {
        title = "Supprimer"
      },
      call = {
        title = "Appeler",
        not_reached = "~r~ n°{1} indisponible."
      }
    },
    sms = {
      title = "Historique des SMS",
      description = "Historique des SMS reçus.",
      info = "<em>{1}</em><br /><br />{2}",
      notify = "SMS~b~ {1}:~s~ ~n~{2}"
    },
    smspos = {
      notify = "SMS-Position ~b~ {1}"
    },
    service = {
      title = "Service",
      description = "Appelez un service ou un n° d'urgence.",
      prompt = "Si besoin, entrez un message pour le service:",
      ask_call = "Reception d'un appel ({1}), voulez vous le prendre ? <em>{2}</em>",
      taken = "~r~Cet appel est déjà pris."
    },
    announce = {
      title = "Annonce",
      description = "Envoyer une annonce visible à tous pendant quelques secondes.",
      item_desc = "{1} $<br /><br/>{2}",
      prompt = "Contenu de l'annonce (10-1000 caractères): "
    },
    call = {
      ask = "Accepter l'appel depuis {1} ?",
      notify_to = "Appel~b~ {1}...",
      notify_from = "Appel reçu de ~b~ {1}...",
      notify_refused = "Appel vers ~b~ {1}... ~r~ refusé."
    },
    hangup = {
      title = "Raccrocher",
      description = "Raccrocher le téléphone (terminer l'appel en cours)."
    }
  },
  emotes = {
    title = "Emotes",
    clear = {
      title = "> Arrêter",
      description = "Arrête toutes les emotes en cours."
    }
  },
  home = {
    address = {
      title = "Adresse",
      info = "{1}, {2}"
    },
    buy = {
      title = "Acheter",
      description = "Acheter un logement ici, le prix est {1} $.",
      bought = "~g~Acheté.",
      full = "~r~Plus de place.",
      have_home = "~r~Vous avez déjà un logement."
    },
    sell = {
      title = "Vendre",
      description = "Vendre son logement pour {1} $",
      sold = "~g~vendu.",
      no_home = "~r~Vous n'avez pas de logement ici."
    },
    intercom = {
      title = "Interphone",
      description = "Utiliser l'interphone pour entrer dans un logement.",
      prompt = "Numéro:",
      not_available = "~r~Indisponible.",
      refused = "~r~Entrée refusée.",
      prompt_who = "Dites qui vous êtes:",
      asked = "Demande...",
      request = "Quelqu'un veut rentrer dans votre logement: <em>{1}</em>"
    },
    slot = {
      leave = {
        title = "Sortir"
      },
      ejectall = {
        title = "Expulser",
        description = "Expulse tous les visiteurs, même vous, et ferme le logement."
      }
    },
    wardrobe = {
      title = "Garde-robe",
      save = {
        title = "> Sauvegarder",
        prompt = "Nom de la sauvegarde:"
      }
    },
    gametable = {
      title = "Table de jeux",
      bet = {
        title = "Commencer un pari",
        description = "Commencer un pari avec les joueurs à proximité, le gagnant sera choisis aléatoirement.",
        prompt = "Mise du pari:",
        request = "[PARI] Voulez vous parier {1} $ ?",
        started = "~g~Pari commencé."
      }
    },
    radio = {
      title = "Radio",
      off = {
        title = "> éteindre"
      }
    }
  },
  garage = {
    title = "Garage ({1})",
    owned = {
      title = "Mes véhicules",
      description = "Véhicules m'appartenant",
      already_out = "Véhicule déjà sorti.",
      force_out = {
        request = "Véhicule déjà sorti, voulez vous payer {1} $ de frais pour le récupérer ?"
      }
    },
    buy = {
      title = "Acheter",
      description = "Acheter des véhicules.",
      info = "{1} $<br /><br />{2}"
    },
    sell = {
      title = "Vendre",
      description = "Vendre des véhicules."
    },
    rent = {
      title = "Location",
      description = "Louer un véhicule pour la session (jusqu'à déconnexion)."
    },
    store = {
      title = "Rentrer au garage",
      description = "Rentrez votre véhicule au garage.",
      too_far = "Le véhicule est trop loin.",
      wrong_garage = "Le véhicule ne peut pas être rangé dans ce garage.",
      stored = "Véhicule rentré."
    }
  },
  vehicle = {
    title = "Véhicule",
    no_owned_near = "~r~Pas de véhicule vous appartenant à proximité.",
    trunk = {
      title = "Coffre",
      description = "Ouvrir le coffre du véhicule."
    },
    detach_trailer = {
      title = "Détacher remorque",
      description = "Détacher la remorque."
    },
    detach_towtruck = {
      title = "Détacher dépanneuse",
      description = "Détacher le lien de la dépanneuse."
    },
    detach_cargobob = {
      title = "Détacher cargobob",
      description = "Détacher le lien de l'hélico de transport."
    },
    lock = {
      title = "Fermer/ouvrir",
      description = "Fermer ou ouvrir le véhicule.",
      locked = "Véhicule vérrouillé.",
      unlocked = "Véhicule dévérrouillé."
    },
    engine = {
      title = "Moteur on/off",
      description = "Démarrer ou arrêter le moteur."
    },
    asktrunk = {
      title = "Demander ouvrir coffre",
      asked = "~g~Demande...",
      request = "Voulez vous ouvrir le coffre ?"
    },
    replace = {
      title = "Replacer véhicule",
      description = "Replacer sur le sol le véhicule le plus proche."
    },
    repair = {
      title = "Réparer véhicule",
      description = "Réparer le véhicule le plus proche."
    }
  },
  shop = {
    title = "Magasin ({1})",
    prompt = "Quantité de {1} à acheter:",
    info = "{1} $<br /><br />{2}"
  },
  skinshop = {
    title = "Magasin d'apparence",
    info = {
      title = "Info",
      description = "Selectionner une partie de l'apparence ci-dessous.<br /><br /><em>Prix actuel: </em>{1} $"
    },
    model = "Modèle",
    texture = "Texture",
    palette = "Palette",
    color_primary = "Couleur première",
    color_secondary = "Couleur secondaire",
    opacity = "Opacité",
    select_description = "{1}/{2} (gauche/droite pour selectionner)"
  },
  cloakroom = {
    title = "Vestiaire ({1})",
    undress = {
      title = "> Enlever"
    }
  },
  transformer = {
    recipe_description = [[{1}<br /><br />{2}<div style="color: rgb(0,255,125)">=></div>{3}]],
    empty_bar = "vide"
  },
  hidden_transformer = {
    informer = {
      title = "Informateur illégal",
      description = "{1} $",
      bought = "~g~Position envoyée au GPS."
    }
  },
  mission = {
    title = "Mission ({1}) {2}/{3}",
    display = "<span class=\"name\">{1}</span> <span class=\"step\">{2}/{3}</span><br /><br />{4}",
    cancel = {
      title = "Abandonner la mission"
    }
  },
  aptitude = {
    title = "Compétences",
    description = "Afficher les compétences.",
    lose_exp = "Compétence ~b~{1}/{2} ~r~-{3} ~s~exp.",
    earn_exp = "Compétence ~b~{1}/{2} ~g~+{3} ~s~exp.",
    level_down = "Compétence ~b~{1}/{2} ~r~descend en niveau ({3}).",
    level_up = "Compétence ~b~{1}/{2} ~g~monte en niveau ({3}).",
    display = {
      group = "{1}",
      aptitude = "{1} NIV {3} EXP {2}"
    },
    transformer_recipe = "[EXP] {3} {1}/{2}<br />"
  },
  radio = {
    title = "Radio ON/OFF",
    description = "Permet de parler avec [CHAT TEXTUEL EQUIPE] et diffuse un signal GPS quand elle est allumée."
  },
  profiler = {
    title_server = "[Profiler:serveur]",
    title_client = "[Profiler:client]",
    prompt_resources = "Noms des ressources à profiler (séparées par des lignes/espaces; vide pour toutes) ?",
    prompt_duration = "Durée (secondes) ?",
    prompt_stack_depth = "Pronfondeur du stack dump ? Une plus grande valeur peut aider à localiser plus précisément les hotspots.",
    prompt_aggregate = "Agréger les profils (yes/no) ? Si utilisé, les profils seront agrégés en un seul profil au lieu d'un par ressource.",
    prompt_report = "Rapport de profilage (copier avec Ctrl-A Ctrl-C)."
  }
}

return lang
