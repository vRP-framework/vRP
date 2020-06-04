-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)


local ActionDelay = class("ActionDelay")

function ActionDelay:__construct()
  self.next_time = 0
end

-- try to perform action
-- delay: delay after the action if performed, seconds
-- return true if performed or false
function ActionDelay:perform(delay)
  local time = os.time()
  if time >= self.next_time then
    self.next_time = time+delay
    return true
  end

  return false
end

-- get remaining seconds
-- return positive value if waiting, negative or 0 if the delay is done
function ActionDelay:remaining()
  return self.next_time-os.time()
end

return ActionDelay
