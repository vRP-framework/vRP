-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.transformer then return end

local lang = vRP.lang

-- this module define a generic system to transform (generate, process, convert) items/money/etc to items/money/etc in a specific area
-- each transformer can take things to generate other things, using a unit of work
-- units are generated periodically at a specific rate
-- reagents => products (ex: reagents can be nothing for an harvest transformer)

-- Transformer

local TransformerDef = class("TransformerDef")

-- id: identifier (string)
function TransformerDef:__construct(id, cfg)
  self.id = id
  self.cfg = cfg
  self.units = 0

  self.users = {} -- map of user => recipe name
end

function TransformerDef:unbindUser(user)
  local recipe_name = self.users[user]
  if recipe_name then
    self.users[user] = nil
    vRP.EXT.GUI.remote._removeProgressBar(user.source,"vRP:transformer:"..self.id)

    -- onstop
    if self.cfg.onstop then self.cfg.onstop(self, user, recipe_name) end
  end
end

function TransformerDef:bindUser(user, recipe_name)
  self:unbindUser(user)
  self.users[user] = recipe_name

  local r,g,b = table.unpack(self.cfg.color)
  vRP.EXT.GUI.remote._setProgressBar(user.source,"vRP:transformer:"..self.id,"center",recipe_name.."...",r,g,b,0)

  -- onstart
  if self.cfg.onstart then self.cfg.onstart(self,user,recipe_name) end
end

function TransformerDef:unbindAll()
  for user, recipe_name in pairs(self.users) do
    self:unbindUser(user)
  end
end

-- do transformer tick
function TransformerDef:tick()
  local processors = vRP.EXT.Transformer.processors

  for user, recipe_name in pairs(self.users) do
    local recipe = self.cfg.recipes[recipe_name]

    if self.units > 0 and recipe then -- check units
      local ok = true

      -- check
      for id, processor in pairs(processors) do
        local reagents, products = recipe.reagents[id], recipe.products[id]
        if reagents ~= nil or products ~= nil then
          local p_ok = processor[2](user, reagents, products)
          if not p_ok then
            ok = false
            break
          end
        end
      end

      if ok then -- do transformation
        self.units = self.units-1 -- sub work unit

        -- process
        for id, processor in pairs(processors) do
          local reagents, products = recipe.reagents[id], recipe.products[id]
          if reagents ~= nil or products ~= nil then
            processor[3](user, reagents, products)
          end
        end

        -- onstep
        if self.cfg.onstep then self.cfg.onstep(self, user, recipe_name) end
      end
    end
  end

  -- display transformation state to all transforming players
  for user,recipe_name in pairs(self.users) do
    vRP.EXT.GUI.remote._setProgressBarValue(user.source,"vRP:transformer:"..self.id, self.units/self.cfg.max_units)
    
    if self.units > 0 then -- display units left
      vRP.EXT.GUI.remote._setProgressBarText(user.source,"vRP:transformer:"..self.id, recipe_name.."... "..self.units.."/"..self.cfg.max_units)
    else
      vRP.EXT.GUI.remote._setProgressBarText(user.source,"vRP:transformer:"..self.id, lang.transformer.empty_bar())
    end
  end
end

-- per minute regen tick
function TransformerDef:regen()
  self.units = self.units+self.cfg.units_per_minute
  if self.units >= self.cfg.max_units then self.units = self.cfg.max_units end
end

-- Extension

local Transformer = class("Transformer", vRP.Extension)

-- PRIVATE METHODS

-- menu: transformer
local function menu_transformer(self)
  local function m_recipe(menu, recipe_name)
    local user = menu.user
    local tr = menu.data.transformer

    if user:inArea("vRP:transformer:"..tr.id) then
      tr:bindUser(user, recipe_name)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("transformer", function(menu)
    local tr = menu.data.transformer
    local user = menu.user

    menu.title = tr.cfg.title
    local r,g,b = table.unpack(tr.cfg.color)
    menu.css.header_color = "rgba("..r..","..g..","..b..",0.75)"

    -- add recipes
    for recipe_name,recipe in pairs(tr.cfg.recipes) do
      if user:hasPermissions(recipe.permissions or {}) then
        local r_info, p_info = "", ""

        -- compute info

        for id, processor in pairs(self.processors) do
          local reagents, products = recipe.reagents[id], recipe.products[id]
          if reagents ~= nil or products ~= nil then
            local r, p = processor[1](user, reagents, products)
            r_info = r_info..r
            p_info = p_info..p
          end
        end

        local info = lang.transformer.recipe_description({recipe.description, r_info, p_info})

        menu:addOption(recipe_name, m_recipe, info, recipe_name)
      end
    end
  end)
end

local function bind_tr_area(self, user, tr)
  local menu
  local function enter(user)
    if user:hasPermissions(tr.cfg.permissions or {}) then
      menu = user:openMenu("transformer", {transformer = tr}) -- open menu
    end
  end

  local function leave(user)
    if menu then
      user:closeMenu(menu)
    end

    tr:unbindUser(user)
  end

  local x,y,z = table.unpack(tr.cfg.position)
  user:setArea("vRP:transformer:"..tr.id,x,y,z,tr.cfg.radius,tr.cfg.height,enter,leave)
end

local function unbind_tr_area(self, user, tr)
  user:removeArea("vRP:transformer:"..tr.id)
end

-- METHODS

function Transformer:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/transformers")
  self:log(#self.cfg.transformers.." static transformers")

  self.processors = {} -- registered processors, map of id => {on_display, on_check, on_process}
  self.transformers = {} -- map of id => transformer

  menu_transformer(self)

  -- load transformers from config file
  for i,cfg in pairs(self.cfg.transformers) do
    self:set("vRP:cfg_static:"..i, cfg)
  end

  -- task: transformers ticks (every 3 seconds)
  local function transformers_tick()
    SetTimeout(3000,transformers_tick)

    for id,tr in pairs(self.transformers) do
      tr:tick()
    end
  end
  SetTimeout(3000,transformers_tick)

  -- task: transformers unit regeneration
  local function transformers_regen()
    SetTimeout(60000,transformers_regen)

    for id,tr in pairs(self.transformers) do
      tr:regen()
    end
  end
  SetTimeout(60000,transformers_regen)
end

-- register a transformer processor
-- on_display(user, reagents, products): should return r_info, p_info (two html strings to display info about the reagents and products)
-- on_check(user, reagents, products): should return true if the processing can occur
-- on_process(user, reagents, products): should process the transformation
-- for the three callbacks:
--- reagents: reagents data, can be nil
--- products: products data, can be nil
function Transformer:registerProcessor(id, on_display, on_check, on_process)
  self.processors[id] = {on_display, on_check, on_process}
end

-- add a transformer
-- id: transformer identitifer (string)
-- cfg: transformer config
--- title
--- color {r,g,b} (255)
--- max_units
--- units_per_minute
--- pos {x,y,z}
--- radius,height (area properties)
--- permissions: (optional)
--- recipes: map of recipe name => recipe {}
---- description (html)
---- reagents: map of processor id => data, see modules transformer processors
---- products: map of processor id => data, see modules transformer processors
---- permissions: (optional) recipe permissions
---- onstart(transformer, user, recipe_name): (optional) called when the recipe starts
---- onstep(transformer, user, recipe_name): (optional) called at each recipe step
---- onstop(transformer, user, recipe_name): (optional) called when the recipe stops
function Transformer:set(id, cfg)
  self:remove(id) -- remove pre-existing transformer

  -- create transformer
  local tr = TransformerDef(id, clone(cfg))
  self.transformers[id] = tr

  -- bind tr area to all already spawned players
  for id,user in pairs(vRP.users) do
    bind_tr_area(self, user, tr)
  end
end

-- remove a transformer
function Transformer:remove(id)
  local tr = self.transformers[id]
  if tr then
    tr:unbindAll()

    -- remove tr area from all already spawned players
    for id,user in pairs(vRP.users) do
      unbind_tr_area(self,user,tr)
    end

    self.transformers[id] = nil
  end
end

-- EVENT
Transformer.event = {}

function Transformer.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- bind transformers areas
    for id,tr in pairs(self.transformers) do
      bind_tr_area(self, user, tr)
    end
  end
end

vRP:registerExtension(Transformer)
