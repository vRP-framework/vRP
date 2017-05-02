
# vRP
FiveM RP addon/framework

The project aim to create a generic and simple RP framework to prevent everyone from reinventing the wheel.

Contributions are welcomed.

## Features
* player state auto saved to database (hunger,thirst,weapons,player apparence,position)
* money (wallet/bank)
* inventory (with custom item definition)
* basic implementations: ATM, market, gunshop, skinshop, garage
* identification system (persistant user id for database storage)
* user custom data key/value
* gui (dynamic menu, progress bars, prompt) API
* blip, markers (colored circles), areas (enter/leave callbacks) API
* MySQL lua bindings (prepared statements)
* proxy for easy server-side inter-resource developement
* tunnel for easy server/clients communication

## TODO LIST
* citizen informations (identity, home)
* job/services
* business system
* extensible menu (ex: global menu, interaction menu)

## Tutorials

### Events
#### Base

```lua

-- (server) called after identification 
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login) end)

-- (server) called when the player join again without triggering the vRP:playerLeave event before
-- (used after a client crash for example)
AddEventHandler("vRP:playerRejoin",function(user_id,source,name) end)

-- (server) 
AddEventHandler("vRP:playerLeave",function(user_id) end)
```

### API

To call the server-side API functions, get the vRP interface.

```lua
local Proxy = require("resources/vRP/lib/Proxy")

vRP = Proxy.getInterface("vRP")

-- ex:
vRP.getUserId({source},function(user_id)
  print("user_id = "..user_id)
end)
```

You can also do it client-side, the API is the same as the TUNNEL CLIENT APIs (copy and add the vrp/client/Proxy.lua to your resource, first).

```lua
vRP = Proxy.getInterface("vRP")

-- ex:
vRP.notify({"A notification."}) -- notify the player
```

For the client/server tunnel API, the interface is also "vRP", see the Tunnel library below.

#### Base

```lua
-- PROXY API

-- return user id or nil if the source is invalid
vRP.getUserId(source)

-- return source of the user or nil if not connected
vRP.getUserSource(user_id)

-- set user data (textual data)
vRP.setUData(user_id,key,value)

-- get user data (textual data)
-- return nil if data not found
vRP.getUData(user_id,key)

-- TUNNEL SERVER API

-- TUNNEL CLIENT API

-- teleport the player to the specified coordinates
vRP.teleport(x,y,z)

-- get the player position
-- return x,y,z
vRP.getPosition()

-- get the player speed
-- return speed 
vRP.getSpeed()

-- notify the player
vRP.notify(message)
```

#### Survival

Running, walking, being hurt/injured, and just living add hunger and thirst. When the hunger and the thirst are at their maximum level (100%), next hunger/thirst overflow will damage the character by the same amout (ex: when thirsty, don't run, take a car).

```lua
-- PROXY API

-- return hunger (0-100)
vRP.getHunger(user_id)

-- return thirst (0-100)
vRP.getThirst(user_id)

vRP.setHunger(user_id,value)

vRP.setThirst(user_id,value)

-- vary hunger value by variation amount (+ to add hunger, - to remove hunger)
vRP.varyHunger(user_id,variation)

-- same as vary hunger
vRP.varyThirst(user_id,variation)

-- TUNNEL SERVER API

-- TUNNEL CLIENT API

-- player health variation (+ to heal, - to deal damage)
vRP.varyHealth(variation)

-- enable/disable spawned player ability to hurt friendly
-- flag: boolean
vRP.setFriendlyFire(flag)

-- enable/disable spawned player ability to be chased/arrested by cops
-- flag: boolean
vRP.setPolice(flag)
```

#### Player state
```lua
-- PROXY API

-- TUNNEL SERVER API

-- TUNNEL CLIENT API

-- get player weapons data
-- return table with weapons data, use print(json.encode(result)) to understand the structure
vRP.getWeapons()

-- give weapons
-- weapons: same structure as returned by getWeapons()
-- (optional) clear_before: if true, will remove all the weapons before adding the new ones
vRP.giveWeapons(weapons,clear_before)

-- get player apparence customization data
-- return table with customization data, use print(json.encode(result)) to understand the structure
-- .model or .modelhash define the player model, the indexes define each component as [drawable_id,texture_id,palette_id] array
vRP.getCustomization()

-- set player apparence
-- customization_data: same structure as returned by getCustomization()
vRP.setCustomization(customization_data)
```

#### Money

The money is managed with direct SQL requests to prevent most potential value corruptions.
The wallet empty itself when respawning (after death).

```lua
-- PROXY API

-- get money in wallet
vRP.getMoney(user_id)

-- set money in wallet
vRP.setMoney(user_id,value)

-- try a payment (wallet only)
-- return true or false (debited if true)
vRP.tryPayment(user_id,amount)

-- give money to wallet
vRP.giveMoney(user_id,amount)

-- get bank money
vRP.getBankMoney(user_id)

-- set bank money
vRP.setBankMoney(user_id,value)

-- try a withdraw
-- return true or false (withdrawn if true)
vRP.tryWithdraw(user_id,amount)

-- try a deposit
-- return true or false (deposited if true)
vRP.tryDeposit(user_id,amount)

-- TUNNEL SERVER API

-- TUNNEL CLIENT API
```

#### Inventory

The inventory is autosaved and, as the wallet, empty upon death.

```lua
-- PROXY API

-- define an inventory item (call this once at server start)
-- idname: unique item name
-- name: display name
-- description: item description (html)
-- choices: menudata choices (see gui api)
vRP.defInventoryItem(idname,name,description,choices)

-- add item to a connected user inventory
vRP.giveInventoryItem(user_id,idname,amount)

-- try to get item from a connected user inventory
-- return true if the item has been found and the quantity removed
vRP.tryGetInventoryItem(user_id,idname,amount)

-- clear connected user inventory
vRP.clearInventory(user_id)


-- TUNNEL SERVER API

-- TUNNEL CLIENT API
```

Full example of a resource defining a water bottle item.
Once defined, items can be used by any resources (ex: they can be added to shops).

```lua
local Proxy = require("resources/vRP/lib/Proxy")
local Tunnel = require("resources/vRP/lib/Tunnel")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_waterbottle")

-- create Water bottle item (the callback hell begins) 
local wb_choices = {}  -- (see gui API for menudata choices structure)

wb_choices["Drink"] = {function(player,choice) -- add drink action
  vRP.getUserId({player},function(user_id) -- get user_id
    if user_id ~= nil then
      vRP.tryGetInventoryItem({user_id,"water_bottle",1},function(ok) -- try to remove one bottle
        if ok then
          vRP.varyThirst({user_id,-35}) -- decrease thirst
          vRPclient.notify(player,{"~b~ Drinking."}) -- notify
          vRP.closeMenu({player}) -- the water bottle is consumed by the action, close the menu
        end
      end)
    end
  end)
end,"Do it."}

-- add item definition
vRP.defInventoryItem({"water_bottle","Water bottle","Drink this my friend.",wb_choices})

-- (at any time later) give 2 water bottles to a connected user
vRP.giveInventoryItem({user_id,"water_bottle",2})

```

#### GUI

Controls for the menu generated by the API are the cellphone controls (LEFT,RIGHT,UP,DOWN,CANCEL,SELECT and OPEN to open the main menu).
Don't forget to change the key to open the phone for something different than UP. You can also use the middle mouse button by default.


```lua
-- PROXY API

-- HOW TO: building a dynamic menu
local menudata = {}
menudata.name = "My Menu"

-- shift menu from the top by 75px and set the menu header to green
menudata.css = {top = "75px", header_color = "rgba(0,255,0,0.75)"} -- exhaustive list

menudata.onclose = function(player)
  print("menu closed")
end

local onchoose = function(player,choice)
  print("player choose "..choice)
  vRP.closeMenu({source}) -- ({} because proxy call) close the menu after the first choice (an action menu for example)
end

-- add options and callbacks
menudata["Option1"] = {onchoose, "this <b>option</b> is amazing"} -- callaback and description
menudata["Option two"] = {onchoose} -- no description
menudata["Another option"] = {function(choice) print("another option choice") end,"this<br />one<br />is<br />better"}
-- END HOW TO

-- open a dynamic menu to the client (will close previously opened menus)
vRP.openMenu(source, menudata)

-- close client active menu
vRP.closeMenu(source)

-- prompt textual (and multiline) information from player
-- cb_result: function(player,result)
vRP.prompt(source,title,default_text,cb_result)

-- TUNNEL SERVER API

-- TUNNEL CLIENT API

-- create/update a progress bar 
-- anchor: the anchor string type (multiple progress bars can be set for the same anchor)
---- "minimap" => above minimap (will divide that horizontal space)
---- "center" => center of the screen, at the bottom
---- "botright" => bottom right of the screen
vRP.setProgressBar(name,anchor,text,r,g,b,value)

-- set progress bar value in percent
vRP.setProgressBarValue(name,value)

-- set progress bar text
vRP.setProgressBarText(name,text)

-- remove progress bar
vRP.removeProgressBar(name)

```

##### Registering choices to the main menu

The main menu is generated using an event, this is useful to add special choices if needed.

```lua
-- in another resource using the proxy interface

AddEventHandler("vRP:buildMainMenu",function(player) 
  local choices = {}
  
  local fchoice = function(player,choice)
    print("player "..player.." choose "..choice)
  end

  choices["My Choice"] = {fchoice,"My choice description."}
  choices["My Choice 2"] = {fchoice,"My choice 2 description."}

  vRP.buildMainMenu({player,choices}) -- add choices to the player main menu
end)
```

#### Map

```lua
-- PROXY API

-- create/update a player area (will trigger enter and leave callbacks)
-- cb_enter, cb_leave: function(player,area_name)
vRP.setArea(source,name,x,y,z,radius,height,cb_enter,cb_leave)

-- remove a player area 
vRP.removeArea(source,name)

-- TUNNEL SERVER API

-- TUNNEL CLIENT API

-- create new blip, return native id
vRP.addBlip(x,y,z,idtype,idcolor,text)

-- remove blip by native id
vRP.removeBlip(id)

-- set a named blip (same as addBlip but for a unique name, add or update)
-- return native id
vRP.setNamedBlip(name,x,y,z,idtype,idcolor,text)

-- remove a named blip
vRP.removeNamedBlip(name)

-- add a circular marker to the game map
-- return marker id
vRP.addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)

-- remove marker
vRP.removeMarker(id)

-- set a named marker (same as addMarker but for a unique name, add or update)
-- return id
vRP.setNamedMarker(name,x,y,z,sx,sy,sz,r,g,b,a,visible_distance)

-- remove a named marker
vRP.removeNamedMarker(name)

```

### Libs

#### Proxy

The proxy lib is used to call other resources functions through a proxy event.

Ex:

resource1.lua
```lua
local Proxy = require("resources/vRP/lib/Proxy")

Resource1 = {}
Proxy.addInterface("resource1",Resource1) -- add functions to resource1 interface (can be called multiple times if multiple files declare different functions for the same interface)

function Resource1.test(a,b)
  print("resource1 TEST "..a..","..b)
  return a+b,a*b -- return two values
end
```
resource2.lua
```lua
local Proxy = require("resources/vRP/lib/Proxy")

Resource1 = Proxy.getInterface("resource1")

Resource1.test({13,42},function(rvalue1,rvalue2)
  print("resource2 TEST rvalues = "..rvalue1..","..rvalue2)
end)
```

The notation is **Interface.function({arguments},callback_with_return_values_as_parameters)** (the callback is optional).

#### Tunnel

The idea behind tunnels is to easily access any declared server function from any client resource, and to access any declared client function from any server resource.

Example of two-way resource communication:

Server-side myrsc
```lua
local Tunnel = require("resources/vRP/lib/Tunnel")

-- build the server-side interface
serverdef = {} -- you can add function to serverdef later in other server scripts
Tunnel.bindInterface("myrsc",serverdef)

function serverdef.test(msg)
  print("msg "..msg.." received from "..source)
  return 42
end

-- get the client-side access
clientaccess = Tunnel.getInterface("myrsc","myrsc") -- the second argument is a unique id for this tunnel access, the current resource name is a good choice

-- (later, in a player spawn event) teleport the player to 0,0,0
clientaccess.teleport(source,{0,0,0})
```

Client-side myrsc (copy the resources/vRP/client/Tunnel.lua and add it first to the client scripts of your resource)
```lua

-- build the client-side interface
clientdef = {} -- you can add function to clientdef later in other client scripts
Tunnel.bindInterface("myrsc",clientdef)

function clientdef.teleport(x,y,z)
  SetEntityCoords(GetPlayerPed(-1), x, y, z, 1,0,0,0) 
end

-- get the server-side access
serveraccess = Tunnel.getInterface("myrsc","myrsc") -- the second argument is a unique id for this tunnel access, the current resource name is a good choice

-- call test on server and print the returned value
serveraccess.test({"my client message"},function(r)
  print(r)
end)
```

Now if we want to use the same teleport function in another resource:

```lua
local Tunnel = require("resources/vRP/lib/Tunnel")

-- get the client-side access of myrsc
myrsc_access = Tunnel.getInterface("myrsc","myotherrsc")

-- (later, in a player spawn event) teleport the player to 0,0,0
myrsc_access.teleport(source,{0,0,0})
```

This way resources can easily use other resources client/server API.

A magic trick with the tunnel system (which is based on the TriggerEvent), imagine we want to teleport all players to the same position:

```lua
clientaccess.teleport(-1,{0,0,0},function()
  print("player "..source.." teleported") -- will be displayed for each teleported player
end)
```

#### MySQL

```lua
local MySQL = require("resources/vRP/lib/MySQL/MySQL")

local sql = MySQL.open("127.0.0.1","user","password","database") -- add ,true) to enable debug for the connection
local q_init = sql:prepare([[
CREATE IF NOT EXISTS list(
  name VARCHAR(255),
  value INTEGER,
  CONSTRAINT pk_list PRIMARY KEY(name)
);
]])
q_init:execute()

local q_insert = sql:prepare("INSERT INTO list(name,value) VALUES(@name,@value)")

for i=0,100 do
  q_insert:bind("@name","entry"..i)
  q_insert:bind("@value",i*5)
  q_insert:execute()
  
  print("inserted id = "..q_insert:last_insert_id())
end

local q_select = sql:prepare("SELECT * FROM list")
local r = q_select:query() 
print("NAME VALUE")
while r:fetch() do
  print(r:getValue("name").." "..r:getValue("value"))
  -- or print(r:getValue(0).." "..r:getValue(1))
  -- or local row = r:getRow()
end

r:close() -- don't forget to close the result

-- or
local r = q_select:query() 
local list = r:toTable() -- result is autoclosed
```
