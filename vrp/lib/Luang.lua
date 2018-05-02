
local Luang = {}
local Lang = {}

-- dict resolve functions

local function replace_args(str,args)
  if str ~= nil and args ~= nil then
    for k,v in pairs(args) do
      str = string.gsub(str,"%{"..k.."%}",tostring(v))
    end
  end

  return str
end

local function resolve_path(dict,path,t,k)
  if path ~= "" then
    path = path.."."..k
  else
    path = k
  end

  local el = nil
  if dict then el = dict[k] end

  if el ~= nil then
    if type(el) == "table" then -- table, continue 
      return setmetatable({}, { __index = function(t,k) return resolve_path(el,path,t,k) end, __tostring = function(t) return path end, __call = function(t, args, default) return replace_args(default, args) or path end })
    else -- value
      return setmetatable({}, { __index = function(t,k) return resolve_path(el,path,t,k) end, __tostring = function(t) return el end, __call = function(t, args, default) return replace_args(el,args) end })
    end
  else -- nil, return path
    return setmetatable({}, { __index = function(t,k) return resolve_path(el,path,t,k) end, __tostring = function(t) return path end, __call = function(t, args, default) return replace_args(default, args) or path end })
  end
end

-- Lang object methods

-- load a dict table to the lang dict
function Lang:load(dict)
  if dict then
    Luang.inject(self.dict, dict)
  end
end

-- load a dict table to the lang dict for a specific locale
function Lang:loadLocale(locale, dict)
  self:load({[locale] = dict})
end

-- construct Lang object
setmetatable(Luang, { __call = function(t)
  local obj = {}
  obj.dict = {}
  obj.lang = setmetatable({}, { __index = function(t,k) return resolve_path(obj.dict,"",t,k) end })
  return setmetatable(obj, { __index = Lang })
end})

-- inject recursively the itable (insert table) properties into the btable (base table)
function Luang.inject(btable, itable)
  if type(itable) == "table" then
    for k,v in pairs(itable) do
      local bv = btable[k]
      if type(bv) == "table" then
        Luang.inject(bv, v) -- recursive, don't replace table
      else
        btable[k] = itable[k] -- replace property
      end
    end
  end
end

return Luang
