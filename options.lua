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

function drawInternalMenuItems()
	local vspace = button_gap + button_height
	local tspace = button_gap / 2 + button_height
	local hspace = button_gap + button_width
	UiPush()
		UiTranslate(24, 24)
		UiFont('bold.ttf', 24)
		UiPush()
			UiFont('regular.ttf', 18)
			UiTextShadow(0, 0, 0, 0.5 * debug_opacity, 1.0, 0.5)
			UiAlign('right top')
			UiTranslate(hspace + button_width, 0)
			if debug_state == 'warn' then
				UiColor(1, 0.7, 0.1, debug_opacity)
			else
				UiColor(1, 1, 1, debug_opacity)
			end
			UiText(debug_message)
		UiPop()
		UiText("SirCode's Mod Menu")
		UiTranslate(0, 24)
		UiFont('bold.ttf', 16)
		UiText('Version '..version)
		UiTranslate(0, 48)
		UiPush()
			BoolButton('Godmode', 'inf-health')
			UiTranslate(0, vspace)
			BoolButton('Infinite Ammo', 'inf-ammo')
			UiTranslate(0, vspace)
			BoolButton('Disable Alarm', 'inf-timer')
			UiTranslate(0, vspace)
			BoolButton('Unlock Tools', 'unlock-tools')
			UiTranslate(0, vspace + button_gap)
			BoolButton('Override Gravity', 'override-gravity')
			UiTranslate(0, tspace)
			FloatButton('Gravitation', 'gravitation', -30, 30, 1)
			UiTranslate(0, vspace + button_gap)
			if GetBool(modid..'extraboostbinds') then
				BoolButton('Player Boost', 'player-boost')
				UiTranslate(0, tspace)
				KeybindSelector('Horizontal', 'player-boost-hor', 'Vertical', 'player-boost-ver')
			else
				KeyButton('Player Boost', 'player-boost')
			end
			UiTranslate(0, tspace)
			FloatButton('Velocity', 'player-boost-velocity', 0, 10, 0.1)
		UiPop()
		UiPush()
			UiTranslate(hspace, 0)
			KeyButton('Flight', 'flight')
			UiTranslate(0, vspace)
			ToolButton('Click Delete', 'click-delete')
			UiTranslate(0, vspace)
			ToolButton('Click Flame', 'click-fire')
			UiTranslate(0, vspace)
			-- Extra Spot
			UiTranslate(0, vspace + button_gap)
			ToolButton('Click Explode', 'click-explode')
			UiTranslate(0, tspace)
			FloatButton('Explosiveness', 'explosion-power', 0.5, 4, 0.1)
			UiTranslate(0, vspace + button_gap)
			if GetBool(modid..'extraboostbinds') then
				BoolButton('Vehicle Boost', 'vehicle-boost')
				UiTranslate(0, tspace)
				KeybindSelector('Horizontal', 'vehicle-boost-hor', 'Vertical', 'vehicle-boost-ver')
			else
				KeyButton('Vehicle Boost', 'vehicle-boost')
			end
			UiTranslate(0, tspace)
			FloatButton('Velocity', 'vehicle-boost-velocity', 0, 10, 0.1)
		UiPop()
	UiPop()
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
				drawInternalMenuItems()
			frameWidth, frameHeight = UiEndFrame()
			hasframed = 1
		else
			drawInternalMenuItems()
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
	UiPop()
end
