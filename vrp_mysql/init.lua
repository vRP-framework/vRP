
local function tick()
  TriggerEvent("vRP:MySQL_tick")
  SetTimeout(10, tick)
end
tick()
