--============================================================
-- 🕌 Be Halal - Legendary Edition (All OFF by default)
--============================================================
local P = game:GetService("Players")
local S = game:GetService("SoundService")
local U = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local TweenS = game:GetService("TweenService")
local L = P.LocalPlayer

local CREATOR_NAME = "EZ_NOOB11220"

local Theme = {
    BG1 = Color3.fromRGB(14, 18, 24),
    BG2 = Color3.fromRGB(20, 26, 34),
    BG3 = Color3.fromRGB(26, 34, 44),
    Card = Color3.fromRGB(30, 40, 52),
    CardHi = Color3.fromRGB(38, 50, 64),
    Accent = Color3.fromRGB(72, 219, 138),
    Accent2 = Color3.fromRGB(46, 204, 190),
    Gold = Color3.fromRGB(255, 200, 87),
    Text = Color3.fromRGB(240, 244, 250),
    TextDim = Color3.fromRGB(150, 165, 185),
    Danger = Color3.fromRGB(232, 89, 89),
    DangerHi = Color3.fromRGB(255, 116, 116),
    Success = Color3.fromRGB(72, 219, 138),
    Info = Color3.fromRGB(85, 170, 255),
}

local W = {[L.Name] = true}
local B = {}
local CB = {}
local D = {}
-- ✅ كل شي طافي في البداية
local ST = {M = false, N = false, D = false, R = true}
local LANG = "ar"
local searchQuery = ""

local NC = {Skin = Color3.fromRGB(245, 205, 48), T = Color3.fromRGB(13, 105, 172), Lg = Color3.fromRGB(40, 127, 71)}
local CM = {
    Head = NC.Skin, LeftArm = NC.Skin, RightArm = NC.Skin, Torso = NC.T, LeftLeg = NC.Lg, RightLeg = NC.Lg,
    UpperTorso = NC.T, LowerTorso = NC.T, LeftUpperArm = NC.Skin, LeftLowerArm = NC.Skin, LeftHand = NC.Skin,
    RightUpperArm = NC.Skin, RightLowerArm = NC.Skin, RightHand = NC.Skin, LeftUpperLeg = NC.Lg, LeftLowerLeg = NC.Lg,
    LeftFoot = NC.Lg, RightUpperLeg = NC.Lg, RightLowerLeg = NC.Lg, RightFoot = NC.Lg
}

local function sf(f, ...)
    local ok, e = pcall(f, ...)
    if not ok then warn("BH:", e) end
end

local T = {
    ar = {
        title = "بي حلال", subtitle = "أدوات إسلامية للسيرفر",
        sectionAudio = "الأصوات", sectionVisual = "المظهر", sectionTools = "الأدوات",
        sectionPlayers = "اللاعبون", sectionLists = "القوائم",
        muteMusic = "كتم الموسيقى", noobSkin = "سكنات نوب", stopDance = "إيقاف الرقصات",
        suggest = "اقتراح لاعب", players = "اللاعبون", whitelist = "المسموحون",
        blocked = "المحجوبون", searchPH = "ابحث عن لاعب...", add = "إضافة",
        on = "مفعّل", off = "معطّل", noPlayers = "لا يوجد لاعبون",
        wl = "سماح", block = "حجب", empty = "فارغ", footer = "صُنع بإتقان",
    },
    en = {
        title = "Be Halal", subtitle = "Islamic server tools",
        sectionAudio = "Audio", sectionVisual = "Visual", sectionTools = "Tools",
        sectionPlayers = "Players", sectionLists = "Lists",
        muteMusic = "Mute Music", noobSkin = "Noob Skins", stopDance = "Stop Dances",
        suggest = "Suggest Player", players = "Players", whitelist = "Whitelisted",
        blocked = "Blocked", searchPH = "Search for player...", add = "Add",
        on = "Active", off = "Disabled", noPlayers = "No players found",
        wl = "Allow", block = "Block", empty = "Empty", footer = "Crafted with precision",
    }
}

local function isFriend(p)
    local ok, res = pcall(function() return L:IsFriendsWith(p.UserId) end)
    return ok and res == true
end

local function addFriend(p)
    if p == L then return end
    if isFriend(p) then W[p.Name] = true end
end

for _, p in ipairs(P:GetPlayers()) do addFriend(p) end
P.PlayerAdded:Connect(function(p) task.wait(1) addFriend(p) end)

--============================================================
-- 🔊 كتم الموسيقى
--============================================================
local savedVolumes = {}

local function isMusicSound(sound)
    if not sound:IsA("Sound") then return false end
    if sound.TimeLength and sound.TimeLength > 10 then return true end
    local n = string.lower(sound.Name)
    if n:find("music") or n:find("bgm") or n:find("song") or n:find("theme") then
        return true
    end
    local p = sound.Parent
    while p and p ~= game do
        local pn = string.lower(p.Name)
        if pn:find("music") or pn:find("bgm") or pn:find("song") then
            return true
        end
        p = p.Parent
    end
    return false
end

local function muteMusicInContainer(container)
    for _, sound in ipairs(container:GetDescendants()) do
        if sound:IsA("Sound") and isMusicSound(sound) then
            if savedVolumes[sound] == nil then
                savedVolumes[sound] = sound.Volume
            end
            pcall(function() sound.Volume = 0 end)
        end
    end
end

local function muteAllMusic()
    muteMusicInContainer(WS)
    muteMusicInContainer(S)
end

local function unmuteAllMusic()
    for s, v in pairs(savedVolumes) do
        if s and s.Parent and s:IsA("Sound") then
            pcall(function() s.Volume = v end)
        end
        savedVolumes[s] = nil
    end
end

WS.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Sound") and isMusicSound(descendant) then
        task.defer(function()
            if descendant.Parent and ST.M then
                if savedVolumes[descendant] == nil then
                    savedVolumes[descendant] = descendant.Volume
                end
                pcall(function() descendant.Volume = 0 end)
            end
        end)
    end
end)

S.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Sound") and isMusicSound(descendant) then
        task.defer(function()
            if descendant.Parent and ST.M then
                if savedVolumes[descendant] == nil then
                    savedVolumes[descendant] = descendant.Volume
                end
                pcall(function() descendant.Volume = 0 end)
            end
        end)
    end
end)

--============================================================
-- 👕 Noob Skin
--============================================================
local function tN(c, p)
    if not ST.R or not c or not c.Parent then return end
    if W[p.Name] or B[p.Name] or not ST.N then return end
    if not c:FindFirstChildOfClass("Humanoid") then return end
    if not CB[c] then CB[c] = {co = {}, sh = nil, pa = nil, gr = nil, ac = {}, fa = nil} end
    local b = CB[c]
    for _, i in ipairs(c:GetChildren()) do
        if i:IsA("Shirt") then
            if b.sh == nil then b.sh = i.ShirtTemplate end
            if i.ShirtTemplate ~= "" then i.ShirtTemplate = "" end
        elseif i:IsA("Pants") then
            if b.pa == nil then b.pa = i.PantsTemplate end
            if i.PantsTemplate ~= "" then i.PantsTemplate = "" end
        elseif i:IsA("ShirtGraphic") then
            if b.gr == nil then b.gr = i.Graphic end
            if i.Graphic ~= "" then i.Graphic = "" end
        elseif i:IsA("Accessory") or i:IsA("Hat") then
            local h = i:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then
                if b.ac[i] == nil then b.ac[i] = h.Transparency end
                h.Transparency = 1
            end
        end
    end
    local hd = c:FindFirstChild("Head")
    if hd then
        if b.fa == nil then
            local d = hd:FindFirstChildOfClass("Decal")
            if d then b.fa = {t = d.Texture, c = d.Color3, n = d.Name, tr = d.Transparency, f = d.Face}
            else b.fa = {no = true} end
        end
        for _, x in ipairs(hd:GetChildren()) do if x:IsA("Decal") then x:Destroy() end end
        local f = Instance.new("Decal")
        f.Name = "face"
        f.Texture = "rbxasset://textures/face.png"
        f.Face = Enum.NormalId.Front
        f.Parent = hd
    end
    for _, p2 in ipairs(c:GetChildren()) do
        if p2:IsA("BasePart") and CM[p2.Name] then
            if b.co[p2] == nil then b.co[p2] = p2.Color end
            p2.Color = CM[p2.Name]
            pcall(function() p2.BrickColor = BrickColor.new(CM[p2.Name]) end)
        end
    end
end

local function rA(c)
    if not c or not c.Parent then return end
    local b = CB[c]
    if not b then return end
    for p2, co in pairs(b.co) do
        if p2 and p2.Parent then
            pcall(function() p2.Color = co p2.BrickColor = BrickColor.new(co) end)
        end
    end
    local hd = c:FindFirstChild("Head")
    if hd and b.fa then
        for _, x in ipairs(hd:GetChildren()) do if x:IsA("Decal") then x:Destroy() end end
        if not b.fa.no then
            local f = Instance.new("Decal")
            f.Name = b.fa.n or "face"
            f.Texture = b.fa.t
            f.Color3 = b.fa.c
            f.Transparency = b.fa.tr or 0
            f.Face = b.fa.f or Enum.NormalId.Front
            f.Parent = hd
        end
    end
    for _, i in ipairs(c:GetChildren()) do
        if i:IsA("Shirt") and b.sh then i.ShirtTemplate = b.sh
        elseif i:IsA("Pants") and b.pa then i.PantsTemplate = b.pa
        elseif i:IsA("ShirtGraphic") and b.gr then i.Graphic = b.gr end
    end
    for a, tr in pairs(b.ac) do
        if a and a.Parent then
            local h = a:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then h.Transparency = tr end
        end
    end
    CB[c] = nil
end

local function hookCharForNoob(c, p)
    if W[p.Name] or B[p.Name] then return end
    if c:GetAttribute("BH_NoobHooked") then return end
    c:SetAttribute("BH_NoobHooked", true)
    c.DescendantAdded:Connect(function(child)
        if not ST.R or not ST.N then return end
        if W[p.Name] or B[p.Name] then return end
        if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic")
            or child:IsA("Accessory") or child:IsA("Hat") or child:IsA("CharacterMesh")
            or child:IsA("Decal") then
            task.defer(function()
                task.wait(0.05)
                if c.Parent and not W[p.Name] and not B[p.Name] and ST.N and ST.R then
                    sf(tN, c, p)
                end
            end)
        end
    end)
end

--============================================================
-- 💃 إيقاف الرقصات
--============================================================
local function isD(a)
    if not a then return false end
    local n = (a.Name or ""):lower()
    if n:find("dance") or n:find("emote") then return true end
    local id = tostring(a.AnimationId or "")
    return id:find("507771019") or id:find("507776043") or id:find("507777826") or id:find("507771013") ~= nil
end

local function sD(c, p)
    if W[p.Name] or B[p.Name] or D[c] then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    local a = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 5)
    if not a then return end
    D[c] = a.AnimationPlayed:Connect(function(t)
        if ST.R and ST.D and isD(t.Animation) then pcall(function() t:Stop(0) end) end
    end)
end

--============================================================
-- 🚫 إخفاء اللاعب
--============================================================
local function hC(c)
    if not c or not c.Parent then return end
    for _, i in ipairs(c:GetDescendants()) do
        if i:IsA("BasePart") or i:IsA("Decal") then
            if i:GetAttribute("BHO") == nil then i:SetAttribute("BHO", i.Transparency) end
            i.Transparency = 1
        elseif i:IsA("BillboardGui") or i:IsA("SurfaceGui") then
            i.Enabled = false
        end
    end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then
        h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        h.NameDisplayDistance = 0
        h.HealthDisplayDistance = 0
    end
end

local function sC(c)
    if not c or not c.Parent then return end
    for _, i in ipairs(c:GetDescendants()) do
        if i:IsA("BasePart") or i:IsA("Decal") then
            local o = i:GetAttribute("BHO")
            if o ~= nil then i.Transparency = o i:SetAttribute("BHO", nil) end
        elseif i:IsA("BillboardGui") or i:IsA("SurfaceGui") then
            i.Enabled = true
        end
    end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then
        h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        h.NameDisplayDistance = 100
        h.HealthDisplayDistance = 100
    end
end

local function aBS(n, bl)
    local p = P:FindFirstChild(n)
    if not p then return end
    if bl then
        if p.Character then sf(hC, p.Character) end
    else
        if p.Character then
            sf(sC, p.Character)
            if ST.N and not W[p.Name] then task.spawn(sf, tN, p.Character, p) end
        end
    end
end

local function sP(p)
    if p == L then return end
    local function oC(c)
        if B[p.Name] then hC(c)
        else
            if ST.R and ST.N then
                c:WaitForChild("Humanoid", 5)
                task.wait(0.5)
                sf(tN, c, p)
                hookCharForNoob(c, p)
            end
            if ST.R and ST.D then task.spawn(sf, sD, c, p) end
        end
    end
    if p.Character then task.spawn(oC, p.Character) end
    p.CharacterAdded:Connect(oC)
end

for _, p in ipairs(P:GetPlayers()) do sP(p) end
P.PlayerAdded:Connect(sP)

local function forceNoob(name)
    if not ST.N then return end
    local pl = P:FindFirstChild(name)
    if not pl or not pl.Character then return end
    task.spawn(function()
        task.wait(0.1)
        sf(tN, pl.Character, pl)
    end)
end

local function needsNoobCheck(p)
    local c = p.Character
    if not c then return false end
    local head = c:FindFirstChild("Head")
    local torso = c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    if head then
        local face = head:FindFirstChild("face")
        if not face or face.Texture ~= "rbxasset://textures/face.png" then return true end
        if head:IsA("BasePart") then
            local diff = (head.Color - NC.Skin).Magnitude
            if diff > 0.05 then return true end
        end
    end
    if torso and torso:IsA("BasePart") then
        local diff = (torso.Color - NC.T).Magnitude
        if diff > 0.05 then return true end
    end
    for _, it in ipairs(c:GetChildren()) do
        if it:IsA("Shirt") or it:IsA("Pants") or it:IsA("ShirtGraphic") or it:IsA("Accessory") or it:IsA("Hat") or it:IsA("CharacterMesh") then
            return true
        end
    end
    return false
end

--============================================================
-- 🔄 Loop كل ثانية — موسيقى + نوب + رقص
--============================================================
task.spawn(function()
    while ST.R do
        task.wait(1)
        if not ST.R then break end

        if ST.M then
            muteAllMusic()
        end

        if ST.N then
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= L and p.Character and not W[p.Name] and not B[p.Name] then
                    if needsNoobCheck(p) then
                        sf(tN, p.Character, p)
                        hookCharForNoob(p.Character, p)
                    end
                end
            end
        end
    end
end)

--============================================================
-- 🎨 UI
--============================================================
local UILib = {}
function UILib.corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 12)
    return c
end
function UILib.stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Theme.Accent
    s.Thickness = thick or 1.5
    s.Transparency = trans or 0
    return s
end
function UILib.gradient(parent, c1, c2, rot)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 90
    return g
end
function UILib.padding(parent, all)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0, all or 8)
    p.PaddingBottom = UDim.new(0, all or 8)
    p.PaddingLeft = UDim.new(0, all or 8)
    p.PaddingRight = UDim.new(0, all or 8)
    return p
end
function UILib.hover(btn, fromCol, toCol)
    btn.MouseEnter:Connect(function()
        TweenS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = toCol or fromCol}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = fromCol}):Play()
    end)
end
function UILib.drawX(parent, color, size, thickness)
    size = size or 12
    thickness = thickness or 2
    color = color or Color3.fromRGB(255, 255, 255)
    local l1 = Instance.new("Frame", parent)
    l1.Size = UDim2.new(0, size, 0, thickness)
    l1.Position = UDim2.new(0.5, -size/2, 0.5, -thickness/2)
    l1.BackgroundColor3 = color
    l1.BorderSizePixel = 0
    l1.Rotation = 45
    l1.ZIndex = 5
    Instance.new("UICorner", l1).CornerRadius = UDim.new(1, 0)
    local l2 = Instance.new("Frame", parent)
    l2.Size = UDim2.new(0, size, 0, thickness)
    l2.Position = UDim2.new(0.5, -size/2, 0.5, -thickness/2)
    l2.BackgroundColor3 = color
    l2.BorderSizePixel = 0
    l2.Rotation = -45
    l2.ZIndex = 5
    Instance.new("UICorner", l2).CornerRadius = UDim.new(1, 0)
end

local G, M

local function startMain()
    local t = T[LANG]
    local isMobile = U.TouchEnabled and not U.KeyboardEnabled

    G = Instance.new("ScreenGui")
    G.Name = "BH"
    G.ResetOnSpawn = false
    G.IgnoreGuiInset = isMobile
    G.DisplayOrder = 5
    G.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    G.Parent = L:WaitForChild("PlayerGui")

    local baseW = isMobile and 240 or 320
    local baseH = isMobile and 420 or 560

    local glowFrame = Instance.new("Frame", G)
    glowFrame.Size = UDim2.new(0, baseW + 8, 0, baseH + 8)
    glowFrame.Position = UDim2.new(0, 20, 0.5, -baseH/2 - 4)
    glowFrame.BackgroundColor3 = Theme.Accent
    glowFrame.BackgroundTransparency = 0.92
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = 1
    UILib.corner(glowFrame, 22)

    M = Instance.new("Frame", G)
    M.Size = UDim2.new(0, baseW, 0, baseH)
    M.Position = UDim2.new(0, 24, 0.5, -baseH/2)
    M.BackgroundColor3 = Theme.BG2
    M.BorderSizePixel = 0
    M.Active = true
    M.Draggable = true
    M.ClipsDescendants = true
    M.ZIndex = 2
    UILib.corner(M, 18)
    UILib.gradient(M, Theme.BG1, Theme.BG3, 135)
    UILib.stroke(M, Theme.Accent, 1.5, 0.55)

    M:GetPropertyChangedSignal("Position"):Connect(function()
        glowFrame.Position = UDim2.new(M.Position.X.Scale, M.Position.X.Offset - 4, M.Position.Y.Scale, M.Position.Y.Offset - 4)
    end)
    M:GetPropertyChangedSignal("Size"):Connect(function()
        glowFrame.Size = UDim2.new(M.Size.X.Scale, M.Size.X.Offset + 8, M.Size.Y.Scale, M.Size.Y.Offset + 8)
    end)

    local header = Instance.new("Frame", M)
    header.Size = UDim2.new(1, 0, 0, 72)
    header.BackgroundColor3 = Theme.BG1
    header.BorderSizePixel = 0
    header.ZIndex = 3
    UILib.corner(header, 18)
    local hCover = Instance.new("Frame", header)
    hCover.Size = UDim2.new(1, 0, 0, 20)
    hCover.Position = UDim2.new(0, 0, 1, -20)
    hCover.BackgroundColor3 = Theme.BG1
    hCover.BorderSizePixel = 0
    hCover.ZIndex = 3
    UILib.gradient(header, Color3.fromRGB(22, 32, 42), Color3.fromRGB(30, 46, 54), 90)

    local logoBox = Instance.new("Frame", header)
    logoBox.Size = UDim2.new(0, 46, 0, 46)
    logoBox.Position = UDim2.new(0, 16, 0, 13)
    logoBox.BackgroundColor3 = Theme.BG3
    logoBox.BorderSizePixel = 0
    logoBox.ZIndex = 4
    UILib.corner(logoBox, 14)
    UILib.stroke(logoBox, Theme.Accent, 1.5, 0.4)
    UILib.gradient(logoBox, Color3.fromRGB(30, 60, 45), Color3.fromRGB(20, 40, 32), 135)
    local logoIcon = Instance.new("TextLabel", logoBox)
    logoIcon.Size = UDim2.new(1, 0, 1, 0)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "🕌"
    logoIcon.TextSize = 26
    logoIcon.Font = Enum.Font.GothamBold
    logoIcon.ZIndex = 5

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(1, -160, 0, 24)
    titleLbl.Position = UDim2.new(0, 72, 0, 14)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = t.title
    titleLbl.TextColor3 = Theme.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 18
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    UILib.gradient(titleLbl, Theme.Accent, Color3.fromRGB(180, 255, 210), 90)

    local subLbl = Instance.new("TextLabel", header)
    subLbl.Size = UDim2.new(1, -160, 0, 14)
    subLbl.Position = UDim2.new(0, 72, 0, 40)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = t.subtitle
    subLbl.TextColor3 = Theme.TextDim
    subLbl.Font = Enum.Font.GothamMedium
    subLbl.TextSize = 11
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.ZIndex = 4

    local minBtn = Instance.new("TextButton", header)
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -72, 0, 21)
    minBtn.BackgroundColor3 = Theme.Card
    minBtn.BorderSizePixel = 0
    minBtn.Text = "−"
    minBtn.TextColor3 = Theme.Text
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = 4
    UILib.corner(minBtn, 15)
    UILib.stroke(minBtn, Theme.Info, 1.5, 0.5)
    UILib.hover(minBtn, Theme.Card, Theme.CardHi)

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 21)
    closeBtn.BackgroundColor3 = Theme.Card
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 4
    UILib.corner(closeBtn, 15)
    UILib.stroke(closeBtn, Theme.Danger, 1.5, 0.5)
    UILib.hover(closeBtn, Theme.Card, Color3.fromRGB(60, 30, 30))
    UILib.drawX(closeBtn, Theme.DangerHi, 12, 2)

    local scroll = Instance.new("ScrollingFrame", M)
    scroll.Size = UDim2.new(1, -16, 1, -80)
    scroll.Position = UDim2.new(0, 8, 0, 72)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 2000)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 3
    local sp = UILib.padding(scroll, 4)
    sp.PaddingTop = UDim.new(0, 12)
    sp.PaddingBottom = UDim.new(0, 16)
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(layout.AbsoluteContentSize.Y + 40, 200))
    end)

    local function mkSH(text, icon, order, color)
        local hf = Instance.new("Frame", scroll)
        hf.Size = UDim2.new(1, 0, 0, 26)
        hf.BackgroundTransparency = 1
        hf.LayoutOrder = order
        hf.ZIndex = 4
        local lr = Instance.new("Frame", hf)
        lr.Size = UDim2.new(1, -140, 0, 1)
        lr.Position = UDim2.new(0, 130, 0.5, 0)
        lr.BackgroundColor3 = color or Theme.Accent
        lr.BackgroundTransparency = 0.65
        lr.BorderSizePixel = 0
        lr.ZIndex = 4
        local ll = Instance.new("Frame", hf)
        ll.Size = UDim2.new(0, 20, 0, 1)
        ll.Position = UDim2.new(0, 8, 0.5, 0)
        ll.BackgroundColor3 = color or Theme.Accent
        ll.BackgroundTransparency = 0.65
        ll.BorderSizePixel = 0
        ll.ZIndex = 4
        local il = Instance.new("TextLabel", hf)
        il.Size = UDim2.new(0, 20, 1, 0)
        il.Position = UDim2.new(0, 4, 0, 0)
        il.BackgroundTransparency = 1
        il.Text = icon or "◆"
        il.TextColor3 = color or Theme.Accent
        il.Font = Enum.Font.GothamBold
        il.TextSize = 12
        il.ZIndex = 4
        local tl = Instance.new("TextLabel", hf)
        tl.Size = UDim2.new(0, 100, 1, 0)
        tl.Position = UDim2.new(0, 26, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Text = text
        tl.TextColor3 = color or Theme.Accent
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 11
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.ZIndex = 4
    end

    local function mkTC(text, icon, order, isOn, onToggle)
        local card = Instance.new("Frame", scroll)
        card.Size = UDim2.new(1, 0, 0, 56)
        card.BackgroundColor3 = Theme.Card
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.ZIndex = 4
        UILib.corner(card, 14)
        local cs = UILib.stroke(card, isOn and Theme.Success or Theme.TextDim, 1.2, 0.5)
        local ib = Instance.new("Frame", card)
        ib.Size = UDim2.new(0, 36, 0, 36)
        ib.Position = UDim2.new(0, 12, 0.5, -18)
        ib.BackgroundColor3 = isOn and Color3.fromRGB(28, 50, 38) or Theme.BG3
        ib.BorderSizePixel = 0
        ib.ZIndex = 5
        UILib.corner(ib, 10)
        local il = Instance.new("TextLabel", ib)
        il.Size = UDim2.new(1, 0, 1, 0)
        il.BackgroundTransparency = 1
        il.Text = icon
        il.TextSize = 20
        il.Font = Enum.Font.GothamBold
        il.ZIndex = 6
        local tl = Instance.new("TextLabel", card)
        tl.Size = UDim2.new(1, -130, 0, 16)
        tl.Position = UDim2.new(0, 58, 0, 13)
        tl.BackgroundTransparency = 1
        tl.Text = text
        tl.TextColor3 = Theme.Text
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.ZIndex = 5
        local sl = Instance.new("TextLabel", card)
        sl.Size = UDim2.new(1, -130, 0, 14)
        sl.Position = UDim2.new(0, 58, 0, 30)
        sl.BackgroundTransparency = 1
        sl.Text = isOn and t.on or t.off
        sl.TextColor3 = isOn and Theme.Success or Theme.TextDim
        sl.Font = Enum.Font.GothamMedium
        sl.TextSize = 11
        sl.TextXAlignment = Enum.TextXAlignment.Left
        sl.ZIndex = 5
        local tg = Instance.new("TextButton", card)
        tg.Size = UDim2.new(0, 42, 0, 24)
        tg.Position = UDim2.new(1, -54, 0.5, -12)
        tg.BackgroundColor3 = isOn and Theme.Success or Color3.fromRGB(60, 68, 78)
        tg.BorderSizePixel = 0
        tg.Text = ""
        tg.AutoButtonColor = false
        tg.ZIndex = 5
        UILib.corner(tg, 12)
        local kn = Instance.new("Frame", tg)
        kn.Size = UDim2.new(0, 18, 0, 18)
        kn.Position = isOn and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
        kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        kn.BorderSizePixel = 0
        kn.ZIndex = 6
        UILib.corner(kn, 9)
        local ca = Instance.new("TextButton", card)
        ca.Size = UDim2.new(1, 0, 1, 0)
        ca.BackgroundTransparency = 1
        ca.Text = ""
        ca.ZIndex = 6
        ca.MouseButton1Click:Connect(function()
            local ns = not isOn
            isOn = ns
            TweenS:Create(tg, TweenInfo.new(0.2), {BackgroundColor3 = ns and Theme.Success or Color3.fromRGB(60, 68, 78)}):Play()
            TweenS:Create(kn, TweenInfo.new(0.2), {Position = ns and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
            TweenS:Create(cs, TweenInfo.new(0.2), {Color = ns and Theme.Success or Theme.TextDim}):Play()
            sl.Text = ns and t.on or t.off
            sl.TextColor3 = ns and Theme.Success or Theme.TextDim
            if onToggle then onToggle(ns) end
        end)
    end

    mkSH(t.sectionAudio, "♪", 1, Theme.Accent)
    mkTC(t.muteMusic, "🎵", 2, ST.M, function(s)
        ST.M = s
        if s then
            muteAllMusic()
        else
            unmuteAllMusic()
        end
    end)

    mkSH(t.sectionVisual, "◈", 10, Theme.Info)
    mkTC(t.noobSkin, "👕", 11, ST.N, function(s)
        ST.N = s
        if s then
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= L and p.Character and not B[p.Name] then
                    task.spawn(sf, tN, p.Character, p)
                    hookCharForNoob(p.Character, p)
                end
            end
        else
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= L and p.Character then task.spawn(sf, rA, p.Character) end
            end
        end
    end)

    mkSH(t.sectionTools, "◆", 20, Theme.Gold)
    mkTC(t.stopDance, "💃", 21, ST.D, function(s) ST.D = s end)

    -- زر اقتراح اللاعب
    local suggestActive = false
    local suggestPanel, suggestLabel, suggestAvatar, currentTarget
    local suggestBtn = Instance.new("TextButton", scroll)
    suggestBtn.Size = UDim2.new(1, 0, 0, 44)
    suggestBtn.BackgroundColor3 = Theme.Card
    suggestBtn.BorderSizePixel = 0
    suggestBtn.Text = "🎯  " .. t.suggest
    suggestBtn.TextColor3 = Theme.Text
    suggestBtn.Font = Enum.Font.GothamBold
    suggestBtn.TextSize = 13
    suggestBtn.LayoutOrder = 22
    suggestBtn.AutoButtonColor = false
    suggestBtn.ZIndex = 4
    UILib.corner(suggestBtn, 14)
    UILib.stroke(suggestBtn, Theme.Accent2, 1.2, 0.55)
    UILib.hover(suggestBtn, Theme.Card, Theme.CardHi)

    suggestBtn.MouseButton1Click:Connect(function()
        suggestActive = not suggestActive
        if suggestActive then
            suggestBtn.BackgroundColor3 = Color3.fromRGB(28, 48, 40)
            suggestBtn.Text = "🎯  " .. t.suggest .. "  ●"
            suggestPanel = Instance.new("Frame", G)
            suggestPanel.Size = UDim2.new(0, 200, 0, 180)
            suggestPanel.Position = UDim2.new(1, -220, 0.3, 0)
            suggestPanel.BackgroundColor3 = Theme.BG2
            suggestPanel.BorderSizePixel = 0
            suggestPanel.Active = true
            suggestPanel.Draggable = true
            suggestPanel.ZIndex = 20
            UILib.corner(suggestPanel, 16)
            UILib.gradient(suggestPanel, Theme.BG1, Theme.BG3, 135)
            UILib.stroke(suggestPanel, Theme.Accent2, 1.5, 0.3)
            local spH = Instance.new("Frame", suggestPanel)
            spH.Size = UDim2.new(1, 0, 0, 32)
            spH.BackgroundColor3 = Theme.BG1
            spH.BorderSizePixel = 0
            spH.ZIndex = 21
            UILib.corner(spH, 16)
            local spHL = Instance.new("TextLabel", spH)
            spHL.Size = UDim2.new(1, -16, 1, 0)
            spHL.Position = UDim2.new(0, 12, 0, 0)
            spHL.BackgroundTransparency = 1
            spHL.Text = "🎯  " .. t.suggest
            spHL.TextColor3 = Theme.Accent2
            spHL.Font = Enum.Font.GothamBold
            spHL.TextSize = 12
            spHL.TextXAlignment = Enum.TextXAlignment.Left
            spHL.ZIndex = 22
            suggestAvatar = Instance.new("ImageLabel", suggestPanel)
            suggestAvatar.Size = UDim2.new(0, 56, 0, 56)
            suggestAvatar.Position = UDim2.new(0, 12, 0, 44)
            suggestAvatar.BackgroundColor3 = Theme.BG3
            suggestAvatar.BorderSizePixel = 0
            suggestAvatar.Image = ""
            suggestAvatar.ScaleType = Enum.ScaleType.Crop
            suggestAvatar.ZIndex = 22
            UILib.corner(suggestAvatar, 28)
            UILib.stroke(suggestAvatar, Theme.Accent2, 1.5, 0.4)
            suggestLabel = Instance.new("TextLabel", suggestPanel)
            suggestLabel.Size = UDim2.new(1, -84, 0, 56)
            suggestLabel.Position = UDim2.new(0, 76, 0, 44)
            suggestLabel.BackgroundTransparency = 1
            suggestLabel.Text = "—"
            suggestLabel.TextColor3 = Theme.Text
            suggestLabel.Font = Enum.Font.GothamBold
            suggestLabel.TextSize = 13
            suggestLabel.TextWrapped = true
            suggestLabel.TextXAlignment = Enum.TextXAlignment.Left
            suggestLabel.TextYAlignment = Enum.TextYAlignment.Center
            suggestLabel.ZIndex = 22
            local sW = Instance.new("TextButton", suggestPanel)
            sW.Size = UDim2.new(0, 85, 0, 34)
            sW.Position = UDim2.new(0, 12, 1, -46)
            sW.BackgroundColor3 = Theme.Success
            sW.BorderSizePixel = 0
            sW.Text = "✓ " .. t.wl
            sW.TextColor3 = Color3.fromRGB(255, 255, 255)
            sW.Font = Enum.Font.GothamBold
            sW.TextSize = 12
            sW.AutoButtonColor = false
            sW.ZIndex = 22
            UILib.corner(sW, 10)
            sW.MouseButton1Click:Connect(function()
                if currentTarget then
                    W[currentTarget.Name] = true
                    B[currentTarget.Name] = nil
                    aBS(currentTarget.Name, false)
                    local tt = currentTarget
                    task.spawn(function() if tt.Character then sf(rA, tt.Character) end end)
                    if refreshWL then refreshWL() end
                    if refreshBL then refreshBL() end
                    if refreshPL then refreshPL() end
                end
            end)
            local sB = Instance.new("TextButton", suggestPanel)
            sB.Size = UDim2.new(0, 85, 0, 34)
            sB.Position = UDim2.new(1, -97, 1, -46)
            sB.BackgroundColor3 = Theme.Danger
            sB.BorderSizePixel = 0
            sB.Text = t.block
            sB.TextColor3 = Color3.fromRGB(255, 255, 255)
            sB.Font = Enum.Font.GothamBold
            sB.TextSize = 12
            sB.AutoButtonColor = false
            sB.ZIndex = 22
            UILib.corner(sB, 10)
            sB.MouseButton1Click:Connect(function()
                if currentTarget then
                    B[currentTarget.Name] = true
                    W[currentTarget.Name] = nil
                    aBS(currentTarget.Name, true)
                    if refreshWL then refreshWL() end
                    if refreshBL then refreshBL() end
                    if refreshPL then refreshPL() end
                end
            end)
            TweenS:Create(suggestPanel, TweenInfo.new(0.4), {Position = UDim2.new(1, -220, 0.3, 0)}):Play()
            task.spawn(function()
                while ST.R and suggestActive do
                    task.wait(0.4)
                    if not suggestActive or not suggestPanel then break end
                    if not L.Character then
                        if suggestLabel then suggestLabel.Text = "—" end
                        currentTarget = nil
                        continue
                    end
                    local myRoot = L.Character:FindFirstChild("HumanoidRootPart")
                    if not myRoot then currentTarget = nil continue end
                    local cam = workspace.CurrentCamera
                    local camLook = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
                    local best, bestScore = nil, 0
                    for _, p in ipairs(P:GetPlayers()) do
                        if p ~= L and p.Character and not B[p.Name] then
                            local root = p.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local dir = root.Position - myRoot.Position
                                local dist = dir.Magnitude
                                if dist < 100 then
                                    local dot = dir.Unit:Dot(camLook)
                                    if dot > 0.3 then
                                        local score = dot / (dist + 1)
                                        if score > bestScore then bestScore = score best = p end
                                    end
                                end
                            end
                        end
                    end
                    currentTarget = best
                    if suggestLabel then
                        if best then
                            local dn = best.DisplayName ~= "" and best.DisplayName or best.Name
                            suggestLabel.Text = dn .. "\n@" .. best.Name
                            suggestLabel.TextColor3 = Theme.Success
                            if suggestAvatar then suggestAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. best.UserId .. "&w=150&h=150" end
                        else
                            suggestLabel.Text = "—"
                            suggestLabel.TextColor3 = Theme.TextDim
                            if suggestAvatar then suggestAvatar.Image = "" end
                        end
                    end
                end
            end)
        else
            suggestBtn.BackgroundColor3 = Theme.Card
            suggestBtn.Text = "🎯  " .. t.suggest
            if suggestPanel then pcall(function() suggestPanel:Destroy() end) suggestPanel = nil end
            currentTarget = nil
        end
    end)

    mkSH(t.players, "◆", 30, Theme.Accent)

    local searchBox = Instance.new("Frame", scroll)
    searchBox.Size = UDim2.new(1, 0, 0, 40)
    searchBox.BackgroundColor3 = Theme.Card
    searchBox.BorderSizePixel = 0
    searchBox.LayoutOrder = 31
    searchBox.ZIndex = 4
    UILib.corner(searchBox, 12)
    local si = Instance.new("TextLabel", searchBox)
    si.Size = UDim2.new(0, 32, 1, 0)
    si.Position = UDim2.new(0, 6, 0, 0)
    si.BackgroundTransparency = 1
    si.Text = "🔍"
    si.TextSize = 14
    si.ZIndex = 5
    local sii = Instance.new("TextBox", searchBox)
    sii.Size = UDim2.new(1, -80, 1, 0)
    sii.Position = UDim2.new(0, 34, 0, 0)
    sii.BackgroundTransparency = 1
    sii.Text = ""
    sii.PlaceholderText = t.searchPH
    sii.TextColor3 = Theme.Text
    sii.PlaceholderColor3 = Theme.TextDim
    sii.Font = Enum.Font.GothamMedium
    sii.TextSize = 12
    sii.TextXAlignment = Enum.TextXAlignment.Left
    sii.ClearTextOnFocus = false
    sii.ZIndex = 5
    local cS = Instance.new("TextButton", searchBox)
    cS.Size = UDim2.new(0, 24, 0, 24)
    cS.Position = UDim2.new(1, -30, 0.5, -12)
    cS.BackgroundColor3 = Theme.Danger
    cS.BorderSizePixel = 0
    cS.Text = ""
    cS.AutoButtonColor = false
    cS.ZIndex = 5
    UILib.corner(cS, 12)
    UILib.drawX(cS, Color3.fromRGB(255, 255, 255), 10, 2)

    local plFrame = Instance.new("Frame", scroll)
    plFrame.Size = UDim2.new(1, 0, 0, 200)
    plFrame.BackgroundColor3 = Theme.BG3
    plFrame.BorderSizePixel = 0
    plFrame.LayoutOrder = 32
    plFrame.ZIndex = 4
    UILib.corner(plFrame, 12)
    local plScroll = Instance.new("ScrollingFrame", plFrame)
    plScroll.Size = UDim2.new(1, -8, 1, -8)
    plScroll.Position = UDim2.new(0, 4, 0, 4)
    plScroll.BackgroundTransparency = 1
    plScroll.BorderSizePixel = 0
    plScroll.ScrollBarThickness = 3
    plScroll.ScrollBarImageColor3 = Theme.Accent
    plScroll.CanvasSize = UDim2.new(0, 0, 0, 200)
    plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    plScroll.ZIndex = 5
    local plLay = Instance.new("UIListLayout", plScroll)
    plLay.Padding = UDim.new(0, 4)

    mkSH(t.sectionLists, "◆", 40, Theme.Accent2)

    local wlFrame = Instance.new("Frame", scroll)
    wlFrame.Size = UDim2.new(1, 0, 0, 130)
    wlFrame.BackgroundColor3 = Theme.Card
    wlFrame.BorderSizePixel = 0
    wlFrame.LayoutOrder = 41
    wlFrame.ZIndex = 4
    UILib.corner(wlFrame, 12)
    UILib.stroke(wlFrame, Theme.Success, 1, 0.5)
    local wlH = Instance.new("TextLabel", wlFrame)
    wlH.Size = UDim2.new(1, -16, 0, 24)
    wlH.Position = UDim2.new(0, 12, 0, 8)
    wlH.BackgroundTransparency = 1
    wlH.Text = "✓  " .. t.whitelist
    wlH.TextColor3 = Theme.Success
    wlH.Font = Enum.Font.GothamBold
    wlH.TextSize = 12
    wlH.TextXAlignment = Enum.TextXAlignment.Left
    wlH.ZIndex = 5
    local wlI = Instance.new("TextBox", wlFrame)
    wlI.Size = UDim2.new(1, -66, 0, 26)
    wlI.Position = UDim2.new(0, 12, 0, 36)
    wlI.BackgroundColor3 = Theme.BG3
    wlI.BorderSizePixel = 0
    wlI.PlaceholderText = t.searchPH
    wlI.Text = ""
    wlI.TextColor3 = Theme.Text
    wlI.PlaceholderColor3 = Theme.TextDim
    wlI.Font = Enum.Font.GothamMedium
    wlI.TextSize = 11
    wlI.TextXAlignment = Enum.TextXAlignment.Left
    wlI.ClearTextOnFocus = false
    wlI.ZIndex = 5
    UILib.corner(wlI, 8)
    local wlAdd = Instance.new("TextButton", wlFrame)
    wlAdd.Size = UDim2.new(0, 44, 0, 26)
    wlAdd.Position = UDim2.new(1, -56, 0, 36)
    wlAdd.BackgroundColor3 = Theme.Success
    wlAdd.BorderSizePixel = 0
    wlAdd.Text = "+"
    wlAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
    wlAdd.Font = Enum.Font.GothamBold
    wlAdd.TextSize = 16
    wlAdd.AutoButtonColor = false
    wlAdd.ZIndex = 5
    UILib.corner(wlAdd, 8)
    local wlL = Instance.new("ScrollingFrame", wlFrame)
    wlL.Size = UDim2.new(1, -24, 1, -72)
    wlL.Position = UDim2.new(0, 12, 0, 66)
    wlL.BackgroundTransparency = 1
    wlL.BorderSizePixel = 0
    wlL.ScrollBarThickness = 3
    wlL.ScrollBarImageColor3 = Theme.Success
    wlL.CanvasSize = UDim2.new(0, 0, 0, 100)
    wlL.AutomaticCanvasSize = Enum.AutomaticSize.Y
    wlL.ZIndex = 5
    local wlLay = Instance.new("UIListLayout", wlL)
    wlLay.Padding = UDim.new(0, 3)

    local blFrame = Instance.new("Frame", scroll)
    blFrame.Size = UDim2.new(1, 0, 0, 130)
    blFrame.BackgroundColor3 = Theme.Card
    blFrame.BorderSizePixel = 0
    blFrame.LayoutOrder = 42
    blFrame.ZIndex = 4
    UILib.corner(blFrame, 12)
    UILib.stroke(blFrame, Theme.Danger, 1, 0.5)
    local blH = Instance.new("TextLabel", blFrame)
    blH.Size = UDim2.new(1, -16, 0, 24)
    blH.Position = UDim2.new(0, 12, 0, 8)
    blH.BackgroundTransparency = 1
    blH.Text = t.blocked
    blH.TextColor3 = Theme.Danger
    blH.Font = Enum.Font.GothamBold
    blH.TextSize = 12
    blH.TextXAlignment = Enum.TextXAlignment.Left
    blH.ZIndex = 5
    local blI = Instance.new("TextBox", blFrame)
    blI.Size = UDim2.new(1, -66, 0, 26)
    blI.Position = UDim2.new(0, 12, 0, 36)
    blI.BackgroundColor3 = Theme.BG3
    blI.BorderSizePixel = 0
    blI.PlaceholderText = t.searchPH
    blI.Text = ""
    blI.TextColor3 = Theme.Text
    blI.PlaceholderColor3 = Theme.TextDim
    blI.Font = Enum.Font.GothamMedium
    blI.TextSize = 11
    blI.TextXAlignment = Enum.TextXAlignment.Left
    blI.ClearTextOnFocus = false
    blI.ZIndex = 5
    UILib.corner(blI, 8)
    local blAdd = Instance.new("TextButton", blFrame)
    blAdd.Size = UDim2.new(0, 44, 0, 26)
    blAdd.Position = UDim2.new(1, -56, 0, 36)
    blAdd.BackgroundColor3 = Theme.Danger
    blAdd.BorderSizePixel = 0
    blAdd.Text = "+"
    blAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
    blAdd.Font = Enum.Font.GothamBold
    blAdd.TextSize = 16
    blAdd.AutoButtonColor = false
    blAdd.ZIndex = 5
    UILib.corner(blAdd, 8)
    local blL = Instance.new("ScrollingFrame", blFrame)
    blL.Size = UDim2.new(1, -24, 1, -72)
    blL.Position = UDim2.new(0, 12, 0, 66)
    blL.BackgroundTransparency = 1
    blL.BorderSizePixel = 0
    blL.ScrollBarThickness = 3
    blL.ScrollBarImageColor3 = Theme.Danger
    blL.CanvasSize = UDim2.new(0, 0, 0, 100)
    blL.AutomaticCanvasSize = Enum.AutomaticSize.Y
    blL.ZIndex = 5
    local blLay = Instance.new("UIListLayout", blL)
    blLay.Padding = UDim.new(0, 3)

    local function mkPR(parent, pl, aType, aColor, onAct)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -8, 0, 42)
        row.BackgroundColor3 = Theme.BG3
        row.BorderSizePixel = 0
        row.ZIndex = 6
        UILib.corner(row, 10)
        local av = Instance.new("ImageLabel", row)
        av.Size = UDim2.new(0, 32, 0, 32)
        av.Position = UDim2.new(0, 6, 0.5, -16)
        av.BackgroundColor3 = Theme.Card
        av.BorderSizePixel = 0
        av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. (pl.UserId or 1) .. "&w=150&h=150"
        av.ScaleType = Enum.ScaleType.Crop
        av.ZIndex = 7
        UILib.corner(av, 16)
        UILib.stroke(av, Theme.Accent, 1, 0.4)
        local nl = Instance.new("TextLabel", row)
        nl.Size = UDim2.new(1, -100, 0, 14)
        nl.Position = UDim2.new(0, 46, 0, 6)
        nl.BackgroundTransparency = 1
        local dn = pl.DisplayName ~= "" and pl.DisplayName or pl.Name
        if pl.Name == CREATOR_NAME then dn = "👑 " .. dn end
        nl.Text = dn
        nl.TextColor3 = Theme.Text
        nl.Font = Enum.Font.GothamBold
        nl.TextSize = 12
        nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.TextTruncate = Enum.TextTruncate.AtEnd
        nl.ZIndex = 7
        local ul = Instance.new("TextLabel", row)
        ul.Size = UDim2.new(1, -100, 0, 12)
        ul.Position = UDim2.new(0, 46, 0, 20)
        ul.BackgroundTransparency = 1
        ul.Text = "@" .. pl.Name
        ul.TextColor3 = Theme.TextDim
        ul.Font = Enum.Font.GothamMedium
        ul.TextSize = 10
        ul.TextXAlignment = Enum.TextXAlignment.Left
        ul.TextTruncate = Enum.TextTruncate.AtEnd
        ul.ZIndex = 7
        if aType and onAct then
            local ab = Instance.new("TextButton", row)
            ab.Size = UDim2.new(0, 30, 0, 30)
            ab.Position = UDim2.new(1, -38, 0.5, -15)
            ab.BackgroundColor3 = aColor or Theme.Success
            ab.BorderSizePixel = 0
            ab.Text = ""
            ab.AutoButtonColor = false
            ab.ZIndex = 7
            UILib.corner(ab, 15)
            UILib.stroke(ab, Color3.fromRGB(255, 255, 255), 1.5, 0.4)
            if aType == "check" then
                local cl = Instance.new("TextLabel", ab)
                cl.Size = UDim2.new(1, 0, 1, 0)
                cl.BackgroundTransparency = 1
                cl.Text = "✓"
                cl.TextColor3 = Color3.fromRGB(255, 255, 255)
                cl.Font = Enum.Font.GothamBlack
                cl.TextSize = 18
                cl.ZIndex = 8
            elseif aType == "x" then
                UILib.drawX(ab, Color3.fromRGB(255, 255, 255), 12, 2)
            elseif aType == "undo" then
                local ul2 = Instance.new("TextLabel", ab)
                ul2.Size = UDim2.new(1, 0, 1, 0)
                ul2.BackgroundTransparency = 1
                ul2.Text = "↩"
                ul2.TextColor3 = Color3.fromRGB(255, 255, 255)
                ul2.Font = Enum.Font.GothamBold
                ul2.TextSize = 16
                ul2.ZIndex = 8
            end
            ab.MouseButton1Click:Connect(onAct)
        end
        return row
    end

    local refreshPL, refreshWL, refreshBL

    refreshPL = function()
        for _, c in ipairs(plScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local count = 0
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= L then
                local dn = (pl.DisplayName ~= "" and pl.DisplayName or pl.Name):lower()
                local un = pl.Name:lower()
                if searchQuery == "" or dn:find(searchQuery, 1, true) or un:find(searchQuery, 1, true) then
                    count = count + 1
                    local row = mkPR(plScroll, pl, "check", Theme.Success, function()
                        W[pl.Name] = true
                        B[pl.Name] = nil
                        aBS(pl.Name, false)
                        task.spawn(function() if pl.Character then sf(rA, pl.Character) end end)
                        if refreshWL then refreshWL() end
                        if refreshBL then refreshBL() end
                        if refreshPL then refreshPL() end
                    end)
                    local bb = Instance.new("TextButton", row)
                    bb.Size = UDim2.new(0, 30, 0, 30)
                    bb.Position = UDim2.new(1, -72, 0.5, -15)
                    bb.BackgroundColor3 = Theme.Danger
                    bb.BorderSizePixel = 0
                    bb.Text = ""
                    bb.AutoButtonColor = false
                    bb.ZIndex = 7
                    UILib.corner(bb, 15)
                    UILib.stroke(bb, Color3.fromRGB(255, 255, 255), 1.5, 0.4)
                    UILib.drawX(bb, Color3.fromRGB(255, 255, 255), 12, 2)
                    bb.MouseButton1Click:Connect(function()
                        B[pl.Name] = true
                        W[pl.Name] = nil
                        aBS(pl.Name, true)
                        if refreshWL then refreshWL() end
                        if refreshBL then refreshBL() end
                        if refreshPL then refreshPL() end
                    end)
                end
            end
        end
        if count == 0 then
            local el = Instance.new("TextLabel", plScroll)
            el.Size = UDim2.new(1, 0, 0, 60)
            el.BackgroundTransparency = 1
            el.Text = "🌙  " .. t.noPlayers
            el.TextColor3 = Theme.TextDim
            el.Font = Enum.Font.GothamMedium
            el.TextSize = 12
            el.ZIndex = 6
        end
        plFrame.Size = UDim2.new(1, 0, 0, math.clamp(count * 46 + 16, 100, 300))
    end

    refreshWL = function()
        for _, c in ipairs(wlL:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local count = 0
        for n, _ in pairs(W) do
            if n ~= L.Name then
                count = count + 1
                local pl = P:FindFirstChild(n)
                local fakeP = pl or {UserId = 1, Name = n, DisplayName = n}
                mkPR(wlL, fakeP, "x", Theme.Danger, function()
                    W[n] = nil
                    forceNoob(n)
                    if refreshWL then refreshWL() end
                    if refreshPL then refreshPL() end
                end)
            end
        end
        if count == 0 then
            local el = Instance.new("TextLabel", wlL)
            el.Size = UDim2.new(1, 0, 0, 40)
            el.BackgroundTransparency = 1
            el.Text = t.empty
            el.TextColor3 = Theme.TextDim
            el.Font = Enum.Font.GothamMedium
            el.TextSize = 11
            el.ZIndex = 6
        end
    end

    refreshBL = function()
        for _, c in ipairs(blL:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local count = 0
        for n, _ in pairs(B) do
            if n ~= L.Name then
                count = count + 1
                local pl = P:FindFirstChild(n)
                local fakeP = pl or {UserId = 1, Name = n, DisplayName = n}
                mkPR(blL, fakeP, "undo", Theme.Success, function()
                    B[n] = nil
                    if refreshBL then refreshBL() end
                    aBS(n, false)
                    if refreshPL then refreshPL() end
                end)
            end
        end
        if count == 0 then
            local el = Instance.new("TextLabel", blL)
            el.Size = UDim2.new(1, 0, 0, 40)
            el.BackgroundTransparency = 1
            el.Text = t.empty
            el.TextColor3 = Theme.TextDim
            el.Font = Enum.Font.GothamMedium
            el.TextSize = 11
            el.ZIndex = 6
        end
    end

    sii:GetPropertyChangedSignal("Text"):Connect(function()
        searchQuery = sii.Text:lower()
        if refreshPL then refreshPL() end
    end)
    cS.MouseButton1Click:Connect(function()
        sii.Text = ""
        searchQuery = ""
        if refreshPL then refreshPL() end
    end)

    wlAdd.MouseButton1Click:Connect(function()
        local n = wlI.Text:gsub("%s+", "")
        if n == "" or n == L.Name then return end
        W[n] = true
        B[n] = nil
        wlI.Text = ""
        if refreshWL then refreshWL() end
        if refreshBL then refreshBL() end
        aBS(n, false)
        if refreshPL then refreshPL() end
    end)
    wlI.FocusLost:Connect(function(e)
        if e then
            local n = wlI.Text:gsub("%s+", "")
            if n == "" or n == L.Name then return end
            W[n] = true
            B[n] = nil
            wlI.Text = ""
            if refreshWL then refreshWL() end
            if refreshBL then refreshBL() end
            aBS(n, false)
            if refreshPL then refreshPL() end
        end
    end)

    blAdd.MouseButton1Click:Connect(function()
        local n = blI.Text:gsub("%s+", "")
        if n == "" or n == L.Name then return end
        B[n] = true
        W[n] = nil
        blI.Text = ""
        if refreshBL then refreshBL() end
        if refreshWL then refreshWL() end
        aBS(n, true)
        if refreshPL then refreshPL() end
    end)
    blI.FocusLost:Connect(function(e)
        if e then
            local n = blI.Text:gsub("%s+", "")
            if n == "" or n == L.Name then return end
            B[n] = true
            W[n] = nil
            blI.Text = ""
            if refreshBL then refreshBL() end
            if refreshWL then refreshWL() end
            aBS(n, true)
            if refreshPL then refreshPL() end
        end
    end)

    refreshPL()
    refreshWL()
    refreshBL()

    P.PlayerAdded:Connect(function() task.wait(1) if refreshPL then refreshPL() end end)
    P.PlayerRemoving:Connect(function() task.wait(0.5) if refreshPL then refreshPL() end end)

    local miniIcon = Instance.new("TextButton", G)
    miniIcon.Size = UDim2.new(0, 60, 0, 60)
    miniIcon.Position = M.Position
    miniIcon.BackgroundColor3 = Theme.BG2
    miniIcon.BorderSizePixel = 0
    miniIcon.Text = "🕌"
    miniIcon.TextSize = 28
    miniIcon.Font = Enum.Font.GothamBold
    miniIcon.Visible = false
    miniIcon.AutoButtonColor = false
    miniIcon.ZIndex = 4
    UILib.corner(miniIcon, 30)
    UILib.stroke(miniIcon, Theme.Accent, 2, 0.3)

    local miniGlow = Instance.new("Frame", G)
    miniGlow.Size = UDim2.new(0, 68, 0, 68)
    miniGlow.Position = UDim2.new(0, 0, 0, 0)
    miniGlow.BackgroundColor3 = Theme.Accent
    miniGlow.BackgroundTransparency = 0.9
    miniGlow.BorderSizePixel = 0
    miniGlow.Visible = false
    miniGlow.ZIndex = 3
    UILib.corner(miniGlow, 34)

    miniIcon:GetPropertyChangedSignal("Position"):Connect(function()
        miniGlow.Position = UDim2.new(miniIcon.Position.X.Scale, miniIcon.Position.X.Offset - 4, miniIcon.Position.Y.Scale, miniIcon.Position.Y.Offset - 4)
    end)

    local function setMin(state)
        if state then
            miniIcon.Position = M.Position
            M.Visible = false
            glowFrame.Visible = false
            miniIcon.Visible = true
            miniGlow.Visible = true
        else
            M.Position = miniIcon.Position
            M.Visible = true
            glowFrame.Position = UDim2.new(miniIcon.Position.X.Scale, miniIcon.Position.X.Offset - 4, miniIcon.Position.Y.Scale, miniIcon.Position.Y.Offset - 4)
            glowFrame.Visible = true
            miniIcon.Visible = false
            miniGlow.Visible = false
        end
    end

    minBtn.MouseButton1Click:Connect(function() setMin(true) end)

    local mDrag = false
    local mMoved = false
    local mDS = nil
    local mSP = nil
    miniIcon.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            mDrag = true mMoved = false mDS = i.Position mSP = miniIcon.Position
        end
    end)
    U.InputChanged:Connect(function(i)
        if not mDrag then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - mDS
        if d.Magnitude > 5 then mMoved = true end
        miniIcon.Position = UDim2.new(mSP.X.Scale, mSP.X.Offset + d.X, mSP.Y.Scale, mSP.Y.Offset + d.Y)
    end)
    U.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if mDrag and not mMoved then setMin(false) end
            mDrag = false
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            pcall(function() ST.R = false end)
            pcall(unmuteAllMusic)
            pcall(function()
                for _, p in ipairs(P:GetPlayers()) do
                    if p.Character then
                        pcall(rA, p.Character)
                        pcall(sC, p.Character)
                    end
                end
            end)
            pcall(function() for _, c in pairs(D) do c:Disconnect() end end)
            pcall(function() G:Destroy() end)
        end)
    end)

    M.Position = UDim2.new(0, -baseW - 50, 0.5, -baseH/2)
    TweenS:Create(M, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0, 24, 0.5, -baseH/2)}):Play()
    glowFrame.Position = UDim2.new(0, -baseW - 50, 0.5, -baseH/2 - 4)
    TweenS:Create(glowFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0, 20, 0.5, -baseH/2 - 4)}):Play()

    task.spawn(function()
        while G and G.Parent do
            if glowFrame.Visible then
                TweenS:Create(glowFrame, TweenInfo.new(2), {BackgroundTransparency = 0.95}):Play()
            end
            task.wait(2)
            if glowFrame.Visible then
                TweenS:Create(glowFrame, TweenInfo.new(2), {BackgroundTransparency = 0.88}):Play()
            end
            task.wait(2)
        end
    end)
    task.spawn(function()
        while G and G.Parent do
            if miniGlow.Visible then
                TweenS:Create(miniGlow, TweenInfo.new(1.5), {BackgroundTransparency = 0.95}):Play()
            end
            task.wait(1.5)
            if miniGlow.Visible then
                TweenS:Create(miniGlow, TweenInfo.new(1.5), {BackgroundTransparency = 0.82}):Play()
            end
            task.wait(1.5)
        end
    end)
end

--============================================================
-- 🎨 قائمة اللغة
--============================================================
local isMob = U.TouchEnabled and not U.KeyboardEnabled
local langGui = Instance.new("ScreenGui")
langGui.Name = "BHLang"
langGui.ResetOnSpawn = false
langGui.IgnoreGuiInset = isMob
langGui.DisplayOrder = 999
langGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
langGui.Parent = L:WaitForChild("PlayerGui")

local bd = Instance.new("Frame", langGui)
bd.Size = UDim2.new(1, 0, 1, 0)
bd.BackgroundColor3 = Color3.fromRGB(5, 8, 12)
bd.BackgroundTransparency = 1
bd.BorderSizePixel = 0

local bg = Instance.new("Frame", langGui)
bg.Size = UDim2.new(0, 500, 0, 500)
bg.Position = UDim2.new(0.5, -250, 0.5, -250)
bg.BackgroundColor3 = Theme.Accent
bg.BackgroundTransparency = 0.93
bg.BorderSizePixel = 0
Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

local cardW, cardH = isMob and 300 or 400, isMob and 460 or 520

local lf = Instance.new("Frame", langGui)
lf.Size = UDim2.new(0, cardW, 0, cardH)
lf.Position = UDim2.new(0.5, -cardW/2, 0.5, -cardH/2 + 30)
lf.BackgroundColor3 = Theme.BG2
lf.BorderSizePixel = 0
lf.Active = true
lf.BackgroundTransparency = 1
UILib.corner(lf, 24)

local lfg = Instance.new("UIGradient", lf)
lfg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 30, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(16, 24, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 18, 24)),
})
lfg.Rotation = 135

local lfs = Instance.new("UIStroke", lf)
lfs.Color = Theme.Accent
lfs.Thickness = 1.5
lfs.Transparency = 0.4

local lflg = Instance.new("Frame", langGui)
lflg.Size = UDim2.new(0, cardW + 12, 0, cardH + 12)
lflg.Position = UDim2.new(0.5, -cardW/2 - 6, 0.5, -cardH/2 + 24)
lflg.BackgroundColor3 = Theme.Accent
lflg.BackgroundTransparency = 0.9
lflg.BorderSizePixel = 0
lflg.ZIndex = lf.ZIndex - 1
UILib.corner(lflg, 28)

local lc = Instance.new("Frame", lf)
lc.Size = UDim2.new(0, 100, 0, 100)
lc.Position = UDim2.new(0.5, -50, 0, 30)
lc.BackgroundColor3 = Theme.BG3
lc.BorderSizePixel = 0
UILib.corner(lc, 50)
UILib.gradient(lc, Color3.fromRGB(36, 70, 50), Color3.fromRGB(20, 40, 30), 135)

local lcs = Instance.new("UIStroke", lc)
lcs.Color = Theme.Accent
lcs.Thickness = 2
lcs.Transparency = 0.3

local lci = Instance.new("TextLabel", lc)
lci.Size = UDim2.new(1, 0, 1, 0)
lci.BackgroundTransparency = 1
lci.Text = "🕌"
lci.TextSize = 52
lci.Font = Enum.Font.GothamBold

local lt = Instance.new("TextLabel", lf)
lt.Size = UDim2.new(1, -30, 0, 34)
lt.Position = UDim2.new(0, 15, 0, 145)
lt.BackgroundTransparency = 1
lt.Text = "بي حلال · Be Halal"
lt.TextColor3 = Theme.Text
lt.Font = Enum.Font.GothamBold
lt.TextSize = 24
lt.TextXAlignment = Enum.TextXAlignment.Center
local ltg = Instance.new("UIGradient", lt)
ltg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 255, 230)),
    ColorSequenceKeypoint.new(1, Theme.Accent),
})
ltg.Rotation = 90

local ls = Instance.new("TextLabel", lf)
ls.Size = UDim2.new(1, -30, 0, 20)
ls.Position = UDim2.new(0, 15, 0, 182)
ls.BackgroundTransparency = 1
ls.Text = "اختر اللغة  •  Select Language"
ls.TextColor3 = Theme.TextDim
ls.Font = Enum.Font.GothamMedium
ls.TextSize = 12
ls.TextXAlignment = Enum.TextXAlignment.Center

local dl = Instance.new("Frame", lf)
dl.Size = UDim2.new(0, 220, 0, 1)
dl.Position = UDim2.new(0.5, -110, 0, 218)
dl.BackgroundColor3 = Theme.Accent
dl.BackgroundTransparency = 0.6
dl.BorderSizePixel = 0

local dd = Instance.new("Frame", lf)
dd.Size = UDim2.new(0, 6, 0, 6)
dd.Position = UDim2.new(0.5, -3, 0, 215.5)
dd.BackgroundColor3 = Theme.Accent
dd.BorderSizePixel = 0
UILib.corner(dd, 3)

local function mkb(text, flag, desc, y, lang, c1, c2)
    local bc = Instance.new("Frame", lf)
    bc.Size = UDim2.new(1, -60, 0, 76)
    bc.Position = UDim2.new(0, 30, 0, y)
    bc.BackgroundColor3 = Theme.Card
    bc.BorderSizePixel = 0
    UILib.corner(bc, 16)
    local bg2 = Instance.new("UIGradient", bc)
    bg2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)})
    bg2.Rotation = 90
    bg2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 0.85)})
    local bs = Instance.new("UIStroke", bc)
    bs.Color = c1
    bs.Thickness = 1.5
    bs.Transparency = 0.4
    local b = Instance.new("TextButton", bc)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.AutoButtonColor = false
    UILib.corner(b, 16)
    local fb = Instance.new("Frame", bc)
    fb.Size = UDim2.new(0, 48, 0, 48)
    fb.Position = UDim2.new(0, 14, 0.5, -24)
    fb.BackgroundColor3 = Theme.BG1
    fb.BorderSizePixel = 0
    UILib.corner(fb, 12)
    UILib.stroke(fb, c1, 1, 0.4)
    local fl = Instance.new("TextLabel", fb)
    fl.Size = UDim2.new(1, 0, 1, 0)
    fl.BackgroundTransparency = 1
    fl.Text = flag
    fl.TextSize = 28
    fl.Font = Enum.Font.GothamBold
    local nl = Instance.new("TextLabel", bc)
    nl.Size = UDim2.new(1, -100, 0, 22)
    nl.Position = UDim2.new(0, 72, 0, 16)
    nl.BackgroundTransparency = 1
    nl.Text = text
    nl.TextColor3 = Theme.Text
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 18
    nl.TextXAlignment = Enum.TextXAlignment.Left
    local dcl = Instance.new("TextLabel", bc)
    dcl.Size = UDim2.new(1, -100, 0, 16)
    dcl.Position = UDim2.new(0, 72, 0, 40)
    dcl.BackgroundTransparency = 1
    dcl.Text = desc
    dcl.TextColor3 = Theme.TextDim
    dcl.Font = Enum.Font.GothamMedium
    dcl.TextSize = 11
    dcl.TextXAlignment = Enum.TextXAlignment.Left
    local ar = Instance.new("TextLabel", bc)
    ar.Size = UDim2.new(0, 30, 1, 0)
    ar.Position = UDim2.new(1, -36, 0, 0)
    ar.BackgroundTransparency = 1
    ar.Text = "›"
    ar.TextColor3 = c1
    ar.Font = Enum.Font.GothamBold
    ar.TextSize = 32
    b.MouseButton1Click:Connect(function()
        TweenS:Create(lf, TweenInfo.new(0.35), {Position = UDim2.new(0.5, -cardW/2, 0.5, -cardH/2 + 80)}):Play()
        TweenS:Create(lflg, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        TweenS:Create(bd, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        TweenS:Create(bg, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        TweenS:Create(lfs, TweenInfo.new(0.35), {Transparency = 1}):Play()
        for _, c in ipairs(lf:GetDescendants()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                TweenS:Create(c, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
            elseif c:IsA("UIStroke") then
                TweenS:Create(c, TweenInfo.new(0.35), {Transparency = 1}):Play()
            elseif c:IsA("Frame") then
                TweenS:Create(c, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
            end
        end
        task.wait(0.35)
        LANG = lang
        langGui:Destroy()
        startMain()
    end)
end

mkb("العربية", "🇸🇦", "واجهة عربية كاملة", 250, "ar", Color3.fromRGB(60, 180, 110), Color3.fromRGB(30, 110, 65))
mkb("English", "🇬🇧", "Full English interface", 340, "en", Color3.fromRGB(80, 140, 220), Color3.fromRGB(40, 80, 160))

local fl2 = Instance.new("TextLabel", lf)
fl2.Size = UDim2.new(1, -30, 0, 20)
fl2.Position = UDim2.new(0, 15, 1, -32)
fl2.BackgroundTransparency = 1
fl2.Text = "✧  صُنع بإتقان  ✧"
fl2.TextColor3 = Theme.TextDim
fl2.Font = Enum.Font.GothamMedium
fl2.TextSize = 11
fl2.TextXAlignment = Enum.TextXAlignment.Center

TweenS:Create(bd, TweenInfo.new(0.5), {BackgroundTransparency = 0.4}):Play()
TweenS:Create(bg, TweenInfo.new(0.8), {BackgroundTransparency = 0.93}):Play()
lf.Position = UDim2.new(0.5, -cardW/2, 0.5, -cardH/2 + 60)
TweenS:Create(lf, TweenInfo.new(0.7, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -cardW/2, 0.5, -cardH/2),
    BackgroundTransparency = 0
}):Play()
lflg.Position = UDim2.new(0.5, -cardW/2 - 6, 0.5, -cardH/2 + 84)
TweenS:Create(lflg, TweenInfo.new(0.7, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -cardW/2 - 6, 0.5, -cardH/2 - 6),
    BackgroundTransparency = 0.9
}):Play()
lc.Size = UDim2.new(0, 0, 0, 0)
lc.Position = UDim2.new(0.5, 0, 0, 80)
TweenS:Create(lc, TweenInfo.new(0.7, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 100, 0, 100),
    Position = UDim2.new(0.5, -50, 0, 30)
}):Play()

task.spawn(function()
    while langGui and langGui.Parent do
        TweenS:Create(lci, TweenInfo.new(1.3), {TextSize = 58}):Play()
        TweenS:Create(lcs, TweenInfo.new(1.3), {Transparency = 0.6}):Play()
        task.wait(1.3)
        TweenS:Create(lci, TweenInfo.new(1.3), {TextSize = 52}):Play()
        TweenS:Create(lcs, TweenInfo.new(1.3), {Transparency = 0.3}):Play()
        task.wait(1.3)
    end
end)
