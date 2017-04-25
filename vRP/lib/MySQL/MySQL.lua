clr.System.Reflection.Assembly.LoadFrom("resources/vRP/lib/MySQL/MySql.Data.dll")
local lib = clr.MySql.Data
local lib_type = lib.MySqlClient.MySqlDbType

-- Result

local Result = {}

function Result:init()
  self._fields = self.reader.FieldCount
  self.columns = {}
  for i=0,self:fields()-1 do
    self.columns[self:getName(i)] = i
  end
end

function Result:close()
  self.reader.Close()
end

function Result:fetch()
  return self.reader.Read()
end

function Result:affected()
  return self.reader.RecordsAffected
end

function Result:getValue(col)
  -- convert from name to index
  if type(col) == "string" then
    col = self:getIndex(col)
  end

  return self.reader.GetValue(col)
end

function Result:getName(col)
  return self.reader.GetName(col)
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

-- Command

local Command = {}

function Command:bind(param,value)
  param = string.gsub(param,"@","?") -- compatibility with @ notation

  local _param = self.params[param]
  if not _param then
    -- can do: optimize with better type selection
    local vtype = lib_type.VarString -- use string type by default

    -- create parameter
    _param = self.command.Parameters.Add(param,vtype)
    self.params[param] = _param
  end

  -- set parameter value
  _param.Value = value
end

function Command:query()
  local r = setmetatable({},{ __index = Result })

  -- force close previous result
  if self.connection.active_result ~= nil then
    self.connection.active_result:close()
  end

  r.reader = self.command.ExecuteReader()
  self.connection.active_result = r -- set active connection result

  r.command = self
  r:init()
  return r
end

function Command:execute()
  return self.command.ExecuteNonQuery()
end

-- Connection

local Connection = {}

function Connection:close()
  self.connection.Close()
end

function Connection:prepare(sql)
  sql = string.gsub(sql,"@","?") -- compatibility with @ notation

  local r = setmetatable({},{ __index = Command })
  r.command = self.connection.CreateCommand()
  r.params = {}
  r.command.CommandText = sql
  r.command.Prepare()
  r.connection = self
  return r
end

-- begin MySQL module
local MySQL = {}

function MySQL.open(host,user,password,db)
  local r = setmetatable({},{ __index = Connection })
  r.connection = lib.MySqlClient.MySqlConnection("server="..host..";uid="..user..";pwd="..password..";database="..db..";")
  r.connection.Open()
  return r
end

-- return module
return MySQL
