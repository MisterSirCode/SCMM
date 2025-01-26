local toolIds = {
    "sledge",
    "spraycan",
    "extinguisher",
	"leafblower",
    "blowtorch",
    "shotgun",
    "gun",
	"rifle",
    "pipebomb",
	"bomb",
	"rocket",
	"explosive"
}

local toolImages = {
    "sledge.png",
    "spraycan.png",
    "extinguisher.png",
	"leafblower.png",
    "blowtorch.png",
    "shotgun.png",
    "gun.png",
	"rifle.png",
    "pipebomb.png",
	"bomb.png",
    "launcher.png",
	"explosive.png"
}

local toolNames = {
	"Sledge",
	"Spray Can",
	"Extinguisher",
	"Leafblower",
	"Blowtorch",
	"Shotgun",
	"Gun",
	"Hunting Rifle",
	"Pipe Bomb",
	"Bomb",
	"Rocket Launcher",
	"Nitroglycerin"
}

local keyList = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"shift",
	"ctrl",
	"esc",
	"return"
}

local function clamp(value, mi, ma)
	if value < mi then value = mi end
	if value > ma then value = ma end
	return value
end

local function round(n, dp)
	local mult = 10^(dp or 0)
	return math.floor(n * mult + 0.5) / mult
end

local function DrawCheatButton(text, bool)
	UiButtonImageBox("MOD/Images/box-light.png", 6, 6)
	if GetBool("savegame.mod.scmm."..bool) then
		UiColor(0, 1, 0)
		if UiTextButton(text.." - ON", 300, 40) then
			SetBool("savegame.mod.scmm."..bool, false)
			UiSound("Sounds/BlipLower.wav")
		end
	else
		UiColor(1, 0, 0)
		if UiTextButton(text.." - OFF", 300, 40) then
			SetBool("savegame.mod.scmm."..bool, true)
			UiSound("Sounds/BlipHigher.wav")
		end
	end
end

local function DrawCheatButtonSet(text, bool, useSettings)
	UiPush()
		UiButtonImageBox("MOD/Images/box-light-left.png", 6, 6)
		UiColor(1, 1, 1)
		if UiTextButton(text, 200, 40) then
			SetBool("level.scmm.descOpen", true)
			SetString("level.scmm.curTool", bool)
			SetString("level.scmm.curToolText", text)
			UiSound("Sounds/BlipHigher.wav")
		end
		UiTranslate(125, 0)
		UiButtonImageBox("MOD/Images/box-light-mid.png", 6, 6)
		if useSettings then
			UiColor(1, 0.8, 0)
			if UiTextButton("+", 40, 40) then
				SetBool("level.scmm.settingsOpen", true)
				SetString("level.scmm.curTool", bool)
				SetString("level.scmm.curToolText", text)
				UiSound("Sounds/BlipHigher.wav")
			end
		else
			UiTextButton(" ", 40, 40)
		end
		UiTranslate(55, 0)
		UiColor(1, 1, 1)
		UiButtonImageBox("MOD/Images/box-light-right.png", 6, 6)
		if GetBool("savegame.mod.scmm."..bool) then
			UiColor(0, 1, 0)
			if UiTextButton("ON", 60, 40) then
				SetBool("savegame.mod.scmm."..bool, false)
				UiSound("Sounds/BlipLower.wav")
			end
		else
			UiColor(1, 0, 0)
			if UiTextButton("OFF", 60, 40) then
				SetBool("savegame.mod.scmm."..bool, true)
				UiSound("Sounds/BlipHigher.wav")
			end
		end
		UiButtonImageBox("MOD/Images/box-light.png", 6, 6)
	UiPop()
end

local function DrawIncDecSet(float, incdec, min, max)
	UiPush()
		UiButtonImageBox("MOD/Images/box-light-left.png", 6, 6)
		UiColor(1, 0.6, 0.6)
		UiTranslate(-65, 0)
		if UiTextButton("-", 60, 40) then
			SetFloat("savegame.mod.scmm."..float, round(clamp(GetFloat("savegame.mod.scmm."..float) - incdec, min, max), 1))
			UiSound("Sounds/BlipLower.wav")
		end
		UiTranslate(65, 0)
		UiButtonImageBox("MOD/Images/box-light-mid.png", 6, 6)
		UiColor(1, 1, 1)
		UiTextButton(round(GetFloat("savegame.mod.scmm."..float), 1), 60, 40)
		UiTranslate(65, 0)
		UiButtonImageBox("MOD/Images/box-light-right.png", 6, 6)
		UiColor(0.6, 1, 0.6)
		if UiTextButton("+", 60, 40) then
			SetFloat("savegame.mod.scmm."..float, round(clamp(GetFloat("savegame.mod.scmm."..float) + incdec, min, max), 1))
			UiSound("Sounds/BlipHigher.wav")
		end
	UiPop()
end

local function DrawKeybindSet(bool, keybind)
	UiPush()
		UiButtonImageBox("MOD/Images/box-light-left.png", 6, 6)
		UiColor(1, 1, 1)
		UiTranslate(-35, 0)
		UiTextButton("Key", 60, 40)
		UiTranslate(65, 0)
		UiButtonImageBox("MOD/Images/box-light-right.png", 6, 6)
		if GetBool("isSettingKey-"..bool..keybind) then
			UiColor(1, 0.8, 0)
			UiTextButton("_", 60, 40)
			for i = 1, #keyList do
				if InputPressed(keyList[i]) then 
					SetString("savegame.mod.scmm."..bool..keybind, keyList[i]) 
					SetBool("isSettingKey-"..bool..keybind, false)
				break end
			end
		else
			UiColor(1, 0.8, 0)
			if UiTextButton(GetString("savegame.mod.scmm."..bool..keybind), 60, 40) then
				SetBool("isSettingKey-"..bool..keybind, true)
				UiSound("Sounds/BlipHigher.wav")
			end
		end
	UiPop()
end

local function DrawToolSelector(int)
	UiPush()
		if GetInt("savegame.mod.scmm."..int) == 0 then
			SetInt("savegame.mod.scmm."..int, 1)
		end
		local toolId = toolIds[GetInt("savegame.mod.scmm."..int)]
		local toolImage = toolImages[GetInt("savegame.mod.scmm."..int)]
		local toolName = toolNames[GetInt("savegame.mod.scmm."..int)]
		UiButtonImageBox("MOD/Images/box-light-left.png", 6, 6)
		UiColor(1, 0.8, 0)
		UiTranslate(-65, 0)
		if UiTextButton("<<", 60, 40) then
			UiSound("Sounds/BlipHigher.wav")
			local toolInt = GetInt("savegame.mod.scmm."..int)
			SetInt("savegame.mod.scmm."..int, clamp(toolInt-1, 1, #toolIds))
		end
		UiTranslate(65, 0)
		UiButtonImageBox("MOD/Images/box-light-mid.png", 6, 6)
		UiColor(1, 1, 1)
		UiScale(0.1)
		UiImage("Tools/"..toolImage)
		UiScale(10)
		UiTranslate(65, 0)
		UiButtonImageBox("MOD/Images/box-light-right.png", 6, 6)
		UiColor(1, 0.8, 0)
		if UiTextButton(">>", 60, 40) then
			UiSound("Sounds/BlipHigher.wav")
			local toolInt = GetInt("savegame.mod.scmm."..int)
			SetInt("savegame.mod.scmm."..int, clamp(toolInt+1, 1, #toolIds))
		end
	UiPop()
end

function init()
	if GetBool("savegame.mod.scmm.startedUsingMenu") == false then
		SetBool("savegame.mod.scmm.ingame-menu", true)
		SetFloat("savegame.mod.scmm.player-boost-velocity", 0.3)
		SetFloat("savegame.mod.scmm.vehicle-boost-velocity", 0.3)
		SetFloat("savegame.mod.scmm.free-cam-velocity", 1.0)
		SetFloat("savegame.mod.scmm.click-explode-power", 2)
		SetFloat("savegame.mod.scmm.click-destroy-power", 5)
		SetFloat("savegame.mod.scmm.blast-away-radius", 10)
		SetFloat("savegame.mod.scmm.clear-debris-radius", 10)
		SetFloat("savegame.mod.scmm.ray-cutter-radius", 0.2)
		SetString("savegame.mod.scmm.ingame-menu0", "return")
		SetString("savegame.mod.scmm.free-cam0", "g")
		SetString("savegame.mod.scmm.blast-away0", "b")
		SetString("savegame.mod.scmm.vehicle-boost0", "q")
		SetString("savegame.mod.scmm.vehicle-boost1", "r")
		SetString("savegame.mod.scmm.player-boost0", "q")
		SetString("savegame.mod.scmm.player-boost1", "r")
		SetString("savegame.mod.scmm.ray-cutter0", "l")
		SetString("savegame.mod.scmm.clear-debris0", "k")
		SetString("savegame.mod.scmm.flight0", "v")
		SetInt("savegame.mod.scmm.click-fire-tool", 0)
		SetInt("savegame.mod.scmm.click-explode-tool", 0)
		SetInt("savegame.mod.scmm.click-delete-tool", 0)
		SetInt("savegame.mod.scmm.click-destroy-tool", 0)
		SetBool("savegame.mod.scmm.startedUsingMenu", true)
	end

	SetBool("isSettingKey-ingame-menu0", false)
	SetBool("isSettingKey-free-cam0", false)
	SetBool("isSettingKey-blast-away0", false)
	SetBool("isSettingKey-vehicle-boost0", false)
	SetBool("isSettingKey-player-boost0", false)
	SetBool("isSettingKey-click-fire0", false)
	SetBool("isSettingKey-click-explode0", false)
	SetBool("isSettingKey-click-delete0", false)
	SetBool("isSettingKey-click-destroy0", false)
	SetBool("isSettingKey-ray-cutter0", false)
	SetBool("isSettingKey-clear-debris0", false)
	SetBool("isSettingKey-flight0", false)
end

function draw()
	UiPush()
		UiTranslate(0, 0)
		UiAlign("left top")
		UiFont("regular.ttf", 26)
		UiText("The Text Button Contains Info About A Module")
		UiTranslate(0, 50)
		UiText("The + Button Contains Settings For A Module. Not All Have Settings")
		UiTranslate(0, 50)
		UiText("The On / Off Button Toggles The Module")
		UiTranslate(0, 50)
		UiFont("bold.ttf", 26)
		UiText("Turning off 'Ingame Menu' will NOT disable other cheats!")
	UiPop()
	UiPush()
		UiTranslate(UiCenter(), 50)
		UiAlign("center middle")
		UiFont("bold.ttf", 48)
		UiColor(1, 1, 1)
		UiText("SirCode's Mod Menu")
		UiFont("regular.ttf", 26)
		UiTranslate(240, 6)
		UiColor(1, 0.8, 0.5)
		UiText("v11")
		UiTranslate(-240, 50)
		UiColor(1, 1, 1)
		UiText("Contact Dominusnak on the Official Teardown Discord for help")
		UiTranslate(0, 50)
		UiText("This mod runs stable on 1.5.1, you are on "..GetString("game.version"))
		UiTranslate(0, 75)
		UiPush()
			UiTranslate(-55, 60)
			DrawCheatButtonSet("Ingame Menu", "ingame-menu", true)
			UiTranslate(-160, 60)
			DrawCheatButtonSet("Freeze Timer", "inf-timer", false)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Infinite Ammo", "inf-ammo", false)
			UiTranslate(-330, 60)
			DrawCheatButtonSet("Infinite Health", "inf-health", false)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Free-Camera", "free-cam", true)
			UiTranslate(-330, 60)
			DrawCheatButtonSet("Blast Away", "blast-away", true)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Debug Info", "debug-info", false)
			UiTranslate(-330, 60)
			DrawCheatButtonSet("Vehicle Boost", "vehicle-boost", true)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Player Boost", "player-boost", true)
			UiTranslate(-330, 60)
			DrawCheatButtonSet("Click Fire", "click-fire", true)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Click Explode", "click-explode", true)
			UiTranslate(-330, 60)
			DrawCheatButtonSet("Click Delete", "click-delete", true)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Click Destroy", "click-destroy", true)
			UiTranslate(-330, 60)
			DrawCheatButtonSet("Unlock Tools", "unlock-tools", false)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Ray Cutter", "ray-cutter", true)
			UiTranslate(-330, 60)
			DrawCheatButtonSet("Clear Debris", "clear-debris", true)
			UiTranslate(330, 0)
			DrawCheatButtonSet("Smooth Flight", "flight", true)
		UiPop()
	UiPop()
	UiPush()
		UiTranslate(UiCenter(), UiHeight() - 80)
		UiAlign("center middle")
		UiFont("regular.ttf", 26)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		UiColor(1, 1, 1)
		if UiTextButton("Close", 200, 40) then
			Menu()
			SetBool("level.scmm.descOpen", false)
			UiSound("Sounds/BlipHigher.wav")
		end
	UiPop()
	UiPush()
		if GetBool("level.scmm.descOpen") then
			UiModalBegin()
			UiTranslate(UiCenter(), UiMiddle())
			UiAlign("center middle")
			if InputDown("esc") then
				SetBool("level.scmm.descOpen", false)
			end
			if not UiIsMouseInRect(512, 512) and InputDown("lmb") then
				SetBool("level.scmm.descOpen", false)
			end
			UiBlur(1)
			UiColor(0.7, 0.7, 0.7, 0.1)
			UiRect(512, 512)
			UiFont("bold.ttf", 32)
			UiTranslate(0, -200)
			UiColor(1, 1, 1)
			UiText(GetString("level.scmm.curToolText").." Information")
			local curMod = GetString("level.scmm.curTool")
			if curMod == "ingame-menu" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("An Ingame Mod Menu")
			elseif curMod == "inf-timer" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Freeze / Stop Mission Timer")
			elseif curMod == "inf-ammo" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Unlimited Weapon Ammo")
			elseif curMod == "inf-health" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Unlimited Health / Never Die")
				UiTranslate(0, 50)
				UiText("Taking massive damage can still fake-kill you")
				UiTranslate(0, 50)
				UiText("(You will not teleport, screen will just darken)")
			elseif curMod == "free-cam" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Noclip Flight Mode / Freecam Hack")
				UiTranslate(0, 50)
				UiText("Currently A Little Buggy. Still A WIP Module")
			elseif curMod == "blast-away" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Blow Away Debris And Objects")
			elseif curMod == "debug-info" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Show Metrics And Debug Information")
			elseif curMod == "vehicle-boost" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Hold A Boost Key To Push Your Car In A Direction")
				UiTranslate(0, 50)
				UiText("Hold "..GetString("savegame.mod.scmm.vehicle-boost1").." + W/A/S/D To Boost Horizontally")
				UiTranslate(0, 50)
				UiText("Hold "..GetString("savegame.mod.scmm.vehicle-boost0").." + Space/Shift To Boost Vertically")
			elseif curMod == "player-boost" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Hold A Boost Key To Push Your Player In A Direction")
				UiTranslate(0, 50)
				UiText("Hold "..GetString("savegame.mod.scmm.player-boost1").." + W/A/S/D To Boost Horizontally")
				UiTranslate(0, 50)
				UiText("Hold "..GetString("savegame.mod.scmm.player-boost0").." + Space/Shift To Boost Vertically")
			elseif curMod == "click-fire" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Place Fire At Mouse Cursor")
				UiTranslate(0, 50)
				UiText("Only Works On Flammable Objects")
			elseif curMod == "click-explode" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Explode Region At Mouse Cursor")
			elseif curMod == "click-delete" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Delete Object Youre Looking At")
			elseif curMod == "click-destroy" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Exploit To Place Larger Explosions At Cursor")
				UiTranslate(0, 50)
				UiText("Only Really Works On Small / Dynamic Objects")
				UiTranslate(0, 50)
				UiText("(Click Explode On Steroids)")
			elseif curMod == "unlock-tools" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Lets You Use Any Tool (Doesnt Edit Savegame)")
			elseif curMod == "ray-cutter" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Cut Holes In The Direction Youre Facing")
			elseif curMod == "clear-debris" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Delete All Nearby Moving / Dynamic Objects In Radius")
			elseif curMod == "flight" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Minecraft-Like Flight Mode, Allows Usage Of Tools While Flying")
			end
			UiModalEnd()
		end
	UiPop()
	UiPush()
		if GetBool("level.scmm.settingsOpen") then
			UiModalBegin()
			UiTranslate(UiCenter(), UiMiddle())
			UiAlign("center middle")
			if InputDown("esc") then
				SetBool("level.scmm.settingsOpen", false)
			end
			if not UiIsMouseInRect(512, 512) and InputDown("lmb") then
				SetBool("level.scmm.settingsOpen", false)
			end
			UiBlur(1)
			UiColor(0.7, 0.7, 0.7, 0.1)
			UiRect(512, 512)
			UiFont("bold.ttf", 32)
			UiTranslate(0, -200)
			UiColor(1, 1, 1)
			UiText(GetString("level.scmm.curToolText").." Settings")
			local curMod = GetString("level.scmm.curTool")
			if curMod == "ingame-menu" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Toggle Menu")
				UiTranslate(0, 50)
				DrawKeybindSet("ingame-menu", "0")
			elseif curMod == "free-cam" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Activate Free-cam")
				UiTranslate(0, 50)
				DrawKeybindSet("free-cam", "0")
				UiTranslate(0, 75)
				UiText("Free-cam Movespeed")
				UiTranslate(0, 50)
				DrawIncDecSet("free-cam-velocity", 0.1, 0, 2.0)
			elseif curMod == "blast-away" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Use Blast Away")
				UiTranslate(0, 50)
				DrawKeybindSet("blast-away", "0")
				UiTranslate(0, 75)
				UiText("Blast Radius")
				UiTranslate(0, 50)
				DrawIncDecSet("blast-away-radius", 10, 0, 100)
			elseif curMod == "vehicle-boost" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Forward / Reverse Boost")
				UiTranslate(0, 50)
				DrawKeybindSet("vehicle-boost", "1")
				UiTranslate(0, 75)
				UiText("Upward / Downward Boost")
				UiTranslate(0, 50)
				DrawKeybindSet("vehicle-boost", "0")
				UiTranslate(0, 75)
				UiText("Boost Velocity")
				UiTranslate(0, 50)
				DrawIncDecSet("vehicle-boost-velocity", 0.1, 0, 4.0)
			elseif curMod == "player-boost" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Forward / Reverse Boost")
				UiTranslate(0, 50)
				DrawKeybindSet("player-boost", "1")
				UiTranslate(0, 75)
				UiText("Upward / Downward Boost")
				UiTranslate(0, 50)
				DrawKeybindSet("player-boost", "0")
				UiTranslate(0, 75)
				UiText("Boost Velocity")
				UiTranslate(0, 50)
				DrawIncDecSet("player-boost-velocity", 0.1, 0, 4.0)
			elseif curMod == "click-fire" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Click Fire Tool")
				UiTranslate(0, 50)
				DrawToolSelector("click-fire-tool")
			elseif curMod == "click-explode" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Click Explode Tool")
				UiTranslate(0, 50)
				DrawToolSelector("click-explode-tool")
				UiTranslate(0, 75)
				UiText("Explosion Power")
				UiTranslate(0, 50)
				DrawIncDecSet("click-explode-power", 0.1, 0.5, 4.0)
			elseif curMod == "click-delete" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Click Delete Tool")
				UiTranslate(0, 50)
				DrawToolSelector("click-delete-tool")
			elseif curMod == "click-destroy" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Click Destroy Tool")
				UiTranslate(0, 50)
				DrawToolSelector("click-destroy-tool")
				UiTranslate(0, 75)
				UiText("Explosion Power")
				UiTranslate(0, 50)
				DrawIncDecSet("click-destroy-power", 1, 5, 30)
			elseif curMod == "ray-cutter" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Use Ray Cutter")
				UiTranslate(0, 50)
				DrawKeybindSet("ray-cutter", "0")
				UiTranslate(0, 75)
				UiText("Cutter Radius")
				UiTranslate(0, 50)
				DrawIncDecSet("ray-cutter-radius", 0.1, 0, 4.0)
			elseif curMod == "clear-debris" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Use Clear Debris")
				UiTranslate(0, 50)
				DrawKeybindSet("clear-debris", "0")
				UiTranslate(0, 75)
				UiText("Deletion Radius")
				UiTranslate(0, 50)
				DrawIncDecSet("clear-debris-radius", 10, 0, 100)
			elseif curMod == "flight" then
				UiFont("regular.ttf", 26)
				UiTranslate(0, 75)
				UiText("Activate Flight")
				UiTranslate(0, 50)
				DrawKeybindSet("flight", "0")
				UiTranslate(0, 75)
				UiText("Flight Movespeed")
				UiTranslate(0, 50)
				DrawIncDecSet("free-cam-velocity", 0.1, 0, 2.0)
			end
			UiModalEnd()
		end
	UiPush()
end

