#include "game.lua"
#include "menu_api.lua"

local uidelay = 0.1
local playerTarget
local maxDist = 1000
local hasframed = 0
local frameWidth, frameHeight
currentMenuOpacity = 0
currentDebugOpacity = 0
currentDebugMessage = ''
local needsToClose = false
local menuOpen = false
local flight = false
local godmode_needs_off = false
local freecam_needs_off = false
local grav_needs_off = false
local starting_grav = Vec(0, -10, 0)

local useTimer = 0

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
		Explosion(hitPos, GetFloat(modid..'explosion-power'))
	end
end

function clickDestroy()
	local cam = GetCameraTransform()
	local dir = TransformToParentVec(cam, Vec(0,0,-1))
	local hit, dist, n, shape = QueryRaycast(cam.pos, dir, maxDist)
	if hit then
		local hitPos = VecAdd(cam.pos, VecScale(dir, dist))
		SetTag(shape, 'explosive', GetFloat(modid..'click-destroy-power'))
		MakeHole(hitPos, 0.1, 0.1, 0.1)
	end
end

function init()
	validateDefaultOptions()

	-- Unlock All Items Hack
	if GetBool(modid..'unlock-tools') then
		for id, tool in pairs(gTools) do
			SetBool('game.tool.'..id..'.enabled', true)
			SetBool('savegame.tool.'..id..'.enabled', true)
			for j=1, #tool.upgrades do
				local prop = tool.upgrades[j].id
				local value = tool.upgrades[j].max
				SetInt('game.tool.'..id..'.'..prop, value)
				SetInt('savegame.tool.'..id..'.'..prop, value)
			end
		end
	end

	menuOpen = false
	starting_grav = GetGravity()
end

function tick(dt)
	if useTimer < 10 then
		useTimer = useTimer + (10 * dt)
	end

	if menuOpen then
		SetBool('game.disablepause', true)
		SetBool('game.disablemap', true)
	end

	-- Infinite Mission Time
	if GetBool(modid..'inf-timer') then
		if GetBool('level.alarm') then
			SetFloat('level.alarmtimer', 60)
			SetBool('level.alarm', false)
		end
	end

	-- Infinite Ammo
	if GetBool(modid..'inf-ammo') then
		tool = GetString('game.player.tool')
		SetInt('game.tool.'..tool..'.ammo', 999)
		SetString('game.tool.'..tool..'.ammo.display', '')
	end

	-- Infinite Health
	if GetBool(modid..'inf-health') then
		SetPlayerParam('GodMode', true)
		if GetPlayerHealth() then
			SetPlayerRegenerationState(true)
			SetPlayerHealth(1) -- Backup, incase a mod directly damages the player
		end
		godmode_needs_off = false
	else
		if godmode_needs_off == false then
			godmode_needs_off = true
			SetPlayerParam('GodMode', false)
		end
	end

	if menuOpen then
		return
	end

	-- Clear Fires
	if GetBool(modid..'clear-fires') then
		if InputPressed(getkey('clear-fires')) then	
			RemoveAabbFires(Vec(-32768, -32768, -32768), Vec(32768, 32768, 32768))
		end
	end

	-- Player Boost
	if GetBool(modid..'player-boost') then
		if GetPlayerVehicle() == 0 then
			local t = GetPlayerTransform()
			local d = TransformToParentVec(t, Vec(0, 0, 0))
			local vel = GetPlayerVelocity()
			local velocity = GetFloat(modid..'player-boost-velocity')
			local usingDualBinds = GetBool(modid..'extraboostbinds')
			if InputDown(getkey('player-boost')) or usingDualBinds then
				if InputDown(getkey('player-boost-ver')) or not usingDualBinds then
					if InputDown('space') then
						d = TransformToParentVec(t, Vec(0, velocity, 0))
						vel = VecAdd(vel, d)
					elseif InputDown('shift') then
						d = TransformToParentVec(t, Vec(0, -velocity, 0))
						vel = VecAdd(vel, d)
					end
				end
				if InputDown(getkey('player-boost-hor')) or not usingDualBinds then
					if InputDown('up') then
						d = TransformToParentVec(t, Vec(0, 0, -velocity))
						vel = VecAdd(vel, d)
					elseif InputDown('down') then
						d = TransformToParentVec(t, Vec(0, 0, velocity))
						vel = VecAdd(vel, d)
					elseif InputDown('left') then
						d = TransformToParentVec(t, Vec(-velocity, 0, 0))
						vel = VecAdd(vel, d)
					elseif InputDown('right') then
						d = TransformToParentVec(t, Vec(velocity, 0, 0))
						vel = VecAdd(vel, d)
					end
				end
			end
			SetPlayerVelocity(vel)
		end
	end

	-- Vehicle Boost Hack
	if GetBool(modid..'vehicle-boost') then
		local v = GetPlayerVehicle()
		if v > 0 then
			local t = GetVehicleTransform(v)
			local d = TransformToParentVec(t, Vec(0, 0, 0))
			local b = GetVehicleBody(v)	
			local vel = GetBodyVelocity(b)
			local velocity = GetFloat(modid..'vehicle-boost-velocity')
			local usingDualBinds = GetBool(modid..'extraboostbinds')
			if InputDown(getkey('vehicle-boost')) or usingDualBinds then
				if InputDown(getkey('vehicle-boost-ver')) or not usingDualBinds then
					if InputDown('space') then
						d = TransformToParentVec(t, Vec(0, velocity, 0))
						vel = VecAdd(vel, d)
					elseif InputDown('shift') then
						d = TransformToParentVec(t, Vec(0, -velocity, 0))
						vel = VecAdd(vel, d)
					end
				end
				if InputDown(getkey('vehicle-boost-hor')) or not usingDualBinds then
					if InputDown('up') then
						d = TransformToParentVec(t, Vec(0, 0, -velocity))
						vel = VecAdd(vel, d)
					elseif InputDown('down') then
						d = TransformToParentVec(t, Vec(0, 0, velocity))
						vel = VecAdd(vel, d)
					end
				end
			end
			SetBodyVelocity(b, vel)
		end
	end

	-- Blow Away Debris Hack
	if GetBool(modid..'blast-away') then
		if GetPlayerVehicle() == 0 then
			local strength = 20
			local maxMass = 100000
			local maxBlowDist = GetFloat(modid..'blast-radius')
			if InputDown(GetString(modid..'blast-away.key')) and GetBool('game.player.canusetool') then
				local debug = false
				local t = GetCameraTransform()
				local c = TransformToParentPoint(t, Vec(0, 0, -maxBlowDist/2))
				local mi = VecAdd(c, Vec(-maxBlowDist/2, -maxBlowDist/2, -maxBlowDist/2))
				local ma = VecAdd(c, Vec(maxBlowDist/2, maxBlowDist/2, maxBlowDist/2))
				QueryRequire('physical dynamic')
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
						local shapes = GetBodyShapes(b)
						for i=1,#shapes do
							DrawShapeOutline(shapes[i], 1, 0.1, 0.1, 0.5)
						end
						if debug then
						else
							SetBodyVelocity(b, vel)
						end
					end
				end
			end
		end
	end

	
	-- Clear Debris
	if GetBool(modid..'delete-debris') then
		if InputDown(GetString(modid..'delete-debris.key')) then
			local maxMass = 100000
			local maxBlowDist = GetFloat(modid..'delete-radius')
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


	-- Click Fire Hack
	if GetBool(modid..'click-fire') then
		if GetString('game.player.tool') == GetString(modid..'click-fire.tool') then
			if GetBool('game.player.canusetool') and InputDown('usetool') then
				for i=1, 20 do
					clickFlame()
				end
			end
		end
	end

	-- Click Explode Hack
	if GetBool(modid..'click-explode') then
		if GetString('game.player.tool') == GetString(modid..'click-explode.tool') then
			if GetBool('game.player.canusetool') and InputDown('usetool') and (useTimer > 2) then
				useTimer = 0
				clickExplode()
			end
		end
	end

	-- Click Delete Hack
	if GetBool(modid..'click-delete') then
		if GetString('game.player.tool') == GetString(modid..'click-delete.tool') then
			if GetBool('game.player.canusetool') then
				local t = GetCameraTransform()
				local fwd = TransformToParentVec(t, Vec(0, 0, -1))
				local maxDist = 2000
				local hit, dist, normal, shape = QueryRaycast(t.pos, fwd, maxDist)
				if hit then
					DrawShapeOutline(shape, 1, 0.1, 0.1, 1)
					if InputPressed('usetool') then
						Delete(shape)
					end
				end
			end
		end
	end

	-- Click Cut Hack
	if GetBool(modid..'click-cutter') then
		if GetString('game.player.tool') == GetString(modid..'click-cutter.tool') then
			if GetBool('game.player.canusetool') and InputDown('usetool') and (useTimer > 2) then
				useTimer = 0
				local t = GetCameraTransform()
				local dir = TransformToParentVec(t, {0, 0, -1})
				local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 1000)
				local radius = GetFloat(modid..'cutting-range')
				if hit then
					local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
					MakeHole(hitPoint, radius, radius, radius)
				end
			end
		end
	end

	-- Debug Info
	-- if GetBool(modid..'debug-info') then
	-- 	local t = GetCameraTransform()
	-- 	local pt = GetPlayerTransform()
	-- 	local dir = TransformToParentVec(t, {0, 0, -1})
	-- 	local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 100)
	-- 	DebugWatch('Player Position', round(pt.pos[1], 1)..', '..round(pt.pos[2], 1)..', '..round(pt.pos[3], 1))
	-- 	DebugWatch('Hit', hit)
	-- 	if hit then
	-- 		local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
	-- 		DebugLine(VecAdd(t.pos, {0, -1, 0}), hitPoint, 0, 1, 0)
	-- 		DebugCross(hitPoint)
	-- 		DrawShapeOutline(shape, 1)
	-- 		DebugWatch('Point Position', round(hitPoint[1], 1)..', '..round(hitPoint[2], 1)..', '..round(hitPoint[3], 1))
	-- 		DebugWatch('Shape Handle', shape)
	-- 	end
	-- 	DebugWatch('Current Tool ID', GetString('game.player.tool'))
	-- end

	-- Flight Mod
	if GetBool(modid..'flight') and not GetPlayerParam('FlyMode') then
		if InputPressed(getkey('flight')) then
			flight = not flight
		end
		if flight then
			-- Courtesy of Thomasims.. Snippet barrowed from Precision Flight mod
			local Target = nil
            local pos = GetPlayerTransform().pos
            local vel = GetPlayerVelocity()
            if not Target or VecLength(vel) > 1 then
                Target = pos
            end
            local del = getDelta(dt, GetCameraTransform())
            if del then Target = VecAdd(Target, del) end
            SetPlayerVelocity(VecScale(VecSub(Target, pos), 100))
		end
	else
		flight = false
	end

	-- Freecam mod
	if GetBool(modid..'freecam') and not flight then
		if InputPressed(getkey('freecam')) then
			SetPlayerParam('FlyMode', not GetPlayerParam('FlyMode'))
		end
		freecam_needs_off = false
	else
		if freecam_needs_off == false then
			freecam_needs_off = true
			SetPlayerParam('FlyMode', false)
		end
	end

	-- Gravity mod
	if GetBool(modid..'override-gravity') then
		power = GetFloat(modid..'gravitation')
		SetGravity(Vec(0, power, 0))
		grav_needs_off = false
	else
		if grav_needs_off == false then
			grav_needs_off = true
			SetGravity(starting_grav)
		end
	end
end

-- UI
function draw()
	-- Keybind Setting
	if setting_bind then
		checkKeyAtFrame()
	end

	-- Defaults
	debug_opacity = debug_opacity - 0.01
	button_opacity = currentMenuOpacity

	-- Control setter
	if menuOpen then
		if not setting_bind then 
			UiModalBegin() -- Disable other inputs
		end
		UiMakeInteractive() -- Put focus on UI window
	end

	-- Toggle UI On and Off
	if InputPressed(GetString(modid..'menu-ingame.key')) then
		menuOpen = not menuOpen
		if menuOpen then
            UiSound(on_sound)
		else
            UiSound(off_sound)
		end
		InputClear()
	end

	if InputDown(GetString(modid..'menu-ingame.key')) then	
		InputClear()
	end

	-- Transitioner
	if menuOpen then
		if currentMenuOpacity < 1 then
			SetValue("currentMenuOpacity", 1, "linear", 0.1)
		end
	else
		if currentMenuOpacity > 0.01 then
			needsToClose = true
			SetValue("currentMenuOpacity", 0, "linear", 0.1)
		end
	end

	-- Extra closer
	if currentMenuOpacity <= 0.01 then
		needsToClose = false
	end

	-- Draw Menu
	if menuOpen or needsToClose then
		if InputPressed('esc') then
			menuOpen = false
			if menuOpen then
				UiSound(on_sound)
			else
				UiSound(off_sound)
			end
		end

		-- Begin UI Layer
		UiPush()
		UiAlign('left top')
		UiTextShadow(0, 0, 0, 0.5 * currentMenuOpacity, 1.0, 0.5)
		-- Set width and height of menu ingame
		local margins = 24
		local width = UiWidth() / 2
		local height = UiHeight() / 2
		if hasframed == 1 then
			width = frameWidth + margins
			height = frameHeight + margins
			UiTranslate(UiCenter() - width / 2, UiMiddle() - height / 2)
			-- Draw foreground baseplate
			UiBlur(currentMenuOpacity)
			UiColor(1, 1, 1, currentMenuOpacity)
			UiImageBox(darkbox, width, height, 6, 6)
			if not UiIsMouseInRect(width, height) and (InputPressed('lmb') or InputPressed('rmb')) then
				menuOpen = false
				if menuOpen then
					UiSound(on_sound)
				else
					UiSound(off_sound)
				end
			end
		end
		-- Draw internal elements
		if hasframed == 0 then
			UiWindow(0, 0, true)
			UiBeginFrame()
			drawMenuItems(currentMenuOpacity)
			frameWidth, frameHeight = UiEndFrame()
			hasframed = 1
		else
			drawMenuItems(currentMenuOpacity)
		end
		UiPop()
	end

	-- End modal and return inputs
	UiModalEnd()
end
