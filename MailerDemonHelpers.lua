MailerDemonHelpers                            = ZO_Object:Subclass()
MailerDemonHelpers.db                           = nil


local CBM = CALLBACK_MANAGER
local LAM = LibStub( 'LibAddonMenu-2.0' )

if ( not LAM ) then return end

function MailerDemonHelpers:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function MailerDemonHelpers:Initialize( db)
	 self.db = db
 end
 

 MailerDemonHelpers.data = {
	
	["Equip"] = {
	
		["Cloth"] = {
			ARMORTYPE_LIGHT,  
			ARMORTYPE_MEDIUM, 
		},
		
		["Metal"] = {
			-- weapons
			WEAPONTYPE_AXE,  
			WEAPONTYPE_DAGGER,  
			WEAPONTYPE_SWORD, 
			WEAPONTYPE_TWO_HANDED_AXE,  
			WEAPONTYPE_TWO_HANDED_HAMMER,  
			WEAPONTYPE_TWO_HANDED_SWORD, 
			WEAPONTYPE_HAMMER, 
			
			-- armor
			ARMORTYPE_HEAVY, 
		},
		
		["Wood"] = {
			-- weapons
			WEAPONTYPE_BOW,  
			WEAPONTYPE_LIGHTNING_STAFF, 
			WEAPONTYPE_FIRE_STAFF, 
			WEAPONTYPE_FROST_STAFF, 
			WEAPONTYPE_HEALING_STAFF, 
			WEAPONTYPE_SHIELD,  
		},
		
		["Glyph"] = {
			ITEMTYPE_GLYPH_ARMOR, 
			ITEMTYPE_GLYPH_JEWELRY, 
			ITEMTYPE_GLYPH_WEAPON,
		},
		
	},

	["Cloth"] = {
				
		-- material
		ITEMTYPE_CLOTHIER_MATERIAL, 
		-- raw material
		ITEMTYPE_CLOTHIER_RAW_MATERIAL, 
		-- booster
		ITEMTYPE_CLOTHIER_BOOSTER, 
	},

	 ["Metal"] = {
	
		-- material
		ITEMTYPE_BLACKSMITHING_MATERIAL, 
		-- raw material
		ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, 
		-- booster
		ITEMTYPE_BLACKSMITHING_BOOSTER, 
		
	},

	 ["Wood"] = {
	 
		-- material
		ITEMTYPE_WOODWORKING_MATERIAL, 
		
		-- raw material
		ITEMTYPE_WOODWORKING_RAW_MATERIAL,  
		
		-- booster
		ITEMTYPE_WOODWORKING_BOOSTER, 
	},

	 ["Glyph"] = {
		
		-- material
		ITEMTYPE_ENCHANTING_RUNE_ESSENCE, 
		ITEMTYPE_ENCHANTING_RUNE_POTENCY, 
		
		-- booster
		ITEMTYPE_ENCHANTMENT_BOOSTER,  
		ITEMTYPE_ENCHANTING_RUNE_ASPECT,

	},

	 ["Food"] = {
		ITEMTYPE_INGREDIENT,
		ITEMTYPE_RECIPE, 		
	},

	 ["Alchemy"] = {
		ITEMTYPE_REAGENT, 
		ITEMTYPE_ALCHEMY_BASE, 
		
	},

	 ["Bait"] = {
		ITEMTYPE_LURE, 
	},


	["Raw"] = {
		ITEMTYPE_CLOTHIER_RAW_MATERIAL, 
		ITEMTYPE_WOODWORKING_RAW_MATERIAL, 
		ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, 
		ITEMTYPE_ENCHANTING_RUNE_ESSENCE,  
		ITEMTYPE_ENCHANTING_RUNE_POTENCY, 
		ITEMTYPE_ALCHEMY_BASE,
	},

	["Material"] = {

		ITEMTYPE_CLOTHIER_MATERIAL, 
		ITEMTYPE_WOODWORKING_MATERIAL, 
		ITEMTYPE_BLACKSMITHING_MATERIAL, 
		ITEMTYPE_ENCHANTING_RUNE_ESSENCE,  
		ITEMTYPE_ENCHANTING_RUNE_POTENCY,
	},

	["Boosters"] = {
		ITEMTYPE_CLOTHIER_BOOSTER, 
		ITEMTYPE_WOODWORKING_BOOSTER, 
		ITEMTYPE_BLACKSMITHING_BOOSTER, 
		ITEMTYPE_ENCHANTMENT_BOOSTER,  
		ITEMTYPE_ENCHANTING_RUNE_ASPECT, 
		ITEMTYPE_RECIPE, 
	},

	["Weapon"] = {
		EQUIP_TYPE_HAND, 
		EQUIP_TYPE_MAIN_HAND, 
	},

	["Armor"] = {
		EQUIP_TYPE_CHEST, 
		EQUIP_TYPE_FEET, 
		EQUIP_TYPE_HEAD, 
		EQUIP_TYPE_LEGS, 
		EQUIP_TYPE_OFF_HAND, 
		EQUIP_TYPE_ONE_HAND, 
		EQUIP_TYPE_SHOULDERS, 
		EQUIP_TYPE_TWO_HAND, 
		EQUIP_TYPE_WAIST, 
		EQUIP_TYPE_NECK, 
		EQUIP_TYPE_RING, 
	},

}

function MailerDemonHelpers:findInList(itemType, list)

	for i, v in ipairs(list) do
		--d("key: " .. key .. ": " .. value)
		if (v == itemType) then return true end
	end
	
	return false
	
end

function MailerDemonHelpers:IsRawMaterial(bagSlot, taskName)
	
	local itemType = GetItemType(1, bagSlot)
	
	
	local itemTypeInConfig = MailerDemonHelpers:findInList(itemType, self.data[taskName])
	local itemTypeIsMatch = MailerDemonHelpers:findInList(itemType, self.data["Raw"])

	return (itemTypeInConfig and itemTypeIsMatch)
	
end

function MailerDemonHelpers:IsMaterial(bagSlot, taskName)
	
	local itemType = GetItemType(1, bagSlot)

	local itemTypeInConfig =  MailerDemonHelpers:findInList(itemType, self.data[taskName])
	local itemTypeIsMatch =  MailerDemonHelpers:findInList(itemType, self.data["Material"])
	
	return (itemTypeInConfig and itemTypeIsMatch)
	
	
end

function MailerDemonHelpers:IsBooster(bagSlot, taskName)
	
	local itemType = GetItemType(1, bagSlot)
	local itemLink = GetItemLink(1, bagSlot)
	local itemTypeInConfig =  MailerDemonHelpers:findInList(itemType, self.data[taskName])
	local itemTypeIsMatch =  MailerDemonHelpers:findInList(itemType, self.data["Boosters"])
	--d("item type " .. itemType .. " for " .. itemLink .. " in config: " .. tostring(itemTypeInConfig) .. ", itemType is match:" .. tostring(itemTypeIsMatch))	
	return (itemTypeInConfig and itemTypeIsMatch)
	
	
end

function MailerDemonIsCraftingMaterial(bagSlot, taskName)
	return MailerDemonHelpers:IsBooster(bagSlot, taskName) or MailerDemonHelpers:IsMaterial(bagSlot, taskName) or MailerDemonHelpers:IsRawMaterial(bagSlot, taskName)
end

function MailerDemonHelpers:IsEndProduct(bagSlot, taskName)
	
	local itemType
	local ret = false
	
	if taskName == "Alchemy" or taskName == "Bait" or taskName == "Food" or taskName == "Glyph" then
		-- we check for the itemType instead of weaponType or armorType.
		-- if we have a match here we can return directly, because we won't find a weapon or armor type in the config anyway.
	
		itemType = GetItemType(1, bagSlot)	
		
		ret = MailerDemonHelpers:findInList(itemType, self.data[taskName]) 
		
		if taskName == "Glyph" then 
			ret = ret or MailerDemonHelpers:findInList(itemType, self.data["Equip"][taskName])
		end
	
	else
		-- this is not supposed to return any raw materials, so this is a no-condition - in this case we return false
		if MailerDemonIsCraftingMaterial(bagSlot, taskName) then return false end
		
		local armorType = GetItemArmorType(1, bagSlot)
		local weaponType = GetItemWeaponType(1, bagSlot)
		ret = MailerDemonHelpers:findInList(armorType, self.data["Equip"][taskName])  or  MailerDemonHelpers:findInList(weaponType, self.data["Equip"][taskName]) 
		
	end	 
	

	
	--d("checking on task " .. taskName .. ": " .. itemLink .. ", itemType " .. itemType .. ", equipType " .. equipType .. "inConfig: " .. tostring(itemTypeInConfig) .. ", " .. tostring(equipTypeInConfig))
	return ret
	
end

function MailerDemonHelpers:IsQuality(bagSlot, currConfig, checkBoosters)
	
	-- check if the itemType is within the config arrays
	-- if not, check if the equipType is within the config arrays
	
	local minQuality = currConfig.MinQuality
	local maxQuality = currConfig.MaxQuality
	
	if checkBoosters then
		local minQuality = currConfig.RawMinQuality
		local maxQuality = currConfig.MaxRawQuality
	end
	
	local _, _, _, _, _, equipType, _, quality = GetItemInfo(1, bagSlot)

	return (minQuality <= quality) and (maxQuality >= quality)
	
	

end

function MailerDemonHelpers:IsOrnate(bagSlot)

	local itemTrait = GetItemTrait(1, bagSlot)
	return (itemTrait == ITEM_TRAIT_TYPE_ARMOR_ORNATE) 
		or (itemTrait ==  ITEM_TRAIT_TYPE_JEWELRY_ORNATE) 
		or (itemTrait ==  ITEM_TRAIT_TYPE_WEAPON_ORNATE)
		or  (GetItemType(1, bagSlot) == TEMTYPE_ALCHEMY_BASE) -- mark solvents as ornate, just to make sure
end
 
function MailerDemonHelpers:CheckSendItem(bagSlot, currConfig, task)	

	if GetItemLink(1, bagSlot)  == '' then return false end
	if MailerDemonHelpers:IsItemSaved(bagSlot) then return false end
	
	local ret = false
	
	-- for non-programmers: By calling "and" on the configValue I ensure that the value is set to "false" if the configEntry isn't set			
	-- we are checking for material, raw material and booster
	
	ret = (MailerDemonHelpers:IsMaterial(bagSlot, currConfig.Name) and currConfig.SendMaterials)
	ret = ret or (MailerDemonHelpers:IsRawMaterial(bagSlot, currConfig.Name) and currConfig.SendRaw)	
	ret = ret or (MailerDemonHelpers:IsBooster(bagSlot, currConfig.Name) and currConfig.SendBoosters)
			
		
	if currConfig.SplitStuff and not string.match(task, "RAW") then 
		-- if raw materials are supposed to be sent to someone else and we are _NOT_ checking on raw materials, then
		-- everything we have compared so far won't matter anyway, so we just throw our result away.
		ret = false
	elseif currConfig.SplitStuff and string.match(task, "RAW") then 
		-- else we can return here, because we'll come by for a second time to check upon end products
		return ret
	end
	
	ret = ret or (MailerDemonHelpers:IsEndProduct(bagSlot, currConfig.Name) and MailerDemonHelpers:IsQuality(bagSlot, currConfig, false) and currConfig.Send)
	if ret then reason = "because is sendable endProduct" end
	-- make sure that ornate items are NOT sent if not intended
	ret = ret and not ((MailerDemonHelpers:IsOrnate(bagSlot)) and currConfig.KeepOrnate)
	
	return ret
	
end

function MailerDemonHelpers:NormalizeString(text)
	if not text then return "" end
	local minusRaw = text:gsub("RAW", ""):lower()
	return (string.sub(minusRaw,1,1):upper() .. string.sub(minusRaw,2,#minusRaw):gsub("^%s+", ""):gsub("%s+$", ""))
end

function MailerDemonHelpers:GetCurrentConfig(taskRunning, db)
	local identifier = MailerDemonHelpers:NormalizeString(taskRunning)	
	return db.mailSettings[identifier]
end

function MailerDemonHelpers:IsItemSaved(bagSlot)
	
	if (not ItemSaver_IsItemSaved and not FCOIsMarked) then return false end
	local ret = false
	
	if ItemSaver_IsItemSaved then ret = ItemSaver_IsItemSaved(1, bagSlot) end
	if IsItemSavedByFCOItemSaver then ret = ret or IsItemSavedByFCOItemSaver(bagSlot) end
	
	return ret
	
 end


function MailerDemonHelpers:IsActive(currConfig, keepRunning, db, task)
	
	if not currConfig then 
		currConfig = db.mailSettings[task] 
		return currConfig.Send or currConfig.SendBoosters or currConfig.SendMaterials or currConfig.SendRaw
	end
	if keepRunning then 
		return currConfig.Send 
	end
	return currConfig.SendBoosters or currConfig.SendMaterials or currConfig.SendRaw
end

 
function MailerDemonHelpers:Evaluate(currConfig, task, keepRunning)

	local subject, recipient
	subject = currConfig.Subject
	recipient = currConfig.To
	
	
	-- check if raw material is supposed to be sent
	if (currConfig.SplitStuff and keepRunning) then 
		subject = currConfig.RawSubject
		recipient = currConfig.RawTo
	end
		
	return subject, recipient
	
end


function MailerDemonHelpers:GetTexture(task, direction)
	
	return "/MailerDemon/Textures/mail_" .. string.lower( MailerDemonHelpers:NormalizeString(task)) .. "_" .. direction .. ".dds"
end

function MailerDemonHelpers:GetFirstWord(sentence)
	if not sentence then return "" end
	local wordList = {}
	for word in(string.gmatch(sentence, "%a+")) do
		table.insert(wordList, word)	
	end
	return string.lower(table.remove(wordList, 1))
end


function MailerDemonHelpers:MD_SetValue(craft, key, value)
	
	d("trying to set values for " .. craft .. " [".. key .. "]" .. " as " .. value)
	if not craft then d("craft is nil") return end 
	if not key then d("key is nil") return end
	if not value then d("value is nil") return end	
	craft[key] = value

end

function MailerDemonHelpers:UpdateValue(craftname, values, key, value)
	
	d("trying to set values for " .. craftname .. " [".. key .. "]" .. " as " .. value)
	if not craftname then d("craftname is nil") return end 
	if not key then d("key is nil") return end
	if not value then d("value is nil") return end	
	
	if not craft[key] == value then 
		craft[key] = value
	end

end
