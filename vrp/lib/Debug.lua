
local Debug = {}

Debug.active = false
Debug.maxlen = 75
Debug.stack = {}

function Debug.log(str)
  if Debug.active then
    if string.len(str) > Debug.maxlen then
      str = string.sub(str,1,Debug.maxlen).."..."
    end

    print("[vRP Debug] "..str)
  end
end

-- copy table without userdata
function Debug.safeTableCopy(t)
  local r = t

  if type(t) == "table" then
    r = {}
    for k,v in pairs(t) do
      if type(v) ~= "userdata" then
        r[k] = Debug.safeTableCopy(v)
      end
    end
  end

  return r
end

return Debug
