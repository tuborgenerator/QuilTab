--========================================================
-- QUILTAB | CHARACTER CONTROL CENTER (STUDIO-SAFE)
-- Place as a LocalScript in StarterPlayer > StarterPlayerScripts
-- Designed for your own Roblox experience.
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local old = PG:FindFirstChild("QuilTabCharacter")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(10, 11, 14),
    panel = Color3.fromRGB(19, 20, 25),
    card = Color3.fromRGB(29, 30, 37),
    hover = Color3.fromRGB(49, 24, 30),
    red = Color3.fromRGB(176, 28, 49),
    bright = Color3.fromRGB(255, 65, 88),
    white = Color3.fromRGB(245, 245, 248),
    muted = Color3.fromRGB(155, 158, 169),
    green = Color3.fromRGB(95, 225, 150),
    line = Color3.fromRGB(75, 35, 43)
}

local defaultSpeed, defaultJump = 16, 50
local infiniteJump = false
local autoRun = false
local airControl = false
local bookmarks = {}
local jumpCount, airTime, distanceTravelled = 0, 0, 0
local lastPosition, lastAirStart = nil, nil
local fallDistance, falling = 0, false
local alive = true
local status, speedBox, jumpBox
local savedCamera = {Min = LP.CameraMinZoomDistance, Max = LP.CameraMaxZoomDistance, FOV = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70}

local function make(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function corner(obj, radius)
    make("UICorner", obj, {CornerRadius = UDim.new(0, radius or 9)})
end
local function stroke(obj, color, thickness)
    return make("UIStroke", obj, {Color = color or C.line, Thickness = thickness or 1, Transparency = 0.12})
end
local function label(parent, text, size, pos, fontSize, color)
    return make("TextLabel", parent, {BackgroundTransparency = 1, Size = size, Position = pos, Text = text,
        TextColor3 = color or C.white, Font = Enum.Font.Gotham, TextSize = fontSize or 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true})
end
local function button(parent, text, size, pos, callback)
    local b = make("TextButton", parent, {Size = size, Position = pos, BackgroundColor3 = C.card,
        Text = text, TextColor3 = C.white, Font = Enum.Font.GothamMedium, TextSize = 11,
        AutoButtonColor = false, BorderSizePixel = 0})
    corner(b, 8); stroke(b, C.line, 1)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = C.hover}):Play() end)
    b.MouseLeave:Connect(function() if b.Parent then TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = C.card}):Play() end end)
    b.Activated:Connect(callback or function() end)
    return b
end
local function card(parent, title, height)
    local f = make("Frame", parent, {Size = UDim2.new(1, -4, 0, height), BackgroundColor3 = C.panel, BorderSizePixel = 0})
    corner(f, 11); stroke(f, C.line, 1)
    label(f, title, UDim2.new(1, -20, 0, 25), UDim2.fromOffset(12, 4), 12, C.bright)
    return f
end
local function textBox(parent, initial, size, pos, placeholder)
    local t = make("TextBox", parent, {Size = size, Position = pos, BackgroundColor3 = C.card,
        Text = initial or "", PlaceholderText = placeholder or "Değer gir", PlaceholderColor3 = C.muted,
        TextColor3 = C.white, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
        BorderSizePixel = 0})
    corner(t, 7); stroke(t, C.line, 1)
    return t
end
local function getCharacter()
    local ch = LP.Character
    if not ch then return nil, nil, nil end
    return ch, ch:FindFirstChildOfClass("Humanoid"), ch:FindFirstChild("HumanoidRootPart")
end
local function notify(text)
    status.Text = text
end
local function applySpeed(n)
    local _, hum = getCharacter()
    if hum and n then hum.WalkSpeed = math.clamp(n, 0, 60); speedBox.Text = tostring(hum.WalkSpeed); notify("Yürüme hızı güncellendi.") end
end
local function applyJump(n)
    local _, hum = getCharacter()
    if hum and n then hum.UseJumpPower = true; hum.JumpPower = math.clamp(n, 0, 100); jumpBox.Text = tostring(hum.JumpPower); notify("Zıplama gücü güncellendi.") end
end

local gui = make("ScreenGui", PG, {Name = "QuilTabCharacter", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 60, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
local main = make("Frame", gui, {Name = "Main", Size = UDim2.new(.92, 0, .84, 0), Position = UDim2.new(.04, 0, .08, 0), BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true})
corner(main, 16); stroke(main, C.red, 2)
make("UISizeConstraint", main, {MinSize = Vector2.new(310, 400), MaxSize = Vector2.new(760, 850)})
local header = make("Frame", main, {Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = C.panel, BorderSizePixel = 0})
local logo = make("Frame", header, {Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(12, 12), BackgroundColor3 = C.hover, BorderSizePixel = 0})
corner(logo, 12); stroke(logo, C.bright, 1)
local q = label(logo, "Q", UDim2.fromScale(1, 1), UDim2.new(), 22, C.bright); q.TextXAlignment = Enum.TextXAlignment.Center
label(header, "QuilTab", UDim2.new(.65, 0, 0, 28), UDim2.fromOffset(62, 8), 21, C.white)
label(header, "CHARACTER CONTROL CENTER", UDim2.new(.72, 0, 0, 18), UDim2.fromOffset(64, 35), 9, C.bright)
local closeBtn = button(header, "×", UDim2.fromOffset(30, 30), UDim2.new(1, -40, 0, 17), function() gui:Destroy() end)
closeBtn.TextSize = 20
local restoreBtn = button(gui, "Q", UDim2.fromOffset(48, 48), UDim2.new(0, 14, .55, 0), function() main.Visible = not main.Visible end)
restoreBtn.Visible = false; restoreBtn.BackgroundColor3 = C.bg; stroke(restoreBtn, C.bright, 2)

local scroll = make("ScrollingFrame", main, {Name = "Content", Size = UDim2.new(1, -16, 1, -76), Position = UDim2.fromOffset(8, 70), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = C.bright, CanvasSize = UDim2.new()})
local list = make("UIListLayout", scroll, {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 12) end)

local statusCard = card(scroll, "CANLI KARAKTER DURUMU", 112)
status = label(statusCard, "Karakter hazırlanıyor...", UDim2.new(1, -24, 0, 76), UDim2.fromOffset(12, 31), 11, C.muted)

local moveCard = card(scroll, "HAREKET AYARLARI", 150)
label(moveCard, "Yürüme hızı", UDim2.new(.45, 0, 0, 22), UDim2.fromOffset(12, 33), 11, C.muted)
speedBox = textBox(moveCard, "16", UDim2.new(.28, 0, 0, 30), UDim2.new(.44, 0, 0, 30))
button(moveCard, "UYGULA", UDim2.new(.23, 0, 0, 30), UDim2.new(.74, 0, 0, 30), function() applySpeed(tonumber(speedBox.Text)) end)
label(moveCard, "Zıplama gücü", UDim2.new(.45, 0, 0, 22), UDim2.fromOffset(12, 73), 11, C.muted)
jumpBox = textBox(moveCard, "50", UDim2.new(.28, 0, 0, 30), UDim2.new(.44, 0, 0, 70))
button(moveCard, "UYGULA", UDim2.new(.23, 0, 0, 30), UDim2.new(.74, 0, 0, 70), function() applyJump(tonumber(jumpBox.Text)) end)

local profileCard = card(scroll, "HAREKET PROFİLLERİ", 88)
button(profileCard, "NORMAL", UDim2.new(.31, 0, 0, 34), UDim2.new(.025, 0, 0, 42), function() applySpeed(16); applyJump(50) end)
button(profileCard, "ÇEVİK", UDim2.new(.31, 0, 0, 34), UDim2.new(.345, 0, 0, 42), function() applySpeed(22); applyJump(58) end)
button(profileCard, "AĞIR", UDim2.new(.31, 0, 0, 34), UDim2.new(.665, 0, 0, 42), function() applySpeed(10); applyJump(35) end)

local advancedCard = card(scroll, "GELİŞMİŞ KONTROLLER", 154)
local function toggleRow(parent, y, title, initial, callback)
    label(parent, title, UDim2.new(1, -80, 0, 28), UDim2.fromOffset(12, y), 11, C.white)
    local b
    b = button(parent, initial and "AÇIK" or "KAPALI", UDim2.fromOffset(64, 27), UDim2.new(1, -76, 0, y), function()
        initial = not initial; b.Text = initial and "AÇIK" or "KAPALI"; b.BackgroundColor3 = initial and C.hover or C.card; callback(initial)
    end)
    b.BackgroundColor3 = initial and C.hover or C.card
    return b
end
-- Create toggle controls after the helper is defined.
toggleRow(advancedCard, 35, "Sonsuz zıplama", false, function(v) infiniteJump = v; notify(v and "Sonsuz zıplama açıldı." or "Sonsuz zıplama kapandı.") end)
toggleRow(advancedCard, 68, "Otomatik koşma", false, function(v) autoRun = v; notify(v and "Otomatik koşma açıldı." or "Otomatik koşma kapandı.") end)
toggleRow(advancedCard, 101, "Havada yön desteği", false, function(v) airControl = v; notify(v and "Hava kontrolü açıldı." or "Hava kontrolü kapandı.") end)

local cameraCard = card(scroll, "KAMERA VE GÖRÜNÜM", 126)
label(cameraCard, "Kamera FOV", UDim2.new(.42, 0, 0, 24), UDim2.fromOffset(12, 35), 11, C.muted)
local fovBox = textBox(cameraCard, tostring(savedCamera.FOV), UDim2.new(.28, 0, 0, 30), UDim2.new(.43, 0, 0, 32))
button(cameraCard, "UYGULA", UDim2.new(.23, 0, 0, 30), UDim2.new(.74, 0, 0, 32), function()
    local n = tonumber(fovBox.Text); local cam = workspace.CurrentCamera
    if n and cam then cam.FieldOfView = math.clamp(n, 50, 100); notify("Kamera görüş açısı güncellendi.") else notify("FOV için 50–100 arasında sayı gir.") end
end)
button(cameraCard, "Yakınlaştır", UDim2.new(.46, 0, 0, 30), UDim2.fromOffset(12, 77), function() LP.CameraMinZoomDistance = 3; LP.CameraMaxZoomDistance = 12; notify("Kamera mesafesi 3–12 olarak ayarlandı.") end)
button(cameraCard, "Uzaklaştır", UDim2.new(.46, 0, 0, 30), UDim2.new(.52, 0, 0, 77), function() LP.CameraMinZoomDistance = 8; LP.CameraMaxZoomDistance = 24; notify("Kamera mesafesi 8–24 olarak ayarlandı.") end)

local markCard = card(scroll, "KOORDİNAT İŞARETLERİ", 126)
local markName = textBox(markCard, "İşaret 1", UDim2.new(.57, 0, 0, 30), UDim2.fromOffset(12, 38), "İşaret adı")
button(markCard, "KAYDET", UDim2.new(.30, 0, 0, 30), UDim2.new(.67, 0, 0, 38), function()
    local _, _, root = getCharacter()
    if not root then notify("Karakter bulunamadı."); return end
    local name = markName.Text ~= "" and markName.Text or ("İşaret " .. (#bookmarks + 1))
    bookmarks[name] = root.Position
    notify(string.format("%s kaydedildi: %.1f, %.1f, %.1f", name, root.Position.X, root.Position.Y, root.Position.Z))
end)
local markReadout = label(markCard, "Henüz işaret yok.", UDim2.new(1, -24, 0, 42), UDim2.fromOffset(12, 76), 10, C.muted)
button(markCard, "İŞARETLERİ LİSTELE", UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 93), function()
    local names = {}; for name, pos in pairs(bookmarks) do table.insert(names, string.format("%s (%.0f, %.0f, %.0f)", name, pos.X, pos.Y, pos.Z)) end
    table.sort(names); markReadout.Text = #names > 0 and table.concat(names, "\n") or "Henüz işaret yok."
end)

local resetCard = card(scroll, "GÜVENLİ SIFIRLAMA", 78)
button(resetCard, "HAREKETİ SIFIRLA", UDim2.new(.48, 0, 0, 34), UDim2.fromOffset(12, 36), function() applySpeed(defaultSpeed); applyJump(defaultJump); infiniteJump = false; autoRun = false; airControl = false; notify("Hareket ayarları varsayılana döndürüldü.") end)
button(resetCard, "KAMERA SIFIRLA", UDim2.new(.44, 0, 0, 34), UDim2.new(.53, 0, 0, 36), function()
    LP.CameraMinZoomDistance = savedCamera.Min; LP.CameraMaxZoomDistance = savedCamera.Max
    local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = savedCamera.FOV end
    fovBox.Text = tostring(savedCamera.FOV); notify("Kamera ayarları sıfırlandı.")
end)

local commandCard = card(scroll, "KOMUT KONSOLU", 114)
local cmdBox = textBox(commandCard, "", UDim2.new(1, -24, 0, 30), UDim2.fromOffset(12, 34), "help / speed 20 / jump 55 / coords / mark / reset")
local cmdOutput = label(commandCard, "Komut bekleniyor. help yaz.", UDim2.new(1, -24, 0, 35), UDim2.fromOffset(12, 70), 10, C.green)
local function execute(raw)
    local args = string.split(string.lower(raw), " ")
    local cmd, n = args[1] or "", tonumber(args[2])
    local _, hum, root = getCharacter()
    if cmd == "help" then cmdOutput.Text = "help | speed 20 | jump 55 | coords | mark | sit | stand | reset | stats"
    elseif cmd == "speed" and n then applySpeed(n); cmdOutput.Text = "Hız ayarlandı: " .. tostring(math.clamp(n, 0, 60))
    elseif cmd == "jump" and n then applyJump(n); cmdOutput.Text = "Zıplama ayarlandı: " .. tostring(math.clamp(n, 0, 100))
    elseif cmd == "coords" and root then cmdOutput.Text = string.format("X %.1f | Y %.1f | Z %.1f", root.Position.X, root.Position.Y, root.Position.Z)
    elseif cmd == "mark" and root then local name = "Komut İşareti " .. (#bookmarks + 1); bookmarks[name] = root.Position; cmdOutput.Text = name .. " kaydedildi."
    elseif cmd == "sit" and hum then hum.Sit = true; cmdOutput.Text = "Oturma istendi."
    elseif cmd == "stand" and hum then hum.Sit = false; cmdOutput.Text = "Ayağa kalkıldı."
    elseif cmd == "reset" and hum then applySpeed(defaultSpeed); applyJump(defaultJump); cmdOutput.Text = "Hareket varsayılanları yüklendi."
    elseif cmd == "stats" then cmdOutput.Text = string.format("Zıplama: %d | Havada: %.1fs | Mesafe: %.1f studs", jumpCount, airTime, distanceTravelled)
    else cmdOutput.Text = "Komut tanınmadı. help yaz." end
end
button(commandCard, "ÇALIŞTIR", UDim2.new(1, -24, 0, 27), UDim2.fromOffset(12, 83), function() if cmdBox.Text ~= "" then execute(cmdBox.Text) end end)
cmdBox.FocusLost:Connect(function(enter) if enter and cmdBox.Text ~= "" then execute(cmdBox.Text) end end)

-- Dragging (mouse and touch)
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then main.Visible = not main.Visible; restoreBtn.Visible = not main.Visible end
end)
UIS.JumpRequest:Connect(function()
    if not infiniteJump then return end
    local _, hum = getCharacter(); if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local stateConnection
local function hookCharacter(char)
    if stateConnection then stateConnection:Disconnect() end
    local hum = char:WaitForChild("Humanoid", 8)
    local root = char:WaitForChild("HumanoidRootPart", 8)
    if not hum or not root then return end
    lastPosition = root.Position
    stateConnection = hum.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping then jumpCount += 1 end
        if newState == Enum.HumanoidStateType.Freefall then lastAirStart = os.clock(); falling = true; fallDistance = 0 end
        if newState == Enum.HumanoidStateType.Landed then falling = false; lastAirStart = nil end
    end)
end
LP.CharacterAdded:Connect(hookCharacter)
if LP.Character then task.spawn(hookCharacter, LP.Character) end

local elapsed, fpsFrames, fpsElapsed = 0, 0, 0
RunService.RenderStepped:Connect(function(dt)
    if not alive or not gui.Parent then return end
    elapsed += dt; fpsFrames += 1; fpsElapsed += dt
    local _, hum, root = getCharacter()
    if hum and root then
        if lastPosition then distanceTravelled += (root.Position - lastPosition).Magnitude end
        lastPosition = root.Position
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            falling = true
            if lastAirStart then airTime += dt end
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char}
            local ray = Workspace:Raycast(root.Position, Vector3.new(0, -500, 0), rayParams)
            if ray then fallDistance = (root.Position - ray.Position).Magnitude else fallDistance = 500 end
        end
        if autoRun and hum.MoveDirection.Magnitude > 0 then hum:Move(hum.MoveDirection, true) end
        if airControl and hum:GetState() == Enum.HumanoidStateType.Freefall and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * hum.WalkSpeed, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * hum.WalkSpeed)
        end
    end
    if elapsed >= .25 then
        elapsed = 0
        if hum and root then
            status.Text = string.format("Can: %.0f / %.0f\nHız: %.1f | Zıplama: %.1f\nKonum: %.1f, %.1f, %.1f\nDüşüş: %s | Yere mesafe: %.1f studs\nZıplama: %d | Havada: %.1fs | Yol: %.1f studs",
                hum.Health, hum.MaxHealth, hum.WalkSpeed, hum.JumpPower,
                root.Position.X, root.Position.Y, root.Position.Z,
                falling and "EVET" or "Hayır", fallDistance, jumpCount, airTime, distanceTravelled)
        else status.Text = "Karakter yükleniyor..." end
    end
end)

gui.Destroying:Connect(function()
    alive = false
    if stateConnection then stateConnection:Disconnect() end
end)

print("QuilTab Character Control Center loaded. Use only in your own Roblox experience.")
