-- begin MySQL module
local MySQL = {}
local tasks = {}

local function tick()
  local rmtasks = {}
  for id,cb in pairs(tasks) do
    local data = exports.vrp_mysql:checkTask(id)
    if data[1] then -- ok
      cb(data[2],data[3]) -- rows, affected
      table.insert(rmtasks, id)
    end
  end

  -- remove done tasks
  for k,v in pairs(rmtasks) do
    tasks[v] = nil
  end

  SetTimeout(10, tick) 
end
tick()

-- host can be "host" or "host:port"
function MySQL.createConnection(name,host,user,password,db,debug)
  print("[vRP] try to create connection "..name)
  -- parse port in host as "ip:port"
  local host_parts = splitString(host,":")
  if #host_parts >= 2 then
    host = host_parts[1]..";port="..host_parts[2]
  end

  local config = "server="..host..";uid="..user..";pwd="..password..";database="..db..";"

--  TriggerEvent("vRP:MySQL:createConnection", name, config)
  exports.vrp_mysql:createConnection(name, config)
end

function MySQL.createCommand(path, query)
  print("[vRP] try to create command "..path)
--  TriggerEvent("vRP:MySQL:createCommand", path, query)
  exports.vrp_mysql:createCommand(path, query)
end

function MySQL.query(path, args, cb)
  -- TriggerEvent("vRP:MySQL:query", path, args)
  if not (type(args) == "table") then
    args = {}
  end

  -- force args to be a C# dictionary
  args._none = " "

  local task_id = exports.vrp_mysql:query(path, args)
  print("[vRP] try to query "..path.." id "..task_id)
  tasks[task_id] = cb
end

-- return module
return MySQL
