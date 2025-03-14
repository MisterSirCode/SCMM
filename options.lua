#include "menu_api.lua"

local uidelay = 0.1
local hasframed = 0
local frameWidth, frameHeight
currentDebugOpacity = 0
currentDebugMessage = ''
local button_gap = 10

function init()
	validateDefaultOptions()
	disable_tools = true
end

function draw()
	-- Keybind Setting
	if setting_bind then
		checkKeyAtFrame()
	end

	-- Defaults
	debug_opacity = debug_opacity - 0.01
	button_opacity = 1.0

	-- Begin UI Layer
	UiPush()
		UiAlign('left top')
		UiTextShadow(0, 0, 0, 0.5, 1.0, 0.5)
		-- Set width and height of menu ingame
		local margins = 24
		local width = UiWidth() / 2
		local height = UiHeight() / 2
		if hasframed == 1 then
			width = frameWidth + margins
			height = frameHeight + margins
			UiTranslate(UiCenter() - width / 2, UiMiddle() - height / 2)
		end
		-- Draw internal elements
		if hasframed == 0 then
			UiWindow(0, 0, true)
			UiBeginFrame()
			drawMenuItems(1)
			frameWidth, frameHeight = UiEndFrame()
			hasframed = 1
		else
			drawMenuItems(1)
		end
	UiPop()
	UiPush()
		UiFont('regular.ttf', 18)
		UiPush()
			UiAlign('left top')
			UiFont('bold.ttf', 16)
			UiTranslate(20, 20)
			if BoolButton('Extra Boost Keybinds', 'extraboostbinds') then
				hasframed = 0
			end
		UiPop()
		UiAlign('right top')
		UiTranslate(UiWidth() - 50, 50)
		UiText('Tips!')
		UiTranslate(0, 24)
		UiText('The blue "Tool" button selects the currently held tool for that mod')
		UiTranslate(0, 24)
		UiText('(Obviously that means theyre disabled in the options menu)')
		UiTranslate(0, 24)
		UiText('The yellow "Key" button will query a keybind to use for that mod.')
		UiTranslate(0, 24)
		UiText('Clicking the white text on a value button will reset to defaults.')
		UiTranslate(0, 24)
		UiText('Hold Shift while changing a value to double the increment / decrement.')
		UiTranslate(0, 24)
		UiText('Hold Ctrl while changing a value to halve the increment / decrement.')
		UiTranslate(0, 24)
		UiText('Right Click a keybind button to see what its bound to.')
	UiPop()
end
