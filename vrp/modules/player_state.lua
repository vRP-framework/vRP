local cfg = module("cfg/player_state")
local lang = vRP.lang

-- client -> server events
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
  local player = source
  local data = vRP.getUserDataTable(user_id)
  local tmpdata = vRP.getUserTmpTable(user_id)

  if first_spawn then -- first spawn
    -- cascade load customization then weapons
    if data.customization == nil then
      data.customization = cfg.default_customization
    end

    if not data.position and cfg.spawn_enabled then
      local x = cfg.spawn_position[1]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local y = cfg.spawn_position[2]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      local z = cfg.spawn_position[3]+math.random()*cfg.spawn_radius*2-cfg.spawn_radius
      data.position = {x=x,y=y,z=z}
    end

    if data.position then -- teleport to saved pos
      vRPclient.teleport(source,data.position.x,data.position.y,data.position.z)
    end

    if data.customization then
      vRPclient.setCustomization(source,data.customization) 
      if data.weapons then -- load saved weapons
        vRPclient.giveWeapons(source,data.weapons,true)

        if data.health then -- set health
          vRPclient.setHealth(source,data.health)
          SetTimeout(5000, function() -- check coma, kill if in coma
            if vRPclient.isInComa(player) then
              vRPclient.killComa(player)
            end
          end)
        end
      end
    else
      if data.weapons then -- load saved weapons
        vRPclient.giveWeapons(source,data.weapons,true)
      end

      if data.health then
        vRPclient.setHealth(source,data.health)
      end
    end


    -- notify last login
    SetTimeout(15000,function()
      vRPclient._notify(player,lang.common.welcome({tmpdata.last_login}))
    end)
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

  vRPclient._playerStateReady(source, true)
end)

-- updates

function tvRP.updatePos(x,y,z)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    local tmp = vRP.getUserTmpTable(user_id)
    if data and (not tmp or not tmp.home_stype) then -- don't save position if inside home slot
      data.position = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
    end
  end
end

function tvRP.updateWeapons(weapons)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.weapons = weapons
    end
  end
end

function tvRP.updateCustomization(customization)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.customization = customization
    end
  end
end

function tvRP.updateHealth(health)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
      data.health = health
    end
  end
end
