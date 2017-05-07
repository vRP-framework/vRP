local lang = {
  common = {
    no_player_near = "~r~Pas de joueur à proximité.",
    invalid_value = "~r~Valeur incorrecte.",
    invalid_name = "~r~Nom incorrect."
  },
  survival = {
    starving = "Faim",
    thirsty = "Soif"
  },
  money = {
    given = "Vous avez donné ~r~{1}$.",
    received = "Vous avez recu ~g~{1}$.",
    not_enough = "~r~Pas assez d'argent.",
    paid = "Payé ~r~{1}$.",
    give = {
      title = "Donner de l'argent",
      description = "Donnez de l'argent au joueur le plus proche.",
      prompt = "Montant à donner:"
    }
  },
  inventory = {
    title = "Inventaire",
    description = "Ouvrir l'inventaire.",
    iteminfo = "({1})<br /><br />{2}",
    give = {
      title = "Donner",
      description = "Donnez un item au joueur le plus proche.",
      prompt = "Quantité à donner (max {1}):",
      given = "Vous avez donné ~r~{1} ~s~{2}.",
      received = "Vous avez recu ~g~{1} ~s~{2}.",
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
    title = "Office des commerces",
    directory = {
      title = "Annuaire",
      description = "Annuaire des entreprises",
      dprev = "> Précédent",
      dnext = "> Suivant",
      info = "<em>capital: </em>{1} $<br /><em>propriétaire: </em>{2} {3}<br /><em>n° de registre: </em>{4}"
    },
    info = {
      title = "Information sur l'entreprise",
      info = "<em>Nom: </em>{1}<br /><em>capital: </em>{2} $<br /><em>capital de transfert: </em>{3} $<br /><br/>Le capital de transfert représente la quantité d'argent transféré pour une période. Le maximum ne dois pas dépasser le capital initial."
    },
    addcapital = {
      title = "Ajout de capital",
      description = "Augmentez le capital de votre entreprise.",
      prompt = "Montant a ajouter à votre capital:",
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
      prompt_age = "Entrez votre âge:",
    },
    menu = {
      title = "Identité",
      info = "<em>Nom: </em>{1}<br /><em>Prénom: </em>{2}<br /><em>Age: </em>{3}<br /><em>Identité n°: </em>{4}"
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
