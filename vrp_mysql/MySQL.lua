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

  if MySQL.debug and dpaths[task_id] then
    print("[vRP] MySQL end query "..dpaths[task_id].." ("..task_id..")")
    dpaths[task_id] = nil
  end
end)

local task_id = -1
AddEventHandler("vRP:MySQL_taskid", function(_task_id)
--  print("vRP:MySQL_taskid ".._task_id)
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

-- generic query
function MySQL._query(path, args, mode, cb)
  -- TriggerEvent("vRP:MySQL:query", path, args)
  if not (type(args) == "table") then
    args = {}
  end

  -- force args to be a C# dictionary
  args._none = " "

--  exports.vrp_mysql:query(path, args)
--  print("[vRP] try to query "..path.." id "..task_id)
  TriggerEvent("vRP:MySQL_query", path, args, mode)
  if MySQL.debug then
    print("[vRP] MySQL begin query (m"..mode..") "..path.." ("..task_id..")")
    dpaths[task_id] = path
  end

  tasks[task_id] = cb
end

-- do a query (multiple rows)
--- cb(rows, affected)
function MySQL.query(path, args, cb)
  MySQL._query(path, args, 2, cb)
end

-- do a scalar query (one row, one column)
--- cb(scalar)
function MySQL.scalar(path, args, cb)
  MySQL._query(path, args, 1, cb)
end

-- do a execute query (no results)
--- cb(affected)
function MySQL.execute(path, args, cb)
  MySQL._query(path, args, 0, cb)
end

-- return module
return MySQL
