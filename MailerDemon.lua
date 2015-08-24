
local MailerDemon = ZO_Object:Subclass()

MailerDemon.db = nil
MailerDemon.config = nil
MailerDemon.DestroyList = {}
MailerDemon.KeepRunning = true
MailerDemon.NumSlot = 1
MailerDemon.TaskRunning = nil
MailerDemon.LastAnchor = nil

MailerDemon.Buttons = {

			['Cloth'] = nil,
			['Wood'] = nil,
			['Metal'] = nil,
			['Food'] = nil,
			['Glyph'] = nil,
			['Alchemy'] = nil,
			['Bait'] = nil,
			['All'] = nil,
			}


MailerDemon.SkipValues = {
			['Cloth'] = false,
			['Wood'] = false,
			['Metal'] = false,
			['Food'] = false,
			['Glyph'] = false,
			['Alchemy'] = false,
			['Bait'] = false,
			}
MailerDemon.Counter = 0

local Config = MailerDemonConfig


local defaults = 
{
	testData = nil,
	keepOrnate = false,
	keepIntricate = true,
	keepProvisionning = true,
	keepRecipes = true,
	keepFood = true,
	--keepAlchemy = true,
	keepBaits = true,
	minQuality = 2,
	autoLootActivated = false,
	excludeSavedItems = true,
	mailSettings = {
		['Cloth'] = {
			['Name'] = 'Cloth',
			['Send'] = false,
			['KeepOrnate'] = false,
			['To'] = '',
			['Subject'] = 'Deconstructables Cloth!',
			['MinQuality'] = 1,
			['MaxQuality'] = 3,
			['MinNumber'] = 2,
			['SplitStuff'] = false,

			['SendRaw'] = false,
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['RawTo'] = '',
			['RawSubject'] = 'bounce cloth',
			['RawMinNumber'] = 1,
			['RawMinQuality'] = 1,
			['MaxRawQuality'] = 3,
			},
			
		['Metal'] = {
			['Name'] = 'Metal',
			['Send'] = false,
			['KeepOrnate'] = false,
			['To'] = '',
			['Subject'] = 'Deconstructables Metal!',
			['MinQuality'] = 1,
			['MaxQuality'] = 3,
			['MinNumber'] = 2,
			['SplitStuff'] = false,

			['SendRaw'] = false,
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['RawTo'] = '',
			['RawSubject'] = 'bounce ore',
			['RawMinNumber'] = 1,
			['RawMinQuality'] = 1,
			['MaxRawQuality'] = 3
			},	
			
		['Wood'] = {
			['Name'] = 'Wood',
			['Send'] = false,
			['KeepOrnate'] = false,
			['To'] = '',
			['Subject'] = 'Deconstructables Wood!',
			['MinQuality'] = 1,
			['MaxQuality'] = 3,
			['MinNumber'] = 2,
			['SplitStuff'] = false,

			['SendRaw'] = false,
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['RawTo'] = '',
			['RawSubject'] = 'bounce wood',
			['RawMinNumber'] = 1,
			['RawMinQuality'] = 1,
			['MaxRawQuality'] = 3
			},
			
		['Glyph'] = {
		
			['Name'] = 'Glyph',
			['Send'] = false,
			['KeepOrnate'] = false,
			['To'] = '',
			['Subject'] = 'Deconstructables Glyph!',
			['MinQuality'] = 1,
			['MaxQuality'] = 3,
			['MinNumber'] = 2,
			['SplitStuff'] = false,

			['SendRaw'] = false,
			['SendMaterials'] = false, -- will be set to SendRaw
			['SendBoosters'] = false,
			['RawTo'] = '',
			['RawSubject'] = 'bounce runestones',
			['RawMinNumber'] = 1,
			['RawMinQuality'] = 1,
			['MaxRawQuality'] = 3
			
			},
			
		['Food'] = {
			
			['Name'] = 'Food',
			['Send'] = false,
			['KeepOrnate'] = false,
			['To'] = '',
			['Subject'] = 'Food delivery!',
			['MinQuality'] = 1,
			['MaxQuality'] = 3,
			['MinNumber'] = 2,
			['SplitStuff'] = false,

			['SendRaw'] = false, -- recipes
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['RawTo'] = '',
			['RawSubject'] = 'bounce food',
			['RawMinNumber'] = 1,
			['RawMinQuality'] = 1,
			['MaxRawQuality'] = 3
			
			},
		
		['Alchemy'] = {
			
			['Name'] = 'Alchemy',
			['Send'] = false,
			['KeepOrnate'] = false,
			['To'] = '',
			['Subject'] = 'Flowers for you!',
			['MinQuality'] = 1,
			['MaxQuality'] = 3,
			['MinNumber'] = 2,
			['SplitStuff'] = false,

			['SendRaw'] = false, -- Solvent
			['SendMaterials'] = false, -- will be ignored anyway
			['SendBoosters'] = false,
			['RawTo'] = '',
			['RawSubject'] = 'bounce flowers',
			['RawMinNumber'] = 1,
			['RawMinQuality'] = 1,
			['MaxRawQuality'] = 3
			
			},
		
		['Bait'] = {
			['Name'] = 'Bait',
			['Send'] = false,
			['KeepOrnate'] = false,
			['To'] = '',
			['Subject'] = 'Zombie assembly!',
			['MinQuality'] = 1,
			['MaxQuality'] = 3,
			['MinNumber'] = 1,
			['SplitStuff'] = false,

			['SendRaw'] = false,
			['SendMaterials'] = false,
			['SendBoosters'] = false,
			['RawTo'] = '',
			['RawSubject'] = 'bounce bait',
			['RawMinNumber'] = 1,
			['RawMinQuality'] = 1,
			['MaxRawQuality'] = 3
			}
	
	},
	delay = 5000
}

function MailerDemon:GetFunction(condition, argument)

	for key,func in pairs(functions) do
		if string.match(key, condition) then 
			func(argument)
		end
	end

end

function MailerDemon:New( ... )
	local result =  ZO_Object.New( self )
	result:Initialize( ... )
	return result
end

function MailerDemon:Initialize( control )
	self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )
	
    --CBM:RegisterCallback( Config.EVENT_TOGGLE_AUTOLOOT, function() self:ToggleAutoLoot()    end )
end

function MailerDemon:OnLoaded( event, addon )

	if addon ~="MailerDemon" then return end
	
	self.db = ZO_SavedVars:New( 'MailerDemon_Db', 1.3, nil, defaults )
    self.config = Config:New( self.db )
	
    SLASH_COMMANDS['/toto'] = function() mTests() end
    SLASH_COMMANDS['/sendmails'] = function() MailerDemon:SendMails() end
	
    --MailerDemon.ToggleAutoLoot()
	self.control:RegisterForEvent( EVENT_MAIL_OPEN_MAILBOX, function( ... ) self:CreateButtons( ... ) end )
	self.control:RegisterForEvent( EVENT_MAIL_CLOSE_MAILBOX, function( ... ) self:RemoveButtons( ... ) end )
	self.control:RegisterForEvent( EVENT_MAIL_SEND_FAILED, function( ... ) self:OnMailFailure( ... ) end )
	self.control:RegisterForEvent( EVENT_CONFIRM_SEND_MAIL, function(...) self:ConfirmMail(...) end)
	
end

function MailerDemon:ConfirmMail(control)

-- i get an action layer with 1 = recipient, 2 = subject, 3 = emptyString (maybe gold), 4 = 4 and 5 = 0

 -- on click i get an action layer popped with 4 and 4
	
end

-- sending the mails
function MailerDemon:SendAll()
	local db = self.db
	local keepRunning = true
	
	local taskArray = {}
	

	
	if MailerDemonHelpers:IsActive(nil, false, db, "Cloth") then taskArray.insert("CLOTHRAW") end
	if MailerDemonHelpers:IsActive(nil, false, db, "Wood") then taskArray.insert("WOODRAW") end
	if MailerDemonHelpers:IsActive(nil, false, db, "Metal") then taskArray.insert("METALRAW") end
	if MailerDemonHelpers:IsActive(nil, false, db, "Glyph") then taskArray.insert("GLYPHRAW") end
	if MailerDemonHelpers:IsActive(nil, false, db, "Alchemy") then taskArray.insert("ALCHEMY") end
	if MailerDemonHelpers:IsActive(nil, false, db, "Food") then taskArray.insert("FOOD") end
	if MailerDemonHelpers:IsActive(nil, false, db, "Bait") then taskArray.insert("BAIT") end
	
	MailerDemon:SendMails(taskArray, db, keepRunning) 
	
end

function MailerDemon:AttachAndSend(taskTable, db, keepRunning)

	if (not taskTable) or taskTable == {} then return false end
	
	local canAttach, subject, recipient, taskRunning, success, currConfig
	
	if type(taskTable) == "string" then -- if not a table, then we can assume we have a string
		taskRunning = taskTable
	else
		taskRunning = taskTable[1]
		table.remove(taskTable, 1)
	end
		
	if not taskRunning then return false end
	
	currConfig = MailerDemonHelpers:GetCurrentConfig(taskRunning, db)
	
	if not currConfig then d("current config is nil, aborting...") return false	end
	
	
	local bagSlots = GetBagSize and GetBagSize(BAG_BACKPACK) or select(2, GetBagInfo(BAG_BACKPACK))
	local numSlot = 1
	
	-- if keepRunning is false that means that we won't come here for a third time - we're 
	-- sending refined materials now
	-- before that we're sending raw materials
	
	if MailerDemonHelpers:IsActive(currConfig, keepRunning) then
		
		subject, recipient = MailerDemonHelpers:Evaluate(currConfig, taskRunning, keepRunning)
		
		for bagSlot = 0, bagSlots, 1 do
			
			if  MailerDemonHelpers:CheckSendItem(bagSlot, currConfig, taskRunning) then  -- make sure the item should be sent
			
				if CanQueueItemAttachment(1, bagSlot, numSlot) then	 -- make sure that the item can be attached to a mail (not bound etc)
				QueueItemAttachment(1, bagSlot, numSlot)
				numSlot = numSlot + 1
					if(numSlot == 7) then 
						--ClearQueuedMail()
						d("About to send 1 mail to ".. recipient .. " containing 6 items")
						SendMail(recipient, subject, "")
						numSlot = 1
						zo_callLater(function() MailerDemon:SendMoreMails(task, db, keepRunning) end, 5000)
						return true
					end		
				end				
			end			
				
		end -- for end
		
		if(numSlot ~= 1) then 
			if(numSlot - 1) >= currConfig.MinNumber then
				SendMail(recipient,subject,"")
				--ClearQueuedMail()
				d("About to send 1 mail to ".. recipient .." containing ".. numSlot -1 .."items")
				MailerDemon:EndTask(taskRunning, db, keepRunning)
				numSlot=1
				return true
			else
				ClearQueuedMail()
				MailerDemon:EndTask(taskRunning, db, keepRunning)
				return false
			end
	
		end
		
	end
		return false
end

function MailerDemon:SendMails(...)
	
	-- set keepRunning to true so we know we're here for the first time	 
	local db = self.db
	local keepRunning = self.KeepRunning
	local taskRunning = self.TaskRunning
		
	local success = MailerDemon:AttachAndSend(taskRunning, db, keepRunning)
	
	MailerDemon:EndTask(taskRunning, db, success)

end

function MailerDemon:SendMoreMails(taskRunning, db, keepRunning)	
	
	if not taskRunning then return false end

	local success = MailerDemon:AttachAndSend(taskRunning, db, keepRunning)
	
	MailerDemon:EndTask(taskRunning, db, success)
	
end

function MailerDemon:EndTask(taskRunning, db, success)
	
	local delay = db.delay
	if not success then delay = 0 end
	
	if taskRunning then 
		if string.match(taskRunning, "RAW") then 
			local newtask = taskRunning:gsub("RAW", "")
			self.TaskRunning = newtask
			self.KeepRunning = false
			zo_callLater(function() MailerDemon:SendMoreMails(newtask, db, self.KeepRunning) end, delay)
		else 
			self.TaskRunning = nil
			self.KeepRunning = false	
			MailerDemon:PushButton(taskRunning, "Up")
			return
		end
	end
	
	if self.TaskRunning == nil then
		d("No more items left to send")
		MailerDemon:Reset()
		return
	end
	
end

function MailerDemon:GetDb()
	return self.db
end

function MailerDemon_Initialized( self )
    MAILERDEMON = MailerDemon:New( self )
    SLASH_COMMANDS['/toto'] = function() mTests() end
    SLASH_COMMANDS['/sendmails'] = function() MAILERDEMON:SendMails() end
end

function mTests()
	local button = ZO_MainMenuSceneGroupBar:CreateControl("ButtonTest",CT_CONTROL)
	BTNTEST = button
	button:SetMouseEnabled(true)
	--button:SetHandler('OnMouseEnter',ZO_MenuBarButtonTemplate_OnMouseEnter)
	button:SetParent(ZO_MainMenuSceneGroupBar)
	button:SetAnchor(LEFT,ZO_MainMenuSceneGroupBarButton2,RIGHT,20,0)
	button:SetWidth(32)
	button:SetHeight(32)
	button:SetHandler('OnMouseEnter',function () BTNTEST.IconHightlight:SetHidden(false) end)
	button:SetHandler('OnMouseExit',function() BTNTEST.IconHightlight:SetHidden(true) end)
	local buttonImage = button:CreateControl("ButtonTestIcon",CT_TEXTURE)
	button.Icon = buttonImage
	buttonImage:SetAnchor(128,button,128,0,0)
	buttonImage:SetTexture([[/MailerDemon/Textures/mail_tabicon_inbox_up.dds]])
	buttonImage:SetWidth(64)
	buttonImage:SetDrawLayer(2)
	buttonImage:SetHeight(64)
	
	local buttonImage_Highlight = button:CreateControl("ButtonTestIcon_highlight",CT_TEXTURE)
	button.IconHightlight = buttonImage_Highlight
	buttonImage_Highlight:SetAnchor(128,button,128,0,0)
	buttonImage_Highlight:SetTexture([[/MailerDemon/Textures/mail_tabicon_inbox_over.dds]])
	buttonImage_Highlight:SetWidth(64)
	buttonImage_Highlight:SetDrawLayer(1)
	buttonImage_Highlight:SetHeight(64)
	buttonImage_Highlight:SetHidden(true)	
end

function MailerDemon:CreateCallBack(craft)
return function(self)
		-- If a taskRunning is running already and it's mine : I stop it
		if(MAILERDEMON.TaskRunning ~= nil and MAILERDEMON.TaskRunning == craft) then
			MAILERDEMON:Reset()
			MAILERDEMON:PushButton(craft, "up")
		end
		-- No running tasks I run mine
		MAILERDEMON:Reset()
		MAILERDEMON.KeepRunning = true
		d("Starting task: ".. MailerDemonHelpers:NormalizeString(craft)) -- .. ", keepRunning is: " .. tostring(MAILERDEMON.KeepRunning))	
		MAILERDEMON:PushButton(craft, "down")
		
		if craft == "ALL" then
	
			MAILERDEMON:SendAll()
			return
		else
		
			MAILERDEMON.TaskRunning = craft
			MAILERDEMON:SendMails()
			
		end
			

	end
end


function MailerDemon:PushButton(name, state)
	
	--d("called PushButton with " .. name)
	
	local identifier = MailerDemonHelpers:NormalizeString(name)
	local button = MAILERDEMON.Buttons[identifier]
	
	button.Icon:SetTexture(MailerDemonHelpers:GetTexture(identifier, state))

end

function MailerDemon:Reset()
	self.TaskRunning = nil
	self.KeepRunning = false
	self.SkipValues.Cloth = false
	self.SkipValues.Metal = false
	self.SkipValues.Wood = false
	self.SkipValues.Glyph = false
	self.SkipValues.Food = false
	self.SkipValues.Alchemy = false
	self.SkipValues.Bait = false
end

function MailerDemon:CreateButton(name,anchor,textureUp,textureDown,craft,visible)
	local button = ZO_MainMenuSceneGroupBar:CreateControl(name,CT_CONTROL)
	button:SetMouseEnabled(true)
	--button:SetHandler('OnMouseEnter',ZO_MenuBarButtonTemplate_OnMouseEnter)
	button:SetParent(ZO_MainMenuSceneGroupBar)
	button:SetHidden(not visible)
	
	if(visible) then
		button:SetAnchor(LEFT,self.LastAnchor,RIGHT,20,0)
		self.LastAnchor = button
	end
	button:SetWidth(32)
	button:SetHeight(32)
	button:SetHandler('OnMouseEnter',function (self)
		InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -5)
		SetTooltipText(InformationTooltip, MailerDemonHelpers:NormalizeString(craft))
		self.IconHightlight:SetHidden(false) 
	end)
	button:SetHandler('OnMouseExit',function(self) 
		self.IconHightlight:SetHidden(true) 
		ClearTooltip(InformationTooltip)
		end)
	button:SetHandler('OnMouseDown', MailerDemon:CreateCallBack(craft,textureDown,textureUp) )

	local buttonImage = button:CreateControl(name.."_Icon",CT_TEXTURE)
	button.Icon = buttonImage
	buttonImage:SetAnchor(128,button,128,0,0)
	buttonImage:SetTexture(textureUp)
	buttonImage:SetWidth(32)
	buttonImage:SetDrawLayer(2)
	buttonImage:SetHeight(32)
	
	local buttonImage_Highlight = button:CreateControl(name.."_Icon_highlight",CT_TEXTURE)
	button.IconHightlight = buttonImage_Highlight
	buttonImage_Highlight:SetAnchor(128,button,128,0,0)
	buttonImage_Highlight:SetTexture([[/MailerDemon/Textures/mail_tabicon_inbox_over.dds]])
	buttonImage_Highlight:SetWidth(32)
	buttonImage_Highlight:SetDrawLayer(1)
	buttonImage_Highlight:SetHeight(32)
	buttonImage_Highlight:SetHidden(true)
	
	return button
end

function MailerDemon:CreateButtons()
	if(self.ButtonMetal ~= nil) then
		local lastControl = ZO_MainMenuSceneGroupBarButton2
		
	-- Metal, cloth, wood, glyphs, food, alchemy, bait
		if (MailerDemonHelpers:IsActive(nil, nil, self.db, "Metal")) then
			self.ButtonMetal:SetHidden(false)
			self.ButtonMetal:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.ButtonMetal
		end
		if (MailerDemonHelpers:IsActive(nil, nil, self.db, "Cloth")) then
			self.ButtonCloth:SetHidden(false)
			self.ButtonCloth:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.ButtonCloth
		end
		
		if (MailerDemonHelpers:IsActive(nil, nil, self.db, "Wood")) then
			self.ButtonWood:SetHidden(false)
			self.ButtonWood:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.ButtonWood
		end
		
		if (MailerDemonHelpers:IsActive(nil, nil, self.db, "Glyph")) then
			self.ButtonGlyph:SetHidden(false)
			self.ButtonGlyph:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.ButtonGlyph
		end
		
		if (MailerDemonHelpers:IsActive(nil, nil, self.db, "Alchemy")) then
			self.ButtonAlchemy:SetHidden(false)
			self.ButtonAlchemy:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.ButtonAlchemy
		end
		
		if (MailerDemonHelpers:IsActive(nil, nil, self.db, "Food")) then
			self.ButtonFood:SetHidden(false)
			self.ButtonFood:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.ButtonFood
		end
		
		if (MailerDemonHelpers:IsActive(nil, nil, self.db, "Bait")) then
			self.ButtonBait:SetHidden(false)
			self.ButtonBait:SetAnchor(LEFT,lastControl,RIGHT,20,0)
			lastControl = self.ButtonBait
		end
		
		if(lastControl ~= ZO_MainMenuSceneGroupBarButton2) then
			--self.ButtonAll:SetHidden(false)
			--self.ButtonAll:SetAnchor(LEFT,lastControl,RIGHT,20,0)
		end
	else
	
	-- Metal, cloth, wood, glyphs, food, alchemy, bait
		self.LastAnchor = ZO_MainMenuSceneGroupBarButton2
		
		self.ButtonMetal = self:CreateButton('buttonMailMetal',self.LastAnchor, MailerDemonHelpers:GetTexture("metal", "up"), MailerDemonHelpers:GetTexture("metal", "down"), 'METALRAW',self.db.mailSettings.Metal.Send)
		MailerDemon.Buttons.Metal = self.ButtonMetal
		
		self.ButtonCloth = self:CreateButton('buttonMailCloth', self.ButtonMetal, MailerDemonHelpers:GetTexture("cloth", "up"), MailerDemonHelpers:GetTexture("cloth", "down"), 'CLOTHRAW',self.db.mailSettings.Cloth.Send)
		MailerDemon.Buttons.Cloth = self.ButtonCloth
		
		self.ButtonWood = self:CreateButton('buttonMailWood', self.ButtonCloth, MailerDemonHelpers:GetTexture("wood", "up"), MailerDemonHelpers:GetTexture("wood", "down"), 'WOODRAW',self.db.mailSettings.Wood.Send)
		MailerDemon.Buttons.Wood = self.ButtonWood
		
		self.ButtonGlyph = self:CreateButton('buttonMailGlyph',self.ButtonWood, MailerDemonHelpers:GetTexture("glyph", "up"), MailerDemonHelpers:GetTexture("glyph", "down"), 'GLYPHRAW',self.db.mailSettings.Glyph.Send)
		MailerDemon.Buttons.Glyph = self.ButtonGlyph
		
		self.ButtonFood = self:CreateButton('buttonMailFood',self.ButtonGlyph, MailerDemonHelpers:GetTexture("food", "up"), MailerDemonHelpers:GetTexture("food", "down"), 'FOODRAW',self.db.mailSettings.Food.Send)
		MailerDemon.Buttons.Food = self.ButtonFood
		
		self.ButtonAlchemy = self:CreateButton('buttonMailAlchemy', self.ButtonFood, MailerDemonHelpers:GetTexture("alchemy", "up"), MailerDemonHelpers:GetTexture("alchemy" , "down"),'ALCHEMY ',self.db.mailSettings.Alchemy.Send)
		MailerDemon.Buttons.Alchemy = self.ButtonAlchemy
		
		
		self.ButtonBait = self:CreateButton('buttonMailBait',self.ButtonAlchemy, MailerDemonHelpers:GetTexture("bait", "up"), MailerDemonHelpers:GetTexture("bait", "down"),'BAIT',self.db.mailSettings.Bait.Send)
		MailerDemon.Buttons.Bait = self.ButtonBait
		
		--self.ButtonAll = self:CreateButton('buttonMailAll', self.ButtonBait, MailerDemonHelpers:GetTexture("all", "up"), MailerDemonHelpers:GetTexture("all", "down"), 'ALL' ,true)
		--MailerDemon.Buttons.All = self.ButtonAll
		
	end
end

function MailerDemon:RemoveButtons()

	if(self.ButtonAlchemy ~= nil) then
		self.ButtonAlchemy:SetHidden(true)
		self.ButtonCloth:SetHidden(true)
		self.ButtonFood:SetHidden(true)
		self.ButtonGlyph:SetHidden(true)
		self.ButtonMetal:SetHidden(true)
		self.ButtonWood:SetHidden(true)
		self.ButtonBait:SetHidden(true)
		--self.ButtonAll:SetHidden(true)
	end
	if (self.KeepRunning and self.TaskRunning ~= nil) then
		MailerDemon:OnMailFailure()
	end
end

function MailerDemon:OnMailFailure(reason)	
	
	if self.taskRunning then
		
		MAILERDEMON.TaskRunning(nil)
		MailerDemon:PushButton(self.taskRunning, "up")	
		d("Mail couldn't be sent")
	end

end


-- getter and setter for taskRunning
function MailerDemon:GetTaskRunning() return self.TaskRunning end
function MailerDemon:SetTaskRunning(value) self.TaskRunning = value end

function MailerDemon:IsItemSaved(slot)
	if not excludeSavedItems then return MailerDemonHelpers:IsItemSaved(slot) else return false end
end

function MailerDemon:GetDb() return MailerDemon.db end
function MailerDemon:GetKeepRunning() return self.KeepRunning end