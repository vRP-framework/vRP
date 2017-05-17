-- new way, experimental, doesn't work yet
--local Mono = require("resources/vRP/lib/Mono")
--local lib = Mono.loadAssembly("resources/vRP/lib/MySQL/MySql.Data.dll").MySql.Data

local Debug = require("resources/vrp/lib/Debug")

-- global assembly loading, can create conflict with different mysql versions loaded
clr.System.Reflection.Assembly.LoadFrom("resources/vrp/lib/MySQL/MySql.Data.dll")
local lib = clr.MySql.Data

-- local lib = clr.MySql.Data
local lib_type = lib.MySqlClient.MySqlDbType

-- Result

local Result = {}

function Result:init()
  self._fields = 0

  if self.reader ~= nil then
    self._fields = cast(int,self.reader.FieldCount)
  end

  self.columns = {}
  for i=0,self:fields()-1 do
    self.columns[self:getName(i)] = i
  end
end

function Result:close() -- always close the result when unused
  if self.reader ~= nil then
    self.reader.Close()
    self.reader = nil
  end
end

function Result:fetch()
  if self.reader ~= nil and self.reader.HasRows then
    return not (cast(int,self.reader.Read()) == 0)
  else
    return false
  end
end

function Result:affected()
  if self.reader ~= nil then
    return cast(int,self.reader.RecordsAffected)
  else
    return 0
  end
end

function Result:getValue(col)
  if self.reader ~= nil then
    -- convert from name to index
    if type(col) == "string" then
      col = self:getIndex(col)
    end
    

    local v = nil

    if cast(int,self.reader.IsDBNull(col)) == 0 then
      local vtype = tostring(self.reader.GetFieldType(col))

      if vtype == "System.Int64" then
        v = cast(int,self.reader.GetInt64(col))
      elseif vtype == "System.Int32" then
        v = cast(int,self.reader.GetInt32(col))
      elseif vtype == "System.Float" or vtype == "System.Double" then
        v = cast(double,self.reader.GetDouble(col))
      elseif vtype == "System.Boolean" then
        v = not (cast(int,self.reader.GetBoolean(col)) == 0)
      else
        v = self.reader.GetString(col)
      end
    end

    return v
  else
    return nil
  end
end

function Result:getName(col)
  if self.reader ~= nil then
    return self.reader.GetName(col)
  else
    return ""
  end
end

function Result:getIndex(colname)
  return self.columns[colname]
end

function Result:fields()
  return self._fields
end

function Result:getRow()
  local row = {}
  for i=0,self:fields()-1 do
    row[self:getName(i)] = self:getValue(i)
  end

  return row
end

function Result:toTable() -- auto close the result
  local r = {}

  while self:fetch() do
    table.insert(r,self:getRow())
  end

  self:close()

  return r
end

-- Command

local Command = {}

function Command:bind(param,value)
--  param = string.gsub(param,"@","?") -- compatibility with @ notation

  local _param = self.params[param]
  if _param == nil then
    _param = self.command.Parameters.AddWithValue(param,value)
    self.params[param] = _param
  else
    -- set parameter value
    _param.Value = value
  end

end

function Command:query()
  Debug.pbegin("MySQL_query \""..self.command.CommandText.."\"")
  local r = setmetatable({},{ __index = Result })

  -- force close previous result
  self.connection:closeActiveResult()

  r.reader = self.command.ExecuteReader()
  self.connection.active_result = r -- set active connection result

  if self.connection.debug then
    print("[vRP MySQL_query] "..self.command.CommandText)
  end

  r.command = self
  r:init()
  Debug.pend()
  return r
end

function Command:last_insert_id()
  return cast(int,self.command.LastInsertedId)
end

function Command:execute()
  Debug.pbegin("MySQL_execute \""..self.command.CommandText.."\"")
  -- force close previous result
  self.connection:closeActiveResult()

  local r = cast(int,self.command.ExecuteNonQuery())

  if self.connection.debug then
    print("[vRP MySQL_execute] "..self.command.CommandText.." => "..r)
  end

  Debug.pend()
  return r
end

-- Connection

local Connection = {}

function Connection:close()
  self.connection.Close()
end

function Connection:closeActiveResult()
  if self.active_result ~= nil then
    self.active_result:close()
    self.active_result = nil
  end
end

function Connection:prepare(sql)
--  sql = string.gsub(sql,"@","?") -- compatibility with @ notation

  local r = setmetatable({},{ __index = Command })
  r.command = lib.MySqlClient.MySqlCommand(sql,self.connection)
  r.command.Prepare()
  r.params = {}
  r.connection = self
  return r
end

-- begin MySQL module
local MySQL = {}

function MySQL.open(host,user,password,db,debug)
  local r = setmetatable({},{ __index = Connection })
  r.connection = lib.MySqlClient.MySqlConnection("server="..host..";uid="..user..";pwd="..password..";database="..db..";")
  r.connection.Open()
  r.debug = debug
  return r
end

-- return module
return MySQL
