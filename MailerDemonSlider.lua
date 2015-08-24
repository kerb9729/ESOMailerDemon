local MinMaxRangeSlider = ZO_Object:Subclass()
AwesomeGuildStore.MinMaxRangeSlider = MinMaxRangeSlider

function MinMaxRangeSlider:New(parent, name, x, y, width, height)
	local slider = ZO_Object.New(self)
	slider.min, slider.max, slider.step, slider.interval = 1, 2, 1, 0
	slider.minRange = 0
	slider.enabled = true

	local control = CreateControlFromVirtual(name, parent, "AwesomeGuildStoreMinMaxRangeSliderTemplate")
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
	control:SetDimensions(width, height)
	slider.control = control

	local minSlider = control:GetNamedChild("MinSlider")
	minSlider.value = 0
	minSlider.offset = -4
	minSlider.SetValue = self.SetMinValue
	slider.minSlider = minSlider

	local maxSlider = control:GetNamedChild("MaxSlider")
	maxSlider.value = 0
	maxSlider.offset = 4
	maxSlider.SetValue = self.SetMaxValue
	slider.maxSlider = maxSlider

	slider.rangeSlider = control:GetNamedChild("RangeSlider")

	slider.fullRange = control:GetNamedChild("FullRange")

	slider.x, slider.y = x, y
	slider.offsetX = minSlider:GetWidth() / 2
	slider:SetMinMax(1, 2)
	slider:SetStepSize(1)
	slider:SetRangeValue(1, 2)

	slider:InitializeHandlers()

	control.parent = slider
	slider.control = control

	return slider
end

function MinMaxRangeSlider:InitializeHandlers()
	local function PositionToValue(x)
		return math.floor((x - self.offsetX) / self.interval) + self.step
	end

	local function OnRangeDragStart(clickedControl, button)
		if self.enabled then
			clickedControl.dragging = true
			clickedControl.draggingXStart = GetUIMousePosition()
			clickedControl.dragStartOldX = self.minSlider.oldX
			clickedControl.difference = self.maxSlider.value - self.minSlider.value
		end
	end

	local function OnRangeDragStop(clickedControl, button, upInside)
		if clickedControl.dragging then
			clickedControl.dragging = false

			local totalDeltaX = GetUIMousePosition() - clickedControl.draggingXStart
			local newValue = PositionToValue(clickedControl.dragStartOldX + totalDeltaX)
			if(newValue ~= self.minSlider.value and not (newValue < self.min) and not (newValue + clickedControl.difference > self.max)) then
				self:SetMinValue(newValue)
				self:SetMaxValue(newValue + clickedControl.difference)
			end
		end
	end

	local function OnSliderDragStart(clickedControl, button)
		if self.enabled then
			clickedControl.dragging = true
			clickedControl.draggingXStart = GetUIMousePosition()
			clickedControl.dragStartOldX = clickedControl.oldX
		end
	end

	local function OnSliderDragStop(clickedControl)
		if clickedControl.dragging then
			clickedControl.dragging = false

			local totalDeltaX = GetUIMousePosition() - clickedControl.draggingXStart
			local newValue = PositionToValue(clickedControl.dragStartOldX + totalDeltaX)
			if(newValue ~= clickedControl.value) then clickedControl.SetValue(self, newValue) end
		end
	end

	local function OnSliderMouseUp(clickedControl, button, upInside)
		if clickedControl.dragging and button == 1 then
			OnSliderDragStop(clickedControl)
		end
	end

	local function OnSliderUpdate(control)
		if control.dragging then
			local totalDeltaX = GetUIMousePosition() - control.draggingXStart
			local newValue = PositionToValue(control.dragStartOldX + totalDeltaX)
			if(newValue ~= control.value) then control.SetValue(self, newValue) end
		end
	end

	local function OnRangeUpdate(control)
		if control.dragging then
			local totalDeltaX = GetUIMousePosition() - control.draggingXStart
			local newValue = PositionToValue(control.dragStartOldX + totalDeltaX)
			if(newValue ~= self.minSlider.value and not (newValue < self.min) and not (newValue + control.difference > self.max)) then
				self:SetMinValue(newValue)
				self:SetMaxValue(newValue + control.difference)
			end
		end
	end

	self.minSlider:SetHandler("OnDragStart", OnSliderDragStart)
	self.minSlider:SetHandler("OnMouseUp", OnSliderMouseUp)
	self.minSlider:SetHandler("OnUpdate", OnSliderUpdate)

	self.maxSlider:SetHandler("OnDragStart", OnSliderDragStart)
	self.maxSlider:SetHandler("OnMouseUp", OnSliderMouseUp)
	self.maxSlider:SetHandler("OnUpdate", OnSliderUpdate)

	self.rangeSlider:SetHandler("OnDragStart", OnRangeDragStart)
	self.rangeSlider:SetHandler("OnMouseUp", OnRangeDragStop)
	self.rangeSlider:SetHandler("OnUpdate", OnRangeUpdate)

	self.fullRange:SetHandler("OnMouseDown", function(control, button)
		local offset = control:GetScreenRect() - self.interval/2 - self.minSlider.offset
		control.pressedValue = PositionToValue(GetUIMousePosition() - offset)
		control.isPressed = true
		control.lastUpdateTime = GetFrameTimeSeconds()
		control.updateCount = 0
		control.moveDistance = 1
	end)
	self.fullRange:SetHandler("OnMouseUp", function(control, button)
		control.isPressed = false
	end)
	self.fullRange:SetHandler("OnUpdate", function(control, time)
		if(control.isPressed and time - control.lastUpdateTime > 0.15) then
			local min, max = self:GetRangeValue()
			local avg = math.floor((min + max) / 2)

			if(control.pressedValue < min) then
				local value = min - control.moveDistance
				self:SetMinValue((value < control.pressedValue) and control.pressedValue or value)
			elseif(control.pressedValue > min and control.pressedValue < avg) then
				local value = min + control.moveDistance
				self:SetMinValue((value > control.pressedValue) and control.pressedValue or value)
			elseif(control.pressedValue > avg and control.pressedValue < max) then
				local value = max - control.moveDistance
				self:SetMaxValue((value < control.pressedValue) and control.pressedValue or value)
			elseif(control.pressedValue > max) then
				local value = max + control.moveDistance
				self:SetMaxValue((value > control.pressedValue) and control.pressedValue or value)
			end

			control.lastUpdateTime = time
			control.updateCount = control.updateCount + 1
			if(control.updateCount > 2) then
				control.moveDistance = control.moveDistance * 2
				control.updateCount = 0
			end
		end
	end)
end

function MinMaxRangeSlider:SetMinValue(value)
	if(value < self.min) then
		value = self.min
	elseif(value > self.maxSlider.value - self.minRange) then
		value = self.maxSlider.value - self.minRange
	end
	local x = self.x + self.offsetX + (value - self.step) * self.interval + self.minSlider.offset

	self.minSlider.value = value
	self.minSlider:ClearAnchors()
	self.minSlider:SetAnchor(TOPCENTER, self.control, TOPLEFT, x, 0)
	self.minSlider.oldX = x
	self:OnValueChanged(self:GetRangeValue())
end

function MinMaxRangeSlider:SetMaxValue(value)
	if(value > self.max) then
		value = self.max
	elseif(value < self.minSlider.value + self.minRange) then
		value = self.minSlider.value + self.minRange
	end
	local x = self.x + self.offsetX + (value - self.step) * self.interval + self.maxSlider.offset

	self.maxSlider.value = value
	self.maxSlider:ClearAnchors()
	self.maxSlider:SetAnchor(TOPCENTER, self.control, TOPLEFT, x, 0)
	self.maxSlider.oldX = x
	self:OnValueChanged(self:GetRangeValue())
end

function MinMaxRangeSlider:SetMinMax(min, max)
	self.min = min
	self.max = max
	self:SetStepSize(self:GetStepSize())
	self:SetRangeValue(self:GetRangeValue())
end

function MinMaxRangeSlider:SetRangeValue(minValue, maxValue)
	self:SetMaxValue(maxValue)
	self:SetMinValue(minValue)
	if(self.maxSlider.value ~= maxValue) then
		self:SetMaxValue(maxValue) -- set again to prevent max not getting set to the right value when min is larger than max
	end
end

function MinMaxRangeSlider:GetRangeValue()
	return self.minSlider.value, self.maxSlider.value
end

function MinMaxRangeSlider:SetMinRange(value)
	self.minRange = value
	self:SetRangeValue(self:GetRangeValue())
end

function MinMaxRangeSlider:GetMinRange(value)
	return self.minRange
end

function MinMaxRangeSlider:GetRangeValue()
	return self.minSlider.value, self.maxSlider.value
end

function MinMaxRangeSlider:SetStepSize(step)
	self.step = step
	self.interval = (self.control:GetWidth() - (self.minSlider:GetWidth() + self.maxSlider:GetWidth())) / ((self.max - self.min) * self.step)
end

function MinMaxRangeSlider:GetStepSize()
	return self.step
end

function MinMaxRangeSlider:SetEnabled(enable)
	self.enabled = enable
	self.minSlider:SetEnabled(enable)
	self.maxSlider:SetEnabled(enable)
	self.rangeSlider:SetEnabled(enable)
end

function MinMaxRangeSlider:IsEnabled()
	return self.enabled
end

function MinMaxRangeSlider:OnValueChanged(min, max)
-- overwrite this
end


local L = AwesomeGuildStore.Localization
local MinMaxRangeSlider = AwesomeGuildStore.MinMaxRangeSlider

local BUTTON_SIZE = 36
local BUTTON_X = -7
local BUTTON_Y = 46
local BUTTON_SPACING = 7.5
local RESET_BUTTON_SIZE = 18
local RESET_BUTTON_TEXTURE = "EsoUI/Art/Buttons/decline_%s.dds"

local QualitySelector = ZO_Object:Subclass()
AwesomeGuildStore.QualitySelector = QualitySelector

local function CreateButtonControl(parent, name, textureName, tooltipText, callback, saveData)
	local buttonControl = CreateControlFromVirtual(name .. "NormalQualityButton", parent, "ZO_DefaultButton")
	buttonControl:SetNormalTexture(textureName:format("up"))
	buttonControl:SetPressedTexture(textureName:format("down"))
	buttonControl:SetMouseOverTexture("AwesomeGuildStore/images/qualitybuttons/over.dds")
	buttonControl:SetEndCapWidth(0)
	buttonControl:SetDimensions(BUTTON_SIZE, BUTTON_SIZE)
	buttonControl:SetHandler("OnMouseDoubleClick", function(control, button)
		callback(3)
	end)
	buttonControl:SetHandler("OnMouseUp", function(control, button, isInside, ctrl, alt, shift)
		if(isInside) then
			local oldBehavior = saveData.oldQualitySelectorBehavior
			local setBoth = (oldBehavior and shift) or (not oldBehavior and not shift)
			if(setBoth) then
				callback(3)
			else
				callback(button)
			end
			if(button ~= 1) then
				-- the mouse down event does not fire for right and middle click and the button does not show any click behavior at all
				-- we emulate it by changing the texture for a bit and playing the click sound manually
				buttonControl:SetNormalTexture(textureName:format("down"))
				buttonControl:SetMouseOverTexture("")
				zo_callLater(function()
					buttonControl:SetNormalTexture(textureName:format("up"))
					buttonControl:SetMouseOverTexture("AwesomeGuildStore/images/qualitybuttons/over.dds")
				end, 100)
				PlaySound("Click")
			end
		end
	end)
	buttonControl:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(buttonControl, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, tooltipText)
	end)
	buttonControl:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	return buttonControl
end

function QualitySelector:New(parent, name, saveData)
	local selector = ZO_Object.New(self)
	selector.callbackName = name .. "Changed"
	selector.type = 4

	local container = parent:CreateControl(name .. "Container", CT_CONTROL)
	container:SetDimensions(195, 100)
	selector.control = container

	local label = container:CreateControl(name .. "Label", CT_LABEL)
	label:SetFont("ZoFontWinH4")
	label:SetText(L["QUALITY_SELECTOR_TITLE"])
	label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)

	local slider = MinMaxRangeSlider:New(container, name .. "QualitySlider", 0, 30, 195, 16)
	slider:SetMinMax(1, 5)
	slider:SetRangeValue(1, 5)
	slider.OnValueChanged = function(self, min, max)
		selector:HandleChange()
		selector.resetButton:SetHidden(selector:IsDefault())
	end
	selector.slider = slider

	ZO_PreHook(TRADING_HOUSE.m_search, "InternalExecuteSearch", function(self)
		local min, max = slider:GetRangeValue()
		if min == 1 then min = ITEM_QUALITY_TRASH end
		if min == max then max = nil end
		self.m_filters[TRADING_HOUSE_FILTER_TYPE_QUALITY].values = {min, max}
	end)

	local function SafeSetRangeValue(button, value)
		local min, max = slider:GetRangeValue()
		if(button == 1) then
			if(value > max) then slider:SetMaxValue(value) end
			slider:SetMinValue(value)
		elseif(button == 2) then
			if(value < min) then slider:SetMinValue(value) end
			slider:SetMaxValue(value)
		elseif(button == 3) then
			slider:SetRangeValue(value, value)
		end
	end

	local normalButton = CreateButtonControl(container, name .. "NormalQualityButton", "AwesomeGuildStore/images/qualitybuttons/normal_%s.dds", L["NORMAL_QUALITY_LABEL"], function(button)
		SafeSetRangeValue(button, 1)
	end, saveData)
	normalButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X, BUTTON_Y)

	local magicButton = CreateButtonControl(container, name .. "MagicQualityButton", "AwesomeGuildStore/images/qualitybuttons/magic_%s.dds", L["MAGIC_QUALITY_LABEL"], function(button)
		SafeSetRangeValue(button, 2)
	end, saveData)
	magicButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING), BUTTON_Y)

	local arcaneButton = CreateButtonControl(container, name .. "ArcaneQualityButton", "AwesomeGuildStore/images/qualitybuttons/arcane_%s.dds", L["ARCANE_QUALITY_LABEL"], function(button)
		SafeSetRangeValue(button, 3)
	end, saveData)
	arcaneButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 2, BUTTON_Y)

	local artifactButton = CreateButtonControl(container, name .. "ArtifactQualityButton", "AwesomeGuildStore/images/qualitybuttons/artifact_%s.dds", L["ARTIFACT_QUALITY_LABEL"], function(button)
		SafeSetRangeValue(button, 4)
	end, saveData)
	artifactButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 3, BUTTON_Y)

	local legendaryButton = CreateButtonControl(container, name .. "LegendaryQualityButton", "AwesomeGuildStore/images/qualitybuttons/legendary_%s.dds", L["LEGENDARY_QUALITY_LABEL"], function(button)
		SafeSetRangeValue(button, 5)
	end, saveData)
	legendaryButton:SetAnchor(TOPLEFT, container, TOPLEFT, BUTTON_X + (BUTTON_SIZE + BUTTON_SPACING) * 4, BUTTON_Y)

	local resetButton = CreateControlFromVirtual(name .. "ResetButton", parent, "ZO_DefaultButton")
	resetButton:SetNormalTexture(RESET_BUTTON_TEXTURE:format("up"))
	resetButton:SetPressedTexture(RESET_BUTTON_TEXTURE:format("down"))
	resetButton:SetMouseOverTexture(RESET_BUTTON_TEXTURE:format("over"))
	resetButton:SetEndCapWidth(0)
	resetButton:SetDimensions(RESET_BUTTON_SIZE, RESET_BUTTON_SIZE)
	resetButton:SetAnchor(TOPRIGHT, label, TOPLEFT, 196, 0)
	resetButton:SetHidden(true)
	resetButton:SetHandler("OnMouseUp",function(control, button, isInside)
		if(button == 1 and isInside) then
			selector:Reset()
		end
	end)
	local text = L["RESET_FILTER_LABEL_TEMPLATE"]:format(label:GetText():gsub(":", ""))
	resetButton:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip)
		InformationTooltip:ClearAnchors()
		InformationTooltip:SetOwner(resetButton, BOTTOM, 5, 0)
		SetTooltipText(InformationTooltip, text)
	end)
	resetButton:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	selector.resetButton = resetButton

	return selector
end

function QualitySelector:HandleChange()
	if(not self.fireChangeCallback) then
		self.fireChangeCallback = zo_callLater(function()
			self.fireChangeCallback = nil
			CALLBACK_MANAGER:FireCallbacks(self.callbackName, self)
		end, 100)
	end
end

function QualitySelector:Reset()
	self.slider:SetRangeValue(1, 5)
end

function QualitySelector:IsDefault()
	local min, max = self.slider:GetRangeValue()
	return (min == 1 and max == 5)
end

function QualitySelector:Serialize()
	local min, max = self.slider:GetRangeValue()
	return tostring(min) .. ";" .. tostring(max)
end

function QualitySelector:Deserialize(state)
	local min, max = zo_strsplit(";", state)
	assert(min and max)
	self.slider:SetRangeValue(tonumber(min), tonumber(max))
end
