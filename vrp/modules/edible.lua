
local Edible = class("Edible", vRP.Extension)

-- PRIVATE METHODS

local function define_items(self)
  local function i_edible_name(args)
    local edible = self.edibles[args[2]]
    if edible then
      return edible.name
    else
      return "<"..args[2]..">"
    end
  end

  local function i_edible_description(args)
    local edible = self.edibles[args[2]]
    if edible then
      return edible.description
    else
      return ""
    end
  end

  local function m_edible_consume(menu)
    local user = menu.user
    local fullid = menu.data.fullid

    local citem = vRP.EXT.Inventory:computeItem(fullid)
    local edible = self.edibles[citem.args[2]]
    local etype = self.types[edible.type]

    -- consume
    if user:tryTakeItem(fullid, 1) then
      -- menu update
      local namount = user:getItemAmount(fullid)
      if namount > 0 then
        user:actualizeMenu()
      else
        user:closeMenu(menu)
      end

      -- on_consume
      etype[2](user, edible)

      -- effects
      for id, value in pairs(edible.effects) do
        local effect = self.effects[id]
        if effect then
          -- on_effect
          effect(user, value)
        end
      end
    end
  end

  local function i_edible_menu(args, menu)
    local edible = self.edibles[args[2]]
    if edible then
      local etype = self.types[edible.type]
      if etype then
        menu:addOption(etype[1], m_edible_consume)
      end
    end
  end

  local function i_edible_weight(args)
    local edible = self.edibles[args[2]]
    if edible then
      return edible.weight
    else
      return 0
    end
  end

  vRP.EXT.Inventory:defineItem("edible", i_edible_name, i_edible_description, i_edible_menu, i_edible_weight)
end

-- METHODS

function Edible:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/edibles")

  self.types = {}
  self.effects = {}
  self.edibles = {}

  -- load edibles
  for id, v in pairs(self.cfg.edibles) do
    self:defineEdible(id, v[1], v[2], v[3], v[4], v[5])
  end

  -- items
  define_items(self)
end

-- id: identifier (string)
-- action_name: (string)
-- on_consume(user, edible)
function Edible:defineType(id, action_name, on_consume)
  if self.types[id] then
    self:log("WARNING: re-defined type \""..id.."\"")
  end

  self.types[id] = {action_name, on_consume}
end

-- id: identifier (string)
-- on_effect(user, value)
function Edible:defineEffect(id, on_effect)
  if self.effects[id] then
    self:log("WARNING: re-defined effect \""..id.."\"")
  end

  self.effects[id] = on_effect
end

-- id: identifier (string)
-- type: edible type
-- effects: map of effect => value
-- name: (string)
-- description: (html)
-- weight
function Edible:defineEdible(id, type, effects, name, description, weight)
  if self.edibles[id] then
    self:log("WARNING: re-defined edible \""..id.."\"")
  end

  self.edibles[id] = {
    type = type, 
    effects = effects, 
    name = name, 
    description = description,
    weight = weight
  }
end

vRP:registerExtension(Edible)
