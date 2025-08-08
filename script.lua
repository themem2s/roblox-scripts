local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local runService = game:GetService("RunService")
local virtualInputManager = game:GetService("VirtualInputManager")
local teleportService = game:GetService("TeleportService")
local userInputService = game:GetService("UserInputService") 

local targetPos = Vector3.new(-7708.15, 5545.54, -336.53)

local noclipConnection
local lockPositionConnection

local function enableNoClip()
    if noclipConnection then return end
    noclipConnection = runService.Stepped:Connect(function()
        if character and character:FindFirstChild("Humanoid") then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function lockPosition()
    if lockPositionConnection then return end
    lockPositionConnection = runService.RenderStepped:Connect(function()
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(targetPos)
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
end

local function moveToTarget()
    if humanoidRootPart then
        local screenSize = userInputService:GetScreenSize()
        local centerX, centerY = screenSize.X / 2, screenSize.Y / 2
        local clickX = centerX - 100
        local clickY = centerY

        -- Simulate two mouse clicks
        for i = 1, 2 do
            virtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0) 
            wait(0.05)
            virtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0) 
            wait(0.1)
        end

        
        enableNoClip()
        local startPos = humanoidRootPart.Position
        local distance = (targetPos - startPos).Magnitude
        local walkSpeed = 75 
        local duration = distance / walkSpeed
        local startTime = tick()

        while true do
            local elapsed = tick() - startTime
            local alpha = math.clamp(elapsed / duration, 0, 1)
            humanoidRootPart.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
            if alpha >= 1 then break end
            runService.RenderStepped:Wait()
        end

        lockPosition()

        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.1)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

        local teleportCode = [[
            loadstring(game:HttpGet("https://raw.githubusercontent.com/themem2s/roblox-scripts/refs/heads/main/script.lua"))()
        ]]
        local queue = queue_on_teleport or (syn and syn.queue_on_teleport)
        if queue then
            queue(teleportCode)
        end

        wait(7)
        teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
end

moveToTarget()
