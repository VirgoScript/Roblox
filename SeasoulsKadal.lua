local coreGui = cloneref(game:GetService("CoreGui"))
local userInputService = cloneref(game:GetService("UserInputService"))
local runService = cloneref(game:GetService("RunService"))
local tweenService = cloneref(game:GetService("TweenService"))
local teleportService = cloneref(game:GetService("TeleportService"))
local players = cloneref(game:GetService("Players"))
local workspace = cloneref(game:GetService("Workspace"))

if coreGui:FindFirstChild("AceSniperUI") then coreGui.AceSniperUI:Destroy() end

local COL_BG = Color3.fromRGB(18, 18, 20)
local MIN_NORMAL = Color3.fromRGB(40, 40, 45)
local STROKE_CS = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 240, 245)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35)),
})

local allGrads = {}
local function animStroke(parent, thick)
    local s = Instance.new("UIStroke", parent); s.Thickness = thick or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Color = Color3.new(1, 1, 1)
    local g = Instance.new("UIGradient", s); g.Color = STROKE_CS; g.Rotation = 45; table.insert(allGrads, g); return s
end

local gui = Instance.new("ScreenGui", coreGui); gui.Name = "AceSniperUI"
local FULL_H = 225; local MINI_H = 42
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 290, 0, FULL_H); main.Position = UDim2.new(0.5, -145, 0.4, -42 // 2); main.BackgroundColor3 = COL_BG; main.BackgroundTransparency = 0.15; main.BorderSizePixel = 0; main.Active = true; Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10); animStroke(main, 1.5)

-- Elemen UI (Header, TP Game, Navigasi, Input, Auto TP)
local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, -40, 0, 16); title.Position = UDim2.new(0, 12, 0, 8); title.BackgroundTransparency = 1; title.Text = "SEASOULS FIND KADAL"; title.Font = Enum.Font.GothamBlack; title.TextSize = 11.5; title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left
local tpBtn = Instance.new("TextButton", main); tpBtn.Size = UDim2.new(1, -24, 0, 30); tpBtn.Position = UDim2.new(0, 12, 0, 45); tpBtn.BackgroundColor3 = MIN_NORMAL; tpBtn.Text = "TELEPORT KE GAME"; tpBtn.TextColor3 = Color3.new(1, 1, 1); tpBtn.Font = Enum.Font.GothamBold; tpBtn.TextSize = 12; tpBtn.BorderSizePixel = 0; Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5); animStroke(tpBtn, 1)
tpBtn.MouseButton1Click:Connect(function() teleportService:Teleport(89114927420451) end)

local navFrame = Instance.new("Frame", main); navFrame.Size = UDim2.new(1, -24, 0, 30); navFrame.Position = UDim2.new(0, 12, 0, 80); navFrame.BackgroundTransparency = 1
local prevBtn = Instance.new("TextButton", navFrame); prevBtn.Size = UDim2.new(0.48, 0, 1, 0); prevBtn.Text = "< PREV"; prevBtn.BackgroundColor3 = MIN_NORMAL; prevBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(0,5); animStroke(prevBtn, 1)
local nextBtn = Instance.new("TextButton", navFrame); nextBtn.Size = UDim2.new(0.48, 0, 1, 0); nextBtn.Position = UDim2.new(0.52, 0, 0, 0); nextBtn.Text = "NEXT >"; nextBtn.BackgroundColor3 = MIN_NORMAL; nextBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0,5); animStroke(nextBtn, 1)

local inputFrame = Instance.new("Frame", main); inputFrame.Size = UDim2.new(1, -24, 0, 30); inputFrame.Position = UDim2.new(0, 12, 0, 115); inputFrame.BackgroundTransparency = 1
local numInput = Instance.new("TextBox", inputFrame); numInput.Size = UDim2.new(0.65, 0, 1, 0); numInput.BackgroundColor3 = MIN_NORMAL; numInput.PlaceholderText = "Angka (cth: 02)"; numInput.Text = "1"; numInput.TextColor3 = Color3.new(1, 1, 1); numInput.Font = Enum.Font.Gotham; numInput.TextSize = 12; numInput.BorderSizePixel = 0; Instance.new("UICorner", numInput).CornerRadius = UDim.new(0, 5); animStroke(numInput, 1)
local goBtn = Instance.new("TextButton", inputFrame); goBtn.Size = UDim2.new(0.32, 0, 1, 0); goBtn.Position = UDim2.new(0.68, 0, 0, 0); goBtn.Text = "GO"; goBtn.BackgroundColor3 = MIN_NORMAL; goBtn.TextColor3 = Color3.new(1, 1, 1); goBtn.Font = Enum.Font.GothamBold; goBtn.TextSize = 12; goBtn.BorderSizePixel = 0; Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0, 5); animStroke(goBtn, 1)

-- Logika Utama Sinkronisasi
local currentIndex = 1
local function getBorondonList()
    local list = {}
    local folder = workspace:FindFirstChild("SeasoulsPlaces") and workspace.SeasoulsPlaces:FindFirstChild("SanBorondon")
    if folder then for _, obj in pairs(folder:GetChildren()) do if string.find(obj.Name, "Borondon") then table.insert(list, obj) end end end
    return list
end

local function teleportTo(index)
    local list = getBorondonList()
    if #list > 0 then
        if index > #list then index = 1 elseif index < 1 then index = #list end
        currentIndex = index
        local target = list[currentIndex]
        -- Sinkronisasi teks input dengan angka objek
        local _, _, num = string.find(target.Name, "(%d+)")
        numInput.Text = num or tostring(currentIndex)
        
        local lp = players.LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then lp.Character.HumanoidRootPart.CFrame = target:IsA("Model") and target:GetPivot() or target.CFrame end
    end
end

prevBtn.MouseButton1Click:Connect(function() teleportTo(currentIndex - 1) end)
nextBtn.MouseButton1Click:Connect(function() teleportTo(currentIndex + 1) end)
goBtn.MouseButton1Click:Connect(function() teleportTo(tonumber(numInput.Text) or 1) end)

-- Auto TP
local autoTpEnabled = false
local autoTpBtn = Instance.new("TextButton", main); autoTpBtn.Size = UDim2.new(1, -24, 0, 30); autoTpBtn.Position = UDim2.new(0, 12, 0, 150); autoTpBtn.BackgroundColor3 = MIN_NORMAL; autoTpBtn.Text = "AUTO TP: OFF"; autoTpBtn.TextColor3 = Color3.fromRGB(255, 100, 100); autoTpBtn.Font = Enum.Font.GothamBold; autoTpBtn.TextSize = 12; autoTpBtn.BorderSizePixel = 0; Instance.new("UICorner", autoTpBtn).CornerRadius = UDim.new(0, 5); animStroke(autoTpBtn, 1)
autoTpBtn.MouseButton1Click:Connect(function()
    autoTpEnabled = not autoTpEnabled
    autoTpBtn.Text = autoTpEnabled and "AUTO TP: ON" or "AUTO TP: OFF"
    autoTpBtn.TextColor3 = autoTpEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    if autoTpEnabled then task.spawn(function() while autoTpEnabled do teleportTo(currentIndex); task.wait(3) end end) end
end)

-- Minimize & Drag
local minBtn = Instance.new("TextButton", main); minBtn.Size = UDim2.new(0, 22, 0, 22); minBtn.Position = UDim2.new(1, -30, 0, 8); minBtn.BackgroundColor3 = MIN_NORMAL; minBtn.Text = "-"; minBtn.TextColor3 = Color3.new(1, 1, 1); minBtn.Font = Enum.Font.GothamBlack; minBtn.TextSize = 13; minBtn.BorderSizePixel = 0; Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5); animStroke(minBtn, 1)
local minimized = false; minBtn.MouseButton1Click:Connect(function() minimized = not minimized; tweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = minimized and UDim2.new(0, 290, 0, MINI_H) or UDim2.new(0, 290, 0, FULL_H)}):Play(); minBtn.Text = minimized and "+" or "-" end)
local dragging, dragStart, startPos = false, nil, nil; main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = main.Position end end); userInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart; local vp = workspace.CurrentCamera.ViewportSize; local gs = main.AbsoluteSize; main.Position = UDim2.new(0, math.clamp(startPos.X.Offset + d.X, 0, vp.X - gs.X), 0, math.clamp(startPos.Y.Offset + d.Y, 0, vp.Y - gs.Y)) end end); userInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end); runService.RenderStepped:Connect(function() local off = Vector2.new(math.sin(tick() * 2.8), 0); for _, g in ipairs(allGrads) do g.Offset = off end end)
