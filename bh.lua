--[[
    Be Halal · بي حلال        v4.0
    Islamic server tools (client-side)
    Features: v4.0 unchanged · Visuals: v3.7 style
    Modules: Janitor · Config · Audio · Skin · Hide · Dances · Targets · UILib · Icon · UI
]]

local Players           = game:GetService("Players")
local SoundService      = game:GetService("SoundService")
local UIS               = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local Marketplace       = game:GetService("MarketplaceService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local CREATOR_NAME = "EZ_NOOB11220"
local VERSION = "4.0"

local ENV = (getgenv and getgenv()) or _G
if ENV.__BeHalal and type(ENV.__BeHalal.destroy) == "function" then
    pcall(ENV.__BeHalal.destroy)
end
for _, n in ipairs({"BH", "BH_SoundsMgr", "BH_SoundLog", "BH_AnimLog", "BH_Toast", "BH_Splash", "BHLang"}) do
    local old = PG:FindFirstChild(n)
    if old then old:Destroy() end
end

--==============================================================
-- Janitor
--==============================================================
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

--==============================================================
-- Utils
--==============================================================
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
    running = true, lang = "ar", langSaved = false,
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

--==============================================================
-- Theme  (v3.7 visual identity)
--==============================================================
local Theme = {
    BG1 = Color3.fromRGB(10, 9, 7),     BG2 = Color3.fromRGB(18, 16, 12),   BG3 = Color3.fromRGB(27, 24, 18),
    Card = Color3.fromRGB(34, 30, 22),  CardHi = Color3.fromRGB(50, 43, 29),
    Accent = Color3.fromRGB(212, 175, 55), Accent2 = Color3.fromRGB(240, 208, 120), Gold = Color3.fromRGB(255, 225, 130),
    Text = Color3.fromRGB(245, 238, 222), TextDim = Color3.fromRGB(160, 148, 122),
    Danger = Color3.fromRGB(190, 62, 52), DangerHi = Color3.fromRGB(235, 105, 90),
    Success = Color3.fromRGB(222, 182, 64), Info = Color3.fromRGB(170, 130, 52),
    OnBG = Color3.fromRGB(58, 48, 22), Off = Color3.fromRGB(68, 62, 50),
}

--==============================================================
-- Translations (v4.0 keys)
--==============================================================
local T = {
    ar = {
        title = "بي حلال", subtitle = "أدوات إسلامية للسيرفر", footer = "صُنع بإتقان",
        navHome = "الرئيسية", navSounds = "الأصوات", navMusic = "سجل الموسيقى", navAnim = "سجل الحركات", navPlayers = "اللاعبون",
        statPlayers = "لاعبون", statSounds = "أصوات", statMuted = "مكتومة",
        secAudio = "الصوت", secAppearance = "المظهر", secMotion = "الحركة", secData = "البيانات",
        muteMusic = "كتم الموسيقى", muteMusicD = "يكتم موسيقى الخلفية في السيرفر",
        noobSkin = "سكنات نوب", noobSkinD = "يعرض اللاعبين الآخرين بالمظهر الافتراضي",
        stopDance = "إيقاف الرقصات", stopDanceD = "يوقف رقصات اللاعبين الآخرين",
        broadDance = "كشف شامل", broadDanceD = "يوقف أي حركة بأولوية Action، وقد يشمل حركات الماب",
        autosave = "حفظ تلقائي", autosaveD = "يحفظ إعدادات الأصوات لهذه الماب",
        searchSound = "ابحث بالاسم أو المسار أو الـ ID", sortName = "ترتيب: الاسم", sortLen = "ترتيب: المدة",
        catAll = "الكل", catMusic = "موسيقى", catAmbient = "أجواء", catSfx = "مؤثرات", catUi = "واجهة", catOther = "أخرى",
        tabPlaying = "شغّالة", tabAll = "الكل", tabMuted = "مكتومة",
        muteAll = "كتم الكل", unmuteAll = "فك الكل", stopListening = "إيقاف الاستماع",
        mute = "كتم", unmute = "فك الكتم", listen = "استماع", stop = "إيقاف", rename = "تسمية", loop = "تكرار",
        emptyFilter = "لا توجد أصوات بهذا الفلتر", namePh = "اكتب الاسم ثم Enter",
        logOn = "زر كتم الموسيقى مفعّل", logOff = "زر كتم الموسيقى معطّل",
        logHint = "الأصوات اللي يكتمها زر كتم الموسيقى. استمع للصوت لحاله، أو استثنِه من الكتم.",
        logSearch = "ابحث في السجل", clear = "مسح", emptyLog = "لا توجد أصوات مسجّلة بعد",
        exempt = "مستثنى", willMute = "يُكتم", stExempt = "مستثنى من الكتم", stByButton = "مكتوم بالزر", stWillMute = "يُكتم عند تفعيل الزر",
        stPlaying = "شغّال", stIdle = "متوقف", stGone = "غير موجود في الماب",
        animHint = "كل حركة تم إيقافها تظهر هنا. إذا كانت من الماب، اسمح بها وما تنمنع بعدها.",
        animAllowed = "مسموحة", animBlocked = "محجوبة", emptyAnim = "لا توجد حركات محجوبة بعد",
        segOnline = "المتصلون", segAllowed = "المسموحون", segBlocked = "المحجوبون",
        searchPlayer = "ابحث عن لاعب", addPlayer = "اسم اللاعب", add = "إضافة",
        allow = "سماح", block = "حجب", remove = "إزالة", restore = "استعادة",
        noPlayers = "لا يوجد لاعبون", empty = "القائمة فارغة", inView = "في مرمى نظرك", noneInView = "لا أحد أمامك", creator = "المطوّر",
    },
    en = {
        title = "Be Halal", subtitle = "Islamic server tools", footer = "Crafted with precision",
        navHome = "Home", navSounds = "Sounds", navMusic = "Music Log", navAnim = "Animations", navPlayers = "Players",
        statPlayers = "Players", statSounds = "Sounds", statMuted = "Muted",
        secAudio = "Audio", secAppearance = "Appearance", secMotion = "Motion", secData = "Data",
        muteMusic = "Mute Music", muteMusicD = "Silences background music on the server",
        noobSkin = "Noob Skins", noobSkinD = "Shows other players with the default look",
        stopDance = "Stop Dances", stopDanceD = "Stops dance animations of other players",
        broadDance = "Broad Detection", broadDanceD = "Also stops any Action-priority animation, may include map animations",
        autosave = "Auto-save", autosaveD = "Remembers your sound settings for this place",
        searchSound = "Search name, path or ID", sortName = "Sort: Name", sortLen = "Sort: Length",
        catAll = "All", catMusic = "Music", catAmbient = "Ambient", catSfx = "Effects", catUi = "Interface", catOther = "Other",
        tabPlaying = "Playing", tabAll = "All", tabMuted = "Muted",
        muteAll = "Mute all", unmuteAll = "Unmute all", stopListening = "Stop listening",
        mute = "Mute", unmute = "Unmute", listen = "Listen", stop = "Stop", rename = "Rename", loop = "Loop",
        emptyFilter = "No sounds match this filter", namePh = "Type a name, then Enter",
        logOn = "Mute Music is on", logOff = "Mute Music is off",
        logHint = "Sounds caught by the Mute Music button. Listen to one alone, or exempt it from muting.",
        logSearch = "Search the log", clear = "Clear", emptyLog = "No sounds recorded yet",
        exempt = "Exempt", willMute = "Muted", stExempt = "Exempt from muting", stByButton = "Muted by the button", stWillMute = "Will be muted when the button is on",
        stPlaying = "Playing", stIdle = "Idle", stGone = "Gone from the map",
        animHint = "Every stopped animation is listed here. If it belongs to the map, allow it and it won't be stopped again.",
        animAllowed = "Allowed", animBlocked = "Blocked", emptyAnim = "No animations blocked yet",
        segOnline = "Online", segAllowed = "Allowed", segBlocked = "Blocked",
        searchPlayer = "Search players", addPlayer = "Player name", add = "Add",
        allow = "Allow", block = "Block", remove = "Remove", restore = "Restore",
        noPlayers = "No players found", empty = "List is empty", inView = "In your view", noneInView = "No one in view", creator = "Creator",
    },
}
local function tr(k) return (T[State.lang] or T.en)[k] or T.en[k] or k end

--==============================================================
-- Config (v4.0 unchanged)
--==============================================================
local Config = {file = "BeHalal_Config.json", data = {}, queued = false}
local Audio
function Config.collect()
    local w, b = {}, {}
    local me = lower(LP.Name)
    for k in pairs(State.W) do if k ~= me then table.insert(w, k) end end
    for k in pairs(State.B) do if k ~= me then table.insert(b, k) end end
    local aa = {}
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
    task.delay(1, function() Config.queued = false Config.saveNow() end)
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

--==============================================================
-- Audio (v4.0 unchanged — same behavior)
--==============================================================
Audio = {
    place = tostring(game.PlaceId), file = "BeHalal_Sounds.json",
    settings = {}, rec = setmetatable({}, {__mode = "k"}),
    hooks = {}, globalMute = false, solo = nil, autosave = false, dirty = false,
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
function Audio.isCharSound(s)
    local p = s.Parent
    for _ = 1, 6 do
        if not p or p == Workspace or p == game then return false end
        if p:FindFirstChildOfClass("Humanoid") then return true end
        p = p.Parent
    end
    return false
end
function Audio.looksMusic(s)
    if Audio.isCharSound(s) then return false end
    if s.Looped then return true end
    if (s.TimeLength or 0) > 10 then return true end
    return Audio.nameHit(s)
end
function Audio.categoryOf(s)
    local p = s.Parent
    if p and (p:IsA("BasePart") or p:IsA("Attachment")) then return "part" end
    if s:IsDescendantOf(SoundService) or s:IsDescendantOf(Workspace) then return "bg" end
    return "other"
end
function Audio.score(s)
    local sc, len = 0, s.TimeLength or 0
    if len >= 60 then sc = sc + 3 elseif len >= 30 then sc = sc + 2 elseif len >= 10 then sc = sc + 1 end
    if s.Looped then sc = sc + 2 end
    if Audio.nameHit(s) then sc = sc + 2 end
    if Audio.categoryOf(s) == "bg" then sc = sc + 1 end
    return sc
end
function Audio.fmtTime(len) return string.format("%d:%02d", math.floor((len or 0) / 60), math.floor((len or 0) % 60)) end
function Audio.clampStep(x) return math.clamp(math.floor(x * 10 + 0.5) / 10, 0, 2) end

function Audio.enforce(s)
    if not s.Parent then return end
    local key = Audio.keyOf(s)
    local st = Audio.settings[key]
    local muted, factor = false, 1
    if Audio.solo then muted = (key ~= Audio.solo)
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
    if not r then r = {orig = s.Volume} Audio.rec[s] = r
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
    if CoreGui and s:IsDescendantOf(CoreGui) then return end
    local j = Janitor.new()
    Audio.hooks[s] = j
    local function f() Audio.enforce(s) end
    j:Add(s:GetPropertyChangedSignal("Volume"):Connect(f))
    j:Add(s:GetPropertyChangedSignal("SoundId"):Connect(f))
    j:Add(s:GetPropertyChangedSignal("TimeLength"):Connect(f))
    j:Add(s:GetPropertyChangedSignal("Looped"):Connect(f))
    j:Add(s.Played:Connect(function() f() Audio.note(s) end))
    f()
end
function Audio.sweep()
    for s, j in pairs(Audio.hooks) do
        if not s:IsDescendantOf(game) then
            j:Clean() Audio.hooks[s] = nil Audio.rec[s] = nil
        else
            Audio.enforce(s)
            if s.IsPlaying then Audio.note(s) end
        end
    end
    if Audio.dirty and Audio.autosave then Audio.dirty = false Audio.save() end
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
    e.music = Audio.looksMusic(s)
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
function Audio.soloStop() Audio.solo = nil Audio.enforceAll() end
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
function Audio.setGlobalMute(on) Audio.globalMute = on Audio.enforceAll() end
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

--==============================================================
-- Skin / Hide / Dances / Targets (v4.0 unchanged)
--==============================================================
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
        elseif i:IsA("CharacterMesh") then table.insert(b.meshes, i) i.Parent = nil
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
        local ok, info = pcall(function() return Marketplace:GetProductInfo(tonumber(num), Enum.InfoType.Asset) end)
        if ok and info then emoteCache[num] = (info.AssetTypeId == 61)
        else
            emoteFail[num] = (emoteFail[num] or 0) + 1
            if emoteFail[num] >= 2 then emoteCache[num] = false else task.wait(5) emoteCache[num] = nil end
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
    if State.broadDances and ACTION_PRI[track.Priority] and not inTool then return true end
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
    st.pj:Add(p.CharacterRemoving:Connect(function(c) Skin.forget(c) st.cj:Clean() end))
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

--==============================================================
-- Lists API (v4.0)
--==============================================================
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

--==============================================================
-- UILib (v3.7 style)
--==============================================================
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
function UILib.glow(stroke, J, base, c1, c2)
    c1, c2 = c1 or Theme.Accent, c2 or Theme.Accent2
    stroke.Color = Color3.new(1, 1, 1)
    local g = N("UIGradient", {Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(0.5, c2), ColorSequenceKeypoint.new(1, c1),
    })}, stroke)
    local alive = true
    J:Add(function() alive = false end)
    task.spawn(function()
        local t = math.random() * 6
        while alive and State.running do
            t = t + 0.06
            local k = (math.sin(t * 1.6) + 1) / 2
            stroke.Transparency = 0.5 - 0.38 * k
            stroke.Thickness = (base or 1.5) + 1.3 * k
            g.Rotation = (t * 40) % 360
            task.wait(0.06)
        end
    end)
end
function UILib.halo(target, radius, J)
    local f = N("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Active = false}, target.Parent)
    UILib.corner(f, radius)
    local st = N("UIStroke", {Color = Theme.Accent, Thickness = 8, Transparency = 0.85}, f)
    local function sync() f.Size, f.Position, f.Visible = target.Size, target.Position, target.Visible end
    sync()
    J:Add(target:GetPropertyChangedSignal("Position"):Connect(sync))
    J:Add(target:GetPropertyChangedSignal("Size"):Connect(sync))
    J:Add(target:GetPropertyChangedSignal("Visible"):Connect(sync))
    local alive = true
    J:Add(function() alive = false end)
    task.spawn(function()
        local t = math.random() * 6
        while alive and State.running do
            t = t + 0.06
            local k = (math.sin(t * 1.6) + 1) / 2
            st.Transparency = 0.93 - 0.2 * k
            st.Thickness = 6 + 6 * k
            task.wait(0.06)
        end
    end)
    return f
end

--==============================================================
-- Icons (v3.7 hand drawn from frames)
--==============================================================
local Icon = {}
local function part(parent, cx, cy, w, h, color, rot, round)
    local f = N("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx, cy), Size = UDim2.fromScale(w, h),
        BackgroundColor3 = color, BorderSizePixel = 0, Rotation = rot or 0, ZIndex = parent.ZIndex + 1,
    }, parent)
    if round then N("UICorner", {CornerRadius = UDim.new(round, 0)}, f) end
    return f
end
local function ring(parent, cx, cy, d, color, th)
    local f = part(parent, cx, cy, d, d, color, 0, 0.5)
    f.BackgroundTransparency = 1
    N("UIStroke", {Color = color, Thickness = th or 2}, f)
    return f
end
local ICONS = {}
function ICONS.speaker(f, c)
    part(f, 0.24, 0.5, 0.2, 0.28, c, 0, 0.1)
    part(f, 0.4, 0.5, 0.28, 0.28, c, 45)
    part(f, 0.68, 0.5, 0.07, 0.28, c, 0, 0.5)
    part(f, 0.82, 0.5, 0.07, 0.5, c, 0, 0.5)
end
function ICONS.eq(f, c)
    local hs = {0.35, 0.7, 0.5, 0.85, 0.4}
    for i, h in ipairs(hs) do part(f, 0.12 + (i - 1) * 0.19, 0.5, 0.1, h, c, 0, 0.5) end
end
function ICONS.shirt(f, c)
    part(f, 0.5, 0.64, 0.44, 0.6, c, 0, 0.08)
    part(f, 0.2, 0.36, 0.34, 0.2, c, -25, 0.2)
    part(f, 0.8, 0.36, 0.34, 0.2, c, 25, 0.2)
    part(f, 0.5, 0.3, 0.2, 0.1, c, 0, 0.3)
end
function ICONS.dancer(f, c)
    part(f, 0.5, 0.17, 0.2, 0.2, c, 0, 0.5)
    part(f, 0.5, 0.5, 0.1, 0.38, c, 0, 0.5)
    part(f, 0.27, 0.34, 0.4, 0.08, c, -40, 0.5)
    part(f, 0.73, 0.4, 0.4, 0.08, c, 40, 0.5)
    part(f, 0.38, 0.8, 0.08, 0.36, c, 18, 0.5)
    part(f, 0.62, 0.8, 0.08, 0.36, c, -18, 0.5)
end
function ICONS.target(f, c)
    ring(f, 0.5, 0.5, 0.84, c, 2)
    ring(f, 0.5, 0.5, 0.46, c, 2)
    part(f, 0.5, 0.5, 0.14, 0.14, c, 0, 0.5)
end
function ICONS.search(f, c)
    ring(f, 0.43, 0.43, 0.56, c, 2)
    part(f, 0.78, 0.78, 0.34, 0.1, c, 45, 0.5)
end
function ICONS.user(f, c)
    part(f, 0.5, 0.3, 0.3, 0.3, c, 0, 0.5)
    part(f, 0.5, 0.74, 0.62, 0.34, c, 0, 0.5)
end
function ICONS.save(f, c)
    local sq = part(f, 0.5, 0.5, 0.78, 0.78, c, 0, 0.1)
    sq.BackgroundTransparency = 1
    N("UIStroke", {Color = c, Thickness = 2}, sq)
    part(f, 0.5, 0.3, 0.42, 0.18, c)
    part(f, 0.5, 0.72, 0.46, 0.26, c, 0, 0.1)
end
function ICONS.log(f, c)
    part(f, 0.5, 0.26, 0.74, 0.1, c, 0, 0.5)
    part(f, 0.5, 0.5, 0.74, 0.1, c, 0, 0.5)
    part(f, 0.37, 0.74, 0.48, 0.1, c, 0, 0.5)
end
function ICONS.refresh(f, c)
    ring(f, 0.5, 0.5, 0.7, c, 2)
    part(f, 0.84, 0.26, 0.22, 0.22, c, 45)
end
function ICONS.check(f, c)
    part(f, 0.33, 0.6, 0.3, 0.12, c, 45, 0.5)
    part(f, 0.6, 0.5, 0.62, 0.12, c, -50, 0.5)
end
function ICONS.undo(f, c)
    part(f, 0.58, 0.5, 0.56, 0.11, c, 0, 0.5)
    part(f, 0.28, 0.38, 0.32, 0.11, c, -40, 0.5)
    part(f, 0.28, 0.62, 0.32, 0.11, c, 40, 0.5)
end
function ICONS.trash(f, c)
    part(f, 0.5, 0.62, 0.5, 0.56, c, 0, 0.08)
    part(f, 0.5, 0.28, 0.72, 0.1, c, 0, 0.5)
    part(f, 0.5, 0.17, 0.26, 0.08, c, 0, 0.5)
end
function ICONS.folder(f, c)
    part(f, 0.5, 0.6, 0.82, 0.5, c, 0, 0.1)
    part(f, 0.3, 0.3, 0.36, 0.16, c, 0, 0.2)
end
function ICONS.x(f, c)
    part(f, 0.5, 0.5, 0.8, 0.13, c, 45, 0.5)
    part(f, 0.5, 0.5, 0.8, 0.13, c, -45, 0.5)
end
function ICONS.min(f, c) part(f, 0.5, 0.5, 0.7, 0.13, c, 0, 0.5) end
function ICONS.crescent(f, c, bg)
    part(f, 0.46, 0.5, 0.74, 0.74, c, 0, 0.5)
    part(f, 0.6, 0.44, 0.66, 0.66, bg, 0, 0.5)
    part(f, 0.78, 0.32, 0.15, 0.15, c, 0)
    part(f, 0.78, 0.32, 0.15, 0.15, c, 45)
end
function ICONS.play(f, c)
    local cl = part(f, 0.6, 0.5, 0.5, 0.7, c)
    cl.BackgroundTransparency = 1
    cl.ClipsDescendants = true
    part(cl, 0, 0.5, 1, 0.714, c, 45)
end
function ICONS.stop(f, c) part(f, 0.5, 0.5, 0.56, 0.56, c, 0, 0.15) end
function ICONS.mute(f, c)
    ICONS.speaker(f, c)
    part(f, 0.5, 0.5, 0.98, 0.1, c, -45, 0.5)
end
function ICONS.block(f, c)
    ring(f, 0.5, 0.5, 0.8, c, 2)
    part(f, 0.5, 0.5, 0.8, 0.12, c, -45, 0.5)
end
function ICONS.home(f, c)
    part(f, 0.5, 0.55, 0.66, 0.55, c, 0, 0.08)
    part(f, 0.5, 0.32, 0.86, 0.5, c, 45)
    part(f, 0.5, 0.72, 0.22, 0.32, c, 0, 0.08)
end

function Icon.draw(name, parent, color, size, bg)
    local f = N("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, size or 20, 0, size or 20), BackgroundTransparency = 1, ZIndex = parent.ZIndex + 1,
    }, parent)
    local fn = ICONS[name]
    if fn then fn(f, color, bg or Theme.BG2) end
    return f
end
function Icon.set(holder, name, color)
    for _, ch in ipairs(holder:GetChildren()) do ch:Destroy() end
    local fn = ICONS[name]
    if fn then fn(holder, color, Theme.BG1) end
end
function Icon.attach(btn, size)
    N("UIPadding", {PaddingLeft = UDim.new(0, size + 4)}, btn)
    return N("Frame", {Size = UDim2.new(0, size, 0, size), Position = UDim2.new(0, 4 - size, 0.5, -size / 2), BackgroundTransparency = 1, ZIndex = btn.ZIndex + 1}, btn)
end

--==============================================================
-- Helpers
--==============================================================
local WHITE = Color3.new(1, 1, 1)
local DARK = Color3.fromRGB(22, 16, 4)
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
    local dragging, startIn, startAbs = false, nil, nil
    handle.Active = true
    j:Add(handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, st.moved = true, false
            startIn, startAbs = i.Position, target.AbsolutePosition
            local conn
            conn = i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false conn:Disconnect() end
            end)
        end
    end))
    j:Add(UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - startIn
        if d.Magnitude > 5 then st.moved = true end
        local sz, vp = target.AbsoluteSize, viewport()
        local x = math.clamp(startAbs.X + d.X, -sz.X + 80, vp.X - 80)
        local y = math.clamp(startAbs.Y + d.Y, 0, vp.Y - 40)
        target.Position = UDim2.fromOffset(x, y)
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
    local function dropConns() for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end conns = {} end
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

--==============================================================
-- Toast (v3.7 style)
--==============================================================
local function makeToast(TG, J, vp)
    local curToast
    return function(text)
        if curToast then pcall(function() curToast:Destroy() end) end
        local tw = math.clamp(string.len(text) * 6 + 56, 150, vp.X - 20)
        local pill = N("Frame", {Size = UDim2.new(0, tw, 0, 36), Position = UDim2.new(0.5, -tw / 2, 0, -50), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, ZIndex = 100}, TG)
        UILib.corner(pill, 18)
        UILib.stroke(pill, Theme.Accent, 1.5, 0.2)
        N("Frame", {Size = UDim2.new(0, 7, 0, 7), Position = UDim2.new(0, 16, 0.5, -3), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Rotation = 45}, pill)
        Label(pill, {Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 32, 0, 0), Text = text, TextSize = 12, Font = Enum.Font.GothamBold})
        curToast = pill
        TweenService:Create(pill, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -tw / 2, 0, 30)}):Play()
        task.delay(1.8, function()
            if curToast ~= pill or not pill.Parent then return end
            local t = TweenService:Create(pill, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -tw / 2, 0, -50)})
            t:Play() t.Completed:Wait() pill:Destroy()
            if curToast == pill then curToast = nil end
        end)
    end
end

--==============================================================
-- Splash (v3.7)
--==============================================================
local function showSplash(onDone)
    local gui = Root:Add(N("ScreenGui", {Name = "BH_Splash", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 998, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local grp = N("CanvasGroup", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0}, gui)
    UILib.gradient(grp, Color3.fromRGB(24, 20, 12), Color3.fromRGB(6, 5, 3), 90)
    local plate = N("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -40), Size = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, ClipsDescendants = true}, grp)
    UILib.corner(plate, 48) UILib.stroke(plate, Theme.Accent, 2, 0.1)
    Icon.draw("crescent", plate, Theme.Accent, 66, Theme.BG2)
    local title = Label(grp, {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 300, 0, 34), Position = UDim2.new(0.5, 0, 0.5, 52), Text = "BE HALAL", Font = Enum.Font.GothamBold, TextSize = 28, TextColor3 = Theme.Accent2, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1})
    local sub = Label(grp, {AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 300, 0, 18), Position = UDim2.new(0.5, 0, 0.5, 82), Text = "v" .. VERSION .. "   |   " .. CREATOR_NAME, TextSize = 12, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1})
    local line = N("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 104), Size = UDim2.new(0, 0, 0, 2), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0}, grp)
    UILib.corner(line, 1)
    task.spawn(function()
        TweenService:Create(plate, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 96, 0, 96)}):Play()
        task.wait(0.4)
        TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        TweenService:Create(sub, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        TweenService:Create(line, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 180, 0, 2)}):Play()
        task.wait(1.1)
        local t = TweenService:Create(grp, TweenInfo.new(0.4), {GroupTransparency = 1})
        t:Play() t.Completed:Wait() gui:Destroy()
        if State.running then onDone() end
    end)
end

--==============================================================
-- Language screen (v3.7 style)
--==============================================================
local function showLangScreen(onDone)
    local mobile = isMobile()
    local vp = viewport()
    local gui = Root:Add(N("ScreenGui", {Name = "BHLang", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local chosen = false
    N("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(3, 2, 1), BackgroundTransparency = 0.25, BorderSizePixel = 0}, gui)
    local cw, ch = mobile and 300 or 380, 350
    local card = N("Frame", {Size = UDim2.new(0, cw, 0, ch), Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2 + 60), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true}, gui)
    UILib.corner(card, 22)
    UILib.gradient(card, Color3.fromRGB(30, 26, 18), Color3.fromRGB(12, 10, 7), 135)
    UILib.glow(UILib.stroke(card, Theme.Accent, 1.5, 0.3), Root)
    local plate = N("Frame", {Size = UDim2.new(0, 76, 0, 76), Position = UDim2.new(0.5, -38, 0, 24), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0}, card)
    UILib.corner(plate, 38) UILib.stroke(plate, Theme.Accent, 2, 0.15)
    Icon.draw("crescent", plate, Theme.Accent, 54, Theme.BG1)
    Label(card, {Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 110), Text = "Be Halal", Font = Enum.Font.GothamBold, TextSize = 24, TextColor3 = Theme.Accent2, TextXAlignment = Enum.TextXAlignment.Center})
    Label(card, {Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 142), Text = "Select language  |  اختر اللغة", TextColor3 = Theme.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center})
    local sep = N("Frame", {Size = UDim2.new(0.5, 0, 0, 1), Position = UDim2.new(0.25, 0, 0, 170), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.5, BorderSizePixel = 0}, card)
    UILib.gradient(sep, Theme.BG2, Theme.Accent, 0)
    local function option(tag, text, desc, y, lang)
        local bc = N("Frame", {Size = UDim2.new(1, -56, 0, 70), Position = UDim2.new(0, 28, 0, y), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, card)
        UILib.corner(bc, 16)
        local bs = UILib.stroke(bc, Theme.Accent, 1.2, 0.6)
        local badge = N("Frame", {Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 14, 0.5, -22), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0}, bc)
        UILib.corner(badge, 12) UILib.stroke(badge, Theme.Accent, 1, 0.5)
        Label(badge, {Size = UDim2.new(1, 0, 1, 0), Text = tag, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Center})
        Label(bc, {Size = UDim2.new(1, -110, 0, 22), Position = UDim2.new(0, 70, 0, 14), Text = text, Font = Enum.Font.GothamBold, TextSize = 17})
        Label(bc, {Size = UDim2.new(1, -110, 0, 16), Position = UDim2.new(0, 70, 0, 38), Text = desc, TextColor3 = Theme.TextDim, TextSize = 11})
        Label(bc, {Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -30, 0, 0), Text = ">", TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Center})
        local b = N("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, bc)
        b.MouseEnter:Connect(function() TweenService:Create(bc, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardHi}):Play() bs.Transparency = 0.1 end)
        b.MouseLeave:Connect(function() TweenService:Create(bc, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play() bs.Transparency = 0.6 end)
        b.Activated:Connect(function()
            if chosen then return end
            chosen = true
            TweenService:Create(card, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2 + 80)}):Play()
            task.wait(0.25)
            gui:Destroy()
            onDone(lang)
        end)
    end
    option("AR", "العربية", "واجهة عربية كاملة", 190, "ar")
    option("EN", "English", "Full English interface", 270, "en")
    TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2)}):Play()
end

--==============================================================
-- Kit (v3.7 visuals, v4.0 API)
--==============================================================
local Kit = {}
local KIND = {
    primary   = {bg = Theme.Accent,  hover = Theme.Accent2, fg = DARK},
    secondary = {bg = Theme.Card,    hover = Theme.CardHi,  fg = Theme.Text,   line = Theme.Accent},
    ghost     = {bg = Theme.BG3,     hover = Theme.BG3,     fg = Theme.TextDim},
    danger    = {bg = Theme.Danger,  hover = Theme.DangerHi,fg = WHITE},
    tabOn     = {bg = Theme.OnBG,    hover = Theme.OnBG,    fg = Theme.Accent, line = Theme.Accent},
    off       = {bg = Theme.BG3,     hover = Theme.BG3,     fg = Theme.TextDim,line = Theme.TextDim},
}
function Kit.merge(base, extra)
    for k, v in pairs(extra or {}) do base[k] = v end
    return base
end
function Kit.frame(parent, props)
    return N("Frame", Kit.merge({BorderSizePixel = 0, BackgroundColor3 = Theme.Card}, props), parent)
end
function Kit.label(parent, props)
    return N("TextLabel", Kit.merge({
        BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.GothamMedium, TextColor3 = Theme.Text,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, props), parent)
end
function Kit.corner(o, r) return UILib.corner(o, r or 10) end
function Kit.stroke(o, col, th, tp) return UILib.stroke(o, col or Theme.Accent, th or 1.2, tp or 0.5) end
function Kit.pad(o, l, t, r, b)
    return N("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0), PaddingTop = UDim.new(0, t or l or 0),
        PaddingRight = UDim.new(0, r or l or 0), PaddingBottom = UDim.new(0, b or t or l or 0),
    }, o)
end
function Kit.scroller(parent, props)
    return N("ScrollingFrame", Kit.merge({
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, ElasticBehavior = Enum.ElasticBehavior.Never,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
    }, props), parent)
end
function Kit.section(parent, text, order)
    local hf = N("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = order}, parent)
    N("Frame", {Size = UDim2.new(0, 7, 0, 7), Position = UDim2.new(0, 4, 0.5, -3), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Rotation = 45}, hf)
    Kit.label(hf, {Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(0, 20, 0, 0), Text = text, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12})
    local l = N("Frame", {Size = UDim2.new(1, -196, 0, 1), Position = UDim2.new(0, 190, 0.5, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0}, hf)
    N("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})}, l)
    return hf
end
function Kit.button(parent, props, kind, J)
    local b = N("TextButton", Kit.merge({
        BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 11, Text = "",
    }, props), parent)
    Kit.corner(b, 8)
    local st = UILib.stroke(b, Theme.Accent, 1.2, 0.7)
    local o = {inst = b, kind = kind}
    function o.set(k)
        o.kind = k
        local d = KIND[k] or KIND.secondary
        b.BackgroundColor3 = d.bg
        b.TextColor3 = d.fg
        st.Color = d.line or d.bg
        st.Transparency = d.line and 0.2 or 1
    end
    J:Add(b.MouseEnter:Connect(function()
        local d = KIND[o.kind] or KIND.secondary
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = d.hover}):Play()
    end))
    J:Add(b.MouseLeave:Connect(function()
        local d = KIND[o.kind] or KIND.secondary
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = d.bg}):Play()
    end))
    o.set(kind or "secondary")
    return o
end
function Kit.search(parent, pos, size, placeholder, J)
    local f = Kit.frame(parent, {Position = pos, Size = size, BackgroundColor3 = Theme.BG3})
    Kit.corner(f, 10)
    local st = UILib.stroke(f, Theme.Accent, 1.2, 0.75)
    local icon = N("Frame", {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 8, 0.5, -13), BackgroundTransparency = 1}, f)
    Icon.draw("search", icon, Theme.TextDim, 15)
    local box = N("TextBox", {
        Size = UDim2.new(1, -42, 1, 0), Position = UDim2.fromOffset(36, 0), BackgroundTransparency = 1, Text = "",
        PlaceholderText = placeholder, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    }, f)
    J:Add(box.Focused:Connect(function() st.Color = Theme.Accent2 st.Transparency = 0.2 end))
    J:Add(box.FocusLost:Connect(function() st.Color = Theme.Accent st.Transparency = 0.75 end))
    return f, box
end
function Kit.switch(parent, pos, initial, J, onChange)
    local track = N("TextButton", {
        Size = UDim2.fromOffset(42, 24), Position = pos, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        BackgroundColor3 = initial and Theme.Accent or Theme.Off,
    }, parent)
    Kit.corner(track, 12)
    local ts = UILib.stroke(track, initial and Theme.Accent or Theme.TextDim, 1.2, 0.4)
    local knob = Kit.frame(track, {Size = UDim2.fromOffset(18, 18), BackgroundColor3 = initial and DARK or WHITE, Position = initial and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)})
    Kit.corner(knob, 9)
    local sw = {on = initial}
    local function paint(animate)
        local ti = TweenInfo.new(animate and 0.16 or 0, Enum.EasingStyle.Quad)
        TweenService:Create(track, ti, {BackgroundColor3 = sw.on and Theme.Accent or Theme.Off}):Play()
        TweenService:Create(knob, ti, {
            Position = sw.on and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = sw.on and DARK or WHITE,
        }):Play()
        ts.Color = sw.on and Theme.Accent or Theme.TextDim
        ts.Transparency = sw.on and 0.2 or 0.6
    end
    J:Add(track.Activated:Connect(function()
        sw.on = not sw.on
        paint(true)
        if onChange then onChange(sw.on) end
    end))
    function sw.set(v) sw.on = v paint(false) end
    paint(false)
    return sw
end
function Kit.card(parent, order)
    local c = Kit.frame(parent, {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order})
    Kit.corner(c, 12)
    local cs = UILib.stroke(c, Theme.Accent, 1.2, 0.6)
    UILib.gradient(c, Theme.Card, Theme.BG3, 90)
    N("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, c)
    return {inst = c, n = 0, stroke = cs}
end
function Kit.cardRow(card, height)
    if card.n > 0 then
        local d = Kit.frame(card.inst, {Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 0, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.6, LayoutOrder = card.n * 2 - 1})
    end
    card.n = card.n + 1
    return Kit.frame(card.inst, {Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, LayoutOrder = card.n * 2})
end
function Kit.segmented(parent, pos, size, names, J, onSelect, labelsFn)
    local f = Kit.frame(parent, {Position = pos, Size = size, BackgroundColor3 = Theme.BG3})
    Kit.corner(f, 10)
    UILib.stroke(f, Theme.Accent, 1, 0.65)
    Kit.pad(f, 3)
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, f)
    local seg = {frame = f, btns = {}, current = names[1]}
    local n = #names
    function seg.select(name)
        seg.current = name
        for nm, b in pairs(seg.btns) do b.set(nm == name and "tabOn" or "off") end
    end
    for i, nm in ipairs(names) do
        local b = Kit.button(f, {Size = UDim2.new(1 / n, -3 * (n - 1) / n, 1, 0), LayoutOrder = i, TextSize = 11}, "off", J)
        seg.btns[nm] = b
        J:Add(b.inst.Activated:Connect(function()
            seg.select(nm)
            if onSelect then onSelect(nm) end
        end))
    end
    function seg.text(nm, t) seg.btns[nm].inst.Text = t end
    seg.select(names[1])
    return seg
end

--==============================================================
-- Pages
--==============================================================
local CATS = {"music", "ambient", "sfx", "ui", "other"}
local CAT_KEY = {music = "catMusic", ambient = "catAmbient", sfx = "catSfx", ui = "catUi", other = "catOther"}
local CAT_ICON = {music = "eq", ambient = "speaker", sfx = "speaker", ui = "log", other = "log"}
local function sortByName(arr, nameOf, keyOf)
    table.sort(arr, function(a, b)
        local na, nb = lower(nameOf(a)), lower(nameOf(b))
        if na ~= nb then return na < nb end
        return keyOf(a) < keyOf(b)
    end)
end

-- Icon plate for cards/toggles
local function iconPlate(parent, icon, on, size, padL)
    local s = size or 36
    local ib = N("Frame", {Size = UDim2.new(0, s, 0, s), Position = UDim2.new(0, padL or 12, 0.5, -s / 2), BackgroundColor3 = on and Theme.OnBG or Theme.BG3, BorderSizePixel = 0, ZIndex = parent.ZIndex + 1}, parent)
    UILib.corner(ib, math.floor(s / 3))
    UILib.stroke(ib, on and Theme.Accent or Theme.TextDim, 1, on and 0.3 or 0.6)
    local ic = Icon.draw(icon, ib, on and Theme.Accent or Theme.TextDim, math.floor(s * 0.55))
    return ib, ic
end

-- Home page
local function pageHome(ctx)
    local J, page, toast = ctx.J, ctx.page, ctx.toast
    local sc = Kit.scroller(page)
    N("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, sc)
    Kit.pad(sc, 0, 0, 8, 6)
    local ord = 0
    local function nxt() ord = ord + 1 return ord end

    -- Stats tiles (v3.7 card style)
    local tilesF = Kit.frame(sc, {Size = UDim2.new(1, 0, 0, 62), BackgroundTransparency = 1, LayoutOrder = nxt()})
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, tilesF)
    local function tile(i, icon, caption)
        local t = Kit.frame(tilesF, {Size = UDim2.new(1 / 3, -6, 1, 0), LayoutOrder = i})
        Kit.corner(t, 12)
        local ts = UILib.stroke(t, Theme.Accent, 1.2, 0.55)
        UILib.gradient(t, Theme.Card, Theme.BG3, 90)
        local ib = N("Frame", {Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(0, 10, 0.5, -17), BackgroundColor3 = Theme.OnBG, BorderSizePixel = 0}, t)
        UILib.corner(ib, 10)
        Icon.draw(icon, ib, Theme.Accent, 18)
        local num = Kit.label(t, {Size = UDim2.new(1, -56, 0, 24), Position = UDim2.new(0, 52, 0, 6), Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Theme.Accent2, Text = "0"})
        Kit.label(t, {Size = UDim2.new(1, -56, 0, 14), Position = UDim2.new(0, 52, 0, 32), TextSize = 11, TextColor3 = Theme.TextDim, Text = caption})
        return num
    end
    local nPlayers = tile(1, "user", tr("statPlayers"))
    local nSounds  = tile(2, "eq", tr("statSounds"))
    local nMuted   = tile(3, "mute", tr("statMuted"))

    local function group(title)
        Kit.section(sc, title, nxt())
        return Kit.card(sc, nxt())
    end
    local function toggle(card, title, desc, icon, get, set)
        local row = Kit.cardRow(card, 58)
        local ib, ic = iconPlate(row, icon, get())
        Kit.label(row, {Size = UDim2.new(1, -138, 0, 16), Position = UDim2.fromOffset(58, 12), Text = title, TextSize = 13, Font = Enum.Font.GothamBold})
        local sub = Kit.label(row, {Size = UDim2.new(1, -138, 0, 14), Position = UDim2.fromOffset(58, 31), Text = desc, TextSize = 11, TextColor3 = Theme.TextDim})
        Kit.switch(row, UDim2.new(1, -54, 0.5, -12), get(), J, function(v)
            set(v)
            toast(title .. "  |  " .. (v and "ON" or "OFF"))
            TweenService:Create(ib, TweenInfo.new(0.18), {BackgroundColor3 = v and Theme.OnBG or Theme.BG3}):Play()
            TweenService:Create(ic, TweenInfo.new(0.18), {BackgroundColor3 = v and Theme.Accent or Theme.TextDim}):Play()
            for _, d in ipairs(ib:GetDescendants()) do
                if d:IsA("Frame") and d.BackgroundTransparency < 1 then d.BackgroundColor3 = v and Theme.Accent or Theme.TextDim end
                local us = d:FindFirstChildOfClass("UIStroke"); if us then us.Color = v and Theme.Accent or Theme.TextDim end
            end
            sub.TextColor3 = v and Theme.Accent or Theme.TextDim
            sub.Text = v and "ON" or "OFF"
        end)
    end

    local c1 = group(tr("secAudio"))
    toggle(c1, tr("muteMusic"), tr("muteMusicD"), "speaker", function() return State.muteMusic end, function(v)
        State.muteMusic = v; Audio.setGlobalMute(v); Config.save()
    end)
    local c2 = group(tr("secAppearance"))
    toggle(c2, tr("noobSkin"), tr("noobSkinD"), "shirt", function() return State.noob end, function(v)
        State.noob = v; Targets.refreshAll(); Config.save()
    end)
    local c3 = group(tr("secMotion"))
    toggle(c3, tr("stopDance"), tr("stopDanceD"), "dancer", function() return State.dances end, function(v)
        State.dances = v; Config.save()
    end)
    toggle(c3, tr("broadDance"), tr("broadDanceD"), "target", function() return State.broadDances end, function(v)
        State.broadDances = v; Config.save()
    end)
    local c4 = group(tr("secData"))
    toggle(c4, tr("autosave"), tr("autosaveD"), "save", function() return Audio.autosave end, function(v)
        Audio.setAutosave(v)
    end)

    return {refresh = function()
        nPlayers.Text = tostring(math.max(#Players:GetPlayers() - 1, 0))
        local live, muted = 0, 0
        for _ in pairs(Audio.groups()) do live = live + 1 end
        for _, st in pairs(Audio.settings) do if st.m then muted = muted + 1 end end
        nSounds.Text = tostring(live)
        nMuted.Text = tostring(muted)
    end}
end

-- Sounds page (v4.0 logic, v3.7 cards)
local function pageSounds(ctx)
    local J, page, toast = ctx.J, ctx.page, ctx.toast
    local tab, catFilter, query, sortMode = "playing", "all", "", "name"
    local rows, curGroups, visibleKeys = {}, {}, {}
    local refresh

    local _, searchBox = Kit.search(page, UDim2.fromOffset(0, 0), UDim2.new(1, -100, 0, 30), tr("searchSound"), J)
    local sortB = Kit.button(page, {Size = UDim2.fromOffset(92, 30), Position = UDim2.new(1, -92, 0, 0), TextSize = 11}, "secondary", J)

    local chipStrip = N("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 36), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X, ElasticBehavior = Enum.ElasticBehavior.Never,
    }, page)
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, chipStrip)
    local chipOrder = {"all", "music", "ambient", "sfx", "ui", "other"}
    local chips = {}
    for i, c in ipairs(chipOrder) do
        local b = Kit.button(chipStrip, {Size = UDim2.fromOffset(40, 24), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = i, TextSize = 11}, "secondary", J)
        Kit.pad(b.inst, 12, 0, 12, 0)
        chips[c] = b
        J:Add(b.inst.Activated:Connect(function() catFilter = c refresh() end))
    end

    local seg = Kit.segmented(page, UDim2.fromOffset(0, 70), UDim2.new(0.62, 0, 0, 30), {"playing", "all", "muted"}, J, function(name)
        tab = name; refresh()
    end)
    local actB = Kit.button(page, {Size = UDim2.new(0.38, -6, 0, 30), Position = UDim2.new(0.62, 6, 0, 70), TextSize = 11}, "secondary", J)

    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -108), Position = UDim2.fromOffset(0, 108)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)

    local headers = {}
    for i, c in ipairs(CATS) do
        local hf = Kit.label(list, {Size = UDim2.new(1, 0, 0, 18), LayoutOrder = i * 10000, Visible = false, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11})
        headers[c] = hf
    end
    local empty = Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyFilter"), TextColor3 = Theme.TextDim, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    local function makeRow(k)
        local rj = Janitor.new()
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 52), Visible = false, BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, list)
        UILib.corner(row, 12)
        local rs = UILib.stroke(row, Theme.Accent, 1.2, 0.7)
        local dot = N("Frame", {Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(12, 14), BackgroundColor3 = Theme.TextDim, BorderSizePixel = 0, Rotation = 45}, row)
        local nameLbl = Kit.label(row, {Size = UDim2.new(1, -112, 0, 18), Position = UDim2.fromOffset(26, 8), TextSize = 13, Font = Enum.Font.GothamBold})
        local nameBox = N("TextBox", {
            Size = UDim2.new(1, -112, 0, 22), Position = UDim2.fromOffset(26, 6), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, Text = "",
            PlaceholderText = tr("namePh"), TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Visible = false,
        }, row)
        UILib.corner(nameBox, 6) Kit.pad(nameBox, 8, 0, 8, 0)
        local metaLbl = Kit.label(row, {Size = UDim2.new(1, -112, 0, 14), Position = UDim2.fromOffset(26, 28), TextSize = 11, TextColor3 = Theme.TextDim})
        local tap = N("TextButton", {Size = UDim2.new(1, -90, 0, 52), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, row)
        local muteB = Kit.button(row, {Size = UDim2.fromOffset(66, 26), Position = UDim2.new(1, -76, 0, 13), TextSize = 11}, "secondary", rj)
        local pctL = Kit.label(row, {Size = UDim2.fromOffset(40, 24), Position = UDim2.new(1, -184, 0, 58), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, Visible = false})
        local listenB = Kit.button(row, {Size = UDim2.fromOffset(62, 24), Position = UDim2.new(1, -138, 0, 58), TextSize = 11, Visible = false}, "secondary", rj)
        local editB = Kit.button(row, {Size = UDim2.fromOffset(58, 24), Position = UDim2.new(1, -70, 0, 58), TextSize = 11, Visible = false, Text = tr("rename")}, "ghost", rj)
        local slider = makeSlider(row, UDim2.fromOffset(14, 58), UDim2.new(1, -208, 0, 24), rj, function(v)
            local g = curGroups[k]
            local st = Audio.entry(k, g and g.base)
            st.f = v
            Audio.commit(k)
            pctL.Text = math.floor(v * 100 + 0.5) .. "%"
        end)
        slider.hit.Visible = false
        local r = {frame = row, j = rj, expanded = false, stroke = rs}
        local function layout()
            row.Size = UDim2.new(1, 0, 0, r.expanded and 92 or 52)
            pctL.Visible, listenB.inst.Visible, editB.inst.Visible, slider.hit.Visible = r.expanded, r.expanded, r.expanded, r.expanded
        end
        rj:Add(tap.Activated:Connect(function() r.expanded = not r.expanded layout() end))
        rj:Add(muteB.inst.Activated:Connect(function()
            local g = curGroups[k]
            local st = Audio.entry(k, g and g.base)
            st.m = not st.m
            Audio.commit(k)
            refresh()
        end))
        rj:Add(listenB.inst.Activated:Connect(function()
            if Audio.solo == k then Audio.soloStop()
            elseif curGroups[k] and curGroups[k].count > 0 then Audio.soloPlay(k) end
            refresh()
        end))
        rj:Add(editB.inst.Activated:Connect(function()
            local st = Audio.settings[k]
            local g = curGroups[k]
            nameBox.Text = (st and st.c) or (g and g.base) or ""
            nameLbl.Visible, nameBox.Visible = false, true
            nameBox:CaptureFocus()
        end))
        rj:Add(nameBox.FocusLost:Connect(function()
            local t2 = string.sub(trim(nameBox.Text), 1, 40)
            local g = curGroups[k]
            local st = Audio.entry(k, g and g.base)
            st.c = (t2 ~= "") and t2 or nil
            Audio.commit(k)
            nameBox.Visible, nameLbl.Visible = false, true
            refresh()
        end))

        function r.update(g)
            local st = Audio.settings[k]
            local muted = st and st.m == true
            local f = st and st.f or 1
            if not nameBox.Visible then nameLbl.Text = g.name end
            local meta = tr(CAT_KEY[g.cat])
            if g.len > 0 then meta = meta .. "  ·  " .. Audio.fmtTime(g.len) end
            if g.looped then meta = meta .. "  ·  " .. tr("loop") end
            if g.count > 1 then meta = meta .. "  ·  ×" .. g.count end
            if math.abs(f - 1) > 0.001 then meta = meta .. "  ·  " .. math.floor(f * 100 + 0.5) .. "%" end
            metaLbl.Text = meta .. "  ·  " .. g.path
            if not slider.dragging then slider.set(f) end
            pctL.Text = math.floor(f * 100 + 0.5) .. "%"
            dot.BackgroundColor3 = muted and Theme.Danger or (g.playing and Theme.Accent or Theme.TextDim)
            rs.Color = muted and Theme.Danger or Theme.Accent
            muteB.inst.Text = muted and tr("unmute") or tr("mute")
            muteB.set(muted and "primary" or "secondary")
            if Audio.solo == k then listenB.inst.Text, listenB.set("primary")
            else listenB.inst.Text = tr("listen"); listenB.set(g.count > 0 and "secondary" or "off") end
        end
        return r
    end

    refresh = function()
        local groups = {}
        for k, g in pairs(Audio.groups()) do groups[k] = g end
        for k, st in pairs(Audio.settings) do
            if st.m and not groups[k] then
                groups[k] = {key = k, count = 0, playing = false, len = 0, name = st.c or st.n or k, base = st.n or k, path = "-", looped = false, cat = Audio.catCache[k] or "other"}
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
            if ok and query ~= "" then ok = lower(g.name .. " " .. g.path .. " " .. k):find(query, 1, true) ~= nil end
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
            headers[c].Visible = #arr > 0
            headers[c].Text = string.upper(tr(CAT_KEY[c])) .. "  ·  " .. #arr
        end
        local hidden = {}
        for k, r in pairs(rows) do
            if not shown[k] then
                if not groups[k] then killRow(r) rows[k] = nil
                else r.frame.Visible = false table.insert(hidden, k) end
            end
        end
        if #hidden > 150 then for _, k in ipairs(hidden) do killRow(rows[k]) rows[k] = nil end end
        for _, c in ipairs(chipOrder) do
            local b = chips[c]
            local label = (c == "all") and tr("catAll") or tr(CAT_KEY[c])
            b.inst.Text = label .. "  " .. catCount[c]
            b.set(catFilter == c and "primary" or "secondary")
        end
        seg.text("playing", tr("tabPlaying") .. "  " .. nPlaying)
        seg.text("all", tr("tabAll") .. "  " .. nAll)
        seg.text("muted", tr("tabMuted") .. "  " .. nMuted)
        sortB.inst.Text = (sortMode == "name") and tr("sortName") or tr("sortLen")
        if Audio.solo then actB.inst.Text = tr("stopListening"); actB.set("primary")
        elseif tab == "muted" then actB.inst.Text = tr("unmuteAll") .. "  " .. #visibleKeys; actB.set("secondary")
        else actB.inst.Text = tr("muteAll") .. "  " .. #visibleKeys; actB.set("danger") end
        empty.Visible = (#visibleKeys == 0)
    end
    J:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function() query = lower(trim(searchBox.Text)); refresh() end))
    J:Add(sortB.inst.Activated:Connect(function() sortMode = (sortMode == "name") and "len" or "name"; refresh() end))
    J:Add(actB.inst.Activated:Connect(function()
        if Audio.solo then Audio.soloStop()
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
    J:Add(function() for _, r in pairs(rows) do r.j:Clean() end end)
    return {refresh = refresh}
end
local function killRow(r) r.j:Clean() r.frame:Destroy() end

-- Music log (v4.0 logic, v3.7 cards)
local function pageMusic(ctx)
    local J, page = ctx.J, ctx.page
    local rows, query = {}, ""
    local refresh
    local bannerDot = N("Frame", {Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(4, 6), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Rotation = 45}, page)
    local banner = Kit.label(page, {Size = UDim2.new(1, -90, 0, 18), Position = UDim2.fromOffset(18, 0), Font = Enum.Font.GothamBold, TextSize = 12})
    local clearB = Kit.button(page, {Size = UDim2.fromOffset(70, 22), Position = UDim2.new(1, -70, 0, -2), TextSize = 11, Text = tr("clear")}, "secondary", J)
    local _, searchBox = Kit.search(page, UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 30), tr("logSearch"), J)
    local hint = Kit.label(page, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 62), Text = tr("logHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextYAlignment = Enum.TextYAlignment.Top})
    local bar = Kit.frame(page, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 62), BackgroundTransparency = 1, Visible = false})
    local stopB = Kit.button(bar, {Size = UDim2.fromOffset(120, 28), Position = UDim2.fromOffset(0, 1), TextSize = 11, Text = tr("stopListening")}, "primary", J)
    local pctL = Kit.label(bar, {Size = UDim2.fromOffset(42, 28), Position = UDim2.new(1, -42, 0, 1), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.GothamBold, TextColor3 = Theme.Accent, Text = "100%"})
    local soloSlider = makeSlider(bar, UDim2.fromOffset(130, 1), UDim2.new(1, -182, 0, 28), J, function(v)
        local k = Audio.solo
        if not k then return end
        local e = Audio.log[k]
        local st = Audio.entry(k, e and e.base)
        st.f = v; Audio.commit(k); pctL.Text = math.floor(v * 100 + 0.5) .. "%"
    end)
    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -98), Position = UDim2.fromOffset(0, 98)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)
    local empty = Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyLog"), TextColor3 = Theme.TextDim, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    local function makeRow(k)
        local rj = Janitor.new()
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 66), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, list)
        UILib.corner(row, 12)
        local rs = UILib.stroke(row, Theme.Accent, 1.2, 0.7)
        local dot = N("Frame", {Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(12, 14), BackgroundColor3 = Theme.TextDim, BorderSizePixel = 0, Rotation = 45}, row)
        local nameL = Kit.label(row, {Size = UDim2.new(1, -170, 0, 18), Position = UDim2.fromOffset(26, 8), TextSize = 13, Font = Enum.Font.GothamBold})
        local metaL = Kit.label(row, {Size = UDim2.new(1, -170, 0, 14), Position = UDim2.fromOffset(26, 27), TextSize = 11, TextColor3 = Theme.TextDim})
        local stateL = Kit.label(row, {Size = UDim2.new(1, -170, 0, 14), Position = UDim2.fromOffset(26, 42), TextSize = 11, TextColor3 = Theme.TextDim})
        local listenB = Kit.button(row, {Size = UDim2.fromOffset(66, 26), Position = UDim2.new(1, -148, 0, 20), TextSize = 11}, "secondary", rj)
        local exemptB = Kit.button(row, {Size = UDim2.fromOffset(66, 26), Position = UDim2.new(1, -76, 0, 20), TextSize = 11}, "danger", rj)
        local listenIc, exemptIc = Icon.attach(listenB.inst, 12), Icon.attach(exemptB.inst, 12)
        rj:Add(listenB.inst.Activated:Connect(function()
            if Audio.solo == k then Audio.soloStop()
            elseif Audio.isLive(k) then Audio.soloPlay(k) end
            refresh()
        end))
        rj:Add(exemptB.inst.Activated:Connect(function()
            local e = Audio.log[k]
            local st = Audio.entry(k, e and e.base)
            st.x = (not st.x) or nil
            Audio.commit(k)
            refresh()
        end))
        local r = {frame = row, j = rj, stroke = rs}
        function r.update(e, g)
            local st = Audio.settings[k]
            local exempt = st and st.x
            local live = g ~= nil
            nameL.Text = g and g.name or e.name or k
            metaL.Text = Audio.fmtTime(e.len) .. (e.looped and ("  ·  " .. tr("loop")) or "") .. ((g and g.count > 1) and ("  ·  ×" .. g.count) or "") .. "  ·  " .. (e.path or "")
            local state = exempt and tr("stExempt") or (State.muteMusic and tr("stByButton") or tr("stWillMute"))
            local play = (not live) and tr("stGone") or (g.playing and tr("stPlaying") or tr("stIdle"))
            stateL.Text = state .. "  ·  " .. play
            dot.BackgroundColor3 = exempt and Theme.Accent or ((State.muteMusic and Theme.Danger) or Theme.TextDim)
            rs.Color = exempt and Theme.Accent or Theme.Accent2
            if Audio.solo == k then
                listenB.inst.Text = tr("stop")
                listenB.set("primary")
                Icon.set(listenIc, "stop", DARK)
            else
                listenB.inst.Text = tr("listen")
                listenB.set(live and "secondary" or "off")
                Icon.set(listenIc, "play", live and Theme.Text or Theme.TextDim)
            end
            exemptB.inst.Text = exempt and tr("exempt") or tr("willMute")
            exemptB.set(exempt and "primary" or "danger")
            Icon.set(exemptIc, exempt and "speaker" or "mute", exempt and DARK or WHITE)
        end
        return r
    end
    refresh = function()
        banner.Text = State.muteMusic and tr("logOn") or tr("logOff")
        banner.TextColor3 = State.muteMusic and Theme.Accent2 or Theme.TextDim
        bannerDot.BackgroundColor3 = State.muteMusic and Theme.Accent or Theme.TextDim
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
            if not seen[k] then killRow(r) rows[k] = nil end
        end
        empty.Visible = (#arr == 0)
    end
    J:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function() query = lower(trim(searchBox.Text)); refresh() end))
    J:Add(clearB.inst.Activated:Connect(function() Audio.log = {}; refresh() end))
    J:Add(stopB.inst.Activated:Connect(function() Audio.soloStop(); refresh() end))
    J:Add(function() for _, r in pairs(rows) do r.j:Clean() end end)
    return {refresh = refresh}
end

-- Animations page (v4.0 logic, v3.7 cards)
local function pageAnim(ctx)
    local J, page = ctx.J, ctx.page
    local rows = {}
    local refresh
    Kit.label(page, {Size = UDim2.new(1, 0, 0, 30), Text = tr("animHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextYAlignment = Enum.TextYAlignment.Top})
    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -38), Position = UDim2.fromOffset(0, 38)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)
    local empty = Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyAnim"), TextColor3 = Theme.TextDim, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    local function makeRow(k)
        local rj = Janitor.new()
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, list)
        UILib.corner(row, 12)
        local rs = UILib.stroke(row, Theme.Danger, 1.2, 0.7)
        local ib = N("Frame", {Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(0, 10, 0.5, -17), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0}, row)
        UILib.corner(ib, 10)
        local ic = Icon.draw("dancer", ib, Theme.Accent, 18)
        local nameL = Kit.label(row, {Size = UDim2.new(1, -140, 0, 18), Position = UDim2.fromOffset(52, 8), TextSize = 13, Font = Enum.Font.GothamBold})
        local idL = Kit.label(row, {Size = UDim2.new(1, -140, 0, 14), Position = UDim2.fromOffset(52, 28), TextSize = 11, TextColor3 = Theme.TextDim})
        local btn = Kit.button(row, {Size = UDim2.fromOffset(86, 28), Position = UDim2.new(1, -96, 0.5, -14), TextSize = 11}, "danger", rj)
        local btnIc = Icon.attach(btn.inst, 12)
        rj:Add(btn.inst.Activated:Connect(function()
            if State.animAllow[k] then State.animAllow[k] = nil else State.animAllow[k] = true end
            Config.save()
            refresh()
        end))
        local r = {frame = row, j = rj, stroke = rs}
        function r.update(e)
            local allowed = State.animAllow[k] == true
            nameL.Text = e and e.name or k
            idL.Text = (k:sub(1, 2) == "n:" and "-" or ("ID " .. k)) .. (e and ("  ·  ×" .. e.n) or "")
            rs.Color = allowed and Theme.Accent or Theme.Danger
            btn.inst.Text = allowed and tr("animAllowed") or tr("animBlocked")
            btn.set(allowed and "primary" or "danger")
            Icon.set(btnIc, allowed and "check" or "block", allowed and DARK or WHITE)
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
            if not seen[k] then killRow(r) rows[k] = nil end
        end
        empty.Visible = (#arr == 0)
    end
    J:Add(function() for _, r in pairs(rows) do r.j:Clean() end end)
    return {refresh = refresh}
end

-- Players page (v4.0 logic, v3.7 rows)
local function pagePlayers(ctx)
    local J, page = ctx.J, ctx.page
    local segName, query = "online", ""
    local rows, currentTarget = {}, nil
    local refresh, layout

    local seg = Kit.segmented(page, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 30), {"online", "allowed", "blocked"}, J, function(name)
        segName = name; layout(); refresh()
    end)
    local searchF, searchBox = Kit.search(page, UDim2.fromOffset(0, 36), UDim2.new(1, 0, 0, 30), tr("searchPlayer"), J)
    local addF, addBox = Kit.search(page, UDim2.fromOffset(0, 36), UDim2.new(1, -72, 0, 30), tr("addPlayer"), J)
    local addB = Kit.button(page, {Size = UDim2.fromOffset(64, 30), Position = UDim2.new(1, -64, 0, 36), TextSize = 12, Text = tr("add")}, "primary", J)

    -- Suggest card
    local card = N("Frame", {Size = UDim2.new(1, 0, 0, 60), Position = UDim2.fromOffset(0, 72), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, page)
    UILib.corner(card, 12)
    UILib.stroke(card, Theme.Accent, 1.2, 0.6)
    UILib.gradient(card, Theme.Card, Theme.BG3, 90)
    local sAv = N("ImageLabel", {Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(12, 10), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop}, card)
    UILib.corner(sAv, 20) UILib.stroke(sAv, Theme.Accent, 1, 0.4)
    local sName = Kit.label(card, {Size = UDim2.new(1, -200, 0, 18), Position = UDim2.fromOffset(60, 12), TextSize = 13, Font = Enum.Font.GothamBold})
    local sSub = Kit.label(card, {Size = UDim2.new(1, -200, 0, 14), Position = UDim2.fromOffset(60, 32), TextSize = 11, TextColor3 = Theme.TextDim})
    local sAllow = Kit.button(card, {Size = UDim2.fromOffset(58, 28), Position = UDim2.new(1, -132, 0, 16), TextSize = 11, Text = tr("allow")}, "primary", J)
    local sBlock = Kit.button(card, {Size = UDim2.fromOffset(58, 28), Position = UDim2.new(1, -68, 0, 16), TextSize = 11, Text = tr("block")}, "danger", J)

    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -138), Position = UDim2.fromOffset(0, 138)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)
    local empty = Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), TextColor3 = Theme.TextDim, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    layout = function()
        local online = segName == "online"
        searchF.Visible = online
        addF.Visible, addB.inst.Visible = not online, not online
        card.Visible = online
        local y = online and 138 or 72
        list.Position = UDim2.fromOffset(0, y)
        list.Size = UDim2.new(1, 0, 1, -y)
    end

    local function makeRow(sg, info)
        local rj = Janitor.new()
        local name = info.Name
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, list)
        UILib.corner(row, 12)
        UILib.stroke(row, Theme.Accent, 1, 0.7)
        local av = N("ImageLabel", {Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(8, 6), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop}, row)
        UILib.corner(av, 17) UILib.stroke(av, Theme.Accent, 1, 0.4)
        local bw = (sg == "online") and 130 or 78
        local nameL = Kit.label(row, {Size = UDim2.new(1, -(52 + bw + 8), 0, 16), Position = UDim2.fromOffset(48, 6), TextSize = 13, Font = Enum.Font.GothamBold})
        local subL = Kit.label(row, {Size = UDim2.new(1, -(52 + bw + 8), 0, 14), Position = UDim2.fromOffset(48, 24), TextSize = 11, TextColor3 = Theme.TextDim})
        if sg == "online" then
            local a = Kit.button(row, {Size = UDim2.fromOffset(58, 26), Position = UDim2.new(1, -132, 0, 10), TextSize = 11, Text = tr("allow")}, "primary", rj)
            local b = Kit.button(row, {Size = UDim2.fromOffset(58, 26), Position = UDim2.new(1, -68, 0, 10), TextSize = 11, Text = tr("block")}, "danger", rj)
            rj:Add(a.inst.Activated:Connect(function() listSet(name, "white") end))
            rj:Add(b.inst.Activated:Connect(function() listSet(name, "black") end))
        else
            local b = Kit.button(row, {Size = UDim2.fromOffset(70, 26), Position = UDim2.new(1, -80, 0, 10), TextSize = 11, Text = (sg == "allowed") and tr("remove") or tr("restore")}, "secondary", rj)
            rj:Add(b.inst.Activated:Connect(function() listSet(name, nil) end))
        end
        local r = {frame = row, j = rj, avSet = false}
        function r.update(inf)
            local dn = (inf.DisplayName and inf.DisplayName ~= "") and inf.DisplayName or inf.Name
            local isCreator = lower(inf.Name) == lower(CREATOR_NAME)
            nameL.Text = dn
            nameL.TextColor3 = isCreator and Theme.Gold or Theme.Text
            subL.Text = "@" .. inf.Name .. (isCreator and ("  ·  " .. tr("creator")) or "")
            if not r.avSet then
                if inf.UserId then
                    av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. inf.UserId .. "&w=150&h=150"
                    r.avSet = true
                else
                    userIdAsync(inf.Name, function(id)
                        if av.Parent then av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. id .. "&w=150&h=150" end
                    end)
                    r.avSet = true
                end
            end
        end
        return r
    end

    local function updateSuggest()
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
        sAllow.inst.Visible, sBlock.inst.Visible = best ~= nil, best ~= nil
        if best then
            sName.Text = (best.DisplayName ~= "" and best.DisplayName or best.Name)
            sName.TextColor3 = Theme.Text
            sSub.Text = tr("inView") .. "  ·  @" .. best.Name
            sAv.Image = "rbxthumb://type=AvatarHeadShot&id=" .. best.UserId .. "&w=150&h=150"
        else
            sName.Text = tr("noneInView")
            sName.TextColor3 = Theme.TextDim
            sSub.Text = tr("inView")
            sAv.Image = ""
        end
    end

    refresh = function()
        local me = lower(LP.Name)
        local arr, nOnline = {}, 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and not isWhite(p) and not isBlack(p) then nOnline = nOnline + 1 end
        end
        local nW, nB = 0, 0
        for n in pairs(State.W) do if n ~= me then nW = nW + 1 end end
        for n in pairs(State.B) do if n ~= me then nB = nB + 1 end end
        seg.text("online", tr("segOnline") .. "  " .. nOnline)
        seg.text("allowed", tr("segAllowed") .. "  " .. nW)
        seg.text("blocked", tr("segBlocked") .. "  " .. nB)
        if segName == "online" then
            updateSuggest()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and not isWhite(p) and not isBlack(p) then
                    local dn, un = lower(p.DisplayName ~= "" and p.DisplayName or p.Name), lower(p.Name)
                    if query == "" or dn:find(query, 1, true) or un:find(query, 1, true) then
                        table.insert(arr, {key = un, info = p})
                    end
                end
            end
        else
            local set = (segName == "allowed") and State.W or State.B
            for n in pairs(set) do
                if n ~= me then
                    local p = findPlayer(n)
                    table.insert(arr, {key = n, info = p or {Name = n, DisplayName = n}})
                end
            end
        end
        sortByName(arr, function(e) return e.info.DisplayName ~= "" and e.info.DisplayName or e.info.Name end, function(e) return e.key end)
        local seen = {}
        for i, e in ipairs(arr) do
            local rk = segName .. "|" .. e.key
            local r = rows[rk]
            if not r then r = makeRow(segName, e.info) rows[rk] = r end
            r.frame.LayoutOrder = i
            r.update(e.info)
            seen[rk] = true
        end
        for rk, r in pairs(rows) do
            if not seen[rk] then killRow(r) rows[rk] = nil end
        end
        empty.Text = (segName == "online") and tr("noPlayers") or tr("empty")
        empty.Visible = (#arr == 0)
    end
    J:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function() query = lower(trim(searchBox.Text)); refresh() end))
    local function submitAdd()
        local n = resolveName(addBox.Text)
        if not n then return end
        addBox.Text = ""
        listSet(n, (segName == "allowed") and "white" or "black")
    end
    J:Add(addB.inst.Activated:Connect(submitAdd))
    J:Add(addBox.FocusLost:Connect(function(enter) if enter then submitAdd() end end))
    J:Add(sAllow.inst.Activated:Connect(function() if currentTarget then listSet(currentTarget.Name, "white") end end))
    J:Add(sBlock.inst.Activated:Connect(function() if currentTarget then listSet(currentTarget.Name, "black") end end))
    J:Add(function() for _, r in pairs(rows) do r.j:Clean() end end)
    layout()
    return {refresh = refresh}
end

--==============================================================
-- Main window (v3.7 look, v4.0 5-page sidebar)
--==============================================================
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
    local TG = J:Add(N("ScreenGui", {Name = "BH_Toast", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 90, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local toast = makeToast(TG, J, vp)

    local W = math.min(mobile and 560 or 700, vp.X - 24)
    local H = math.min(mobile and 460 or 500, vp.Y - 30)
    local RAIL = 112
    local TH = 76
    local sx, sy = (vp.X - W) / 2, (vp.Y - H) / 2
    local rest = UDim2.fromOffset(sx, sy)
    local firstShow = (UI.pos == nil)

    local win = N("Frame", {Name = "Window", Size = UDim2.fromOffset(W, H), Position = UI.pos or UDim2.fromOffset(sx, sy + 14), BackgroundColor3 = Theme.BG2, ClipsDescendants = true, BorderSizePixel = 0}, G)
    UILib.corner(win, 18)
    UILib.gradient(win, Theme.BG1, Theme.BG3, 135)
    UILib.glow(UILib.stroke(win, Theme.Accent, 1.5, 0.35), J)
    UILib.halo(win, 18, J)

    -- Header
    local header = N("Frame", {Size = UDim2.new(1, 0, 0, TH), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0, ZIndex = 3}, win)
    UILib.corner(header, 18)
    UILib.gradient(header, Color3.fromRGB(40, 33, 17), Color3.fromRGB(16, 13, 8), 90)
    makeDraggable(header, win, J, function() UI.pos = win.Position end)
    local logo = N("Frame", {Size = UDim2.new(0, 48, 0, 48), Position = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0, ZIndex = 4}, header)
    UILib.corner(logo, 24) UILib.stroke(logo, Theme.Accent, 1.5, 0.15)
    Icon.draw("crescent", logo, Theme.Accent, 34, Theme.BG1)
    Label(header, {Size = UDim2.new(1, -220, 0, 24), Position = UDim2.new(0, 72, 0, 16), Text = tr("title"), Font = Enum.Font.GothamBold, TextSize = 19, TextColor3 = Theme.Accent2, ZIndex = 4})
    Label(header, {Size = UDim2.new(1, -220, 0, 14), Position = UDim2.new(0, 72, 0, 42), Text = tr("subtitle") .. "  ·  v" .. VERSION, TextColor3 = Theme.TextDim, TextSize = 11, ZIndex = 4})
    local rule = N("Frame", {Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 1, -1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 4}, header)
    N("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.2), NumberSequenceKeypoint.new(1, 1)})}, rule)

    local minBtn = Btn(header, {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -74, 0, 24), BackgroundColor3 = Theme.Card, Text = "", ZIndex = 4}, 14)
    UILib.stroke(minBtn, Theme.Accent, 1.5, 0.5)
    Icon.draw("min", minBtn, Theme.Accent, 14)
    local closeBtn = Btn(header, {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -40, 0, 24), BackgroundColor3 = Theme.Card, Text = "", ZIndex = 4}, 14)
    UILib.stroke(closeBtn, Theme.Danger, 1.5, 0.5)
    Icon.draw("x", closeBtn, Theme.DangerHi, 12)

    -- Sidebar (RAIL)
    local rail = N("Frame", {Size = UDim2.new(0, RAIL, 1, -TH - 1), Position = UDim2.fromOffset(0, TH + 1), BackgroundTransparency = 1, ZIndex = 3}, win)
    Kit.pad(rail, 8, 12, 8, 8)
    N("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, rail)
    N("Frame", {Size = UDim2.new(0, 1, 1, -TH - 1), Position = UDim2.fromOffset(RAIL, TH + 1), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.65, BorderSizePixel = 0, ZIndex = 4}, win)
    Kit.label(win, {Size = UDim2.fromOffset(RAIL - 16, 12), Position = UDim2.new(0, 14, 1, -22), Text = CREATOR_NAME, TextSize = 10, TextColor3 = Theme.TextDim, ZIndex = 4})

    local content = N("Frame", {Size = UDim2.new(1, -RAIL - 1, 1, -TH - 1), Position = UDim2.fromOffset(RAIL + 1, TH + 1), BackgroundTransparency = 1, ZIndex = 3}, win)
    Kit.pad(content, 14, 12, 8, 10)

    local pages, navBtns, current = {}, {}, nil
    local show

    -- Sidebar nav (icon + label)
    local NAV_ICON = {home = "home", sounds = "eq", music = "log", anim = "dancer", players = "user"}
    local function navButton(id, text, order)
        local b = N("TextButton", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 5}, rail)
        UILib.corner(b, 8)
        local ind = N("Frame", {Size = UDim2.fromOffset(3, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false, ZIndex = 6}, b)
        UILib.corner(ind, 2)
        local ib = N("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 8, 0.5, -11), BackgroundTransparency = 1, ZIndex = 6}, b)
        local ic = Icon.draw(NAV_ICON[id], ib, Theme.TextDim, 16)
        local lbl = Kit.label(b, {Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(34, 0), Text = text, TextSize = 11, TextColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium, ZIndex = 6})
        navBtns[id] = {btn = b, ind = ind, lbl = lbl, icon = ic}
        J:Add(b.MouseEnter:Connect(function()
            if current ~= id then TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 0.55}):Play() end
        end))
        J:Add(b.MouseLeave:Connect(function()
            if current ~= id then TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play() end
        end))
        J:Add(b.Activated:Connect(function() show(id) end))
    end

    show = function(name)
        current = name
        for id, p in pairs(pages) do p.frame.Visible = (id == name) end
        for id, nb in pairs(navBtns) do
            local on = (id == name)
            nb.ind.Visible = on
            nb.btn.BackgroundTransparency = on and 0 or 1
            nb.btn.BackgroundColor3 = on and Theme.Card or Theme.Card
            nb.lbl.TextColor3 = on and Theme.Accent2 or Theme.TextDim
            nb.lbl.Font = on and Enum.Font.GothamBold or Enum.Font.GothamMedium
            for _, d in ipairs(nb.icon:GetDescendants()) do
                if d:IsA("Frame") and d.BackgroundTransparency < 1 then d.BackgroundColor3 = on and Theme.Accent or Theme.TextDim end
                local us = d:FindFirstChildOfClass("UIStroke"); if us then us.Color = on and Theme.Accent or Theme.TextDim end
            end
        end
        local p = pages[name]
        if p and p.refresh then pcall(p.refresh) end
    end

    local specs = {
        {"home", "navHome", pageHome},
        {"sounds", "navSounds", pageSounds},
        {"music", "navMusic", pageMusic},
        {"anim", "navAnim", pageAnim},
        {"players", "navPlayers", pagePlayers},
    }
    for i, sp in ipairs(specs) do
        local f = N("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 4}, content)
        local api = sp[3]({J = J, page = f, toast = toast}) or {}
        api.frame = f
        pages[sp[1]] = api
        navButton(sp[1], tr(sp[2]), i)
    end

    UI.refresh = function()
        local p = pages.players
        if p and current == "players" and p.refresh then pcall(p.refresh) end
    end

    local alive = true
    J:Add(function() alive = false end)
    task.spawn(function()
        while alive and State.running do
            task.wait(0.5)
            local p = pages[current]
            if win.Visible and p and p.refresh then pcall(p.refresh) end
        end
    end)

    -- Minimized icon (crescent, glow, halo)
    local mini = Btn(G, {Size = UDim2.new(0, 60, 0, 60), Position = win.Position, BackgroundColor3 = Theme.BG2, Text = "", Visible = false, ZIndex = 4}, 30)
    UILib.glow(UILib.stroke(mini, Theme.Accent, 2, 0.2), J, 2)
    Icon.draw("crescent", mini, Theme.Accent, 38, Theme.BG2)
    UILib.halo(mini, 30, J)
    local miniDrag = makeDraggable(mini, mini, J)
    local function setMin(on)
        if on then
            mini.Position = win.Position
            win.Visible, mini.Visible = false, true
        else
            win.Position = mini.Position
            UI.pos = win.Position
            win.Visible, mini.Visible = true, false
        end
    end
    J:Add(minBtn.Activated:Connect(function() setMin(true) end))
    J:Add(mini.Activated:Connect(function() if not miniDrag.moved then setMin(false) end end))
    J:Add(closeBtn.Activated:Connect(function() ENV.__BeHalal.destroy() end))

    show("home")
    if firstShow then
        UI.pos = rest
        TweenService:Create(win, TweenInfo.new(0.55, Enum.EasingStyle.Back), {Position = rest}):Play()
    end
end

--==============================================================
-- Lifecycle + Boot
--==============================================================
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
    showSplash(function()
        if State.running then UI.build() end
    end)
end)
