SV_ilvl = SV_ilvl or {}
local _s1 = 1 -- enabled
local _s2 = 2 -- equip
local _s3 = 3 -- clr
local _c = {} -- cache

local function Chat(message) 
    DEFAULT_CHAT_FRAME:AddMessage("|cFF4FC0C4[ClassicItemLevel]:|r |cFF40C24F"..tostring(message).."|r") 
end



local function GetItemNameFromTooltip(tooltip)
    
	local tmp = ""
	local result = nil

		for i = 1, 9 do
        	local textLine = getglobal("GameTooltipTextLeft"..i)
		if textLine then
		local text = textLine:GetText()
			--print("line=" .. tostring(i) .. "=" .. text ) 
			if text then
				if i == 1 then
					tmp = text;
				elseif text == "Soulbound"
					or text == "Feet" 
					or text == "Shirt" 
					or text == "Legs" 
					or text == "Soulbound"
					or text == "Two-Hand" then
					result = tmp
				end
			end
		end
	end

	return result

end

local function GetItemIDFromLink(link)
    if not link then return nil end
    
   	local itemStart = string.find(link, "item:")
    if not itemStart then return nil end
    
    local numStart = itemStart + 5
    
    local numEnd = string.find(link, ":", numStart) or string.find(link, "|", numStart)
    if not numEnd then return nil end
    
    local itemIDStr = string.sub(link, numStart, numEnd - 1)
    return tonumber(itemIDStr)
end


local function _del_Display(tooltip, itemName)
    if SV_ilvl[_s1] == false then return end
    --print("good1") 
			
    --local name, link = tooltip:GetItem()
    --if not link then return end
    
    local tmp1, tmp2, tmp3, tmp4, _, _, _, _, equipSlot = GetItemInfo(itemName)
    local iEquip = (equipSlot and equipSlot ~= "" and equipSlot ~= "INVTYPE_NON_EQUIP_IGNORE")

--local tmp1, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemName)


    print(itemName .. " 1:"..tostring(tmp1) .. " 2:"..tostring(tmp2).. " 3:"..tostring(tmp3) .. " 4:"..tostring(tmp4)) 

    if SV_ilvl[_s2] == false or iEquip then
        if ilvl and ilvl >= 0 then
            local clr = "|cFFFFFFFF"
            if SV_ilvl[_s3] ~= false and rarity and rarity > 0 then
                if _c[rarity] then 
                    clr = _c[rarity] 
                else
                    local r, g, b = GetItemQualityColor(rarity)
                    clr = string.format("|cFF%02x%02x%02x", r*255, g*255, b*255)
                    _c[rarity] = clr
                end
            end
            tooltip:AddLine("ItemLevel: "..clr..ilvl.."|r")
            tooltip:Show()
        end
    end
end

local function _del_Command(s, val, tPre, tOn, tOff, tsOn, tsOff, turnOn)
    if (val == "on" or val == "enable" or val == "yes" or val == "y") then
        SV_ilvl[s] = true
        if turnOn then SV_ilvl[_s1] = true end
        Chat(tPre..tOn)
    elseif (val == "off" or val == "disable" or val == "no" or val == "n") then
        SV_ilvl[s] = false
        if turnOn then SV_ilvl[_s1] = true end
        Chat(tPre..tOff)
    elseif turnOn == true then
        if SV_ilvl[s] == nil and true or SV_ilvl[s] then
            Chat(tPre..tsOn)
        else
            Chat(tPre..tsOff)
        end
    end
end

SLASH_CITEMLEVEL1 = "/itemlevel"
SLASH_CITEMLEVEL2 = "/ilvl"
SLASH_CITEMLEVEL3 = "/itemlvl"
SlashCmdList["CITEMLEVEL"] = function(msg)
    if msg == '' then
        Chat("/ilvl 'on/off' to toggle display of itemlevels")
        Chat("/ilvl equip 'on/off' to only show ilvl on equippable items")
        Chat("/ilvl color 'on/off' to change if itemlevel is be colored or white.")
    else
       local p1, p2
        local spacePos = string.find(msg, " ")
        if spacePos then
            p1 = string.sub(msg, 1, spacePos - 1)
            p2 = string.sub(msg, spacePos + 1)
        else
            p1 = msg
        end
        
        p1 = p1 and string.lower(p1) or ""
        p2 = p2 and string.lower(p2) or nil
        
        if p1 == "equip" then
            Command(_s2, p2, "'EquipOnly' ", "on", "off", "is on", "is off", true)
        elseif p1 == "color" or p1 == "colour" or p1 == "colors" or p1 == "colours" then
            Command(_s3, p2, "Colors ", "on", "off", "are on", "are off", true)
        else
            Command(_s1, p1, "Display is ", "on", "off", nil, nil, false)
        end
    end
end


-- Initialize
local frm = CreateFrame("Frame", "ClassicItemLevelTooltip", GameTooltip)
frm:SetScript("OnShow", function (self)

	local itemName = GetItemNameFromTooltip(GameTooltip)
	if (itemName) then
			
		-- equipped
		local found = false
		for i = 1, 19 do 
			local itemLink = GetInventoryItemLink("player", i)
        		
			if itemLink then
				local currName, _, rarity, ilvl, _, _, _, _, equipSlot = GetItemInfo(GetItemIDFromLink(itemLink))
                
					if currName and string.find(currName, itemName) then
                		local clr = "|cFFFFFFFF"
            			GameTooltip:AddLine("ItemLevel: "..clr..ilvl.."|r")
						--Display(ilvl)
                		break
            		end
	        end
		end
	end
	
    
end)
