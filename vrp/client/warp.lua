-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)


if not vRP.modules.warp then return end

local Warp = class("Warp", vRP.Extension)

-- SUBCLASS

local PosEntity = vRP.EXT.Map.PosEntity

Warp.MapEntity = class("Warp", PosEntity)

function Warp.MapEntity:load()
  PosEntity.load(self)

  self.color = self.cfg.color or {0,255,125,125}
  self.speed = 0.5
  self.r = 0
  self.height = 0.75
  self.scale = 1.5
end

function Warp.MapEntity:frame(time)
  self.r = (self.r+360.0*self.speed*time)%360.0

  DrawMarker(1,self.pos[1],self.pos[2],self.pos[3]+self.height,0,0,0,self.r,0,0,self.scale,self.scale,0.1,self.color[1],self.color[2],self.color[3],self.color[4],0)
  DrawMarker(1,self.pos[1],self.pos[2],self.pos[3]+self.height,0,0,0,0,self.r,0,self.scale,self.scale,0.1,self.color[1],self.color[2],self.color[3],self.color[4],0)
  DrawMarker(1,self.pos[1],self.pos[2],self.pos[3]+self.height,0,0,0,90.0,self.r,0,self.scale,self.scale,0.1,self.color[1],self.color[2],self.color[3],self.color[4],0)
end

-- METHODS

function Warp:__construct()
  vRP.Extension.__construct(self)

  vRP.EXT.Map:registerEntity(Warp.MapEntity)
end

vRP:registerExtension(Warp)
