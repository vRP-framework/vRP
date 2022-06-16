-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.misc then return end

local Misc = class("Misc", vRP.Extension)

function Misc:__construct()
  vRP.Extension.__construct(self)
  
end

vRP:registerExtension(Misc)