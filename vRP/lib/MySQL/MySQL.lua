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

function Result:close() -- always close the result when unused
  if self.reader ~= nil then
    self.reader.Close()
    self.reader = nil
  end
end

function Result:fetch()
  if self.reader ~= nil then
    return not not self.reader.Read()
  else
    return false
  end
end

function Result:affected()
  if self.reader ~= nil then
    return self.reader.RecordsAffected
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

    return self.reader.GetValue(col)
  else
    return nil
  end
end

function Result:getName(col)
  if self.reader ~= nil then
    return tostring(self.reader.GetName(col))
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
  self.connection:closeActiveResult()

  r.reader = self.command.ExecuteReader()
  self.connection.active_result = r -- set active connection result

  r.command = self
  r:init()
  print("query "..self.command.CommandText)
  return r
end

function Command:last_insert_id()
  return self.command.LastInsertedId
end

function Command:execute()
  -- force close previous result
  self.connection:closeActiveResult()

  local r = self.command.ExecuteNonQuery()
  print("execute "..self.command.CommandText.." => "..r)
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
  r.params = {}
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
