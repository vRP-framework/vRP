# vRP
FiveM RP addon/framework

The project aim to create a generic and simple RP framework to prevent everyone from reinventing the wheel.

Contributions are welcomed.

## Features
* MySQL lua bindings (prepared statements)
* identification system (persistant user id for database storage)

## TODO LIST
* add/centralize basic libraries (ex: MySQL)
* basic survival characteristics (hunger/thirst)
* citizen informations (identity, home)
* money/inventory
* job/services
* extensible menu (ex: global menu, interaction menu)

## Tutorials

### Libs
#### MySQL

```lua
local MySQL = require("resources/vRP/lib/MySQL/MySQL")

local sql = MySQL.open("127.0.0.1","user","password","database")
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

-- or
local r = q_select:query() 
local list = r:toTable()
```
