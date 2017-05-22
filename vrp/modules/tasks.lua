
-- this module define the tasks menu

local cfg = require("resources/vrp/cfg/tasks")
local lang = vRP.lang

local tasks = cfg.tasks

local menu = {name=lang.tasks.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

-- clear current tasks
menu[lang.tasks.clear.title()] = {function(player,choice) 
  vRPclient.stopTask(player)
end, lang.tasks.clear.description()}

local function ch_task(player,choice)
  local task = tasks[choice]
  if task then
    vRPclient.playTask(player,task)
  end
end

-- add tasks to the tasks menu
for k,v in pairs(tasks) do
  menu[k] = {ch_task}
end

-- add tasks menu to main menu

AddEventHandler("vRP:buildMainMenu",function(player) 
  local choices = {}
  choices[lang.tasks.title()] = {function() vRP.openMenu(player,menu) end}
  vRP.buildMainMenu(player,choices)
end)
