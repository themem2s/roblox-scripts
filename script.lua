local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local virtualInputManager = game:GetService("VirtualInputManager")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Ekranın ortasının soluna tıklama koordinatlarını belirle
local function getClickPosition()
    local screenSize = camera.ViewportSize
    local centerX = screenSize.X / 2
    local centerY = screenSize.Y / 2
    -- Ortadan sola 100 piksel kaydır (ayarlanabilir)
    local targetX = centerX - 100
    local targetY = centerY
    return Vector2.new(targetX, targetY)
end

-- Çift tıklama simülasyonu (oyun içi test amaçlı)
local function simulateDoubleClick()
    local clickPos = getClickPosition()
    
    -- Raycasting ile tıklama noktasında bir nesne bul
    local ray = camera:ScreenPointToRay(clickPos.X, clickPos.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character or player.CharacterAdded:Wait()}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        print("Tıklanan nesne: " .. hitPart.Name)
        -- Örnek: Nesneye bir olay tetikleyici ekle
        -- hitPart:FindFirstChild("ClickDetector")?.MouseClick:Fire(player)
    else
        print("Tıklama noktasında nesne bulunamadı: X=" .. clickPos.X .. ", Y=" .. clickPos.Y)
    end
end

-- Script başlangıcında çift tıklama simülasyonunu çalıştır
local function startSimulation()
    simulateDoubleClick()
    wait(0.1) -- Çift tıklama için kısa gecikme
    simulateDoubleClick()
end

-- Oyuncunun karakteri yüklendiğinde çalıştır
player.CharacterAdded:Connect(startSimulation)
if player.Character then
    startSimulation()
end

-- Hedef koordinatlar
local targetPos = Vector3.new(-7708.15, 5545.54, -336.53)

-- No-clip fonksiyonu
local noclipConnection
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

-- Hareket fonksiyonu
local function moveToTarget()
    if humanoidRootPart then
        enableNoClip()
        local startPos = humanoidRootPart.Position
        local distance = (targetPos - startPos).Magnitude
        local walkSpeed = 75 -- Doğal Roblox yürüyüş hızı
        local duration = distance / walkSpeed
        local startTime = tick()

        while true do
            local elapsed = tick() - startTime
            local alpha = math.clamp(elapsed / duration, 0, 1)
            humanoidRootPart.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
            if alpha >= 1 then break end
            runService.RenderStepped:Wait()
        end

        -- Hedef konumda sabitle
        humanoidRootPart.CFrame = CFrame.new(targetPos)

        -- 'E' tuşuna bas
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.1)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

        -- Scripti yeni sunucuya aktarmak için sıraya al
        local teleportCode = [[
            loadstring(game:HttpGet("https://raw.githubusercontent.com/themem2s/roblox-scripts/refs/heads/main/script.lua"))()
        ]]
        local queue = queue_on_teleport or (syn and syn.queue_on_teleport)
        if queue then
            queue(teleportCode)
        end

        -- 13 saniye bekle ve yeniden bağlan
        wait(7)
        teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
end

-- Script'i başlat
moveToTarget()
