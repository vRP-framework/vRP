-- define a module to build a language access with a dictionary

local Lang = {}

local function replace_args(str,args)
  for k,v in pairs(args) do
    str = string.gsub(str,"%{"..k.."%}",tostring(v))
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
      return setmetatable({}, { __index = function(t,k) return resolve_path(el,path,t,k) end, __tostring = function(t) return path end, __call = function(t,args,default) return default or path end })
    else -- value
      return setmetatable({}, { __index = function(t,k) return resolve_path(el,path,t,k) end, __tostring = function(t) return el end, __call = function(t,args,default) return replace_args(el,args or {}) end })
    end
  else -- nil, return path
    return setmetatable({}, { __index = function(t,k) return resolve_path(el,path,t,k) end, __tostring = function(t) return path end, __call = function(t,args,default) return default or path end })
  end
end

function Lang.new(dict)
  return setmetatable({}, { __index = function(t,k) return resolve_path(dict,"",t,k) end })
end

return Lang

-- usage
-- local dict = { foo = { foo="a", bar="b"}, bar = {"a {1}"}}
-- local lang = Lang.new(dict)
--
-- lang.foo => "foo"
-- lang.foo.foo => "a"
-- lang.foo.bar => "b"
-- lang.something.a() => "something.a"
-- lang.bar({"arg1"}) => "a arg1"

-- to prevent tostring() not being called sometimes, always use the call form lang.foo.bar.something()
