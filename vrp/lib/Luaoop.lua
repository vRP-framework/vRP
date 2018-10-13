-- https://github.com/ImagicTheCat/Luaoop

local Luaoop = {}

local lua5_1 = (string.find(_VERSION, "5.1") ~= nil)

-- CLASS MODULE

local class = {}

-- force an instance to have a custom mtable (by default they share the same table for optimization)
-- mtable: current instance mtable
-- t: instance
-- return custom mtable, custom luaoop table
local function force_custom_mtable(mtable, t)
  if not mtable.luaoop.custom then
    -- copy mtable
    local new_mtable = {}
    for k,v in pairs(mtable) do
      new_mtable[k] = v
    end

    -- copy luaoop
    new_mtable.luaoop = {}
    for k,v in pairs(mtable.luaoop) do
      new_mtable.luaoop[k] = v
    end

    -- flag custom
    new_mtable.luaoop.custom = true
    setmetatable(t, new_mtable)

    mtable = new_mtable
  end

  return mtable, mtable.luaoop
end

-- create a new class
-- name: identifier for debugging purpose
-- ...: base classes (single/multiple inheritance)
-- return created class
function class.new(name, ...)
  if type(name) == "string" then
    local c = { -- init class
      -- binary operator tables
      __add = {},
      __sub = {},
      __mul = {},
      __div = {},
      __pow = {},
      __mod = {},
      __eq = {},
      __le = {},
      __lt = {},
      __concat = {}
    }
    local bases = {...}

    -- check inheritance validity and build
    for i,base in pairs(bases) do
      local mtable = getmetatable(base)
      local luaoop
      if mtable then
        luaoop = mtable.luaoop
      end

      if not luaoop or luaoop.type then -- if not a class
        error("invalid base class #"..i)
      end

      if not luaoop.build then class.build(base) end
    end

    return setmetatable(c, { 
      luaoop = { bases = bases, name = name }, 
      __call = function(c, ...) return class.instantiate(c, ...) end, 
      __tostring = function(c) return "class<"..class.name(c)..">" end
    })
  else
    error("class name is not a string")
  end
end

-- t: class or instance
-- return class name or nil
function class.name(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      return luaoop.name
    end
  end
end

-- t: instance
-- return the type (class) or nil
function class.type(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      return luaoop.type
    end
  end
end

-- check if an instance/class is/inherits from a specific class
-- t: class or instance
-- classdef: can be nil to check if t is a valid (built) class
function class.is(t, classdef)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      -- build class if not built
      if not luaoop.types and not luaoop.type then
        class.build(t)
      end

      if not classdef then
        return not luaoop.type
      else
        return luaoop.types[classdef]
      end
    end
  end

  return false
end

-- t: class or instance
-- return types map (type => true) or nil
function class.types(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      -- build class if not built
      if not luaoop.types and not luaoop.type then
        class.build(t)
      end

      local types = {}
      for k,v in pairs(luaoop.types) do
        types[k] = v
      end

      return types
    end
  end
end

-- get operator
-- lhs: instance
-- name: full name of the operator (starting with "__")
-- rhs: any value, can be nil for unary operators
-- no_error: if passed/true, will not trigger an error if no operator was found
function class.getop(lhs, name, rhs, no_error)
  local mtable = getmetatable(lhs)
  local luaoop
  if mtable then luaoop = mtable.luaoop end

  if luaoop and luaoop.type then -- check if instance
    local rtype, f
    if rhs ~= nil then -- not nil, binary
      rtype = class.type(rhs) -- Luaoop type
      if not rtype then rtype = type(rhs) end -- fallback to Lua type

      f = luaoop.type[name][rtype]
    else
      f = luaoop.type[name]
    end

    if f then
      return f
    elseif not no_error then
      local drtype
      if rtype == nil then
        drtype = "nil"
      elseif type(rtype) == "string" then
        drtype = rtype
      else
        drtype = class.name(rtype)
      end
      error("operator <"..luaoop.name.."> ["..string.sub(name, 3).."] <"..drtype.."> undefined")
    end
  else
    if not no_error then
      error("left operand for operator ["..string.sub(name, 3).."] is not an instance")
    end
  end
end

local getop = class.getop

-- proxy lua operators
local function op_tostring(lhs)
  local f = getop(lhs, "__tostring", nil, true)
  if f then
    return f(lhs)
  else
    return "class<"..class.name(lhs)..">: "..class.id(lhs)
  end
end

local function op_concat(lhs,rhs)
  local f = getop(lhs, "__concat", rhs, true)
  if f then 
    return f(lhs,rhs) 
  end

  f = getop(rhs, "__concat", lhs)
  if f then 
    return f(rhs,lhs,true) 
  end
end

local function op_unm(lhs)
  local f = getop(lhs, "__unm", nil)
  if f then return f(lhs) end
end

local function op_call(lhs, ...)
  local f = getop(lhs, "__call", nil)
  if f then return f(lhs, ...) end
end

local function op_add(lhs,rhs)
  local f = getop(lhs, "__add", rhs, true)
  if f then 
    return f(lhs,rhs) 
  end

  f = getop(rhs, "__add", lhs)
  if f then 
    return f(rhs,lhs) 
  end
end

local function op_sub(lhs,rhs) -- also deduced as lhs+(-rhs)
  local f = getop(lhs, "__sub", rhs, true)
  if f then 
    return f(lhs,rhs)
  end

  f = getop(lhs, "__add", rhs)
  if f then
    return f(lhs, -rhs)
  end
end

local function op_mul(lhs,rhs)
  local f = getop(lhs, "__mul", rhs, true)
  if f then 
    return f(lhs,rhs) 
  end

  f = getop(rhs, "__mul", lhs)
  if f then 
    return f(rhs,lhs) 
  end
end

local function op_div(lhs,rhs)
  local f = getop(lhs, "__div", rhs)
  if f then 
    return f(lhs,rhs) 
  end
end

local function op_mod(lhs,rhs)
  local f = getop(lhs, "__mod", rhs)
  if f then 
    return f(lhs,rhs) 
  end
end

local function op_pow(lhs,rhs)
  local f = getop(lhs, "__pow", rhs)
  if f then 
    return f(lhs,rhs) 
  end
end

local function op_eq(lhs,rhs)
  local f = getop(lhs, "__eq", rhs, true)
  if f then 
    return f(lhs,rhs) 
  end
end

local function op_lt(lhs,rhs)
  local f = getop(lhs, "__lt", rhs)
  if f then 
    return f(lhs,rhs) 
  end
end

local function op_le(lhs,rhs)
  local f = getop(lhs, "__le", rhs)
  if f then 
    return f(lhs,rhs) 
  end
end

-- get the class metatable applied to the instances
-- useful to apply class behaviour to a custom table
-- will build the class if not already built
-- classdef: class
-- return meta or nil
function class.meta(classdef)
  if classdef then
    local mtable = getmetatable(classdef)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop and not luaoop.type then -- if class
      if not luaoop.build then
        class.build(classdef)
      end

      return luaoop.meta
    end
  end
end

-- create instance
-- classdef: class
-- ...: constructor arguments
function class.instantiate(classdef, ...)
  local mtable = getmetatable(classdef)
  local luaoop
  if mtable then luaoop = mtable.luaoop end

  if luaoop and not luaoop.type then -- valid class
    if not luaoop.build then
      class.build(classdef)
    end

    local __instantiate = luaoop.__instantiate
    if __instantiate then -- instantiate hook
      return __instantiate(classdef, ...)
    else -- regular
      -- create instance
      local t = setmetatable({}, luaoop.meta) 

      local constructor = t.__construct
      local destructor = t.__destruct

      if destructor then
        local mtable, luaoop = force_custom_mtable(meta, t) -- gc requires custom properties

        local gc = function()
          destructor(t)
        end

        if lua5_1 then -- Lua 5.1
          local proxy = newproxy(true)
          getmetatable(proxy).__gc = gc
          luaoop.proxy = proxy
        else
          luaoop.proxy = setmetatable({}, { __gc = gc })
        end
      end

      -- construct
      if constructor then constructor(t, ...) end
      return t
    end
  end
end

-- build class
-- will build/re-build the class
-- (if a class is not already built, when used for inheritance or instantiation this function is called)
-- classdef: class
function class.build(classdef)
  if classdef then
    local mtable = getmetatable(classdef)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop and not luaoop.type then
      -- build
      -- prepare build, table with access to the class inherited properties
      if not luaoop.build then luaoop.build = {} end
      for k in pairs(luaoop.build) do luaoop.build[k] = nil end

      -- prepare types
      if not luaoop.types then luaoop.types = {} end
      for k in pairs(luaoop.types) do luaoop.types[k] = nil end

      -- prepare instance build
      if not luaoop.instance_build then luaoop.instance_build = {} end
      for k in pairs(luaoop.instance_build) do luaoop.instance_build[k] = nil end

      --- inheritance
      for _,base in ipairs(luaoop.bases) do
        local base_luaoop = getmetatable(base).luaoop

        -- types
        for t in pairs(base_luaoop.types) do
          luaoop.types[t] = true
        end

        -- class build properties
        for k,v in pairs(base_luaoop.build) do
          if type(v) == "table" and string.sub(k, 1, 2) == "__" then -- inherit/merge special tables
            local table = luaoop.build[k]
            if not table then
              table = {}
              luaoop.build[k] = table
            end

            for tk, tv in pairs(v) do
              table[tk] = tv
            end
          else -- inherit regular property
            luaoop.build[k] = v
          end
        end

        -- class properties
        for k,v in pairs(base) do
          if type(v) == "table" and string.sub(k, 1, 2) == "__" then -- inherit/merge special tables
            local table = luaoop.build[k]
            if not table then
              table = {}
              luaoop.build[k] = table
            end

            for tk, tv in pairs(v) do
              table[tk] = tv
            end
          else -- inherit regular property
            luaoop.build[k] = v
          end
        end
      end

      -- add self type
      luaoop.types[classdef] = true

      -- postbuild hook
      if luaoop.__postbuild then
        luaoop.__postbuild(classdef, luaoop.build)
      end

      --- build generic instance metatable
      ---- instance build
      for k,v in pairs(luaoop.build) do -- class build, everything but special tables
        if type(v) ~= "table" or string.sub(k, 1, 2) ~= "__" then 
          luaoop.instance_build[k] = v
        end
      end

      for k,v in pairs(classdef) do -- class, everything but special tables
        if type(v) ~= "table" or string.sub(k, 1, 2) ~= "__" then 
          luaoop.instance_build[k] = v
        end
      end

      ---- build generic instance metatable
      if not luaoop.meta then 
        luaoop.meta = {
          __index = luaoop.instance_build, 
          luaoop = {
            name = luaoop.name,
            types = luaoop.types,
            type = classdef
          },

          -- add operators metamethods
          __call = op_call,
          __unm = op_unm,
          __add = op_add,
          __sub = op_sub,
          __mul = op_mul,
          __div = op_div,
          __pow = op_pow,
          __mod = op_mod,
          __eq = op_eq,
          __le = op_le,
          __lt = op_lt,
          __tostring = op_tostring,
          __concat = op_concat
        }

        -- postmeta hook
        if luaoop.__postmeta then
          luaoop.__postmeta(classdef, luaoop.meta)
        end
      end

      -- setup class 
      mtable.__index = luaoop.build -- regular properties inheritance

      --- special tables inheritance
      for k,v in pairs(classdef) do
        if type(v) == "table" and string.sub(k, 1, 2) == "__" then 
          setmetatable(v, { __index = luaoop.build[k] })
        end
      end
    end
  end
end

-- return address number from table (tostring hack, return nil on failure)
local function table_addr(t)
  local hex = string.match(tostring(t), ".*(0x%x+).*")
  if hex then return tonumber(hex) end
end

local addr_counter = 0 -- addr counter in replacement of table_addr

-- works by using tostring(table) address hack or using a counter instead on failure
-- t: instance
-- return unique instance id or nil
function class.id(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end
    if luaoop then
      if luaoop.__id then -- id hook
        return luaoop.__id(t)
      else -- regular
        mtable, luaoop = force_custom_mtable(mtable, t) -- id requires custom properties

        if luaoop.id then -- return existing id
          return luaoop.id
        elseif luaoop.type then -- generate id
          -- remove tostring proxy
          mtable.__tostring = nil
          -- generate addr
          luaoop.id = table_addr(t)
          -- reset tostring proxy
          mtable.__tostring = op_tostring

          if not luaoop.id then
            luaoop.id = addr_counter
            addr_counter = addr_counter+1
          end

          return luaoop.id
        end
      end
    end
  end
end

-- t: instance
-- return unique instance data table or nil
function class.data(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end
    if luaoop and luaoop.type then
      if luaoop.__data then -- data hook
        return luaoop.__data(t)
      else -- regular
        mtable, luaoop = force_custom_mtable(mtable, t) -- data requires custom properties

        if not luaoop.data then -- create data table
          luaoop.data = {}
        end

        return luaoop.data
      end
    end
  end
end

-- SHORTCUTS
setmetatable(class, { __call = function(t, name, ...) 
  return class.new(name, ...)
end})

-- NAMESPACES
Luaoop.class = class

return Luaoop
