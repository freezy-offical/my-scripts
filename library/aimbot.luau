local LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(...) return ... end

local game, workspace = game, workspace
local getrawmetatable, pcall, next, tick = getrawmetatable, pcall, next, tick
local mathclamp, mathpi, mathhuge, osclock = math.clamp, math.pi, math.huge, os.clock

local cloneref = cloneref or LPH_NO_VIRTUALIZE(function(...) return ... end)
local clonefunction = clonefunction or LPH_NO_VIRTUALIZE(function(...) return ... end)

if not Drawing or not Drawing.new then
	loadstring(game.HttpGet(game, "https://pastebin.com/raw/huyiRsK0"))()
end

local Drawing = Drawing

local _Drawingnew = clonefunction(Drawing.new)
local _quadSupported = pcall(function() local q = _Drawingnew("Quad") q:Remove() end)

if not _quadSupported then
	local DrawQuad = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/Exunys/Custom-Quad-Render-Object/main/Main.lua"))()

	Drawing.new = LPH_NO_VIRTUALIZE(function(...)
		return ({...})[1] == "Quad" and DrawQuad(...) or _Drawingnew(...)
	end)
end

local Vector2new, CFramenew, CFramefromOrientation, Color3fromRGB, Color3fromHSV = Vector2.new, CFrame.new, CFrame.fromOrientation, Color3.fromRGB, Color3.fromHSV
local Drawingnew = Drawing.new

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local localPlayer = players.LocalPlayer

local aimbot = {
	enabled = false,
	keybind = Enum.UserInputType.MouseButton2,
	targetPart = "Head",
	toggle = false,
	delay = {
		enabled = false,
		delayMs = 0
	},
	offset = {
		enabled = false,
		x = 0,
		y = 0
	},
	smoothness = {
		enabled = false,
		x = 5,
		y = 5
	},
	prediction = {
		enabled = false,
		amount = 0.165
	},
	fov = {
		enabled = false,
		showFov = false,
		rainbow = false,
		filled = false,
		outline = true,
		radius = 150,
		color = Color3fromRGB(255, 255, 255),
		lockedColor = Color3fromRGB(255, 0, 0),
		outlineColor = Color3fromRGB(0, 0, 0),
		transparency = 1,
		filledTransparency = 0.5,
		numSides = 64,
		thickness = 1,
		position = "Center"
	},
	stickyAim = {
		enabled = false,
		keybind = nil,
		strength = 0.5,
		radius = 150,
		smoothness = {
			enabled = false,
			x = 5,
			y = 5
		}
	},
	checks = {
		teamCheck = { enabled = false, type = "TeamColor" },
		visibleCheck = false,
		invisibleCheck = true,
		healthCheck = false,
		distance = {
			enabled = false,
			maxDistance = 500,
			type = "Character"
		}
	},
	customParts = {},
	whitelist = {},
	blacklist = {},
	triggerbot = {
		enabled = false,
		delay = 0.01,
		keybind = nil
	}
}

local isAiming = false
local firing = false
local lastTarget = nil
local targetLockTime = 0
local originalSensitivity = .userInputService, "MouseDeltaSensitivity")

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local fill = Drawingnew("Circle")
local outline = Drawingnew("Circle")
local circle = Drawingnew("Circle")

local function lerpAngle(current, target, alpha)
	local diff = (target - current + mathpi) % (mathpi * 2) - mathpi
	return current + diff * alpha
end

local function restoreSensitivity()
	if .userInputService, "MouseDeltaSensitivity") == 0 then
		=userInputService, "MouseDeltaSensitivity", originalSensitivity)
	end
end

local function applySmoothAim(camera, targetCFrame, smX, smY, strength)
	local sx = mathclamp(smX, 0, 10)
	local sy = mathclamp(smY, 0, 10)
	local alphaX = (sx == 0 and 1 or (1 / (sx + 1))) * (strength or 1)
	local alphaY = (sy == 0 and 1 or (1 / (sy + 1))) * (strength or 1)
	local currentX, currentY, _ = .camera, "CFrame"):ToOrientation()
	local targetX, targetY, targetZ = targetCFrame:ToOrientation()
	local newX = lerpAngle(currentX, targetX, alphaX)
	local newY = lerpAngle(currentY, targetY, alphaY)
	=camera, "CFrame", CFramenew(.camera, "CFrame").Position) * CFramefromOrientation(newX, newY, targetZ))
end

local function isCharacterInvisible(character)
	for _, obj in next, .character, "GetDescendants")(character) do
		if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
			if obj.Transparency < 0.99 then
				return false
			end
		end
	end
	return true
end

local function isInList(list, player, character)
	for _, entry in next, list do
		if entry == player or entry == character then return true end
		if type(entry) == "string" and player and .player, "Name") == entry then return true end
	end
	return false
end

local function isVisible(target)
	local success, result = pcall(function()
		local character = .localPlayer, "Character")
		local camera = .workspace, "CurrentCamera")
		if not (character and .character, "FindFirstChild")(character, "Head")) then return false end
		local origin = .character, "Head").Position
		local direction = .target, "Position") - origin
		local filter = {character, camera}
		for _ = 1, 5 do
			rayParams.FilterDescendantsInstances = filter
			local res = .workspace, "Raycast")(workspace, origin, direction, rayParams)
			if not res then return true end
			local part = res.Instance
			if part:IsDescendantOf(target.Parent) then
				return true
			elseif part.Transparency >= 0.9 or not part.CanCollide or part:IsA("Accessory") or part:IsA("Handle") then
				table.insert(filter, part)
			else
				return false
			end
		end
		return false
	end)
	if not success then warn("[aimbot] " .. tostring(result)) return false end
	return result
end

local function isValidTarget(character, checkVisibility, specificPart)
	local success, result, hit = pcall(function()
		local camera = .workspace, "CurrentCamera")
		if not character or character == .localPlayer, "Character") then return false end
		local targetPart = specificPart or .character, "FindFirstChild")(character, aimbot.targetPart) or .character, "FindFirstChild")(character, "Head")
		local humanoid = .character, "FindFirstChildOfClass")(character, "Humanoid")
		if not (targetPart and humanoid) then return false end
		if aimbot.checks.healthCheck and .humanoid, "Health") <= 0 then return false end
		if aimbot.checks.invisibleCheck and isCharacterInvisible(character) then return false end
		local player = .players, "GetPlayerFromCharacter")(players, character)
		if #aimbot.whitelist > 0 and not isInList(aimbot.whitelist, player, character) then return false end
		if isInList(aimbot.blacklist, player, character) then return false end
		if player then
			local teamCheck = aimbot.checks.teamCheck
			if teamCheck.enabled then
				local option = teamCheck.type == "Team" and "Team" or "TeamColor"
				if .player, option) == .localPlayer, option) then return false end
			end
		end
		local distanceCheck = aimbot.checks.distance
		if distanceCheck.enabled then
			local origin = .camera, "CFrame").Position
			local char = .localPlayer, "Character")
			if distanceCheck.type == "Character" and char and .char, "FindFirstChild")(char, "HumanoidRootPart") then
				origin = .char, "HumanoidRootPart").Position
			end
			if (.targetPart, "Position") - origin).Magnitude > distanceCheck.maxDistance then return false end
		end
		if checkVisibility and aimbot.checks.visibleCheck and not isVisible(targetPart) then return false end
		return true, targetPart
	end)
	if not success then warn("[aimbot] " .. tostring(result)) return false end
	return result, hit
end

local function getClosestTarget()
	local success, result = pcall(function()
		local camera = .workspace, "CurrentCamera")
		local targetPart = nil
		local shortestDistance = mathhuge
		local fovPos = .userInputService, "GetMouseLocation")(userInputService)
		if aimbot.fov.position == "Center" then fovPos = .camera, "ViewportSize") / 2 end
		local fovEnabled = aimbot.fov.enabled
		local fovRadius = mathclamp(aimbot.fov.radius, 1, 500)
		for _, descendant in next, .workspace, "GetChildren")(workspace) do
			if descendant:IsA("Model") then
				local isValid, hitPart = isValidTarget(descendant, true)
				if isValid then
					local screenPoint, onScreen = .camera, "WorldToViewportPoint")(camera, .hitPart, "Position"))
					if onScreen then
						local distance = (Vector2new(screenPoint.X, screenPoint.Y) - fovPos).Magnitude
						if fovEnabled and distance > fovRadius then continue end
						if distance < shortestDistance then
							targetPart = hitPart
							shortestDistance = distance
						end
					end
				end
			end
		end
		for _, part in next, aimbot.customParts do
			local ok, partPos = pcall(function() return .part, "Position") end)
			if not ok or not partPos then continue end
			local screenPoint, onScreen = .camera, "WorldToViewportPoint")(camera, partPos)
			if onScreen then
				local distance = (Vector2new(screenPoint.X, screenPoint.Y) - fovPos).Magnitude
				if fovEnabled and distance > fovRadius then continue end
				if distance < shortestDistance then
					targetPart = part
					shortestDistance = distance
				end
			end
		end
		return targetPart
	end)
	if not success then warn("[aimbot] " .. tostring(result)) return nil end
	return result
end

runService.RenderStepped:Connect(function()
	local success, err = pcall(function()
		local camera = .workspace, "CurrentCamera")
		local sticky = aimbot.stickyAim
		local fov = aimbot.fov

		local currentTarget = getClosestTarget()
		local isLocked = (isAiming or sticky.enabled) and currentTarget ~= nil

		local triggerActive = aimbot.triggerbot.enabled
		if triggerActive and aimbot.triggerbot.keybind ~= nil then
			triggerActive = userInputService:IsKeyDown(aimbot.triggerbot.keybind) or userInputService:IsMouseButtonPressed(aimbot.triggerbot.keybind)
		end

		if triggerActive and not firing then
			local mouse = .localPlayer, "GetMouse")(localPlayer)
			local target = .mouse, "Target")
			if target then
				local character = .target, "FindFirstAncestorOfClass")(target, "Model")
				if character and character ~= .localPlayer, "Character") then
					local humanoid = .character, "FindFirstChildOfClass")(character, "Humanoid")
					if humanoid and .humanoid, "Health") > 0 then
						task.spawn(function()
							firing = true
							mouse1press()
							task.wait(aimbot.triggerbot.delay)
							mouse1release()
							firing = false
						end)
					end
				end
			end
		end

		if fov.showFov then
			local fovPos = .userInputService, "GetMouseLocation")(userInputService)
			if fov.position == "Center" then fovPos = .camera, "ViewportSize") / 2 end
			local fovColor = fov.rainbow and Color3fromHSV(osclock() % 5 / 5, 1, 1) or (isLocked and fov.lockedColor or fov.color)
			local rad = mathclamp(fov.radius, 1, 500)

			if fov.filled then
				fill.Visible = true
				fill.Position = fovPos
				fill.Radius = rad
				fill.Color = fovColor
				fill.Transparency = fov.filledTransparency
				fill.NumSides = fov.numSides
				fill.Filled = true
			else
				fill.Visible = false
			end

			if fov.outline then
				outline.Visible = true
				outline.Position = fovPos
				outline.Radius = rad
				outline.Color = fov.outlineColor
				outline.Transparency = fov.transparency
				outline.NumSides = fov.numSides
				outline.Thickness = fov.thickness + 2
			else
				outline.Visible = false
			end

			circle.Visible = true
			circle.Position = fovPos
			circle.Radius = rad
			circle.Color = fovColor
			circle.Transparency = fov.transparency
			circle.NumSides = fov.numSides
			circle.Thickness = fov.thickness
		else
			circle.Visible = false
			fill.Visible = false
			outline.Visible = false
		end

		local stickyActive = sticky.enabled
		if sticky.enabled and sticky.keybind ~= nil then
			stickyActive = userInputService:IsKeyDown(sticky.keybind) or userInputService:IsMouseButtonPressed(sticky.keybind)
		end

		if aimbot.enabled or stickyActive then
			local target = currentTarget
			if target then
				if target ~= lastTarget then
					lastTarget = target
					targetLockTime = tick()
				end
				local isDelayPassed = not aimbot.delay.enabled or (tick() - targetLockTime) >= (aimbot.delay.delayMs / 1000)
				local targetPosition = .target, "Position")
				if aimbot.offset.enabled then
					targetPosition = targetPosition + Vector3.new(aimbot.offset.x, aimbot.offset.y, 0)
				end
				if aimbot.prediction.enabled then
					targetPosition = targetPosition + .target, "Velocity") * aimbot.prediction.amount
				end
				if aimbot.enabled and isAiming and isDelayPassed then
					=userInputService, "MouseDeltaSensitivity", 0)
					local targetCFrame = CFramenew(.camera, "CFrame").Position, targetPosition)
					if aimbot.smoothness.enabled then
						applySmoothAim(camera, targetCFrame, aimbot.smoothness.x, aimbot.smoothness.y, nil)
					else
						=camera, "CFrame", targetCFrame)
					end
				elseif stickyActive then
					restoreSensitivity()
					local screenPoint, onScreen = .camera, "WorldToViewportPoint")(camera, targetPosition)
					if onScreen then
						local mousePosition = .userInputService, "GetMouseLocation")(userInputService)
						local distance = (Vector2new(screenPoint.X, screenPoint.Y) - mousePosition).Magnitude
						if distance <= sticky.radius then
							local targetCFrame = CFramenew(.camera, "CFrame").Position, targetPosition)
							if sticky.smoothness.enabled then
								local sx = mathclamp(sticky.smoothness.x, 0, 10)
								local sy = mathclamp(sticky.smoothness.y, 0, 10)
								if distance < 30 then sx = sx * (distance / 30); sy = sy * (distance / 30) end
								applySmoothAim(camera, targetCFrame, sx, sy, sticky.strength)
							else
								=camera, "CFrame", .camera, "CFrame"):Lerp(targetCFrame, sticky.strength))
							end
						end
					end
				else
					restoreSensitivity()
				end
			else
				restoreSensitivity()
			end
		else
			restoreSensitivity()
		end
	end)
	if not success then warn("[aimbot] " .. tostring(err)) end
end)

.userInputService, "InputBegan"):Connect(LPH_NO_VIRTUALIZE(function(input)
	local success, err = pcall(function()
		local keybind = aimbot.keybind
		if keybind and (input.KeyCode == keybind or input.UserInputType == keybind) then
			if .userInputService, "MouseDeltaSensitivity") ~= 0 then
				originalSensitivity = .userInputService, "MouseDeltaSensitivity")
			end
			if aimbot.toggle then isAiming = not isAiming else isAiming = true end
		end
	end)
	if not success then warn("[aimbot] " .. tostring(err)) end
end))

.userInputService, "InputEnded"):Connect(LPH_NO_VIRTUALIZE(function(input)
	local success, err = pcall(function()
		local keybind = aimbot.keybind
		if keybind and (input.KeyCode == keybind or input.UserInputType == keybind) and not aimbot.toggle then
			isAiming = false
			restoreSensitivity()
		end
	end)
	if not success then warn("[aimbot] " .. tostring(err)) end
end))

return aimbot
