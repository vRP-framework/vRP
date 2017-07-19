-- begin MySQL module
local MySQL = {}

MySQL.debug = false
local dpaths = {}

local tasks = {}

--[[
local function tick()
  SetTimeout(1, function() -- protect errors from breaking the loop
    SetTimeout(1000, tick) 

    local rmtasks = {}
    for id,cb in pairs(tasks) do
      local r = exports.vrp_mysql:checkTask(id)
      if r.status == 1 then
        cb(r.rows,r.affected) -- rows, affected
        table.insert(rmtasks, id)
      elseif r.status == -1 then
        print("[vRP] task "..id.." failed.")
        table.insert(rmtasks, id)
      end
    end

    -- remove done tasks
    for k,v in pairs(rmtasks) do
      tasks[v] = nil
    end
  end)
end
tick()
--]]

AddEventHandler("vRP:MySQL_task", function(task_id, data)
--  print("vRP:MySQL_task "..task_id)
  local cb = tasks[task_id]
  if cb then
    if data.status == 1 then
      cb(data.rows or {},data.affected or 0) -- rows, affected
    elseif r.status == -1 then
      print("[vRP] task "..id.." failed.")
    end

    tasks[task_id] = nil
  end

  if MySQL.debug and dpaths[task_id] then
    print("[vRP] MySQL end query "..dpaths[task_id].." ("..task_id..")")
    dpaths[task_id] = nil
  end
end)

local task_id = -1
AddEventHandler("vRP:MySQL_taskid", function(_task_id)
--  print("vRP:MySQL_task "..task_id)
  task_id = _task_id
end)

-- host can be "host" or "host:port"
function MySQL.createConnection(name,host,user,password,db,debug)
--  print("[vRP] try to create connection "..name)
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
--  print("[vRP] try to create command "..path)
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

--  exports.vrp_mysql:query(path, args)
  TriggerEvent("vRP:MySQL_query", path, args)
--  print("[vRP] try to query "..path.." id "..task_id)
  if MySQL.debug then
    print("[vRP] MySQL begin query "..path.." ("..task_id..")")
    dpaths[task_id] = path
  end

  tasks[task_id] = cb
end

-- return module
return MySQL
