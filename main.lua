#include "game.lua"
#include "menu_api.lua"

local uidelay = 0.1
local playerTarget
local maxDist = 1000

function clickFlame()
	local cam = GetCameraTransform()
	local dir = TransformToParentVec(cam, Vec(0,0,-1))
	local hit, dist = QueryRaycast(cam.pos, dir, maxDist)
	if hit then
		local hitPos = VecAdd(cam.pos, VecScale(dir, dist))
		SpawnFire(hitPos)
	end
end

function clickExplode()
	local cam = GetCameraTransform()
	local dir = TransformToParentVec(cam, Vec(0,0,-1))
	local hit, dist = QueryRaycast(cam.pos, dir, maxDist)
	if hit then
		local hitPos = VecAdd(cam.pos, VecScale(dir, dist))
		Explosion(hitPos, GetFloat(modid.."click-explode-power"))
	end
end

function clickDestroy()
	local cam = GetCameraTransform()
	local dir = TransformToParentVec(cam, Vec(0,0,-1))
	local hit, dist, n, shape = QueryRaycast(cam.pos, dir, maxDist)
	if hit then
		local hitPos = VecAdd(cam.pos, VecScale(dir, dist))
		SetTag(shape, "explosive", GetFloat(modid.."click-destroy-power"))
		MakeHole(hitPos, 0.1, 0.1, 0.1)
	end
end

function init()
	if GetBool(modid.."startedUsingMenu") == false then
		SetBool(modid.."ingame-menu", true)
		SetFloat(modid.."player-boost-velocity", 0.3)
		SetFloat(modid.."vehicle-boost-velocity", 0.3)
		SetFloat(modid.."free-cam-velocity", 1.0)
		SetFloat(modid.."click-explode-power", 2)
		SetFloat(modid.."click-destroy-power", 5)
		SetFloat(modid.."blast-away-radius", 10)
		SetFloat(modid.."clear-debris-radius", 10)
		SetFloat(modid.."ray-cutter-radius", 0.2)
		SetBool(modid.."startedUsingMenu", true)
	end

	-- Unlock All Items Hack
	if GetBool(modid.."unlock-tools") then
		for id, tool in pairs(gTools) do
			SetBool("game.tool."..id..".enabled", true)
			SetBool("savegame.tool."..id..".enabled", true)
			for j=1, #tool.upgrades do
				local prop = tool.upgrades[j].id
				local value = tool.upgrades[j].max
				SetInt("game.tool."..id.."."..prop, value)
				SetInt("savegame.tool."..id.."."..prop, value)
			end
		end
	end
	-- Unlock All Items Hack End

	SetBool(tempid.."menu-open", false)
	tp = false
	mx = 0
	my = 0
	ingameMenuAlpha = 0
	aaFlightRate = 0.166667
	aaFlightCurrentX = 0
	aaFlightCurrentY = 0
	aaFlightCurrentZ = 0
	closeMenu = false
	SetInt(modid.."flightSpeed", 10)
end

function tick(dt)
	if GetBool(tempid.."menu-open") then
		SetBool("game.disablepause", true)
		SetBool("game.disablemap", true)
	end

	-- Infinite Mission Time
	if GetBool(modid.."inf-timer") then
		if GetBool("level.alarm") then
			SetFloat("level.alarmtimer", 60)		
		end
	end
	-- Infinite Mission Time End

	-- Infinite Ammo
	if GetBool(modid.."inf-ammo") then
		tool = GetString("game.player.tool")
		SetInt("game.tool."..tool..".ammo", 999)
		SetString("game.tool.tool.ammo.display", "")
	end
	-- Infinite Ammo End

	-- Infinite Health
	if GetBool(modid.."inf-health", true) then
		if GetPlayerHealth() then
			SetPlayerHealth(1)
		end
	end
	-- Infinite Health End

	-- Player Boost
	if GetBool(modid.."player-boost") then
		if GetPlayerVehicle() == 0 then
			local t = GetPlayerTransform()
			local d = TransformToParentVec(t, Vec(0, 0, 0))
			local vel = GetPlayerVelocity()
			local velocity = GetFloat(modid.."player-boost-velocity")
			if InputDown(GetString(modid.."player-boost.key")) then
				if InputDown("space") then
					d = TransformToParentVec(t, Vec(0, velocity, 0))
					vel = VecAdd(vel, d)
				elseif InputDown("shift") then
					d = TransformToParentVec(t, Vec(0, -velocity, 0))
					vel = VecAdd(vel, d)
				end
			elseif InputDown(GetString(modid.."player-boost1")) then
				if InputDown("w") then
					d = TransformToParentVec(t, Vec(0, 0, -velocity))
					vel = VecAdd(vel, d)
				elseif InputDown("s") then
					d = TransformToParentVec(t, Vec(0, 0, velocity))
					vel = VecAdd(vel, d)
				elseif InputDown("a") then
					d = TransformToParentVec(t, Vec(-velocity, 0, 0))
					vel = VecAdd(vel, d)
				elseif InputDown("d") then
					d = TransformToParentVec(t, Vec(velocity, 0, 0))
					vel = VecAdd(vel, d)
				end
			end
			SetPlayerVelocity(vel)
		end
	end
	-- Player Boost End

	-- Vehicle Boost Hack
	if GetBool(modid.."vehicle-boost") then
		local v = GetPlayerVehicle()
		if v > 0 then
			local t = GetVehicleTransform(v)
			local d = TransformToParentVec(t, Vec(0, 0, 0))
			local b = GetVehicleBody(v)	
			local vel = GetBodyVelocity(b)
			local velocity = GetFloat(modid.."vehicle-boost-velocity")
			if InputDown(GetString(modid.."vehicle-boost.key")) then
				if InputDown("space") then
					d = TransformToParentVec(t, Vec(0, velocity, 0))
					vel = VecAdd(vel, d)
				elseif InputDown("shift") then
					d = TransformToParentVec(t, Vec(0, -velocity, 0))
					vel = VecAdd(vel, d)
				end
			elseif InputDown(GetString(modid.."vehicle-boost1")) then
				if InputDown("up") then
					d = TransformToParentVec(t, Vec(0, 0, -velocity))
					vel = VecAdd(vel, d)
				elseif InputDown("down") then
					d = TransformToParentVec(t, Vec(0, 0, velocity))
					vel = VecAdd(vel, d)
				end
			end
			SetBodyVelocity(b, vel)
		end
	end
	-- Vehicle Boost Hack End

	-- Blow Away Debris Hack
	if GetBool(modid.."blast-away") then
		if GetPlayerVehicle() == 0 then
			local strength = 20
			local maxMass = 100000
			local maxBlowDist = GetFloat(modid.."blast-away-radius")
			if InputDown(GetString(modid.."blast-away.key")) and GetBool("game.player.canusetool") then
				local t = GetCameraTransform()
				local c = TransformToParentPoint(t, Vec(0, 0, -maxBlowDist/2))
				local mi = VecAdd(c, Vec(-maxBlowDist/2, -maxBlowDist/2, -maxBlowDist/2))
				local ma = VecAdd(c, Vec(maxBlowDist/2, maxBlowDist/2, maxBlowDist/2))
				QueryRequire("physical dynamic")
				local bodies = QueryAabbBodies(mi, ma)
				for i=1,#bodies do
					local b = bodies[i]
					local bmi, bma = GetBodyBounds(b)
					local bc = VecLerp(bmi, bma, 0.5)
					local dir = VecSub(bc, t.pos)
					local dist = VecLength(dir)
					dir = VecScale(dir, 1.0/dist)
					local mass = GetBodyMass(b)
					if dist < maxBlowDist and mass < maxMass then
						dir[2] = 0.5
						dir = VecNormalize(dir)
						local massScale = 1 - math.min(mass/maxMass, 1.0)
						local distScale = 1 - math.min(dist/maxBlowDist, 1.0)
						local add = VecScale(dir, strength * massScale * distScale)
						local vel = GetBodyVelocity(b)
						vel = VecAdd(vel, add)
						SetBodyVelocity(b, vel)
					end
				end
			end
		end
	end
	-- Blow Away Debris Hack End

	-- Click Fire Hack
	if GetBool(modid.."click-fire") then
		local toolId = toolIds[GetInt(modid.."click-fire-tool")]
		if GetString("game.player.tool") == toolId or GetString("game.player.tool") == "aahandflame" then
			if GetBool("game.player.canusetool") and tp == false and InputDown("lmb") then
				for i=1, 50 do
					clickFlame()
				end
			end
		end
	end
	-- Click Fire Hack End

	-- Click Explode Hack
	if GetBool(modid.."click-explode") then
		local toolId = toolIds[GetInt(modid.."click-explode-tool")]
		if GetBool(modid.."explPaint") then
			if GetString("game.player.tool") == toolId then
				if GetBool("game.player.canusetool") and tp == false and InputDown("lmb") then
					clickExplode()
				end
			end
		else
			if GetString("game.player.tool") == toolId then
				if GetBool("game.player.canusetool") and tp == false and InputPressed("lmb") then
					clickExplode()
				end
			end
		end
	end
	-- Click Explode Hack Ewd

	-- Click Destroy Hack
	if GetBool(modid.."click-destroy") then
		local toolId = toolIds[GetInt(modid.."click-destroy-tool")]
		if GetString("game.player.tool") == toolId or GetString("game.player.tool") == "aahanddestroy" then
			if GetBool("game.player.canusetool") and tp == false and InputPressed("lmb") then
				clickDestroy()
			end
		end
	end
	-- Click Destroy Hack End

	-- Click Delete Hack
	if GetBool(modid.."click-delete") then
		local toolId = toolIds[GetInt(modid.."click-delete-tool")]
		if GetString("game.player.tool") == toolId or GetString("game.player.tool") == "aahanddelete" then
			if GetBool("game.player.canusetool") and tp == false then
				local t = GetCameraTransform()
				local fwd = TransformToParentVec(t, Vec(0, 0, -1))
				local maxDist = 2000
				local hit, dist, normal, shape = QueryRaycast(t.pos, fwd, maxDist)
				if hit then
					DrawShapeOutline(shape, 1, 0.1, 0.1, 1)
					if InputPressed("lmb") then
						Delete(shape)
					end
				end
			end
		end
	end
	-- Click Delete Hack End

	-- Debug Info
	if GetBool(modid.."debug-info") then
		local t = GetCameraTransform()
		local pt = GetPlayerTransform()
		local dir = TransformToParentVec(t, {0, 0, -1})
		local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 100)
		DebugWatch("Player Position", round(pt.pos[1], 1)..", "..round(pt.pos[2], 1)..", "..round(pt.pos[3], 1))
		DebugWatch("Hit", hit)
		if hit then
			local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
			DebugLine(VecAdd(t.pos, {0, -1, 0}), hitPoint, 0, 1, 0)
			DebugCross(hitPoint)
			DrawShapeOutline(shape, 1)
			DebugWatch("Point Position", round(hitPoint[1], 1)..", "..round(hitPoint[2], 1)..", "..round(hitPoint[3], 1))
			DebugWatch("Shape Handle", shape)
		end
		DebugWatch("Current Tool ID", GetString("game.player.tool"))
	end
	-- Debug Info End

	-- Smooth Flight
	if GetBool(modid.."flight") and tp == false then
		if InputPressed(GetString(modid.."flight.key")) then
			SetBool(tempid.."isSmoothFlying", not GetBool(tempid.."isSmoothFlying"))
		end
		if GetBool(tempid.."isSmoothFlying") then
			local t = GetPlayerTransform()
			local v = GetPlayerVelocity()
			local fs = GetInt(modid.."flightSpeed")
			local aaXDir = 0
			local aaYDir = 0
			local aaZDir = 0
			if InputDown("right") then aaXDir = aaXDir + 1 end
			if InputDown("left") then aaXDir = aaXDir - 1 end
			if InputDown("space") then aaYDir = aaYDir + 1 end
			if InputDown("shift") then aaYDir = aaYDir - 1 end
			if InputDown("down") then aaZDir = aaZDir + 1 end
			if InputDown("up") then aaZDir = aaZDir - 1 end
			SetPlayerVelocity(TransformToParentVec(t, Vec(0 + (fs * aaXDir), aaFlightRate + (fs * aaYDir), 0 + (fs * aaZDir))))
		end
	end
	-- Smooth Flight End

	-- Free Camera
	if GetBool(modid.."free-cam") and GetBool(tempid.."isSmoothFlying") == false then
		ptn = GetCameraTransform()
		if tp then
			mx = mx - InputValue("mousedx") / 17.5
			my = my - InputValue("mousedy") / 17.5
			mouserot = QuatEuler(my, mx, 0)
			if InputDown("w") then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, 0, -GetFloat(modid.."free-cam-velocity")))), 0.2)), mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown("s") then
				ptn = Transform(VecSub(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, 0, -GetFloat(modid.."free-cam-velocity")))), 0.2)), mouserot)
				SetCameraTransform(ptn)
			end
			if not(InputDown("w") or InputDown("s")) or InputDown("a") or InputDown("d") then
				ptn = Transform(GetCameraTransform().pos, mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown("a") then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(-GetFloat(modid.."free-cam-velocity"), 0, 0))), 0.13)), mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown("d") then
				ptn = Transform(VecSub(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(-GetFloat(modid.."free-cam-velocity"), 0, 0))), 0.13)), mouserot)
				SetCameraTransform(ptn) 
			end
			if InputDown("space") then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, GetFloat(modid.."free-cam-velocity"), 0))), 0.16)), mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown("shift") then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, -GetFloat(modid.."free-cam-velocity"), 0))), 0.16)), mouserot)
				SetCameraTransform(ptn)
			end
			SetPlayerTransform(GetPlayerTransform())
		end
		if InputPressed(GetString(modid.."free-cam.key")) then
			if tp then
				tp = false
				SetPlayerTransform(Transform(VecSub((ptn.pos), Vec(0, 1.8, 0)), ptn.rot))
			else
				tp = true
			end
		end
	end
	-- Static Fly Hack End

	-- Line Cutter
	if GetBool(modid.."ray-cutter") then
		if InputDown(GetString(modid.."ray-cutter.key")) then
			local t = GetCameraTransform()
			local dir = TransformToParentVec(t, {0, 0, -1})
			local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 1000)
			local radius = GetFloat(modid.."ray-cutter-radius")
			if hit then
				local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
				MakeHole(hitPoint, radius, radius, radius)
			end
		end
	end
	-- Line Cutter End

	-- Clear Debris
	if GetBool(modid.."clear-debris") then
		if InputDown(GetString(modid.."clear-debris.key")) then
			local maxMass = 100000
			local maxBlowDist = GetFloat(modid.."clear-debris-radius")
			local t = GetCameraTransform()
			local c = TransformToParentPoint(t, Vec(0, 0, -maxBlowDist/2))
			local mi = VecAdd(c, Vec(-maxBlowDist/2, -maxBlowDist/2, -maxBlowDist/2))
			local ma = VecAdd(c, Vec(maxBlowDist/2, maxBlowDist/2, maxBlowDist/2))
			QueryRequire("physical dynamic")
			local shapes = QueryAabbShapes(mi, ma)
			for i=1,#shapes do
				local s = shapes[i]
				local bmi, bma = GetShapeBounds(s)
				local bc = VecLerp(bmi, bma, 0.5)
				local dir = VecSub(bc, t.pos)
				local dist = VecLength(dir)
				if dist < maxBlowDist then
					DrawShapeOutline(shape, 1)
					Delete(s)
				end
			end
		end
	end
	-- Clear Debris End
end

function draw()
	if ingameMenuAlpha == 0 and closeMenu and GetBool(tempid.."menu-open") then
		SetBool(tempid.."menu-open", false)
		closeMenu = false
	end

	if ingameMenuAlpha == 1 then
		UiModalBegin()
		SetBool("game.disablepause", true)
		SetBool("game.disablemap", true)
	end

	if InputPressed(GetString(modid.."ingame-menu.key")) then
		if GetBool(tempid.."menu-open") then
			closeMenu = true
			SetValue(tempid.."ingameMenuAlpha", 0, "easeout", uidelay)
		else
			SetBool(tempid.."menu-open", true)
			SetValue(tempid.."ingameMenuAlpha", 1, "easeout", uidelay)
		end
	end

	UiFont("regular.ttf", 15)
	UiAlign("center middle")
	if GetBool(modid.."ingame-menu") then
		UiPush()
			UiColor(1, 1, 1, ingameMenuAlpha)
			UiButtonImageBox("MOD/Images/box-dark.png", 6, 6)
			UiFont("bold.ttf", 15)
			if GetBool(tempid.."menu-open") then
				if ingameMenuAlpha == 1 then
					UiMakeInteractive()
				end
				UiTranslate(UiCenter(), UiMiddle())
				UiAlign("center middle")
				UiBlur(ingameMenuAlpha)
				UiColor(0, 0, 0, 0.7 * ingameMenuAlpha)
				UiRect(800, 725)
				if (not UiIsMouseInRect(800, 725) and (InputPressed("lmb") or InputPressed("rmb"))) or InputPressed("esc") then
					if not GetBool(tempid.."settingsOpen") and not GetBool(tempid.."descOpen") then
						closeMenu = true
						SetValue(tempid.."ingameMenuAlpha", 0, "easeout", uidelay)
					end
				end
				UiColor(1, 1, 1, ingameMenuAlpha)
				UiTranslate(0, -325)
				UiAlign("center middle")
				UiFont("bold.ttf", 35)
				UiTranslate(0, 40)
				UiText("Control Panel")
				UiFont("regular.ttf", 26)
				UiTranslate(0, 65)
				UiTranslate(-55, 0)
				UiButtonImageBox("MOD/Images/box-light-left.png", 6, 6, 1, 1, 1, ingameMenuAlpha)
				if UiTextButton("Ingame Menu", 200, 40) then
					SetBool(tempid.."descOpen", true)
					SetString(tempid.."curTool", "ingame-menu")
					SetString(tempid.."curToolText", "Ingame Menu")
				end
				UiTranslate(125, 0)
				UiButtonImageBox("MOD/Images/box-light-mid.png", 6, 6, 1, 1, 1, ingameMenuAlpha)
				UiColor(1, 0.8, 0, ingameMenuAlpha)
				if UiTextButton("+", 40, 40) then
					SetBool(tempid.."settingsOpen", true)
					SetString(tempid.."curTool", "ingame-menu")
					SetString(tempid.."curToolText", "Ingame Menu")
				end
				UiTranslate(55, 0)
				UiColor(1, 1, 1, ingameMenuAlpha)
				UiButtonImageBox("MOD/Images/box-light-right.png", 6, 6, 1, 1, 1, ingameMenuAlpha)
				if GetBool(modid.."ingame-menu") then
					UiColor(0.6, 0.6, 0.6, ingameMenuAlpha)
					if UiTextButton("ON", 60, 40) then
						UiSound("Sounds/BlipLower.wav")
					end
				end
				UiTranslate(-180, 0)
				UiColor(1, 1, 1, ingameMenuAlpha)
				UiButtonImageBox("MOD/Images/box-light.png", 6, 6, 1, 1, 1, ingameMenuAlpha)
				UiTranslate(-160, 60)
				DrawCheatButtonSet("Freeze Timer", "inf-timer", false, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Infinite Ammo", "inf-ammo", false, ingameMenuAlpha)
				UiTranslate(-330, 60)
				DrawCheatButtonSet("Infinite Health", "inf-health", false, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Free Camera", "free-cam", true, ingameMenuAlpha)
				UiTranslate(-330, 60)
				DrawCheatButtonSet("Blast Away", "blast-away", true, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Debug Info", "debug-info", false, ingameMenuAlpha)
				UiTranslate(-330, 60)
				DrawCheatButtonSet("Vehicle Boost", "vehicle-boost", true, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Player Boost", "player-boost", true, ingameMenuAlpha)
				UiTranslate(-330, 60)
				DrawCheatButtonSet("Click Fire", "click-fire", true, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Click Explode", "click-explode", true, ingameMenuAlpha)
				UiTranslate(-330, 60)
				DrawCheatButtonSet("Click Delete", "click-delete", true, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Click Destroy", "click-destroy", true, ingameMenuAlpha)
				UiTranslate(-330, 60)
				DrawCheatButtonSet("Unlock Tools", "unlock-tools", false, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Ray Cutter", "ray-cutter", true, ingameMenuAlpha)
				UiTranslate(-330, 60)
				DrawCheatButtonSet("Clear Debris", "clear-debris", true, ingameMenuAlpha)
				UiTranslate(330, 0)
				DrawCheatButtonSet("Smooth Flight", "flight", true, ingameMenuAlpha)
			end
		UiPop()
		UiPush()
			UiColor(1, 1, 1, ingameMenuAlpha)
			if GetBool(tempid.."descOpen") then
				UiModalBegin()
				UiTranslate(UiCenter(), UiMiddle())
				UiAlign("center middle")
				if InputDown("esc") then
					SetBool(tempid.."descOpen", false)
				end
				if not UiIsMouseInRect(512, 512) and InputDown("lmb") then
					SetBool(tempid.."descOpen", false)
				end
				UiBlur(1)
				UiColor(0.7, 0.7, 0.7, 0.1)
				UiRect(512, 512)
				UiFont("bold.ttf", 32)
				UiTranslate(0, -200)
				UiColor(1, 1, 1)
				UiText(GetString(tempid.."curToolText").." Information")
				local curMod = GetString(tempid.."curTool")
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
					UiText("Sometimes If You Take Massive Damage Very Quickly..")
					UiTranslate(0, 50)
					UiText("You Can Still Die")
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
					UiText("Hold "..GetString("savegame.mod.vehicle-boost1").." + W/A/S/D To Boost Horizontally")
					UiTranslate(0, 50)
					UiText("Hold "..GetString("savegame.mod.vehicle-boost.key").." + Space/Shift To Boost Vertically")
				elseif curMod == "player-boost" then
					UiFont("regular.ttf", 26)
					UiTranslate(0, 75)
					UiText("Hold A Boost Key To Push Your Player In A Direction")
					UiTranslate(0, 50)
					UiText("Hold "..GetString("savegame.mod.player-boost1").." + W/A/S/D To Boost Horizontally")
					UiTranslate(0, 50)
					UiText("Hold "..GetString("savegame.mod.player-boost.key").." + Space/Shift To Boost Vertically")
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
			UiColor(1, 1, 1, ingameMenuAlpha)
			if GetBool(tempid.."settingsOpen")  then
				UiModalBegin()
				UiTranslate(UiCenter(), UiMiddle())
				UiAlign("center middle")
				if InputDown("esc") then
					SetBool(tempid.."settingsOpen", false)
				end
				if not UiIsMouseInRect(512, 512) and InputDown("lmb") then
					SetBool(tempid.."settingsOpen", false)
				end
				UiBlur(1)
				UiColor(0.7, 0.7, 0.7, 0.1)
				UiRect(512, 512)
				UiFont("bold.ttf", 32)
				UiTranslate(0, -200)
				UiColor(1, 1, 1)
				UiText(GetString(tempid.."curToolText").." Settings")
				local curMod = GetString(tempid.."curTool")
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
		UiPop()
	end
	if ingameMenuAlpha == 1 then
		UiModalEnd()
	end
end
