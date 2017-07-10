-- a basic skinshop implementation

local cfg = module("cfg/skinshops")
local lang = vRP.lang
local skinshops = cfg.skinshops

-- parse part key (a ped part or a prop part)
-- return is_proppart, index
local function parse_part(key)
  if type(key) == "string" and string.sub(key,1,1) == "p" then
    return true,tonumber(string.sub(key,2))
  else
    return false,tonumber(key)
  end
end

-- open the skin shop for the specified ped parts
-- name = partid
function vRP.openSkinshop(source,parts)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    -- notify player if wearing a uniform
    local data = vRP.getUserDataTable(user_id)
    if data.cloakroom_idle ~= nil then
      vRPclient.notify(source,{lang.common.wearing_uniform()})
    end

    -- get old customization to compute the price
    vRPclient.getCustomization(source,{},function(old_custom)
      old_custom.modelhash = nil

      -- start building menu
      local menudata = {
        name=lang.skinshop.title(),
        css={top = "75px", header_color="rgba(0,255,125,0.75)"}
      }

      local drawables = {}
      local textures = {}

      local ontexture = function(player, choice)
        -- change texture
        local texture = textures[choice]
        texture[1] = texture[1]+1
        if texture[1] >= texture[2] then texture[1] = 0 end -- circular selection

        -- apply change
        local custom = {}
        custom[parts[choice]] = {drawables[choice][1],texture[1]}
        vRPclient.setCustomization(source,{custom})
      end

      local ondrawable = function(player, choice, mod)
        if mod == 0 then -- tex variation
          ontexture(player,choice)
        else
          local isprop, index = parse_part(parts[choice])

          -- change drawable
          local drawable = drawables[choice]
          drawable[1] = drawable[1]+mod

          if isprop then
            if drawable[1] >= drawable[2] then drawable[1] = -1 -- circular selection (-1 for prop parts)
            elseif drawable[1] < -1 then drawable[1] = drawable[2]-1 end 
          else
            if drawable[1] >= drawable[2] then drawable[1] = 0 -- circular selection
            elseif drawable[1] < 0 then drawable[1] = drawable[2] end 
          end

          -- apply change
          local custom = {}
          custom[parts[choice]] = {drawable[1],textures[choice][1]}
          vRPclient.setCustomization(source,{custom})

          -- update max textures number
          vRPclient.getDrawableTextures(source,{parts[choice],drawable[1]},function(n)
            textures[choice][2] = n

            if textures[choice][1] >= n then
              textures[choice][1] = 0 -- reset texture number
            end
          end)
        end
      end

      for k,v in pairs(parts) do -- for each part, get number of drawables and build menu

        drawables[k] = {0,0} -- {current,max}
        textures[k] = {0,0}  -- {current,max}

        -- init using old customization
        local old_part = old_custom[v]
        if old_part then
          drawables[k][1] = old_part[1]
          textures[k][1] = old_part[2]
        end

        -- get max drawables
        vRPclient.getDrawables(source,{v},function(n)
          drawables[k][2] = n  -- set max
        end)

        -- get max textures for this drawable
        vRPclient.getDrawableTextures(source,{v,drawables[k][1]},function(n)
          textures[k][2] = n  -- set max
        end)

        -- add menu choices
        menudata[k] = {ondrawable}
      end

      menudata.onclose = function(player)
        -- compute price
        vRPclient.getCustomization(source,{},function(custom)
          local price = 0
          custom.modelhash = nil
          for k,v in pairs(custom) do
            local old = old_custom[k]
            if v[1] ~= old[1] then price = price + cfg.drawable_change_price end -- change of drawable
            if v[2] ~= old[2] then price = price + cfg.texture_change_price end -- change of texture
          end

          if vRP.tryPayment(user_id,price) then
            if price > 0 then
              vRPclient.notify(source,{lang.money.paid({price})})
            end
          else
            vRPclient.notify(source,{lang.money.not_enough()})
            -- revert changes
            vRPclient.setCustomization(source,{old_custom})
          end
        end)
      end

      -- open menu
      vRP.openMenu(source,menudata)
    end)
  end
end

local function build_client_skinshops(source)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(skinshops) do
      local parts,x,y,z = table.unpack(v)

      local skinshop_enter = function(source)
        local user_id = vRP.getUserId(source)
        if user_id ~= nil then

          vRP.openSkinshop(source,parts)
        end
      end

      local function skinshop_leave(source)
        vRP.closeMenu(source)
      end

      vRPclient.addBlip(source,{x,y,z,73,3,lang.skinshop.title()})
      vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

      vRP.setArea(source,"vRP:skinshop"..k,x,y,z,1,1.5,skinshop_enter,skinshop_leave)
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    build_client_skinshops(source)
  end
end)
