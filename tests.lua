MENU_CATEGORY_MailerDemonMAILS = 13
local catDescriptor = 
    {
        binding = "TOGGLE_MailerDemonMAILS",
        categoryName = "Advanced AutoLoot mail panel",

        descriptor = MENU_CATEGORY_MailerDemonMAILS,
		normal = "MailerDemon/Textures/mail_all_up.dds",
		pressed = "MailerDemon/Textures/mail_all_down.dds",
		disabled = "EsoUI/Art/MainMenu/menuBar_mail_disabled.dds", 
		highlight = "EsoUI/Art/Mail/mail_tabIcon_inbox_over.dds",
    }
do
    local iconData = {
        {
            categoryName = "Send Metal panel",
            descriptor = "MailConfigPanel",
            normal = "MailerDemon/Textures/mail_metal_up.dds",
            pressed = "MailerDemon/Textures/mail_metal_down.dds",
            highlight = "EsoUI/Art/Mail/mail_tabIcon_inbox_over.dds",
        },
    }
	-- Have to add the main menu category myself (not part of the default init)
		local categoryLayoutInfo = catDescriptor
        categoryLayoutInfo.callback = function() MAIN_MENU:OnCategoryClicked(MENU_CATEGORY_MailerDemonMAILS) end
        ZO_MenuBar_AddButton(MAIN_MENU.categoryBar, categoryLayoutInfo)

        local subcategoryBar = CreateControlFromVirtual("ZO_MainMenuSubcategoryBar", MAIN_MENU.control, "ZO_MainMenuSubcategoryBar", i)
        subcategoryBar:SetAnchor(TOP, MAIN_MENU.categoryBar, BOTTOM, 0, 7)
        local subcategoryBarFragment = ZO_FadeSceneFragment:New(subcategoryBar)
        MAIN_MENU.categoryInfo[MENU_CATEGORY_MailerDemonMAILS] =
        {
            barControls = {},
            subcategoryBar = subcategoryBar,
            subcategoryBarFragment = subcategoryBarFragment,
        }
	
	
	
    SCENE_MANAGER:AddGroup("advancedLootMailSceneGroup", ZO_SceneGroup:New("MailConfigPanel"))
    MAIN_MENU:AddSceneGroup(MENU_CATEGORY_MailerDemonMAILS, "advancedLootMailSceneGroup", iconData)
end