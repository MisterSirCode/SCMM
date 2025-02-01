-- This will automatically append the mod's ID after savegame.mod
version = 12
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
button_gap = 5
setting_bind = false
setting_display = ''
disable_tools = false

function updateDebugMessage(text, state)
	debug_opacity = 2
	debug_message = text
    debug_state = state
end

function validateDefaultKeys()
    for m=1, #modules do
        local mod = modules[m]
        if mod.key then
            local keypath = modid..mod.id..'.key';
            if GetString(keypath) == '' then
                SetString(keypath, mod.def)
            end
        end
    end
end

function validateDefaultOptions()
    if GetBool(modid..'ever_loaded') then
        -- TODO
    else
        SetBool(modid..'ever_loaded', true)
        -- Enable menu by default
        SetBool(modid..modules[0].id, true)
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
    makeModule('inf-health', 'Godmode', false, ''),
    makeModule('inf-ammo', 'Infinite Ammo', false, ''),
    makeModule('inf-timer', 'Freeze Alarm', false, ''),
    makeModule('unlock-tools', 'Unlock Tools', false, ''),
    makeModule('flight', 'Flight', true, 'f'),
    makeModule('player-boost', 'Player Boost', true, 'q'),
    makeModule('player-boost-velocity', 'Player Speed', true, 0.4),
    makeModule('vehicle-boost', 'Vehicle Boost', true, 'q'),
    makeModule('vehicle-boost-velocity', 'Vehicle Speed', true, 0.4),
    makeModule('click-fire', 'Click Fire', false, ''),
    makeModule('click-explode', 'Click Explode', false, ''),
    makeModule('click-delete', 'Click Delete', false, ''),
    makeModule('click-cutter', 'Click Cut', false, '')
}

-- Is module enabled
function module(int)
    return GetBool(modid..modules[int])
end

function aorb(a, b, d)
	return (a and d or 0) - (b and d or 0)
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

function BoolButton(text, bool)
	UiButtonImageBox(lightbox, 6, 6, 1, 1, 1, button_opacity)
	if GetBool(modid..bool) then
        UiColor(0.3, 1, 0.1, button_opacity)
		if UiTextButton(text..' - On', button_width, button_height) then
			SetBool(modid..bool, false)
			UiSound(off_sound)
		end
	else
		UiColor(1, 0.3, 0.1, button_opacity)
		if UiTextButton(text..' - Off', button_width, button_height) then
			SetBool(modid..bool, true)
			UiSound(on_sound)
		end
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
        SetInt(int, max)
    elseif GetInt(int) > max then
        SetInt(int, min)
    end
end

function ShiftFloat(float, min, max, iter)
    if iter > 0 and GetFloat(float) == max then
        SetFloat(float, min)
    elseif iter < 0 and GetFloat(float) == min then
        SetFloat(float, max)
    else
        SetFloat(float, GetFloat(float) + iter)
    end
    if GetFloat(float) < min then
        SetFloat(float, max)
    elseif GetFloat(float) > max then
        SetFloat(float, min)
    end
end

function IncDecButton(text, type, value, min, max, iter)
    -- Draw the Decrease button
    UiPush()
    UiPush()
        UiButtonImageBox(lightbox_l, 6, 6, 1, 1, 1, button_opacity)
        UiFont('bold.ttf', 24)
        UiColor(1, 0.3, 0.1, button_opacity)
        if UiTextButton('-', modder_width, button_height) then
            if type == 'int' then
                ShiftInt(modid..value, min, max, -iter)
            else
                ShiftFloat(modid..value, min, max, -iter)
            end
            UiSound(off_sound)
        end
    UiPop()
    -- Draw the Middle box
    local middle_width = button_width - (2 * modder_width) - (2 * button_gap)
    UiTranslate(button_gap + modder_width)
	UiButtonImageBox(lightbox_m, 6, 6, 1, 1, 1, button_opacity)
    UiColor(1, 1, 1, button_opacity)
    local valText
    if type == 'int' then
        valText = GetInt(modid..value)
    else
        valText = math.floor(GetFloat(modid..value) * 1000) / 1000
    end
    UiTextButton(text..': '..valText, middle_width, button_height)
    -- Draw the Increase button
    UiTranslate(button_gap + middle_width)
    UiPush()
        UiButtonImageBox(lightbox_r, 6, 6, 1, 1, 1, button_opacity)
        UiFont('bold.ttf', 24)
        UiColor(0.3, 1, 0.1, button_opacity)
        if UiTextButton('+', modder_width, button_height) then
            if type == 'int' then
                ShiftInt(modid..value, min, max, iter)
            else
                ShiftFloat(modid..value, min, max, iter)
            end
            UiSound(on_sound)
        end
    UiPop()
    UiPop()
end

function IntButton(text, int, min, max, iter)
    IncDecButton(text, 'int', int, min, max, iter)
end

function FloatButton(text, float, min, max, iter)
    IncDecButton(text, 'float', float, min, max, iter)
end

-- Tool Setter Button
function ToolButton(text, bool)
    UiPush()
    local left_width = button_width - button_gap - modder_width
	UiButtonImageBox(lightbox_l, 6, 6, 1, 1, 1, button_opacity)
	if GetBool(modid..bool) then
        UiColor(0.3, 1, 0.1, button_opacity)
		if UiTextButton(text..' - On', left_width, button_height) then
			SetBool(modid..bool, false)
			UiSound(off_sound)
		end
	else
		UiColor(1, 0.3, 0.1, button_opacity)
		if UiTextButton(text..' - Off', left_width, button_height) then
			SetBool(modid..bool, true)
			UiSound(on_sound)
		end
	end
    UiTranslate(left_width + button_gap)
	UiButtonImageBox(lightbox_r, 6, 6, 1, 1, 1, button_opacity)
    if disable_tools then
        UiColor(0.4, 0.1, 0.0, 1.0)
    else
        UiColor(0.1, 0.5, 1.0, button_opacity)
    end
    if UiTextButton('Tool', modder_width, button_height) and not disable_tools then
        SetString(modid..bool..'.tool', GetString('game.player.tool'))
        updateDebugMessage(text..' tool updated to '..GetString('game.player.tool'), '')
        UiSound(on_sound)
    end
    UiPop()
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
function KeyButton(text, bool)
    UiPush()
    local left_width = button_width - button_gap - modder_width
	UiButtonImageBox(lightbox_l, 6, 6, 1, 1, 1, button_opacity)
	if GetBool(modid..bool) then
        UiColor(0.3, 1, 0.1, button_opacity)
		if UiTextButton(text..' - On', left_width, button_height) then
			SetBool(modid..bool, false)
			UiSound(off_sound)
		end
	else
		UiColor(1, 0.3, 0.1, button_opacity)
		if UiTextButton(text..' - Off', left_width, button_height) then
			SetBool(modid..bool, true)
			UiSound(on_sound)
		end
	end
    UiTranslate(left_width + button_gap)
	UiButtonImageBox(lightbox_r, 6, 6, 1, 1, 1, button_opacity)
    UiColor(1, 1, 0.1, button_opacity)
    if setting_bind == bool then
        if UiTextButton('...', modder_width, button_height) then
            UiSound(off_sound)
        end
    else
        if UiTextButton('Key', modder_width, button_height) then
            setting_bind = bool
            setting_display = text
            UiSound(on_sound)
        end
    end
    UiPop()
end