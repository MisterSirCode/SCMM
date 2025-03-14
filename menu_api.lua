-- This will automatically append the mod's ID after savegame.mod
version = 12.2
modid = 'savegame.mod.'
tempid = 'level.sircodesmenu.'
modules = {}
off_sound = 'MOD/assets/sounds/pause-off.ogg'
on_sound = 'MOD/assets/sounds/pause-on.ogg'
lightbox = 'MOD/assets/images/box-light.png'
lightbox_l = 'MOD/assets/images/box-light-left.png'
lightbox_m = 'MOD/assets/images/box-light-mid.png'
lightbox_r = 'MOD/assets/images/box-light-right.png'
darkbox = 'MOD/assets/images/box-dark.png'
button_opacity = 0
debug_opacity = 0
debug_message = ''
button_width = 250
modder_width = 50
button_height = 40
button_hgap = 5
button_vgap = 10
button_bump = button_vgap / 4
setting_bind = false
setting_display = ''
disable_tools = false

function updateDebugMessage(text, state)
	debug_opacity = 2
	debug_message = text
    debug_state = state
end

function resetToDefault(modname)
    for m=1, #modules do
        local mod = modules[m]
        if mod.id == modname then
            if mod.key == true then
                SetString(modid..mod.id..'.key', mod.def)
            elseif mod.key == 'float' then
                SetFloat(modid..mod.id, mod.def)
            end
            updateDebugMessage(mod.name..' reset to default value', '')
        end
    end
end

function validateDefaultOptions()
    if GetBool(modid..'ever_loaded') then
        -- TODO
    else
        SetBool(modid..'ever_loaded', true)
        -- Enable menu by default
        SetBool(modid..modules[1].id, true)
        -- Set menu values
        for m=1, #modules do
            local mod = modules[m]
            if mod.key == true then
                SetString(modid..mod.id..'.key', mod.def)
            elseif mod.key == 'float' then
                SetFloat(modid..mod.id, mod.def)
            end
        end
    end
end

-- Instance a module
function makeModule(id, name, needsKey, defaultKey)
    return {
        id = id,
        name = name,
        key = needsKey,
        def = defaultKey
    }
end

-- Set Defaults
modules = {
    makeModule('menu-ingame', 'Ingame Menu', true, 'return'),
    makeModule('inf-health', 'Godmode', false, ''),
    makeModule('inf-ammo', 'Infinite Ammo', false, ''),
    makeModule('inf-timer', 'Freeze Alarm', false, ''),
    makeModule('unlock-tools', 'Unlock Tools', false, ''),
    makeModule('flight', 'Flight', true, 'Q'),
    makeModule('freecam', 'Freecam', true, 'H'),
    makeModule('player-boost', 'Player Boost', true, 'Q'),
    makeModule('player-boost-hor', 'Horizontal Player Boost', true, 'R'),
    makeModule('player-boost-ver', 'Vertical Player Boost', true, 'Q'),
    makeModule('player-boost-velocity', 'Player Speed', 'float', 0.4),
    makeModule('vehicle-boost', 'Vehicle Boost', true, 'Q'),
    makeModule('vehicle-boost-hor', 'Horizontal Vehicle Boost', true, 'R'),
    makeModule('vehicle-boost-ver', 'Vertical Vehicle Boost', true, 'Q'),
    makeModule('vehicle-boost-velocity', 'Vehicle Speed', 'float', 0.4),
    makeModule('click-fire', 'Click Fire', false, ''),
    makeModule('click-explode', 'Click Explode', false, ''),
    makeModule('explosion-power', 'Explosiveness', 'float', 0.5),
    makeModule('click-delete', 'Click Delete', false, ''),
    makeModule('click-cutter', 'Click Cut', false, ''),
    makeModule('cutting-range', 'Cutting Range', 'float', 10),
    makeModule('override-gravity', 'Override Gravity', false, ''),
    makeModule('gravitation', 'Gravitation', 'float', -10),
    makeModule('extraboostbinds', 'Extra Boost Binds', false, ''),
    makeModule('clear-fires', 'Clear Fires', true, 'O'),
    makeModule('blast-away', 'Blast Away', true, 'B'),
    makeModule('blast-radius', 'Blast Radius', 'float', 10),
    makeModule('delete-debris', 'Delete Debris', true, 'K'),
    makeModule('delete-radius', 'Delete Radius', 'float', 10),
}

function getkey(name)
    return GetString(modid..name..'.key')
end

-- Is module enabled
function moduleByInt(int)
    return GetBool(modid..modules[int])
end

function moduleById(id)
    for m=1, #modules do
        local mod = modules[m]
        if mod.id == modname then
            -- TODO
        end
    end
end

-- flight use
function aorb(a, b, d)
	return (a and d or 0) - (b and d or 0)
end

-- flight use
function getDelta(dt, tr)
    local f, b, l, r, s, c = InputDown('up'),
                             InputDown('down'),
                             InputDown('left'),
                             InputDown('right'),
                             InputDown('jump'),
                             InputDown('shift')
    if f or b or l or r or s or c then
        local dist = InputDown('ctrl') and 0.3 or 0.1
        local fup = aorb(s, c, dist)
        return VecAdd(Vec(0, (f and 0 or fup) + dt / 10, 0), TransformToParentVec(tr, Vec(aorb(r, l, dist), (f and fup or 0), aorb(b, f, dist))))
    end
end

function srnd(n)
	return math.floor(n * 100 + 0.5) / 100
end

function round(n, dp)
	local mult = 10^(dp or 0)
	return math.floor(n * mult + 0.5) / mult
end

function clamp(n, mi, ma)
	if n < mi then n = mi end
	if n > ma then n = ma end
	return n
end

function ActionButton(text, bool, bump)
    if bump then 
        bheight = button_height + button_bump
    else 
        bheight = button_height 
    end
	UiButtonImageBox(lightbox, 6, 6, 1, 1, 1, button_opacity)
    UiColor(1, 1, 1, button_opacity)
    if UiTextButton(text, button_width, bheight) then
        UiSound(on_sound)
        return true
    end
    if bump then
        UiTranslate(0, button_bump)
    end
end

function BoolButton(text, bool, bump)
    if bump then 
        bheight = button_height + button_bump
    else 
        bheight = button_height 
    end
	UiButtonImageBox(lightbox, 6, 6, 1, 1, 1, button_opacity)
	if GetBool(modid..bool) then
        UiColor(0.3, 1, 0.1, button_opacity)
		if UiTextButton(text..' - On', button_width, bheight) then
			SetBool(modid..bool, false)
			UiSound(off_sound)
            return true
		end
	else
		UiColor(1, 0.3, 0.1, button_opacity)
		if UiTextButton(text..' - Off', button_width, bheight) then
			SetBool(modid..bool, true)
			UiSound(on_sound)
            return true
		end
	end
    if bump then
        UiTranslate(0, button_bump)
    end
end

function ShiftInt(int, min, max, iter)
    if iter > 0 and GetInt(int) == max then
        SetInt(int, min)
    elseif iter < 0 and GetInt(int) == min then
        SetInt(int, max)
    else
        SetInt(int, GetInt(int) + iter)
    end
    if GetInt(int) < min then
        SetInt(int, min)
    elseif GetInt(int) > max then
        SetInt(int, max)
    end
end

function ShiftFloat(float, min, max, iter)
    if iter > 0 and GetFloat(float) == max then
        SetFloat(float, min)
    elseif iter < 0 and GetFloat(float) == min then
        SetFloat(float, max)
    else
        SetFloat(float, srnd(GetFloat(float) + iter))
    end
    if GetFloat(float) < min then
        SetFloat(float, min)
    elseif GetFloat(float) > max then
        SetFloat(float, max)
    end
end

function IncDecButton(text, type, value, min, max, iter, bump)
    if bump then 
        bheight = button_height + button_bump
    else 
        bheight = button_height 
    end
    if InputDown('shift') then
        iter = iter * 2
    end
    if InputDown('ctrl') then
        iter = iter / 2
    end
    -- Draw the Decrease button
    UiPush()
    UiPush()
        UiButtonImageBox(lightbox_l, 6, 6, 1, 1, 1, button_opacity)
        UiFont('bold.ttf', 24)
        UiColor(1, 0.3, 0.1, button_opacity)
        if UiTextButton('-', modder_width, bheight) then
            if type == 'int' then
                ShiftInt(modid..value, min, max, -iter)
            else
                ShiftFloat(modid..value, min, max, -iter)
            end
            UiSound(off_sound)
        end
    UiPop()
    -- Draw the Middle box
    local middle_width = button_width - (2 * modder_width) - (2 * button_hgap)
    UiTranslate(button_hgap + modder_width)
	UiButtonImageBox(lightbox_m, 6, 6, 1, 1, 1, button_opacity)
    UiColor(1, 1, 1, button_opacity)
    local valText
    if type == 'int' then
        valText = GetInt(modid..value)
    else
        valText = srnd(GetFloat(modid..value))
    end
    if UiTextButton(text..': '..valText, middle_width, bheight) then
        resetToDefault(value)
    end
    -- Draw the Increase button
    UiTranslate(button_hgap + middle_width)
    UiPush()
        UiButtonImageBox(lightbox_r, 6, 6, 1, 1, 1, button_opacity)
        UiFont('bold.ttf', 24)
        UiColor(0.3, 1, 0.1, button_opacity)
        if UiTextButton('+', modder_width, bheight) then
            if type == 'int' then
                ShiftInt(modid..value, min, max, iter)
            else
                ShiftFloat(modid..value, min, max, iter)
            end
            UiSound(on_sound)
        end
    UiPop()
    UiPop()
    if bump then
        UiTranslate(0, button_bump)
    end
end

function IntButton(text, int, min, max, iter, bump)
    IncDecButton(text, 'int', int, min, max, iter, bump)
end

function FloatButton(text, float, min, max, iter, bump)
    IncDecButton(text, 'float', float, min, max, iter, bump)
end

-- Tool Setter Button
function ToolButton(text, bool, bump)
    if bump then 
        bheight = button_height + button_bump
    else 
        bheight = button_height 
    end
    UiPush()
    local left_width = button_width - button_hgap - modder_width
	UiButtonImageBox(lightbox_l, 6, 6, 1, 1, 1, button_opacity)
	if GetBool(modid..bool) then
        UiColor(0.3, 1, 0.1, button_opacity)
		if UiTextButton(text..' - On', left_width, bheight) then
			SetBool(modid..bool, false)
			UiSound(off_sound)
		end
	else
		UiColor(1, 0.3, 0.1, button_opacity)
		if UiTextButton(text..' - Off', left_width, bheight) then
			SetBool(modid..bool, true)
			UiSound(on_sound)
		end
	end
    UiTranslate(left_width + button_hgap)
	UiButtonImageBox(lightbox_r, 6, 6, 1, 1, 1, button_opacity)
    if disable_tools then
        UiColor(0.4, 0.1, 0.0, 1.0)
    else
        UiColor(0.1, 0.5, 1.0, button_opacity)
    end
    if UiTextButton('Tool', modder_width, bheight) and not disable_tools then
        SetString(modid..bool..'.tool', GetString('game.player.tool'))
        updateDebugMessage(text..' tool updated to '..GetString('game.player.tool'), '')
        UiSound(on_sound)
    end
    UiPop()
    if bump then
        UiTranslate(0, button_bump)
    end
end

-- Keybind Setter
function checkKeyAtFrame()
	local key = InputLastPressedKey()
	if string.len(key) > 0 then
		if key == 'return' then
			updateDebugMessage('Sorry! Return is a reserved keybind!', 'warn')
		else
			SetString(modid..setting_bind..'.key', key)
			updateDebugMessage('Set keybind of '..setting_display..' to '..key, '')
		end
        setting_bind = false
	end
end

-- Keybind Setter Button
function KeyButton(text, bool, bump)
    if bump then 
        bheight = button_height + button_bump
    else 
        bheight = button_height 
    end
    UiPush()
    local left_width = button_width - button_hgap - modder_width
	UiButtonImageBox(lightbox_l, 6, 6, 1, 1, 1, button_opacity)
	if GetBool(modid..bool) then
        UiColor(0.3, 1, 0.1, button_opacity)
		if UiTextButton(text..' - On', left_width, bheight) then
			SetBool(modid..bool, false)
			UiSound(off_sound)
		end
	else
		UiColor(1, 0.3, 0.1, button_opacity)
		if UiTextButton(text..' - Off', left_width, bheight) then
			SetBool(modid..bool, true)
			UiSound(on_sound)
		end
	end
    UiTranslate(left_width + button_hgap)
	UiButtonImageBox(lightbox_r, 6, 6, 1, 1, 1, button_opacity)
    UiColor(1, 1, 0.1, button_opacity)
    if setting_bind == bool then
        if UiTextButton('...', modder_width, bheight) then
            UiSound(off_sound)
        end
    else
        if UiTextButton('Key', modder_width, bheight) then
            setting_bind = bool
            setting_display = text
            UiSound(on_sound)
        end
        if InputPressed('rmb') then
            if UiIsMouseInRect(modder_width, bheight) then
                if GetString(modid..bool..'.key') == "" then
                    updateDebugMessage(text..' is currently not bound to a key', '')
                else
                    updateDebugMessage(text..' is currently bound to '..GetString(modid..bool..'.key'), '')
                end
            end
        end
    end
    UiPop()
    if bump then
        UiTranslate(0, button_bump)
    end
end

function KeybindSelector(text1, bind1, text2, bind2, bump)
    if bump then 
        bheight = button_height + button_bump
    else 
        bheight = button_height 
    end
    UiPush()
    local section_width = button_width / 2 - button_hgap / 2
    UiColor(1, 1, 0.1, button_opacity)
	UiButtonImageBox(lightbox_l, 6, 6, 1, 1, 1, button_opacity)
    if setting_bind == bind1 then
        if UiTextButton('...', section_width, bheight) then
            UiSound(off_sound)
        end
    else
        if UiTextButton(text1..' Key', section_width, bheight) then
            setting_bind = bind1
            setting_display = text1
            UiSound(on_sound)
        end
        if InputPressed('rmb') then
            if UiIsMouseInRect(section_width, bheight) then
                if GetString(modid..bind1..'.key') == "" then
                    updateDebugMessage(text1..' is currently not bound to a key', '')
                else
                    updateDebugMessage(text1..' is currently bound to '..GetString(modid..bind1..'.key'), '')
                end
            end
        end
    end
    UiTranslate(section_width + button_hgap)
	UiButtonImageBox(lightbox_r, 6, 6, 1, 1, 1, button_opacity)
    if setting_bind == bind2 then
        if UiTextButton('...', section_width, bheight) then
            UiSound(off_sound)
        end
    else
        if UiTextButton(text2..' Key', section_width, bheight) then
            setting_bind = bind2
            setting_display = text2
            UiSound(on_sound)
        end
        if InputPressed('rmb') then
            if UiIsMouseInRect(section_width, bheight) then
                if GetString(modid..bind2..'.key') == "" then
                    updateDebugMessage(text2..' is currently not bound to a key', '')
                else
                    updateDebugMessage(text2..' is currently bound to '..GetString(modid..bind2..'.key'), '')
                end
            end
        end
    end
    UiPop()
    if bump then
        UiTranslate(0, button_bump)
    end
end

function drawMenuItems(currentMenuOpacity)
	local vspace = button_vgap + button_height
	local tspace = button_vgap / 2 + button_height
	local hspace = button_vgap + button_width
	UiPush()
		UiTranslate(24, 24)
		UiFont('bold.ttf', 24)
		UiPush()
			UiFont('regular.ttf', 18)
			UiTextShadow(0, 0, 0, 0.5 * math.min(currentMenuOpacity, debug_opacity), 1.0, 0.5)
			UiAlign('right top')
			UiTranslate(hspace * 2 + button_width, 0)
			if debug_state == 'warn' then
				UiColor(1, 0.7, 0.1, math.min(currentMenuOpacity, debug_opacity))
			else
				UiColor(1, 1, 1, math.min(currentMenuOpacity, debug_opacity))
			end
			UiText(debug_message)
		UiPop()
		UiText("SirCode's Mod Menu")
		UiTranslate(0, 24)
		UiFont('bold.ttf', 16)
		UiText('Version '..version)
		UiTranslate(0, 48)
		UiPush()
			-- Debug Use Only
			-- UiTranslate(-0, -30)
			-- if UiTextButton('Reset', 100, 100) then
			-- 	SetBool(modid..'ever_loaded', false)
			-- end
			-- UiTranslate(0, 30)
			-- Debug Use Only End
			BoolButton('Godmode', 'inf-health')
			UiTranslate(0, vspace)
			BoolButton('Infinite Ammo', 'inf-ammo')
			UiTranslate(0, vspace)
			BoolButton('Disable Alarm', 'inf-timer')
			UiTranslate(0, vspace)
			BoolButton('Unlock Tools', 'unlock-tools')
			UiTranslate(0, vspace)
			BoolButton('Override Gravity', 'override-gravity', true)
			UiTranslate(0, tspace)
			FloatButton('Gravitation', 'gravitation', -30, 30, 1, true)
			UiTranslate(0, vspace)
			if GetBool(modid..'extraboostbinds') then
				BoolButton('Player Boost', 'player-boost', true)
				UiTranslate(0, tspace)
				KeybindSelector('Horizontal', 'player-boost-hor', 'Vertical', 'player-boost-ver', true)
			else
				KeyButton('Player Boost', 'player-boost', true)
			end
			UiTranslate(0, tspace)
			FloatButton('Velocity', 'player-boost-velocity', 0, 10, 0.1, true)
		UiPop()
		UiPush()
			UiTranslate(hspace, 0)
			KeyButton('Freecam', 'freecam')
			UiTranslate(0, vspace)
			KeyButton('Flight', 'flight')
			UiTranslate(0, vspace)
			KeyButton('Delete Debris', 'delete-debris', true)
			UiTranslate(0, tspace)
			FloatButton('Delete Radius', 'delete-radius', 0, 100, 5, true)
			UiTranslate(0, vspace)
			KeyButton('Blast Away', 'blast-away', true)
			UiTranslate(0, tspace)
			FloatButton('Blast Radius', 'blast-radius', 0, 100, 5, true)
			UiTranslate(0, vspace)
			if GetBool(modid..'extraboostbinds') then
				BoolButton('Vehicle Boost', 'vehicle-boost', true)
				UiTranslate(0, tspace)
				KeybindSelector('Horizontal', 'vehicle-boost-hor', 'Vertical', 'vehicle-boost-ver', true)
			else
				KeyButton('Vehicle Boost', 'vehicle-boost', true)
			end
			UiTranslate(0, tspace)
			FloatButton('Velocity', 'vehicle-boost-velocity', 0, 10, 0.1, true)
		UiPop()
		UiPush()
			UiTranslate(hspace * 2, 0)
			KeyButton('Clear Fires', 'clear-fires')
			UiTranslate(0, vspace)
			ToolButton('Click Delete', 'click-delete')
			UiTranslate(0, vspace)
			ToolButton('Click Flame', 'click-fire')
			UiTranslate(0, vspace)
			UiTranslate(0, vspace)
			ToolButton('Click Cut', 'click-cutter', true)
			UiTranslate(0, tspace)
			FloatButton('Cutting Range', 'cutting-range', 0, 20, 0.5, true)
			UiTranslate(0, vspace)
			ToolButton('Click Explode', 'click-explode', true)
			UiTranslate(0, tspace)
			FloatButton('Explosiveness', 'explosion-power', 0.5, 4, 0.1, true)
		UiPop()
	UiPop()
end