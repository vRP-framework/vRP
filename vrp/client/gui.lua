
local GUI = class("GUI", vRP.Extension)

function GUI:__construct()
  vRP.Extension.__construct(self)

  self.paused = false

  -- task: gui controls (from cellphone)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      -- menu controls
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.up)) then SendNUIMessage({act="event",event="UP"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.down)) then SendNUIMessage({act="event",event="DOWN"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.left)) then SendNUIMessage({act="event",event="LEFT"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.right)) then SendNUIMessage({act="event",event="RIGHT"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.select)) then SendNUIMessage({act="event",event="SELECT"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.cancel)) then 
        self.remote._closeMenu()
        SendNUIMessage({act="event",event="CANCEL"}) 
      end

      -- open general menu
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.open)) and ((vRP.EXT.Survival and not vRP.EXT.Survival:isInComa() or true) or not vRP.cfg.coma_disable_menu) and ((vRP.EXT.Police and not vRP.EXT.Police:isHandcuffed() or true) or not vRP.cfg.handcuff_disable_menu) and not self.menu_data then 
        self.remote._openMainMenu() 
      end

      -- F5,F6 (default: control michael, control franklin)
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.request.yes)) then SendNUIMessage({act="event",event="F5"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.request.no)) then SendNUIMessage({act="event",event="F6"}) end

      -- pause events
      local pause_menu = IsPauseMenuActive()
      if pause_menu and not self.paused then
        self.paused = true
        vRP:triggerEvent("pauseChange", self.paused)
      elseif not pause_menu and self.paused then
        self.paused = false
        vRP:triggerEvent("pauseChange", self.paused)
      end
    end
  end)
end

-- CONTROLS/GUI

function GUI:isPaused()
  return self.paused
end

-- MENU

function GUI:isMenuOpen()
  return self.menu_data ~= nil
end

-- ANNOUNCE

-- add an announce to the queue
-- background: image url (800x150)
-- content: announce html content
function GUI:announce(background,content)
  SendNUIMessage({act="announce",background=background,content=content})
end

-- PROGRESS BAR

-- create/update a progress bar
-- value: 0-1
function GUI:setProgressBar(name,anchor,text,r,g,b,value)
  local pbar = {name=name,anchor=anchor,text=text,r=r,g=g,b=b,value=value}

  -- default values
  if pbar.value == nil then pbar.value = 0 end

  SendNUIMessage({act="set_pbar",pbar = pbar})
end

-- set progress bar value 0-1
function GUI:setProgressBarValue(name,value)
  SendNUIMessage({act="set_pbar_val", name = name, value = value})
end

-- set progress bar text
function GUI:setProgressBarText(name,text)
  SendNUIMessage({act="set_pbar_text", name = name, text = text})
end

-- remove a progress bar
function GUI:removeProgressBar(name)
  SendNUIMessage({act="remove_pbar", name = name})
end

-- DIV

-- set a div
-- css: plain global css, the div class is "div_name"
-- content: html content of the div
function GUI:setDiv(name,css,content)
  SendNUIMessage({act="set_div", name = name, css = css, content = content})
end

-- set the div css
function GUI:setDivCss(name,css)
  SendNUIMessage({act="set_div_css", name = name, css = css})
end

-- set the div content
function GUI:setDivContent(name,content)
  SendNUIMessage({act="set_div_content", name = name, content = content})
end

-- execute js for the div
-- js variables: this is the div
function GUI:divExecuteJS(name,js)
  SendNUIMessage({act="div_execjs", name = name, js = js})
end

-- remove the div
function GUI:removeDiv(name)
  SendNUIMessage({act="remove_div", name = name})
end

-- EVENT

GUI.event = {}

-- pause
function GUI.event:pauseChange(paused)
  SendNUIMessage({act="pause_change", paused=paused})
end

-- TUNNEL

GUI.tunnel = {}

-- MENU

function GUI.tunnel:openMenu(menudata)
  self.menu_data = menudata

  if vRP.cfg.default_menu then
    SendNUIMessage({act="open_menu", menudata = menudata})
  end

  vRP:triggerEvent("menuOpen", menudata)
end

function GUI.tunnel:closeMenu()
  self.menu_data = nil

  if vRP.cfg.default_menu then
    SendNUIMessage({act="close_menu"})
  end

  vRP:triggerEvent("menuClose")
end

-- PROMPT

function GUI.tunnel:prompt(title,default_text)
  SendNUIMessage({act="prompt",title=title,text=tostring(default_text)})
  SetNuiFocus(true)
end

-- REQUEST

function GUI.tunnel:request(id,text,time)
  SendNUIMessage({act="request",id=id,text=tostring(text),time = time})
  vRP.EXT.Base:playSound("HUD_MINI_GAME_SOUNDSET","5_SEC_WARNING")
end

GUI.tunnel.announce = GUI.announce
GUI.tunnel.setProgressBar = GUI.setProgressBar
GUI.tunnel.setProgressBarValue = GUI.setProgressBarValue
GUI.tunnel.setProgressBarText = GUI.setProgressBarText
GUI.tunnel.removeProgressBar = GUI.removeProgressBar
GUI.tunnel.setDiv = GUI.setDiv
GUI.tunnel.setDivCss = GUI.setDivCss
GUI.tunnel.setDivContent = GUI.setDivContent
GUI.tunnel.divExecuteJS = GUI.divExecuteJS
GUI.tunnel.removeDiv = GUI.removeDiv

-- NUI

-- gui menu events
RegisterNUICallback("menu",function(data,cb)
  if data.act == "valid" then
    vRP.EXT.GUI.remote._triggerMenuOption(data.option+1,data.mod)
  end
end)

-- gui prompt event
RegisterNUICallback("prompt",function(data,cb)
  if data.act == "close" then
    SetNuiFocus(false)
    SetNuiFocus(false)
    vRP.EXT.GUI.remote._promptResult(data.result)
  end
end)

-- gui request event
RegisterNUICallback("request",function(data,cb)
  if data.act == "response" then
    vRP.EXT.GUI.remote._requestResult(data.id,data.ok)
  end
end)

-- init
RegisterNUICallback("init",function(data,cb) -- NUI initialized
  SendNUIMessage({act="cfg",cfg=vRP.cfg.gui}) -- send cfg
  vRP:triggerEvent("NUIready")
end)

vRP:registerExtension(GUI)
