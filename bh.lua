--[[
    Be Halal | بي حلال
    v3.1 - client side
    by EZ_NOOB11220
]]

local Players      = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UIS          = game:GetService("UserInputService")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local Marketplace  = game:GetService("MarketplaceService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local CREATOR_NAME = "EZ_NOOB11220"
local VERSION = "3.1"

local ENV = (getgenv and getgenv()) or _G
if ENV.__BeHalal and type(ENV.__BeHalal.destroy) == "function" then
    pcall(ENV.__BeHalal.destroy)
end
for _, n in ipairs({"BH", "BH_SoundsMgr", "BH_SoundLog", "BH_AnimLog", "BHLang"}) do
    local old = PG:FindFirstChild(n)
    if old then old:Destroy() end
end

---------------------------------------------------------------- Janitor
local Janitor = {}
Janitor.__index = Janitor
function Janitor.new() return setmetatable({items = {}}, Janitor) end
function Janitor:Add(x) table.insert(self.items, x) return x end
function Janitor:Clean()
    local items = self.items
    self.items = {}
    for _, x in ipairs(items) do
        local t = typeof(x)
        if t == "RBXScriptConnection" then pcall(function() x:Disconnect() end)
        elseif t == "Instance" then pcall(function() x:Destroy() end)
        elseif t == "function" then pcall(x)
        elseif t == "table" and x.Clean then pcall(function() x:Clean() end) end
    end
end

local Root = Janitor.new()

---------------------------------------------------------------- Utils
local function N(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function trim(s) return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")) end
local function lower(s) return string.lower(tostring(s)) end
local function close(a, b)
    return math.abs(a.R - b.R) < 0.02 and math.abs(a.G - b.G) < 0.02 and math.abs(a.B - b.B) < 0.02
end

local canFS = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
local function readJSON(file)
    if not canFS then return nil end
    local ok, res = pcall(function()
        if isfile(file) then return HttpService:JSONDecode(readfile(file)) end
    end)
    if ok and type(res) == "table" then return res end
    return nil
end
local function writeJSON(file, tbl)
    if not canFS then return end
    pcall(function() writefile(file, HttpService:JSONEncode(tbl)) end)
end

local State = {
    running = true, lang = "ar",
    muteMusic = false, noob = false, dances = true, broadDances = false,
    W = {}, B = {}, animAllow = {},
}

local function loop(interval, fn)
    task.spawn(function()
        while State.running do
            task.wait(interval)
            if not State.running then break end
            local ok, e = pcall(fn)
            if not ok then warn("[BeHalal]", e) end
        end
    end)
end

local idCache = {}
local function userIdAsync(name, cb)
    if idCache[name] then cb(idCache[name]) return end
    task.spawn(function()
        local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(name) end)
        if ok and id then idCache[name] = id cb(id) end
    end)
end

local function findPlayer(key)
    for _, p in ipairs(Players:GetPlayers()) do
        if lower(p.Name) == key then return p end
    end
end
local function isWhite(p) return p == LP or State.W[lower(p.Name)] == true end
local function isBlack(p) return p ~= LP and State.B[lower(p.Name)] == true end

---------------------------------------------------------------- Theme
local Theme = {
    BG1 = Color3.fromRGB(14, 18, 24),   BG2 = Color3.fromRGB(20, 26, 34),   BG3 = Color3.fromRGB(26, 34, 44),
    Card = Color3.fromRGB(30, 40, 52),  CardHi = Color3.fromRGB(38, 50, 64),
    Accent = Color3.fromRGB(72, 219, 138), Accent2 = Color3.fromRGB(46, 204, 190), Gold = Color3.fromRGB(255, 200, 87),
    Text = Color3.fromRGB(240, 244, 250), TextDim = Color3.fromRGB(150, 165, 185),
    Danger = Color3.fromRGB(232, 89, 89), DangerHi = Color3.fromRGB(255, 116, 116),
    Success = Color3.fromRGB(72, 219, 138), Info = Color3.fromRGB(85, 170, 255),
    OnBG = Color3.fromRGB(28, 50, 38), Off = Color3.fromRGB(60, 68, 78),
}

local T = {
    ar = {
        title="بي حلال", subtitle="أدوات إسلامية للسيرفر",
        sectionAudio="الصوت", sectionVisual="المظهر", sectionTools="الأدوات",
        sectionPlayers="اللاعبون", sectionLists="القوائم",
        muteMusic="كتم الموسيقى", noobSkin="سكنات نوب", stopDance="إيقاف الرقصات", broadDance="كشف شامل للرقصات",
        saveSettings="حفظ إعدادات الأصوات",
        suggest="اقتراح لاعب", whitelist="المسموحون", blocked="المحجوبون",
        searchPH="ابحث عن لاعب...", on="مفعّل", off="معطّل", noPlayers="لا يوجد لاعبون",
        wl="سماح", block="حجب", empty="فارغ", footer="بي حلال",
        openMusic="🎵  مدير الأصوات", musicTitle="مدير الأصوات",
        tabPlaying="▶ الشغالة", tabMuted="🔒 المكتومة",
        allMute="🔇 كتم الكل", allUnmute="🔊 فك الكل", muteCurrent="🔇 اكتم الصوت",
        stopListen="⏹ إيقاف الاستماع",
        unmuteBtn="🔊 فك", listenShort="🎧 استمع", mute="كتم",
        none="—", namePh="اكتب الاسم ثم Enter...",
        animLog="📜  سجل الحركات", animTitle="سجل الحركات", allowedTag="مسموحة", blockedTag="محجوبة",
        animHint="كل حركة انمنعت تظهر هنا. إذا كانت من الماب اضغط عليها لتصير مسموحة.", emptyAnim="ما انمنعت أي حركة بعد",
        soundLog="🎧  سجل الأصوات", soundLogTitle="سجل الأصوات", clearLog="🗑 مسح", stopShort="⏹ إيقاف", emptyLog="ما اشتغل أي صوت بعد",
        soundHint="الأصوات اللي يكتمها زر كتم الموسيقى. 🎧 تسمعه لحاله، و🔊 تستثنيه من الكتم.",
        stPlaying="▶ شغال", stIdle="⏸ متوقف", stGone="✖ اختفى من الماب",
        catAll="الكل", catMusic="موسيقى", catAmbient="أجواء", catSfx="مؤثرات", catUi="واجهة", catOther="أخرى",
        tabAll="📚 الكل", searchSound="🔍 ابحث بالاسم أو المسار أو الـ ID...", logSearch="🔍 ابحث في السجل...",
        sortName="ترتيب: الاسم", sortLen="ترتيب: المدة", emptyFilter="ما فيه أصوات بهذا الفلتر",
        btnOn="زر كتم الموسيقى: مفعّل", btnOff="زر كتم الموسيقى: معطّل",
        exemptOn="مستثنى", exemptOff="يُكتم", stExempt="🔊 مستثنى من الكتم", stByButton="🔇 مكتوم بالزر", stWillMute="⏳ يُكتم لما تفعّل الزر",
    },
    en = {
        title="Be Halal", subtitle="Islamic server tools",
        sectionAudio="Audio", sectionVisual="Visual", sectionTools="Tools",
        sectionPlayers="Players", sectionLists="Lists",
        muteMusic="Mute Music", noobSkin="Noob Skins", stopDance="Stop Dances", broadDance="Broad Dance Detection",
        saveSettings="Save Sound Settings",
        suggest="Suggest Player", whitelist="Whitelisted", blocked="Blocked",
        searchPH="Search for player...", on="Active", off="Disabled", noPlayers="No players found",
        wl="Allow", block="Block", empty="Empty", footer="Be Halal",
        openMusic="🎵  Sound Manager", musicTitle="Sound Manager",
        tabPlaying="▶ Playing", tabMuted="🔒 Muted",
        allMute="🔇 Mute All", allUnmute="🔊 Unmute All", muteCurrent="🔇 Mute Sound",
        stopListen="⏹ Stop Listening",
        unmuteBtn="🔊 Unmute", listenShort="🎧 Listen", mute="Mute",
        none="—", namePh="Type name then Enter...",
        animLog="📜  Animation Log", animTitle="Animation Log", allowedTag="Allowed", blockedTag="Blocked",
        animHint="Every stopped animation shows here. If it belongs to the map, tap it to mark it Allowed.", emptyAnim="Nothing blocked yet",
        soundLog="🎧  Sound Log", soundLogTitle="Sound Log", clearLog="🗑 Clear", stopShort="⏹ Stop", emptyLog="No sound played yet",
        soundHint="Sounds caught by the Mute Music button. 🎧 listens to it alone, 🔊 exempts it from muting.",
        stPlaying="▶ Playing", stIdle="⏸ Idle", stGone="✖ Gone from map",
        catAll="All", catMusic="Music", catAmbient="Ambient", catSfx="Effects", catUi="UI", catOther="Other",
        tabAll="📚 All", searchSound="🔍 Search name, path or ID...", logSearch="🔍 Search the log...",
        sortName="Sort: Name", sortLen="Sort: Length", emptyFilter="No sounds match this filter",
        btnOn="Mute Music button: ON", btnOff="Mute Music button: OFF",
        exemptOn="Exempt", exemptOff="Muted", stExempt="🔊 Exempt from muting", stByButton="🔇 Muted by button", stWillMute="⏳ Will mute when button is on",
    },
}
local function tr(k) return (T[State.lang] or T.en)[k] or T.en[k] or k end

---------------------------------------------------------------- Config
local Config = {file = "BeHalal_Config.json", data = {}, queued = false}
local Audio

function Config.collect()
    local w, b, aa = {}, {}, {}
    local me = lower(LP.Name)
    for k in pairs(State.W) do if k ~= me then table.insert(w, k) end end
    for k in pairs(State.B) do if k ~= me then table.insert(b, k) end end
    for k in pairs(State.animAllow) do table.insert(aa, k) end
    return {
        muteMusic = State.muteMusic, noob = State.noob,
        dances = State.dances, broadDances = State.broadDances,
        autosave = Audio and Audio.autosave or false, W = w, B = b, animAllow = aa,
    }
end
function Config.saveNow() writeJSON(Config.file, Config.collect()) end
function Config.save()
    if not canFS or Config.queued then return end
    Config.queued = true
    task.delay(1, function()
        Config.queued = false
        Config.saveNow()
    end)
end
function Config.apply()
    local d = readJSON(Config.file) or {}
    Config.data = d
    if type(d.animAllow) == "table" then for _, k in ipairs(d.animAllow) do State.animAllow[tostring(k)] = true end end
    for _, k in ipairs({"muteMusic", "noob", "dances", "broadDances"}) do
        if type(d[k]) == "boolean" then State[k] = d[k] end
    end
    if type(d.W) == "table" then for _, n in ipairs(d.W) do State.W[lower(n)] = true end end
    if type(d.B) == "table" then for _, n in ipairs(d.B) do State.B[lower(n)] = true end end
end

---------------------------------------------------------------- Audio
Audio = {
    place = tostring(game.PlaceId), file = "BeHalal_Sounds.json",
    settings = {},
    rec = setmetatable({}, {__mode = "k"}),
    hooks = {},
    globalMute = false, solo = nil, autosave = false, dirty = false,
}
local KW = {"music","bgm","song","theme","soundtrack","radio","lofi","playlist","muzik","ambience"}

function Audio.keyOf(s)
    local id = s.SoundId
    if id and id ~= "" then
        local num = id:match("rbxassetid://(%d+)") or id:match("[?&]id=(%d+)")
        return "id:" .. (num or id)
    end
    return "path:" .. s:GetFullName()
end
function Audio.soundName(s)
    if lower(s.Name) == "sound" and s.Parent then return s.Parent.Name .. " / " .. s.Name end
    return s.Name
end
function Audio.displayName(s)
    local st = Audio.settings[Audio.keyOf(s)]
    if st and st.c then return st.c end
    return Audio.soundName(s)
end
function Audio.nameHit(s)
    local n = lower(s:GetFullName())
    for _, w in ipairs(KW) do if n:find(w, 1, true) then return true end end
    return false
end
function Audio.looksMusic(s) return (s.TimeLength or 0) > 10 or Audio.nameHit(s) end
function Audio.fmtTime(len)
    len = len or 0
    return string.format("%d:%02d", math.floor(len / 60), math.floor(len % 60))
end

function Audio.enforce(s)
    if not s.Parent then return end
    local key = Audio.keyOf(s)
    local st = Audio.settings[key]
    local muted, factor = false, 1
    if Audio.solo then
        muted = (key ~= Audio.solo)
    else
        if st and st.m then muted = true end
        if not muted and Audio.globalMute and not (st and st.x) and Audio.looksMusic(s) then muted = true end
    end
    if st then factor = st.f end

    local active = muted or math.abs(factor - 1) > 0.001
    local r = Audio.rec[s]
    if not active then
        if r then
            if r.applied ~= nil and math.abs(s.Volume - r.applied) < 0.01 then
                pcall(function() s.Volume = r.orig end)
            end
            Audio.rec[s] = nil
        end
        return
    end
    if not r then
        r = {orig = s.Volume}
        Audio.rec[s] = r
    elseif r.applied ~= nil and math.abs(s.Volume - r.applied) > 0.005 then
        if muted or factor <= 0.001 then r.orig = s.Volume else r.orig = s.Volume / factor end
    end
    local target = muted and 0 or math.clamp(r.orig * factor, 0, 10)
    r.applied = target
    if math.abs(s.Volume - target) > 0.005 then pcall(function() s.Volume = target end) end
end
function Audio.enforceAll()
    for s in pairs(Audio.hooks) do if s.Parent then Audio.enforce(s) end end
end
function Audio.hook(s)
    if Audio.hooks[s] then return end
    local j = Janitor.new()
    Audio.hooks[s] = j
    local function f() Audio.enforce(s) end
    j:Add(s:GetPropertyChangedSignal("Volume"):Connect(f))
    j:Add(s:GetPropertyChangedSignal("SoundId"):Connect(f))
    j:Add(s:GetPropertyChangedSignal("TimeLength"):Connect(f))
    j:Add(s.Played:Connect(function() f() Audio.note(s) end))
    f()
end
function Audio.sweep()
    for s, j in pairs(Audio.hooks) do
        if not s:IsDescendantOf(game) then
            j:Clean()
            Audio.hooks[s] = nil
            Audio.rec[s] = nil
        else
            Audio.enforce(s)
            if s.IsPlaying then Audio.note(s) end
        end
    end
    if Audio.dirty and Audio.autosave then
        Audio.dirty = false
        Audio.save()
    end
end

Audio.catCache = {}
function Audio.classify(s)
    local k = Audio.keyOf(s)
    local c = Audio.catCache[k]
    if c then return c end
    local len = s.TimeLength or 0
    local cat
    if s:IsDescendantOf(PG) then cat = "ui"
    elseif len <= 0 then return "other"
    elseif len >= 45 or (s.Looped and len >= 30) or (Audio.nameHit(s) and len >= 10) then cat = "music"
    elseif s.Looped then cat = "ambient"
    elseif len < 10 then cat = "sfx"
    else cat = "other" end
    Audio.catCache[k] = cat
    return cat
end

function Audio.groups()
    local now = os.clock()
    if Audio._gc and now - (Audio._gcT or 0) < 0.25 then return Audio._gc end
    local groups = {}
    for s in pairs(Audio.hooks) do
        if s.Parent then
            local k = Audio.keyOf(s)
            local g = groups[k]
            if not g then g = {key = k, count = 0, playing = false, len = 0} groups[k] = g end
            g.count = g.count + 1
            local pl = s.IsPlaying
            if pl then g.playing = true end
            if not g.rep or (pl and not g.repPlaying) then g.rep, g.repPlaying = s, pl end
            if (s.TimeLength or 0) > g.len then g.len = s.TimeLength end
        end
    end
    for _, g in pairs(groups) do
        local s = g.rep
        g.name = Audio.displayName(s)
        g.base = Audio.soundName(s)
        g.path = s.Parent and s.Parent:GetFullName() or ""
        g.looped = s.Looped
        g.cat = Audio.classify(s)
    end
    Audio._gc, Audio._gcT = groups, now
    return groups
end

Audio.log = {}
function Audio.note(s)
    if not s.Parent or not Audio.looksMusic(s) then return end
    local k = Audio.keyOf(s)
    local e = Audio.log[k]
    if not e then
        local count, oldK, oldT = 0, nil, math.huge
        for kk, ee in pairs(Audio.log) do
            count = count + 1
            local st = Audio.settings[kk]
            if ee.t < oldT and not (st and st.m) then oldK, oldT = kk, ee.t end
        end
        if count >= 60 and oldK then Audio.log[oldK] = nil end
        e = {key = k, first = os.clock(), t = 0}
        Audio.log[k] = e
    end
    e.base = Audio.soundName(s)
    e.name = Audio.displayName(s)
    e.path = s.Parent:GetFullName()
    e.len = s.TimeLength or 0
    e.looped = s.Looped
    e.t = os.clock()
end
function Audio.isLive(key)
    for s in pairs(Audio.hooks) do
        if s.Parent and Audio.keyOf(s) == key then return true end
    end
    return false
end

function Audio.entry(key, name)
    local st = Audio.settings[key]
    if not st then st = {m = false, f = 1, n = name or key} Audio.settings[key] = st end
    if name then st.n = name end
    return st
end
function Audio.commit(key)
    local st = Audio.settings[key]
    if st and not st.m and not st.c and not st.x and math.abs(st.f - 1) < 0.001 then Audio.settings[key] = nil end
    Audio._gc = nil
    if Audio.autosave then Audio.dirty = true end
    for s in pairs(Audio.hooks) do
        if s.Parent and Audio.keyOf(s) == key then Audio.enforce(s) end
    end
end

function Audio.soloPlay(key)
    Audio.solo = key
    local anyPlaying, first = false, nil
    for s in pairs(Audio.hooks) do
        if s.Parent and Audio.keyOf(s) == key then
            first = first or s
            if s.IsPlaying then anyPlaying = true end
        end
    end
    Audio.enforceAll()
    if not anyPlaying and first then pcall(function() first:Play() end) end
end
function Audio.soloStop()
    Audio.solo = nil
    Audio.enforceAll()
end
function Audio.muteCurrentSolo()
    local key = Audio.solo
    if not key then return end
    Audio.entry(key).m = true
    Audio.solo = nil
    Audio.commit(key)
    Audio.enforceAll()
end

function Audio.save()
    if not canFS then return end
    local data = readJSON(Audio.file) or {}
    local out = {}
    for k, st in pairs(Audio.settings) do
        out[k] = {m = st.m, f = st.f, n = st.n, c = st.c, x = st.x}
    end
    data[Audio.place] = out
    writeJSON(Audio.file, data)
end
function Audio.clearSaved()
    if not canFS then return end
    local data = readJSON(Audio.file) or {}
    data[Audio.place] = nil
    writeJSON(Audio.file, data)
end
function Audio.loadSaved()
    local data = readJSON(Audio.file)
    local mine = data and data[Audio.place]
    if type(mine) ~= "table" then return end
    for k, v in pairs(mine) do
        if type(v) == "table" then
            Audio.settings[k] = {
                m = v.m == true, f = tonumber(v.f) or 1, n = tostring(v.n or k), x = (v.x == true) or nil,
                c = (type(v.c) == "string" and v.c ~= "") and v.c or nil,
            }
        end
    end
end
function Audio.setAutosave(on)
    Audio.autosave = on
    if on then Audio.dirty = true else Audio.clearSaved() end
    Config.save()
end
function Audio.setGlobalMute(on)
    Audio.globalMute = on
    Audio.enforceAll()
end
function Audio.init()
    Audio.autosave = Config.data.autosave == true
    Audio.globalMute = State.muteMusic
    if Audio.autosave then Audio.loadSaved() end
    for _, c in ipairs({Workspace, SoundService, PG, Lighting}) do
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("Sound") then Audio.hook(d) end
        end
        Root:Add(c.DescendantAdded:Connect(function(d)
            if d:IsA("Sound") then Audio.hook(d) end
        end))
    end
    loop(1, Audio.sweep)
end
function Audio.shutdown()
    Audio.solo = nil
    Audio.globalMute = false
    for s, r in pairs(Audio.rec) do
        if s.Parent and r.applied ~= nil and math.abs(s.Volume - r.applied) < 0.01 then
            pcall(function() s.Volume = r.orig end)
        end
    end
    Audio.rec = setmetatable({}, {__mode = "k"})
    if Audio.autosave then Audio.save() end
    for _, j in pairs(Audio.hooks) do j:Clean() end
    Audio.hooks = {}
end

---------------------------------------------------------------- Skin
local Skin = {}
local backups = {}
local NC = {Skin = Color3.fromRGB(245,205,48), T = Color3.fromRGB(13,105,172), Lg = Color3.fromRGB(40,127,71)}
local PART_COLORS = {
    Head=NC.Skin, LeftArm=NC.Skin, RightArm=NC.Skin, Torso=NC.T, LeftLeg=NC.Lg, RightLeg=NC.Lg,
    UpperTorso=NC.T, LowerTorso=NC.T, LeftUpperArm=NC.Skin, LeftLowerArm=NC.Skin, LeftHand=NC.Skin,
    RightUpperArm=NC.Skin, RightLowerArm=NC.Skin, RightHand=NC.Skin, LeftUpperLeg=NC.Lg, LeftLowerLeg=NC.Lg,
    LeftFoot=NC.Lg, RightUpperLeg=NC.Lg, RightLowerLeg=NC.Lg, RightFoot=NC.Lg,
}
local FACE_TEX = "rbxasset://textures/face.png"

local function setProp(b, inst, prop, value)
    local rec = b.props[inst]
    if not rec then rec = {} b.props[inst] = rec end
    if rec[prop] == nil then rec[prop] = inst[prop] end
    if inst[prop] ~= value then inst[prop] = value end
end

function Skin.has(c) return backups[c] ~= nil end
function Skin.forget(c) backups[c] = nil end

function Skin.needs(c)
    local head = c:FindFirstChild("Head")
    if head then
        local f = head:FindFirstChild("BH_face")
        if not f then return true end
        for _, x in ipairs(head:GetChildren()) do
            if x:IsA("Decal") and x ~= f and x.Transparency < 1 then return true end
        end
    end
    for _, i in ipairs(c:GetChildren()) do
        if i:IsA("Shirt") then if i.ShirtTemplate ~= "" then return true end
        elseif i:IsA("Pants") then if i.PantsTemplate ~= "" then return true end
        elseif i:IsA("ShirtGraphic") then if i.Graphic ~= "" then return true end
        elseif i:IsA("CharacterMesh") then return true
        elseif i:IsA("Accoutrement") then
            local h = i:FindFirstChild("Handle")
            if h and h:IsA("BasePart") and h.Transparency < 1 then return true end
        end
    end
    for name, col in pairs(PART_COLORS) do
        local part = c:FindFirstChild(name)
        if part and part:IsA("BasePart") and not close(part.Color, col) then return true end
    end
    return false
end

function Skin.apply(c)
    if not c or not c.Parent or not c:FindFirstChildOfClass("Humanoid") then return end
    local b = backups[c]
    if not b then b = {props = {}, meshes = {}} backups[c] = b end
    for _, i in ipairs(c:GetChildren()) do
        if i:IsA("Shirt") then setProp(b, i, "ShirtTemplate", "")
        elseif i:IsA("Pants") then setProp(b, i, "PantsTemplate", "")
        elseif i:IsA("ShirtGraphic") then setProp(b, i, "Graphic", "")
        elseif i:IsA("Accoutrement") then
            local h = i:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then setProp(b, h, "Transparency", 1) end
        elseif i:IsA("CharacterMesh") then
            table.insert(b.meshes, i)
            i.Parent = nil
        end
    end
    local head = c:FindFirstChild("Head")
    if head then
        for _, x in ipairs(head:GetChildren()) do
            if x:IsA("Decal") and x.Name ~= "BH_face" then setProp(b, x, "Transparency", 1) end
        end
        if not head:FindFirstChild("BH_face") then
            b.face = N("Decal", {Name = "BH_face", Texture = FACE_TEX, Face = Enum.NormalId.Front}, head)
        end
    end
    for name, col in pairs(PART_COLORS) do
        local part = c:FindFirstChild(name)
        if part and part:IsA("BasePart") then setProp(b, part, "Color", col) end
    end
end

function Skin.restore(c)
    local b = backups[c]
    if not b then return end
    backups[c] = nil
    if b.face then pcall(function() b.face:Destroy() end) end
    for inst, props in pairs(b.props) do
        for prop, v in pairs(props) do pcall(function() inst[prop] = v end) end
    end
    for _, m in ipairs(b.meshes) do pcall(function() m.Parent = c end) end
end

---------------------------------------------------------------- Hide
local Hide = {}
local EFFECT = {ParticleEmitter = true, Trail = true, Beam = true, Fire = true, Smoke = true, Sparkles = true}

function Hide.inst(i)
    if i:IsA("BasePart") or i:IsA("Decal") then
        if i:GetAttribute("BHO") == nil then i:SetAttribute("BHO", i.Transparency) end
        if i.Transparency ~= 1 then i.Transparency = 1 end
    elseif i:IsA("BillboardGui") or i:IsA("SurfaceGui") or EFFECT[i.ClassName] then
        if i:GetAttribute("BHE") == nil then i:SetAttribute("BHE", i.Enabled) end
        if i.Enabled then i.Enabled = false end
    end
end
function Hide.apply(c)
    if not c or not c.Parent then return end
    for _, i in ipairs(c:GetDescendants()) do Hide.inst(i) end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h and h.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
        h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        h.NameDisplayDistance = 0
        h.HealthDisplayDistance = 0
    end
    c:SetAttribute("BH_Hidden", true)
end
function Hide.restore(c)
    if not c or not c.Parent or not c:GetAttribute("BH_Hidden") then return end
    for _, i in ipairs(c:GetDescendants()) do
        local o = i:GetAttribute("BHO")
        if o ~= nil then i.Transparency = o i:SetAttribute("BHO", nil) end
        local e = i:GetAttribute("BHE")
        if e ~= nil then i.Enabled = e i:SetAttribute("BHE", nil) end
    end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then
        h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        h.NameDisplayDistance = 100
        h.HealthDisplayDistance = 100
    end
    c:SetAttribute("BH_Hidden", nil)
end

---------------------------------------------------------------- Dances
local Dances = {}
local DANCE_IDS = {
    ["507771019"]=true, ["507776043"]=true, ["507777268"]=true, ["507777826"]=true, ["507771013"]=true,
    ["182435998"]=true, ["182491037"]=true, ["182491065"]=true,
}
local ACTION_PRI = {}
for _, n in ipairs({"Action", "Action2", "Action3", "Action4"}) do
    local ok, v = pcall(function() return Enum.AnimationPriority[n] end)
    if ok and v then ACTION_PRI[v] = true end
end
local emoteCache, emoteFail = {}, {}
Dances.log = {}

function Dances.isEmoteAsset(num)
    local c = emoteCache[num]
    if c ~= nil then return c == true end
    emoteCache[num] = "pending"
    task.spawn(function()
        local ok, info = pcall(function()
            return Marketplace:GetProductInfo(tonumber(num), Enum.InfoType.Asset)
        end)
        if ok and info then
            emoteCache[num] = (info.AssetTypeId == 61)
        else
            emoteFail[num] = (emoteFail[num] or 0) + 1
            if emoteFail[num] >= 2 then
                emoteCache[num] = false
            else
                task.wait(5)
                emoteCache[num] = nil
            end
        end
    end)
    return false
end

function Dances.keyOf(track)
    local a = track.Animation
    local num = a and tostring(a.AnimationId or ""):match("%d+")
    if num then return num end
    return "n:" .. lower(track.Name or "?")
end

function Dances.record(track)
    local k = Dances.keyOf(track)
    local a = track.Animation
    local e = Dances.log[k]
    if not e then
        local count, oldestK, oldestT = 0, nil, math.huge
        for kk, ee in pairs(Dances.log) do
            count = count + 1
            if ee.t < oldestT then oldestK, oldestT = kk, ee.t end
        end
        if count >= 30 and oldestK then Dances.log[oldestK] = nil end
        e = {key = k, name = (a and a.Name ~= "" and a.Name) or track.Name or "?", n = 0, t = 0}
        Dances.log[k] = e
    end
    e.n = e.n + 1
    e.t = os.clock()
end

function Dances.isDance(track, char)
    if not track then return false end
    if State.animAllow[Dances.keyOf(track)] then return false end
    local a = track.Animation
    local num = a and tostring(a.AnimationId or ""):match("%d+")
    if num then
        if DANCE_IDS[num] then return true end
        if Dances.isEmoteAsset(num) then return true end
    end
    local inTool = a and a.Parent and a:FindFirstAncestorOfClass("Tool") ~= nil
    local own = a and a.Parent and char and a:IsDescendantOf(char) and not inTool
    if own then
        local names = {lower(track.Name or ""), lower(a.Name or ""), lower(a.Parent.Name)}
        for _, n in ipairs(names) do
            if n:find("dance") or n:find("emote") then return true end
        end
    end
    if State.broadDances and ACTION_PRI[track.Priority] and not inTool then
        return true
    end
    return false
end

function Dances.shouldStop(p) return p ~= LP and not isWhite(p) end
function Dances.stop(t)
    Dances.record(t)
    pcall(function() t:AdjustWeight(0, 0) end)
    pcall(function() t:AdjustSpeed(0) end)
    pcall(function() t:Stop(0) end)
end
function Dances.sweepChar(c)
    local h = c:FindFirstChildOfClass("Humanoid")
    local a = h and h:FindFirstChildOfClass("Animator")
    if not a then return end
    for _, t in ipairs(a:GetPlayingAnimationTracks()) do
        if Dances.isDance(t, c) then Dances.stop(t) end
    end
end
function Dances.hookChar(c, p, j)
    task.spawn(function()
        local h = c:WaitForChild("Humanoid", 5)
        if not h then return end
        local a = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 5)
        if not a then return end
        j:Add(a.AnimationPlayed:Connect(function(t)
            if State.running and State.dances and Dances.shouldStop(p) and Dances.isDance(t, c) then
                Dances.stop(t)
            end
        end))
    end)
end

---------------------------------------------------------------- Targets
local Targets = {}
local PS = {}
local UI = {refresh = function() end}

function Targets.refresh(p)
    if p == LP then return end
    local c = p.Character
    if not c or not c.Parent then return end
    if isBlack(p) then
        Hide.apply(c)
        if Skin.has(c) then Skin.restore(c) end
    else
        Hide.restore(c)
        if State.noob and not isWhite(p) then
            if Skin.needs(c) then Skin.apply(c) end
        elseif Skin.has(c) then
            Skin.restore(c)
        end
    end
end
function Targets.refreshAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if PS[p] then Targets.refresh(p) end
    end
end
function Targets.setup(p)
    if p == LP or PS[p] or not State.running then return end
    local st = {pj = Janitor.new(), cj = Janitor.new()}
    PS[p] = st
    local function onChar(c)
        st.cj:Clean()
        local pending = false
        st.cj:Add(c.DescendantAdded:Connect(function(d)
            if isBlack(p) then pcall(Hide.inst, d) end
            if pending then return end
            pending = true
            task.delay(0.1, function()
                pending = false
                if State.running and PS[p] then Targets.refresh(p) end
            end)
        end))
        Dances.hookChar(c, p, st.cj)
        task.spawn(function()
            c:WaitForChild("Humanoid", 5)
            task.wait(0.3)
            if State.running and PS[p] and c.Parent then Targets.refresh(p) end
        end)
    end
    st.pj:Add(p.CharacterAdded:Connect(onChar))
    st.pj:Add(p.CharacterRemoving:Connect(function(c)
        Skin.forget(c)
        st.cj:Clean()
    end))
    if p.Character then task.spawn(onChar, p.Character) end
end
function Targets.remove(p)
    local st = PS[p]
    if not st then return end
    st.pj:Clean() st.cj:Clean()
    PS[p] = nil
end
function Targets.shutdown()
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p.Character
        if c then pcall(Skin.restore, c) pcall(Hide.restore, c) end
    end
    for p in pairs(PS) do Targets.remove(p) end
end

local function onPlayer(p)
    if p == LP then return end
    local ok, fr = pcall(function() return LP:IsFriendsWith(p.UserId) end)
    if ok and fr and not State.B[lower(p.Name)] then State.W[lower(p.Name)] = true end
    Targets.setup(p)
    UI.refresh()
end

---------------------------------------------------------------- Lists
local function resolveName(text)
    text = trim(text)
    if text == "" then return nil end
    local lt, prefix = lower(text), nil
    for _, p in ipairs(Players:GetPlayers()) do
        local un, dn = lower(p.Name), lower(p.DisplayName)
        if un == lt or dn == lt then return p.Name end
        if not prefix and (un:sub(1, #lt) == lt or dn:sub(1, #lt) == lt) then prefix = p.Name end
    end
    return prefix or text
end
local function listSet(name, mode)
    local k = lower(name)
    if k == lower(LP.Name) then return end
    State.W[k] = (mode == "white") or nil
    State.B[k] = (mode == "black") or nil
    local p = findPlayer(k)
    if p then Targets.refresh(p) end
    Config.save()
    UI.refresh()
end

---------------------------------------------------------------- UI helpers
local UILib = {}
function UILib.corner(o, r) return N("UICorner", {CornerRadius = UDim.new(0, r or 12)}, o) end
function UILib.stroke(o, col, th, tp) return N("UIStroke", {Color = col or Theme.Accent, Thickness = th or 1.5, Transparency = tp or 0}, o) end
function UILib.gradient(o, c1, c2, rot) return N("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 90}, o) end
function UILib.padding(o, a)
    return N("UIPadding", {PaddingTop = UDim.new(0, a), PaddingBottom = UDim.new(0, a), PaddingLeft = UDim.new(0, a), PaddingRight = UDim.new(0, a)}, o)
end
function UILib.hover(btn, base, hi, j)
    j:Add(btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hi}):Play() end))
    j:Add(btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play() end))
end
function UILib.drawX(parent, color, size, thick)
    for _, rot in ipairs({45, -45}) do
        local l = N("Frame", {
            Size = UDim2.new(0, size, 0, thick), Position = UDim2.new(0.5, -size / 2, 0.5, -thick / 2),
            BackgroundColor3 = color, BorderSizePixel = 0, Rotation = rot, ZIndex = 8,
        }, parent)
        UILib.corner(l, 99)
    end
end
local WHITE = Color3.new(1, 1, 1)
local DARK = Color3.fromRGB(10, 24, 16)
local function Btn(parent, props, radius)
    local p = {BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextColor3 = WHITE, TextSize = 11}
    for k, v in pairs(props) do p[k] = v end
    local b = N("TextButton", p, parent)
    UILib.corner(b, radius or 8)
    return b
end
local function Label(parent, props)
    local p = {BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}
    for k, v in pairs(props) do p[k] = v end
    return N("TextLabel", p, parent)
end
local function isMobile() return UIS.TouchEnabled and not UIS.KeyboardEnabled end
local function viewport()
    local cam = Workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function makeDraggable(handle, target, j, onMove)
    local st = {moved = false}
    local dragging, startIn, startPos = false, nil, nil
    handle.Active = true
    j:Add(handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, st.moved = true, false
            startIn, startPos = i.Position, target.Position
            local conn
            conn = i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end))
    j:Add(UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - startIn
        if d.Magnitude > 5 then st.moved = true end
        target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        if onMove then onMove() end
    end))
    return st
end

local function makeSlider(parent, pos, size, J, onChange)
    local hit = N("TextButton", {Size = size, Position = pos, BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, parent)
    local track = N("Frame", {Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0}, hit)
    UILib.corner(track, 3)
    local fill = N("Frame", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0}, track)
    UILib.corner(fill, 3)
    UILib.gradient(fill, Theme.Accent, Theme.Accent2, 0)
    local knob = N("Frame", {Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = Theme.Accent2, BorderSizePixel = 0}, hit)
    UILib.corner(knob, 8)
    UILib.stroke(knob, Theme.BG1, 2, 0)
    local sl = {value = 1, max = 2, dragging = false}
    local conns = {}
    local function dropConns()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end
    J:Add(dropConns)
    function sl.set(v)
        sl.value = math.clamp(v, 0, sl.max)
        local a = sl.value / sl.max
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
    end
    local function fromInput(x)
        local w = track.AbsoluteSize.X
        if w <= 0 then return end
        local a = math.clamp((x - track.AbsolutePosition.X) / w, 0, 1)
        local v = math.floor(a * sl.max / 0.05 + 0.5) * 0.05
        sl.set(v)
        if onChange then onChange(v) end
    end
    J:Add(hit.InputBegan:Connect(function(i)
        if sl.dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sl.dragging = true
            fromInput(i.Position.X)
            table.insert(conns, UIS.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    fromInput(inp.Position.X)
                end
            end))
            table.insert(conns, UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sl.dragging = false
                    dropConns()
                end
            end))
        end
    end))
    return sl
end

---------------------------------------------------------------- Language screen
local function showLangScreen(onDone)
    local mobile = isMobile()
    local gui = Root:Add(N("ScreenGui", {Name = "BHLang", ResetOnSpawn = false, IgnoreGuiInset = mobile, DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local chosen = false
    N("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(5, 8, 12), BackgroundTransparency = 0.35, BorderSizePixel = 0}, gui)
    local cw, ch = mobile and 300 or 400, 370
    local card = N("Frame", {Size = UDim2.new(0, cw, 0, ch), Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2 + 60), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true}, gui)
    UILib.corner(card, 24)
    UILib.gradient(card, Color3.fromRGB(22, 30, 40), Color3.fromRGB(12, 18, 24), 135)
    UILib.stroke(card, Theme.Accent, 1.5, 0.3)

    local logo = N("Frame", {Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0.5, -40, 0, 22), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0}, card)
    UILib.corner(logo, 40) UILib.stroke(logo, Theme.Accent, 2, 0.2)
    Label(logo, {Size = UDim2.new(1, 0, 1, 0), Text = "🕌", TextSize = 42, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center})
    Label(card, {Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 112), Text = "بي حلال · Be Halal", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Theme.Accent2, TextXAlignment = Enum.TextXAlignment.Center})
    Label(card, {Size = UDim2.new(1, -30, 0, 18), Position = UDim2.new(0, 15, 0, 146), Text = "اختر اللغة  •  Select Language", TextColor3 = Theme.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center})

    local function mkb(text, flag, desc, y, lang, col)
        local bc = N("Frame", {Size = UDim2.new(1, -60, 0, 76), Position = UDim2.new(0, 30, 0, y), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, card)
        UILib.corner(bc, 16) UILib.stroke(bc, col, 1.5, 0.4)
        local fb = N("Frame", {Size = UDim2.new(0, 48, 0, 48), Position = UDim2.new(0, 14, 0.5, -24), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0}, bc)
        UILib.corner(fb, 12)
        Label(fb, {Size = UDim2.new(1, 0, 1, 0), Text = flag, TextSize = 26, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center})
        Label(bc, {Size = UDim2.new(1, -100, 0, 22), Position = UDim2.new(0, 72, 0, 16), Text = text, Font = Enum.Font.GothamBold, TextSize = 18})
        Label(bc, {Size = UDim2.new(1, -100, 0, 16), Position = UDim2.new(0, 72, 0, 40), Text = desc, TextColor3 = Theme.TextDim, TextSize = 11})
        Label(bc, {Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -36, 0, 0), Text = "›", TextColor3 = col, Font = Enum.Font.GothamBold, TextSize = 30, TextXAlignment = Enum.TextXAlignment.Center})
        local b = N("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, bc)
        b.Activated:Connect(function()
            if chosen then return end
            chosen = true
            TweenService:Create(card, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2 + 80)}):Play()
            task.wait(0.25)
            gui:Destroy()
            onDone(lang)
        end)
    end
    mkb("العربية", "🇸🇦", "واجهة عربية كاملة", 185, "ar", Theme.Accent)
    mkb("English", "🇬🇧", "Full English interface", 270, "en", Theme.Accent2)
    TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2)}):Play()
end

---------------------------------------------------------------- Sound manager
local CATS = {"music", "ambient", "sfx", "ui", "other"}
local CAT_KEY = {music = "catMusic", ambient = "catAmbient", sfx = "catSfx", ui = "catUi", other = "catOther"}
local CAT_ICON = {music = "🎵", ambient = "🌿", sfx = "💥", ui = "🖱", other = "📦"}
local CAT_COLOR = {
    music = Theme.Accent, ambient = Theme.Accent2, sfx = Theme.Gold,
    ui = Theme.Info, other = Theme.TextDim,
}

local function padChip(b)
    N("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, b)
end
local function sortByName(arr, nameOf, keyOf)
    table.sort(arr, function(a, b)
        local na, nb = lower(nameOf(a)), lower(nameOf(b))
        if na ~= nb then return na < nb end
        return keyOf(a) < keyOf(b)
    end)
end

local function buildSoundManager(J, vp)
    local MG = J:Add(N("ScreenGui", {Name = "BH_SoundsMgr", ResetOnSpawn = false, DisplayOrder = 60, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local pw, ph = math.min(340, vp.X - 20), math.min(540, vp.Y - 40)
    local panel = N("Frame", {Size = UDim2.new(0, pw, 0, ph), Position = UDim2.new(0.5, -pw / 2, 0.5, -ph / 2), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, Visible = false}, MG)
    UILib.corner(panel, 18) UILib.gradient(panel, Theme.BG1, Theme.BG3, 135) UILib.stroke(panel, Theme.Accent, 1.5, 0.35)

    local top = N("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1}, panel)
    makeDraggable(top, panel, J)
    Label(top, {Size = UDim2.new(1, -60, 0, 32), Position = UDim2.new(0, 14, 0, 8), Text = tr("musicTitle"), TextColor3 = Theme.Accent2, Font = Enum.Font.GothamBold, TextSize = 15})
    local closeB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 10), BackgroundColor3 = Theme.Card, Text = "✕", TextColor3 = Theme.Danger, TextSize = 14}, 13)
    UILib.stroke(closeB, Theme.Danger, 1.5, 0.5)
    J:Add(closeB.Activated:Connect(function() panel.Visible = false end))

    local searchF = N("Frame", {Size = UDim2.new(1, -120, 0, 28), Position = UDim2.new(0, 14, 0, 46), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0}, panel)
    UILib.corner(searchF, 8)
    local searchBox = N("TextBox", {
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = tr("searchSound"),
        TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd,
    }, searchF)
    local sortB = Btn(panel, {Size = UDim2.new(0, 92, 0, 28), Position = UDim2.new(1, -106, 0, 46), BackgroundColor3 = Theme.BG3, TextColor3 = Theme.Text, TextSize = 10}, 8)
    UILib.stroke(sortB, Theme.TextDim, 1, 0.5)

    local chipStrip = N("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 78), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X,
    }, panel)
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, chipStrip)
    local chipOrder = {"all", "music", "ambient", "sfx", "ui", "other"}
    local chips = {}

    local tabsF = N("Frame", {Size = UDim2.new(1, -28, 0, 28), Position = UDim2.new(0, 14, 0, 112), BackgroundTransparency = 1}, panel)
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, tabsF)
    local tabBtns = {}

    local allBtn = Btn(panel, {Size = UDim2.new(1, -28, 0, 26), Position = UDim2.new(0, 14, 0, 144), BackgroundColor3 = Theme.Danger, Text = tr("allMute")})
    local stopSoloB = Btn(panel, {Size = UDim2.new(0.5, -20, 0, 26), Position = UDim2.new(0.5, 6, 0, 144), BackgroundColor3 = Theme.Info, Text = tr("stopListen"), Visible = false})

    local list = N("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -186), Position = UDim2.new(0, 10, 0, 176), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)
    UILib.corner(list, 12) UILib.padding(list, 6)
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)

    local headers = {}
    for i, c in ipairs(CATS) do
        local hf = N("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = i * 10000, Visible = false}, list)
        local lbl = Label(hf, {Size = UDim2.new(1, -6, 1, 0), Position = UDim2.new(0, 4, 0, 0), TextColor3 = CAT_COLOR[c], Font = Enum.Font.GothamBold})
        headers[c] = {frame = hf, lbl = lbl}
    end
    local empty = Label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyFilter"), TextColor3 = Theme.TextDim, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    local tab, catFilter, query, sortMode = "playing", "all", "", "name"
    local rows, curGroups, visibleKeys = {}, {}, {}
    local refresh

    local function makeRow(k)
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 80), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, Visible = false}, list)
        UILib.corner(row, 10)
        local rowStroke = UILib.stroke(row, Theme.Accent, 1, 0.7)
        local icon = Label(row, {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 8, 0, 6), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center})
        local nameLbl = Label(row, {Size = UDim2.new(1, -150, 0, 18), Position = UDim2.new(0, 32, 0, 8), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd})
        local nameBox = N("TextBox", {
            Size = UDim2.new(1, -150, 0, 20), Position = UDim2.new(0, 32, 0, 6), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, Text = "",
            PlaceholderText = tr("namePh"), TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Visible = false,
        }, row)
        UILib.corner(nameBox, 6)
        local metaLbl = Label(row, {Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 10, 0, 30), TextColor3 = Theme.TextDim, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd})
        local editB = Btn(row, {Size = UDim2.new(0, 26, 0, 24), Position = UDim2.new(1, -112, 0, 5), BackgroundColor3 = Theme.BG3, Text = "✏️", TextSize = 12}, 6)
        local muteB = Btn(row, {Size = UDim2.new(0, 76, 0, 24), Position = UDim2.new(1, -82, 0, 5), TextSize = 10}, 6)
        Label(row, {Size = UDim2.new(0, 20, 0, 24), Position = UDim2.new(0, 8, 0, 48), Text = "🔉", TextSize = 13})
        local pctL = Label(row, {Size = UDim2.new(0, 40, 0, 24), Position = UDim2.new(1, -130, 0, 48), Text = "100%", Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right})
        local listenB = Btn(row, {Size = UDim2.new(0, 76, 0, 24), Position = UDim2.new(1, -86, 0, 48), TextSize = 10}, 6)
        local slider = makeSlider(row, UDim2.new(0, 30, 0, 48), UDim2.new(1, -168, 0, 24), J, function(v)
            local g = curGroups[k]
            local st = Audio.entry(k, g and g.base)
            st.f = v
            Audio.commit(k)
            pctL.Text = math.floor(v * 100 + 0.5) .. "%"
        end)

        J:Add(muteB.Activated:Connect(function()
            local g = curGroups[k]
            local st = Audio.entry(k, g and g.base)
            st.m = not st.m
            Audio.commit(k)
            refresh()
        end))
        J:Add(listenB.Activated:Connect(function()
            if Audio.solo == k then
                Audio.soloStop()
            elseif curGroups[k] and curGroups[k].count > 0 then
                Audio.soloPlay(k)
            end
            refresh()
        end))
        J:Add(editB.Activated:Connect(function()
            local st = Audio.settings[k]
            local g = curGroups[k]
            nameBox.Text = (st and st.c) or (g and g.base) or ""
            nameLbl.Visible, nameBox.Visible = false, true
            nameBox:CaptureFocus()
        end))
        J:Add(nameBox.FocusLost:Connect(function()
            local t2 = string.sub(trim(nameBox.Text), 1, 40)
            local g = curGroups[k]
            local st = Audio.entry(k, g and g.base)
            st.c = (t2 ~= "") and t2 or nil
            Audio.commit(k)
            nameBox.Visible, nameLbl.Visible = false, true
            refresh()
        end))

        local r = {frame = row}
        function r.update(g)
            local st = Audio.settings[k]
            local muted = st and st.m == true
            local f = st and st.f or 1
            icon.Text = CAT_ICON[g.cat]
            if not nameBox.Visible then nameLbl.Text = g.name end
            local meta = tr(CAT_KEY[g.cat])
            if g.len > 0 then meta = meta .. "  ·  ⏱ " .. Audio.fmtTime(g.len) end
            if g.looped then meta = meta .. " 🔁" end
            if g.count > 1 then meta = meta .. "  ·  ×" .. g.count end
            meta = meta .. "  ·  " .. (g.playing and "▶" or "⏸") .. "  ·  " .. g.path
            metaLbl.Text = meta
            if not slider.dragging then slider.set(f) end
            pctL.Text = math.floor(f * 100 + 0.5) .. "%"
            if muted then
                muteB.Text, muteB.BackgroundColor3, muteB.TextColor3 = tr("unmuteBtn"), Theme.Success, DARK
            else
                muteB.Text, muteB.BackgroundColor3, muteB.TextColor3 = "🔇 " .. tr("mute"), Theme.Danger, WHITE
            end
            if Audio.solo == k then
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("stopShort"), Theme.Gold, DARK
            elseif g.count > 0 then
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("listenShort"), Theme.Info, WHITE
            else
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("listenShort"), Theme.BG3, Theme.TextDim
            end
            rowStroke.Color = muted and Theme.Danger or CAT_COLOR[g.cat]
        end
        return r
    end

    refresh = function()
        local groups = {}
        for k, g in pairs(Audio.groups()) do groups[k] = g end
        for k, st in pairs(Audio.settings) do
            if st.m and not groups[k] then
                groups[k] = {key = k, count = 0, playing = false, len = 0, name = st.c or st.n or k, base = st.n or k, path = "—", looped = false, cat = Audio.catCache[k] or "other"}
            end
        end
        curGroups = groups

        local nPlaying, nAll, nMuted = 0, 0, 0
        local catCount = {all = 0, music = 0, ambient = 0, sfx = 0, ui = 0, other = 0}
        local byCat = {music = {}, ambient = {}, sfx = {}, ui = {}, other = {}}
        for k, g in pairs(groups) do
            local st = Audio.settings[k]
            local muted = st and st.m
            if g.count > 0 then nAll = nAll + 1 end
            if g.playing then nPlaying = nPlaying + 1 end
            if muted then nMuted = nMuted + 1 end
            local ok
            if tab == "muted" then ok = muted
            elseif tab == "playing" then ok = g.playing
            else ok = g.count > 0 end
            if ok and query ~= "" then
                ok = lower(g.name .. " " .. g.path .. " " .. k):find(query, 1, true) ~= nil
            end
            if ok then
                catCount.all = catCount.all + 1
                catCount[g.cat] = catCount[g.cat] + 1
                if catFilter == "all" or catFilter == g.cat then table.insert(byCat[g.cat], g) end
            end
        end

        visibleKeys = {}
        local shown = {}
        for ci, c in ipairs(CATS) do
            local arr = byCat[c]
            if sortMode == "len" then
                table.sort(arr, function(a, b)
                    if a.len ~= b.len then return a.len > b.len end
                    return a.key < b.key
                end)
            else
                sortByName(arr, function(g) return g.name end, function(g) return g.key end)
            end
            for i, g in ipairs(arr) do
                local r = rows[g.key]
                if not r then r = makeRow(g.key) rows[g.key] = r end
                r.frame.LayoutOrder = ci * 10000 + i
                r.frame.Visible = true
                r.update(g)
                shown[g.key] = true
                table.insert(visibleKeys, g.key)
            end
            local h = headers[c]
            h.frame.Visible = #arr > 0
            h.lbl.Text = CAT_ICON[c] .. " " .. tr(CAT_KEY[c]) .. "  (" .. #arr .. ")"
        end
        local hiddenList = {}
        for k, r in pairs(rows) do
            if not shown[k] then
                if not groups[k] then
                    r.frame:Destroy()
                    rows[k] = nil
                else
                    r.frame.Visible = false
                    table.insert(hiddenList, k)
                end
            end
        end
        if #hiddenList > 150 then
            for _, k in ipairs(hiddenList) do rows[k].frame:Destroy() rows[k] = nil end
        end

        for _, c in ipairs(chipOrder) do
            local b = chips[c]
            local label = (c == "all") and tr("catAll") or (CAT_ICON[c] .. " " .. tr(CAT_KEY[c]))
            b.Text = label .. " " .. catCount[c]
            local on = (catFilter == c)
            b.BackgroundColor3 = on and (c == "all" and Theme.Accent or CAT_COLOR[c]) or Theme.BG3
            b.TextColor3 = on and DARK or Theme.Text
        end
        tabBtns.playing.Text = tr("tabPlaying") .. " (" .. nPlaying .. ")"
        tabBtns.all.Text = tr("tabAll") .. " (" .. nAll .. ")"
        tabBtns.muted.Text = tr("tabMuted") .. " (" .. nMuted .. ")"
        for t, b in pairs(tabBtns) do
            local on = (tab == t)
            b.BackgroundColor3 = on and (t == "muted" and Theme.Danger or Theme.Accent) or Theme.BG3
            b.TextColor3 = on and (t == "muted" and WHITE or DARK) or Theme.Text
        end
        if Audio.solo then
            stopSoloB.Visible = true
            allBtn.Size = UDim2.new(0.5, -20, 0, 26)
            allBtn.Text, allBtn.BackgroundColor3 = tr("muteCurrent"), Theme.Danger
            allBtn.TextColor3 = WHITE
        else
            stopSoloB.Visible = false
            allBtn.Size = UDim2.new(1, -28, 0, 26)
            if tab == "muted" then
                allBtn.Text, allBtn.BackgroundColor3, allBtn.TextColor3 = tr("allUnmute") .. " (" .. #visibleKeys .. ")", Theme.Success, DARK
            else
                allBtn.Text, allBtn.BackgroundColor3, allBtn.TextColor3 = tr("allMute") .. " (" .. #visibleKeys .. ")", Theme.Danger, WHITE
            end
        end
        sortB.Text = (sortMode == "name") and tr("sortName") or tr("sortLen")
        empty.Visible = (#visibleKeys == 0)
    end

    for i, c in ipairs(chipOrder) do
        local b = Btn(chipStrip, {Size = UDim2.new(0, 50, 0, 26), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.BG3, TextColor3 = Theme.Text, TextSize = 11, LayoutOrder = i}, 13)
        padChip(b)
        chips[c] = b
        J:Add(b.Activated:Connect(function() catFilter = c refresh() end))
    end
    for i, t in ipairs({"playing", "all", "muted"}) do
        local b = Btn(tabsF, {Size = UDim2.new(1 / 3, -4, 1, 0), BackgroundColor3 = Theme.BG3, TextColor3 = Theme.Text, TextSize = 11, LayoutOrder = i}, 8)
        tabBtns[t] = b
        J:Add(b.Activated:Connect(function() tab = t refresh() end))
    end

    J:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        query = lower(trim(searchBox.Text))
        refresh()
    end))
    J:Add(sortB.Activated:Connect(function()
        sortMode = (sortMode == "name") and "len" or "name"
        refresh()
    end))
    J:Add(allBtn.Activated:Connect(function()
        if Audio.solo then
            Audio.muteCurrentSolo()
        else
            local snap = {}
            for _, k in ipairs(visibleKeys) do table.insert(snap, k) end
            for _, k in ipairs(snap) do
                if tab == "muted" then
                    local st = Audio.settings[k]
                    if st then st.m = false end
                else
                    local g = curGroups[k]
                    Audio.entry(k, g and g.base).m = true
                end
                Audio.commit(k)
            end
        end
        refresh()
    end))
    J:Add(stopSoloB.Activated:Connect(function()
        Audio.soloStop()
        refresh()
    end))

    local alive = true
    J:Add(function() alive = false end)
    task.spawn(function()
        while alive and State.running do
            task.wait(0.5)
            if panel.Visible then pcall(refresh) end
        end
    end)
    return panel, refresh
end

---------------------------------------------------------------- Sound log
local function buildSoundLog(J, vp)
    local SG = J:Add(N("ScreenGui", {Name = "BH_SoundLog", ResetOnSpawn = false, DisplayOrder = 62, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local pw, ph = math.min(340, vp.X - 20), math.min(500, vp.Y - 40)
    local panel = N("Frame", {Size = UDim2.new(0, pw, 0, ph), Position = UDim2.new(0.5, -pw / 2 + 12, 0.5, -ph / 2 + 12), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, Visible = false}, SG)
    UILib.corner(panel, 18) UILib.gradient(panel, Theme.BG1, Theme.BG3, 135) UILib.stroke(panel, Theme.Accent2, 1.5, 0.4)
    local top = N("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1}, panel)
    makeDraggable(top, panel, J)
    Label(top, {Size = UDim2.new(1, -80, 0, 28), Position = UDim2.new(0, 14, 0, 8), Text = tr("soundLogTitle"), TextColor3 = Theme.Accent2, Font = Enum.Font.GothamBold, TextSize = 15})
    local closeB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 8), BackgroundColor3 = Theme.Card, Text = "✕", TextColor3 = Theme.Danger, TextSize = 14}, 13)
    UILib.stroke(closeB, Theme.Danger, 1.5, 0.5)
    J:Add(closeB.Activated:Connect(function() panel.Visible = false end))

    local banner = Label(panel, {Size = UDim2.new(1, -28, 0, 18), Position = UDim2.new(0, 14, 0, 40), Font = Enum.Font.GothamBold, TextSize = 11})
    local searchF = N("Frame", {Size = UDim2.new(1, -112, 0, 28), Position = UDim2.new(0, 14, 0, 62), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0}, panel)
    UILib.corner(searchF, 8)
    local searchBox = N("TextBox", {
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = tr("logSearch"),
        TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    }, searchF)
    local clearB = Btn(panel, {Size = UDim2.new(0, 84, 0, 28), Position = UDim2.new(1, -98, 0, 62), BackgroundColor3 = Theme.BG3, Text = tr("clearLog"), TextColor3 = Theme.Text}, 8)
    UILib.stroke(clearB, Theme.TextDim, 1, 0.5)

    local hint = Label(panel, {Size = UDim2.new(1, -28, 0, 34), Position = UDim2.new(0, 14, 0, 96), Text = tr("soundHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})
    local bar = N("Frame", {Size = UDim2.new(1, -28, 0, 34), Position = UDim2.new(0, 14, 0, 96), BackgroundTransparency = 1, Visible = false}, panel)
    local stopB = Btn(bar, {Size = UDim2.new(0, 130, 0, 28), Position = UDim2.new(0, 0, 0, 3), BackgroundColor3 = Theme.Info, Text = tr("stopListen"), TextSize = 10})
    local pctL = Label(bar, {Size = UDim2.new(0, 48, 0, 28), Position = UDim2.new(1, -48, 0, 3), Text = "100%", Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right})
    local soloSlider = makeSlider(bar, UDim2.new(0, 140, 0, 3), UDim2.new(1, -196, 0, 28), J, function(v)
        local k = Audio.solo
        if not k then return end
        local e = Audio.log[k]
        local st = Audio.entry(k, e and e.base)
        st.f = v
        Audio.commit(k)
        pctL.Text = math.floor(v * 100 + 0.5) .. "%"
    end)

    local list = N("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -144), Position = UDim2.new(0, 10, 0, 134), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)
    UILib.corner(list, 12) UILib.padding(list, 6)
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    local empty = Label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyLog"), TextColor3 = Theme.TextDim, LayoutOrder = 9999, TextXAlignment = Enum.TextXAlignment.Center})

    local rows, query = {}, ""
    local refresh
    local function makeRow(k)
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 66), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, list)
        UILib.corner(row, 10)
        local rowStroke = UILib.stroke(row, Theme.Accent2, 1, 0.7)
        local nameL = Label(row, {Size = UDim2.new(1, -176, 0, 18), Position = UDim2.new(0, 10, 0, 6), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd})
        local pathL = Label(row, {Size = UDim2.new(1, -176, 0, 12), Position = UDim2.new(0, 10, 0, 26), TextColor3 = Theme.TextDim, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd})
        local statL = Label(row, {Size = UDim2.new(1, -176, 0, 12), Position = UDim2.new(0, 10, 0, 44), TextColor3 = Theme.TextDim, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd})
        local listenB = Btn(row, {Size = UDim2.new(0, 76, 0, 26), Position = UDim2.new(1, -166, 0.5, -13), TextSize = 10}, 6)
        local exemptB = Btn(row, {Size = UDim2.new(0, 76, 0, 26), Position = UDim2.new(1, -86, 0.5, -13), TextSize = 10}, 6)
        J:Add(listenB.Activated:Connect(function()
            if Audio.solo == k then Audio.soloStop()
            elseif Audio.isLive(k) then Audio.soloPlay(k) end
            refresh()
        end))
        J:Add(exemptB.Activated:Connect(function()
            local e = Audio.log[k]
            local st = Audio.entry(k, e and e.base)
            st.x = (not st.x) or nil
            Audio.commit(k)
            refresh()
        end))
        local r = {frame = row}
        function r.update(e, g)
            local st = Audio.settings[k]
            local exempt = st and st.x
            local live = g ~= nil
            nameL.Text = g and g.name or e.name or k
            local cat = Audio.catCache[k]
            pathL.Text = (cat and (CAT_ICON[cat] .. " ") or "") .. (e.path or "") .. "  ·  ⏱ " .. Audio.fmtTime(e.len) .. (e.looped and " 🔁" or "") .. ((g and g.count > 1) and ("  ·  ×" .. g.count) or "")
            local state = exempt and tr("stExempt") or (State.muteMusic and tr("stByButton") or tr("stWillMute"))
            local play = (not live) and tr("stGone") or (g.playing and tr("stPlaying") or tr("stIdle"))
            statL.Text = state .. "  ·  " .. play
            if Audio.solo == k then
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("stopShort"), Theme.Gold, DARK
            elseif live then
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("listenShort"), Theme.Info, WHITE
            else
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("listenShort"), Theme.BG3, Theme.TextDim
            end
            if exempt then
                exemptB.Text, exemptB.BackgroundColor3, exemptB.TextColor3 = "🔊 " .. tr("exemptOn"), Theme.Success, DARK
            else
                exemptB.Text, exemptB.BackgroundColor3, exemptB.TextColor3 = "🔇 " .. tr("exemptOff"), Theme.Danger, WHITE
            end
            rowStroke.Color = exempt and Theme.Success or Theme.Accent2
        end
        return r
    end

    refresh = function()
        banner.Text = State.muteMusic and tr("btnOn") or tr("btnOff")
        banner.TextColor3 = State.muteMusic and Theme.Success or Theme.TextDim
        local soloK = Audio.solo
        bar.Visible, hint.Visible = soloK ~= nil, soloK == nil
        if soloK then
            local st = Audio.settings[soloK]
            local f = st and st.f or 1
            if not soloSlider.dragging then soloSlider.set(f) end
            pctL.Text = math.floor(f * 100 + 0.5) .. "%"
        end
        local groups = Audio.groups()
        local arr = {}
        for k, e in pairs(Audio.log) do
            local g = groups[k]
            local hay = lower((g and g.name or e.name or "") .. " " .. (e.path or "") .. " " .. k)
            if query == "" or hay:find(query, 1, true) then table.insert(arr, k) end
        end
        sortByName(arr, function(k) local g = groups[k] return g and g.name or Audio.log[k].name or k end, function(k) return k end)
        local seen = {}
        for i, k in ipairs(arr) do
            local r = rows[k]
            if not r then r = makeRow(k) rows[k] = r end
            r.frame.LayoutOrder = i
            r.update(Audio.log[k], groups[k])
            seen[k] = true
        end
        for k, r in pairs(rows) do
            if not seen[k] then r.frame:Destroy() rows[k] = nil end
        end
        empty.Visible = (#arr == 0)
    end

    J:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        query = lower(trim(searchBox.Text))
        refresh()
    end))
    J:Add(clearB.Activated:Connect(function()
        Audio.log = {}
        refresh()
    end))
    J:Add(stopB.Activated:Connect(function()
        Audio.soloStop()
        refresh()
    end))
    local alive = true
    J:Add(function() alive = false end)
    task.spawn(function()
        while alive and State.running do
            task.wait(0.5)
            if panel.Visible then pcall(refresh) end
        end
    end)
    return panel, refresh
end

---------------------------------------------------------------- Animation log
local function buildAnimLog(J, vp)
    local AG = J:Add(N("ScreenGui", {Name = "BH_AnimLog", ResetOnSpawn = false, DisplayOrder = 61, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local pw, ph = math.min(320, vp.X - 20), math.min(440, vp.Y - 40)
    local panel = N("Frame", {Size = UDim2.new(0, pw, 0, ph), Position = UDim2.new(0.5, -pw / 2, 0.5, -ph / 2), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, Visible = false}, AG)
    UILib.corner(panel, 18) UILib.gradient(panel, Theme.BG1, Theme.BG3, 135) UILib.stroke(panel, Theme.Gold, 1.5, 0.4)
    local top = N("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1}, panel)
    makeDraggable(top, panel, J)
    Label(top, {Size = UDim2.new(1, -80, 0, 32), Position = UDim2.new(0, 14, 0, 8), Text = tr("animTitle"), TextColor3 = Theme.Gold, Font = Enum.Font.GothamBold, TextSize = 15})
    local closeB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 10), BackgroundColor3 = Theme.Card, Text = "✕", TextColor3 = Theme.Danger, TextSize = 14}, 13)
    UILib.stroke(closeB, Theme.Danger, 1.5, 0.5)
    J:Add(closeB.Activated:Connect(function() panel.Visible = false end))
    Label(panel, {Size = UDim2.new(1, -28, 0, 34), Position = UDim2.new(0, 14, 0, 44), Text = tr("animHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})

    local list = N("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -94), Position = UDim2.new(0, 10, 0, 84), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Gold, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)
    UILib.corner(list, 12) UILib.padding(list, 6)
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    local empty = Label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyAnim"), TextColor3 = Theme.TextDim, LayoutOrder = 9999, TextXAlignment = Enum.TextXAlignment.Center})

    local rows = {}
    local refresh
    local function makeRow(k)
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, list)
        UILib.corner(row, 10)
        local nameL = Label(row, {Size = UDim2.new(1, -112, 0, 18), Position = UDim2.new(0, 10, 0, 8), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd})
        local idL = Label(row, {Size = UDim2.new(1, -112, 0, 14), Position = UDim2.new(0, 10, 0, 28), TextColor3 = Theme.TextDim, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd})
        local btn = Btn(row, {Size = UDim2.new(0, 92, 0, 28), Position = UDim2.new(1, -100, 0.5, -14), TextSize = 10}, 8)
        J:Add(btn.Activated:Connect(function()
            if State.animAllow[k] then State.animAllow[k] = nil else State.animAllow[k] = true end
            Config.save()
            refresh()
        end))
        local r = {frame = row}
        function r.update(e)
            local allowed = State.animAllow[k] == true
            nameL.Text = e and e.name or k
            idL.Text = (k:sub(1, 2) == "n:" and "—" or ("ID: " .. k)) .. (e and ("  ·  x" .. e.n) or "")
            btn.Text = allowed and ("✓ " .. tr("allowedTag")) or ("✕ " .. tr("blockedTag"))
            btn.BackgroundColor3 = allowed and Theme.Success or Theme.Danger
            btn.TextColor3 = allowed and DARK or WHITE
        end
        return r
    end
    refresh = function()
        local keys = {}
        for k in pairs(Dances.log) do keys[k] = true end
        for k in pairs(State.animAllow) do keys[k] = true end
        local arr = {}
        for k in pairs(keys) do table.insert(arr, k) end
        table.sort(arr, function(a, b)
            local ta = Dances.log[a] and Dances.log[a].t or 0
            local tb = Dances.log[b] and Dances.log[b].t or 0
            if ta ~= tb then return ta > tb end
            return a < b
        end)
        local seen = {}
        for i, k in ipairs(arr) do
            local r = rows[k]
            if not r then r = makeRow(k) rows[k] = r end
            r.frame.LayoutOrder = i
            r.update(Dances.log[k])
            seen[k] = true
        end
        for k, r in pairs(rows) do
            if not seen[k] then r.frame:Destroy() rows[k] = nil end
        end
        empty.Visible = (#arr == 0)
    end
    local alive = true
    J:Add(function() alive = false end)
    task.spawn(function()
        while alive and State.running do
            task.wait(0.5)
            if panel.Visible then pcall(refresh) end
        end
    end)
    return panel, refresh
end

---------------------------------------------------------------- Main UI
function UI.destroy()
    if UI.j then UI.j:Clean() UI.j = nil end
    UI.refresh = function() end
end

function UI.build()
    UI.destroy()
    local J = Janitor.new()
    UI.j = J
    local mobile = isMobile()
    local vp = viewport()

    local G = J:Add(N("ScreenGui", {Name = "BH", ResetOnSpawn = false, IgnoreGuiInset = mobile, DisplayOrder = 5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local baseW = math.min(mobile and 240 or 320, vp.X - 20)
    local baseH = math.min(mobile and 420 or 560, vp.Y - 40)
    local rest = UDim2.new(0, 24, 0.5, -baseH / 2)

    local M = N("Frame", {Size = UDim2.new(0, baseW, 0, baseH), Position = UI.pos or rest, BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2}, G)
    UILib.corner(M, 18) UILib.gradient(M, Theme.BG1, Theme.BG3, 135) UILib.stroke(M, Theme.Accent, 1.5, 0.35)

    local header = N("Frame", {Size = UDim2.new(1, 0, 0, 72), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0, ZIndex = 3}, M)
    UILib.corner(header, 18) UILib.gradient(header, Color3.fromRGB(22, 32, 42), Color3.fromRGB(30, 46, 54), 90)
    local drag = makeDraggable(header, M, J, function() UI.pos = M.Position end)

    local logo = N("Frame", {Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0, 14, 0, 13), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, ZIndex = 4}, header)
    UILib.corner(logo, 14) UILib.stroke(logo, Theme.Accent, 1.5, 0.2)
    Label(logo, {Size = UDim2.new(1, 0, 1, 0), Text = "🕌", TextSize = 26, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5})
    Label(header, {Size = UDim2.new(1, -120, 0, 24), Position = UDim2.new(0, 68, 0, 14), Text = tr("title"), Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Accent2, ZIndex = 4})
    Label(header, {Size = UDim2.new(1, -120, 0, 14), Position = UDim2.new(0, 68, 0, 40), Text = tr("subtitle"), TextColor3 = Theme.TextDim, TextSize = 11, ZIndex = 4})

    local minBtn = Btn(header, {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -74, 0, 22), BackgroundColor3 = Theme.Card, Text = "−", TextColor3 = Theme.Accent, TextSize = 20, ZIndex = 4}, 14)
    UILib.stroke(minBtn, Theme.Accent, 1.5, 0.5)
    local closeBtn = Btn(header, {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -40, 0, 22), BackgroundColor3 = Theme.Card, Text = "", ZIndex = 4}, 14)
    UILib.stroke(closeBtn, Theme.Danger, 1.5, 0.5)
    UILib.drawX(closeBtn, Theme.DangerHi, 12, 2)

    local scroll = N("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -80), Position = UDim2.new(0, 8, 0, 72), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 3,
    }, M)
    local sp = UILib.padding(scroll, 4)
    sp.PaddingTop, sp.PaddingBottom = UDim.new(0, 12), UDim.new(0, 16)
    N("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)

    local function section(text, icon, order)
        local hf = N("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, LayoutOrder = order, ZIndex = 4}, scroll)
        N("Frame", {Size = UDim2.new(1, -140, 0, 1), Position = UDim2.new(0, 130, 0.5, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 4}, hf)
        Label(hf, {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 4, 0, 0), Text = icon, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, ZIndex = 4})
        Label(hf, {Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(0, 26, 0, 0), Text = text, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 4})
    end

    local function toggle(text, icon, order, get, set)
        local isOn = get()
        local card = N("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 4}, scroll)
        UILib.corner(card, 14)
        local cs = UILib.stroke(card, isOn and Theme.Accent or Theme.TextDim, 1.2, 0.5)
        local ib = N("Frame", {Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(0, 12, 0.5, -18), BackgroundColor3 = isOn and Theme.OnBG or Theme.BG3, BorderSizePixel = 0, ZIndex = 5}, card)
        UILib.corner(ib, 10)
        Label(ib, {Size = UDim2.new(1, 0, 1, 0), Text = icon, TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6})
        Label(card, {Size = UDim2.new(1, -130, 0, 16), Position = UDim2.new(0, 58, 0, 12), Text = text, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 5, TextTruncate = Enum.TextTruncate.AtEnd})
        local sl = Label(card, {Size = UDim2.new(1, -130, 0, 14), Position = UDim2.new(0, 58, 0, 30), Text = isOn and tr("on") or tr("off"), TextColor3 = isOn and Theme.Accent or Theme.TextDim, TextSize = 11, ZIndex = 5})
        local tg = N("Frame", {Size = UDim2.new(0, 42, 0, 24), Position = UDim2.new(1, -54, 0.5, -12), BackgroundColor3 = isOn and Theme.Accent or Theme.Off, BorderSizePixel = 0, ZIndex = 5}, card)
        UILib.corner(tg, 12)
        local kn = N("Frame", {Size = UDim2.new(0, 18, 0, 18), Position = isOn and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 6}, tg)
        UILib.corner(kn, 9)
        local ca = N("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 7}, card)
        J:Add(ca.Activated:Connect(function()
            isOn = not isOn
            local ti = TweenInfo.new(0.2)
            TweenService:Create(tg, ti, {BackgroundColor3 = isOn and Theme.Accent or Theme.Off}):Play()
            TweenService:Create(kn, ti, {Position = isOn and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
            TweenService:Create(ib, ti, {BackgroundColor3 = isOn and Theme.OnBG or Theme.BG3}):Play()
            TweenService:Create(cs, ti, {Color = isOn and Theme.Accent or Theme.TextDim}):Play()
            sl.Text = isOn and tr("on") or tr("off")
            sl.TextColor3 = isOn and Theme.Accent or Theme.TextDim
            set(isOn)
            Config.save()
        end))
    end

    local function actionCard(text, order)
        local b = Btn(scroll, {Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Theme.Card, Text = text, TextColor3 = Theme.Text, TextSize = 13, LayoutOrder = order, ZIndex = 4}, 14)
        UILib.stroke(b, Theme.Accent, 1.2, 0.6)
        UILib.hover(b, Theme.Card, Theme.CardHi, J)
        return b
    end

    -- Audio
    section(tr("sectionAudio"), "♪", 1)
    toggle(tr("muteMusic"), "🎵", 2, function() return State.muteMusic end, function(s)
        State.muteMusic = s
        Audio.setGlobalMute(s)
    end)
    toggle(tr("saveSettings"), "💾", 3, function() return Audio.autosave end, function(s)
        Audio.setAutosave(s)
    end)
    local musicBtn = actionCard(tr("openMusic"), 4)
    local logBtn = actionCard(tr("soundLog"), 5)

    -- Visual
    section(tr("sectionVisual"), "◈", 10)
    toggle(tr("noobSkin"), "👕", 11, function() return State.noob end, function(s)
        State.noob = s
        Targets.refreshAll()
    end)

    -- Tools
    section(tr("sectionTools"), "◆", 20)
    toggle(tr("stopDance"), "💃", 21, function() return State.dances end, function(s) State.dances = s end)
    toggle(tr("broadDance"), "🎯", 22, function() return State.broadDances end, function(s) State.broadDances = s end)
    local suggestBtn = actionCard("🎯  " .. tr("suggest"), 23)
    local animBtn = actionCard(tr("animLog"), 24)

    -- Players
    section(tr("sectionPlayers"), "◆", 30)
    local searchBox = N("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, LayoutOrder = 31, ZIndex = 4}, scroll)
    UILib.corner(searchBox, 12)
    Label(searchBox, {Size = UDim2.new(0, 32, 1, 0), Position = UDim2.new(0, 6, 0, 0), Text = "🔍", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5})
    local searchInput = N("TextBox", {
        Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 34, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = tr("searchPH"),
        TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 5,
    }, searchBox)

    local plFrame = N("Frame", {Size = UDim2.new(1, 0, 0, 200), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, LayoutOrder = 32, ZIndex = 4}, scroll)
    UILib.corner(plFrame, 12)
    local plScroll = N("ScrollingFrame", {Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 5}, plFrame)
    N("UIListLayout", {Padding = UDim.new(0, 4)}, plScroll)

    -- Lists
    section(tr("sectionLists"), "◆", 40)
    local function listBox(order, height, title, titleCol, strokeCol, addCol, onAdd)
        local f = N("Frame", {Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 4}, scroll)
        UILib.corner(f, 12) UILib.stroke(f, strokeCol, 1, 0.5)
        Label(f, {Size = UDim2.new(1, -16, 0, 24), Position = UDim2.new(0, 12, 0, 8), Text = title, TextColor3 = titleCol, Font = Enum.Font.GothamBold, ZIndex = 5})
        local input = N("TextBox", {
            Size = UDim2.new(1, -66, 0, 26), Position = UDim2.new(0, 12, 0, 36), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, Text = "",
            PlaceholderText = tr("searchPH"), TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium,
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 5,
        }, f)
        UILib.corner(input, 8)
        local add = Btn(f, {Size = UDim2.new(0, 44, 0, 26), Position = UDim2.new(1, -56, 0, 36), BackgroundColor3 = addCol, Text = "+", TextSize = 16, TextColor3 = (addCol == Theme.Danger) and WHITE or DARK, ZIndex = 5})
        local list = N("ScrollingFrame", {Size = UDim2.new(1, -24, 1, -72), Position = UDim2.new(0, 12, 0, 66), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = strokeCol, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 5}, f)
        N("UIListLayout", {Padding = UDim.new(0, 3)}, list)
        local function submit()
            local n = resolveName(input.Text)
            if not n then return end
            input.Text = ""
            onAdd(n)
        end
        J:Add(add.Activated:Connect(submit))
        J:Add(input.FocusLost:Connect(function(enter) if enter then submit() end end))
        return list
    end
    local wlL = listBox(41, 130, "✓  " .. tr("whitelist"), Theme.Accent, Theme.Accent, Theme.Accent, function(n) listSet(n, "white") end)
    local blL = listBox(42, 160, tr("blocked"), Theme.Danger, Theme.Danger, Theme.Danger, function(n) listSet(n, "black") end)

    Label(scroll, {Size = UDim2.new(1, 0, 0, 18), Text = tr("footer") .. "  ·  v" .. VERSION .. "  ·  " .. CREATOR_NAME, TextColor3 = Theme.TextDim, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 100, ZIndex = 4})

    -- Rows
    local function mkRow(parent, info, actions)
        local row = N("Frame", {Size = UDim2.new(1, -8, 0, 42), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, ZIndex = 6}, parent)
        UILib.corner(row, 10)
        local av = N("ImageLabel", {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 6, 0.5, -16), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop, ZIndex = 7}, row)
        UILib.corner(av, 16) UILib.stroke(av, Theme.Accent, 1, 0.4)
        local function setAv(id)
            if av.Parent then av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. id .. "&w=150&h=150" end
        end
        if info.UserId then setAv(info.UserId) else userIdAsync(info.Name, setAv) end
        local dn = (info.DisplayName and info.DisplayName ~= "") and info.DisplayName or info.Name
        if lower(info.Name) == lower(CREATOR_NAME) then dn = "👑 " .. dn end
        Label(row, {Size = UDim2.new(1, -46 - 34 * #actions - 8, 0, 14), Position = UDim2.new(0, 46, 0, 6), Text = dn, Font = Enum.Font.GothamBold, ZIndex = 7, TextTruncate = Enum.TextTruncate.AtEnd})
        Label(row, {Size = UDim2.new(1, -46 - 34 * #actions - 8, 0, 12), Position = UDim2.new(0, 46, 0, 20), Text = "@" .. info.Name, TextColor3 = Theme.TextDim, TextSize = 10, ZIndex = 7, TextTruncate = Enum.TextTruncate.AtEnd})
        for i, a in ipairs(actions) do
            local ab = Btn(row, {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -38 - 34 * (i - 1), 0.5, -15), BackgroundColor3 = a.color, Text = "", ZIndex = 7}, 15)
            UILib.stroke(ab, WHITE, 1.5, 0.5)
            if a.kind == "x" then
                UILib.drawX(ab, WHITE, 12, 2)
            else
                Label(ab, {Size = UDim2.new(1, 0, 1, 0), Text = a.kind == "check" and "✓" or "↩", TextColor3 = DARK, Font = Enum.Font.GothamBlack, TextSize = a.kind == "check" and 18 or 16, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 8})
            end
            J:Add(ab.Activated:Connect(a.fn))
        end
    end
    local function clearRows(parent)
        for _, c in ipairs(parent:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end
    end
    local function emptyLabel(parent, text, h)
        Label(parent, {Size = UDim2.new(1, 0, 0, h), Text = text, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6})
    end
    local function infoOf(name)
        local p = findPlayer(name)
        return p or {Name = name, DisplayName = name}
    end

    local query = ""
    local function refreshPL()
        clearRows(plScroll)
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and not isWhite(p) and not isBlack(p) then
                local dn, un = lower(p.DisplayName ~= "" and p.DisplayName or p.Name), lower(p.Name)
                if query == "" or dn:find(query, 1, true) or un:find(query, 1, true) then
                    count = count + 1
                    mkRow(plScroll, p, {
                        {kind = "check", color = Theme.Accent, fn = function() listSet(p.Name, "white") end},
                        {kind = "x", color = Theme.Danger, fn = function() listSet(p.Name, "black") end},
                    })
                end
            end
        end
        if count == 0 then emptyLabel(plScroll, tr("noPlayers"), 60) end
        plFrame.Size = UDim2.new(1, 0, 0, math.clamp(count * 46 + 16, 100, 300))
    end
    local function refreshWL()
        clearRows(wlL)
        local names = {}
        for n in pairs(State.W) do if n ~= lower(LP.Name) then table.insert(names, n) end end
        table.sort(names)
        for _, n in ipairs(names) do
            local info = infoOf(n)
            mkRow(wlL, info, {{kind = "x", color = Theme.Danger, fn = function() listSet(info.Name, nil) end}})
        end
        if #names == 0 then emptyLabel(wlL, tr("empty"), 40) end
    end
    local function refreshBL()
        clearRows(blL)
        local names = {}
        for n in pairs(State.B) do if n ~= lower(LP.Name) then table.insert(names, n) end end
        table.sort(names)
        for _, n in ipairs(names) do
            local info = infoOf(n)
            mkRow(blL, info, {{kind = "undo", color = Theme.Accent, fn = function() listSet(info.Name, nil) end}})
        end
        if #names == 0 then emptyLabel(blL, tr("empty"), 40) end
    end
    UI.refresh = function()
        pcall(refreshPL) pcall(refreshWL) pcall(refreshBL)
    end
    J:Add(searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        query = lower(searchInput.Text)
        pcall(refreshPL)
    end))
    UI.refresh()
    J:Add(Players.PlayerRemoving:Connect(function() task.delay(0.5, UI.refresh) end))

    -- Suggest panel
    local suggestActive, suggestPanel, currentTarget = false, nil, nil
    J:Add(function() suggestActive = false end)
    J:Add(suggestBtn.Activated:Connect(function()
        suggestActive = not suggestActive
        if not suggestActive then
            suggestBtn.BackgroundColor3 = Theme.Card
            suggestBtn.Text = "🎯  " .. tr("suggest")
            if suggestPanel then suggestPanel:Destroy() suggestPanel = nil end
            currentTarget = nil
            return
        end
        suggestBtn.BackgroundColor3 = Theme.OnBG
        suggestBtn.Text = "🎯  " .. tr("suggest") .. "  ●"
        local sw = math.min(200, vp.X - 20)
        suggestPanel = N("Frame", {Size = UDim2.new(0, sw, 0, 180), Position = UDim2.new(1, -sw - 20, 0.3, 0), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, ZIndex = 20}, G)
        UILib.corner(suggestPanel, 16) UILib.gradient(suggestPanel, Theme.BG1, Theme.BG3, 135) UILib.stroke(suggestPanel, Theme.Accent, 1.5, 0.3)
        local spH = N("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0, ZIndex = 21}, suggestPanel)
        UILib.corner(spH, 16)
        Label(spH, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = "🎯  " .. tr("suggest"), TextColor3 = Theme.Accent2, Font = Enum.Font.GothamBold, ZIndex = 22})
        makeDraggable(spH, suggestPanel, J)
        local av = N("ImageLabel", {Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 12, 0, 44), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop, ZIndex = 22}, suggestPanel)
        UILib.corner(av, 28) UILib.stroke(av, Theme.Accent, 1.5, 0.3)
        local lbl = Label(suggestPanel, {Size = UDim2.new(1, -84, 0, 56), Position = UDim2.new(0, 76, 0, 44), Text = tr("none"), Font = Enum.Font.GothamBold, TextSize = 13, TextWrapped = true, ZIndex = 22})
        local sW = Btn(suggestPanel, {Size = UDim2.new(0.5, -18, 0, 34), Position = UDim2.new(0, 12, 1, -46), BackgroundColor3 = Theme.Accent, TextColor3 = DARK, Text = "✓ " .. tr("wl"), TextSize = 12, ZIndex = 22}, 10)
        local sB = Btn(suggestPanel, {Size = UDim2.new(0.5, -18, 0, 34), Position = UDim2.new(1, -12, 1, -46), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Theme.Danger, Text = tr("block"), TextSize = 12, ZIndex = 22}, 10)
        sW.Activated:Connect(function() if currentTarget then listSet(currentTarget.Name, "white") end end)
        sB.Activated:Connect(function() if currentTarget then listSet(currentTarget.Name, "black") end end)

        task.spawn(function()
            while State.running and suggestActive and suggestPanel do
                task.wait(0.4)
                local best
                local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local cam = Workspace.CurrentCamera
                    local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
                    local bestScore = 0
                    for _, p in ipairs(Players:GetPlayers()) do
                        local pr = p ~= LP and not isWhite(p) and not isBlack(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if pr then
                            local dir = pr.Position - root.Position
                            local dist = dir.Magnitude
                            if dist < 100 and dist > 0 then
                                local dot = dir.Unit:Dot(look)
                                if dot > 0.3 then
                                    local score = dot / (dist + 1)
                                    if score > bestScore then bestScore, best = score, p end
                                end
                            end
                        end
                    end
                end
                currentTarget = best
                if best then
                    lbl.Text = (best.DisplayName ~= "" and best.DisplayName or best.Name) .. "\n@" .. best.Name
                    lbl.TextColor3 = Theme.Accent2
                    av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. best.UserId .. "&w=150&h=150"
                else
                    lbl.Text = tr("none")
                    lbl.TextColor3 = Theme.TextDim
                    av.Image = ""
                end
            end
        end)
    end))

    -- Sub panels
    local mmPanel, mmRefresh = buildSoundManager(J, vp)
    J:Add(musicBtn.Activated:Connect(function()
        mmPanel.Visible = not mmPanel.Visible
        if mmPanel.Visible then pcall(mmRefresh) end
    end))
    local slPanel, slRefresh = buildSoundLog(J, vp)
    J:Add(logBtn.Activated:Connect(function()
        slPanel.Visible = not slPanel.Visible
        if slPanel.Visible then pcall(slRefresh) end
    end))
    local alPanel, alRefresh = buildAnimLog(J, vp)
    J:Add(animBtn.Activated:Connect(function()
        alPanel.Visible = not alPanel.Visible
        if alPanel.Visible then pcall(alRefresh) end
    end))

    -- Minimized icon
    local mini = Btn(G, {Size = UDim2.new(0, 60, 0, 60), Position = M.Position, BackgroundColor3 = Theme.BG2, Text = "🕌", TextSize = 28, Visible = false, ZIndex = 4}, 30)
    UILib.stroke(mini, Theme.Accent, 2, 0.2)
    local miniDrag = makeDraggable(mini, mini, J)
    local function setMin(state)
        if state then
            mini.Position = M.Position
            M.Visible, mini.Visible = false, true
        else
            M.Position = mini.Position
            UI.pos = M.Position
            M.Visible, mini.Visible = true, false
        end
    end
    J:Add(minBtn.Activated:Connect(function() setMin(true) end))
    J:Add(mini.Activated:Connect(function() if not miniDrag.moved then setMin(false) end end))

    J:Add(closeBtn.Activated:Connect(function() ENV.__BeHalal.destroy() end))

    if not UI.pos then
        M.Position = UDim2.new(0, -baseW - 50, 0.5, -baseH / 2)
        TweenService:Create(M, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = rest}):Play()
        UI.pos = rest
    end
end

---------------------------------------------------------------- Lifecycle
local Hub = {}
function Hub.destroy()
    if not State.running then return end
    State.running = false
    pcall(Config.saveNow)
    pcall(Audio.shutdown)
    pcall(Targets.shutdown)
    pcall(UI.destroy)
    Root:Clean()
    if ENV.__BeHalal == Hub then ENV.__BeHalal = nil end
end
ENV.__BeHalal = Hub

---------------------------------------------------------------- Boot
Config.apply()
Audio.init()

Root:Add(Players.PlayerAdded:Connect(function(p) task.spawn(onPlayer, p) end))
Root:Add(Players.PlayerRemoving:Connect(function(p) Targets.remove(p) end))
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end

loop(0.25, function()
    if not State.dances then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and Dances.shouldStop(p) then Dances.sweepChar(p.Character) end
    end
end)
loop(1, Targets.refreshAll)

showLangScreen(function(lang)
    State.lang = lang
    task.wait(0.1)
    if State.running then UI.build() end
end)
