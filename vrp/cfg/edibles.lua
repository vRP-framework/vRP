
local cfg = {}

cfg.action_delay = 5 -- seconds, delay between two edible consume actions

cfg.solid_sound = "sounds/eating.ogg"
cfg.liquid_sound = "sounds/drinking.ogg"

-- (see vRP.EXT.Edible:defineEdible)
-- map of id => {type, effects, name, description, weight}
--- type
---- default types: liquid, solid, drug
--- effects: map of effect => value
---- default effects: water (0-1), food (0-1), health (0-100)
--- name, description, weight: same as item
cfg.edibles = {
  -- drinks
  water = {"liquid", {water = 0.25}, "Water bottle","", 0.5},
  milk = {"liquid", {water = 0.05}, "Milk","", 0.5},
  coffee = {"liquid", {water = 0.1}, "Coffee", "", 0.2},
  tea = {"liquid", {water = 0.15}, "Tea","", 0.2},
  icetea = {"liquid", {water = 0.2}, "ice-Tea","", 0.5},
  orangejuice = {"liquid", {water = 0.25}, "Orange Juice.","", 0.5},
  gocagola = {"liquid", {water = 0.35}, "Goca Gola","", 0.3},
  redgull = {"liquid", {water = 0.4}, "RedGull","", 0.3},
  lemonlimonad = {"liquid", {water = 0.45}, "Lemon limonad","", 0.3},
  vodka = {"liquid", {water = 0.65, food = -0.15, health = -1}, "Vodka","",0.5},

  -- food
  bread = {"solid", {food = 0.1, water = -0.05}, "Bread","", 0.5},
  donut = {"solid", {food = 0.15, water = -0.05}, "Donut","", 0.2},
  tacos = {"solid", {food = 0.2, water = -0.05}, "Tacos","", 0.2},
  sandwich = {"solid", {food = 0.25, water = -0.1}, "Sandwich","A tasty snack.", 0.5},
  kebab = {"solid", {food = 0.45, water = -0.2, health = 5}, "Kebab","", 0.85},
  --- fruits
  peach = {"solid", {food = 0.1, water = 0.1}, "Peach","A peach.", 0.15},


  -- drugs
  pills = {"drug", {health = 25}, "Pills","A simple medication.", 0.1}
}

return cfg
