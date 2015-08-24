MailerDemonConfig                               = ZO_Object:Subclass()
MailerDemonConfig.db                            = nil


MailerDemonConfig.overallValues	= {

	Send = false, 
	SendRaw = false,
	SendMaterials = false,
	SendBoosters = false,
	To = "",
	Subject = "",
	RawTo = "",
	RawSubject = "",
	MinNumber = 1,
	MinQuality = 1, 
	MinRawQuality = 1,
	MaxQuality = 3,
	MaxRawQuality = 3,

}

local CBM = CALLBACK_MANAGER
local LAM = LibStub( 'LibAddonMenu-2.0' )

local database = nil

if ( not LAM ) then return end

function MailerDemonConfig:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function MailerDemonConfig:Initialize( db )
    self.db = db
	database = db
	
	local panelData = {
		type = "panel",
		name = "Mailer Demon",
		author = "manavortex, based on the work of Mandrakia, proofing by Slater2715",
		slashCommand = "/md",
		registerForRefresh = true,
		registerForDefaults  = true,
	}
	
	LAM:RegisterAddonPanel("MailerDemonOptions", panelData)
	
	local optionsData = {
	
	--{	type = "submenu", -- general settings
	--	name = "Overall settings",
	--	tooltip = "",	--(optional)
	--	controls = {
	
		
			{type = "description",
				text = "Here you can preconfigure the add-on:" 
			},
			
			{type = "description",
				text = "You can enter the name of a recipient for the stuff in your bag." ,
			},
			
			{type = "description",
				text = "To send crafting materials to a different recipient than deconstructables, just enter a name in the corresponding box." ..
				"You can enter subjects below. The subject will be automatically expanded with the name of the configuration, e.g., if you enter 'bounce', it will become 'bounce metal' etc.",
			},
			
			{type = "description",
				text ="",
			},
		
			{	type = "header", -- config
					name = "General settings - override below",
			},
				
			{	type = "checkbox", -- Send
				name = "Send deconstructables?",
				tooltip ="Will activate deconstructable items for clothing, blacksmithing, enchanting and woodworing",
				getFunc = function() return  MailerDemonConfig.overallValues.Send end,
				setFunc = function( value ) MailerDemonConfig.UpdateValues(self.db.mailSettings, Send, value, true) end,
			},

			{	type = "checkbox", -- SendRaw, SendMaterials
				name = "Send crafting material?",
				tooltip ="Will send both unrefined and refined materials away, including essence and potency runes. Fine config below.",
				getFunc = function() return  MailerDemonConfig.overallValues.SendRaw end,
				setFunc = function( value ) 
					MailerDemonConfig.UpdateValues(self.db.mailSettings, "SendRaw", value, true) 
					MailerDemonConfig.UpdateValues(self.db.mailSettings, "SendMaterials", value, true) 
				end,	
			},
			
			{	type = "checkbox", -- SendBoosters
				name = "Send boosters?",
				tooltip ="Will send boosters away, including potency runes.",
				getFunc = function() return  MailerDemonConfig.overallValues.SendBooster end,
				setFunc = function( value ) MailerDemonConfig.UpdateValues(self.db.mailSettings, "SendBooster", value, true) end,
					-- if not value ==  MailerDemonConfig.overallValues.SendBoosters then
						-- for craft, values in pairs(self.db.mailSettings) do
							-- values.SendBoosters = value
						-- end
					-- end
					
			},
			
			{	type = "editbox", -- To
				name = "Deconstructables recipient",
				tooltip = "Set recipient for deconstructables here",
				getFunc = function() return  MailerDemonConfig.overallValues.To end,
				setFunc = function( value ) MailerDemonConfig.UpdateValues(self.db.mailSettings, "To", value, true) end,
			},
			
			{	type = "editbox", -- Subject
				name = "Deconstructables subject",
				tooltip = "The name of what you are sending (wood, metal, cloth) will be added automatically",
				getFunc = function() return  MailerDemonConfig.overallValues.Subject end,
				setFunc = function( value ) MailerDemonConfig.UpdateValues(self.db.mailSettings, "Subject", value, true) end,
			},

			{	type = "editbox", -- RawTo
				name = "Raw materials recipient",
				tooltip = "Set recipient for raw material here",
				getFunc = function() return  MailerDemonConfig.overallValues.RawTo end,
				setFunc = function( value ) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawTo", value, true) end,
			},
			
			{	type = "editbox", -- RawSubject
				name = "Raw materials subject",
				tooltip = "The name of the configuration will be added automatically",
				getFunc = function() return  MailerDemonConfig.overallValues.RawSubject end,
				setFunc = function( value ) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawSubject", value, true) end,
			},
			
			{	type = "slider", -- MinNumber
				name = "Minimum mail items",
				tooltip = "You can override this setting below",
				min = 1, 
				max = 6, 
				getFunc = function() return  MailerDemonConfig.overallValues.MinNumber end,
				setFunc = function( value ) MailerDemonConfig.UpdateValues(self.db.mailSettings, "MinNumber", value, true) end,
			},
			
			{	type = "slider", -- MinQuality, MinRawQuality
				name = "Minimum quality of items to send",
				tooltip = "You can override this setting below (1=white,5=legendary)",
				min = 1, 
				max = 5, 
				getFunc = function() return  MailerDemonConfig.overallValues.MinQuality end,
				setFunc = function( value ) 
				MailerDemonConfig.UpdateValues(self.db.mailSettings, "MinQuality", value, true) 
				MailerDemonConfig.UpdateValues(self.db.mailSettings, "MinRawQuality", value, true) 
				end,
			},
			
			{	type = "slider", -- MaxQuality, MaxRawQuality
				name = "Maxiumum quality of items to send",
				tooltip = "Maximum quality items to send (1=white,5=legendary)",
				min = 1, 
				max = 5, 
				getFunc = function() return  MailerDemonConfig.overallValues.MaxQuality end,
				setFunc = function( value ) 
				MailerDemonConfig.UpdateValues(self.db.mailSettings, "MaxQuality", value, true) 
				MailerDemonConfig.UpdateValues(self.db.mailSettings, "MaxRawQuality", value, true) 
				end,
			},	
	--	},
	--}
	
	
	{	type = "submenu", -- -- Metal
			name = "Metal settings",
			tooltip = "",	--(optional)
			controls = {
			
				{	type = "checkbox", -- send metal?
					name = "Mail metal equipment?",
					width = "half",
					tooltip ="Do you have someone to deconstruct all those for you?",
					getFunc = function() return self.db.mailSettings.Metal.Send end,
					setFunc = function() self.db.mailSettings.Metal.Send = not self.db.mailSettings.Metal.Send end,
				},
				
				{	type = "checkbox", -- keep ornate?
					name = "             ... even if ornate?",
					width = "half",
					tooltip = "Should we keep ornate? items?",
					getFunc = function() return self.db.mailSettings.Metal.KeepOrnate end,
					setFunc = function() self.db.mailSettings.Metal.KeepOrnate = not self.db.mailSettings.Metal.KeepOrnate end,
				},
				
				{	type = "editbox", -- Metal.To
					name = "Recipient",
					tooltip = "Who should get your metal equipment?",
					getFunc = function() return self.db.mailSettings.Metal.To end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "To", value, false, "Metal") end,
					 
				},
				
				{	type = "editbox", -- Metal.Subject
					name = "Subject",
					tooltip = "Would you like to tell them something?",
					getFunc = function() return self.db.mailSettings.Metal.Subject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "Subject", value, false, "Metal") end,
				},
				
				{	type = "slider", -- Metal.MinQuality
					name = "Minimum quality of items to send",
					tooltip = "Minimum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.MinQuality end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MinQuality = mini end,
				},
				
				{	type = "slider", -- Metal.MaxQuality
					name = "Maxiumum quality of items to send",
					tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.MaxQuality end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MaxQuality = mini end,
				},
				
				{	type = "header", --
					name = "Raw Material",
				},
			
				{	type = "checkbox", -- Metal.SendRaw
					name = "Send unrefined ore?",
					width = "half",
					tooltip = "Should we send ore?",
					getFunc = function() return self.db.mailSettings.Metal.SendRaw end,
					setFunc = function() self.db.mailSettings.Metal.SendRaw = not self.db.mailSettings.Metal.SendRaw end,
				},	
				
				{	type = "checkbox", -- Metal.SendMaterials
					width = "half",
					name = "             Send ingots?",
					tooltip = "Should we send ingots?",
					getFunc = function() return self.db.mailSettings.Metal.SendMaterials end,
					setFunc = function() self.db.mailSettings.Metal.SendMaterials = not self.db.mailSettings.Metal.SendMaterials end,
				},
				
				{	type = "checkbox", -- Metal.SendBoosters
					name = "Send tempers?",
					tooltip = "Should we send Honing Stone, Dwarven Oil, Grain Solvent..?",
					getFunc = function() return self.db.mailSettings.Metal.SendBoosters end,
					setFunc = function() self.db.mailSettings.Metal.SendBoosters = not self.db.mailSettings.Metal.SendBoosters end,
				},
				
				{	type = "editbox",  -- Metal.RawTo
					name = "Who should get your unrefined ore?",
					tooltip = "Not necessary to fill this if you haven't checked the box",
					getFunc = function() return self.db.mailSettings.Metal.RawTo end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawTo", value, false, "Metal") end,
					 
				},
				
				{	type = "editbox",  -- Metal.RawSubject 
					name = "Ore and temper topic",
					tooltip = "Not necessary to fill this if you haven't checked the box",
					getFunc = function() return self.db.mailSettings.Metal.RawSubject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawSubject", value, false, "Metal") end,
				},

				{	type = "slider", -- Metal.RawMinQuality
					name = "Minimum quality of crafting material to send",
					tooltip = "Minimum quality of crafting material items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.RawMinQuality end,
					setFunc = function( mini ) self.db.mailSettings.Metal.RawMinQuality = mini end,
				},
				
				{	type = "slider", -- Metal.MaxRawQuality
					name = "Maxiumum quality of crafting material to send",
					tooltip = "Maximum quality of crafting material items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.MaxRawQuality end,
					setFunc = function( value ) self.db.mailSettings.Metal.MaxRawQuality = value end,
				},
				

			}, 
			
		}, -- Metal submenu end
	
	{   type = "submenu", -- Cloth / Leather
		name = "Cloth/Leather settings",
		tooltip = "",	--(optional)
		controls = {
		
			{	type = "checkbox", -- send cloth?
				name = "Mail clothier deconstructables?",
				width = "half",
				tooltip = "Do you have someone to deconstruct all those for you?",
				getFunc = function() return self.db.mailSettings.Cloth.Send end,
				setFunc = function() self.db.mailSettings.Cloth.Send = not self.db.mailSettings.Cloth.Send end,
			},
			{	type = "checkbox", -- keep ornate??
				name = "             ... even if ornate?",
				width = "half",
				tooltip = "Should we keep ornate items??",
				getFunc = function() return self.db.mailSettings.Cloth.KeepOrnate end,
				setFunc = function() self.db.mailSettings.Cloth.KeepOrnate = not self.db.mailSettings.Cloth.KeepOrnate end,
			},
			{	type = "editbox", -- recipient
				name = "Recipient",
				tooltip = "Who should get your light and medium armor equipment?",
				getFunc = function() return self.db.mailSettings.Cloth.To end,
				setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "To", value, false, "Cloth") end,
				 
			},
			{	type = "editbox", -- subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return self.db.mailSettings.Cloth.Subject end,
				setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "Subject", value, false, "Cloth") end,
			},
			
			{	type = "slider", -- min quality
				name = "Minimum quality",
				tooltip = "Minimum quality of equipment items to send (1=white,5=legendary)",
				min = 1, 
				max = 5, 
				getFunc = function() return self.db.mailSettings.Cloth.MinQuality end,
				setFunc = function( mini ) self.db.mailSettings.Cloth.MinQuality = mini end,
			},
			{	type = "slider", -- max quality
				name = "Maxiumum quality",
				tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
				min = 1, 
				max = 5, 
				getFunc = function() return self.db.mailSettings.Cloth.MaxQuality end,
				setFunc = function( mini ) self.db.mailSettings.Cloth.MaxQuality = mini end,
			},
			
			{	type = "header", -- raw
				name = "Raw Material",
			},
		
			{	type = "checkbox", -- send raw
				name = "Send fibers/scraps?",
				width = "half",
				tooltip = "Should we send leather scraps and cloth fibers?",
				getFunc = function() return self.db.mailSettings.Cloth.SendRaw end,
				setFunc = function() self.db.mailSettings.Cloth.SendRaw = not self.db.mailSettings.Cloth.SendRaw end,
			},	
	
			{	type = "checkbox", -- send refined
				name = "             Send cloth/leather?",
				width = "half",
				tooltip = "Should we send cloth and hide?",
				getFunc = function() return self.db.mailSettings.Cloth.SendMaterials end,
				setFunc = function() self.db.mailSettings.Cloth.SendMaterials = not self.db.mailSettings.Cloth.SendMaterials end,
			},
			{	type = "checkbox", -- send boosters
				name = "Send tempers?",
				tooltip = "Should we send Hemming, Elegant Lining, Embroidery..?",
				getFunc = function() return self.db.mailSettings.Cloth.SendBoosters end,
				setFunc = function() self.db.mailSettings.Cloth.SendBoosters = not self.db.mailSettings.Cloth.SendBoosters end,
			},
			
			{	type = "editbox",  -- rawTo
				name = "Who should get your clothing material?",
				tooltip = "Not necessary to fill this if you haven't checked the box",
				getFunc = function() return self.db.mailSettings.Cloth.RawTo end,
				setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawTo", value, false, "Cloth") end,
				 
			},
			{	type = "editbox",  -- rawSubject
				name = "Scrap and fiber topic",
				tooltip = "Not necessary to fill this if you haven't checked the box",
				getFunc = function() return self.db.mailSettings.Cloth.RawSubject end,
				setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawSubject", value, false, "Cloth") end,
			},
			
			{	type = "slider", -- RawMinQuality
				name = "Minimum quality of crafting material to send",
				tooltip = "Minimum quality of crafting material items to send (1=white,5=legendary)",
				min = 1, 
				max = 5, 
				getFunc = function() return self.db.mailSettings.Cloth.RawMinQuality end,
				setFunc = function( mini ) self.db.mailSettings.Cloth.RawMinQuality = mini end,
			},
			{	type = "slider", -- RawMaxQuality
				name = "Maxiumum quality of crafting material to send",
				tooltip = "Maximum quality of crafting material items to send (1=white,5=legendary)",
				min = 1, 
				max = 5, 
				getFunc = function() return self.db.mailSettings.Cloth.MaxRawQuality end,
				setFunc = function( value ) self.db.mailSettings.Cloth.MaxRawQuality = value end,
			},

		}, 
		
	}, -- cloth submenu end		
		
	{	type = "submenu", -- -- Wood
			name = "Wood settings",
			tooltip = "",	--(optional)
			controls = {
			
				{	type = "checkbox", -- send
				name = "Mail bows, staves and shields?",
				width = "half",
				tooltip = "Do you have someone to deconstruct all those for you?",
				getFunc = function() return self.db.mailSettings.Wood.Send end,
				setFunc = function() self.db.mailSettings.Wood.Send = not self.db.mailSettings.Wood.Send end,
				},
				{	type = "checkbox", -- Wood.KeepOrnate
					name = "             ... even if ornate?",
					width = "half",
					tooltip = "Should we keep ornate? items?",
					getFunc = function() return self.db.mailSettings.Wood.KeepOrnate end,
					setFunc = function() self.db.mailSettings.Wood.KeepOrnate = not self.db.mailSettings.Wood.KeepOrnate end,
				},
				{	type = "editbox", -- Wood.To
					name = "Recipient",
					tooltip = "Who should get your wooden weaponry and shields?",
					getFunc = function() return self.db.mailSettings.Wood.To end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "To", value, false, "Wood") end,
					 
				},
				{	type = "editbox", -- Wood.Subject
					name = "Subject",
					tooltip = "Would you like to tell them something?",
					getFunc = function() return self.db.mailSettings.Wood.Subject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "Subject", value, false, "Wood") end,
				},
				
				{	type = "slider", -- Wood.MinQuality
					name = "Minimum quality",
					tooltip = "Minimum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.MinQuality end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MinQuality = mini end,
				},
				{	type = "slider", -- Wood.MaxQuality
					name = "Maxiumum quality",
					tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.MaxQuality end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MaxQuality = mini end,
				},
				
				 {	type = "header",
					name = "Raw Material",
				},
			
				{	type = "checkbox", -- Wood.SendRaw
					name = "Send rough wood?",
					width = "half",
					tooltip = "Should we send lumber and flotsam?",
					getFunc = function() return self.db.mailSettings.Wood.SendRaw end,
					setFunc = function() self.db.mailSettings.Wood.SendRaw = not self.db.mailSettings.Wood.SendRaw end,
				},	
				
				{	type = "checkbox", -- Wood.SendMaterials
					name = "             Send sanded wood?",
					width = "half",
					tooltip = "Should we send sanded wood?",
					getFunc = function() return self.db.mailSettings.Wood.SendMaterials end,
					setFunc = function() self.db.mailSettings.Wood.SendMaterials = not self.db.mailSettings.Wood.SendMaterials end,
				},
				{	type = "checkbox", -- Wood.SendBoosters
					name = "Send tempers?",
					tooltip = "Should we send Pitch, Turpen, Mastic..?",
					getFunc = function() return self.db.mailSettings.Wood.SendBoosters end,
					setFunc = function() self.db.mailSettings.Wood.SendBoosters = not self.db.mailSettings.Wood.SendBoosters end,
				},
				
				{	type = "editbox", -- Wood.RawTo
					name = "Who should get your woodworking material?",
					tooltip = "Not necessary to fill this if you haven't checked the box above",
					getFunc = function() return self.db.mailSettings.Wood.RawTo end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawTo", value, false, "Wood") end,
					 
				},
				{	type = "editbox",  -- Wood.RawSubject
					name = "Lumber and flotsam topic",
					tooltip = "Not necessary to fill this if you haven't checked the box above",
					getFunc = function() return self.db.mailSettings.Wood.RawSubject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawSubject", value, false, "Wood") end,
				},
				{	type = "slider", -- Wood.RawMinQuality 
					name = "Minimum quality of crafting material and tempers to send",
					tooltip = "Minimum quality of crafting material items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.RawMinQuality end,
					setFunc = function( mini ) self.db.mailSettings.Wood.RawMinQuality = mini end,
				},
				{	type = "slider", --Wood.MaxRawQuality
					name = "Maxiumum quality of crafting material and tempers to send",
					tooltip = "Maximum quality of crafting material items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.MaxRawQuality end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MaxRawQuality = mini end,
				},

			}, -- wood controls end
			
	}, -- wood submenu end			
	
	{	type = "submenu", -- -- Glyphs	
		name = "Glyphs settings",
		controls = {
			
				{	type = "checkbox", -- Glyph.Send
				name = "Mail Glyphs?",
				tooltip = "Do you have someone to deconstruct all those for you?",
				getFunc = function() return self.db.mailSettings.Glyph.Send end,
				setFunc = function() self.db.mailSettings.Glyph.Send = not self.db.mailSettings.Glyph.Send end,
				},
				
				{	type = "editbox", -- Glyph.To
					name = "Recipient",
					tooltip = "Who should get your Glyphs?",
					getFunc = function() return self.db.mailSettings.Glyph.To end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "To", value, false, "Glyph") end,
					 
				},
				{	type = "editbox", -- Glyph.Subject
					name = "Subject",
					tooltip = "Would you like to tell them something?",
					getFunc = function() return self.db.mailSettings.Glyph.Subject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "Subject", value, false, "Glyph") end,
				},
				
				{	type = "slider", -- Glyph.MinQuality
					name = "Minimum quality",
					tooltip = "Minimum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Glyph.MinQuality end,
					setFunc = function( mini ) self.db.mailSettings.Glyph.MinQuality = mini end,
				},
				{	type = "slider", -- Glyph.MaxQuality
					name = "Maxiumum quality",
					tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Glyph.MaxQuality end,
					setFunc = function( mini ) self.db.mailSettings.Glyph.MaxQuality = mini end,
				},
				
				 {	type = "header",
					name = "Runestones",
				},
			
				{	type = "checkbox", -- Glyph.SendRaw and Glyph.SendMaterials 
					name = "Send runes??",
					width = "half",
					tooltip = "Potency and Essence - the square-ish and triangle-ish ones",
					getFunc = function() return self.db.mailSettings.Glyph.SendRaw end,
					setFunc = (function() 
						self.db.mailSettings.Glyph.SendRaw = not self.db.mailSettings.Glyph.SendRaw 
						self.db.mailSettings.Glyph.SendMaterials = not self.db.mailSettings.Glyph.SendMaterials 
					end),
				},	

				{	type = "checkbox", -- Glyph.SendBoosters
					name = "             Send Aspect runes?",
					width = "half",
					tooltip = "Should we send Ta, Jejota, Denata, Rekuta, Kuta?",
					getFunc = function() return self.db.mailSettings.Glyph.SendBoosters end,
					setFunc = function() self.db.mailSettings.Glyph.SendBoosters = not self.db.mailSettings.Glyph.SendBoosters end,
				},
								
				{	type = "editbox", -- Glyph.RawTo
					name = "Who should get your runestones?",
					tooltip = "Not necessary to fill this if you haven't checked the box above",
					getFunc = function() return self.db.mailSettings.Glyph.RawTo end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawTo", value, false, "Glyph") end,
					
				},
				{	type = "editbox", -- Glyph.RawSubject
					name = "Runestone topic",
					tooltip = "Not necessary to fill this if you haven't checked the box above",
					getFunc = function() return self.db.mailSettings.Glyph.RawSubject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawSubject", value, false, "Glyph") end,
				},
				{	type = "slider", -- Glyph.RawMinQuality
					name = "Minimum quality of aspect runes to send",
					tooltip = "Minimum quality of aspect runes to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Glyph.RawMinQuality end,
					setFunc = function( mini ) self.db.mailSettings.Glyph.RawMinQuality = mini end,
				},
				{	type = "slider", -- Glyph.MaxRawQuality
					name = "Maxiumum quality of aspect runes to send",
					tooltip = "Maximum quality of aspect runes to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Glyph.MaxRawQuality end,
					setFunc = function( mini ) self.db.mailSettings.Glyph.MaxRawQuality = mini end,
				},

			}, -- wood controls end
			
	}, -- glyphs submenu end		
	
	{	type = "submenu", -- -- Food
			name = "Food settings",
			tooltip = "",	--(optional)
			controls = {
			
				{	type = "checkbox", -- Food.Send
				name = "Mail Ingredients?",
				tooltip = "You don't cook yourself, do you?",
				getFunc = function() return self.db.mailSettings.Food.Send end,
				setFunc = function() self.db.mailSettings.Food.Send = not self.db.mailSettings.Food.Send end,
				},
				
				{	type = "editbox", -- Food.To
					name = "Recipient",
					tooltip = "Who is your cook?",
					getFunc = function() return self.db.mailSettings.Food.To end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "To", value, false, "Food") end,
					 
				},
				{	type = "editbox", -- Food.Subject
					name = "Subject",
					tooltip = "Would you like to tell them something?",
					getFunc = function() return self.db.mailSettings.Food.Subject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "Subject", value, false, "Food") end,
				},
				
				{	type = "header",
					name = "Recipes",
				},
			
				{	type = "checkbox", -- Food.SendBoosters - Recipes
					name = "Send recipes?",
					tooltip = "Should we send recipes as well?",
					getFunc = function() return self.db.mailSettings.Food.SendBoosters end,
					setFunc = function() self.db.mailSettings.Food.SendBoosters = not self.db.mailSettings.Food.SendBoosters end,
				},					
				
				{	type = "editbox", -- Food.RawTo - Recipes
					name = "Insert name of mother-in-law here",
					tooltip = "Not necessary to fill this if you haven't checked the box above",
					getFunc = function() return self.db.mailSettings.Food.RawTo end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawTo", value, false, "Food") end,
					
				},
				{	type = "editbox",  -- Food.RawSubject - Recipes
					name = "Recipe topic",
					tooltip = "Not necessary to fill this if you haven't checked the box above",
					getFunc = function() return self.db.mailSettings.Food.RawSubject end,
					setFunc = function(value) MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawSubject", value, false, "Food") end,
				},
				{	type = "slider", -- Food.RawMinQuality - Recipes
					name = "Minimum quality of recipes to send",
					tooltip = "Minimum quality of aspect runes to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Food.RawMinQuality end,
					setFunc = function( mini ) self.db.mailSettings.Food.RawMinQuality = mini end,
				},
				{	type = "slider", -- Food.MaxRawQuality - Recipes
					name = "Maxiumum quality of recipes to send",
					tooltip = "Maximum quality of aspect runes to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Food.MaxRawQuality end,
					setFunc = function( mini ) self.db.mailSettings.Food.MaxRawQuality = mini end,
				},

			}, -- food controls end
		
		}, -- Food submenu end		
	
	{	type = "submenu", -- -- Alchemy
			name = "Alchemy settings",
			
			controls = {
			
				{	type = "checkbox",  -- Alchemy.Send - Flowers
					name = "Mail flowers?",
					width = "half",
					tooltip = "Who is your alchemist??",
					getFunc = function() return self.db.mailSettings.Alchemy.Send end,
					setFunc = function() 
					self.db.mailSettings.Alchemy.Send = not self.db.mailSettings.Alchemy.Send 
					self.db.mailSettings.Glyph.SendRaw = not self.db.mailSettings.Alchemy.SendRaw 
					self.db.mailSettings.Glyph.SendMaterials = not self.db.mailSettings.Alchemy.SendMaterials 
				end,
				},
				{	type = "checkbox",  -- Alchemy.KeepOrnate - Solvent
					name = "             Send solvents?",
					width = "half",
					tooltip = "Argonians like water, they say",
					getFunc = function() return not self.db.mailSettings.Alchemy.KeepOrnate end,
					setFunc = (function( value) self.db.mailSettings.Alchemy.KeepOrnate = not value			
					end),
				},	
				{	type = "editbox",   -- Alchemy.To - Flowers
					name = "Recipient",
					tooltip = "Who is your sweetheart?",
					getFunc = function() return self.db.mailSettings.Alchemy.To end,
					setFunc = function(value) 
						MailerDemonConfig.UpdateValues(self.db.mailSettings, "To", value, false, "Alchemy") 
						MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawTo", value, false, "Alchemy") 
					end,
				},
				{	type = "editbox",   -- Alchemy.Subject - Flowers
					name = "Subject",
					tooltip = "Would you like to tell them something?",
					getFunc = function() return self.db.mailSettings.Alchemy.Subject end,
					setFunc = function(value) 
						MailerDemonConfig.UpdateValues(self.db.mailSettings, "Subject", value, false, "Alchemy") 
						MailerDemonConfig.UpdateValues(self.db.mailSettings, "RawSubject", value, false, "Alchemy") 
					end,
				},
				
			}, -- alchemy controls end
		
		}, -- Alchemy submenu end
		
	 {	type = "submenu", -- Bait
		name = "Bait settings",
		
		controls = {
		
			{	type = "checkbox", -- Bait.Send
				name = "Mail lures?",
				tooltip = "We all have that one friend who likes fishing",
				getFunc = function() return self.db.mailSettings.Bait.Send end,
				setFunc = function() self.db.mailSettings.Bait.Send = not self.db.mailSettings.Bait.Send end,
				},
				
			{	type = "editbox", -- Bait.To
				name = "Recipient",
				tooltip = "Who is this patient person?",
				getFunc = function() return self.db.mailSettings.Bait.To end,
				setFunc = function(value) self.db.mailSettings.Bait.To = value end,
				 
			},
			
			{	type = "editbox", -- Bait.Subject
				name = "Subject",
				tooltip = "Would you like to tell them something?",
				getFunc = function() return self.db.mailSettings.Bait.Subject end,
				setFunc = function(value) self.db.mailSettings.Bait.Subject = value end,
			},				
			
			
			{	type = "slider", -- Bait.MinNumber
				name = "Minimum mail items",
				min = 1, 
				max = 6, 
				getFunc = function() return self.db.mailSettings.Bait.MinNumber end,
				setFunc = function( mini ) self.db.mailSettings.Bait.MinNumber = mini end,
			},	
		}, -- bait controls
		
	}, -- Bait submenu
	
	}	 -- optionsData end
	LAM:RegisterOptionControls("MailerDemonOptions", optionsData)
	 
end

function MailerDemonConfig.UpdateValues(mailSettings, key, value, override, name)
		
		
	for craft, values in pairs(mailSettings) do
		
		if override and not name then 
			if not (value ==  MailerDemonConfig.overallValues[key]) then
				values[key] = value
			end
		elseif not override and name then
			if (values.Name == name) then 
				values[key] = value
			end
		end

		MailerDemonConfig.CheckSplitStuff(values)
		
	end
	
	
end

function MailerDemonConfig.CheckSplitStuff(values)

	-- check if there are different subjects - in this case we need to send two mails
	values.SplitStuff = values.SplitStuff or (values.Subject == values.RawSubject)
		
	-- check if there are different recipients - in this case we need to send two mails
	values.SplitStuff = values.SplitStuff or (values.To == values.rawTo)
	
end

function getfield(f)
  local v = _G    -- start with the table of globals
  for w in string.gfind(f, "[%w_]+") do
	v = v[w]
  end
  return v
end
