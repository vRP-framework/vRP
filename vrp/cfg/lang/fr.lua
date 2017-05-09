


local lang = {
  common = {
    no_player_near = "~r~Pas de joueur à proximité.",
    invalid_value = "~r~Valeur incorrecte.",
    invalid_name = "~r~Nom incorrect.",
    not_found = "~r~Non trouvé.",
    request_refused = "~r~Requête refusée."
  },
  survival = {
    starving = "Affamé",
    thirsty = "Assoiffé"
  },
  money = {
    given = "Vous avez donné ~r~{1}$.",
    received = "Vous avez reçu ~g~{1}$.",
    not_enough = "~r~Pas assez d'argent.",
    paid = "Payé ~r~{1}$.",
    give = {
      title = "Donner de l'argent",
      description = "Donner de l'argent au joueur le plus proche.",
      prompt = "Montant à donner:"
    }
  },
  inventory = {
    title = "Inventaire",
    description = "Ouvrir l'inventaire.",
    iteminfo = "({1})<br /><br />{2}",
    give = {
      title = "Donner",
      description = "Donner un item au joueur le plus proche.",
      prompt = "Quantité à donner (max {1}):",
      given = "Vous avez donné ~r~{1} ~s~{2}.",
      received = "Vous avez reçu ~g~{1} ~s~{2}.",
    }
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
    directory = {
      title = "Annuaire",
      description = "Annuaire des entreprises",
      dprev = "> Précédent",
      dnext = "> Suivant",
      info = "<em>capital: </em>{1} $<br /><em>propriétaire: </em>{2} {3}<br /><em>immatriculation: </em>{4}<br /><em>téléphone: </em>{5}"
    },
    info = {
      title = "Information sur l'entreprise",
      info = "<em>nom: </em>{1}<br /><em>capital: </em>{2} $<br /><em>capital de transfert: </em>{3} $<br /><br/>Le capital de transfert représente la quantité d'argent transférée pour une période. Le maximum ne peut pas dépasser le capital de l'entreprise."
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
  cityhall = {
    title = "Hôtel de ville",
    identity = {
      title = "Nouvelle identité",
      description = "Creez une nouvelle identité, frais de création = {1} $.",
      prompt_firstname = "Entrez votre prénom:",
      prompt_name = "Entrez votre nom de famille:",
      prompt_age = "Entrez votre âge:"
    },
    menu = {
      title = "Identité",
      info = "<em>Nom: </em>{1}<br /><em>Prénom: </em>{2}<br /><em>Age: </em>{3}<br /><em> n° d'immatriculation: </em>{4}<br /><em>téléphone: </em>{5}"
    }
  },
  police = {
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
      }
    },
    menu = {
      handcuff = {
        title = "Menotter",
        description = "Menotter/démenotter le joueur le plus proche."
      },
      putinveh = {
        title = "Mettre dans le véhicule",
        description = "Mettre le joueur le plus proche dans le véhicule le plus proche."
      },
      askid = {
        title = "Demander les papiers",
        description = "Demander les papiers d'identité du joueur le plus proche.",
        request = "Voulez vous montrer vos papiers d'identité ?",
        request_hide = "Fermer les informations d'identité."
      },
      check = {
        title = "Fouiller le joueur",
        description = "Fouiller l'argent, les objets et les armes du joueur le plus proche.",
        request_hide = "Fermer le rapport de fouille.",
        info = "<em>argent: </em>{1} $<br /><br /><em>inventaire: </em>{2}<br /><br /><em>armes: </em>{3}"
      }
    },
    identity = {
      info = "<em>Nom: </em>{1}<br /><em>Prénom: </em>{2}<br /><em>Age: </em>{3}<br /><em>n° d'immatriculation: </em>{4}<br /><em>Téléphone: </em>{5}<br /><em>Entreprise: </em>{6}<br /><em>Capital de l'entreprise: </em>{7} $"
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
      description = "Appelez un service ou un n° d'urgence."
    }
  },
  emotes = {
    title = "Emotes",
    clear = {
      title = "> Stopper",
      description = "Stopper toutes les emotes en cours."
    }
  },
  garage = {
    title = "Garage ({1})",
    owned = {
      title = "Mes véhicules",
      description = "Véhicules m'appartenant"
    },
    buy = {
      title = "Acheter",
      description = "Acheter des véhicules.",
      info = "{1} $<br /><br />{2}"
    },
    store = {
      title = "Rentrer au garage",
      description = "Rentrez votre véhicule au garage."
    }
  },
  gunshop = {
    title = "Magasin d'armes ({1})",
    prompt_ammo = "Quantité de munition à acheter pour {1}:",
    info = "<em>Arme: </em> {1} $<br /><em>Munition: </em> {2} $/u<br /><br />{3}"
  },
  market = {
    title = "Supérette ({1})",
    prompt = "Quantité de {1} à acheter:",
    info = "{1} $<br /><br />{2}"
  },
  skinshop = {
    title = "Magasin de vêtements"
  }
}

return lang
