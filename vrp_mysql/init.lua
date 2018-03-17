local Proxy = module("vrp", "lib/Proxy")

local vRP = Proxy.getInterface("vRP")

-- register "vrp_mysql" DB driver

local tasks = {}

AddEventHandler("vRP:MySQL_task", function(task_id, data)
--  print("vRP:MySQL_task "..task_id)
  local cb = tasks[task_id]
  if data.status == 1 then
    if cb then
      if data.mode == 0 then
        cb(data.affected or 0)
      elseif data.mode == 1 then
        cb(data.scalar or 0)
      elseif data.mode == 2 then
        cb(data.rows or {}, data.affected or 0) -- rows, affected
      end
    end
  elseif data.status == -1 then
    print("[vRP] task "..task_id.." failed.")
  end

  tasks[task_id] = nil
end)

local task_id = -1
AddEventHandler("vRP:MySQL_taskid", function(_task_id)
--  print("vRP:MySQL_taskid ".._task_id)
  task_id = _task_id
end)

-- host can be "host" or "host:port"
local function on_init(cfg)
  -- parse port in host as "ip:port"
  local host = cfg.host
  local host_parts = splitString(host,":")
  if #host_parts >= 2 then
    host = host_parts[1]..";port="..host_parts[2]
  end

  local config = "server="..host..";uid="..cfg.user..";pwd="..cfg.password..";database="..cfg.database..";"

  exports.vrp_mysql:createConnection("vRP", config)
  return true
end

local function on_prepare(name, query)
  exports.vrp_mysql:createCommand("vRP/"..name, query)
end

-- generic query
local function on_query(name, args, mode)
  if mode == "execute" then
    mode = 0
  elseif mode == "scalar" then
    mode = 1
  else
    mode = 2
  end

  local r = async()

  -- TriggerEvent("vRP:MySQL:query", path, args)
  if not (type(args) == "table") then
    args = {}
  end

  -- force args to be a C# dictionary
  args._none = " "

  TriggerEvent("vRP:MySQL_query", "vRP/"..name, args, mode)
  tasks[task_id] = r

  return r:wait()
end

local function tick()
  TriggerEvent("vRP:MySQL_tick")
  SetTimeout(10, tick)
end
tick()

SetTimeout(4000, function()
  vRP.registerDBDriver("vrp_mysql", on_init, on_prepare, on_query)
end)
