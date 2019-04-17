
-- Translated by Tabarra & ncK
-- Compatible with vRP 2 - https://github.com/ImagicTheCat/vRP/commit/e0a3a9a64752f7c5ba0a3049abbac977a9047747
local lang = {
  common = {
    welcome = "Use <b>[SETA PARA CIMA]</b> para acessar seu telefone.~n~<br>Último login: {1}",
    no_player_near = "~r~Não tem player próximo a você.",
    invalid_value = "~r~Valor incorreto.",
    invalid_name = "~r~Nome incorreto.",
    not_found = "~r~Não encontrado.",
    request_refused = "~r~Pedido negado.",
    wearing_uniform = "~r~Cuidado, você está vestindo um uniforme.",
    not_allowed = "~r~Não permitido.",
    must_wait = "~r~Deve esperar {1} segundos.",
    menu = {
      title = "Menu"
    }
  },
  characters = {
    title = "[Personagens]",
    character = {
      title = "#{1}: {2} {3}",
      error = "~r~Personagem incorreto."
    },
    create = {
      title = "Criar",
      error = "~r~Não foi possível criar um novo personagem."
    },
    delete = {
      title = "Deletar",
      prompt = "ID do personagem que deseja deletar ?",
      error = "~r~Não foi possível deletar o personagem. #{1}."
    }
  },
  admin = {
    title = "Admin",
    call_admin = {
      title = "Ligar para admin",
      prompt = "Descreva seu problema: ",
      notify_taken = "Um admin está a caminho.",
      notify_already_taken = "Ticket já atendido.",
      request = "Ticket PARA ADMINS (user_id = {1}) dar TP para ?: {2}"
    },
    tptocoords = {
      title = "TP PARA AS COORDS",
      prompt = "Coords x,y,z: "
    },
    tptomarker = {
      title = "TP PARA O MARCADOR"
    },
    noclip = {
      title = "NOCLIP"
    },
    coords = {
      title = "SUA CORDENADA",
      hint = "Copie a cordenada usando Ctrl-A Ctrl-C"
    },
    custom_upper_emote = {
      title = "EMOTE SUPERIOR",
      prompt = "Animation sequence ('dict anim optional_loops' per line): "
    },
    custom_full_emote = {
      title = "EMOTE CUSTOM"
    },
    custom_emote_task = {
      title = "TAREFA CUSTOM",
      prompt = "NOME DA TAREFA: "
    },
    custom_sound = {
      title = "SOM CUSTOM",
      prompt = "Sound 'dict name': "
    },
    custom_model = {
      title = "MODEL CUSTOM",
      prompt = "Model hash or name: "
    },
    custom_audiosource = {
      title = "CUSTOM AUDIOSOURCE",
      prompt = "Audio source: name=url, omit url to delete the named source."
    },
    users = {
      title = "Usuários",
      by_id = {
        title = "> Por id",
        prompt = "ID do usuário: "
      },
      user = {
        title = "#{1}: {2}",
        info = {
          title = "Info",
          description = "<em>Localização: </em>{1}<br /><em>Fonte: </em>{2}<br /><em>Último login: </em>{3}<br /><em>ID do usuário: </em>{4}<br /><em>Banned: </em>{5}<br /><em>Whitelisted: </em>{6}<br /><br />(valid to update)"
        },
        kick = {
          title = "Kick",
          prompt = "Motivo: "
        },
        ban = {
          title = "Ban",
          prompt = "Motivo: "
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
          title = "TP EM MIM"
        },
        tpto = {
          title = "TP PARA"
        },
        groups = {
          title = "Grupos",
          description = "{1}<br /><br />(valid to update)"
        },
        group_add = {
          title = "Adicionar para o grupo",
          prompt = "Adicionar ao grupo: "
        },
        group_remove = {
          title = "Remover do grupo",
          prompt = "Grupo para remover: "
        },
        give_money = {
          title = "Dar dinheiro",
          prompt = "Quantidade: "
        },
        give_item = {
          title = "Dar item",
          prompt = "Full id: ",
          prompt_amount = "Quantidade: ",
          notify_failed = "Item inválido ou inventário cheio."
        }
      }
    }
  },
  weapon = {
    -- weapon translation by GTA 5 weapon name (lower case)
    pistol = "Pistola"
  },
  item = {
    medkit = {
      name = "Kit Médico",
      description = "Usado para reanimar pessoas inconscientes."
    },
    repairkit = {
      name = "Kit de Reparo Veicular",
      description = "Usado para reparar veículos."
    },
    dirty_money = {
      name = "Dinheiro Sujo",
      description = "Dinheiro obtido de forma ilegal."
    },
    money = {
      name = "Dinheiro",
      description = "Malote de dinheiro.",
      unpack = {
        title = "Abrir Malote",
        prompt = "Quanto deseja tirar do malote ? (max {1})"
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
      name = "{1} arma",
      description = "Arma {1}.",
      equip = {
        title = "Equipar"
      }
    },
    wammo = {
      name = "{1} munição",
      name_box = "{1} munição x{2}",
      description = "Munição para {1}.",
      load = {
        title = "Carregar",
        prompt = "Quanto deseja carregar ? (max {1})"
      },
      open = {
        title = "Abrir"
      }
    },
    bulletproof_vest = {
      name = "Colete a prova de balas",
      description = "Colete a prova de balas",
      wear = {
        title = "Vestir"
      }
    }
  },
  edible = {
    liquid = {
      action = "Beber",
      notify = "~b~Bebendo {1}."
    },
    solid = {
      action = "Comer",
      notify = "~o~Comendo {1}."
    },
    drug = {
      action = "Usar",
      notify = "~g~Usando {1}."
    }
  },
  survival = {
    starving = "fome",
    thirsty = "sede",
    coma_display = [[
      Você está em coma.<br />
      Para desistir da sua vida aperte <span class="key">[ESPAÇO]</span> (tempo mínimo: <span class="countdown" data-duration="{1}"></span>).<br /> 
      Vida restante: <span class="countdown" data-duration="{2}"></span>.
      ]]
  },
  money = {
    display = "{1} <span class=\"symbol\">$</span>",
    given = "Deu ~r~{1}$.",
    received = "Recebido ~g~{1}$.",
    not_enough = "~r~Sem dinheiro suficiente.",
    paid = "Pagou ~r~{1}$.",
    give = {
      title = "Doar Dinheiro",
      description = "Doar dinheiro para o jogador mais próximo.",
      prompt = "Quantidade para doar:"
    },
    transformer_recipe = "{1} $<br />"
  },
  inventory = {
    title = "Inventário",
    description = "Abrir inventário.",
    iteminfo = "({1})<br /><br />{2}<br /><em>{3} kg</em>",
    info_weight = "peso {1}/{2} kg",
    give = {
      title = "Doar",
      description = "Doar itens ao jogador mais próximo.",
      prompt = "Quantidade para doar (max {1}):",
      given = "Doado ~r~{1} ~s~{2}.",
      received = "Recebido ~g~{1} ~s~{2}.",
    },
    trash = {
      title = "Jogar fora",
      description = "Destruir itens.",
      prompt = "Quantidade (max {1}):",
      done = "Jogou fora ~r~{1} ~s~{2}."
    },
    missing = "~r~Faltando {2} {1}.",
    full = "~r~Inventário cheio.",
    chest = {
      title = "Báu",
      already_opened = "~r~Este báu já foi aberto por alguém.",
      full = "~r~Báu cheio.",
      take = {
        title = "Pegar",
        prompt = "Quantidade (max {1}):"
      },
      put = {
        title = "Colocar",
        prompt = "Quantidade (max {1}):"
      }
    },
    transformer_recipe = "{2} {1}<br />"
  },
  atm = {
    title = "Caixa Eletrônico",
    info = {
      title = "Info",
      bank = "banco: {1} $"
    },
    deposit = {
      title = "Depositar",
      description = "Carteira para banco",
      prompt = "Coloque o valor de dinheiro que deseja depositar:",
      deposited = "~r~{1}$~s~ depositado."
    },
    withdraw = {
      title = "Saque",
      description = "Banco para Carteira",
      prompt = "Coloque o valor de dinheiro que deseja sacar:",
      withdrawn = "~g~{1}$ ~s~sacado.",
      not_enough = "~r~Você não tem dinheiro suficiente no banco."
    }
  },
  business = {
    title = "Junta Comercial",
    identity = {
      title = "Junta Comercial",
      info = "<em>nome: </em>{1}<br /><em>capital: </em>{2} $"
    },
    directory = {
      title = "Empresas Abertas",
      description = "Empresas abertas.",
      dprev = "> Ante",
      dnext = "> Prox",
      info = "<em>capital: </em>{1} $<br /><em>dono: </em>{2} {3}<br /><em>n° registro: </em>{4}<br /><em>phone: </em>{5}"
    },
    info = {
      title = "Info de Empresas",
      info = "<em>nome: </em>{1}<br /><em>capital: </em>{2} $<br /><em>transferência de capital: </em>{3} $<br /><br/>Transferência de capital é um valor transferido por um tempo econômico, o valor máximo de transferência é o capital total da empresa."
    },
    addcapital = {
      title = "Adicionar capital",
      description = "Adicionar capital para sua empresa.",
      prompt = "Quantidade de dinheiro para inserir:",
      added = "~r~{1}$ ~s~adiciado ao capital de empresa."
    },
    launder = {
      title = "Lavagem de dinheiro",
      description = "Use sua empresa para lavar dinheiro.",
      prompt = "Quantidade de dinheiro sujo que deseja limpar (max {1} $): ",
      laundered = "~g~{1}$ ~s~lavado.",
      not_enough = "~r~Não tem dinheiro suficiente."
    },
    open = {
      title = "Abrir empresa",
      description = "Abra seu negócio, minímo de capital para se investir {1} $.",
      prompt_name = "Nome da empresa (não pode mudar após, max {1} chars):",
      prompt_capital = "Capital Inicial (min {1})",
      created = "~g~Empresa criada."
      
    }
  },
  identity = {
    title = "Identidade",
    citizenship = {
      title = "Cidadania",
      info = "<em>Nome: </em>{1}<br /><em>Sobrenome: </em>{2}<br /><em>Idade: </em>{3}<br /><em>RG n°: </em>{4}<br /><em>Telefone: </em>{5}",
    },
    cityhall = {
      title = "Prefeitura",
      new_identity = {
        title = "Nova identidade",
        description = "Criar nova identidade, custo = {1} $.",
        prompt_firstname = "Primeiro Nome:",
        prompt_name = "Sobrenome:",
        prompt_age = "Idade:",
      }
    }
  },
  police = {
    title = "Policía",
    wanted = "Procurado Rank {1}",
    not_handcuffed = "~r~Não algemado",
    cloakroom = {
      title = "Vestiário",
      uniform = {
        title = "Uniforme",
        description = "Colocar uniforme."
      }
    },
    pc = {
      title = "Sistema Do Estado",
      searchreg = {
        title = "Procura de Registro",
        description = "Achar identidade por registro.",
        prompt = "Entre número de registro:"
      },
      closebusiness = {
        title = "Fechar Empresa",
        description = "Fechar empresa do jogador mais próximo.",
        request = "Certeza que deseja fechar a empresa {3} possuída por {1} {2} ?",
        closed = "~g~Empresa fechada."
      },
      trackveh = {
        title = "Rastrear veículo",
        description = "Rastrear um veículo pelo seu registro.",
        prompt_reg = "Número de registro:",
        prompt_note = "Coloque uma nota no rastreio(motivo):",
        tracking = "~b~Rastreamento começou.",
        track_failed = "~b~Rastreando de {1}~s~ ({2}) ~n~~r~Falhou.",
        tracked = "Rastreado {1} ({2})"
      },
      records = {
        title = "Passagens",
        description = "Administra ficha criminal.",
        add = {
          title = "Adicionar",
          prompt = "Novo incidente:"
        },
        delete = {
          title = "Deletar",
          prompt = "Lembrar id para deletar ?"
        }
      }
    },
    menu = {
      handcuff = {
        title = "Algemar",
        description = "Algemar/Desalgemar jogador mais próximo."
      },
      drag = {
        title = "Arrastar",
        description = "Obriga o jogador mais próximo a te seguir."
      },
      putinveh = {
        title = "Colocar dentro do veículo",
        description = "Colocar o jogador algemado dentro de veículo mais próximo, como um passageiro."
      },
      getoutveh = {
        title = "Tirar do veículo",
        description = "Tira do veículo jogador algemado dentro de veículo."
      },
      askid = {
        title = "Pedir RG",
        description = "Pede RG do jogador mais próximo",
        request = "Deseja mostrar seu RG ?",
        request_hide = "Esconder RG.",
        asked = "Pedindo RG..."
      },
      check = {
        title = "Revistar",
        description = "Revista carteira, inventário e armas do jogador mais próximo.",
        checked = "~b~Você foi revistado.",
        info = {
          title = "Revista:",
          description = "<em>Carteira: </em>{1} $"
        }
      },
      seize = {
        seized = "~b~Suas armas e itens ilegais foram aprendidos.",
        title = "Aprende armas/ilegais",
        description = "Aprender itens ilegais do jogador mais próximo."
      },
      jail = {
        title = "Prender",
        description = "Prender/Soltar o jogador mais próximo dentro da jaula na delegacia.",
        not_found = "~r~Longe da cela.",
        jailed = "~b~PRESO.",
        unjailed = "~b~SOLTO.",
        notify_jailed = "~b~Você foi preso.",
        notify_unjailed = "~b~Você foi solto."
      },
      fine = {
        title = "Multa",
        description = "Multar o jogador mais próximo.",
        fined = "~b~Multado ~s~{2} $ por ~b~{1}.",
        notify_fined = "~b~Você foi multado ~s~ {2} $ por ~b~{1}.",
        record = "[Multa] {2} $ por {1}"
      },
      store_weapons = {
        title = "Guardar armas",
        description = "Guarda armas no inventário."
      }
    }
  },
  emergency = {
    menu = {
      revive = {
        title = "Reanimar",
        description = "Reanimar jogador mais próximo.",
        not_in_coma = "~r~Não está em coma."
      }
    }
  },
  phone = {
    title = "Telefone",
    directory = {
      title = "Contatos",
      description = "Abrir seus contatos.",
      add = {
        title = "> Adicionar",
        prompt_number = "Coloque o número que deseja adicionar:",
        prompt_name = "Coloque o nome:",
        added = "~g~Número adicionado."
      },
      sendsms = {
        title = "Enviar SMS",
        prompt = "Coloque sua mensagem (max {1} chars):",
        sent = "~g~ Enviado para n°{1}.",
        not_sent = "~r~ n°{1} indisponível."
      },
      sendpos = {
        title = "Enviar localização",
      },
      remove = {
        title = "Remover"
      },
      call = {
        title = "Ligar",
        not_reached = "~r~ n°{1} não atende."
      }
    },
    sms = {
      title = "Histórico de Mensagens",
      description = "Mensagens Recebidas.",
      info = "<em>{1}</em><br /><br />{2}",
      notify = "SMS~b~ {1}:~s~ ~n~{2}"
    },
    smspos = {
      notify = "SMS-Posição ~b~ {1}"
    },
    service = {
      title = "Serviços",
      description = "Veja os serviços oferecidos pela cidade.",
      prompt = "Se precisar, insira uma mensagem para seu serviço:",
      ask_call = "Recebendo {1} ligação, quer atende-la ? <em>{2}</em>",
      taken = "~r~Ligação já atendida."
    },
    announce = {
      title = "Anúnciar",
      description = "Coloque um anúncio na cidade.",
      item_desc = "{1} $<br /><br/>{2}",
      prompt = "Anúnciar (10-1000 letras): "
    },
    call = {
      ask = "Aceitar ligação de {1} ?",
      notify_to = "Ligando~b~ {1}...",
      notify_from = "Ligação recebida de ~b~ {1}...",
      notify_refused = "Ligar para ~b~ {1}... ~r~ refused."
    },
    hangup = {
      title = "Desligar",
      description = "Desligar (apenas ligação)."
    }
  },
  emotes = {
    title = "Emotes",
    clear = {
      title = "> Parar animação",
      description = "Para todas as animações."
    }
  },
  home = {
    address = {
      title = "Endereço",
      info = "{1}, {2}"
    },
    buy = {
      title = "Comprar",
      description = "Compre uma casa aqui, o preço é {1} $.",
      bought = "~g~Comprou.",
      full = "~r~Moradia Ocupada.",
      have_home = "~r~Você já tem uma casa!"
    },
    sell = {
      title = "Vender",
      description = "Vender sua casa por {1} $",
      sold = "~g~Vendida.",
      no_home = "~r~Você não é proprietário aqui."
    },
    intercom = {
      title = "Interfone",
      description = "Use interfone para entrar na sua casa ou na de um amigo.",
      prompt = "Número:",
      not_available = "~r~Não disponível.",
      refused = "~r~Recusou sua entrada.",
      prompt_who = "Diga quem é:",
      asked = "Interfonando...",
      request = "Alguém está pedindo para entrar na sua casa: <em>{1}</em>"
    },
    slot = {
      leave = {
        title = "Sair"
      },
      ejectall = {
        title = "Retirar todos da sua residência",
        description = "Retirar todos da sua residência."
      }
    },
    wardrobe = {
      title = "Guarda-Roupas",
      save = {
        title = "> Salvar",
        prompt = "Nome:"
      }
    },
    gametable = {
      title = "Mesa de Apostas",
      bet = {
        title = "Começar aposta",
        description = "Começe uma aposta com um jogador próximo a você.",
        prompt = "Valor da aposta:",
        request = "[Aposta] Você quer apostar {1} $ ?",
        started = "~g~Aposta iniciada."
      }
    },
    radio = {
      title = "Radio",
      off = {
        title = "> desligar"
      }
    }
  },
  garage = {
    title = "Garagem ({1})",
    owned = {
      title = "Seus veículos",
      description = "Seus veículos.",
      already_out = "Este veículo já está fora da garagem.",
      force_out = {
        request = "Este veículo já está fora da garagem, quer pagar a taxa de {1} $ para traze-lo de volta?"
      }
    },
    buy = {
      title = "Comprar",
      description = "Comprar veículos.",
      info = "{1} $<br /><br />{2}"
    },
    sell = {
      title = "Vender",
      description = "Vender veículos."
    },
    rent = {
      title = "Alugar",
      description = "Alugar veículo (Até se desconectar do servidor)."
    },
    store = {
      title = "Guardar",
      description = "Guarda seu veículo na garagem.",
      too_far = "Veículo distante.",
      wrong_garage = "Veículo não pode ser guardado nesta garagem.",
      stored = "Veículo guardado."
    }
  },
  vehicle = {
    title = "Veículo",
    no_owned_near = "~r~Nenhum veículo próximo",
    trunk = {
      title = "Trunk",
      description = "Abrir porta malas"
    },
    detach_trailer = {
      title = "Soltar Trailer",
      description = "Soltar trailer."
    },
    detach_towtruck = {
      title = "Soltar Reboque",
      description = "Soltar Reboque"
    },
    detach_cargobob = {
      title = "Soltar CargoBob",
      description = "Soltar CargoBob."
    },
    lock = {
      title = "Travar/Destravar",
      description = "Travar e Destravar veículo.",
      locked = "Vehicle travado.",
      unlocked = "Vehicle destravado."
    },
    engine = {
      title = "Motor on/off",
      description = "Liga e desliga motor do carro."
    },
    asktrunk = {
      title = "Abrir porta malas?",
      asked = "~g~Pedindo...",
      request = "Pediram para abrir seu porta malas ?"
    },
    replace = {
      title = "Desvirar",
      description = "Desvira veículo capotado."
    },
    repair = {
      title = "Consertar veículo",
      description = "Repara veículo mais próximo."
    }
  },
  shop = {
    title = "Loja ({1})",
    prompt = "Quantidade de {1} para comprar:",
    info = "{1} $<br /><br />{2}"
  },
  skinshop = {
    title = "Barbearia",
    info = {
      title = "Info",
      description = "Selecione uma opção de barbearia.<br /><br /><em>Preços: </em>{1} $"
    },
    model = "Model",
    texture = "Textura",
    palette = "Palette",
    color_primary = "Cor Primária",
    color_secondary = "Cor Secundária",
    opacity = "Opacidade",
    select_description = "{1}/{2} (left/right to select)"
  },
  cloakroom = {
    title = "Vestiário ({1})",
    undress = {
      title = "> Despir"
    }
  },
  transformer = {
    recipe_description = [[{1}<br /><br />{2}<div style="color: rgb(0,255,125)">=></div>{3}]],
    empty_bar = "Vázio"
  },
  hidden_transformer = {
    informer = {
      title = "Ilegal Informer",
      description = "{1} $",
      bought = "~g~Posição enviada ao seu GPS."
    }
  },
  mission = {
    title = "Missão ({1}) {2}/{3}",
    display = "<span class=\"name\">{1}</span> <span class=\"step\">{2}/{3}</span><br /><br />{4}",
    cancel = {
      title = "Cancelar missão"
    }
  },
  aptitude = {
    title = "Habilidades",
    description = "Mostrar habilidades.",
    lose_exp = "Habilidade ~b~{1}/{2} ~r~-{3} ~s~exp.",
    earn_exp = "Habilidade ~b~{1}/{2} ~g~+{3} ~s~exp.",
    level_down = "Habilidade ~b~{1}/{2} ~r~perdeu level ({3}).",
    level_up = "Habilidade ~b~{1}/{2} ~g~ganhou level ({3}).",
    display = {
      group = "{1}",
      aptitude = "{1} LVL {3} EXP {2}"
    },
    transformer_recipe = "[EXP] {3} {1}/{2}<br />"
  },
  radio = {
    title = "Radio ON/OFF",
    description = "Habilita Escuta PRIVADA [TEAM TEXT CHAT] e sinal ao vivo de GPS quando ligado."
  }
}

return lang
