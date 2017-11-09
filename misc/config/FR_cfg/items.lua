-- define items, see the Inventory API on github

local cfg = {}

-- idname = {name,description,choices,weight}
-- a good practice is to create your own item pack file instead of adding items here
cfg.items = {
}

-- load more items function
local function load_item_pack(name)
  local items = module("cfg/item/"..name)
  if items then
    for k,v in pairs(items) do
      cfg.items[k] = v
    end
  else
    print("[vRP] item pack ["..name.."] not found")
  end
end

-- PACKS
load_item_pack("required")
load_item_pack("food")
load_item_pack("drugs")
load_item_pack("custom")


return cfg
