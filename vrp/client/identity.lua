-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.identity then return end

local Identity = class("Identity", vRP.Extension)

-- METHODS

function Identity:__construct()
  vRP.Extension.__construct(self)

  self.registration = "000AAA"
end

-- TUNNEL
Identity.tunnel = {}

function Identity.tunnel:setRegistrationNumber(registration)
  self.registration = registration
end

vRP:registerExtension(Identity)
