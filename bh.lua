--[[
    Be Halal |  
    v3.6 - client side
    by EZ_NOOB11220

    :
      Janitor  Utils  Theme  Translations  Audio  Skin  Hide
      Dances  Targets  Lists  Saves  UI helpers  Language screen
      Sound log  Dance log  Saves panel  Main UI  Lifecycle  Boot
]]

local Players      = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UIS          = game:GetService("UserInputService")
local Workspace    = game:GetService("Workspace")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local Marketplace  = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local CREATOR_NAME = "EZ_NOOB11220"
local VERSION = "3.6"

local ENV = (getgenv and getgenv()) or _G
if ENV.__BeHalal and type(ENV.__BeHalal.destroy) == "function" then
    pcall(ENV.__BeHalal.destroy)
end
for _, n in ipairs({"BH", "BH_SoundsMgr", "BH_SoundLog", "BH_AnimLog", "BH_Saves", "BHLang"}) do
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
    W = {}, B = {}, animAllow = {}, animBlock = {},
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
        title="\u{628}\u{64A} \u{62D}\u{644}\u{627}\u{644}", subtitle="\u{623}\u{62F}\u{648}\u{627}\u{62A} \u{625}\u{633}\u{644}\u{627}\u{645}\u{64A}\u{629} \u{644}\u{644}\u{633}\u{64A}\u{631}\u{641}\u{631}",
        sectionAudio="\u{627}\u{644}\u{635}\u{648}\u{62A}", sectionVisual="\u{627}\u{644}\u{645}\u{638}\u{647}\u{631}", sectionTools="\u{627}\u{644}\u{623}\u{62F}\u{648}\u{627}\u{62A}",
        sectionPlayers="\u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{648}\u{646}", sectionLists="\u{627}\u{644}\u{642}\u{648}\u{627}\u{626}\u{645}",
        muteMusic="\u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}", noobSkin="\u{633}\u{643}\u{646}\u{627}\u{62A} \u{646}\u{648}\u{628}", stopDance="\u{625}\u{64A}\u{642}\u{627}\u{641} \u{627}\u{644}\u{631}\u{642}\u{635}\u{627}\u{62A}", broadDance="\u{643}\u{634}\u{641} \u{634}\u{627}\u{645}\u{644} \u{644}\u{644}\u{631}\u{642}\u{635}\u{627}\u{62A}",
        suggest="\u{627}\u{642}\u{62A}\u{631}\u{627}\u{62D} \u{644}\u{627}\u{639}\u{628}", whitelist="\u{627}\u{644}\u{645}\u{633}\u{645}\u{648}\u{62D}\u{648}\u{646}", blocked="\u{627}\u{644}\u{645}\u{62D}\u{62C}\u{648}\u{628}\u{648}\u{646}",
        searchPH="\u{627}\u{628}\u{62D}\u{62B} \u{639}\u{646} \u{644}\u{627}\u{639}\u{628}...", on="\u{645}\u{641}\u{639}\u{651}\u{644}", off="\u{645}\u{639}\u{637}\u{651}\u{644}", noPlayers="\u{644}\u{627} \u{64A}\u{648}\u{62C}\u{62F} \u{644}\u{627}\u{639}\u{628}\u{648}\u{646}",
        wl="\u{633}\u{645}\u{627}\u{62D}", block="\u{62D}\u{62C}\u{628}", empty="\u{641}\u{627}\u{631}\u{63A}", footer="\u{628}\u{64A} \u{62D}\u{644}\u{627}\u{644}", none="\u{2014}",
        soundLog="\u{1F3A7}  \u{633}\u{62C}\u{644} \u{627}\u{644}\u{623}\u{635}\u{648}\u{627}\u{62A}", soundLogTitle="\u{633}\u{62C}\u{644} \u{627}\u{644}\u{623}\u{635}\u{648}\u{627}\u{62A}", clearLog="\u{1F5D1} \u{645}\u{633}\u{62D}", stopShort="\u{23F9} \u{625}\u{64A}\u{642}\u{627}\u{641}", stopListen="\u{23F9} \u{625}\u{64A}\u{642}\u{627}\u{641} \u{627}\u{644}\u{627}\u{633}\u{62A}\u{645}\u{627}\u{639}",
        emptyLog="\u{645}\u{627} \u{627}\u{634}\u{62A}\u{63A}\u{644} \u{623}\u{64A} \u{635}\u{648}\u{62A} \u{628}\u{639}\u{62F}", logSearch="\u{1F50D} \u{627}\u{628}\u{62D}\u{62B} \u{641}\u{64A} \u{627}\u{644}\u{633}\u{62C}\u{644}...",
        soundHint="\u{627}\u{644}\u{623}\u{635}\u{648}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{64A} \u{64A}\u{643}\u{62A}\u{645}\u{647}\u{627} \u{632}\u{631} \u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}. \u{1F3A7} \u{62A}\u{633}\u{645}\u{639}\u{647} \u{644}\u{62D}\u{627}\u{644}\u{647}\u{60C} \u{648}\u{1F50A} \u{62A}\u{633}\u{62A}\u{62B}\u{646}\u{64A}\u{647} \u{645}\u{646} \u{627}\u{644}\u{643}\u{62A}\u{645}.",
        stPlaying="\u{25B6} \u{634}\u{63A}\u{627}\u{644}", stIdle="\u{23F8} \u{645}\u{62A}\u{648}\u{642}\u{641}", stGone="\u{2716} \u{627}\u{62E}\u{62A}\u{641}\u{649} \u{645}\u{646} \u{627}\u{644}\u{645}\u{627}\u{628}",
        btnOn="\u{632}\u{631} \u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}: \u{645}\u{641}\u{639}\u{651}\u{644}", btnOff="\u{632}\u{631} \u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}: \u{645}\u{639}\u{637}\u{651}\u{644}",
        exemptOn="\u{645}\u{633}\u{62A}\u{62B}\u{646}\u{649}", exemptOff="\u{64A}\u{64F}\u{643}\u{62A}\u{645}", stExempt="\u{1F50A} \u{645}\u{633}\u{62A}\u{62B}\u{646}\u{649} \u{645}\u{646} \u{627}\u{644}\u{643}\u{62A}\u{645}", stByButton="\u{1F507} \u{645}\u{643}\u{62A}\u{648}\u{645} \u{628}\u{627}\u{644}\u{632}\u{631}", stWillMute="\u{23F3} \u{64A}\u{64F}\u{643}\u{62A}\u{645} \u{644}\u{645}\u{627} \u{62A}\u{641}\u{639}\u{651}\u{644} \u{627}\u{644}\u{632}\u{631}",
        listenShort="\u{1F3A7} \u{627}\u{633}\u{62A}\u{645}\u{639}",
        animLog="\u{1F4DC}  \u{633}\u{62C}\u{644} \u{627}\u{644}\u{631}\u{642}\u{635}\u{627}\u{62A}", animTitle="\u{633}\u{62C}\u{644} \u{627}\u{644}\u{631}\u{642}\u{635}\u{627}\u{62A}", allowedTag="\u{645}\u{633}\u{645}\u{648}\u{62D}\u{629}", blockedTag="\u{645}\u{62D}\u{62C}\u{648}\u{628}\u{629}",
        animHint="\u{631}\u{642}\u{635}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{64A}\u{646} \u{648}\u{62D}\u{631}\u{643}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{639}\u{628}\u{629} \u{62A}\u{638}\u{647}\u{631} \u{647}\u{646}\u{627}. \u{627}\u{636}\u{63A}\u{637} \u{639}\u{644}\u{649} \u{627}\u{644}\u{632}\u{631} \u{639}\u{634}\u{627}\u{646} \u{62A}\u{62D}\u{62C}\u{628} \u{623}\u{648} \u{62A}\u{633}\u{645}\u{62D}.",
        emptyAnim="\u{645}\u{627} \u{627}\u{646}\u{631}\u{635}\u{62F}\u{62A} \u{623}\u{64A} \u{62D}\u{631}\u{643}\u{629} \u{628}\u{639}\u{62F}", animAll="\u{627}\u{644}\u{643}\u{644}", animPlayers="\u{631}\u{642}\u{635}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{64A}\u{646}", animGame="\u{645}\u{646} \u{627}\u{644}\u{644}\u{639}\u{628}\u{629}",
        tagPlayer="\u{1F483} \u{631}\u{642}\u{635}\u{629} \u{644}\u{627}\u{639}\u{628}", tagGame="\u{1F3AE} \u{645}\u{646} \u{627}\u{644}\u{644}\u{639}\u{628}\u{629}", tagSaved="\u{1F4CC} \u{645}\u{62D}\u{641}\u{648}\u{638}\u{629}",
        saveBtn="\u{1F4BE}  \u{62D}\u{641}\u{638}", savesTitle="\u{627}\u{644}\u{62D}\u{641}\u{638}", saveNamePh="\u{627}\u{633}\u{645} \u{627}\u{644}\u{62D}\u{641}\u{638}...", saveNow="\u{62D}\u{641}\u{638}", loadShort="\u{62A}\u{62D}\u{645}\u{64A}\u{644}",
        saveHint="\u{64A}\u{62D}\u{641}\u{638} \u{643}\u{644} \u{625}\u{639}\u{62F}\u{627}\u{62F}\u{627}\u{62A}\u{643} \u{627}\u{644}\u{62D}\u{627}\u{644}\u{64A}\u{629} (\u{627}\u{644}\u{623}\u{632}\u{631}\u{627}\u{631} \u{648}\u{627}\u{644}\u{642}\u{648}\u{627}\u{626}\u{645} \u{648}\u{627}\u{644}\u{623}\u{635}\u{648}\u{627}\u{62A}) \u{628}\u{627}\u{644}\u{627}\u{633}\u{645} \u{627}\u{644}\u{644}\u{64A} \u{62A}\u{62E}\u{62A}\u{627}\u{631}\u{647}.",
        emptySaves="\u{645}\u{627} \u{641}\u{64A}\u{647} \u{62D}\u{641}\u{638} \u{628}\u{639}\u{62F}", saved="\u{2713} \u{62A}\u{645} \u{627}\u{644}\u{62D}\u{641}\u{638}", thisMap="\u{647}\u{630}\u{627} \u{627}\u{644}\u{645}\u{627}\u{628}",
        resetAll="\u{1F5D1}  \u{645}\u{633}\u{62D} \u{643}\u{644} \u{627}\u{644}\u{628}\u{64A}\u{627}\u{646}\u{627}\u{62A}", resetConfirm="\u{26A0} \u{627}\u{636}\u{63A}\u{637} \u{645}\u{631}\u{629} \u{62B}\u{627}\u{646}\u{64A}\u{629} \u{644}\u{644}\u{62A}\u{623}\u{643}\u{64A}\u{62F}",
    },
    en = {
        title="Be Halal", subtitle="Islamic server tools",
        sectionAudio="Audio", sectionVisual="Visual", sectionTools="Tools",
        sectionPlayers="Players", sectionLists="Lists",
        muteMusic="Mute Music", noobSkin="Noob Skins", stopDance="Stop Dances", broadDance="Broad Dance Detection",
        suggest="Suggest Player", whitelist="Whitelisted", blocked="Blocked",
        searchPH="Search for player...", on="Active", off="Disabled", noPlayers="No players found",
        wl="Allow", block="Block", empty="Empty", footer="Be Halal", none="\u{2014}",
        soundLog="\u{1F3A7}  Sound Log", soundLogTitle="Sound Log", clearLog="\u{1F5D1} Clear", stopShort="\u{23F9} Stop", stopListen="\u{23F9} Stop Listening",
        emptyLog="No sound played yet", logSearch="\u{1F50D} Search the log...",
        soundHint="Sounds caught by the Mute Music button. \u{1F3A7} listens to it alone, \u{1F50A} exempts it from muting.",
        stPlaying="\u{25B6} Playing", stIdle="\u{23F8} Idle", stGone="\u{2716} Gone from map",
        btnOn="Mute Music button: ON", btnOff="Mute Music button: OFF",
        exemptOn="Exempt", exemptOff="Muted", stExempt="\u{1F50A} Exempt from muting", stByButton="\u{1F507} Muted by button", stWillMute="\u{23F3} Will mute when button is on",
        listenShort="\u{1F3A7} Listen",
        animLog="\u{1F4DC}  Dance Log", animTitle="Dance Log", allowedTag="Allowed", blockedTag="Blocked",
        animHint="Player dances and game animations show here. Tap the button to block or allow.",
        emptyAnim="No animation detected yet", animAll="All", animPlayers="Player dances", animGame="From game",
        tagPlayer="\u{1F483} Player dance", tagGame="\u{1F3AE} From game", tagSaved="\u{1F4CC} Saved",
        saveBtn="\u{1F4BE}  Save", savesTitle="Saves", saveNamePh="Save name...", saveNow="Save", loadShort="Load",
        saveHint="Saves all your current settings (toggles, lists and sounds) under the name you choose.",
        emptySaves="Nothing saved yet", saved="\u{2713} Saved", thisMap="This map",
        resetAll="\u{1F5D1}  Clear all data", resetConfirm="\u{26A0} Tap again to confirm",
    },
}
local function tr(k) return (T[State.lang] or T.en)[k] or T.en[k] or k end

---------------------------------------------------------------- State
local Audio

---------------------------------------------------------------- Audio
Audio = {
    settings = {},                                   -- [key] = {m, f, n, c, x}
    rec = setmetatable({}, {__mode = "k"}),
    hooks = {},
    globalMute = false, solo = nil, _tick = 0,
}
local KW = {"music","bgm","song","theme","soundtrack","radio","lofi","playlist","muzik","ambience"}
local keyCache = setmetatable({}, {__mode = "k"})

function Audio.keyOf(s)
    local id = s.SoundId
    local c = keyCache[s]
    if c and c[1] == id then return c[2] end
    local key
    if id and id ~= "" then
        local num = id:match("rbxassetid://(%d+)") or id:match("[?&]id=(%d+)")
        key = "id:" .. (num or id)
    else
        key = "path:" .. s:GetFullName()
    end
    keyCache[s] = {id, key}
    return key
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
--   ( ...)  
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
            j:Clean()
            Audio.hooks[s] = nil
            Audio.rec[s] = nil
        else
            Audio.enforce(s)
            if s.IsPlaying then Audio.note(s) end
        end
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

-- /  (  )
function Audio.snapshot()
    local out = {}
    for k, st in pairs(Audio.settings) do
        out[k] = {m = st.m, f = st.f, n = st.n, c = st.c, x = st.x}
    end
    return out
end
function Audio.restore(t)
    Audio.settings = {}
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then
                Audio.settings[k] = {
                    m = v.m == true, f = tonumber(v.f) or 1, n = tostring(v.n or k),
                    x = (v.x == true) or nil,
                    c = (type(v.c) == "string" and v.c ~= "") and v.c or nil,
                }
            end
        end
    end
    Audio.solo = nil
    Audio._gc = nil
    Audio.enforceAll()
end

function Audio.setGlobalMute(on)
    Audio.globalMute = on
    Audio.enforceAll()
end
function Audio.init()
    Audio.globalMute = State.muteMusic
    Root:Add(game.DescendantAdded:Connect(function(d)
        if d:IsA("Sound") then Audio.hook(d) end
    end))
    task.spawn(function()
        local n = 0
        for _, d in ipairs(game:GetDescendants()) do
            if not State.running then return end
            if d:IsA("Sound") then Audio.hook(d) end
            n = n + 1
            if n % 1500 == 0 then task.wait() end
        end
    end)
    --    0.25      
    Root:Add(RunService.Heartbeat:Connect(function()
        if not (Audio.globalMute or Audio.solo) then return end
        local now = os.clock()
        if now - Audio._tick < 0.25 then return end
        Audio._tick = now
        Audio.enforceAll()
    end))
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
    for _, j in pairs(Audio.hooks) do j:Clean() end
    Audio.hooks = {}
end

---------------------------------------------------------------- Skin
--  :              
local Skin = {}
local backups = {}
local NC = {Skin = Color3.fromRGB(245,205,48), T = Color3.fromRGB(13,105,172), Lg = Color3.fromRGB(40,127,71)}
local PART_COLORS = {
    LeftArm=NC.Skin, RightArm=NC.Skin, Torso=NC.T, LeftLeg=NC.Lg, RightLeg=NC.Lg,
    UpperTorso=NC.T, LowerTorso=NC.T, LeftUpperArm=NC.Skin, LeftLowerArm=NC.Skin, LeftHand=NC.Skin,
    RightUpperArm=NC.Skin, RightLowerArm=NC.Skin, RightHand=NC.Skin, LeftUpperLeg=NC.Lg, LeftLowerLeg=NC.Lg,
    LeftFoot=NC.Lg, RightUpperLeg=NC.Lg, RightLowerLeg=NC.Lg, RightFoot=NC.Lg,
}
local SKIN_FX = {ParticleEmitter = true, Trail = true, Beam = true, Fire = true, Smoke = true, Sparkles = true}
local FACE_TEX = "rbxasset://textures/face.png"
-- R15: all body parts are hidden and replaced by classic noob blocks
local R15_PARTS = {}
for _, n in ipairs({"UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do R15_PARTS[n] = true end

local function isMine(i) return i.Name:sub(1, 3) == "BH_" end
local function inTool(i) return i:FindFirstAncestorOfClass("Tool") ~= nil end

local function setProp(b, inst, prop, value)
    local ok, cur = pcall(function() return inst[prop] end)
    if not ok then return end
    local rec = b.props[inst]
    if not rec then rec = {} b.props[inst] = rec end
    if rec[prop] == nil then rec[prop] = cur end
    if cur ~= value then pcall(function() inst[prop] = value end) end
end

function Skin.has(c) return backups[c] ~= nil end
function Skin.forget(c) backups[c] = nil end

--     
local function dirty(d, c, head)
    if isMine(d) then return false end
    if d:IsA("Shirt") then return d.ShirtTemplate ~= "" end
    if d:IsA("Pants") then return d.PantsTemplate ~= "" end
    if d:IsA("ShirtGraphic") then return d.Graphic ~= "" end
    if d:IsA("CharacterMesh") or d:IsA("SurfaceAppearance") then return true end
    if SKIN_FX[d.ClassName] then return d.Enabled and not inTool(d) end
    if d:IsA("Decal") then return d.Parent == head and d.Transparency < 1 end
    if d:IsA("BasePart") then
        if d == head then return d.Transparency < 1 end
        if d.Name == "HumanoidRootPart" then return false end
        if R15_PARTS[d.Name] and d.Parent == c then return d.Transparency < 1 end
        local col = PART_COLORS[d.Name]
        if col and d.Parent == c then
            if not close(d.Color, col) or d.Material ~= Enum.Material.Plastic then return true end
            return d:IsA("MeshPart") and d.TextureID ~= ""
        end
        return d.Transparency < 1 and not inTool(d)
    end
    return false
end

function Skin.needs(c)
    local head = c:FindFirstChild("Head")
    if head and not c:FindFirstChild("BH_head") then return true end
    if c:FindFirstChild("UpperTorso") and not c:FindFirstChild("BH_torso") then return true end
    for _, d in ipairs(c:GetDescendants()) do
        if dirty(d, c, head) then return true end
    end
    return false
end

local function mkBlock(c, name, size, color, anchor, offset)
    local p = c:FindFirstChild(anchor)
    if not p or c:FindFirstChild(name) then return end
    local nb = N("Part", {
        Name = name, Size = size, Color = color, Material = Enum.Material.Plastic,
        CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
        TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
    }, c)
    N("Weld", {Part0 = p, Part1 = nb, C0 = CFrame.new(offset)}, nb)
end

function Skin.apply(c)
    if not c or not c.Parent or not c:FindFirstChildOfClass("Humanoid") then return end
    local b = backups[c]
    if not b then b = {props = {}, removed = {}} backups[c] = b end
    local head = c:FindFirstChild("Head")
    for _, d in ipairs(c:GetDescendants()) do
        if not isMine(d) then
            if d:IsA("Shirt") then setProp(b, d, "ShirtTemplate", "")
            elseif d:IsA("Pants") then setProp(b, d, "PantsTemplate", "")
            elseif d:IsA("ShirtGraphic") then setProp(b, d, "Graphic", "")
            elseif d:IsA("CharacterMesh") or d:IsA("SurfaceAppearance") then
                table.insert(b.removed, {d, d.Parent})
                d.Parent = nil
            elseif SKIN_FX[d.ClassName] then
                if not inTool(d) then setProp(b, d, "Enabled", false) end
            elseif d:IsA("Decal") then
                if d.Parent == head then setProp(b, d, "Transparency", 1) end
            elseif d:IsA("BasePart") then
                if d == head then
                    setProp(b, d, "Transparency", 1)
                elseif d.Name ~= "HumanoidRootPart" then
                    local col = PART_COLORS[d.Name]
                    if R15_PARTS[d.Name] and d.Parent == c then
                        setProp(b, d, "Transparency", 1)
                    elseif col and d.Parent == c then
                        setProp(b, d, "Color", col)
                        setProp(b, d, "Material", Enum.Material.Plastic)
                        if d:IsA("MeshPart") then setProp(b, d, "TextureID", "") end
                    elseif not inTool(d) then
                        setProp(b, d, "Transparency", 1)
                    end
                end
            end
        end
    end
    if head and not c:FindFirstChild("BH_head") then
        local nh = N("Part", {
            Name = "BH_head", Size = Vector3.new(2, 1, 1), Color = NC.Skin, Material = Enum.Material.Plastic,
            CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
            TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
        }, c)
        N("SpecialMesh", {MeshType = Enum.MeshType.Head, Scale = Vector3.new(1.25, 1.25, 1.25)}, nh)
        N("Decal", {Name = "BH_face", Texture = FACE_TEX, Face = Enum.NormalId.Front}, nh)
        N("Weld", {Part0 = head, Part1 = nh}, nh)
    end
    if c:FindFirstChild("UpperTorso") then
        mkBlock(c, "BH_torso", Vector3.new(2, 2, 1), NC.T, "UpperTorso", Vector3.new(0, -0.2, 0))
        mkBlock(c, "BH_larm", Vector3.new(1, 2, 1), NC.Skin, "LeftUpperArm", Vector3.new(0, -0.4, 0))
        mkBlock(c, "BH_rarm", Vector3.new(1, 2, 1), NC.Skin, "RightUpperArm", Vector3.new(0, -0.4, 0))
        mkBlock(c, "BH_lleg", Vector3.new(1, 2.3, 1), NC.Lg, "LeftUpperLeg", Vector3.new(0, -0.55, 0))
        mkBlock(c, "BH_rleg", Vector3.new(1, 2.3, 1), NC.Lg, "RightUpperLeg", Vector3.new(0, -0.55, 0))
    end
end

function Skin.restore(c)
    local b = backups[c]
    if not b then return end
    backups[c] = nil
    for inst, props in pairs(b.props) do
        for prop, v in pairs(props) do pcall(function() inst[prop] = v end) end
    end
    for _, r in ipairs(b.removed) do pcall(function() r[1].Parent = r[2] end) end
    for _, x in ipairs(c:GetChildren()) do
        if isMine(x) then pcall(function() x:Destroy() end) end
    end
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
local seenTracks = setmetatable({}, {__mode = "k"})
Dances.log = {}   -- [key] = {key, name, kind = "dance"|"game", who, n, t}

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

--  : "dance" =   (/ )  "game" =     nil =  
function Dances.detect(track, char)
    local a = track.Animation
    local num = a and tostring(a.AnimationId or ""):match("%d+")
    if num then
        if DANCE_IDS[num] then return "dance" end
        if Dances.isEmoteAsset(num) then return "dance" end
    end
    if a and a.Parent and a:FindFirstAncestorOfClass("Tool") then return nil end
    local own = a and a.Parent and char and a:IsDescendantOf(char)
    local names = {lower(track.Name or ""), a and lower(a.Name or "") or "", (a and a.Parent) and lower(a.Parent.Name) or ""}
    if own or not a then
        for _, n in ipairs(names) do
            if n:find("dance") or n:find("emote") then return "dance" end
        end
    end
    if own then return nil end
    if ACTION_PRI[track.Priority] then return "game" end
    return nil
end

function Dances.blocked(k, kind)
    if State.animAllow[k] then return false end
    if State.animBlock[k] then return true end
    if kind == "dance" then return true end
    return kind == "game" and State.broadDances
end

function Dances.record(track, kind, p)
    local k = Dances.keyOf(track)
    local a = track.Animation
    local e = Dances.log[k]
    if not e then
        local count, oldestK, oldestT = 0, nil, math.huge
        for kk, ee in pairs(Dances.log) do
            count = count + 1
            if ee.t < oldestT then oldestK, oldestT = kk, ee.t end
        end
        if count >= 40 and oldestK then Dances.log[oldestK] = nil end
        e = {key = k, name = (a and a.Name ~= "" and a.Name) or track.Name or "?", n = 0, t = 0}
        Dances.log[k] = e
    end
    if not seenTracks[track] then
        seenTracks[track] = true
        e.n = e.n + 1
    end
    if kind == "dance" or not e.kind then e.kind = kind end
    e.who = (p.DisplayName ~= "" and p.DisplayName) or p.Name
    e.t = os.clock()
end

function Dances.shouldStop(p) return p ~= LP and not isWhite(p) end
function Dances.stop(t)
    pcall(function() t:AdjustWeight(0, 0) end)
    pcall(function() t:AdjustSpeed(0) end)
    pcall(function() t:Stop(0) end)
end
function Dances.handle(track, char, p)
    local kind = Dances.detect(track, char)
    local k = Dances.keyOf(track)
    if kind then Dances.record(track, kind, p) end
    if (kind or State.animBlock[k]) and Dances.blocked(k, kind)
        and State.dances and Dances.shouldStop(p) then
        Dances.stop(track)
    end
end
function Dances.scan(c, p)
    local h = c:FindFirstChildOfClass("Humanoid")
    local a = h and h:FindFirstChildOfClass("Animator")
    if not a then return end
    for _, t in ipairs(a:GetPlayingAnimationTracks()) do Dances.handle(t, c, p) end
end
function Dances.hookChar(c, p, j)
    task.spawn(function()
        local h = c:WaitForChild("Humanoid", 5)
        if not h then return end
        local a = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 5)
        if not a then return end
        j:Add(a.AnimationPlayed:Connect(function(t)
            if State.running then Dances.handle(t, c, p) end
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
    UI.refresh()
end

---------------------------------------------------------------- Saves ( )
local Saves = {file = "BeHalal_Saves.json", list = {}}

local function autoFriends()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local ok, fr = pcall(function() return LP:IsFriendsWith(p.UserId) end)
            if ok and fr and not State.B[lower(p.Name)] then State.W[lower(p.Name)] = true end
        end
    end
end

function Saves.init()
    local d = readJSON(Saves.file)
    Saves.list = (d and type(d.saves) == "table") and d.saves or {}
    Saves.placeName = "ID " .. tostring(game.PlaceId)
    task.spawn(function()
        local ok, info = pcall(function() return Marketplace:GetProductInfo(game.PlaceId) end)
        if ok and info and info.Name then Saves.placeName = info.Name end
    end)
end
function Saves.write() writeJSON(Saves.file, {saves = Saves.list}) end

local function keysOf(set, skipMe)
    local out, me = {}, lower(LP.Name)
    for k in pairs(set) do if not (skipMe and k == me) then table.insert(out, k) end end
    return out
end
function Saves.snapshot()
    return {
        muteMusic = State.muteMusic, noob = State.noob, dances = State.dances, broadDances = State.broadDances,
        W = keysOf(State.W, true), B = keysOf(State.B, true),
        animAllow = keysOf(State.animAllow), animBlock = keysOf(State.animBlock),
        audio = Audio.snapshot(),
    }
end
function Saves.add(name)
    name = trim(name)
    if name == "" then name = ((State.lang == "ar") and "\u{62D}\u{641}\u{638} " or "Save ") .. (#Saves.list + 1) end
    local n = utf8.len(name)
    if n and n > 28 then name = name:sub(1, utf8.offset(name, 29) - 1) end
    local place = tostring(game.PlaceId)
    local entry = {name = name, t = os.time(), place = place, placeName = Saves.placeName, data = Saves.snapshot()}
    for i, e in ipairs(Saves.list) do
        if e.name == name and e.place == place then table.remove(Saves.list, i) break end
    end
    table.insert(Saves.list, 1, entry)
    while #Saves.list > 50 do table.remove(Saves.list) end
    Saves.write()
end
function Saves.apply(entry)
    local d = entry.data or {}
    for _, k in ipairs({"muteMusic", "noob", "dances", "broadDances"}) do
        if type(d[k]) == "boolean" then State[k] = d[k] end
    end
    State.W, State.B, State.animAllow, State.animBlock = {}, {}, {}, {}
    if type(d.W) == "table" then for _, n in ipairs(d.W) do State.W[lower(n)] = true end end
    if type(d.B) == "table" then for _, n in ipairs(d.B) do State.B[lower(n)] = true end end
    if type(d.animAllow) == "table" then for _, k in ipairs(d.animAllow) do State.animAllow[tostring(k)] = true end end
    if type(d.animBlock) == "table" then for _, k in ipairs(d.animBlock) do State.animBlock[tostring(k)] = true end end
    Audio.setGlobalMute(State.muteMusic)
    Audio.restore(d.audio)
    Targets.refreshAll()
    task.spawn(function() autoFriends() Targets.refreshAll() UI.refresh() end)
end
function Saves.resetAll()
    State.muteMusic, State.noob, State.dances, State.broadDances = false, false, true, false
    State.W, State.B, State.animAllow, State.animBlock = {}, {}, {}, {}
    Audio.setGlobalMute(false)
    Audio.restore({})
    Audio.log, Dances.log = {}, {}
    Saves.list = {}
    Saves.write()
    Targets.refreshAll()
    task.spawn(function() autoFriends() Targets.refreshAll() UI.refresh() end)
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
-- :    
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
--     (//)    
function UILib.halo(target, radius, J)
    local f = N("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Active = false}, target.Parent)
    UILib.corner(f, radius)
    local st = N("UIStroke", {Color = Theme.Accent, Thickness = 8, Transparency = 0.85}, f)
    local function sync()
        f.Size, f.Position, f.Visible = target.Size, target.Position, target.Visible
    end
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
    UILib.glow(UILib.stroke(card, Theme.Accent, 1.5, 0.3), Root)

    local logo = N("Frame", {Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0.5, -40, 0, 22), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0}, card)
    UILib.corner(logo, 40) UILib.stroke(logo, Theme.Accent, 2, 0.2)
    Label(logo, {Size = UDim2.new(1, 0, 1, 0), Text = "\u{1F54C}", TextSize = 42, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center})
    Label(card, {Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 112), Text = "\u{628}\u{64A} \u{62D}\u{644}\u{627}\u{644} \u{B7} Be Halal", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Theme.Accent2, TextXAlignment = Enum.TextXAlignment.Center})
    Label(card, {Size = UDim2.new(1, -30, 0, 18), Position = UDim2.new(0, 15, 0, 146), Text = "\u{627}\u{62E}\u{62A}\u{631} \u{627}\u{644}\u{644}\u{63A}\u{629}  \u{2022}  Select Language", TextColor3 = Theme.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center})

    local function mkb(text, flag, desc, y, lang, col)
        local bc = N("Frame", {Size = UDim2.new(1, -60, 0, 76), Position = UDim2.new(0, 30, 0, y), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, card)
        UILib.corner(bc, 16) UILib.stroke(bc, col, 1.5, 0.4)
        local fb = N("Frame", {Size = UDim2.new(0, 48, 0, 48), Position = UDim2.new(0, 14, 0.5, -24), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0}, bc)
        UILib.corner(fb, 12)
        Label(fb, {Size = UDim2.new(1, 0, 1, 0), Text = flag, TextSize = 26, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center})
        Label(bc, {Size = UDim2.new(1, -100, 0, 22), Position = UDim2.new(0, 72, 0, 16), Text = text, Font = Enum.Font.GothamBold, TextSize = 18})
        Label(bc, {Size = UDim2.new(1, -100, 0, 16), Position = UDim2.new(0, 72, 0, 40), Text = desc, TextColor3 = Theme.TextDim, TextSize = 11})
        Label(bc, {Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -36, 0, 0), Text = "\u{203A}", TextColor3 = col, Font = Enum.Font.GothamBold, TextSize = 30, TextXAlignment = Enum.TextXAlignment.Center})
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
    mkb("\u{627}\u{644}\u{639}\u{631}\u{628}\u{64A}\u{629}", "\u{1F1F8}\u{1F1E6}", "\u{648}\u{627}\u{62C}\u{647}\u{629} \u{639}\u{631}\u{628}\u{64A}\u{629} \u{643}\u{627}\u{645}\u{644}\u{629}", 185, "ar", Theme.Accent)
    mkb("English", "\u{1F1EC}\u{1F1E7}", "Full English interface", 270, "en", Theme.Accent2)
    TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2)}):Play()
end

---------------------------------------------------------------- Shared sound helpers
local CAT_ICON = {music = "\u{1F3B5}", ambient = "\u{1F33F}", sfx = "\u{1F4A5}", ui = "\u{1F5B1}", other = "\u{1F4E6}"}
local function sortByName(arr, nameOf, keyOf)
    table.sort(arr, function(a, b)
        local na, nb = lower(nameOf(a)), lower(nameOf(b))
        if na ~= nb then return na < nb end
        return keyOf(a) < keyOf(b)
    end)
end

---------------------------------------------------------------- Sound log
local function buildSoundLog(J, vp)
    local SG = J:Add(N("ScreenGui", {Name = "BH_SoundLog", ResetOnSpawn = false, DisplayOrder = 62, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local pw, ph = math.min(340, vp.X - 20), math.min(500, vp.Y - 40)
    local panel = N("Frame", {Size = UDim2.new(0, pw, 0, ph), Position = UDim2.new(0.5, -pw / 2 + 12, 0.5, -ph / 2 + 12), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, Visible = false}, SG)
    UILib.corner(panel, 18) UILib.gradient(panel, Theme.BG1, Theme.BG3, 135) UILib.glow(UILib.stroke(panel, Theme.Accent2, 1.5, 0.4), J)
    local top = N("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1}, panel)
    makeDraggable(top, panel, J)
    Label(top, {Size = UDim2.new(1, -80, 0, 28), Position = UDim2.new(0, 14, 0, 8), Text = tr("soundLogTitle"), TextColor3 = Theme.Accent2, Font = Enum.Font.GothamBold, TextSize = 15})
    local closeB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 8), BackgroundColor3 = Theme.Card, Text = "\u{2715}", TextColor3 = Theme.Danger, TextSize = 14}, 13)
    UILib.stroke(closeB, Theme.Danger, 1.5, 0.5)
    J:Add(closeB.Activated:Connect(function() panel.Visible = false end))
    local refreshB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -68, 0, 8), BackgroundColor3 = Theme.Card, Text = "\u{1F504}", TextColor3 = Theme.Accent2, TextSize = 13}, 13)
    UILib.stroke(refreshB, Theme.Accent2, 1.5, 0.5)

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
            pathL.Text = (cat and (CAT_ICON[cat] .. " ") or "") .. (e.path or "") .. "  \u{B7}  \u{23F1} " .. Audio.fmtTime(e.len) .. (e.looped and " \u{1F501}" or "") .. ((g and g.count > 1) and ("  \u{B7}  \u{D7}" .. g.count) or "")
            local state = exempt and tr("stExempt") or (State.muteMusic and tr("stByButton") or tr("stWillMute"))
            local play = (not live) and tr("stGone") or (g.playing and tr("stPlaying") or tr("stIdle"))
            statL.Text = state .. "  \u{B7}  " .. play
            if Audio.solo == k then
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("stopShort"), Theme.Gold, DARK
            elseif live then
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("listenShort"), Theme.Info, WHITE
            else
                listenB.Text, listenB.BackgroundColor3, listenB.TextColor3 = tr("listenShort"), Theme.BG3, Theme.TextDim
            end
            if exempt then
                exemptB.Text, exemptB.BackgroundColor3, exemptB.TextColor3 = "\u{1F50A} " .. tr("exemptOn"), Theme.Success, DARK
            else
                exemptB.Text, exemptB.BackgroundColor3, exemptB.TextColor3 = "\u{1F507} " .. tr("exemptOff"), Theme.Danger, WHITE
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
    J:Add(refreshB.Activated:Connect(function()
        Audio._gc = nil
        for k, r in pairs(rows) do r.frame:Destroy() rows[k] = nil end
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

---------------------------------------------------------------- Dance log
local function buildAnimLog(J, vp)
    local AG = J:Add(N("ScreenGui", {Name = "BH_AnimLog", ResetOnSpawn = false, DisplayOrder = 61, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local pw, ph = math.min(330, vp.X - 20), math.min(480, vp.Y - 40)
    local panel = N("Frame", {Size = UDim2.new(0, pw, 0, ph), Position = UDim2.new(0.5, -pw / 2, 0.5, -ph / 2), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, Visible = false}, AG)
    UILib.corner(panel, 18) UILib.gradient(panel, Theme.BG1, Theme.BG3, 135)
    UILib.glow(UILib.stroke(panel, Theme.Gold, 1.5, 0.4), J, 1.5, Theme.Gold, Theme.Accent2)
    local top = N("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1}, panel)
    makeDraggable(top, panel, J)
    Label(top, {Size = UDim2.new(1, -80, 0, 32), Position = UDim2.new(0, 14, 0, 8), Text = tr("animTitle"), TextColor3 = Theme.Gold, Font = Enum.Font.GothamBold, TextSize = 15})
    local closeB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 10), BackgroundColor3 = Theme.Card, Text = "\u{2715}", TextColor3 = Theme.Danger, TextSize = 14}, 13)
    UILib.stroke(closeB, Theme.Danger, 1.5, 0.5)
    J:Add(closeB.Activated:Connect(function() panel.Visible = false end))
    local refreshB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -68, 0, 10), BackgroundColor3 = Theme.Card, Text = "\u{1F504}", TextColor3 = Theme.Accent2, TextSize = 13}, 13)
    UILib.stroke(refreshB, Theme.Accent2, 1.5, 0.5)
    Label(panel, {Size = UDim2.new(1, -28, 0, 30), Position = UDim2.new(0, 14, 0, 44), Text = tr("animHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})

    local tabsF = N("Frame", {Size = UDim2.new(1, -28, 0, 28), Position = UDim2.new(0, 14, 0, 78), BackgroundTransparency = 1}, panel)
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, tabsF)
    local tabBtns, tab = {}, "all"

    local list = N("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -120), Position = UDim2.new(0, 10, 0, 112), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Gold, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)
    UILib.corner(list, 12) UILib.padding(list, 6)
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    local empty = Label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyAnim"), TextColor3 = Theme.TextDim, LayoutOrder = 9999, TextXAlignment = Enum.TextXAlignment.Center})

    local rows = {}
    local refresh
    local function makeRow(k)
        local row = N("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, list)
        UILib.corner(row, 10)
        local nameL = Label(row, {Size = UDim2.new(1, -112, 0, 18), Position = UDim2.new(0, 10, 0, 8), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd})
        local subL = Label(row, {Size = UDim2.new(1, -112, 0, 26), Position = UDim2.new(0, 10, 0, 28), TextColor3 = Theme.TextDim, TextSize = 10, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})
        local btn = Btn(row, {Size = UDim2.new(0, 92, 0, 30), Position = UDim2.new(1, -100, 0.5, -15), TextSize = 10}, 8)
        J:Add(btn.Activated:Connect(function()
            local e = Dances.log[k]
            if Dances.blocked(k, e and e.kind) then
                State.animBlock[k] = nil
                State.animAllow[k] = true
            else
                State.animAllow[k] = nil
                State.animBlock[k] = true
            end
            refresh()
        end))
        local r = {frame = row}
        function r.update(e)
            local kind = e and e.kind
            local blocked = Dances.blocked(k, kind)
            nameL.Text = e and e.name or k
            local tag = (kind == "dance" and tr("tagPlayer")) or (kind == "game" and tr("tagGame")) or tr("tagSaved")
            local id = (k:sub(1, 2) == "n:") and "\u{2014}" or ("ID " .. k)
            subL.Text = tag .. "  \u{B7}  " .. id .. ((e and e.who) and ("  \u{B7}  " .. e.who) or "") .. (e and ("  \u{B7}  x" .. e.n) or "")
            btn.Text = blocked and ("\u{1F6AB} " .. tr("blockedTag")) or ("\u{2713} " .. tr("allowedTag"))
            btn.BackgroundColor3 = blocked and Theme.Danger or Theme.Success
            btn.TextColor3 = blocked and WHITE or DARK
        end
        return r
    end
    refresh = function()
        local keys = {}
        for k in pairs(Dances.log) do keys[k] = true end
        for k in pairs(State.animAllow) do keys[k] = true end
        for k in pairs(State.animBlock) do keys[k] = true end
        local arr = {}
        for k in pairs(keys) do
            local e = Dances.log[k]
            local kind = e and e.kind
            if tab == "all" or (tab == "players" and kind == "dance") or (tab == "game" and kind == "game") then
                table.insert(arr, k)
            end
        end
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
        for t, b in pairs(tabBtns) do
            local on = (tab == t)
            b.BackgroundColor3 = on and Theme.Gold or Theme.BG3
            b.TextColor3 = on and DARK or Theme.Text
        end
    end
    J:Add(refreshB.Activated:Connect(function()
        for k, r in pairs(rows) do r.frame:Destroy() rows[k] = nil end
        refresh()
    end))
    for i, t in ipairs({{"all", "animAll"}, {"players", "animPlayers"}, {"game", "animGame"}}) do
        local b = Btn(tabsF, {Size = UDim2.new(1 / 3, -4, 1, 0), BackgroundColor3 = Theme.BG3, TextColor3 = Theme.Text, TextSize = 10, Text = tr(t[2]), LayoutOrder = i}, 8)
        tabBtns[t[1]] = b
        J:Add(b.Activated:Connect(function() tab = t[1] refresh() end))
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

---------------------------------------------------------------- Saves panel
local function buildSaves(J, vp, onChanged)
    local SG = J:Add(N("ScreenGui", {Name = "BH_Saves", ResetOnSpawn = false, DisplayOrder = 63, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local pw, ph = math.min(330, vp.X - 20), math.min(480, vp.Y - 40)
    local panel = N("Frame", {Size = UDim2.new(0, pw, 0, ph), Position = UDim2.new(0.5, -pw / 2 - 10, 0.5, -ph / 2 - 10), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, Visible = false}, SG)
    UILib.corner(panel, 18) UILib.gradient(panel, Theme.BG1, Theme.BG3, 135)
    UILib.glow(UILib.stroke(panel, Theme.Accent, 1.5, 0.4), J)
    local top = N("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1}, panel)
    makeDraggable(top, panel, J)
    Label(top, {Size = UDim2.new(1, -80, 0, 32), Position = UDim2.new(0, 14, 0, 8), Text = "\u{1F4BE}  " .. tr("savesTitle"), TextColor3 = Theme.Accent2, Font = Enum.Font.GothamBold, TextSize = 15})
    local closeB = Btn(top, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 10), BackgroundColor3 = Theme.Card, Text = "\u{2715}", TextColor3 = Theme.Danger, TextSize = 14}, 13)
    UILib.stroke(closeB, Theme.Danger, 1.5, 0.5)
    J:Add(closeB.Activated:Connect(function() panel.Visible = false end))

    local nameF = N("Frame", {Size = UDim2.new(1, -112, 0, 32), Position = UDim2.new(0, 14, 0, 46), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0}, panel)
    UILib.corner(nameF, 8)
    local nameBox = N("TextBox", {
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = tr("saveNamePh"),
        TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    }, nameF)
    local saveB = Btn(panel, {Size = UDim2.new(0, 84, 0, 32), Position = UDim2.new(1, -98, 0, 46), BackgroundColor3 = Theme.Accent, TextColor3 = DARK, Text = "\u{1F4BE} " .. tr("saveNow"), TextSize = 11}, 8)
    Label(panel, {Size = UDim2.new(1, -28, 0, 30), Position = UDim2.new(0, 14, 0, 84), Text = tr("saveHint"), TextColor3 = Theme.TextDim, TextSize = 10, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})
    local status = Label(panel, {Size = UDim2.new(1, -28, 0, 16), Position = UDim2.new(0, 14, 0, 112), Text = "", TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11})

    local list = N("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -204), Position = UDim2.new(0, 10, 0, 132), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)
    UILib.corner(list, 12) UILib.padding(list, 6)
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)

    local resetB = Btn(panel, {Size = UDim2.new(1, -28, 0, 38), Position = UDim2.new(0, 14, 1, -52), BackgroundColor3 = Theme.Danger, Text = tr("resetAll"), TextSize = 12}, 10)

    local function flash(text)
        status.Text = text
        task.delay(1.8, function() if status.Parent and status.Text == text then status.Text = "" end end)
    end

    local refresh
    refresh = function()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end
        if #Saves.list == 0 then
            Label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptySaves"), TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Center})
            return
        end
        for i, e in ipairs(Saves.list) do
            local row = N("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, LayoutOrder = i}, list)
            UILib.corner(row, 10)
            local thisMap = tostring(e.place) == tostring(game.PlaceId)
            UILib.stroke(row, thisMap and Theme.Accent or Theme.TextDim, 1, 0.7)
            Label(row, {Size = UDim2.new(1, -128, 0, 18), Position = UDim2.new(0, 10, 0, 8), Text = tostring(e.name), Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd})
            local sub = (thisMap and ("\u{1F4CD} " .. tr("thisMap")) or ("\u{1F5FA} " .. tostring(e.placeName or e.place)))
            local okd, ds = pcall(function() return os.date("%d/%m %H:%M", e.t) end)
            if okd then sub = sub .. "  \u{B7}  " .. ds end
            Label(row, {Size = UDim2.new(1, -128, 0, 26), Position = UDim2.new(0, 10, 0, 28), Text = sub, TextColor3 = Theme.TextDim, TextSize = 10, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top})
            local loadB = Btn(row, {Size = UDim2.new(0, 70, 0, 30), Position = UDim2.new(1, -118, 0.5, -15), BackgroundColor3 = Theme.Accent, TextColor3 = DARK, Text = "\u{1F4C2} " .. tr("loadShort"), TextSize = 10}, 8)
            local delB = Btn(row, {Size = UDim2.new(0, 36, 0, 30), Position = UDim2.new(1, -42, 0.5, -15), BackgroundColor3 = Theme.Danger, Text = "\u{1F5D1}", TextSize = 13}, 8)
            J:Add(loadB.Activated:Connect(function()
                Saves.apply(e)
                onChanged()
            end))
            J:Add(delB.Activated:Connect(function()
                for idx, x in ipairs(Saves.list) do
                    if x == e then table.remove(Saves.list, idx) break end
                end
                Saves.write()
                refresh()
            end))
        end
    end

    J:Add(saveB.Activated:Connect(function()
        Saves.add(nameBox.Text)
        nameBox.Text = ""
        flash(tr("saved"))
        refresh()
    end))
    local armed = false
    J:Add(resetB.Activated:Connect(function()
        if not armed then
            armed = true
            resetB.Text = tr("resetConfirm")
            resetB.BackgroundColor3 = Theme.Gold
            resetB.TextColor3 = DARK
            task.delay(3, function()
                if armed and resetB.Parent then
                    armed = false
                    resetB.Text = tr("resetAll")
                    resetB.BackgroundColor3 = Theme.Danger
                    resetB.TextColor3 = WHITE
                end
            end)
            return
        end
        armed = false
        Saves.resetAll()
        onChanged()
    end))
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
    UILib.corner(M, 18) UILib.gradient(M, Theme.BG1, Theme.BG3, 135)
    UILib.glow(UILib.stroke(M, Theme.Accent, 1.5, 0.35), J)
    UILib.halo(M, 18, J)

    local header = N("Frame", {Size = UDim2.new(1, 0, 0, 72), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0, ZIndex = 3}, M)
    UILib.corner(header, 18) UILib.gradient(header, Color3.fromRGB(22, 32, 42), Color3.fromRGB(30, 46, 54), 90)
    local drag = makeDraggable(header, M, J, function() UI.pos = M.Position end)

    local logo = N("Frame", {Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0, 14, 0, 13), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, ZIndex = 4}, header)
    UILib.corner(logo, 14) UILib.stroke(logo, Theme.Accent, 1.5, 0.2)
    Label(logo, {Size = UDim2.new(1, 0, 1, 0), Text = "\u{1F54C}", TextSize = 26, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5})
    Label(header, {Size = UDim2.new(1, -120, 0, 24), Position = UDim2.new(0, 68, 0, 14), Text = tr("title"), Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Accent2, ZIndex = 4})
    Label(header, {Size = UDim2.new(1, -120, 0, 14), Position = UDim2.new(0, 68, 0, 40), Text = tr("subtitle"), TextColor3 = Theme.TextDim, TextSize = 11, ZIndex = 4})

    local minBtn = Btn(header, {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -74, 0, 22), BackgroundColor3 = Theme.Card, Text = "\u{2212}", TextColor3 = Theme.Accent, TextSize = 20, ZIndex = 4}, 14)
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
        end))
    end

    local function actionCard(text, order)
        local b = Btn(scroll, {Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Theme.Card, Text = text, TextColor3 = Theme.Text, TextSize = 13, LayoutOrder = order, ZIndex = 4}, 14)
        UILib.stroke(b, Theme.Accent, 1.2, 0.6)
        UILib.hover(b, Theme.Card, Theme.CardHi, J)
        return b
    end

    -- Audio
    section(tr("sectionAudio"), "\u{266A}", 1)
    toggle(tr("muteMusic"), "\u{1F3B5}", 2, function() return State.muteMusic end, function(s)
        State.muteMusic = s
        Audio.setGlobalMute(s)
    end)
    local logBtn = actionCard(tr("soundLog"), 3)

    -- Visual
    section(tr("sectionVisual"), "\u{25C8}", 10)
    toggle(tr("noobSkin"), "\u{1F455}", 11, function() return State.noob end, function(s)
        State.noob = s
        Targets.refreshAll()
    end)

    -- Tools
    section(tr("sectionTools"), "\u{25C6}", 20)
    toggle(tr("stopDance"), "\u{1F483}", 21, function() return State.dances end, function(s) State.dances = s end)
    toggle(tr("broadDance"), "\u{1F3AF}", 22, function() return State.broadDances end, function(s) State.broadDances = s end)
    local suggestBtn = actionCard("\u{1F3AF}  " .. tr("suggest"), 23)
    local animBtn = actionCard(tr("animLog"), 24)

    -- Players
    section(tr("sectionPlayers"), "\u{25C6}", 30)
    local searchBox = N("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Card, BorderSizePixel = 0, LayoutOrder = 31, ZIndex = 4}, scroll)
    UILib.corner(searchBox, 12)
    Label(searchBox, {Size = UDim2.new(0, 32, 1, 0), Position = UDim2.new(0, 6, 0, 0), Text = "\u{1F50D}", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5})
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
    section(tr("sectionLists"), "\u{25C6}", 40)
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
    local wlL = listBox(41, 130, "\u{2713}  " .. tr("whitelist"), Theme.Accent, Theme.Accent, Theme.Accent, function(n) listSet(n, "white") end)
    local blL = listBox(42, 160, tr("blocked"), Theme.Danger, Theme.Danger, Theme.Danger, function(n) listSet(n, "black") end)

    Label(scroll, {Size = UDim2.new(1, 0, 0, 18), Text = tr("footer") .. "  \u{B7}  v" .. VERSION .. "  \u{B7}  " .. CREATOR_NAME, TextColor3 = Theme.TextDim, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 100, ZIndex = 4})

    local saveBtn = Btn(scroll, {Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Theme.Accent, Text = tr("saveBtn"), TextColor3 = DARK, TextSize = 14, LayoutOrder = 110, ZIndex = 4}, 14)
    UILib.gradient(saveBtn, Theme.Accent, Theme.Accent2, 0)

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
        if lower(info.Name) == lower(CREATOR_NAME) then dn = "\u{1F451} " .. dn end
        Label(row, {Size = UDim2.new(1, -46 - 34 * #actions - 8, 0, 14), Position = UDim2.new(0, 46, 0, 6), Text = dn, Font = Enum.Font.GothamBold, ZIndex = 7, TextTruncate = Enum.TextTruncate.AtEnd})
        Label(row, {Size = UDim2.new(1, -46 - 34 * #actions - 8, 0, 12), Position = UDim2.new(0, 46, 0, 20), Text = "@" .. info.Name, TextColor3 = Theme.TextDim, TextSize = 10, ZIndex = 7, TextTruncate = Enum.TextTruncate.AtEnd})
        for i, a in ipairs(actions) do
            local ab = Btn(row, {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -38 - 34 * (i - 1), 0.5, -15), BackgroundColor3 = a.color, Text = "", ZIndex = 7}, 15)
            UILib.stroke(ab, WHITE, 1.5, 0.5)
            if a.kind == "x" then
                UILib.drawX(ab, WHITE, 12, 2)
            else
                Label(ab, {Size = UDim2.new(1, 0, 1, 0), Text = a.kind == "check" and "\u{2713}" or "\u{21A9}", TextColor3 = DARK, Font = Enum.Font.GothamBlack, TextSize = a.kind == "check" and 18 or 16, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 8})
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
            suggestBtn.Text = "\u{1F3AF}  " .. tr("suggest")
            if suggestPanel then suggestPanel:Destroy() suggestPanel = nil end
            currentTarget = nil
            return
        end
        suggestBtn.BackgroundColor3 = Theme.OnBG
        suggestBtn.Text = "\u{1F3AF}  " .. tr("suggest") .. "  \u{25CF}"
        local sw = math.min(200, vp.X - 20)
        suggestPanel = N("Frame", {Size = UDim2.new(0, sw, 0, 180), Position = UDim2.new(1, -sw - 20, 0.3, 0), BackgroundColor3 = Theme.BG2, BorderSizePixel = 0, Active = true, ZIndex = 20}, G)
        UILib.corner(suggestPanel, 16) UILib.gradient(suggestPanel, Theme.BG1, Theme.BG3, 135) UILib.stroke(suggestPanel, Theme.Accent, 1.5, 0.3)
        local spH = N("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.BG1, BorderSizePixel = 0, ZIndex = 21}, suggestPanel)
        UILib.corner(spH, 16)
        Label(spH, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = "\u{1F3AF}  " .. tr("suggest"), TextColor3 = Theme.Accent2, Font = Enum.Font.GothamBold, ZIndex = 22})
        makeDraggable(spH, suggestPanel, J)
        local av = N("ImageLabel", {Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 12, 0, 44), BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop, ZIndex = 22}, suggestPanel)
        UILib.corner(av, 28) UILib.stroke(av, Theme.Accent, 1.5, 0.3)
        local lbl = Label(suggestPanel, {Size = UDim2.new(1, -84, 0, 56), Position = UDim2.new(0, 76, 0, 44), Text = tr("none"), Font = Enum.Font.GothamBold, TextSize = 13, TextWrapped = true, ZIndex = 22})
        local sW = Btn(suggestPanel, {Size = UDim2.new(0.5, -18, 0, 34), Position = UDim2.new(0, 12, 1, -46), BackgroundColor3 = Theme.Accent, TextColor3 = DARK, Text = "\u{2713} " .. tr("wl"), TextSize = 12, ZIndex = 22}, 10)
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
    local svPanel, svRefresh = buildSaves(J, vp, function()
        task.defer(function()
            if State.running then
                UI.reopen = true
                UI.build()
            end
        end)
    end)
    J:Add(saveBtn.Activated:Connect(function()
        svPanel.Visible = not svPanel.Visible
        if svPanel.Visible then pcall(svRefresh) end
    end))

    -- Minimized icon (     )
    local mini = Btn(G, {Size = UDim2.new(0, 60, 0, 60), Position = M.Position, BackgroundColor3 = Theme.BG2, Text = "\u{1F54C}", TextSize = 28, Visible = false, ZIndex = 4}, 30)
    UILib.glow(UILib.stroke(mini, Theme.Accent, 2, 0.2), J, 2)
    UILib.halo(mini, 30, J)
    local miniDrag = makeDraggable(mini, mini, J)
    local stash = {}
    local function setMin(state)
        if state then
            mini.Position = M.Position
            local all = {slPanel, alPanel, svPanel}
            if suggestPanel then table.insert(all, suggestPanel) end
            for _, p in ipairs(all) do
                if p.Visible then stash[p] = true p.Visible = false end
            end
            M.Visible, mini.Visible = false, true
        else
            M.Position = mini.Position
            UI.pos = M.Position
            for p in pairs(stash) do
                if p.Parent then p.Visible = true end
            end
            stash = {}
            M.Visible, mini.Visible = true, false
        end
    end
    J:Add(minBtn.Activated:Connect(function() setMin(true) end))
    J:Add(mini.Activated:Connect(function() if not miniDrag.moved then setMin(false) end end))

    J:Add(closeBtn.Activated:Connect(function() ENV.__BeHalal.destroy() end))

    if UI.reopen then
        UI.reopen = false
        svPanel.Visible = true
        pcall(svRefresh)
    end

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
    pcall(Audio.shutdown)
    pcall(Targets.shutdown)
    pcall(UI.destroy)
    Root:Clean()
    if ENV.__BeHalal == Hub then ENV.__BeHalal = nil end
end
ENV.__BeHalal = Hub

---------------------------------------------------------------- Boot
Audio.init()
Saves.init()

Root:Add(Players.PlayerAdded:Connect(function(p) task.spawn(onPlayer, p) end))
Root:Add(Players.PlayerRemoving:Connect(function(p) Targets.remove(p) end))
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end

loop(0.25, function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then Dances.scan(p.Character, p) end
    end
end)
loop(1, Targets.refreshAll)

showLangScreen(function(lang)
    State.lang = lang
    task.wait(0.1)
    if State.running then UI.build() end
end)
