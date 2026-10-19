--[[
    Be Halal | v3.9
    client side    by EZ_NOOB11220

    Modules:
      Janitor  Utils  Theme  Translations  Audio  Skin  Hide
      Dances  Targets  Lists  Saves  UI kit  Pages  Main window  Lifecycle  Boot
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
local VERSION = "3.9"

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

---------------------------------------------------------------- Theme + Translations
local Theme = {
    Base       = Color3.fromRGB(14, 13, 11),
    Bar        = Color3.fromRGB(19, 17, 14),
    Surface    = Color3.fromRGB(25, 23, 19),
    Raised     = Color3.fromRGB(36, 33, 27),
    RaisedHi   = Color3.fromRGB(47, 43, 34),
    Line       = Color3.fromRGB(49, 44, 34),
    Gold       = Color3.fromRGB(212, 175, 55),
    GoldHi     = Color3.fromRGB(234, 199, 88),
    GoldDim    = Color3.fromRGB(126, 103, 36),
    OnGold     = Color3.fromRGB(22, 17, 6),
    Text       = Color3.fromRGB(237, 231, 215),
    TextDim    = Color3.fromRGB(152, 143, 122),
    TextFaint  = Color3.fromRGB(98, 91, 76),
    Danger     = Color3.fromRGB(204, 84, 72),
    DangerBg   = Color3.fromRGB(50, 27, 24),
    DangerBgHi = Color3.fromRGB(66, 33, 29),
    DangerFg   = Color3.fromRGB(238, 142, 130),
    DangerLine = Color3.fromRGB(108, 50, 44),
}

local T = {
    ar = {
        title = "\u{628}\u{64A} \u{62D}\u{644}\u{627}\u{644}", subtitle = "\u{623}\u{62F}\u{648}\u{627}\u{62A} \u{625}\u{633}\u{644}\u{627}\u{645}\u{64A}\u{629} \u{644}\u{644}\u{633}\u{64A}\u{631}\u{641}\u{631}", footer = "\u{628}\u{64A} \u{62D}\u{644}\u{627}\u{644}",
        navHome = "\u{627}\u{644}\u{631}\u{626}\u{64A}\u{633}\u{64A}\u{629}", navMusic = "\u{633}\u{62C}\u{644} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}", navDances = "\u{633}\u{62C}\u{644} \u{627}\u{644}\u{631}\u{642}\u{635}\u{627}\u{62A}", navPlayers = "\u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{648}\u{646}", navSaves = "\u{627}\u{644}\u{62D}\u{641}\u{638}",
        statPlayers = "\u{644}\u{627}\u{639}\u{628}\u{648}\u{646}", statSounds = "\u{623}\u{635}\u{648}\u{627}\u{62A} \u{645}\u{633}\u{62C}\u{651}\u{644}\u{629}", statSaves = "\u{62D}\u{641}\u{638}\u{627}\u{62A}",
        secAudio = "\u{627}\u{644}\u{635}\u{648}\u{62A}", secAppearance = "\u{627}\u{644}\u{645}\u{638}\u{647}\u{631}", secMotion = "\u{627}\u{644}\u{62D}\u{631}\u{643}\u{629}",
        muteMusic = "\u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}", muteMusicD = "\u{64A}\u{643}\u{62A}\u{645} \u{645}\u{648}\u{633}\u{64A}\u{642}\u{649} \u{627}\u{644}\u{62E}\u{644}\u{641}\u{64A}\u{629} \u{641}\u{64A} \u{627}\u{644}\u{633}\u{64A}\u{631}\u{641}\u{631}",
        noobSkin = "\u{633}\u{643}\u{646}\u{627}\u{62A} \u{646}\u{648}\u{628}", noobSkinD = "\u{64A}\u{639}\u{631}\u{636} \u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{64A}\u{646} \u{627}\u{644}\u{622}\u{62E}\u{631}\u{64A}\u{646} \u{628}\u{645}\u{638}\u{647}\u{631} \u{627}\u{644}\u{646}\u{648}\u{628}",
        stopDance = "\u{625}\u{64A}\u{642}\u{627}\u{641} \u{627}\u{644}\u{631}\u{642}\u{635}\u{627}\u{62A}", stopDanceD = "\u{64A}\u{648}\u{642}\u{641} \u{631}\u{642}\u{635}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{64A}\u{646} \u{627}\u{644}\u{622}\u{62E}\u{631}\u{64A}\u{646}\u{60C} \u{62D}\u{62A}\u{649} \u{627}\u{644}\u{625}\u{64A}\u{645}\u{648}\u{62A}\u{627}\u{62A} \u{627}\u{644}\u{62E}\u{627}\u{635}\u{629} \u{628}\u{627}\u{644}\u{644}\u{639}\u{628}\u{629}",
        broadDance = "\u{625}\u{64A}\u{642}\u{627}\u{641} \u{634}\u{627}\u{645}\u{644}", broadDanceD = "\u{64A}\u{648}\u{642}\u{641} \u{623}\u{64A} \u{62D}\u{631}\u{643}\u{629} \u{645}\u{62E}\u{635}\u{635}\u{629} \u{645}\u{646} \u{627}\u{644}\u{645}\u{627}\u{628} (\u{63A}\u{64A}\u{631} \u{627}\u{644}\u{645}\u{634}\u{64A} \u{648}\u{627}\u{644}\u{648}\u{642}\u{648}\u{641} \u{648}\u{627}\u{644}\u{642}\u{641}\u{632})",
        catMusic = "\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}", catAmbient = "\u{623}\u{62C}\u{648}\u{627}\u{621}", catSfx = "\u{645}\u{624}\u{62B}\u{631}\u{627}\u{62A}", catUi = "\u{648}\u{627}\u{62C}\u{647}\u{629}", catOther = "\u{623}\u{62E}\u{631}\u{649}",
        logOn = "\u{632}\u{631} \u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}: \u{645}\u{641}\u{639}\u{651}\u{644}", logOff = "\u{632}\u{631} \u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}: \u{645}\u{639}\u{637}\u{651}\u{644}",
        logHint = "\u{627}\u{644}\u{623}\u{635}\u{648}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{64A} \u{64A}\u{643}\u{62A}\u{645}\u{647}\u{627} \u{632}\u{631} \u{643}\u{62A}\u{645} \u{627}\u{644}\u{645}\u{648}\u{633}\u{64A}\u{642}\u{649}. \u{627}\u{633}\u{62A}\u{645}\u{639} \u{644}\u{644}\u{635}\u{648}\u{62A} \u{644}\u{62D}\u{627}\u{644}\u{647}\u{60C} \u{623}\u{648} \u{627}\u{633}\u{62A}\u{62B}\u{646}\u{650}\u{647} \u{645}\u{646} \u{627}\u{644}\u{643}\u{62A}\u{645}.",
        logSearch = "\u{627}\u{628}\u{62D}\u{62B} \u{641}\u{64A} \u{627}\u{644}\u{633}\u{62C}\u{644}", clear = "\u{645}\u{633}\u{62D}", refresh = "\u{62A}\u{62D}\u{62F}\u{64A}\u{62B}", emptyLog = "\u{645}\u{627} \u{627}\u{634}\u{62A}\u{63A}\u{644} \u{623}\u{64A} \u{635}\u{648}\u{62A} \u{628}\u{639}\u{62F}",
        listen = "\u{627}\u{633}\u{62A}\u{645}\u{639}", stop = "\u{625}\u{64A}\u{642}\u{627}\u{641}", stopListening = "\u{625}\u{64A}\u{642}\u{627}\u{641} \u{627}\u{644}\u{627}\u{633}\u{62A}\u{645}\u{627}\u{639}", loop = "\u{62A}\u{643}\u{631}\u{627}\u{631}",
        exempt = "\u{645}\u{633}\u{62A}\u{62B}\u{646}\u{649}", willMute = "\u{64A}\u{64F}\u{643}\u{62A}\u{645}",
        stExempt = "\u{645}\u{633}\u{62A}\u{62B}\u{646}\u{649} \u{645}\u{646} \u{627}\u{644}\u{643}\u{62A}\u{645}", stByButton = "\u{645}\u{643}\u{62A}\u{648}\u{645} \u{628}\u{627}\u{644}\u{632}\u{631}", stWillMute = "\u{64A}\u{64F}\u{643}\u{62A}\u{645} \u{644}\u{645}\u{627} \u{62A}\u{641}\u{639}\u{651}\u{644} \u{627}\u{644}\u{632}\u{631}",
        stPlaying = "\u{634}\u{63A}\u{651}\u{627}\u{644}", stIdle = "\u{645}\u{62A}\u{648}\u{642}\u{641}", stGone = "\u{627}\u{62E}\u{62A}\u{641}\u{649} \u{645}\u{646} \u{627}\u{644}\u{645}\u{627}\u{628}",
        animHint = "\u{631}\u{642}\u{635}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{64A}\u{646} \u{648}\u{62D}\u{631}\u{643}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{639}\u{628}\u{629} \u{62A}\u{638}\u{647}\u{631} \u{647}\u{646}\u{627}. \u{627}\u{636}\u{63A}\u{637} \u{639}\u{644}\u{649} \u{627}\u{644}\u{632}\u{631} \u{639}\u{634}\u{627}\u{646} \u{62A}\u{62D}\u{62C}\u{628} \u{623}\u{648} \u{62A}\u{633}\u{645}\u{62D}.",
        animAll = "\u{627}\u{644}\u{643}\u{644}", animPlayers = "\u{631}\u{642}\u{635}\u{627}\u{62A} \u{627}\u{644}\u{644}\u{627}\u{639}\u{628}\u{64A}\u{646}", animGame = "\u{645}\u{646} \u{627}\u{644}\u{644}\u{639}\u{628}\u{629}",
        tagPlayer = "\u{631}\u{642}\u{635}\u{629} \u{644}\u{627}\u{639}\u{628}", tagGame = "\u{645}\u{646} \u{627}\u{644}\u{644}\u{639}\u{628}\u{629}", tagOther = "\u{62D}\u{631}\u{643}\u{629} \u{623}\u{62E}\u{631}\u{649}", tagSaved = "\u{645}\u{62D}\u{641}\u{648}\u{638}\u{629}",
        animAllowed = "\u{645}\u{633}\u{645}\u{648}\u{62D}\u{629}", animBlocked = "\u{645}\u{62D}\u{62C}\u{648}\u{628}\u{629}", emptyAnim = "\u{645}\u{627} \u{627}\u{646}\u{631}\u{635}\u{62F}\u{62A} \u{623}\u{64A} \u{62D}\u{631}\u{643}\u{629} \u{628}\u{639}\u{62F}",
        segOnline = "\u{627}\u{644}\u{645}\u{62A}\u{635}\u{644}\u{648}\u{646}", segAllowed = "\u{627}\u{644}\u{645}\u{633}\u{645}\u{648}\u{62D}\u{648}\u{646}", segBlocked = "\u{627}\u{644}\u{645}\u{62D}\u{62C}\u{648}\u{628}\u{648}\u{646}",
        searchPlayer = "\u{627}\u{628}\u{62D}\u{62B} \u{639}\u{646} \u{644}\u{627}\u{639}\u{628}", addPlayer = "\u{627}\u{633}\u{645} \u{627}\u{644}\u{644}\u{627}\u{639}\u{628}", add = "\u{625}\u{636}\u{627}\u{641}\u{629}",
        allow = "\u{633}\u{645}\u{627}\u{62D}", block = "\u{62D}\u{62C}\u{628}", remove = "\u{625}\u{632}\u{627}\u{644}\u{629}", restore = "\u{627}\u{633}\u{62A}\u{639}\u{627}\u{62F}\u{629}",
        noPlayers = "\u{644}\u{627} \u{64A}\u{648}\u{62C}\u{62F} \u{644}\u{627}\u{639}\u{628}\u{648}\u{646}", empty = "\u{627}\u{644}\u{642}\u{627}\u{626}\u{645}\u{629} \u{641}\u{627}\u{631}\u{63A}\u{629}", inView = "\u{641}\u{64A} \u{645}\u{631}\u{645}\u{649} \u{646}\u{638}\u{631}\u{643}", noneInView = "\u{644}\u{627} \u{623}\u{62D}\u{62F} \u{623}\u{645}\u{627}\u{645}\u{643}", creator = "\u{627}\u{644}\u{645}\u{637}\u{648}\u{651}\u{631}",
        saveNamePh = "\u{627}\u{633}\u{645} \u{627}\u{644}\u{62D}\u{641}\u{638}", saveNow = "\u{62D}\u{641}\u{638}", loadShort = "\u{62A}\u{62D}\u{645}\u{64A}\u{644}", delete = "\u{62D}\u{630}\u{641}",
        saveHint = "\u{64A}\u{62D}\u{641}\u{638} \u{643}\u{644} \u{625}\u{639}\u{62F}\u{627}\u{62F}\u{627}\u{62A}\u{643} \u{627}\u{644}\u{62D}\u{627}\u{644}\u{64A}\u{629} (\u{627}\u{644}\u{623}\u{632}\u{631}\u{627}\u{631} \u{648}\u{627}\u{644}\u{642}\u{648}\u{627}\u{626}\u{645} \u{648}\u{627}\u{644}\u{623}\u{635}\u{648}\u{627}\u{62A}) \u{628}\u{627}\u{644}\u{627}\u{633}\u{645} \u{627}\u{644}\u{644}\u{64A} \u{62A}\u{62E}\u{62A}\u{627}\u{631}\u{647}.",
        emptySaves = "\u{645}\u{627} \u{641}\u{64A}\u{647} \u{62D}\u{641}\u{638} \u{628}\u{639}\u{62F}", saved = "\u{62A}\u{645} \u{627}\u{644}\u{62D}\u{641}\u{638}", thisMap = "\u{647}\u{630}\u{627} \u{627}\u{644}\u{645}\u{627}\u{628}",
        resetAll = "\u{645}\u{633}\u{62D} \u{643}\u{644} \u{627}\u{644}\u{628}\u{64A}\u{627}\u{646}\u{627}\u{62A}", resetConfirm = "\u{627}\u{636}\u{63A}\u{637} \u{645}\u{631}\u{629} \u{62B}\u{627}\u{646}\u{64A}\u{629} \u{644}\u{644}\u{62A}\u{623}\u{643}\u{64A}\u{62F}",
    },
    en = {
        title = "Be Halal", subtitle = "Islamic server tools", footer = "Be Halal",
        navHome = "Home", navMusic = "Sound Log", navDances = "Dance Log", navPlayers = "Players", navSaves = "Saves",
        statPlayers = "Players", statSounds = "Sounds logged", statSaves = "Saves",
        secAudio = "Audio", secAppearance = "Appearance", secMotion = "Motion",
        muteMusic = "Mute Music", muteMusicD = "Silences background music on the server",
        noobSkin = "Noob Skins", noobSkinD = "Shows other players with the noob look",
        stopDance = "Stop Dances", stopDanceD = "Stops dances of other players, including a game's own emotes",
        broadDance = "Stop Map Dances", broadDanceD = "Stops any custom map animation (except walking, idle, jumping...)",
        catMusic = "Music", catAmbient = "Ambient", catSfx = "Effects", catUi = "Interface", catOther = "Other",
        logOn = "Mute Music button: on", logOff = "Mute Music button: off",
        logHint = "Sounds caught by the Mute Music button. Listen to one alone, or exempt it from muting.",
        logSearch = "Search the log", clear = "Clear", refresh = "Refresh", emptyLog = "No sound played yet",
        listen = "Listen", stop = "Stop", stopListening = "Stop listening", loop = "Loop",
        exempt = "Exempt", willMute = "Muted",
        stExempt = "Exempt from muting", stByButton = "Muted by the button", stWillMute = "Will be muted when the button is on",
        stPlaying = "Playing", stIdle = "Idle", stGone = "Gone from the map",
        animHint = "Player dances and game animations show here. Tap the button to block or allow.",
        animAll = "All", animPlayers = "Player dances", animGame = "From game",
        tagPlayer = "Player dance", tagGame = "From game", tagOther = "Other motion", tagSaved = "Saved",
        animAllowed = "Allowed", animBlocked = "Blocked", emptyAnim = "No animation detected yet",
        segOnline = "Online", segAllowed = "Allowed", segBlocked = "Blocked",
        searchPlayer = "Search players", addPlayer = "Player name", add = "Add",
        allow = "Allow", block = "Block", remove = "Remove", restore = "Restore",
        noPlayers = "No players found", empty = "List is empty", inView = "In your view", noneInView = "No one in view", creator = "Creator",
        saveNamePh = "Save name", saveNow = "Save", loadShort = "Load", delete = "Delete",
        saveHint = "Saves all your current settings (toggles, lists and sounds) under the name you choose.",
        emptySaves = "Nothing saved yet", saved = "Saved", thisMap = "This map",
        resetAll = "Clear all data", resetConfirm = "Tap again to confirm",
    },
}
local function tr(k) return (T[State.lang] or T.en)[k] or T.en[k] or k end



---------------------------------------------------------------- Audio
local Audio

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
-- sounds that belong to a character (footsteps, voice...) are never treated as music
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

-- snapshot / restore (used by Saves)
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
    -- re-apply every 0.25s so games that keep resetting volume can't override us
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
-- Noob skin: classic colours, default face, accessories/effects hidden, R15 swapped for R6-style blocks
local Skin = {}
local backups = {}
local NC = {Skin = Color3.fromRGB(245,205,48), T = Color3.fromRGB(13,105,172), Lg = Color3.fromRGB(40,127,71)}
local PART_COLORS = {
    LeftArm=NC.Skin, RightArm=NC.Skin, Torso=NC.T, LeftLeg=NC.Lg, RightLeg=NC.Lg,
    ["Left Arm"]=NC.Skin, ["Right Arm"]=NC.Skin, ["Left Leg"]=NC.Lg, ["Right Leg"]=NC.Lg,
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
-- "Stop Dances"     -> stops dances/emotes of other players   (kind = "dance")
-- "Stop Map Dances" -> stops Action animations from the map   (kind = "game")
-- manual block/allow from the dance log always wins
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

-- true = catalog emote, false = normal/custom animation, nil = still checking
function Dances.emoteState(num)
    local c = emoteCache[num]
    if c == true or c == false then return c end
    if c == "pending" then return nil end
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
    return nil
end

function Dances.keyOf(track)
    local a = track.Animation
    local num = a and tostring(a.AnimationId or ""):match("%d+")
    if num then return num end
    return "n:" .. lower(track.Name or "?")
end

local DANCE_WORDS = {"dance", "emote", "floss", "dab", "twerk", "taunt"}
local RANK = {other = 1, game = 2, dance = 3}
local LOCO_WORDS = {"walk", "run", "idle", "jump", "fall", "climb", "swim", "sit", "land", "sprint", "crouch", "stand"}
local function locoName(str)
    str = lower(str or "")
    for _, w in ipairs(LOCO_WORDS) do
        if str:find(w, 1, true) then return true end
    end
    return false
end
local function danceName(str)
    str = lower(str or "")
    for _, w in ipairs(DANCE_WORDS) do
        if str:find(w, 1, true) then return true end
    end
    return false
end

-- Works on any map. Every animation that plays on a player's character is judged by what it is, not by which game it is:
--   "dance" = known dance / catalog emote / dance-like name / a looping Action animation (custom emotes)
--   "game"  = other Action animations (one-shots)
--   "other" = any other custom animation (logged so you can block it by hand, never blocked automatically)
function Dances.detect(track, char)
    local a = track.Animation
    local num = a and tostring(a.AnimationId or ""):match("%d+")
    if num and DANCE_IDS[num] then return "dance" end
    if a and a.Parent and a:FindFirstAncestorOfClass("Tool") then return nil end
    local inChar = a and a.Parent and char and a:IsDescendantOf(char)
    local fromAnimate = inChar and a:FindFirstAncestor("Animate") ~= nil
    if danceName(track.Name) or (a and (danceName(a.Name) or (a.Parent and danceName(a.Parent.Name)))) then
        return "dance"
    end
    if fromAnimate then return nil end          -- default walk/idle/jump of the Roblox Animate script
    if not a then
        return ACTION_PRI[track.Priority] and "game" or nil
    end
    if ACTION_PRI[track.Priority] then
        if num and Dances.emoteState(num) == true then return "dance" end
        if track.Looped then return "dance" end
        return "game"
    end
    -- any other custom animation (Idle/Movement/Core priority): ignore plain locomotion, treat the rest as map motion
    if locoName(track.Name) or locoName(a.Name) or (a.Parent and locoName(a.Parent.Name)) then return nil end
    return "other"
end

function Dances.blocked(k, kind)
    if State.animAllow[k] then return false end
    if State.animBlock[k] then return true end
    if kind == "dance" then return State.dances end
    if kind == "game" or kind == "other" then return State.broadDances end
    return false
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
    if not e.kind or (RANK[kind] or 0) > (RANK[e.kind] or 0) then e.kind = kind end
    e.who = (p.DisplayName ~= "" and p.DisplayName) or p.Name
    e.t = os.clock()
end

function Dances.shouldStop(p) return p ~= LP and not isWhite(p) end
function Dances.stop(t)
    pcall(function() t:AdjustWeight(0, 0) end)
    pcall(function() t:AdjustSpeed(0) end)
    pcall(function() t:Stop(0) end)
end
Dances.held = setmetatable({}, {__mode = "k"})   -- tracks we keep pinned down for a few seconds
function Dances.handle(track, char, p)
    local kind = Dances.detect(track, char)
    local k = Dances.keyOf(track)
    if kind then Dances.record(track, kind, p) end
    if Dances.blocked(k, kind) and Dances.shouldStop(p) then
        Dances.held[track] = {k = k, kind = kind, p = p, untilT = os.clock() + 3}
        Dances.stop(track)
    end
end
-- runs every frame: if the game restarts/keeps a blocked animation, stop it again right away
function Dances.hold()
    local now = os.clock()
    for t, info in pairs(Dances.held) do
        if now > info.untilT or not info.p.Parent or not Dances.blocked(info.k, info.kind) or not Dances.shouldStop(info.p) then
            Dances.held[t] = nil
        elseif t.IsPlaying then
            Dances.stop(t)
        end
    end
end
local function animatorOf(c)
    local h = c:FindFirstChildOfClass("Humanoid")
    local a = h and h:FindFirstChildOfClass("Animator")
    return a or c:FindFirstChildWhichIsA("Animator", true)
end
function Dances.scan(c, p)
    local a = animatorOf(c)
    if not a then return end
    for _, t in ipairs(a:GetPlayingAnimationTracks()) do Dances.handle(t, c, p) end
end
function Dances.hookChar(c, p, j)
    task.spawn(function()
        local h = c:WaitForChild("Humanoid", 5)
        if not h then return end
        local a = h:FindFirstChildOfClass("Animator") or h:WaitForChild("Animator", 5) or animatorOf(c)
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

---------------------------------------------------------------- Saves
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

--==============================================================
-- UI kit
--==============================================================
local WHITE = Color3.new(1, 1, 1)
local function viewport()
    local cam = Workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end
local function caps(text)
    if State.lang == "en" then return string.upper(text) end
    return text
end

local Kit = {}
function Kit.merge(base, extra)
    for k, v in pairs(extra or {}) do base[k] = v end
    return base
end
function Kit.frame(parent, props)
    return N("Frame", Kit.merge({BorderSizePixel = 0, BackgroundColor3 = Theme.Surface}, props), parent)
end
function Kit.label(parent, props)
    return N("TextLabel", Kit.merge({
        BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.GothamMedium, TextColor3 = Theme.Text,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, props), parent)
end
function Kit.corner(o, r) return N("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end
function Kit.stroke(o, col, th, tp)
    return N("UIStroke", {Color = col or Theme.Line, Thickness = th or 1, Transparency = tp or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
function Kit.pad(o, l, t, r, b)
    return N("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0), PaddingTop = UDim.new(0, t or l or 0),
        PaddingRight = UDim.new(0, r or l or 0), PaddingBottom = UDim.new(0, b or t or l or 0),
    }, o)
end
function Kit.scroller(parent, props)
    return N("ScrollingFrame", Kit.merge({
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.GoldDim, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, ElasticBehavior = Enum.ElasticBehavior.Never,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
    }, props), parent)
end
function Kit.section(parent, text, order)
    return Kit.label(parent, {
        Size = UDim2.new(1, 0, 0, 16), Text = caps(text), TextColor3 = Theme.GoldDim,
        Font = Enum.Font.GothamBold, TextSize = 11, LayoutOrder = order,
    })
end

local KIND = {
    primary   = {bg = Theme.Gold,     hover = Theme.GoldHi,     fg = Theme.OnGold},
    secondary = {bg = Theme.Raised,   hover = Theme.RaisedHi,   fg = Theme.Text, line = Theme.Line},
    ghost     = {bg = Theme.Surface,  hover = Theme.Raised,     fg = Theme.TextDim},
    danger    = {bg = Theme.DangerBg, hover = Theme.DangerBgHi, fg = Theme.DangerFg, line = Theme.DangerLine},
    tabOn     = {bg = Theme.Raised,   hover = Theme.RaisedHi,   fg = Theme.Gold, line = Theme.GoldDim},
    off       = {bg = Theme.Surface,  hover = Theme.Surface,    fg = Theme.TextFaint, line = Theme.Line},
}

function Kit.button(parent, props, kind, J)
    local b = N("TextButton", Kit.merge({
        BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 12, Text = "",
    }, props), parent)
    Kit.corner(b, 6)
    local st = Kit.stroke(b, Theme.Line, 1, 1)
    local o = {inst = b, kind = kind}
    function o.set(k)
        o.kind = k
        local d = KIND[k]
        b.BackgroundColor3 = d.bg
        b.TextColor3 = d.fg
        st.Color = d.line or d.bg
        st.Transparency = d.line and 0 or 1
    end
    J:Add(b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = KIND[o.kind].hover}):Play()
    end))
    J:Add(b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = KIND[o.kind].bg}):Play()
    end))
    o.set(kind)
    return o
end

function Kit.search(parent, pos, size, placeholder, J)
    local f = Kit.frame(parent, {Position = pos, Size = size})
    Kit.corner(f, 6)
    local st = Kit.stroke(f, Theme.Line)
    local box = N("TextBox", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = "",
        PlaceholderText = placeholder, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    }, f)
    J:Add(box.Focused:Connect(function() st.Color = Theme.GoldDim end))
    J:Add(box.FocusLost:Connect(function() st.Color = Theme.Line end))
    return f, box
end

function Kit.switch(parent, pos, initial, J, onChange)
    local track = N("TextButton", {
        Size = UDim2.fromOffset(38, 20), Position = pos, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        BackgroundColor3 = Theme.Raised,
    }, parent)
    Kit.corner(track, 10)
    local ts = Kit.stroke(track, Theme.Line)
    local knob = Kit.frame(track, {Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Theme.TextDim})
    Kit.corner(knob, 7)
    local sw = {on = initial}
    local function paint(animate)
        local ti = TweenInfo.new(animate and 0.16 or 0, Enum.EasingStyle.Quad)
        TweenService:Create(track, ti, {BackgroundColor3 = sw.on and Theme.Gold or Theme.Raised}):Play()
        TweenService:Create(knob, ti, {
            Position = sw.on and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = sw.on and Theme.OnGold or Theme.TextDim,
        }):Play()
        ts.Color = sw.on and Theme.Gold or Theme.Line
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
    Kit.corner(c, 8)
    Kit.stroke(c, Theme.Line)
    N("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, c)
    return {inst = c, n = 0}
end
function Kit.cardRow(card, height)
    if card.n > 0 then
        local d = Kit.frame(card.inst, {Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 1, LayoutOrder = card.n * 2 - 1})
        Kit.frame(d, {Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundColor3 = Theme.Line})
    end
    card.n = card.n + 1
    return Kit.frame(card.inst, {Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, LayoutOrder = card.n * 2})
end

function Kit.segmented(parent, pos, size, names, J, onSelect)
    local f = Kit.frame(parent, {Position = pos, Size = size})
    Kit.corner(f, 7)
    Kit.stroke(f, Theme.Line)
    Kit.pad(f, 3)
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, f)
    local seg = {frame = f, btns = {}, current = names[1]}
    local n = #names
    function seg.select(name)
        seg.current = name
        for nm, b in pairs(seg.btns) do b.set(nm == name and "tabOn" or "ghost") end
    end
    for i, nm in ipairs(names) do
        local b = Kit.button(f, {Size = UDim2.new(1 / n, -3 * (n - 1) / n, 1, 0), LayoutOrder = i, TextSize = 11}, "ghost", J)
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

-- crescent logo (drawn, no emoji)
function Kit.crescent(parent, pos, size, fg, bg)
    local w = Kit.frame(parent, {Position = pos, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1})
    local a = Kit.frame(w, {Size = UDim2.fromScale(1, 1), BackgroundColor3 = fg})
    Kit.corner(a, size)
    local d = size * 0.84
    local b = Kit.frame(w, {Size = UDim2.fromOffset(d, d), Position = UDim2.fromOffset(size * 0.3, -size * 0.06), BackgroundColor3 = bg})
    Kit.corner(b, size)
    return w
end

-- critically damped spring: smooth even when input events are sparse (touch)
local function smoothDamp(cur, goal, vel, smooth, dt)
    local omega = 2 / smooth
    local x = omega * dt
    local e = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
    local change = cur - goal
    local temp = (vel + change * omega) * dt
    local nvel = (vel - temp * omega) * e
    return goal + (change + temp) * e, nvel
end

local function makeDraggable(handle, target, j, onMove, onDrop)
    local st = {moved = false}
    local dragging, startIn, startAbs = false, nil, nil
    local goal, cur, vel = nil, nil, Vector2.zero
    local pendingDrop = false
    handle.Active = true
    j:Add(RunService.RenderStepped:Connect(function(dt)
        if not goal then return end
        cur, vel = smoothDamp(cur, goal, vel, 0.075, math.min(dt, 1 / 20))
        local settled = (not dragging) and (goal - cur).Magnitude < 0.4 and vel.Magnitude < 6
        if settled then cur, vel = goal, Vector2.zero end
        target.Position = UDim2.fromOffset(math.floor(cur.X + 0.5), math.floor(cur.Y + 0.5))
        if onMove then onMove() end
        if settled then
            goal = nil
            if pendingDrop then
                pendingDrop = false
                if onDrop then onDrop() end
            end
        end
    end))
    j:Add(handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, st.moved = true, false
            startIn, startAbs = i.Position, target.AbsolutePosition
            cur, vel, goal = startAbs, Vector2.zero, nil
            local conn
            conn = i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                    if st.moved then pendingDrop = true end
                end
            end)
        end
    end))
    j:Add(UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - startIn
        if d.Magnitude > 4 then st.moved = true end
        if not st.moved then return end
        local sz, vp = target.AbsoluteSize, viewport()
        goal = Vector2.new(
            math.clamp(startAbs.X + d.X, -sz.X + 80, vp.X - 80),
            math.clamp(startAbs.Y + d.Y, 0, vp.Y - 40)
        )
    end))
    return st
end

-- volume slider 0% - 200%
local function makeSlider(parent, pos, size, J, onChange)
    local hit = N("TextButton", {Size = size, Position = pos, BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, parent)
    local track = Kit.frame(hit, {Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0.5, -2), BackgroundColor3 = Theme.Raised})
    Kit.corner(track, 2)
    local fill = Kit.frame(track, {Size = UDim2.fromScale(0.5, 1), BackgroundColor3 = Theme.Gold})
    Kit.corner(fill, 2)
    local knob = Kit.frame(hit, {Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Theme.GoldHi})
    Kit.corner(knob, 6)
    local sl = {value = 1, max = 2, dragging = false, hit = hit}
    local conns = {}
    local function dropConns()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end
    J:Add(dropConns)
    function sl.set(v)
        sl.value = math.clamp(v, 0, sl.max)
        local a = sl.value / sl.max
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, 0.5)
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

local function pctText(f) return math.floor(f * 100 + 0.5) .. "%" end
local function killRow(r) r.j:Clean() r.frame:Destroy() end


-- animated gold border
function Kit.pulse(stroke, J, base)
    stroke.Color = WHITE
    local g = N("UIGradient", {Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Gold), ColorSequenceKeypoint.new(0.5, Theme.GoldHi), ColorSequenceKeypoint.new(1, Theme.Gold),
    })}, stroke)
    local alive = true
    J:Add(function() alive = false end)
    task.spawn(function()
        local t = math.random() * 6
        while alive and State.running do
            t = t + 0.06
            local k = (math.sin(t * 1.6) + 1) / 2
            stroke.Transparency = 0.62 - 0.38 * k
            stroke.Thickness = (base or 1) + 0.8 * k
            g.Rotation = (t * 40) % 360
            task.wait(0.06)
        end
    end)
end

--==============================================================
-- Pages
--==============================================================
local CATS = {"music", "ambient", "sfx", "ui", "other"}
local CAT_KEY = {music = "catMusic", ambient = "catAmbient", sfx = "catSfx", ui = "catUi", other = "catOther"}

local function sortByName(arr, nameOf, keyOf)
    table.sort(arr, function(a, b)
        local na, nb = lower(nameOf(a)), lower(nameOf(b))
        if na ~= nb then return na < nb end
        return keyOf(a) < keyOf(b)
    end)
end

------------------------------------------------------------------ Home
local function pageHome(ctx)
    local J, page = ctx.J, ctx.page
    local sc = Kit.scroller(page)
    N("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, sc)
    Kit.pad(sc, 0, 0, 8, 6)
    local ord = 0
    local function nxt() ord = ord + 1 return ord end

    local tilesF = Kit.frame(sc, {Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, LayoutOrder = nxt()})
    N("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, tilesF)
    local function tile(i, caption)
        local t = Kit.frame(tilesF, {Size = UDim2.new(1 / 3, -6, 1, 0), LayoutOrder = i})
        Kit.corner(t, 8)
        Kit.stroke(t, Theme.Line)
        local num = Kit.label(t, {Size = UDim2.new(1, -20, 0, 26), Position = UDim2.fromOffset(12, 6), Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Theme.Gold, Text = "0"})
        Kit.label(t, {Size = UDim2.new(1, -20, 0, 14), Position = UDim2.fromOffset(12, 34), TextSize = 11, TextColor3 = Theme.TextDim, Text = caption})
        return num
    end
    local nPlayers, nSounds, nSaves = tile(1, tr("statPlayers")), tile(2, tr("statSounds")), tile(3, tr("statSaves"))

    local function group(title)
        Kit.section(sc, title, nxt())
        return Kit.card(sc, nxt())
    end
    local function toggle(card, title, desc, get, set)
        local row = Kit.cardRow(card, 56)
        Kit.label(row, {Size = UDim2.new(1, -76, 0, 18), Position = UDim2.fromOffset(14, 10), Text = title, TextSize = 13})
        Kit.label(row, {Size = UDim2.new(1, -76, 0, 14), Position = UDim2.fromOffset(14, 30), Text = desc, TextSize = 11, TextColor3 = Theme.TextDim})
        Kit.switch(row, UDim2.new(1, -52, 0.5, -10), get(), J, set)
    end

    local c1 = group(tr("secAudio"))
    toggle(c1, tr("muteMusic"), tr("muteMusicD"), function() return State.muteMusic end, function(v)
        State.muteMusic = v
        Audio.setGlobalMute(v)
    end)
    local c2 = group(tr("secAppearance"))
    toggle(c2, tr("noobSkin"), tr("noobSkinD"), function() return State.noob end, function(v)
        State.noob = v
        Targets.refreshAll()
    end)
    local c3 = group(tr("secMotion"))
    toggle(c3, tr("stopDance"), tr("stopDanceD"), function() return State.dances end, function(v)
        State.dances = v
    end)
    toggle(c3, tr("broadDance"), tr("broadDanceD"), function() return State.broadDances end, function(v)
        State.broadDances = v
    end)

    return {refresh = function()
        nPlayers.Text = tostring(math.max(#Players:GetPlayers() - 1, 0))
        local n = 0
        for _ in pairs(Audio.log) do n = n + 1 end
        nSounds.Text = tostring(n)
        nSaves.Text = tostring(#Saves.list)
    end}
end

------------------------------------------------------------------ Music log
local function pageMusic(ctx)
    local J, page = ctx.J, ctx.page
    local rows, query = {}, ""
    local refresh

    local bannerDot = Kit.frame(page, {Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(2, 6), BackgroundColor3 = Theme.Gold})
    Kit.corner(bannerDot, 3)
    local banner = Kit.label(page, {Size = UDim2.new(1, -170, 0, 18), Position = UDim2.fromOffset(14, 0), Font = Enum.Font.GothamBold, TextSize = 12})
    local clearB = Kit.button(page, {Size = UDim2.fromOffset(70, 22), Position = UDim2.new(1, -70, 0, -2), TextSize = 11, Text = tr("clear")}, "secondary", J)
    local refreshB = Kit.button(page, {Size = UDim2.fromOffset(70, 22), Position = UDim2.new(1, -146, 0, -2), TextSize = 11, Text = tr("refresh")}, "secondary", J)
    local _, searchBox = Kit.search(page, UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 30), tr("logSearch"), J)

    local hint = Kit.label(page, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 62), Text = tr("logHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextYAlignment = Enum.TextYAlignment.Top})
    local bar = Kit.frame(page, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.fromOffset(0, 62), BackgroundTransparency = 1, Visible = false})
    local stopB = Kit.button(bar, {Size = UDim2.fromOffset(120, 28), Position = UDim2.fromOffset(0, 1), TextSize = 11, Text = tr("stopListening")}, "primary", J)
    local pctL = Kit.label(bar, {Size = UDim2.fromOffset(42, 28), Position = UDim2.new(1, -42, 0, 1), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.GothamBold, TextColor3 = Theme.Gold, Text = "100%"})
    local soloSlider = makeSlider(bar, UDim2.fromOffset(134, 1), UDim2.new(1, -186, 0, 28), J, function(v)
        local k = Audio.solo
        if not k then return end
        local e = Audio.log[k]
        local st = Audio.entry(k, e and e.base)
        st.f = v
        Audio.commit(k)
        pctL.Text = pctText(v)
    end)

    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -98), Position = UDim2.fromOffset(0, 98)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)
    local empty = Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyLog"), TextColor3 = Theme.TextFaint, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    local function makeRow(k)
        local rj = Janitor.new()
        local row = Kit.frame(list, {Size = UDim2.new(1, 0, 0, 62)})
        Kit.corner(row, 8)
        Kit.stroke(row, Theme.Line)
        local dot = Kit.frame(row, {Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(12, 13), BackgroundColor3 = Theme.TextFaint})
        Kit.corner(dot, 3)
        local nameL = Kit.label(row, {Size = UDim2.new(1, -170, 0, 18), Position = UDim2.fromOffset(26, 8), TextSize = 13})
        local metaL = Kit.label(row, {Size = UDim2.new(1, -170, 0, 14), Position = UDim2.fromOffset(26, 27), TextSize = 11, TextColor3 = Theme.TextDim})
        local stateL = Kit.label(row, {Size = UDim2.new(1, -170, 0, 14), Position = UDim2.fromOffset(26, 42), TextSize = 11, TextColor3 = Theme.TextDim})
        local listenB = Kit.button(row, {Size = UDim2.fromOffset(62, 26), Position = UDim2.new(1, -144, 0, 18), TextSize = 11}, "secondary", rj)
        local exemptB = Kit.button(row, {Size = UDim2.fromOffset(66, 26), Position = UDim2.new(1, -76, 0, 18), TextSize = 11}, "danger", rj)
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
        local r = {frame = row, j = rj}
        function r.update(e, g)
            local st = Audio.settings[k]
            local exempt = st and st.x
            local live = g ~= nil
            nameL.Text = g and g.name or e.name or k
            local cat = Audio.catCache[k]
            metaL.Text = (cat and (tr(CAT_KEY[cat]) .. "  \u{B7}  ") or "") .. Audio.fmtTime(e.len) .. (e.looped and ("  \u{B7}  " .. tr("loop")) or "") .. ((g and g.count > 1) and ("  \u{B7}  \u{D7}" .. g.count) or "") .. "  \u{B7}  " .. (e.path or "")
            local state = exempt and tr("stExempt") or (State.muteMusic and tr("stByButton") or tr("stWillMute"))
            local play = (not live) and tr("stGone") or (g.playing and tr("stPlaying") or tr("stIdle"))
            stateL.Text = state .. "  \u{B7}  " .. play
            dot.BackgroundColor3 = exempt and Theme.Gold or ((State.muteMusic and Theme.Danger) or Theme.TextFaint)
            if Audio.solo == k then
                listenB.inst.Text = tr("stop")
                listenB.set("primary")
            else
                listenB.inst.Text = tr("listen")
                listenB.set(live and "secondary" or "off")
            end
            exemptB.inst.Text = exempt and tr("exempt") or tr("willMute")
            exemptB.set(exempt and "primary" or "danger")
        end
        return r
    end

    refresh = function()
        banner.Text = State.muteMusic and tr("logOn") or tr("logOff")
        banner.TextColor3 = State.muteMusic and Theme.Gold or Theme.TextDim
        bannerDot.BackgroundColor3 = State.muteMusic and Theme.Gold or Theme.TextFaint
        local soloK = Audio.solo
        bar.Visible, hint.Visible = soloK ~= nil, soloK == nil
        if soloK then
            local st = Audio.settings[soloK]
            local f = st and st.f or 1
            if not soloSlider.dragging then soloSlider.set(f) end
            pctL.Text = pctText(f)
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

    J:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        query = lower(trim(searchBox.Text))
        refresh()
    end))
    J:Add(clearB.inst.Activated:Connect(function()
        Audio.log = {}
        refresh()
    end))
    J:Add(refreshB.inst.Activated:Connect(function()
        Audio._gc = nil
        for k, r in pairs(rows) do killRow(r) rows[k] = nil end
        refresh()
    end))
    J:Add(stopB.inst.Activated:Connect(function()
        Audio.soloStop()
        refresh()
    end))
    J:Add(function() for _, r in pairs(rows) do r.j:Clean() end end)
    return {refresh = refresh}
end

------------------------------------------------------------------ Dance log
local function pageDances(ctx)
    local J, page = ctx.J, ctx.page
    local rows, tab = {}, "all"
    local refresh

    Kit.label(page, {Size = UDim2.new(1, 0, 0, 30), Text = tr("animHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextYAlignment = Enum.TextYAlignment.Top})
    local seg = Kit.segmented(page, UDim2.fromOffset(0, 36), UDim2.new(1, -78, 0, 30), {"all", "players", "game"}, J, function(name)
        tab = name
        refresh()
    end)
    seg.text("all", tr("animAll"))
    seg.text("players", tr("animPlayers"))
    seg.text("game", tr("animGame"))
    local refreshB = Kit.button(page, {Size = UDim2.fromOffset(70, 30), Position = UDim2.new(1, -70, 0, 36), TextSize = 11, Text = tr("refresh")}, "secondary", J)

    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -74), Position = UDim2.fromOffset(0, 74)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)
    local empty = Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptyAnim"), TextColor3 = Theme.TextFaint, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    local function makeRow(k)
        local rj = Janitor.new()
        local row = Kit.frame(list, {Size = UDim2.new(1, 0, 0, 52)})
        Kit.corner(row, 8)
        Kit.stroke(row, Theme.Line)
        local dot = Kit.frame(row, {Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(12, 23), BackgroundColor3 = Theme.Danger})
        Kit.corner(dot, 3)
        local nameL = Kit.label(row, {Size = UDim2.new(1, -130, 0, 18), Position = UDim2.fromOffset(26, 8), TextSize = 13})
        local subL = Kit.label(row, {Size = UDim2.new(1, -130, 0, 14), Position = UDim2.fromOffset(26, 28), TextSize = 11, TextColor3 = Theme.TextDim})
        local btn = Kit.button(row, {Size = UDim2.fromOffset(86, 26), Position = UDim2.new(1, -96, 0.5, -13), TextSize = 11}, "danger", rj)
        rj:Add(btn.inst.Activated:Connect(function()
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
        local r = {frame = row, j = rj}
        function r.update(e)
            local kind = e and e.kind
            local blocked = Dances.blocked(k, kind)
            nameL.Text = e and e.name or k
            local tag = (kind == "dance" and tr("tagPlayer")) or (kind == "game" and tr("tagGame")) or (kind == "other" and tr("tagOther")) or tr("tagSaved")
            local id = (k:sub(1, 2) == "n:") and "-" or ("ID " .. k)
            subL.Text = tag .. "  \u{B7}  " .. id .. ((e and e.who) and ("  \u{B7}  " .. e.who) or "") .. (e and ("  \u{B7}  x" .. e.n) or "")
            dot.BackgroundColor3 = blocked and Theme.Danger or Theme.Gold
            btn.inst.Text = blocked and tr("animBlocked") or tr("animAllowed")
            btn.set(blocked and "danger" or "primary")
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
            if tab == "all" or (tab == "players" and kind == "dance") or (tab == "game" and (kind == "game" or kind == "other")) then
                table.insert(arr, k)
            end
        end
        local function rankOf(k)
            local e = Dances.log[k]
            return e and RANK[e.kind] or 0
        end
        table.sort(arr, function(a, b)
            local ra, rb = rankOf(a), rankOf(b)
            if ra ~= rb then return ra > rb end
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

    J:Add(refreshB.inst.Activated:Connect(function()
        for k, r in pairs(rows) do killRow(r) rows[k] = nil end
        refresh()
    end))
    J:Add(function() for _, r in pairs(rows) do r.j:Clean() end end)
    return {refresh = refresh}
end

------------------------------------------------------------------ Players
local function pagePlayers(ctx)
    local J, page = ctx.J, ctx.page
    local segName, query = "online", ""
    local rows, currentTarget = {}, nil
    local refresh, layout

    local seg = Kit.segmented(page, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 30), {"online", "allowed", "blocked"}, J, function(name)
        segName = name
        layout()
        refresh()
    end)

    local searchF, searchBox = Kit.search(page, UDim2.fromOffset(0, 36), UDim2.new(1, 0, 0, 30), tr("searchPlayer"), J)
    local addF, addBox = Kit.search(page, UDim2.fromOffset(0, 36), UDim2.new(1, -72, 0, 30), tr("addPlayer"), J)
    local addB = Kit.button(page, {Size = UDim2.fromOffset(64, 30), Position = UDim2.new(1, -64, 0, 36), TextSize = 12, Text = tr("add")}, "primary", J)

    -- suggestion card
    local card = Kit.frame(page, {Size = UDim2.new(1, 0, 0, 56), Position = UDim2.fromOffset(0, 72)})
    Kit.corner(card, 8)
    Kit.stroke(card, Theme.Line)
    local sAv = N("ImageLabel", {Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(10, 11), BackgroundColor3 = Theme.Raised, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop}, card)
    Kit.corner(sAv, 17)
    local sName = Kit.label(card, {Size = UDim2.new(1, -200, 0, 18), Position = UDim2.fromOffset(54, 10), TextSize = 13})
    local sSub = Kit.label(card, {Size = UDim2.new(1, -200, 0, 14), Position = UDim2.fromOffset(54, 30), TextSize = 11, TextColor3 = Theme.TextDim})
    local sAllow = Kit.button(card, {Size = UDim2.fromOffset(58, 28), Position = UDim2.new(1, -132, 0, 14), TextSize = 11, Text = tr("allow")}, "primary", J)
    local sBlock = Kit.button(card, {Size = UDim2.fromOffset(58, 28), Position = UDim2.new(1, -68, 0, 14), TextSize = 11, Text = tr("block")}, "danger", J)

    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -134), Position = UDim2.fromOffset(0, 134)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)
    local empty = Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), TextColor3 = Theme.TextFaint, LayoutOrder = 99999, TextXAlignment = Enum.TextXAlignment.Center})

    layout = function()
        local online = segName == "online"
        searchF.Visible = online
        addF.Visible, addB.inst.Visible = not online, not online
        card.Visible = online
        local y = online and 134 or 72
        list.Position = UDim2.fromOffset(0, y)
        list.Size = UDim2.new(1, 0, 1, -y)
    end

    local function makeRow(sg, info)
        local rj = Janitor.new()
        local name = info.Name
        local row = Kit.frame(list, {Size = UDim2.new(1, 0, 0, 46)})
        Kit.corner(row, 8)
        Kit.stroke(row, Theme.Line)
        local av = N("ImageLabel", {Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(8, 8), BackgroundColor3 = Theme.Raised, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop}, row)
        Kit.corner(av, 15)
        local bw = (sg == "online") and 130 or 78
        local nameL = Kit.label(row, {Size = UDim2.new(1, -(52 + bw + 8), 0, 16), Position = UDim2.fromOffset(46, 6), TextSize = 13})
        local subL = Kit.label(row, {Size = UDim2.new(1, -(52 + bw + 8), 0, 14), Position = UDim2.fromOffset(46, 25), TextSize = 11, TextColor3 = Theme.TextDim})
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
            subL.Text = "@" .. inf.Name .. (isCreator and ("  \u{B7}  " .. tr("creator")) or "")
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
            sSub.Text = tr("inView") .. "  \u{B7}  @" .. best.Name
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

    J:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        query = lower(trim(searchBox.Text))
        refresh()
    end))
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

------------------------------------------------------------------ Saves
local function pageSaves(ctx)
    local J, page, onChanged = ctx.J, ctx.page, ctx.onChanged
    local dirty = true
    local lj = Janitor.new()
    J:Add(lj)

    local _, nameBox = Kit.search(page, UDim2.fromOffset(0, 0), UDim2.new(1, -78, 0, 30), tr("saveNamePh"), J)
    local saveB = Kit.button(page, {Size = UDim2.fromOffset(70, 30), Position = UDim2.new(1, -70, 0, 0), TextSize = 12, Text = tr("saveNow")}, "primary", J)
    Kit.label(page, {Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 36), Text = tr("saveHint"), TextColor3 = Theme.TextDim, TextSize = 11, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextYAlignment = Enum.TextYAlignment.Top})
    local status = Kit.label(page, {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 66), TextColor3 = Theme.Gold, Font = Enum.Font.GothamBold, TextSize = 11})

    local list = Kit.scroller(page, {Size = UDim2.new(1, 0, 1, -122), Position = UDim2.fromOffset(0, 86)})
    N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    Kit.pad(list, 0, 0, 8, 6)
    local resetB = Kit.button(page, {Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 1, -34), TextSize = 12, Text = tr("resetAll")}, "danger", J)

    local refresh
    local function flash(text)
        status.Text = text
        task.delay(1.8, function() if status.Parent and status.Text == text then status.Text = "" end end)
    end

    local function rebuild()
        lj:Clean()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end
        if #Saves.list == 0 then
            Kit.label(list, {Size = UDim2.new(1, 0, 0, 60), Text = tr("emptySaves"), TextColor3 = Theme.TextFaint, TextXAlignment = Enum.TextXAlignment.Center})
            return
        end
        for i, e in ipairs(Saves.list) do
            local row = Kit.frame(list, {Size = UDim2.new(1, 0, 0, 58), LayoutOrder = i})
            Kit.corner(row, 8)
            Kit.stroke(row, Theme.Line)
            local thisMap = tostring(e.place) == tostring(game.PlaceId)
            local dot = Kit.frame(row, {Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(12, 14), BackgroundColor3 = thisMap and Theme.Gold or Theme.TextFaint})
            Kit.corner(dot, 3)
            Kit.label(row, {Size = UDim2.new(1, -160, 0, 18), Position = UDim2.fromOffset(26, 8), Text = tostring(e.name), TextSize = 13})
            local sub = thisMap and tr("thisMap") or tostring(e.placeName or e.place)
            local okd, ds = pcall(function() return os.date("%d/%m %H:%M", e.t) end)
            if okd then sub = sub .. "  \u{B7}  " .. ds end
            Kit.label(row, {Size = UDim2.new(1, -160, 0, 14), Position = UDim2.fromOffset(26, 30), Text = sub, TextSize = 11, TextColor3 = Theme.TextDim})
            local loadB = Kit.button(row, {Size = UDim2.fromOffset(62, 28), Position = UDim2.new(1, -134, 0.5, -14), TextSize = 11, Text = tr("loadShort")}, "primary", lj)
            local delB = Kit.button(row, {Size = UDim2.fromOffset(58, 28), Position = UDim2.new(1, -66, 0.5, -14), TextSize = 11, Text = tr("delete")}, "danger", lj)
            lj:Add(loadB.inst.Activated:Connect(function()
                Saves.apply(e)
                onChanged()
            end))
            lj:Add(delB.inst.Activated:Connect(function()
                for idx, x in ipairs(Saves.list) do
                    if x == e then table.remove(Saves.list, idx) break end
                end
                Saves.write()
                dirty = true
                refresh()
            end))
        end
    end

    refresh = function()
        if dirty then
            dirty = false
            rebuild()
        end
    end

    J:Add(saveB.inst.Activated:Connect(function()
        Saves.add(nameBox.Text)
        nameBox.Text = ""
        flash(tr("saved"))
        dirty = true
        refresh()
    end))
    local armed = false
    J:Add(resetB.inst.Activated:Connect(function()
        if not armed then
            armed = true
            resetB.inst.Text = tr("resetConfirm")
            resetB.set("primary")
            task.delay(3, function()
                if armed and resetB.inst.Parent then
                    armed = false
                    resetB.inst.Text = tr("resetAll")
                    resetB.set("danger")
                end
            end)
            return
        end
        armed = false
        Saves.resetAll()
        onChanged()
    end))
    return {refresh = refresh}
end

--==============================================================
-- Language screen
--==============================================================
local function showLangScreen(onDone)
    local vp = viewport()
    local J = Root:Add(Janitor.new())
    local gui = Root:Add(N("ScreenGui", {Name = "BHLang", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))
    local chosen = false
    local dim = Kit.frame(gui, {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1})
    TweenService:Create(dim, TweenInfo.new(0.3), {BackgroundTransparency = 0.45}):Play()

    local cw, ch = math.min(340, vp.X - 24), 236
    local cx, cy = (vp.X - cw) / 2, (vp.Y - ch) / 2
    local card = Kit.frame(gui, {Size = UDim2.fromOffset(cw, ch), Position = UDim2.fromOffset(cx, cy + 18), BackgroundColor3 = Theme.Base})
    Kit.corner(card, 12)
    Kit.pulse(Kit.stroke(card, Theme.Line), Root)
    local hair = Kit.frame(card, {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 0), BackgroundColor3 = Theme.Gold})
    N("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1)})}, hair)

    Kit.crescent(card, UDim2.new(0.5, -14, 0, 22), 28, Theme.Gold, Theme.Base)
    Kit.label(card, {Size = UDim2.new(1, -30, 0, 22), Position = UDim2.fromOffset(15, 62), Text = "\u{628}\u{64A} \u{62D}\u{644}\u{627}\u{644}  /  Be Halal", Font = Enum.Font.GothamBold, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Center})
    Kit.label(card, {Size = UDim2.new(1, -30, 0, 16), Position = UDim2.fromOffset(15, 86), Text = "\u{627}\u{62E}\u{62A}\u{631} \u{627}\u{644}\u{644}\u{63A}\u{629}  /  Select language", TextSize = 11, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Center})

    local function option(text, sub, y, lang)
        local b = Kit.button(card, {Size = UDim2.new(1, -40, 0, 46), Position = UDim2.fromOffset(20, y), Text = ""}, "secondary", J)
        Kit.label(b.inst, {Size = UDim2.new(1, -50, 0, 18), Position = UDim2.fromOffset(16, 7), Text = text, Font = Enum.Font.GothamBold, TextSize = 14})
        Kit.label(b.inst, {Size = UDim2.new(1, -50, 0, 14), Position = UDim2.fromOffset(16, 25), Text = sub, TextSize = 11, TextColor3 = Theme.TextDim})
        Kit.label(b.inst, {Size = UDim2.fromOffset(20, 46), Position = UDim2.new(1, -28, 0, 0), Text = ">", TextColor3 = Theme.Gold, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center})
        J:Add(b.inst.Activated:Connect(function()
            if chosen then return end
            chosen = true
            TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.fromOffset(cx, cy + 18)}):Play()
            TweenService:Create(dim, TweenInfo.new(0.22), {BackgroundTransparency = 1}):Play()
            task.wait(0.22)
            gui:Destroy()
            onDone(lang)
        end))
    end
    option("\u{627}\u{644}\u{639}\u{631}\u{628}\u{64A}\u{629}", "\u{648}\u{627}\u{62C}\u{647}\u{629} \u{639}\u{631}\u{628}\u{64A}\u{629} \u{643}\u{627}\u{645}\u{644}\u{629}", 116, "ar")
    option("English", "Full English interface", 170, "en")
    TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(cx, cy)}):Play()
end

--==============================================================
-- Main window
--==============================================================
-- window position survives closing/re-running the script (file if the executor allows it, otherwise getgenv)
local PosStore = {file = "BeHalal_Pos.json"}
function PosStore.load()
    local d = readJSON(PosStore.file)
    if not (d and tonumber(d.x) and tonumber(d.y)) then d = ENV.__BeHalalPos end
    if type(d) == "table" and tonumber(d.x) and tonumber(d.y) then
        UI.pos = UDim2.fromOffset(tonumber(d.x), tonumber(d.y))
    end
end
function PosStore.save()
    if not UI.pos then return end
    local d = {x = UI.pos.X.Offset, y = UI.pos.Y.Offset}
    ENV.__BeHalalPos = d
    writeJSON(PosStore.file, d)
end

function UI.destroy()
    if UI.j then UI.j:Clean() UI.j = nil end
    UI.refresh = function() end
end

function UI.build()
    UI.destroy()
    local J = Janitor.new()
    UI.j = J
    local vp = viewport()
    local G = J:Add(N("ScreenGui", {Name = "BH", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PG))

    local W, H = math.min(640, vp.X - 24), math.min(440, vp.Y - 30)
    local RAIL = (W < 500) and 92 or 124
    local TH = 40
    local firstShow = not UI.shown
    UI.shown = true
    local px, py = (vp.X - W) / 2, (vp.Y - H) / 2
    if UI.pos then px, py = UI.pos.X.Offset, UI.pos.Y.Offset end
    px = math.clamp(px, -W + 80, vp.X - 80)
    py = math.clamp(py, 0, vp.Y - 40)
    local win = Kit.frame(G, {Name = "Window", Size = UDim2.fromOffset(W, H), Position = UDim2.fromOffset(px, firstShow and py + 14 or py), BackgroundColor3 = Theme.Base, ClipsDescendants = true})
    Kit.corner(win, 10)
    Kit.pulse(Kit.stroke(win, Theme.Line), J)

    -- title bar
    local bar = Kit.frame(win, {Size = UDim2.new(1, 0, 0, TH), BackgroundTransparency = 1})
    makeDraggable(bar, win, J, function() UI.pos = win.Position end, PosStore.save)
    Kit.crescent(bar, UDim2.fromOffset(14, 10), 20, Theme.Gold, Theme.Base)
    Kit.label(bar, {Size = UDim2.new(1, -170, 0, 18), Position = UDim2.fromOffset(44, 5), Text = tr("title"), Font = Enum.Font.GothamBold, TextSize = 14})
    Kit.label(bar, {Size = UDim2.new(1, -170, 0, 12), Position = UDim2.fromOffset(44, 22), Text = tr("subtitle") .. "  \u{B7}  v" .. VERSION, TextSize = 10, TextColor3 = Theme.TextFaint})

    local function iconBtn(xOff)
        return Kit.button(bar, {Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, xOff, 0, 6)}, "ghost", J)
    end
    local minB, closeB = iconBtn(-68), iconBtn(-36)
    Kit.frame(minB.inst, {Size = UDim2.fromOffset(10, 2), Position = UDim2.new(0.5, -5, 0.5, -1), BackgroundColor3 = Theme.TextDim})
    for _, rot in ipairs({45, -45}) do
        Kit.frame(closeB.inst, {Size = UDim2.fromOffset(12, 2), Position = UDim2.new(0.5, -6, 0.5, -1), BackgroundColor3 = Theme.TextDim, Rotation = rot})
    end

    local hair = Kit.frame(win, {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, TH), BackgroundColor3 = Theme.Gold})
    N("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(0.5, 0.15), NumberSequenceKeypoint.new(1, 0.9)})}, hair)

    -- side rail
    local rail = Kit.frame(win, {Size = UDim2.new(0, RAIL, 1, -TH - 1), Position = UDim2.fromOffset(0, TH + 1), BackgroundTransparency = 1})
    Kit.pad(rail, 8, 10, 8, 8)
    N("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, rail)
    Kit.frame(win, {Size = UDim2.new(0, 1, 1, -TH - 1), Position = UDim2.fromOffset(RAIL, TH + 1), BackgroundColor3 = Theme.Line})
    Kit.label(win, {Size = UDim2.fromOffset(RAIL - 16, 12), Position = UDim2.new(0, 14, 1, -22), Text = CREATOR_NAME, TextSize = 10, TextColor3 = Theme.TextFaint})

    local content = Kit.frame(win, {Size = UDim2.new(1, -RAIL - 1, 1, -TH - 1), Position = UDim2.fromOffset(RAIL + 1, TH + 1), BackgroundTransparency = 1})
    Kit.pad(content, 14, 12, 8, 10)

    local pages, navBtns, current = {}, {}, nil
    local show

    local function navButton(id, text, order)
        local b = N("TextButton", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Surface, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = order}, rail)
        Kit.corner(b, 6)
        local ind = Kit.frame(b, {Size = UDim2.fromOffset(3, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = Theme.Gold, Visible = false})
        Kit.corner(ind, 2)
        local lbl = Kit.label(b, {Size = UDim2.new(1, -22, 1, 0), Position = UDim2.fromOffset(14, 0), Text = text, TextSize = 12, TextColor3 = Theme.TextDim})
        navBtns[id] = {btn = b, ind = ind, lbl = lbl}
        J:Add(b.MouseEnter:Connect(function()
            if current ~= id then TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.55}):Play() end
        end))
        J:Add(b.MouseLeave:Connect(function()
            if current ~= id then TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play() end
        end))
        J:Add(b.Activated:Connect(function() show(id) end))
    end

    show = function(name)
        current = name
        UI.page = name
        for id, p in pairs(pages) do p.frame.Visible = (id == name) end
        for id, nb in pairs(navBtns) do
            local on = (id == name)
            nb.ind.Visible = on
            nb.btn.BackgroundTransparency = on and 0 or 1
            nb.lbl.TextColor3 = on and Theme.Text or Theme.TextDim
            nb.lbl.Font = on and Enum.Font.GothamBold or Enum.Font.GothamMedium
        end
        local p = pages[name]
        if p and p.refresh then pcall(p.refresh) end
    end

    -- after loading a save / reset everything, rebuild so the switches reflect the new state
    local function onChanged()
        task.defer(function()
            if State.running then
                UI.page = "saves"
                UI.build()
            end
        end)
    end

    local specs = {
        {"home", "navHome", pageHome},
        {"music", "navMusic", pageMusic},
        {"dances", "navDances", pageDances},
        {"players", "navPlayers", pagePlayers},
        {"saves", "navSaves", pageSaves},
    }
    for i, sp in ipairs(specs) do
        local f = Kit.frame(content, {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false})
        local api = sp[3]({J = J, page = f, onChanged = onChanged}) or {}
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

    -- minimized icon
    local mini = Kit.frame(G, {Size = UDim2.fromOffset(44, 44), Position = win.Position, BackgroundColor3 = Theme.Base, Visible = false})
    Kit.corner(mini, 22)
    Kit.pulse(Kit.stroke(mini, Theme.Gold, 1.5), J, 1.5)
    Kit.crescent(mini, UDim2.fromOffset(11, 11), 22, Theme.Gold, Theme.Base)
    local miniBtn = N("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, mini)
    local miniDrag = makeDraggable(miniBtn, mini, J, function() UI.pos = mini.Position end, PosStore.save)
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
    J:Add(minB.inst.Activated:Connect(function() setMin(true) end))
    J:Add(miniBtn.Activated:Connect(function() if not miniDrag.moved then setMin(false) end end))
    J:Add(closeB.inst.Activated:Connect(function() ENV.__BeHalal.destroy() end))

    show(UI.page or "home")
    UI.pos = UDim2.fromOffset(px, py)
    if firstShow then
        TweenService:Create(win, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UI.pos}):Play()
    end
end

--==============================================================
-- Lifecycle
--==============================================================
local Hub = {}
function Hub.destroy()
    if not State.running then return end
    State.running = false
    pcall(PosStore.save)
    pcall(Audio.shutdown)
    pcall(Targets.shutdown)
    pcall(UI.destroy)
    Root:Clean()
    if ENV.__BeHalal == Hub then ENV.__BeHalal = nil end
end
ENV.__BeHalal = Hub

--==============================================================
-- Boot
--==============================================================
Audio.init()
Saves.init()

Root:Add(Players.PlayerAdded:Connect(function(p) task.spawn(onPlayer, p) end))
Root:Add(Players.PlayerRemoving:Connect(function(p) Targets.remove(p) end))
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end

Root:Add(RunService.Heartbeat:Connect(Dances.hold))
loop(0.2, function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then Dances.scan(p.Character, p) end
    end
end)
loop(1, Targets.refreshAll)

PosStore.load()
showLangScreen(function(lang)
    State.lang = lang
    task.wait(0.1)
    if State.running then UI.build() end
end)
