--========================================================
-- QUILTAB HUB | NEON PURPLE EDITION
-- Roblox Luau | LocalScript
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local old = PG:FindFirstChild("QuilTab")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(13, 12, 22),
    panel = Color3.fromRGB(20, 19, 32),
    card = Color3.fromRGB(26, 25, 42),
    hover = Color3.fromRGB(42, 30, 62),
    purple = Color3.fromRGB(176, 91, 255),
    bright = Color3.fromRGB(207, 139, 255),
    white = Color3.fromRGB(246, 243, 255),
    muted = Color3.fromRGB(164, 158, 184),
    green = Color3.fromRGB(105, 238, 153),
    red = Color3.fromRGB(255, 100, 125),
    line = Color3.fromRGB(58, 49, 77)
}

local selectedPlayer
local previousPosition
local savedPosition
local infiniteJump = false
local espEnabled = false
local playerRows = {}
local espTags = {}
local alive = true
local fps = 0
local frameCount = 0
local frameTime = 0
local refreshClock = 0

local function make(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    make("UICorner", obj, {CornerRadius = UDim.new(0, radius or 10)})
end

local function stroke(obj, color, thickness, transparency)
    return make("UIStroke", obj, {
        Color = color or C.line,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    })
end

local function padding(obj, left, right, top, bottom)
    make("UIPadding", obj, {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0)
    })
end

local function label(parent, text, size, pos, fontSize, color)
    return make("TextLabel", parent, {
        BackgroundTransparency = 1,
        Size = size,
        Position = pos,
        Text = text,
        TextColor3 = color or C.white,
        Font = Enum.Font.Gotham,
        TextSize = fontSize or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true
    })
end

local function newButton(parent, text, size, pos, callback)
    local b = make("TextButton", parent, {
        Size = size,
        Position = pos,
        BackgroundColor3 = C.card,
        Text = text,
        TextColor3 = C.white,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    corner(b, 8)
    stroke(b, C.line, 1)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = C.hover
        }):Play()
    end)

    b.MouseLeave:Connect(function()
        if b.Parent then
            TweenService:Create(b, TweenInfo.new(0.12), {
                BackgroundColor3 = C.card
            }):Play()
        end
    end)

    b.Activated:Connect(callback or function() end)
    return b
end

local function newCard(parent, title, height)
    local f = make("Frame", parent, {
        Size = UDim2.new(1, -2, 0, height),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0
    })
    corner(f, 11)
    stroke(f, C.line, 1)
    label(f, title, UDim2.new(1, -20, 0, 27),
        UDim2.fromOffset(12, 5), 13, C.bright)
    return f
end

local function makeToggle(parent, title, callback, initial)
    local row = make("Frame", parent, {
        Size = UDim2.new(1, -2, 0, 43),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0
    })
    corner(row, 8)
    label(row, title, UDim2.new(1, -68, 1, 0),
        UDim2.fromOffset(12, 0), 12, C.white)

    local track = make("TextButton", row, {
        Size = UDim2.fromOffset(43, 23),
        Position = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = initial and C.purple or C.line,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    corner(track, 20)

    local knob = make("Frame", track, {
        Size = UDim2.fromOffset(17, 17),
        Position = initial and UDim2.new(1, -20, 0.5, -8)
            or UDim2.fromOffset(3, 3),
        BackgroundColor3 = C.white,
        BorderSizePixel = 0
    })
    corner(knob, 20)

    local enabled = initial or false

    local function setEnabled(value)
        enabled = value
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = enabled and C.purple or C.line
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = enabled and UDim2.new(1, -20, 0.5, -8)
                or UDim2.fromOffset(3, 3)
        }):Play()
        if callback then callback(enabled) end
    end

    track.Activated:Connect(function()
        setEnabled(not enabled)
    end)

    return {
        Set = setEnabled,
        Get = function() return enabled end
    }
end

local gui = make("ScreenGui", PG, {
    Name = "QuilTab",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 50,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local main = make("Frame", gui, {
    Name = "Main",
    Size = UDim2.new(0.90, 0, 0.82, 0),
    Position = UDim2.new(0.05, 0, 0.09, 0),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true
})
corner(main, 18)
stroke(main, C.purple, 2)

make("UISizeConstraint", main, {
    MinSize = Vector2.new(310, 360),
    MaxSize = Vector2.new(1100, 760)
})

local header = make("Frame", main, {
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0
})

local logo = make("Frame", header, {
    Size = UDim2.fromOffset(45, 45),
    Position = UDim2.fromOffset(14, 15),
    BackgroundColor3 = C.hover,
    BorderSizePixel = 0
})
corner(logo, 13)
stroke(logo, C.purple, 1)
label(logo, "Q", UDim2.fromScale(1, 1), UDim2.new(), 24, C.bright).TextXAlignment = Enum.TextXAlignment.Center

label(header, "QuilTab", UDim2.new(0.44, 0, 0, 32),
    UDim2.fromOffset(70, 10), 23, C.white)
label(header, "SMART PLAYER HUB", UDim2.new(0.45, 0, 0, 19),
    UDim2.fromOffset(72, 42), 10, C.purple)
label(header, "● LIVE", UDim2.new(0, 66, 0, 22),
    UDim2.new(1, -106, 0, 12), 11, C.green)
label(header, "PC / MOBILE", UDim2.new(0, 95, 0, 20),
    UDim2.new(1, -135, 0, 39), 9, C.muted)

local restore
local close = newButton(header, "×", UDim2.fromOffset(30, 30),
    UDim2.new(1, -39, 0, 22), function()
        main.Visible = false
        restore.Visible = true
    end)
close.BackgroundColor3 = Color3.fromRGB(75, 31, 52)
close.TextSize = 22

restore = newButton(gui, "Q", UDim2.fromOffset(48, 48),
    UDim2.new(1, -60, 0.70, 0), function()
        main.Visible = true
        restore.Visible = false
    end)
restore.Visible = false
restore.BackgroundColor3 = C.purple
restore.TextSize = 22
corner(restore, 24)

local sidebar = make("Frame", main, {
    Position = UDim2.fromOffset(10, 86),
    Size = UDim2.new(0, 142, 1, -98),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0
})
corner(sidebar, 12)
stroke(sidebar, C.line, 1)

local sideScroll = make("ScrollingFrame", sidebar, {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.purple,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
})
padding(sideScroll, 7, 7, 10, 10)
make("UIListLayout", sideScroll, {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local area = make("Frame", main, {
    Position = UDim2.new(0, 162, 0, 86),
    Size = UDim2.new(1, -172, 1, -98),
    BackgroundTransparency = 1,
    ClipsDescendants = true
})

local pages = {}
local navButtons = {}
local pageNames = {
    {"⌂", "Ana Sayfa"}, {"♙", "Oyuncular"},
    {"⚙", "Karakter"}, {"⌖", "Teleport"},
    {"◎", "ESP"}, {"◇", "Dünya"},
    {">_", "Komutlar"}, {"⚙", "Ayarlar"}
}

local function newPage(name)
    local p = make("ScrollingFrame", area, {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.purple,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false
    })
    padding(p, 1, 4, 1, 8)
    make("UIListLayout", p, {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    pages[name] = p
    return p
end

local function showPage(name)
    for pageName, p in pairs(pages) do
        p.Visible = pageName == name
    end
    for pageName, b in pairs(navButtons) do
        local chosen = pageName == name
        b.BackgroundColor3 = chosen and C.hover or C.panel
        b.TextColor3 = chosen and C.bright or C.white
        local s = b:FindFirstChildOfClass("UIStroke")
        if s then s.Color = chosen and C.purple or C.line end
    end
end

for i, entry in ipairs(pageNames) do
    local icon, name = entry[1], entry[2]
    local b = newButton(sideScroll, icon .. "   " .. name,
        UDim2.new(1, 0, 0, 39), UDim2.new(), function()
            showPage(name)
        end)
    b.Name = name
    b.LayoutOrder = i
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextSize = 11
    navButtons[name] = b
end

local home = newPage("Ana Sayfa")
local people = newPage("Oyuncular")
local character = newPage("Karakter")
local teleport = newPage("Teleport")
local espPage = newPage("ESP")
local worldPage = newPage("Dünya")
local commandPage = newPage("Komutlar")
local settings = newPage("Ayarlar")

-- ANA SAYFA
local welcome = newCard(home, "Kontrol Paneli", 82)
label(welcome, "QuilTab HUB  •  Neon Edition",
    UDim2.new(1, -24, 0, 24), UDim2.fromOffset(12, 33), 15, C.white)
label(welcome, "Oyun ve karakter bilgileri canlı güncellenir.",
    UDim2.new(1, -24, 0, 18), UDim2.fromOffset(12, 56), 10, C.muted)

local gameCard = newCard(home, "Oyun Bilgileri", 105)
label(gameCard, "Oyun: " .. game.Name,
    UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 32), 11, C.muted)
label(gameCard, "PlaceId: " .. tostring(game.PlaceId),
    UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 54), 11, C.muted)
label(gameCard, "Kullanıcı: " .. LP.Name,
    UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 76), 11, C.muted)

local statsCard = newCard(home, "Canlı İstatistikler", 105)
local statsText = label(statsCard, "Oyuncular: --\nFPS: --\nPing: --",
    UDim2.new(1, -24, 0, 69), UDim2.fromOffset(12, 31), 12, C.green)

local charCard = newCard(home, "Karakter Durumu", 112)
local charText = label(charCard, "Karakter yükleniyor...",
    UDim2.new(1, -24, 0, 76), UDim2.fromOffset(12, 31), 11, C.muted)

-- OYUNCULAR
local search = make("TextBox", people, {
    Size = UDim2.new(1, -2, 0, 38),
    BackgroundColor3 = C.panel,
    Text = "",
    PlaceholderText = "Oyuncu ara...",
    PlaceholderColor3 = C.muted,
    TextColor3 = C.white,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    ClearTextOnFocus = false,
    BorderSizePixel = 0
})
corner(search, 9)
stroke(search, C.line, 1)

local selectedCard = newCard(people, "Seçili Oyuncu", 154)
local selectedInfo = label(selectedCard, "Listeden bir oyuncu seç.",
    UDim2.new(1, -24, 0, 116), UDim2.fromOffset(12, 31), 11, C.muted)
newCard(people, "Sunucudaki Oyuncular", 37)

local rowsHolder = make("Frame", people, {
    Size = UDim2.new(1, -2, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y
})
make("UIListLayout", rowsHolder, {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.Name
})

local function getCharacterInfo(p)
    local ch = p.Character
    if not ch then return "Karakter yüklenmedi." end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local root = ch:FindFirstChild("HumanoidRootPart")
    local lines = {
        "Kullanıcı: @" .. p.Name,
        "Görünen ad: " .. p.DisplayName,
        "UserId: " .. p.UserId,
        "Takım: " .. (p.Team and p.Team.Name or "Yok")
    }
    if hum then
        table.insert(lines, string.format("Can: %.0f / %.0f", hum.Health, hum.MaxHealth))
        table.insert(lines, "Durum: " .. hum:GetState().Name)
        table.insert(lines, "Hız: " .. string.format("%.1f", hum.WalkSpeed))
    end
    if root then
        local pos = root.Position
        table.insert(lines, string.format("Konum: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            table.insert(lines, string.format("Mesafe: %.1f studs", (myRoot.Position - pos).Magnitude))
        end
    end
    return table.concat(lines, "\n")
end

local function updateSelected()
    if selectedPlayer and selectedPlayer.Parent == Players then
        selectedInfo.Text = getCharacterInfo(selectedPlayer)
    else
        selectedInfo.Text = "Listeden bir oyuncu seç."
    end
end

local refreshPlayers
refreshPlayers = function()
    for _, row in pairs(playerRows) do row:Destroy() end
    table.clear(playerRows)

    local query = string.lower(search.Text)
    local all = Players:GetPlayers()
    table.sort(all, function(a, b) return a.Name:lower() < b.Name:lower() end)

    for _, p in ipairs(all) do
        if string.find(p.Name:lower(), query, 1, true)
        or string.find(p.DisplayName:lower(), query, 1, true) then
            local row = newButton(rowsHolder, "",
                UDim2.new(1, 0, 0, 61), UDim2.new(), function()
                    selectedPlayer = p
                    refreshPlayers()
                    updateSelected()
                end)
            row.Name = p.Name
            row.BackgroundColor3 = p == selectedPlayer and C.hover or C.panel
            playerRows[p] = row

            local avatar = make("ImageLabel", row, {
                Size = UDim2.fromOffset(43, 43),
                Position = UDim2.fromOffset(8, 9),
                BackgroundColor3 = C.hover,
                Image = "",
                BorderSizePixel = 0
            })
            corner(avatar, 22)

            task.spawn(function()
                local ok, image = pcall(function()
                    return Players:GetUserThumbnailAsync(p.UserId,
                        Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if ok and avatar.Parent then avatar.Image = image end
            end)

            label(row, p.DisplayName, UDim2.new(1, -65, 0, 22),
                UDim2.fromOffset(60, 8), 12, C.white)
            label(row, "@" .. p.Name, UDim2.new(1, -65, 0, 19),
                UDim2.fromOffset(60, 30), 10, C.muted)
        end
    end
end

search:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)
Players.PlayerAdded:Connect(function() refreshPlayers() end)
Players.PlayerRemoving:Connect(function(p)
    if selectedPlayer == p then selectedPlayer = nil end
    refreshPlayers()
    updateSelected()
end)

-- KARAKTER
local speedCard = newCard(character, "Yürüme Hızı", 83)
local speedBox = make("TextBox", speedCard, {
    Size = UDim2.new(0.57, 0, 0, 32),
    Position = UDim2.fromOffset(10, 40),
    BackgroundColor3 = C.card, Text = "16",
    TextColor3 = C.white, Font = Enum.Font.Gotham,
    TextSize = 12, ClearTextOnFocus = false, BorderSizePixel = 0
})
corner(speedBox, 7)
newButton(speedCard, "Uygula", UDim2.new(0.32, 0, 0, 32),
    UDim2.new(0.65, 0, 0, 40), function()
        local n = tonumber(speedBox.Text)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if n and hum then hum.WalkSpeed = math.clamp(n, 0, 100) end
    end)

local jumpCard = newCard(character, "Zıplama Gücü", 83)
local jumpBox = make("TextBox", jumpCard, {
    Size = UDim2.new(0.57, 0, 0, 32),
    Position = UDim2.fromOffset(10, 40),
    BackgroundColor3 = C.card, Text = "50",
    TextColor3 = C.white, Font = Enum.Font.Gotham,
    TextSize = 12, ClearTextOnFocus = false, BorderSizePixel = 0
})
corner(jumpBox, 7)
newButton(jumpCard, "Uygula", UDim2.new(0.32, 0, 0, 32),
    UDim2.new(0.65, 0, 0, 40), function()
        local n = tonumber(jumpBox.Text)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if n and hum then
            hum.UseJumpPower = true
            hum.JumpPower = math.clamp(n, 0, 150)
        end
    end)

makeToggle(character, "Sonsuz Zıplama", function(value)
    infiniteJump = value
end, false)

UIS.JumpRequest:Connect(function()
    if not infiniteJump then return end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- TELEPORT
local tpInfo = newCard(teleport, "Teleport Merkezi", 73)
label(tpInfo, "Oyuncular sekmesinden bir oyuncu seç.",
    UDim2.new(1, -24, 0, 26), UDim2.fromOffset(12, 35), 11, C.muted)
local targetLabel = label(teleport, "Hedef: Seçilmedi",
    UDim2.new(1, -4, 0, 28), UDim2.new(), 12, C.bright)

local function getRoot()
    local ch = LP.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function notify(text)
    targetLabel.Text = text
end

local saveCard = newCard(teleport, "Konum Kaydet", 82)
newButton(saveCard, "Mevcut Konumu Kaydet", UDim2.new(1, -20, 0, 34),
    UDim2.fromOffset(10, 39), function()
        local root = getRoot()
        if root then
            savedPosition = root.CFrame
            previousPosition = root.CFrame
            notify("Konum kaydedildi.")
        else
            notify("Karakter yüklenmedi.")
        end
    end)

local targetCard = newCard(teleport, "Oyuncuya Işınlan", 91)
newButton(targetCard, "Seçili Oyuncuya Git", UDim2.new(1, -20, 0, 36),
    UDim2.fromOffset(10, 42), function()
        local root = getRoot()
        local targetRoot = selectedPlayer and selectedPlayer.Character
            and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not selectedPlayer or not targetRoot then
            notify("Önce geçerli bir oyuncu seç.")
            return
        end
        if not root then notify("Karakter yüklenmedi.") return end
        if selectedPlayer == LP then notify("Kendine ışınlanamazsın.") return end
        previousPosition = root.CFrame
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
        notify("Işınlanma istendi: " .. selectedPlayer.Name)
    end)

local returnCard = newCard(teleport, "Konuma Dön", 128)
newButton(returnCard, "Önceki Konuma Dön", UDim2.new(1, -20, 0, 34),
    UDim2.fromOffset(10, 40), function()
        local root = getRoot()
        if root and previousPosition then
            root.CFrame = previousPosition
            notify("Önceki konuma dönüldü.")
        else
            notify("Önceki konum kayıtlı değil.")
        end
    end)
newButton(returnCard, "Kaydedilen Konuma Git", UDim2.new(1, -20, 0, 34),
    UDim2.fromOffset(10, 82), function()
        local root = getRoot()
        if root and savedPosition then
            previousPosition = root.CFrame
            root.CFrame = savedPosition
            notify("Kaydedilen konuma dönüldü.")
        else
            notify("Önce bir konum kaydet.")
        end
    end)

-- ESP
local espCard = newCard(espPage, "Oyuncu Etiketleri", 55)
local function clearTags()
    for p, tag in pairs(espTags) do
        if tag then tag:Destroy() end
        espTags[p] = nil
    end
end

local function refreshTags()
    clearTags()
    if not espEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local tag = make("BillboardGui", head, {
                    Name = "QuilTabPlayerTag",
                    Size = UDim2.fromOffset(180, 34),
                    StudsOffset = Vector3.new(0, 2.8, 0),
                    AlwaysOnTop = true
                })
                make("TextLabel", tag, {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = p.DisplayName .. "  @" .. p.Name,
                    TextColor3 = C.bright,
                    TextStrokeTransparency = 0.25,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12
                })
                espTags[p] = tag
            end
        end
    end
end

makeToggle(espCard, "Oyuncu ESP", function(value)
    espEnabled = value
    refreshTags()
end, false)

local espNote = newCard(espPage, "Bilgi", 67)
label(espNote, "Etiketler istemci tarafında oluşturulur.",
    UDim2.new(1, -24, 0, 30), UDim2.fromOffset(12, 32), 10, C.muted)

-- DÜNYA
local worldCard = newCard(worldPage, "Dünya Bilgileri", 124)
local worldText = label(worldCard, "Taranmayı bekliyor...",
    UDim2.new(1, -24, 0, 83), UDim2.fromOffset(12, 32), 11, C.muted)

local function inspectWorld()
    local counts, total = {}, 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        total += 1
        counts[obj.ClassName] = (counts[obj.ClassName] or 0) + 1
    end
    worldText.Text = table.concat({
        "Toplam nesne: " .. total,
        "Part: " .. (counts.Part or 0),
        "MeshPart: " .. (counts.MeshPart or 0),
        "Model: " .. (counts.Model or 0),
        "Script: " .. ((counts.Script or 0) + (counts.LocalScript or 0))
    }, "\n")
end

newButton(worldPage, "Dünyayı Yeniden Tara",
    UDim2.new(1, -2, 0, 36), UDim2.new(), inspectWorld)

-- KOMUTLAR
local cmdBox = make("TextBox", commandPage, {
    Size = UDim2.new(1, -2, 0, 39),
    BackgroundColor3 = C.panel,
    Text = "",
    PlaceholderText = "help / reset / speed 24 / jump 50",
    PlaceholderColor3 = C.muted,
    TextColor3 = C.white,
    Font = Enum.Font.Code,
    TextSize = 11,
    ClearTextOnFocus = false,
    BorderSizePixel = 0
})
corner(cmdBox, 9)
stroke(cmdBox, C.line, 1)

local cmdOutput = make("TextLabel", commandPage, {
    Size = UDim2.new(1, -2, 0, 120),
    BackgroundColor3 = C.panel,
    Text = "QuilTab konsolu hazır.\nhelp yaz.",
    TextColor3 = C.green,
    Font = Enum.Font.Code,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    BorderSizePixel = 0
})
corner(cmdOutput, 9)
padding(cmdOutput, 10, 10, 10, 10)

local function execute(raw)
    local a = string.split(raw, " ")
    local cmd = string.lower(a[1] or "")

    if cmd == "help" then
        cmdOutput.Text = "Komutlar:\nhelp\nreset\nspeed 24\njump 50\nplayers\nclear"
    elseif cmd == "clear" then
        cmdOutput.Text = "Konsol hazır."
    elseif cmd == "reset" then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 cmdOutput.Text = "Sıfırlama istendi." end
    elseif cmd == "speed" then
        local n = tonumber(a[2])
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if n and hum then
            hum.WalkSpeed = math.clamp(n, 0, 100)
            cmdOutput.Text = "Hız: " .. hum.WalkSpeed
        else
            cmdOutput.Text = "Kullanım: speed 24"
        end
    elseif cmd == "jump" then
        local n = tonumber(a[2])
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if n and hum then
            hum.UseJumpPower = true
            hum.JumpPower = math.clamp(n, 0, 150)
            cmdOutput.Text = "Zıplama: " .. hum.JumpPower
        else
            cmdOutput.Text = "Kullanım: jump 50"
        end
    elseif cmd == "players" then
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
        cmdOutput.Text = table.concat(names, "\n")
    else
        cmdOutput.Text = "Bilinmeyen komut: " .. cmd
    end
end

newButton(commandPage, "Çalıştır", UDim2.new(1, -2, 0, 36),
    UDim2.new(), function()
        if cmdBox.Text ~= "" then
            execute(cmdBox.Text)
            cmdBox.Text = ""
        end
    end)

cmdBox.FocusLost:Connect(function(enter)
    if enter and cmdBox.Text ~= "" then
        execute(cmdBox.Text)
        cmdBox.Text = ""
    end
end)

-- AYARLAR
local windowCard = newCard(settings, "Pencere Ayarları", 95)
newButton(windowCard, "Küçült", UDim2.new(0.47, 0, 0, 34),
    UDim2.fromOffset(10, 43), function()
        main.Size = UDim2.new(0.75, 0, 0.70, 0)
        main.Position = UDim2.new(0.125, 0, 0.15, 0)
    end)
newButton(windowCard, "Varsayılan", UDim2.new(0.47, 0, 0, 34),
    UDim2.new(0.52, 0, 0, 43), function()
        main.Size = UDim2.new(0.90, 0, 0.82, 0)
        main.Position = UDim2.new(0.05, 0, 0.09, 0)
    end)

local keyCard = newCard(settings, "Kısayollar", 67)
label(keyCard, "RightControl: Arayüzü göster / gizle",
    UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 32), 11, C.muted)

-- SÜRÜKLEME
local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
        restore.Visible = not main.Visible
    end
end)

-- CANLI İSTATİSTİKLER
RunService.RenderStepped:Connect(function(dt)
    if not alive then return end
    frameCount += 1
    frameTime += dt
    refreshClock += dt

    if frameTime >= 1 then
        fps = math.floor(frameCount / frameTime)
        frameCount = 0
        frameTime = 0

        local pingText = "--"
        pcall(function()
            pingText = tostring(math.floor(
                Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            )) .. " ms"
        end)

        statsText.Text = string.format(
            "Oyuncular: %d\nFPS: %d\nPing: %s",
            #Players:GetPlayers(), fps, pingText
        )

        local ch = LP.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local root = ch and ch:FindFirstChild("HumanoidRootPart")

        if hum then
            charText.Text = string.format(
                "Can: %.0f / %.0f\nHız: %.1f\nZıplama: %.1f\nDurum: %s",
                hum.Health, hum.MaxHealth, hum.WalkSpeed,
                hum.JumpPower, hum:GetState().Name
            )
            if root then
                charText.Text ..= string.format(
                    "\nKonum: %.1f, %.1f, %.1f",
                    root.Position.X, root.Position.Y, root.Position.Z
                )
            end
        else
            charText.Text = "Karakter yükleniyor..."
        end
    end

    if refreshClock >= 1 then
        refreshClock = 0
        updateSelected()
        if espEnabled then refreshTags() end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshPlayers()
    updateSelected()
end)

gui.Destroying:Connect(function()
    alive = false
    clearTags()
end)

refreshPlayers()
inspectWorld()
showPage("Ana Sayfa")

print("QuilTab HUB | Neon Purple Edition loaded.")
