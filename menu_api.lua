-- This will automatically append the mod's ID after savegame.mod
version = 12
modid = 'savegame.mod.'
tempid = 'level.assist_menu.'
modules = {}
off_sound = 'MOD/assets/sounds/pause-off.ogg'
on_sound = 'MOD/assets/sounds/pause-on.ogg'
lightbox = 'MOD/assets/images/box-light.png'
darkbox = 'MOD/assets/images/box-dark.png'

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
    makeModule('menu-ingame', 'Ingame Menu', true, 'return'),
    makeModule('inf-timer', 'Freeze Alarm', false, ''),
    makeModule('inf-ammo', 'Infinite Ammo', false, ''),
    makeModule('inf-health', 'Godmode', false, ''),
    makeModule('unlock-tools', 'Unlock Tools', false, ''),
    makeModule('free-cam', 'Free-Camera', true, 'g'),
    makeModule('flight', 'Flight', true, 'f'),
    makeModule('player-boost', 'Player Boost', true, ''),
    makeModule('vehicle-boost', 'Vehicle Boost', true, ''),
    makeModule('clear-debris', 'Clear Debris', true, ''),
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
	UiButtonImageBox(lightbox, 6, 6)
	if GetBool(modid..bool) then
		UiColor(0.3, 1, 0.1)
		if UiTextButton(text..' - Yes', 300, 40) then
			SetBool(modid..bool, false)
			UiSound(off_sound)
		end
	else
		UiColor(1, 0.3, 0.1)
		if UiTextButton(text..' - No', 300, 40) then
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

function IntButton(text, int, min, max, iter)
	UiButtonImageBox(lightbox, 6, 6)
    UiColor(1, 1, 1)
    UiTextButton(text..': '..GetInt(modid..int), 180, 40)
    UiPush()
        UiColor(1, 0.3, 0.1)
        UiAlign('right top')
        UiTranslate(-100, 0)
        if UiTextButton('<', 50, 40) then
            ShiftInt(modid..int, min, max, -iter)
            UiSound(off_sound)
        end
    UiPop()
    UiPush()
        UiColor(0.3, 1, 0.1)
        UiAlign('left top')
        UiTranslate(100, 0)
        if UiTextButton('>', 50, 40) then
            ShiftInt(modid..int, min, max, iter)
            UiSound(on_sound)
        end
    UiPop()
end
