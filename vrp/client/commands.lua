-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.command then return end

local Command = class("Command", vRP.Extension)

function Command:__construct()
  vRP.Extension.__construct(self)

end


vRP:registerExtension(Command)