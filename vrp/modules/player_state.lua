local PlayerState = class("PlayerState", vRP.Extension)

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/player_state")
end

-- EVENT

PlayerState.event = {}

function PlayerState.event:characterLoad(user)
    -- cascade load customization then weapons
    if not user.cdata.customization then
      user.cdata.customization = self.cfg.default_customization
    end

    if not user.cdata.position and self.cfg.spawn_enabled then
      local x = self.cfg.spawn_position[1]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
      local y = self.cfg.spawn_position[2]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
      local z = self.cfg.spawn_position[3]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
      user.cdata.position = {x=x,y=y,z=z}
    end

    if user.cdata.position then -- teleport to saved pos
      vRP.EXT.Base.remote.teleport(user.source,user.cdata.position.x,user.cdata.position.y,user.cdata.position.z)
    end

    if user.cdata.customization then
      self.remote.setCustomization(user.source,user.cdata.customization) 

      if user.cdata.weapons then -- load saved weapons
        self.remote.giveWeapons(user.source,user.cdata.weapons,true)

        --[[
        if user.cdata.health then -- set health
          self.remote.setHealth(user.source,user.cdata.health)
          SetTimeout(5000, function() -- check coma, kill if in coma
            if self.remote.isInComa(user.source) then
              self.remote.killComa(user.source)
            end
          end)
        end
        --]]
      end
    else
      if user.cdata.weapons then -- load saved weapons
        self.remote.giveWeapons(user.source,user.cdata.weapons,true)
      end

      --[[
      if user.cdata.health then
        self.remote.setHealth(user.source,user.cdata.health)
      end
      --]]
    end

    --[[
  else -- not first spawn (player died), don't load weapons, empty wallet, empty inventory
    vRP.setHunger(user_id,0)
    vRP.setThirst(user_id,0)
    vRP.clearInventory(user_id)

    if cfg.clear_phone_directory_on_death then
      data.phone_directory = {} -- clear phone directory after death
    end

    if cfg.lose_aptitudes_on_death then
      data.gaptitudes = {} -- clear aptitudes after death
    end

    vRP.setMoney(user_id,0)

    -- disable handcuff
    vRPclient._setHandcuffed(player,false)

    if cfg.spawn_enabled then -- respawn
      local x = cfg.spawn_position[1]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local y = cfg.spawn_position[2]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local z = cfg.spawn_position[3]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      data.position = {x=x,y=y,z=z}
      vRPclient._teleport(source,x,y,z)
    end

    -- load character customization
    if data.customization then
      vRPclient._setCustomization(source,data.customization)
    end
  end
  --]]

  self.remote._setStateReady(user.source, true)
end

function PlayerState.event:characterUnload(user)
  self.remote._setStateReady(user.source, false)
end

-- TUNNEL
PlayerState.tunnel = {}

function PlayerState.tunnel:updatePos(x,y,z)
  local user = vRP.users_by_source[source]
  if user then
--    if  then -- don't save position if inside home slot
      user.cdata.position = {x,y,z}
--    end
  end
end

function PlayerState.tunnel:updateWeapons(weapons)
  local user = vRP.users_by_source[source]
  if user then
    user.cdata.weapons = weapons
  end
end

function PlayerState.tunnel:updateCustomization(customization)
  local user = vRP.users_by_source[source]
  if user then
    user.cdata.customization = customization
  end
end

vRP:registerExtension(PlayerState)
