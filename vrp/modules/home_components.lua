-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.home_components then return end

local lang = vRP.lang

-- Chest

local Chest = class("chest", vRP.EXT.Home.Component)

function Chest:load()
  self.point_id = "vRP:home:component:chest:"..self.index
end

function Chest:enter(user)
  local menu
  local function enter(user)
    if user.cid == self.slot.owner_id then -- owner
      menu = user:openChest("home:"..self.slot.owner_id, self.cfg.weight or 200)
    end
  end

  local function leave(user)
    if menu then
      user:closeMenu(menu)
    end
  end

  local x,y,z = self.x, self.y, self.z
  local ment = clone(vRP.EXT.home_components.cfg.chest.map_entity)
  ment[2].pos = {x,y,z-1}
  vRP.EXT.Map.remote._setEntity(user.source,self.point_id,ment[1],ment[2])

  user:setArea(self.point_id,x,y,z,1,1.5,enter,leave)
end

function Chest:leave(user)
  vRP.EXT.Map.remote._removeEntity(user.source,self.point_id)
  user:removeArea(self.point_id)
end

-- Wardrobe

local Wardrobe = class("wardrobe", vRP.EXT.Home.Component)

local function e_wardrobe_remove(menu)
  -- save sets to db
  vRP:setCData(menu.user.cid,"vRP:home:wardrobe", msgpack.pack(menu.data.sets))
end

function Wardrobe:load()
  self.point_id = "vRP:home:component:wardrobe:"..self.index
end

function Wardrobe:enter(user)
  local menu
  local function enter(user)
    if user.cid == self.slot.owner_id then -- if owner
      -- load sets
      local sdata = vRP:getCData(user.cid, "vRP:home:wardrobe")
      local sets
      if sdata and string.len(sdata) > 0 then
        sets = msgpack.unpack(sdata)
      end
      if not sets then sets = {} end

      -- notify player if wearing a uniform
      if user:hasCloak() then
        vRP.EXT.Base.remote._notify(user.source,lang.common.wearing_uniform())
      end

      menu = user:openMenu("home:component:wardrobe", {sets = sets})
      menu:listen("remove", e_wardrobe_remove)
    end
  end

  local function leave(user)
    if menu then
      user:closeMenu(menu)
    end
  end

  local x,y,z = self.x, self.y, self.z
  local ment = clone(vRP.EXT.home_components.cfg.wardrobe.map_entity)
  ment[2].pos = {x,y,z-1}
  vRP.EXT.Map.remote._setEntity(user.source,self.point_id,ment[1],ment[2])

  user:setArea(self.point_id,x,y,z,1,1.5,enter,leave)
end

function Wardrobe:leave(user)
  vRP.EXT.Map.remote._removeEntity(user.source,self.point_id)
  user:removeArea(self.point_id)
end

-- Gametable

local Gametable = class("gametable", vRP.EXT.Home.Component)

function Gametable:load()
  self.point_id = "vRP:home:component:gametable:"..self.index
end

function Gametable:enter(user)
  local menu
  local function enter(user)
    if user.cid == self.slot.owner_id then -- if owner
      menu = user:openMenu("home:component:gametable")
    end
  end

  local function leave(user)
    if menu then
      user:closeMenu(menu)
    end
  end

  local x,y,z = self.x, self.y, self.z

  local ment = clone(vRP.EXT.home_components.cfg.gametable.map_entity)
  ment[2].pos = {x,y,z-1}
  vRP.EXT.Map.remote._setEntity(user.source,self.point_id,ment[1],ment[2])

  user:setArea(self.point_id,x,y,z,1,1.5,enter,leave)
end

function Gametable:leave(user)
  vRP.EXT.Map.remote._removeEntity(user.source,self.point_id)
  user:removeArea(self.point_id)
end

-- Transformer

local Transformer = class("transformer", vRP.EXT.Home.Component)

function Transformer:load()
  self.point_id = "vRP:home:component:transformer:"..self.index
  self.transformer_id = "vRP:home:component:transformer:"..self.slot.type.."_"..self.slot.id.."_"..self.index


  self.cfg.cfg.position = {self.x, self.y, self.z}
  vRP.EXT.Transformer:set(self.transformer_id, self.cfg.cfg)
end

function Transformer:unload()
  vRP.EXT.Transformer:remove(self.transformer_id)
end

function Transformer:enter(user)
  local ment = clone(self.cfg.map_entity)
  if ment then
    ment[2].pos = {self.x,self.y,self.z-1}
    vRP.EXT.Map.remote._setEntity(user.source,self.point_id,ment[1],ment[2])
  end
end

function Transformer:leave(user)
  if self.cfg.map_entity then
    vRP.EXT.Map.remote._removeEntity(user.source, self.point_id)
  end
end

-- Radio

local Radio = class("radio", vRP.EXT.Home.Component)

function Radio:load()
  self.point_id = "vRP:home:component:radio:"..self.index
  self.source_position = self.cfg.position or {self.x,self.y,self.z+1}
end

function Radio:enter(user)
  -- build radio menu entry

  local menu
  local function enter(user)
    menu = user:openMenu("home:component:radio", {component = self})
  end

  local function leave(user)
    if menu then
      user:closeMenu(menu)
    end
  end

  local x,y,z = self.x, self.y, self.z

  local ment = clone(vRP.EXT.home_components.cfg.radio.map_entity)
  ment[2].pos = {x,y,z-1}
  vRP.EXT.Map.remote._setEntity(user.source,self.point_id,ment[1],ment[2])

  user:setArea(self.point_id,x,y,z,1,1.5,enter,leave)

  -- auto play station
  if self.station then
    local x,y,z = table.unpack(self.source_position)
    vRP.EXT.Audio.remote._setAudioSource(user.source, self.point_id, self.station, 0.5, x, y, z, 50)
  end
end

function Radio:leave(user)
  -- remove radio menu entry
  vRP.EXT.Map.remote._removeEntity(user.source,self.point_id)
  user:removeArea(self.point_id)

  -- auto stop station
  if self.station then
    vRP.EXT.Audio.remote._removeAudioSource(user.source, self.point_id)
  end
end

function Radio:off()
  if self.station then
    self.station = nil

    -- remove radio source for all players
    for user in pairs(self.slot.users) do
      vRP.EXT.Audio.remote._removeAudioSource(user.source, self.point_id)
    end
  end
end

function Radio:play(name)
  local station = self.cfg.stations[name]

  if station then
    self.station = station
    local x,y,z = table.unpack(self.source_position)

    -- apply station change to players
    for user in pairs(self.slot.users) do
      vRP.EXT.Audio.remote._setAudioSource(user.source, self.point_id, self.station, 0.5, x, y, z, 50)
    end
  end
end

-- Extension

local home_components = class("home_components", vRP.Extension)

-- PRIVATE METHODS

-- menu: wardrobe
local function menu_wardrobe(self)
  local function m_save(menu)
    local user = menu.user
    local sets = menu.data.sets

    local setname = user:prompt(lang.home.wardrobe.save.prompt(), "")
    setname = sanitizeString(setname, self.sanitizes.text[1], self.sanitizes.text[2])
    if string.len(setname) > 0 then
      -- save custom
      local custom = vRP.EXT.PlayerState.remote.getCustomization(user.source)
      sets[setname] = custom

      user:actualizeMenu()
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  local function m_use(menu, name)
    local user = menu.user
    local sets = menu.data.sets

    local custom = sets[name]
    if custom then
      vRP.EXT.PlayerState.remote._setCustomization(user.source,custom)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("home:component:wardrobe", function(menu)
    menu.title =lang.home.wardrobe.title()
    menu.css.header_color = "rgba(0,255,125,0.75)"

    menu:addOption(lang.home.wardrobe.save.title(), m_save)

    -- sets
    for name in pairs(menu.data.sets) do
      menu:addOption(name, m_use, nil, name)
    end
  end)
end

-- menu: gametable
local function menu_gametable(self)
  local function m_launch_bet(menu)
    local user = menu.user

    local amount = parseInt(user:prompt(lang.home.gametable.bet.prompt(), ""))
    if amount > 0 then
      if user:tryPayment(amount) then
        vRP.EXT.Base.remote._notify(user.source,lang.home.gametable.bet.started())

        -- init bet total and players (add by default the bet launcher)
        local bet_total = amount 
        local bet_users = {}
        local bet_opened = true
        table.insert(bet_users, user)

        local close_bet = function()
          if bet_opened then
            bet_opened = false
            -- select winner
            local wuser = bet_users[math.random(1,#bet_users)]
            wuser:giveWallet(bet_total)
            vRP.EXT.Base.remote._notify(wuser.source,lang.money.received({bet_total}))
            vRP.EXT.Base.remote._playAnim(wuser.source,true,{{"mp_player_introck","mp_player_int_rock",1}},false)
          end
        end

        -- send bet request to all nearest players
        local players = vRP.EXT.Base.remote.getNearestPlayers(user.source,7)
        local pcount = 0
        for player in pairs(players) do
          pcount = pcount+1
          local nuser = vRP.users_by_source[player]

          if nuser then -- request
            async(function() -- non blocking
              if nuser:request(lang.home.gametable.bet.request({amount}), 30) and bet_opened then
                if nuser:tryPayment(amount) then -- register player bet
                  bet_total = bet_total+amount
                  table.insert(bet_users, nuser)
                  vRP.EXT.Base.remote._notify(nuser.source,lang.money.paid({amount}))
                else
                  vRP.EXT.Base.remote._notify(nuser.source,lang.money.not_enough())
                end
              end

              pcount = pcount-1
              if pcount == 0 then -- autoclose bet, everyone is ok
                close_bet()
              end
            end)
          end
        end

        -- bet timeout
        SetTimeout(32000, close_bet)
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("home:component:gametable", function(menu)
    menu.title = lang.home.gametable.title()
    menu.css.header_color = "rgba(0,255,125,0.75)"

    menu:addOption(lang.home.gametable.bet.title(), m_launch_bet, lang.home.gametable.bet.description())
  end)
end

-- menu: radio
local function menu_radio(self)
  local function m_select(menu, name)
    menu.data.component:play(name)
  end

  local function m_off(menu)
    menu.data.component:off()
  end

  vRP.EXT.GUI:registerMenuBuilder("home:component:radio", function(menu)
    menu.title = lang.home.radio.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    for name in pairs(menu.data.component.cfg.stations) do
      menu:addOption(name, m_select, nil, name)
    end

    menu:addOption(lang.home.radio.off.title(), m_off)
  end)
end

-- METHODS

function home_components:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/home_components")
  self.sanitizes = module("vrp", "cfg/sanitizes")

  menu_wardrobe(self)
  menu_gametable(self)
  menu_radio(self)

  vRP.EXT.Home:registerComponent(Chest)
  vRP.EXT.Home:registerComponent(Wardrobe)
  vRP.EXT.Home:registerComponent(Gametable)
  vRP.EXT.Home:registerComponent(Transformer)
  vRP.EXT.Home:registerComponent(Radio)
end

vRP:registerExtension(home_components)
