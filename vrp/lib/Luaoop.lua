-- https://github.com/ImagicTheCat/Luaoop
-- MIT license (see LICENSE)

--[[
MIT License

Copyright (c) 2017 Imagic

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local Luaoop = {}

local lua5_1 = (string.find(_VERSION, "5.1") ~= nil)

local getmetatable, setmetatable, pairs = getmetatable, setmetatable, pairs

-- CLASS MODULE

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

-- t: class or instance
-- return the type (class) or nil
local function class_type(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      return luaoop.type or t
    end
  end
end

-- t: class or instance
-- return class name or nil
local function class_name(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      return luaoop.name
    end
  end
end

-- get operator
-- lhs: instance
-- name: full name of the operator (starting with "__")
-- rhs: any value, can be nil for unary operators
-- no_error: if passed/true, will not trigger an error if no operator was found
local function class_getop(lhs, name, rhs, no_error)
  local mtable = getmetatable(lhs)
  local luaoop
  if mtable then luaoop = mtable.luaoop end

  if luaoop and luaoop.type then -- check if instance
    local rtype, f
    if rhs ~= nil then -- not nil, binary
      rtype = class_type(rhs) -- Luaoop type
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
        drtype = class_name(rtype)
      end
      error("operator <"..luaoop.name.."> ["..string.sub(name, 3).."] <"..drtype.."> undefined")
    end
  else
    if not no_error then
      error("left operand for operator ["..string.sub(name, 3).."] is not an instance")
    end
  end
end

-- proxy lua operators
local function op_tostring(lhs)
  local f = class_getop(lhs, "__tostring", nil, true)
  if f then
    return f(lhs)
  else -- default: print "instance<type>: 0x..."
    local mtable = getmetatable(lhs)
    mtable.__tostring = nil
    local str = string.gsub(tostring(lhs), "table:", "instance<"..class_name(lhs)..">:", 1)
    mtable.__tostring = op_tostring

    return str
  end
end

local function op_concat(lhs,rhs)
  local f = class_getop(lhs, "__concat", rhs, true)
  if f then
    return f(lhs,rhs)
  end

  f = class_getop(rhs, "__concat", lhs)
  if f then
    return f(rhs,lhs,true)
  end
end

local function op_unm(lhs)
  local f = class_getop(lhs, "__unm", nil)
  if f then return f(lhs) end
end

local function op_call(lhs, ...)
  local f = class_getop(lhs, "__call", nil)
  if f then return f(lhs, ...) end
end

local function op_add(lhs,rhs)
  local f = class_getop(lhs, "__add", rhs, true)
  if f then
    return f(lhs,rhs)
  end

  f = class_getop(rhs, "__add", lhs)
  if f then
    return f(rhs,lhs)
  end
end

local function op_sub(lhs,rhs) -- also deduced as lhs+(-rhs)
  local f = class_getop(lhs, "__sub", rhs, true)
  if f then
    return f(lhs,rhs)
  end

  f = class_getop(lhs, "__add", rhs)
  if f then
    return f(lhs, -rhs)
  end
end

local function op_mul(lhs,rhs)
  local f = class_getop(lhs, "__mul", rhs, true)
  if f then
    return f(lhs,rhs)
  end

  f = class_getop(rhs, "__mul", lhs)
  if f then
    return f(rhs,lhs)
  end
end

local function op_div(lhs,rhs)
  local f = class_getop(lhs, "__div", rhs)
  if f then
    return f(lhs,rhs)
  end
end

local function op_mod(lhs,rhs)
  local f = class_getop(lhs, "__mod", rhs)
  if f then
    return f(lhs,rhs)
  end
end

local function op_pow(lhs,rhs)
  local f = class_getop(lhs, "__pow", rhs)
  if f then
    return f(lhs,rhs)
  end
end

local function op_eq(lhs,rhs)
  local f = class_getop(lhs, "__eq", rhs, true)
  if f then
    return f(lhs,rhs)
  end
end

local function op_lt(lhs,rhs)
  local f = class_getop(lhs, "__lt", rhs)
  if f then
    return f(lhs,rhs)
  end
end

local function op_le(lhs,rhs)
  local f = class_getop(lhs, "__le", rhs)
  if f then
    return f(lhs,rhs)
  end
end


-- build class
-- will build/re-build the class
-- (if a class is not already built, when used for inheritance or instantiation this function is called)
-- classdef: class
local function class_build(classdef)
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
      for _, base in ipairs(luaoop.bases) do
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
      for k,v in pairs(luaoop.build) do -- class build, everything but special properties
        if string.sub(k, 1, 2) ~= "__" then
          luaoop.instance_build[k] = v
        end
      end

      for k,v in pairs(classdef) do -- class, everything but special properties
        if string.sub(k, 1, 2) ~= "__" then
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

local function proxy_gc(t)
  local mt = getmetatable(t)
  mt.destructor(mt.instance)
end

-- create instance
-- classdef: class
-- ...: constructor arguments
local function class_instantiate(classdef, ...)
  local mtable = getmetatable(classdef)
  local luaoop
  if mtable then luaoop = mtable.luaoop end

  if luaoop and not luaoop.type then -- valid class
    if not luaoop.build then
      class_build(classdef)
    end

    local __instantiate = luaoop.__instantiate
    if __instantiate then -- instantiate hook
      return __instantiate(classdef, ...)
    else -- regular
      -- create instance
      local t = setmetatable({}, luaoop.meta)

      local constructor = classdef.__construct
      local destructor = classdef.__destruct

      if destructor then
        local mtable, luaoop = force_custom_mtable(luaoop.meta, t) -- gc requires custom properties

        if lua5_1 then -- Lua 5.1
          local proxy = newproxy(true)
          local mt = getmetatable(proxy)
          mt.__gc = proxy_gc
          mt.destructor = destructor
          mt.instance = t
          luaoop.proxy = proxy
        else
          luaoop.proxy = setmetatable({}, { __gc = proxy_gc, instance = t, destructor = destructor })
        end
      end

      -- construct
      if constructor then constructor(t, ...) end
      return t
    end
  end
end

-- create a new class
-- name: identifier for debugging purpose
-- ...: base classes (single/multiple inheritance)
-- return created class
local function class_new(name, ...)
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

      if not luaoop.build then class_build(base) end
    end

    -- default print "class<type>: 0x..."
    local tostring_const = string.gsub(tostring(c), "table:", "class<"..name..">:", 1)

    return setmetatable(c, {
      luaoop = { bases = bases, name = name },
      __call = class_instantiate,
      __tostring = function(c) return tostring_const end
    })
  else
    error("class name is not a string")
  end
end

-- check if an instance/class is/inherits from a specific class
-- t: class or instance
-- classdef: class
-- return true or nil
local function class_is(t, classdef)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      -- build class if not built
      if not luaoop.type and not luaoop.types then
        class_build(t)
      end

      return luaoop.types[classdef]
    end
  end
end

-- t: class or instance
-- return types map (type => true) or nil
local function class_types(t)
  if t then
    local mtable = getmetatable(t)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop then
      -- build class if not built
      if not luaoop.types and not luaoop.type then
        class_build(t)
      end

      local types = {}
      for k,v in pairs(luaoop.types) do
        types[k] = v
      end

      return types
    end
  end
end


-- get the class metatable applied to the instances
-- useful to apply class behaviour to a custom table
-- will build the class if not already built
-- classdef: class
-- return meta or nil
local function class_meta(classdef)
  if classdef then
    local mtable = getmetatable(classdef)
    local luaoop
    if mtable then luaoop = mtable.luaoop end

    if luaoop and not luaoop.type then -- if class
      if not luaoop.build then
        class_build(classdef)
      end

      return luaoop.meta
    end
  end
end

-- MODULE class
local class = setmetatable({
  new = class_new,
  name = class_name,
  type = class_type,
  is = class_is,
  types = class_types,
  meta = class_meta,
  instantiate = class_instantiate,
  build = class_build,
  getop = class_getop
}, {
  __call = function(t, name, ...) -- shortcut
    return class_new(name, ...)
  end
})

-- NAMESPACES
Luaoop.class = class

return Luaoop
