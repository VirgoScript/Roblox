local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🚀 TELEPORT | VIRGOBOY ",
   LoadingTitle = "VIRGOBOY SCRIPT",
   LoadingSubtitle = "Loading.....",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "HyperToolV3",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   Theme = "Ocean",
})

-- === SERVICES & VARIABLES ===
local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local CAS = game:GetService("ContextActionService") 

local Player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Variables Control
local freecamEnabled = false
local fSpeed = 2.2
local rotX, rotY = 0, 0
local dragSens = 0.4
local targetFOV = 70

local speedEnabled = false
local walkSpeedValue = 16 
local fullBrightEnabled = false
local targetPlayerName = ""
local coordInputText = ""
local cctvTarget = ""

-- Anti AFK Global Settings
getgenv().AutoReconnect = true

-- === LOGIC FUNCTIONS ===
local function RejoinServer()
    if #Players:GetPlayers() <= 1 then
        TPS:Teleport(game.PlaceId, Player)
    else
        TPS:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end
end

local function ServerHop()
    local Api = "https://games.roblox.com/v1/games/"
    local _place = game.PlaceId
    local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"

    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. (cursor and "&cursor="..cursor or ""))
        return Http:JSONDecode(Raw)
    end

    local Next;
    repeat
        local ServerList = ListServers(Next)
        for _, s in pairs(ServerList.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TPS:TeleportToPlaceInstance(_place, s.id, Player)
                return 
            end
        end
        Next = ServerList.nextPageCursor
    until not Next
end

-- Fungsi Mematikan Input Karakter agar tidak jalan di tempat
local function FreezeCharacter(bool)
    if bool then
        CAS:BindAction("FreecamFreeze", function() return Enum.ContextActionResult.Sink end, false, 
            Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space)
    else
        CAS:UnbindAction("FreecamFreeze")
    end
end

-- === TABS ===
local TabCam = Window:CreateTab("CAMERA & COORD", "camera") 
local TabPlayer = Window:CreateTab("PLAYER", "user")
local TabMods = Window:CreateTab("MODS", "zap") 
local TabServer = Window:CreateTab("SERVER", "refresh-cw")

-- === TAB: CAMERA & COORD ===
TabCam:CreateSection("Freecam Mode")
local CoordParagraph = TabCam:CreateParagraph({Title = "📍 Live Position", Content = "X: 0, Y: 0, Z: 0"})

TabCam:CreateToggle({
   Name = "Mode Freecam",
   CurrentValue = false,
   Flag = "FreecamToggle",
   Callback = function(Value)
       freecamEnabled = Value
       local char = Player.Character
       local root = char and char:FindFirstChild("HumanoidRootPart")
       local hum = char and char:FindFirstChild("Humanoid")
       
       if char and root then
           if freecamEnabled then
               local rx, ry, rz = cam.CFrame:ToOrientation()
               rotX, rotY = math.deg(rx), math.deg(ry)
               targetFOV = cam.FieldOfView
               
               root.Anchored = true 
               FreezeCharacter(true)
               cam.CameraType = Enum.CameraType.Scriptable
           else
               root.Anchored = false
               FreezeCharacter(false)
               cam.CameraType = Enum.CameraType.Custom
               cam.FieldOfView = 70
               cam.CameraSubject = hum
               UserInputService.MouseBehavior = Enum.MouseBehavior.Default
           end
       end
   end,
})

TabCam:CreateButton({
   Name = "📋 Copy Camera Coords",
   Callback = function()
       local pos = cam.CFrame.Position
       local formattedCoord = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
       if setclipboard then setclipboard(formattedCoord) end
   end,
})

TabCam:CreateSection("Coordinate Teleport")

TabCam:CreateInput({
   Name = "Input Koordinat",
   PlaceholderText = "Contoh: 100, 50, -200",
   Callback = function(Text) coordInputText = Text end,
})

TabCam:CreateButton({
   Name = "⚡ Teleport ke Koordinat",
   Callback = function()
       local coords = {}
       for val in coordInputText:gmatch("([^,]+)") do table.insert(coords, tonumber(val)) end
       if #coords >= 3 and Player.Character then
           Player.Character.HumanoidRootPart.CFrame = CFrame.new(coords[1], coords[2] + 2, coords[3])
       end
   end,
})

TabCam:CreateButton({
   Name = "📋 Copy Character Position",
   Callback = function()
       if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
           local pos = Player.Character.HumanoidRootPart.Position
           local formattedCoord = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
           if setclipboard then 
               setclipboard(formattedCoord)
               Rayfield:Notify({Title = "Copied!", Content = "Posisi karakter disalin ke clipboard.", Duration = 2})
           end
       end
   end,
})

-- === TAB: PLAYER ===
TabPlayer:CreateSection("Teleport Player")
TabPlayer:CreateInput({
   Name = "Nama Target",
   PlaceholderText = "Masukkan username...",
   Callback = function(Text) targetPlayerName = Text end,
})
TabPlayer:CreateButton({
   Name = "🎯 Teleport ke Target",
   Callback = function()
       local target = targetPlayerName:lower()
       for _, v in pairs(Players:GetPlayers()) do
           if v.Name:lower():find(target) or v.DisplayName:lower():find(target) then
               if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                   Player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
               end
               break
           end
       end
   end,
})

TabPlayer:CreateSection("CCTV / Spectate")
TabPlayer:CreateInput({
   Name = "Monitor Player",
   PlaceholderText = "Username...",
   Callback = function(Text) cctvTarget = Text end,
})
TabPlayer:CreateButton({
   Name = "👁️ Mulai CCTV",
   Callback = function()
       local target = cctvTarget:lower()
       for _, v in pairs(Players:GetPlayers()) do
           if v.Name:lower():find(target) or v.DisplayName:lower():find(target) then
               if v.Character and v.Character:FindFirstChild("Humanoid") then
                   cam.CameraSubject = v.Character.Humanoid
               end
               break
           end
       end
   end,
})
TabPlayer:CreateButton({
   Name = "🔄 Reset Kamera",
   Callback = function()
       if Player.Character and Player.Character:FindFirstChild("Humanoid") then 
           cam.CameraSubject = Player.Character.Humanoid 
       end
   end,
})

-- === TAB: MODS ===
TabMods:CreateSection("Performance & Graphics")
TabMods:CreateButton({
   Name = "✨ Ultra HD Graphics",
   Callback = function()
       settings().Rendering.QualityLevel = 21
       Lighting.Technology = Enum.Technology.Future
   end,
})
TabMods:CreateButton({
   Name = "🚀 FPS Booster",
   Callback = function() settings().Rendering.QualityLevel = 1 end,
})

TabMods:CreateSection("Cheats")
TabMods:CreateToggle({
   Name = "Fullbright (ON/OFF)",
   CurrentValue = false,
   Callback = function(Value) fullBrightEnabled = Value end,
})

TabMods:CreateToggle({
   Name = "Speed Hack (ON/OFF)",
   CurrentValue = false,
   Callback = function(Value)
       speedEnabled = Value
       if not speedEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
           Player.Character.Humanoid.WalkSpeed = 16
       end
   end,
})

TabMods:CreateSlider({
   Name = "Atur Kecepatan",
   Range = {16, 1000},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Callback = function(Value)
       walkSpeedValue = Value
   end,
})

TabMods:CreateSection("Anti-AFK Methods")
TabMods:CreateToggle({
   Name = "Auto Reconnect",
   CurrentValue = true,
   Flag = "ReconnectToggle", 
   Callback = function(Value) getgenv().AutoReconnect = Value end,
})

-- === TAB: SERVER ===
TabServer:CreateSection("Server Management")
TabServer:CreateButton({
   Name = "🔄 Rejoin Current Server",
   Callback = function() RejoinServer() end,
})
TabServer:CreateButton({
   Name = "🌐 Find New Server (Hop)",
   Callback = function() ServerHop() end,
})

-- === CORE LOGIC & INPUTS ===

-- 1. Anti-Idle Core (Metode VirtualUser agar tidak AFK tanpa melompat)
for _, v in pairs(getconnections(Player.Idled)) do v:Disable() end

Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- 2. Zoom Logic
UserInputService.InputChanged:Connect(function(input)
    if freecamEnabled and input.UserInputType == Enum.UserInputType.MouseWheel then
        targetFOV = math.clamp(targetFOV - (input.Position.Z * 5), 10, 120)
    end
end)

-- 3. Reconnect Logic
GuiService.ErrorMessageChanged:Connect(function()
    if getgenv().AutoReconnect then
        task.wait(5)
        TPS:Teleport(game.PlaceId, Player)
    end
end)

-- 4. RenderStepped Loop (Freecam & Speed)
RunService.RenderStepped:Connect(function()
    if freecamEnabled then
        local pos = cam.CFrame.Position
        CoordParagraph:Set({Title = "📍 Live Position", Content = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)})
        
        -- Smooth Zoom FOV
        cam.FieldOfView = cam.FieldOfView + (targetFOV - cam.FieldOfView) * 0.2
        
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local delta = UserInputService:GetMouseDelta()
            rotY = rotY - delta.X * dragSens
            rotX = math.clamp(rotX - delta.Y * dragSens, -80, 80)
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end

        local newRot = CFrame.Angles(0, math.rad(rotY), 0) * CFrame.Angles(math.rad(rotX), 0, 0)
        local moveDir = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + newRot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - newRot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - newRot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + newRot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        cam.CFrame = CFrame.new(cam.CFrame.Position + (moveDir * fSpeed)) * newRot
    end

    if speedEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = walkSpeedValue
    end
end)

-- 5. Heartbeat Loop (Fullbright)
RunService.Heartbeat:Connect(function()
    if fullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
    end
end)

Rayfield:Notify({
   Title = "VIRGOBOY LOADED",
   Content = "Script siap digunakan tanpa Auto Jump!",
   Duration = 5,
   Image = 4483362458,
})
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024"))()