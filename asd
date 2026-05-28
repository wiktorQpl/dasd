-- palofsc: Aimbot с меню настройки FOV и активацией на E
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Создание графического интерфейса
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

local fovInput = Instance.new("TextBox", frame)
fovInput.Size = UDim2.new(0, 180, 0, 30)
fovInput.Position = UDim2.new(0.1, 0, 0.4, 0)
fovInput.PlaceholderText = "Введите FOV (текущий: 45)"

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(0, 180, 0, 30)
statusLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
statusLabel.Text = "Статус: Выключен (E)"

local FOV_ANGLE = 45
local isLocked = false

fovInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        FOV_ANGLE = tonumber(fovInput.Text) or 45
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        isLocked = not isLocked
        statusLabel.Text = isLocked and "Статус: Включен" or "Статус: Выключен"
    end
end)

local function getTargetInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                if dist < (FOV_ANGLE * 5) and dist < shortestDistance then
                    closestPlayer = player
                    shortestDistance = dist
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if isLocked then
        local target = getTargetInFOV()
        if target and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
