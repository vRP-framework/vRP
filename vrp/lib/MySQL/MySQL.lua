local Debug = module("lib/Debug")

-- Result

local Result = {}

-- begin MySQL module
local MySQL = {}
local tasks = {}
local task_id = -1

AddEventHandler("vRP:MySQL:rtask_id", function(id)
  task_id = id
end)

AddEventHandler("vRP:MySQL:result", function(id, rows, affected)
  local cb = tasks[id]
  if cb then
    cb(rows, affected)
    tasks[id] = nil
  end
end)

-- host can be "host" or "host:port"
function MySQL.createConnection(name,host,user,password,db,debug)
  -- parse port in host as "ip:port"
  local host_parts = splitString(host,":")
  if #host_parts >= 2 then
    host = host_parts[1]..";port="..host_parts[2]
  end

  local config = "server="..host..";uid="..user..";pwd="..password..";database="..db..";"

  TriggerEvent("vRP:MySQL:createConnection", name, config)
end

function MySQL.createCommand(path, query)
  TriggerEvent("vRP:MySQL:createCommand", path, query)
end

function MySQL.query(path, args, cb)
  TriggerEvent("vRP:MySQL:query", path, args)
  tasks[task_id] = cb
end

-- return module
return MySQL
