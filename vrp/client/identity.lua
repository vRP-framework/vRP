local Identity = class("Identity", vRP.Extension)

-- METHODS

function Identity:__construct()
  vRP.Extension.__construct(self)

  self.registration_number = "000AAA"
end

function Identity:getRegistrationNumber()
  return self.registration_number
end

-- TUNNEL
Identity.tunnel = {}

function Identity.tunnel:setRegistrationNumber(registration)
  self.registration_number = registration
end

Identity.tunnel.getRegistrationNumber = Identity.getRegistrationNumber

vRP:registerExtension(Identity)
