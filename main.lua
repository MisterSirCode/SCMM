#include "game.lua"
#include "menu_api.lua"

local uidelay = 0.1
local playerTarget
local maxDist = 1000
local hasframed = 0
local frameWidth, frameHeight

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
		Explosion(hitPos, GetFloat(modid..'click-explode-power'))
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
	validateDefaultKeys()
	-- if GetBool(modid..'startedUsingMenu') == false then
	-- 	SetBool(modid..'ingame-menu', true)
	-- 	SetFloat(modid..'player-boost-velocity', 0.3)
	-- 	SetFloat(modid..'vehicle-boost-velocity', 0.3)
	-- 	SetFloat(modid..'free-cam-velocity', 1.0)
	-- 	SetFloat(modid..'click-explode-power', 2)
	-- 	SetFloat(modid..'click-destroy-power', 5)
	-- 	SetFloat(modid..'blast-away-radius', 10)
	-- 	SetFloat(modid..'clear-debris-radius', 10)
	-- 	SetFloat(modid..'ray-cutter-radius', 0.2)
	-- 	SetBool(modid..'startedUsingMenu', true)
	-- end

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
	-- Unlock All Items Hack End

	SetBool(tempid..'menu-open', false)
	tp = false
	mx = 0
	my = 0
	ingameMenuAlpha = 0
	aaFlightRate = 0.166667
	aaFlightCurrentX = 0
	aaFlightCurrentY = 0
	aaFlightCurrentZ = 0
	closeMenu = false
	-- SetInt(modid..'flightSpeed', 10)
end

function tick(dt)
	if GetBool(tempid..'menu-open') then
		SetBool('game.disablepause', true)
		SetBool('game.disablemap', true)
	end

	-- Infinite Mission Time
	if GetBool(modid..'inf-timer') then
		if GetBool('level.alarm') then
			SetFloat('level.alarmtimer', 60)		
		end
	end
	-- Infinite Mission Time End

	-- Infinite Ammo
	if GetBool(modid..'inf-ammo') then
		tool = GetString('game.player.tool')
		SetInt('game.tool.'..tool..'.ammo', 999)
		SetString('game.tool.tool.ammo.display', '')
	end
	-- Infinite Ammo End

	-- Infinite Health

	-- TODO: CHANGE TO SETPARAM GODMODE

	if GetBool(modid..'inf-health', true) then
		if GetPlayerHealth() then
			SetPlayerHealth(1)
		end
	end
	-- Infinite Health End

	-- Player Boost
	if GetBool(modid..'player-boost') then
		if GetPlayerVehicle() == 0 then
			local t = GetPlayerTransform()
			local d = TransformToParentVec(t, Vec(0, 0, 0))
			local vel = GetPlayerVelocity()
			local velocity = GetFloat(modid..'player-boost-velocity')
			if InputDown(GetString(modid..'player-boost.key')) then
				if InputDown('space') then
					d = TransformToParentVec(t, Vec(0, velocity, 0))
					vel = VecAdd(vel, d)
				elseif InputDown('shift') then
					d = TransformToParentVec(t, Vec(0, -velocity, 0))
					vel = VecAdd(vel, d)
				end
			elseif InputDown(GetString(modid..'player-boost1')) then
				if InputDown('w') then
					d = TransformToParentVec(t, Vec(0, 0, -velocity))
					vel = VecAdd(vel, d)
				elseif InputDown('s') then
					d = TransformToParentVec(t, Vec(0, 0, velocity))
					vel = VecAdd(vel, d)
				elseif InputDown('a') then
					d = TransformToParentVec(t, Vec(-velocity, 0, 0))
					vel = VecAdd(vel, d)
				elseif InputDown('d') then
					d = TransformToParentVec(t, Vec(velocity, 0, 0))
					vel = VecAdd(vel, d)
				end
			end
			SetPlayerVelocity(vel)
		end
	end
	-- Player Boost End

	-- Vehicle Boost Hack
	if GetBool(modid..'vehicle-boost') then
		local v = GetPlayerVehicle()
		if v > 0 then
			local t = GetVehicleTransform(v)
			local d = TransformToParentVec(t, Vec(0, 0, 0))
			local b = GetVehicleBody(v)	
			local vel = GetBodyVelocity(b)
			local velocity = GetFloat(modid..'vehicle-boost-velocity')
			if InputDown(GetString(modid..'vehicle-boost.key')) then
				if InputDown('space') then
					d = TransformToParentVec(t, Vec(0, velocity, 0))
					vel = VecAdd(vel, d)
				elseif InputDown('shift') then
					d = TransformToParentVec(t, Vec(0, -velocity, 0))
					vel = VecAdd(vel, d)
				end
			elseif InputDown(GetString(modid..'vehicle-boost1')) then
				if InputDown('up') then
					d = TransformToParentVec(t, Vec(0, 0, -velocity))
					vel = VecAdd(vel, d)
				elseif InputDown('down') then
					d = TransformToParentVec(t, Vec(0, 0, velocity))
					vel = VecAdd(vel, d)
				end
			end
			SetBodyVelocity(b, vel)
		end
	end
	-- Vehicle Boost Hack End

	-- Blow Away Debris Hack
	if GetBool(modid..'blast-away') then
		if GetPlayerVehicle() == 0 then
			local strength = 20
			local maxMass = 100000
			local maxBlowDist = GetFloat(modid..'blast-away-radius')
			if InputDown(GetString(modid..'blast-away.key')) and GetBool('game.player.canusetool') then
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
						SetBodyVelocity(b, vel)
					end
				end
			end
		end
	end
	-- Blow Away Debris Hack End

	-- Click Fire Hack
	if GetBool(modid..'click-fire') then
		local toolId = toolIds[GetInt(modid..'click-fire-tool')]
		if GetString('game.player.tool') == toolId or GetString('game.player.tool') == 'aahandflame' then
			if GetBool('game.player.canusetool') and tp == false and InputDown('lmb') then
				for i=1, 50 do
					clickFlame()
				end
			end
		end
	end
	-- Click Fire Hack End

	-- Click Explode Hack
	if GetBool(modid..'click-explode') then
		local toolId = toolIds[GetInt(modid..'click-explode-tool')]
		if GetBool(modid..'explPaint') then
			if GetString('game.player.tool') == toolId then
				if GetBool('game.player.canusetool') and tp == false and InputDown('lmb') then
					clickExplode()
				end
			end
		else
			if GetString('game.player.tool') == toolId then
				if GetBool('game.player.canusetool') and tp == false and InputPressed('lmb') then
					clickExplode()
				end
			end
		end
	end
	-- Click Explode Hack Ewd

	-- Click Destroy Hack
	if GetBool(modid..'click-destroy') then
		local toolId = toolIds[GetInt(modid..'click-destroy-tool')]
		if GetString('game.player.tool') == toolId or GetString('game.player.tool') == 'aahanddestroy' then
			if GetBool('game.player.canusetool') and tp == false and InputPressed('lmb') then
				clickDestroy()
			end
		end
	end
	-- Click Destroy Hack End

	-- Click Delete Hack
	if GetBool(modid..'click-delete') then
		local toolId = toolIds[GetInt(modid..'click-delete-tool')]
		if GetString('game.player.tool') == toolId or GetString('game.player.tool') == 'aahanddelete' then
			if GetBool('game.player.canusetool') and tp == false then
				local t = GetCameraTransform()
				local fwd = TransformToParentVec(t, Vec(0, 0, -1))
				local maxDist = 2000
				local hit, dist, normal, shape = QueryRaycast(t.pos, fwd, maxDist)
				if hit then
					DrawShapeOutline(shape, 1, 0.1, 0.1, 1)
					if InputPressed('lmb') then
						Delete(shape)
					end
				end
			end
		end
	end
	-- Click Delete Hack End

	-- Debug Info
	if GetBool(modid..'debug-info') then
		local t = GetCameraTransform()
		local pt = GetPlayerTransform()
		local dir = TransformToParentVec(t, {0, 0, -1})
		local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 100)
		DebugWatch('Player Position', round(pt.pos[1], 1)..', '..round(pt.pos[2], 1)..', '..round(pt.pos[3], 1))
		DebugWatch('Hit', hit)
		if hit then
			local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
			DebugLine(VecAdd(t.pos, {0, -1, 0}), hitPoint, 0, 1, 0)
			DebugCross(hitPoint)
			DrawShapeOutline(shape, 1)
			DebugWatch('Point Position', round(hitPoint[1], 1)..', '..round(hitPoint[2], 1)..', '..round(hitPoint[3], 1))
			DebugWatch('Shape Handle', shape)
		end
		DebugWatch('Current Tool ID', GetString('game.player.tool'))
	end
	-- Debug Info End

	-- Smooth Flight

	-- TODO: CHANGE TO SETPARAM FLIGHT

	if GetBool(modid..'flight') and tp == false then
		if InputPressed(GetString(modid..'flight.key')) then
			SetBool(tempid..'isSmoothFlying', not GetBool(tempid..'isSmoothFlying'))
		end
		if GetBool(tempid..'isSmoothFlying') then
			local t = GetPlayerTransform()
			local v = GetPlayerVelocity()
			local fs = GetInt(modid..'flightSpeed')
			local aaXDir = 0
			local aaYDir = 0
			local aaZDir = 0
			if InputDown('right') then aaXDir = aaXDir + 1 end
			if InputDown('left') then aaXDir = aaXDir - 1 end
			if InputDown('space') then aaYDir = aaYDir + 1 end
			if InputDown('shift') then aaYDir = aaYDir - 1 end
			if InputDown('down') then aaZDir = aaZDir + 1 end
			if InputDown('up') then aaZDir = aaZDir - 1 end
			SetPlayerVelocity(TransformToParentVec(t, Vec(0 + (fs * aaXDir), aaFlightRate + (fs * aaYDir), 0 + (fs * aaZDir))))
		end
	end
	-- Smooth Flight End

	-- Free Camera
	if GetBool(modid..'free-cam') and GetBool(tempid..'isSmoothFlying') == false then
		ptn = GetCameraTransform()
		if tp then
			mx = mx - InputValue('mousedx') / 17.5
			my = my - InputValue('mousedy') / 17.5
			mouserot = QuatEuler(my, mx, 0)
			if InputDown('w') then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, 0, -GetFloat(modid..'free-cam-velocity')))), 0.2)), mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown('s') then
				ptn = Transform(VecSub(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, 0, -GetFloat(modid..'free-cam-velocity')))), 0.2)), mouserot)
				SetCameraTransform(ptn)
			end
			if not(InputDown('w') or InputDown('s')) or InputDown('a') or InputDown('d') then
				ptn = Transform(GetCameraTransform().pos, mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown('a') then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(-GetFloat(modid..'free-cam-velocity'), 0, 0))), 0.13)), mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown('d') then
				ptn = Transform(VecSub(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(-GetFloat(modid..'free-cam-velocity'), 0, 0))), 0.13)), mouserot)
				SetCameraTransform(ptn) 
			end
			if InputDown('space') then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, GetFloat(modid..'free-cam-velocity'), 0))), 0.16)), mouserot)
				SetCameraTransform(ptn)
			end
			if InputDown('shift') then
				ptn = Transform(VecAdd(ptn.pos, VecScale(VecNormalize(TransformToParentVec(ptn, Vec(0, -GetFloat(modid..'free-cam-velocity'), 0))), 0.16)), mouserot)
				SetCameraTransform(ptn)
			end
			SetPlayerTransform(GetPlayerTransform())
		end
		if InputPressed(GetString(modid..'free-cam.key')) then
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
	if GetBool(modid..'ray-cutter') then
		if InputDown(GetString(modid..'ray-cutter.key')) then
			local t = GetCameraTransform()
			local dir = TransformToParentVec(t, {0, 0, -1})
			local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 1000)
			local radius = GetFloat(modid..'ray-cutter-radius')
			if hit then
				local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
				MakeHole(hitPoint, radius, radius, radius)
			end
		end
	end
	-- Line Cutter End

	-- Clear Debris
	if GetBool(modid..'clear-debris') then
		if InputDown(GetString(modid..'clear-debris.key')) then
			local maxMass = 100000
			local maxBlowDist = GetFloat(modid..'clear-debris-radius')
			local t = GetCameraTransform()
			local c = TransformToParentPoint(t, Vec(0, 0, -maxBlowDist/2))
			local mi = VecAdd(c, Vec(-maxBlowDist/2, -maxBlowDist/2, -maxBlowDist/2))
			local ma = VecAdd(c, Vec(maxBlowDist/2, maxBlowDist/2, maxBlowDist/2))
			QueryRequire('physical dynamic')
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

-- Externalized so that it can be framed more easily.
function drawInternalMenuItems()
	UiPush()
		UiTranslate(24, 24)
		UiFont('bold.ttf', 24)
		UiText('The Assist Menu')
		UiTranslate(0, 24)
		UiFont('bold.ttf', 16)
		UiText('Version '..version)
	UiPop()
end

function draw()
	if GetBool(tempid..'menu-open') then
		UiModalBegin() -- Disable other inputs
		UiMakeInteractive() -- Put focus on UI window
	end

	-- Toggle UI On and Off
	if InputPressed(GetString(modid..'menu-ingame.key')) then
		SetBool(tempid..'menu-open', not GetBool(tempid..'menu-open'))
	end

	-- Draw Menu
	if GetBool(tempid..'menu-open') then
		if InputPressed('esc') then
			SetBool(tempid..'menu-open', false)
		end

		-- Begin UI Layer
		UiPush()
		UiAlign('left top')
		-- Set width and height of menu ingame
		local margins = 24
		local width = UiWidth() / 2
		local height = UiHeight() / 2
		if hasframed == 1 then
			width = frameWidth + margins
			height = frameHeight + margins
			UiTranslate(UiCenter() - width / 2, UiMiddle() - height / 2)
			-- Draw foreground baseplate
			UiBlur(1)
			UiImageBox(darkbox, width, height, 6, 6)
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
	end

	-- End modal and return inputs
	UiModalEnd()
end
