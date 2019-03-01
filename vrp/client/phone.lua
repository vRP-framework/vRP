if not vRP.modules.phone then return end

local Phone = class("Phone", vRP.Extension)

-- METHODS

function Phone:__construct()
  vRP.Extension.__construct(self)
end

-- EVENT
Phone.event = {}

function Phone.event:speakingChange(speaking)
  vRP.EXT.Audio:setVoiceState("phone", speaking)
end

-- TUNNEL
Phone.tunnel = {}

vRP:registerExtension(Phone)
