
-- gui config file

local cfg = {}

-- additional css loaded to customize the gui display (see gui/design.css to know the available css elements)
-- it is not recommended to modify the vRP core files outside the cfg/ directory, create a new resource instead
-- you can load external images/fonts/etc using the NUI absolute path: nui://my_resource/myfont.ttf
-- example, changing the gui font (suppose a vrp_mod resource containing a custom font)
cfg.css = [[
@font-face {
  font-family: "Custom Font";
  src: url(nui://vrp_mod/customfont.ttf) format("truetype");
}

body{
  font-family: "Custom Font";
}
]]

return cfg

--[[This is the full list of Menu building events available from vRP core modules:
vRP:buildMainMenu
vRP:buildATMMenu
vRP:buildGarageMenu
vRP:buildGarageOwnedMenu
vRP:buildGarageBuyMenu
vRP:buildGunshopMenu
vRP:buildMarketMenu (you can get the exact Market name from the Menu data passed to the event)
vRP:buildPhoneMenu
vRP:buildPhoneDirectoryMenu
vRP:buildPhoneContactMenu
vRP:buildPhoneSMSMenu
vRP:buildPhoneServiceMenu
vRP:buildSkinshopMenu
vRP:buildBusinessDirectoryMenu
vRP:buildBusinessMenu
vRP:buildCloacroomMenu
vRP:buildEmoteMenu
vRP:buildGroupMenu
vRP:buildHouseMenu
vRP:buildHouseEnterMenu
vRP:buildIdentityMenu
VRP:buildInventoryMenu
vRP:buildInventoryItemMenu (you can get the exact Item name from the Menu data passed to the event)
vRP:buildTransformerMenu
vRP:buildInformerMenu
vRP:buildPoliceMenu
vRP:buildPoliceFineMenu
]]--
