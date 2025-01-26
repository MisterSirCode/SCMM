modid = "savegame.mod.assist_menu."
tempid = "level.assist_menu."
modules = {}

function validateDefaultKeys()
    for m=1, #modules do
        local mod = modules[m]
        if mod.key then
            local keypath = modid..mod.id..".key";
            if GetString(keypath).len() == 0 then
                SetString(keypath, mod.def)
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
    makeModule("menu-open", "Ingame Menu", true, "return"),
    makeModule("inf-timer", "Freeze Alarm", false, ""),
    makeModule("inf-ammo", "Infinite Ammo", false, ""),
    makeModule("inf-health", "Godmode", false, ""),
    makeModule("unlock-tools", "Unlock Tools", false, ""),
    makeModule("free-cam", "Free-Camera", true, "g"),
    makeModule("flight", "Flight", true, "f"),
    makeModule("player-boost", "Player Boost", true, ""),
    makeModule("vehicle-boost", "Vehicle Boost", true, ""),
    makeModule("clear-debris", "Clear Debris", true, ""),
    makeModule("click-fire", "Click Fire", false, ""),
    makeModule("click-explode", "Click Explode", false, ""),
    makeModule("click-delete", "Click Delete", false, ""),
    makeModule("click-cutter", "Click Cut", false, "")
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
	UiButtonImageBox('MOD/assets/images/box-light.png', 6, 6)
	if GetBool(key..bool) then
		UiColor(0.3, 1, 0.1)
		if UiTextButton(text..' - Yes', 300, 40) then
			SetBool(key..bool, false)
			UiSound('MOD/assets/sounds/pause-off.ogg')
		end
	else
		UiColor(1, 0.3, 0.1)
		if UiTextButton(text..' - No', 300, 40) then
			SetBool(key..bool, true)
			UiSound('MOD/assets/sounds/pause-on.ogg')
		end
	end
end

function ShiftInt(int, min, max, iter)
    SetInt(int, GetInt(int) + iter)
    if GetInt(int) < min then
        SetInt(int, max)
    elseif GetInt(int) > max then
        SetInt(int, min)
    end
end

function IntButton(text, int, min, max, iter)
	UiButtonImageBox('MOD/assets/images/box-light.png', 6, 6)
    UiColor(1, 1, 1)
    UiTextButton(text..' - '..GetInt(key..int), 180, 40)
    UiPush()
        UiColor(1, 0.3, 0.1)
        UiAlign('right top')
        UiTranslate(-100, 0)
        if UiTextButton('<', 50, 40) then
            ShiftInt(key..int, min, max, -iter)
            UiSound('MOD/assets/sounds/pause-off.ogg')
        end
    UiPop()
    UiPush()
        UiColor(0.3, 1, 0.1)
        UiAlign('left top')
        UiTranslate(100, 0)
        if UiTextButton('>', 50, 40) then
            ShiftInt(key..int, min, max, iter)
            UiSound('MOD/assets/sounds/pause-on.ogg')
        end
    UiPop()
end
