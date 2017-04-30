-- this module define some Mono tools (ex: non global assembly loader) (experimental, doesn't fully work)

local Mono = {}

local function splitString(str, sep)
  if sep == nil then sep = "%s" end

  local t={}
  local i=1

  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end

  return t
end

local function __call_type(self,...)
  print("call "..tostring(self._type))
  return clr.System.Activator.CreateInstance(self._type, arg)
end

-- build assembly namespace
local function add_assembly_type(namespace,atype)
  local path = splitString(tostring(atype),".")

  local t = namespace
  for i=1,#path do
    local name = path[i]

    if i == #path then -- last iteration, add type
      -- proxy type definition, can call the activator instance creation
      local def = setmetatable({}, { __call = __call_type })
      def._type = atype
      def.GetType = function() return def._type end

      t[name] = def
    else
      local nt = t[name]
      if nt == nil then -- create subspace if not exists
        nt = {}
        t[name] = nt
      end  

      t = nt
    end
  end
end

function Mono.loadAssembly(path)
  local bytes = clr.System.IO.File.ReadAllBytes(path)
  local assembly = clr.System.Reflection.Assembly.Load(bytes)
  local r = {}
  if assembly ~= nil then
    -- build assembly namespace
    local count = 0
    foreach atype in assembly.GetTypes() do
      add_assembly_type(r,atype)
      count = count+1
    end

    print("[vRP Mono] loaded assembly "..path.." ("..count.." types)")
  else
    print("[vRP Mono] ERROR: failed to load assembly "..path)
  end

  return r
end

return Mono
