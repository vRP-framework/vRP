
local Luaseq = {}

local unpack = table.unpack or unpack
local maxn = table.maxn

if not maxn then
  maxn = function(t)
    local max = 0
    for k,v in pairs(t) do
      local n = tonumber(k)
      if n and n > max then max = n end
    end

    return max
  end
end

local running = coroutine.running
local yield = coroutine.yield
local create = coroutine.create
local resume = coroutine.resume

local function wait(self)
  local r = self.r
  if r then
    return unpack(r, 1, maxn(r)) -- indirect immediate return
  else
    self.waiting = true
    return yield() -- indirect coroutine return
  end
end

local function areturn(self, ...)
  if not self.waiting then
    self.r = {...} -- set return values on the table (in case where the return is triggered immediatly)
  end

  local co = self.co
  if running() ~= co then
    local ok, err = resume(co, ...)
    if not ok then
      print(debug.traceback(co, err))
    end
  end
end

-- create an async context if a function is passed (execute the function in a coroutine if none exists)
-- force: if passed/true, will create a coroutine even if already inside one
--
-- without arguments, an async returner is created and returned
-- returner(...): call to pass return values
-- returner:wait(): call to wait for the return values
function Luaseq.async(func, force)
  local co = running()
  if func then -- block use mode
    if not co or force then -- exec in coroutine
      co = create(func)
      local ok, err = resume(co)
      if not ok then
        print(debug.traceback(co, err))
      end
    else -- exec 
      func()
    end
  else -- in definition mode
    if co then
      return setmetatable({ wait = wait, co = co }, { __call = areturn })
    else
      error("async call outside a coroutine")
    end
  end
end

return Luaseq
