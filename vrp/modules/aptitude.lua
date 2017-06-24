
-- define aptitude system (aka. education, skill system)

-- exp notes:
-- levels are defined by the amount of xp
-- with a step of 5: 5|15|30|50|75
-- total exp for a specific level, exp = step*lvl*(lvl+1)/2
-- level for a specific exp amount, lvl = (sqrt(1+8*exp/step)-1)/2

local exp_step = 5

function vRP.defAptitudeGroup(group, title)
end

function vRP.defAptitude(group, aptitude, title, init_exp, exp_step, max_exp)
end

function vRP.varyExp(user_id, group, aptitude, amount)
end

function vRP.levelUp(user_id, group, aptitude)
  local next_level = math.floor(vRP.expToLevel(vRP.getExt(user_id,group,aptitude)))+1
  local next_exp = vRP.levelToExp(next_level)
  local add_exp = next_exp-vRP.getExp(user_id, group, aptitude)
  vRP.varyExp(user_id, group, aptitude, add_exp)
end

function vRP.levelDown(user_id, group, aptitude)
  local prev_level = math.floor(vRP.expToLevel(vRP.getExt(user_id,group,aptitude)))-1
  local prev_exp = vRP.levelToExp(prev_level)
  local add_exp = prev_exp-vRP.getExp(user_id, group, aptitude)
  vRP.varyExp(user_id, group, aptitude, add_exp)
end

function vRP.getExp(user_id, group, aptitude)
end

-- return float
function vRP.expToLevel(exp)
  return (math.sqrt(1+8*exp/exp_step)-1)/2
end

-- return integer
function vRP.levelToExp(lvl)
  return math.floor((exp_step*lvl*(lvl+1))/2)
end
