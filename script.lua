local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local virtualInputManager = game:GetService("VirtualInputManager")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")

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
        -- Ekran boyutunu al ve tıklama pozisyonunu hesapla
        local screenSize = userInputService:GetScreenSize()
        local centerX, centerY = screenSize.X / 2, screenSize.Y / 2
        local clickX = centerX - 100 -- Ortadan 100 piksel sola
        local clickY = centerY

        -- İki kez tıklama simülasyonu
        for i = 1, 2 do
            virtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0) -- Fare sol tuş basılı
            wait(0.05) -- Tıklama süresi
            virtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0) -- Fare sol tuş bırak
            wait(0.1) -- Tıklamalar arası kısa bekleme
        end

        -- Orijinal hareket kodu
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

        -- 7 saniye bekle ve yeniden bağlan
        wait(7)
        teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
end

-- Script'i başlat
moveToTarget()
