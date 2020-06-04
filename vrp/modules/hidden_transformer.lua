-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.hidden_transformer then return end

local lang = vRP.lang

local HiddenTransformer = class("HiddenTransformer", vRP.Extension)

-- PRIVATE METHODS

-- menu: hidden transformer informer
local function menu_informer(self)
  local function m_buy(menu, id)
    local user = menu.user

    local tr = vRP.EXT.Transformer.transformers["vRP:cfg_hidden:"..id]
    local price = self.cfg.informer.infos[id]

    if tr then
      if user:tryPayment(price) then
        vRP.EXT.Map.remote._setGPS(user.source, tr.cfg.position[1], tr.cfg.position[2]) -- set gps marker
        vRP.EXT.Base.remote._notify(user.source, lang.money.paid({price}))
        vRP.EXT.Base.remote._notify(user.source, lang.hidden_transformer.informer.bought())
      else
        vRP.EXT.Base.remote._notify(user.source, lang.money.not_enough())
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("hidden_transformer_informer", function(menu)
    menu.title = lang.hidden_transformer.informer.title()
    menu.css.header_color = "rgba(0,255,125,0.75)"

    -- add infos
    for id,price in pairs(self.cfg.informer.infos) do
      menu:addOption(id, m_buy, lang.hidden_transformer.informer.description({price}), id)
    end
  end)
end

local function bind_informer(self, user)
  if self.informer then
    local x,y,z = table.unpack(self.informer)

    local menu
    local function enter(user)
      menu = user:openMenu("hidden_transformer_informer")
    end

    local function leave(user)
      if menu then
        user:closeMenu(menu)
      end
    end

    -- add informer map_entity and area

    local ment = clone(self.cfg.informer.map_entity)
    ment[2].title = lang.hidden_transformer.informer.title()
    ment[2].pos = {x,y,z-1}
    vRP.EXT.Map.remote._setEntity(user.source,"vRP:informer",ment[1],ment[2])

    user:setArea("vRP:informer",x,y,z,1,1.5,enter,leave)
  end
end

-- METHODS

function HiddenTransformer:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/hidden_transformers")

  -- task: hidden placement
  local function hidden_placement_task()
    SetTimeout(300000, hidden_placement_task)

    local sdata = vRP:getSData("vRP:hidden_transformers")
    local hidden_transformers = {}
    if sdata and string.len(sdata) > 0 then
      hidden_transformers = msgpack.unpack(sdata)
    end

    for id, cfg_htr in pairs(self.cfg.hidden_transformers) do
      -- init entry
      local htr = hidden_transformers[id]
      if not htr then
        htr = {timestamp=os.time(), position=cfg_htr.positions[math.random(1,#cfg_htr.positions)]}
        hidden_transformers[id] = htr
      end

      -- remove hidden transformer if needs respawn
      if os.time()-htr.timestamp >= self.cfg.hidden_transformer_duration*60 then
        htr.timestamp = os.time()
        vRP.EXT.Transformer:remove("vRP:cfg_hidden:"..id)

        -- generate new position
        htr.position = cfg_htr.positions[math.random(1, #cfg_htr.positions)]
      end

      -- spawn if unspawned 
      if not vRP.EXT.Transformer.transformers["vRP:cfg_hidden:"..id] then
        cfg_htr.def.position = htr.position

        vRP.EXT.Transformer:set("vRP:cfg_hidden:"..id, cfg_htr.def)
      end
    end

    vRP:setSData("vRP:hidden_transformers", msgpack.pack(hidden_transformers)) -- save hidden transformers
  end
  async(function()
    hidden_placement_task()
  end)

  local function informer_placement_task()
    SetTimeout(self.cfg.informer.interval*60000, informer_placement_task)

    -- spawn informer
    self:spawnInformer()

    -- despawn informer after a while
    SetTimeout(self.cfg.informer.duration*60000, function()
      self:despawnInformer()
    end)
  end
  SetTimeout(self.cfg.informer.interval*60000,informer_placement_task)

  menu_informer(self)
end

function HiddenTransformer:spawnInformer()
  self:despawnInformer()

  -- informer pos
  self.informer = self.cfg.informer.positions[math.random(1, #self.cfg.informer.positions)]

  for id, user in pairs(vRP.users) do
    bind_informer(self, user)
  end
end

function HiddenTransformer:despawnInformer()
  if self.informer then
    for id,user in pairs(vRP.users) do -- remove informer data for all users
      vRP.EXT.Map.remote._removeEntity(user.source,"vRP:informer")
      user:removeArea("vRP:informer")
    end

    self.informer = nil
  end
end

-- EVENT
HiddenTransformer.event = {}

function HiddenTransformer.event:playerSpawn(user, first_spawn)
  if first_spawn then
    bind_informer(self, user)
  end
end

vRP:registerExtension(HiddenTransformer)
