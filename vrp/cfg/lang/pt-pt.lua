local lang = {
  common = {
    welcome = "Bem-vindo. Utilize as teclas do telefone para os menus.~n~ultima vez online: {1}",
    no_player_near = "~r~Não tem jogadores perto de si.",
    invalid_value = "~r~Valor Inválido.",
    invalid_name = "~r~Nome Inválido.",
    not_found = "~r~Não encontrado.",
    request_refused = "~r~Conexão recusada.",
    wearing_uniform = "~r~Atenção, esta a utilizar um uniforme.",
    not_allowed = "~r~Não autorizado."
  },
  weapon = {
    pistol = "Pistola"
  },
  survival = {
    starving = "Com fome",
    thirsty = "Com sede"
  },
  money = {
    display = "{1} <span class=\"symbol\">€</span>",
    given = "Deu ~r~{1}€.",
    received = "Recebeu ~g~{1}€.",
    not_enough = "~r~Dinheiro insuficiente.",
    paid = "Pagou ~r~{1}€.",
    give = {
      title = "Dar dinheiro",
      description = "Dar dinheiro ao jogador mais proximo.",
      prompt = "Valor que deseja dar:"
    }
  },
  inventory = {
    title = "Inventário",
    description = "Abrir Inventário.",
    iteminfo = "({1})<br /><br />{2}<br /><em>{3} kg</em>",
    info_weight = "Peso {1}/{2} kg",
    give = {
      title = "Dar",
      description = "Dar item ao jogador mais proximo.",
      prompt = "Quantidade a dar (max {1}):",
      given = "Deu ~r~{1} ~s~{2}.",
      received = "Recebeu ~g~{1} ~s~{2}.",
    },
    trash = {
      title = "Lixo",
      description = "Destruir itens.",
      prompt = "Quantidade para o lixo (max {1}):",
      done = "Mandas-te fora ~r~{1} ~s~{2}."
    },
    missing = "~r~Falta {2} {1}.",
    full = "~r~Inventário cheio.",
    chest = {
      title = "Cofre",
      already_opened = "~r~Este cofre ja está aberto por outra pessoa.",
      full = "~r~Cofre cheio.",
      take = {
        title = "Agarrar",
        prompt = "Quantidade de coisas que deseja agarrar (max {1}):"
      },
      put = {
        title = "Meter",
        prompt = "Quantidade de coisas que deseja meter (max {1}):"
      }
    }
  },
  atm = {
    title = "ATM",
    info = {
      title = "Informações",
      bank = "Banco: {1} €"
    },
    deposit = {
      title = "Depositar",
      description = "Depositar dinheiro na sua conta",
      prompt = "Insira o montante que deseja depositar:",
      deposited = "~r~{1}€~s~ depositados."
    },
    withdraw = {
      title = "Lavantar",
      description = "Levantar dinheiro da sua conta",
      prompt = "Insira o montate que deseja levantar:",
      withdrawn = "~g~{1}€ ~s~ retirados do banco.",
      not_enough = "~r~Não tem esse montante no seu banco."
    }
  },
  business = {
    title = "Centro de Negocios",
    directory = {
      title = "Directorio",
      description = "Diretorio de Negocios.",
      dprev = "> Anterior",
      dnext = "> Seguinte",
      info = "<em>Capital: </em>{1} €<br /><em>Dono: </em>{2} {3}<br /><em>Nº registo: </em>{4}<br /><em>Nº de telefone: </em>{5}"
    },
    info = {
      title = "Informação do Negocio",
      info = "<em>Nome: </em>{1}<br /><em>Capital: </em>{2} $<br /><em>Capital de transferencia: </em>{3} $<br /><br/>O Capital de transferencia é a quantidade de dinheiro que pode transferir num periodo de tempo, o maximo é o valor do capital do negócio."
    },
    addcapital = {
      title = "Adicionar capital",
      description = "Adicionar capital ao seu negocio.",
      prompt = "Montante a adicionar ao seu capital do negocio:",
      added = "~r~{1}€ ~s~adicionados ao capital do seu negocio."
    },
    launder = {
      title = "Lavagem de dinheiro",
      description = "Use o seu negócio para lavar dinheiro sujo.",
      prompt = "Montante de dinheiro sujo para lavagem (max {1} €): ",
      laundered = "~g~{1}€ ~s~limpo.",
      not_enough = "~r~Não tem dinheiro sujo suficiente."
    },
    open = {
      title = "Abrir negócio",
      description = "Abre o seu negócio, o investimento minimo para abrir o seu negócio é de {1} €.",
      prompt_name = "Nome do negócio (não poderá ser alterado futuramente, maximo de {1} carateres):",
      prompt_capital = "Capital inicial (min {1})",
      created = "~g~Negócio aberto."
      
    }
  },
  cityhall = {
    title = "Registo Civil",
    identity = {
      title = "Nova identidade",
      description = "Para criar uma nova identidade irá custar: {1} €.",
      prompt_firstname = "Seu primeiro nome:",
      prompt_name = "Seu apelido:",
      prompt_age = "Sua idade:",
    },
    menu = {
      title = "Identidade",
      info = "<em>Nome: </em>{1}<br /><em>Apelido: </em>{2}<br /><em>Idade: </em>{3}<br /><em>Nº de Cidadão: </em>{4}<br /><em>Nº Telefone: </em>{5}<br /><em>Morada: </em>{7}, {6}"
    }
  },
  police = {
    title = "Policia",
    wanted = "Nivel de procura {1}",
    not_handcuffed = "~r~Não algemado",
    cloakroom = {
      title = "Vestuário",
      uniform = {
        title = "Uniforme",
        description = "Vestir uniforme."
      }
    },
    pc = {
      title = "PC",
      searchreg = {
        title = "Procurar cidadão",
        description = "Procurar identificação pelo Nº de Cidadão.",
        prompt = "Inserir Nº de Cidadão:"
      },
      closebusiness = {
        title = "Fechar negócio",
        description = "Fechar o negócio do jogador mais proximo.",
        request = "Tem a certeza que deseja fechar o negócio {3} do cidadão {1} {2} ?",
        closed = "~g~Negócio fechado."
      },
      trackveh = {
        title = "Localizar veiculo",
        description = "Localizar veiculo pelo registo.",
        prompt_reg = "Insira o numero de registo:",
        prompt_note = "Insira o motivo da localização:",
        tracking = "~b~Localização iniciada.",
        track_failed = "~b~Localização de {1}~s~ ({2}) ~n~~r~Falhou.",
        tracked = "Localizado {1} ({2})"
      },
      records = {
        show = {
          title = "Mostar registo criminal",
          description = "Mostrar registo criminal por Nº de Cidadão."
        },
        delete = {
          title = "Limpar registo criminal",
          description = "Limpar registo criminal por Nº de Cidadão.",
          deleted = "~b~Registo criminal limpo."
        }
      }
    },
    menu = {
      handcuff = {
        title = "Algemar",
        description = "Algemar/Desalgemar o jogador mais proximo."
      },
      putinveh = {
        title = "Meter no veiculo",
        description = "Meter cidadão algemado mais proximo dentro de veiculo, no lugar do passageiro."
      },
      getoutveh = {
        title = "Tirar do veiculo",
        description = "Tirar cidadão algemado fora do veiculo."
      },
      askid = {
        title = "Pedir Identificação",
        description = "Pedir identificação do jogador mais proximo.",
        request = "Deseja mostrar a sua identificação ?",
        request_hide = "Esconder identificação.",
        asked = "A pedir a identificação..."
      },
      check = {
        title = "Revistar cidadão",
        description = "Revista se o cidadão possui dinheiro, algo no seu inventário e armas ao jogador mais proximo.",
        request_hide = "Esconder revista.",
        info = "<em>Dinheiro: </em>{1} €<br /><br /><em>Inventário: </em>{2}<br /><br /><em>Armas: </em>{3}",
        checked = "Foste revistado com sucesso."
      },
      seize = {
        seized = "Foi aprendido {2} ~r~{1}",
        weapons = {
          title = "Aprender armas",
          description = "Retira as armas do jogador mais proximo",
          seized = "~b~As suas armas foram aprendidas."
        },
        items = {
          title = "Aprender coisas ilegais",
          description = "Aprender material ilegal",
          seized = "~b~O seu material ilegal foi aprendido."
        }
      },
      jail = {
        title = "Prisão",
        description = "Prender/Libertar o cidadão mais proximo para/da na prisão mais perto.",
        not_found = "~r~Não foi encontrada nenhuma prisão.",
        jailed = "~b~Preso.",
        unjailed = "~b~Liberto.",
        notify_jailed = "~b~Acabou de ser preso.",
        notify_unjailed = "~b~Acabou de ser libertado."
      },
      fine = {
        title = "Multar",
        description = "Multar jogador mais proximo.",
        fined = "~b~Multado ~s~{2} € por ~b~{1}.",
        notify_fined = "~b~Foi multado no valor de ~s~ {2} € por ~b~{1}.",
        record = "[Multa] {2} € por {1}"
      },
      store_weapons = {
        title = "Guardar armas",
        description = "Guarda as armas no seu inventário."
      }
    },
    identity = {
      info = "<em>Nome: </em>{1}<br /><em>Apelido: </em>{2}<br /><em>Idade: </em>{3}<br /><em>N° de Cidadão: </em>{4}<br /><em>Nº de Telefone: </em>{5}<br /><em>Negócio: </em>{6}<br /><em>Capital do Negócio: </em>{7} $<br /><em>Morada: </em>{9}, {8}"
    }
  },
  emergency = {
    menu = {
      revive = {
        title = "Reanimar",
        description = "Reanimar cidadão mais proximo.",
        not_in_coma = "~r~O cidadão nao está em COMA."
      }
    }
  },
  phone = {
    title = "Telefone",
    directory = {
      title = "Contactos",
      description = "Abrir os contactos do telefone.",
      add = {
        title = "> Adicionar",
        prompt_number = "Insira o numero de telefone:",
        prompt_name = "Insira o nome do cidadão:",
        added = "~g~Contacto adicionado."
      },
      sendsms = {
        title = "Enviar SMS",
        prompt = "Insira a mensagem (max {1} carateres):",
        sent = "~g~ Envidado para n°{1}.",
        not_sent = "~r~ N°{1} inválido."
      },
      sendpos = {
        title = "Enviar localização",
      },
      remove = {
        title = "Apagar"
      }
    },
    sms = {
      title = "Historico de SMS",
      description = "Histórico de SMS recebidas.",
      info = "<em>{1}</em><br /><br />{2}",
      notify = "SMS~b~ {1}:~s~ ~n~{2}"
    },
    smspos = {
      notify = "SMS-Localização ~b~ {1}"
    },
    service = {
      title = "Serviçoes",
      description = "Livar para um serviço.",
      prompt = "Se preciso, insira uma mensagem para o serviço que pediu:",
      ask_call = "Recebeu uma chamada de {1}, deseja atender ? <em>{2}</em>",
      taken = "~r~Esta chamada ja foi atendida."
    },
    announce = {
      title = "Anuncio",
      description = "Mandar um anuncio para todos os cidadãos por alguns segundos.",
      item_desc = "{1} $<br /><br/>{2}",
      prompt = "O anuncio contem (10-1000 carateres): "
    }
  },
  emotes = {
    title = "Emotes",
    clear = {
      title = "> Limpar",
      description = "Limpar todos os emotes em curso."
    }
  },
  home = {
    buy = {
      title = "Comprar",
      description = "Comprar esta casa, o seu preço é {1} €.",
      bought = "~g~Comprado.",
      full = "~r~Esta casa já não está masi disponivel.",
      have_home = "~r~Já tem uma casa."
    },
    sell = {
      title = "Vender",
      description = "Vender a sua casa por {1} €",
      sold = "~g~Vendida.",
      no_home = "~r~Não tem cas aqui."
    },
    intercom = {
      title = "Interfone",
      description = "Use o interfone para entrar em casa.",
      prompt = "Numero:",
      not_available = "~r~Inválido.",
      refused = "~r~Entrada recusada.",
      prompt_who = "Quem é?:",
      asked = "A perguntar...",
      request = "Alguem quer entrar em sua casa: <em>{1}</em>"
    },
    slot = {
      leave = {
        title = "Sair"
      },
      ejectall = {
        title = "Expulsar todos",
        description = "Expulsar todas as vizitas, incluindo voce, e fechar a casa."
      }
    },
    wardrobe = {
      title = "Vestuário Pessoal",
      save = {
        title = "> Guardar",
        prompt = "Guardar com o nome de:"
      }
    },
    gametable = {
      title = "Mesa de apostas",
      bet = {
        title = "Comecar aposta",
        description = "Jogar com os cidadãos mais proximos, o vencedor será escolhido aleatoriamente.",
        prompt = "Montate da aposta:",
        request = "[APOSTA] Deseja apostar {1} € ?",
        started = "~g~Aposta feita."
      }
    }
  },
  garage = {
    title = "Garagem ({1})",
    owned = {
      title = "Meus veiculos",
      description = "Lista de carros que comprou."
    },
    buy = {
      title = "Comprar",
      description = "Comprar veiculos novos.",
      info = "{1} $<br /><br />{2}"
    },
    sell = {
      title = "Vender",
      description = "Vender veiculos seus."
    },
    rent = {
      title = "Alugar",
      description = "Alugar carro para esta sessão (irá perde-lo quando sair da sessão)."
    },
    store = {
      title = "Guardar",
      description = "Meter o carro na garagem."
    }
  },
  vehicle = {
    title = "Veiculo",
    no_owned_near = "~r~Não existe nenhum veiculo seu proximo.",
    trunk = {
      title = "Bagajeira",
      description = "Abrir a bagajeira do seu veiculo."
    },
    detach_trailer = {
      title = "Largar reboque",
      description = "Largar reboque."
    },
    detach_towtruck = {
      title = "Largar pronto socorro",
      description = "Largar pronto socorro."
    },
    detach_cargobob = {
      title = "Largar cargobob",
      description = "Largar cargobob."
    },
    lock = {
      title = "Fechar/Abrir",
      description = "Fechar ou abrir o veiculo."
    },
    engine = {
      title = "Ligar/Desligar motor",
      description = "Ligar ou desligar o motor do veiculo."
    },
    asktrunk = {
      title = "Perguntar apra abrir bagajeira",
      asked = "~g~A perguntar...",
      request = "Deseja abrir a bagajeira ?"
    },
    replace = {
      title = "Substituir veiculo",
      description = "Seubstiruir veiculo mais proximo."
    },
    repair = {
      title = "Reparar veiculo",
      description = "Reparar veiculo mais proximo."
    }
  },
  gunshop = {
    title = "Loja de armas ({1})",
    prompt_ammo = "Quantidade de munições que deseja comprar {1}:",
    info = "<em>Arma: </em> {1} €<br /><em>Munições: </em> {2} €/u<br /><br />{3}"
  },
  market = {
    title = "Loja ({1})",
    prompt = "Quantidade de {1} para comprar:",
    info = "{1} €<br /><br />{2}"
  },
  skinshop = {
    title = "Loja de Roupa"
  },
  cloakroom = {
    title = "Vestuário ({1})",
    undress = {
      title = "> Despir"
    }
  },
  itemtr = {
    informer = {
      title = "Informador Ilegar",
      description = "{1} €",
      bought = "~g~Localização enviada para o seu GPS."
    }
  },
  mission = {
    blip = "Missão ({1}) {2}/{3}",
    display = "<span class=\"name\">{1}</span> <span class=\"step\">{2}/{3}</span><br /><br />{4}",
    cancel = {
      title = "Cancelar missão"
    }
  },
  aptitude = {
    title = "Hibilidades",
    description = "Mostrar habilidades.",
    lose_exp = "Habilidade ~b~{1}/{2} ~r~-{3} ~s~experiencia.",
    earn_exp = "Habilidade ~b~{1}/{2} ~g~+{3} ~s~experiencia.",
    level_down = "Habilidade ~b~{1}/{2} ~r~baixou de nivel ({3}).",
    level_up = "Habilidade ~b~{1}/{2} ~g~subiu de nivel ({3}).",
    display = {
      group = "{1}: ",
      aptitude = "{1} NIVEL {3} EXXPERIENCIA {2}"
    }
  }
}

return lang
