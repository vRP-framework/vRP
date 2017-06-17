
local Debug = {}

Debug.active = false
Debug.maxlen = 75
Debug.stack = {}

function Debug.pbegin(name)
  if Debug.active then
    if string.len(name) > Debug.maxlen then
      name = string.sub(name,1,Debug.maxlen).."..."
    end

    table.insert(Debug.stack, {name,os.clock()})
    print("[profile] => "..name)
  end
end

function Debug.pend()
  if Debug.active then
    local front = table.remove(Debug.stack)
    print("[profile] <= "..front[1].." "..(os.clock()-front[2]).."s")
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
