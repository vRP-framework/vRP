
local lang = vRP.lang

local Radio = class("Radio", vRP.Extension)

-- SUBCLASS

Radio.User = class("User")

-- get group which makes a specific user a radio peer
-- return group name or nil if not a valid peer
function Radio.User:getRadioPeerGroup(user)
  for group in pairs(self:getGroups()) do -- each player group
    local cgroups = vRP.EXT.Radio.cgroups[group]
    if cgroups then
      for cgroup in pairs(cgroups) do -- each group from connect graph for this group
        if user:hasGroup(cgroup) then -- if in group
          return cgroup
        end
      end
    end
  end
end

function Radio.User:connectRadio()
  local rusers = vRP.EXT.Radio.rusers

  if not rusers[self] then
    -- send map of players to connect to for this radio
    local players = {}
    for ruser in pairs(rusers) do -- each radio user
      local group = self:getRadioPeerGroup(ruser)
      if group then
        players[ruser.source] = {
          group = group,
          group_title = vRP.EXT.Group:getGroupTitle(group),
          title = ruser.identity.firstname.." "..ruser.identity.name
        }
      end

      -- connect all radio players to this new radio player
      local rgroup = ruser:getRadioPeerGroup(self)
      if rgroup then
        vRP.EXT.Radio.remote._setupPlayers(ruser.source, {
          [self.source] = {
            group = rgroup,
            group_title = vRP.EXT.Group:getGroupTitle(rgroup),
            title = self.identity.firstname.." "..self.identity.name
          }
        })
      end
    end

    vRP.EXT.Audio.remote._playAudioSource(-1, vRP.EXT.Radio.cfg.on_sound, 1, 0,0,0, 30, self.source)

    -- connect to all radio players
    vRP.EXT.Radio.remote._setupPlayers(self.source, players)

    rusers[self] = true
  end
end

function Radio.User:disconnectRadio()
  local rusers = vRP.EXT.Radio.rusers

  if rusers[self] then
    rusers[self] = nil

    vRP.EXT.Audio.remote._playAudioSource(-1, vRP.EXT.Radio.cfg.off_sound, 1, 0,0,0, 30, self.source)
    vRP.EXT.Radio.remote._clearPlayers(self.source)
  end
end

-- METHODS

function Radio:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/radio")

  vRP.EXT.Audio:registerVoiceChannel("radio", self.cfg.radio_voice)

  self.cgroups = {} -- groups connect graph
  self.rusers = {} -- radio users, map of user

  -- build groups connect graph
  for k,v in pairs(self.cfg.channels) do
    for _,g1 in pairs(v) do
      local group = self.cgroups[g1]
      if not group then
        group = {}
        self.cgroups[g1] = group
      end

      for _,g2 in pairs(v) do
        group[g2] = true
      end
    end
  end

  -- main menu

  local function m_radio(menu)
    local user = menu.user

    if self.rusers[user] then
      user:disconnectRadio() 
    else
      user:connectRadio() 
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    local user = menu.user

    -- check if in a radio group
    local groups = user:getGroups()
    local ok = false
    for group in pairs(groups) do
      if self.cgroups[group] then
        ok = true
        break
      end
    end

    if ok then
      menu:addOption(lang.radio.title(), m_radio)
    end
  end)
end

-- EVENT
Radio.event = {}

function Radio.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- load additional css using the div api
    vRP.EXT.GUI.remote._setDiv(user.source, "radio_additional_css",".div_radio_additional_css{ display: none; }\n\n"..self.cfg.css,"")
  end
end


function Radio.event:characterUnload(user)
  user:disconnectRadio()
end

function Radio.event:playerLeaveGroup(user)
  user:disconnectRadio()
end

function Radio.event:playerJoinGroup(user)
  user:disconnectRadio()
end

vRP:registerExtension(Radio)
