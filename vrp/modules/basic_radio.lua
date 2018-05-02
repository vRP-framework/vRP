
local lang = vRP.lang
local cfg = module("cfg/radio")

local cgroups = {}
local rusers = {}

-- build groups connect graph
for k,v in pairs(cfg.channels) do
  for _,g1 in pairs(v) do
    local group = cgroups[g1]
    if not group then
      group = {}
      cgroups[g1] = group
    end

    for _,g2 in pairs(v) do
      group[g2] = true
    end
  end
end

-- connect the user to the radio
function vRP.connectRadio(user_id)
  if not rusers[user_id] then
    local player = vRP.getUserSource(user_id)
    if player then
      -- send map of players to connect to for this radio
      local groups = vRP.getUserGroups(user_id)
      local players = {}
      for ruser,_ in pairs(rusers) do -- each radio user
        for k,v in pairs(groups) do -- each player group
          for cgroup,_ in pairs(cgroups[k] or {}) do -- each group from connect graph for this group
            if vRP.hasGroup(ruser, cgroup) then -- if in group
              local rplayer = vRP.getUserSource(ruser) 
              if rplayer then
                players[rplayer] = true
              end
            end
          end
        end
      end

      vRPclient._playAudioSource(player, cfg.on_sound, 0.5)
      vRPclient.setupRadio(player, players)
      -- wait setup and connect all radio players to this new one
      for k,v in pairs(players) do
        vRPclient._connectVoice(k, "radio", player)
      end

      rusers[user_id] = true
    end
  end
end

-- disconnect the user from the radio
function vRP.disconnectRadio(user_id)
  if rusers[user_id] then
    rusers[user_id] = nil
    local player = vRP.getUserSource(user_id)
    if player then
      vRPclient._playAudioSource(player, cfg.off_sound, 0.5)
      vRPclient._disconnectRadio(player)
    end
  end
end

-- menu
vRP.registerMenuBuilder("main", function(add, data)
  local choices = {}
  local player = data.player
  local user_id = vRP.getUserId(player)
  if user_id then
    -- check if in a radio group
    local groups = vRP.getUserGroups(user_id)
    local ok = false
    for group,_ in pairs(groups) do
      if cgroups[group] then
        ok = true
        break
      end
    end

    if ok then
      choices[lang.radio.title()] = {function() 
        if rusers[user_id] then
          vRP.disconnectRadio(user_id) 
        else
          vRP.connectRadio(user_id) 
        end
      end}
    end
  end

  add(choices)
end)

-- events

AddEventHandler("vRP:playerLeave",function(user_id, source) 
  vRP.disconnectRadio(user_id)
end)

-- disconnect radio on group changes

AddEventHandler("vRP:playerLeaveGroup", function(user_id, group, gtype) 
  vRP.disconnectRadio(user_id)
end)

AddEventHandler("vRP:playerJoinGroup", function(user_id, group, gtype) 
  vRP.disconnectRadio(user_id)
end)
