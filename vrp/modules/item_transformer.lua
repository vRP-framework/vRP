if not vRP.modules.item_transformer then return end

local lang = vRP.lang

-- this module define a generic system to transform (generate, process, convert) items and money to other items or money in a specific area
-- each transformer can take things to generate other things, using a unit of work
-- units are generated periodically at a specific rate
-- reagents => products (reagents can be nothing, as for an harvest transformer)

-- Transformer

local Transformer = class("Transformer")

-- id: identifier (string)
function Transformer:__construct(id, cfg)
  self.id = id
  self.cfg = cfg
  self.units = 0

  self.users = {} -- map of user => recipe name
end

function Transformer:unbindUser(user)
  local recipe_name = self.users[user]
  if recipe_name then
    self.users[user] = nil
    vRP.EXT.GUI.remote._removeProgressBar(user.source,"vRP:item_transformer:"..self.id)

    -- onstop
    if self.cfg.onstop then self.cfg.onstop(user, recipe_name) end
  end
end

function Transformer:bindUser(user, recipe_name)
  self:unbindUser(user)
  self.users[user] = recipe_name

  vRP.EXT.GUI.remote._setProgressBar(user.source,"vRP:item_transformer:"..self.id,"center",recipe_name.."...",self.cfg.r,self.cfg.g,self.cfg.b,0)

  -- onstart
  if self.cfg.onstart then self.cfg.onstart(user,recipe_name) end
end

function Transformer:unbindAll()
  for user, recipe_name in pairs(self.users) do
    self:unbindUser(user)
  end
end

-- do transformer tick
function Transformer:tick()
  for user, recipe_name in pairs(self.users) do
    local recipe = self.cfg.recipes[recipe_name]

    if self.units > 0 and recipe then -- check units
      -- check reagents
      local reagents_ok = true
      for fullid,amount in pairs(recipe.reagents) do
        reagents_ok = reagents_ok and (user:getItemAmount(fullid) >= amount)
      end

      -- check money
      local money_ok = (user:getWallet() >= recipe.in_money)

      local new_weight = user:getInventoryWeight()+vRP.EXT.Inventory:computeItemsWeight(recipe.products)-vRP.EXT.Inventory:computeItemsWeight(recipe.reagents)

      local inventory_ok = true
      if new_weight > user:getInventoryMaxWeight() then
        inventory_ok = false
      end

      if not inventory_ok then
        vRP.EXT.Base.remote._notify(user.source, lang.inventory.full())
      end

      if not money_ok then
        vRP.EXT.Base.remote._notify(user.source, lang.money.not_enough())
      end

      if not reagents_ok then
        vRP.EXT.Base.remote._notify(user.source, lang.item_transformer.not_enough_reagents())
      end

      if money_ok and reagents_ok and inventory_ok then -- do transformation
        self.units = self.units-1 -- sub work unit

        -- consume reagents
        if recipe.in_money > 0 then user:tryPayment(recipe.in_money) end
        for fullid,amount in pairs(recipe.reagents) do
          user:tryTakeItem(fullid,amount)
        end

        -- produce products
        if recipe.out_money > 0 then user:giveWallet(recipe.out_money) end
        for fullid,amount in pairs(recipe.products) do
          user:tryGiveItem(fullid,amount)
        end

        -- give exp
        for apt,amount in pairs(recipe.aptitudes or {}) do
          local parts = splitString(apt,".")
          if #parts == 2 then
            user:varyExp(parts[1],parts[2],amount)
          end
        end

        -- onstep
        if self.cfg.onstep then self.cfg.onstep(user,recipe_name) end
      end
    end
  end

  -- display transformation state to all transforming players
  for user,recipe_name in pairs(self.users) do
    vRP.EXT.GUI.remote._setProgressBarValue(user.source,"vRP:item_transformer:"..self.id, self.units/self.cfg.max_units)
    
    if self.units > 0 then -- display units left
      vRP.EXT.GUI.remote._setProgressBarText(user.source,"vRP:item_transformer:"..self.id, recipe_name.."... "..self.units.."/"..self.cfg.max_units)
    else
      vRP.EXT.GUI.remote._setProgressBarText(user.source,"vRP:item_transformer:"..self.id, lang.item_transformer.empty())
    end
  end
end

-- per minute regen tick
function Transformer:regen()
  self.units = self.units+self.cfg.units_per_minute
  if self.units >= self.cfg.max_units then self.units = self.cfg.max_units end
end

-- Extension

local ItemTransformer = class("ItemTransformer", vRP.Extension)

-- PRIVATE METHODS

-- menu: item transformer
local function menu_item_transformer(self)
  local function m_recipe(menu, recipe_name)
    local user = menu.user
    local itemtr = menu.data.itemtr

    if user:inArea("vRP:item_transformer:"..itemtr.id) then
      itemtr:bindUser(user, recipe_name)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("item_transformer", function(menu)
    local itemtr = menu.data.itemtr
    local user = menu.user

    menu.title = itemtr.cfg.name
    menu.css.header_color = "rgba("..itemtr.cfg.r..","..itemtr.cfg.g..","..itemtr.cfg.b..",0.75)"

    -- add recipes
    for recipe_name,recipe in pairs(itemtr.cfg.recipes) do
      if user:hasPermissions(recipe.permissions or {}) then
        local info = "<br /><br />"
        if recipe.in_money > 0 then info = info.."- "..recipe.in_money end
        for fullid,amount in pairs(recipe.reagents) do
          local citem = vRP.EXT.Inventory:computeItem(fullid)
          if citem then
            info = info.."<br />"..amount.." "..citem.name
          end
        end
        info = info.."<br /><span style=\"color: rgb(0,255,125)\">=></span>"
        if recipe.out_money > 0 then info = info.."<br />+ "..recipe.out_money end
        for fullid,amount in pairs(recipe.products) do
          local citem = vRP.EXT.Inventory:computeItem(fullid)
          if citem then
            info = info.."<br />"..amount.." "..citem.name
          end
        end
        for apt,exp in pairs(recipe.aptitudes or {}) do
          local parts = splitString(apt,".")
          if #parts == 2 then
            local def = vRP.EXT.Aptitude:getAptitude(parts[1],parts[2])
            if def then
              info = info.."<br />[EXP] "..exp.." "..vRP.EXT.Aptitude:getGroupTitle(parts[1]).."/"..def[1]
            end
          end
        end

        menu:addOption(recipe_name, m_recipe, recipe.description..info, recipe_name)
      end
    end
  end)
end

local function bind_itemtr_area(self, user, itemtr)
  local menu
  local function enter(user)
    if user:hasPermissions(itemtr.cfg.permissions or {}) then
      menu = user:openMenu("item_transformer", {itemtr = itemtr}) -- open menu
    end
  end

  local function leave(user)
    if menu then
      user:closeMenu(menu)
    end

    itemtr:unbindUser(user)
  end

  user:setArea("vRP:item_transformer:"..itemtr.id,itemtr.cfg.x,itemtr.cfg.y,itemtr.cfg.z,itemtr.cfg.radius,itemtr.cfg.height,enter,leave)
end

local function unbind_itemtr_area(self, user, itemtr)
  user:removeArea("vRP:item_transformer:"..itemtr.id)
end

-- METHODS

function ItemTransformer:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/item_transformers")
  self:log(#self.cfg.item_transformers.." static item transformers")
  self.transformers = {} -- map of id => transformer

  menu_item_transformer(self)

  -- load item transformers from config file
  for i,cfg in pairs(self.cfg.item_transformers) do
    self:set("vRP:cfg_static:"..i, cfg)
  end

  -- task: transformers ticks (every 3 seconds)
  local function transformers_tick()
    SetTimeout(3000,transformers_tick)

    for id,itemtr in pairs(self.transformers) do
      itemtr:tick()
    end
  end
  transformers_tick()

  -- task: transformers unit regeneration
  local function transformers_regen()
    SetTimeout(60000,transformers_regen)

    for id,itemtr in pairs(self.transformers) do
      itemtr:regen()
    end
  end
  transformers_regen()
end

-- add an item transformer
-- id: transformer identitifer (string)
-- cfg: item transformer config
--- name
--- max_units
--- units_per_minute
--- x,y,z,radius,height (area properties)
--- r,g,b (color)
--- permissions: (optional)
--- recipes: map of recipe name => recipe {}
---- description
---- in_money
---- out_money
---- reagents: items as fullid => amount
---- products: items as fullid => amount
---- aptitudes: (optional) aptitudes production as "group.aptitude" => exp
---- permissions: (optional) recipe permissions
function ItemTransformer:set(id, cfg)
  self:remove(id) -- remove pre-existing transformer

  -- create item transformer
  local itemtr = Transformer(id, clone(cfg))
  self.transformers[id] = itemtr

  -- bind tr area to all already spawned players
  for id,user in pairs(vRP.users) do
    bind_itemtr_area(self, user, itemtr)
  end
end

-- remove an item transformer
function ItemTransformer:remove(id)
  local itemtr = self.transformers[id]
  if itemtr then
    itemtr:unbindAll()

    -- remove tr area from all already spawned players
    for id,user in pairs(vRP.users) do
      unbind_itemtr_area(self,user,itemtr)
    end

    self.transformers[id] = nil
  end
end

-- EVENT
ItemTransformer.event = {}

function ItemTransformer.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- bind transformers areas
    for id,itemtr in pairs(self.transformers) do
      bind_itemtr_area(self, user, itemtr)
    end
  end
end

vRP:registerExtension(ItemTransformer)
