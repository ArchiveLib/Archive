if not game:IsLoaded() then local t = 0; while not game:IsLoaded() and t < 20 do task.wait(0.1); t = t + 0.1 end end
if type(shared.ArchiveCleanup) == "function" then pcall(shared.ArchiveCleanup) end

local BUILD = "dev-build 1.0.49"
local placeids = {
    chime = 12522881268,
    lobby = 4111023553
}

if game.PlaceId == placeids.chime then
    pcall(function()
        local pg = game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then for _, g in ipairs(pg:GetChildren()) do if g.Name == "ArchiveChimeHelper" then g:Destroy() end end end
    end)
    local G = {}
    G.tw = (task and task.wait) or wait
    G.ts = (task and task.spawn) or spawn
    G.WS = game:GetService("Workspace")
    G.Plrs = game:GetService("Players")
    G.UIS = game:GetService("UserInputService")
    G.SG = game:GetService("StarterGui")
    G.TS = game:GetService("TweenService")
    G.new = Instance.new
    G.V2 = Vector2.new
    G.UD = UDim.new
    G.UD2 = UDim2.new
    G.TI = TweenInfo.new
    G.RGB = Color3.fromRGB
    G.C3 = Color3.new
    G.LP = G.Plrs.LocalPlayer
    if not G.LP then local t = 0; while not G.LP and t < 15 do G.tw(0.1); G.LP = G.Plrs.LocalPlayer; t = t + 0.1 end end
    G.tw(0.3)
    local function getHP()
        local pg = G.LP and (G.LP:FindFirstChildOfClass("PlayerGui") or G.LP:FindFirstChild("PlayerGui"))
        if pg then return pg end
        if G.LP then pg = G.LP:WaitForChild("PlayerGui", 15); if pg then return pg end end
        return G.WS
    end
    local P = { base = G.RGB(11,12,14), panel = G.RGB(17,19,24), brd = G.RGB(35,39,48), tx = G.RGB(232,230,225), mt = G.RGB(110,116,128), amb = G.RGB(217,162,76), ok = G.RGB(92,214,140) }
    local ACCENT_FALLBACK = {
        EloRank1   = { {0.00,{0,0,0}}, {0.28,{28,5,6}}, {0.66,{213,43,46}}, {0.91,{237,240,56}}, {1.00,{240,88,88}} },
        EloRank10  = { {0.00,{162,25,1}}, {0.61,{240,112,53}}, {0.67,{240,177,75}}, {1.00,{240,177,75}} },
        EloRank50  = { {0.00,{255,242,176}}, {0.21,{245,245,245}}, {0.44,{245,234,150}}, {0.71,{202,163,63}}, {1.00,{245,234,150}} },
        EloRank250 = { {0.00,{215,255,252}}, {0.38,{245,245,245}}, {0.48,{245,245,245}}, {0.66,{163,202,194}}, {1.00,{116,159,168}} },
        EloRank1000 = { {0.00,{230,191,144}}, {0.38,{245,181,138}}, {0.49,{227,200,176}}, {0.70,{194,158,129}}, {1.00,{168,147,130}} },
    }
    local accentFolder = nil
    pcall(function() accentFolder = game:GetService("ReplicatedStorage").Assets.NameAccents end)
    local accentCache = {}
    local function filterSeq(seq)
        local kp, total = {}, #seq.Keypoints
        for _, k in ipairs(seq.Keypoints) do
            local v = k.Value
            if total <= 2 or math.max(v.R, v.G, v.B) > 0.25 then table.insert(kp, k) end
        end
        if #kp < 2 then return seq end
        local ok, s = pcall(function() return ColorSequence.new(kp) end)
        if ok then return s end
        return seq
    end
    local function getAccent(tier)
        if accentCache[tier] then return accentCache[tier] end
        local seq
        if accentFolder then
            local a = accentFolder:FindFirstChild(tier)
            if a then
                local ok, c = pcall(function() return a.Color end)
                if ok and typeof(c) == "ColorSequence" then seq = c end
            end
        end
        if not seq then
            local fb = ACCENT_FALLBACK[tier]
            if fb then
                local kp = {}
                for _, k in ipairs(fb) do
                    table.insert(kp, ColorSequenceKeypoint.new(k[1], G.RGB(k[2][1], k[2][2], k[2][3])))
                end
                seq = ColorSequence.new(kp)
            end
        end
        seq = filterSeq(seq or ColorSequence.new(P.tx))
        accentCache[tier] = seq
        return seq
    end
    local function tierFor(rank)
        if rank == 1 then return "EloRank1" end
        if rank <= 10 then return "EloRank10" end
        if rank <= 50 then return "EloRank50" end
        if rank <= 250 then return "EloRank250" end
        return "EloRank1000"
    end
    local TIER_NAME_FALLBACK = { EloRank1 = "Sovereign of Conflict", EloRank10 = "Godseeker", EloRank50 = "Grandmaster", EloRank250 = "Silver", EloRank1000 = "Bronze" }
    local function tierName(tier)
        local a = accentFolder and accentFolder:FindFirstChild(tier)
        if a then
            local n = a:GetAttribute("RichName")
            if type(n) == "string" and n ~= "" then return n end
        end
        return TIER_NAME_FALLBACK[tier] or ""
    end
    local function setAccent(lbl, tier)
        local g = lbl:FindFirstChildOfClass("UIGradient")
        if not g then g = G.new("UIGradient", lbl) end
        g.Color = getAccent(tier)
        g.Rotation = 0
    end
    local function mkC(p, r) G.new("UICorner", p).CornerRadius = G.UD(0, r) end
    local function mkS(p, c, th) local s = G.new("UIStroke", p); s.Color = c; s.Thickness = th or 1 end
    local function mkL(par, txt, x, y, w, h, ts, fnt, ax, col)
        local l = G.new("TextLabel"); l.BackgroundTransparency = 1
        l.Font = fnt or Enum.Font.GothamMedium
        l.TextSize = ts or 12
        l.TextColor3 = col or P.tx
        l.TextXAlignment = ax or Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        l.Text = txt or ""
        l.RichText = false
        l.Position = G.UD2(0, math.floor(x), 0, math.floor(y))
        l.Size = G.UD2(0, math.floor(w), 0, math.floor(h))
        l.Parent = par
        return l
    end
    local function mkRich(par, x, y, w, h, ts, ax)
        local l = mkL(par, "", x, y, w, h, ts, Enum.Font.Gotham, ax or Enum.TextXAlignment.Left, P.tx)
        l.RichText = true
        return l
    end
    local sg = G.new("ScreenGui")
    sg.Name = "ArchiveChimeHelper"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 1000
    pcall(function()
        if type(syn) == "table" and syn.protect_gui then syn.protect_gui(sg)
        elseif type(protectgui) == "function" then protectgui(sg) end
    end)
    sg.Parent = getHP()
    local f = G.new("Frame", sg)
    f.Name = "Main"
    f.AnchorPoint = G.V2(0, 0.5)
    f.Position = G.UD2(0, 12, 0.5, 0)
    f.Size = G.UD2(0, 344, 0, 296)
    f.BackgroundColor3 = P.base
    f.BorderSizePixel = 0
    mkC(f, 6); mkS(f, P.amb, 1, 0.7)
    local hdr = G.new("Frame", f)
    hdr.Name = "Header"
    hdr.Size = G.UD2(1, 0, 0, 36)
    hdr.BackgroundColor3 = P.panel
    hdr.BorderSizePixel = 0
    mkC(hdr, 6)
    mkL(hdr, "ARCHIVE CHIME HELPER", 12, 0, 320, 36, 20, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb)
    local drag, ds, fp = false, nil, nil
    hdr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; fp = f.Position
        end
    end)
    G.UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            f.Position = G.UD2(0, fp.X.Offset + d.X, 0.5, fp.Y.Offset + d.Y)
        end
    end)
    G.UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    local body = G.new("Frame", f)
    body.Position = G.UD2(0, 8, 0, 44)
    body.Size = G.UD2(1, -16, 1, -52)
    body.BackgroundTransparency = 1
    body.BorderSizePixel = 0
    
    mkL(body, "YOUR RATING", 0, 0, 160, 22, 14, Enum.Font.Gotham, Enum.TextXAlignment.Left, P.mt)
    local ratingLabel = mkRich(body, 168, 0, 160, 20, 15, Enum.TextXAlignment.Right)
    ratingLabel.Text = '<font face="Roboto" color="rgb(255,230,160)">...</font>'

    local function mkDivider(y)
        local d = G.new("Frame", body)
        d.Position = G.UD2(0, 0, 0, y)
        d.Size = G.UD2(1, 0, 0, 1)
        d.BackgroundColor3 = P.brd
        d.BorderSizePixel = 0
    end
    mkDivider(24)

    mkL(body, "ELO NEEDED TO REACH", 0, 32, 220, 16, 14, Enum.Font.Gotham, Enum.TextXAlignment.Left, P.mt)

    local fontSrc, fontApplied = nil, {}
    local function getFontSource()
        if fontSrc then return fontSrc end
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
        local lobby = pg and pg:FindFirstChild("LobbyGui")
        local scroll = lobby and lobby.Overlay and lobby.Overlay.Ranking and lobby.Overlay.Ranking:FindFirstChild("RankScroll")
        if scroll then
            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("TextLabel") then fontSrc = c; break end
            end
        end
        if not fontSrc then
            local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
            local gui = assets and assets:FindFirstChild("GUI")
            local nd = gui and gui:FindFirstChild("NameDisplay")
            local nf = nd and nd:FindFirstChild("NameFrame")
            local cn = nf and nf:FindFirstChild("CharacterName")
            if cn and cn:IsA("TextLabel") then fontSrc = cn end
        end
        return fontSrc
    end
    local function applyGameFont(key, lbl)
        if fontApplied[key] then return end
        local src = getFontSource()
        if not src then return end
        if src.Font ~= Enum.Font.Unknown then
            pcall(function() lbl.Font = src.Font end)
        else
            pcall(function() lbl.FontFace = src.FontFace end)
        end
        fontApplied[key] = true
    end
    local function boldify(lbl)
        lbl.RichText = true
    end
    local function B(txt) return "<b>" .. txt .. "</b>" end

    local TARGETS = { 10, 50, 250 }
    local ROW_H = 21
    local rowLabels, tierLabels = {}, {}
    for i, t in ipairs(TARGETS) do
        local y = 50 + (i - 1) * ROW_H
        local l = mkL(body, "", 0, y, 200, 20, 14, Enum.Font.Gotham, Enum.TextXAlignment.Left, G.C3(1, 1, 1))
        setAccent(l, tierFor(t))
        applyGameFont("r" .. t, l)
        boldify(l)
        rowLabels[t] = l
        local tl = mkL(body, B(tierName(tierFor(t))), 196, y - 1, 132, 22, 13, Enum.Font.Gotham, Enum.TextXAlignment.Right, G.C3(1, 1, 1))
        setAccent(tl, tierFor(t))
        applyGameFont("t" .. t, tl)
        boldify(tl)
        tierLabels[t] = tl
    end

    local rowsBottom = 50 + #TARGETS * ROW_H
    local yDiv = rowsBottom + 8
    mkDivider(yDiv)
    mkL(body, "CHECK ANY RANK", 0, yDiv + 8, 220, 16, 12, Enum.Font.Gotham, Enum.TextXAlignment.Left, P.mt)

    local inputBox = G.new("TextBox", body)
    inputBox.Position = G.UD2(0, 0, 0, yDiv + 28)
    inputBox.Size = G.UD2(1, 0, 0, 24)
    inputBox.BackgroundColor3 = P.panel
    inputBox.BorderSizePixel = 0
    inputBox.Font = Enum.Font.Roboto
    inputBox.TextSize = 14
    inputBox.TextColor3 = P.tx
    inputBox.Text = ""
    inputBox.PlaceholderText = "enter a rank, e.g. 178"
    inputBox.PlaceholderColor3 = P.mt
    inputBox.ClearTextOnFocus = false
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    mkC(inputBox, 4); mkS(inputBox, P.brd, 1)
    G.new("UIPadding", inputBox).PaddingLeft = G.UD(0, 8)

    local yCustom = yDiv + 56
    local customResult = mkL(body, "", 0, yCustom, 328, 20, 14, Enum.Font.Gotham, Enum.TextXAlignment.Left, G.C3(1, 1, 1))
    customResult.Text = B("#?   ...")
    boldify(customResult)

    mkL(body, "Only #1 - #250 is available", 0, yCustom + 26, 328, 16, 12, Enum.Font.Gotham, Enum.TextXAlignment.Left, P.mt)
    local statusLabel = mkL(body, "", 0, yCustom + 44, 328, 16, 10, Enum.Font.Gotham, Enum.TextXAlignment.Left, P.mt)

    local function getScroll()
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local lobby = pg:FindFirstChild("LobbyGui")
        local rs = lobby and lobby.Overlay and lobby.Overlay.Ranking and lobby.Overlay.Ranking:FindFirstChild("RankScroll")
        if rs then return rs end
        for _, d in ipairs(pg:GetDescendants()) do
            if d.Name == "RankScroll" then return d end
        end
        return nil
    end

    local function readBoard()
        local map = {}
        local rs = getScroll()
        if not rs then return map end
        for _, c in ipairs(rs:GetChildren()) do
            if c:IsA("TextLabel") then
                local rnk = tonumber(c.Name)
                if rnk then
                    local segs = {}
                    for v in (c.Text or ""):gmatch(">([^<]*)</font>") do table.insert(segs, v) end
                    map[rnk] = {
                        rank = rnk,
                        name = segs[2] or "",
                        rating = tonumber((segs[3] or ""):match("%d+")) or nil,
                    }
                end
            end
        end
        return map
    end

    local function rowText(target, entry, rating)
        if not entry or not entry.rating then
            return string.format("#%d   no data yet", target)
        end
        local delta = entry.rating - rating
        if delta > 0 then
            return string.format("#%d   +%d elo   (%d)", target, delta, entry.rating)
        end
        return string.format("#%d   reached   (%d)", target, entry.rating)
    end

    local function setSolid(lbl, col)
        local g = lbl:FindFirstChildOfClass("UIGradient")
        if not g then g = G.new("UIGradient", lbl) end
        g.Color = ColorSequence.new(col)
        g.Rotation = 0
    end

    local customRank = nil
    local function applyCustom(map, rating)
        if not customRank then return end
        customResult.Text = B(rowText(customRank, map[customRank], rating))
        boldify(customResult)
        setAccent(customResult, tierFor(customRank))
    end

    local function refreshRank()
        local rating = 0
        pcall(function() rating = tonumber(G.LP:GetAttribute("EloRating")) or 0 end)
        local ownRank = nil
        pcall(function() ownRank = tonumber(G.LP:GetAttribute("EloRankNo")) end)
        if ownRank then
            ratingLabel.Text = string.format('<font face="Roboto" color="rgb(255,230,160)">Top #%d</font>   <font face="Roboto" color="rgb(200,200,200)">%d</font>', ownRank, rating)
        else
            ratingLabel.Text = string.format('<font face="Roboto" color="rgb(255,230,160)">%d Elo</font>', rating)
        end
        local map = readBoard()
        local tracked = 0
        for _ in pairs(map) do tracked = tracked + 1 end
        for _, t in ipairs(TARGETS) do
            rowLabels[t].Text = B(rowText(t, map[t], rating))
            applyGameFont("r" .. t, rowLabels[t])
            applyGameFont("t" .. t, tierLabels[t])
        end
        applyCustom(map, rating)
    end

    local function submitCustom()
        local n = tonumber((inputBox.Text or ""):match("%d+"))
        if not n then
            customResult.Text = B("enter a number")
            setSolid(customResult, G.RGB(214, 92, 92))
            return
        end
        if n < 1 or n > 250 then
            customResult.Text = B("out of range - only #1 to #250 exists")
            setSolid(customResult, G.RGB(214, 92, 92))
            customRank = nil
            return
        end
        customRank = n
        inputBox.Text = tostring(n)
        refreshRank()
    end

    inputBox.FocusLost:Connect(submitCustom)
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        local n = tonumber((inputBox.Text or ""):match("%d+"))
        if n and n >= 1 and n <= 250 then
            customRank = n
            refreshRank()
        end
    end)

    G.ts(function()
        while f and f.Parent do
            refreshRank()
            G.tw(5)
        end
    end)
    refreshRank()
    G.SG:SetCore("SendNotification", {Title = "Archive Chime Helper", Text = "Loaded", Duration = 3})
    return
elseif game.PlaceId == placeids.lobby then
    local player = game.Players.LocalPlayer
    player:Kick("Script does not support the main lobby")
end

local G = {}
G.tw = (task and task.wait) or wait
G.ts = (task and task.spawn) or spawn
G.WS = game:GetService("Workspace")
G.Plrs = game:GetService("Players")
G.TS = game:GetService("TweenService")
G.RS = game:GetService("RunService")
G.UIS = game:GetService("UserInputService")
G.SG = game:GetService("StarterGui")
G.HS = game:GetService("HttpService")
G.TPS = game:GetService("TeleportService")
G.RepS = game:GetService("ReplicatedStorage")
pcall(function() G.VIM = game:GetService("VirtualInputManager") end)
G.new = Instance.new; G.V2 = Vector2.new; G.V3 = Vector3.new
G.RGB = Color3.fromRGB; G.C3 = Color3.new
G.CS = ColorSequence.new; G.CSK = ColorSequenceKeypoint.new
G.UD = UDim.new; G.UD2 = UDim2.new; G.TI = TweenInfo.new
G.CF = CFrame.new
G.ti = table.insert
G.ck = os.clock; G.mx = math.max; G.sq = math.sqrt; G.mr = math.round or function(x) return math.floor(x + 0.5) end
G.mc = math.clamp or function(v, a, b) if v < a then return a end; if v > b then return b end; return v end
G.tc = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
G.LP = G.Plrs.LocalPlayer
if not G.LP then local t = 0; while not G.LP and t < 15 do G.tw(0.1); G.LP = G.Plrs.LocalPlayer; t = t + 0.1 end end
G.tw(0.3)

G.httpReq = (type(request) == "function" and request)
    or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
    or (type(http_request) == "function" and http_request)
    or (type(http) == "table" and type(http.request) == "function" and http.request) or nil
function G.httpGet(u, headers)
    local r
    if G.httpReq then local o, v = pcall(G.httpReq, {Url = u, Method = "GET", Headers = headers}); if o and v then r = v.Body end end
    if not r then pcall(function() r = game:HttpGet(u) end) end
    return r
end

function G.pressKey(kc)
    if G.VIM then pcall(function() G.VIM:SendKeyEvent(true, kc, false, game); G.tw(); G.VIM:SendKeyEvent(false, kc, false, game) end); return end
    if type(keypress) == "function" then
        local vk = ({[Enum.KeyCode.F] = 0x46, [Enum.KeyCode.E] = 0x45, [Enum.KeyCode.Q] = 0x51, [Enum.KeyCode.G] = 0x47})[kc]
        if vk then pcall(function() keypress(vk); G.tw(); keyrelease(vk) end) end
    end
end
function G.pressM2()
    if G.VIM then pcall(function() G.VIM:SendMouseButtonEvent(0, 0, 1, true, game, 1); G.tw(); G.VIM:SendMouseButtonEvent(0, 0, 1, false, game, 1) end); return end
    if type(mouse2press) == "function" then pcall(function() mouse2press(); G.tw(); mouse2release() end) end
end

local CFG = {
    MenuKey = Enum.KeyCode.P,
    File = "Archive_config.json",
    EspRange = 4000,
    EspFps = 60,
    PlrEspRange = 4000, PlrEspFps = 60,
    MobEspRange = 4000, MobEspFps = 60,
    NpcEspRange = 4000, NpcEspFps = 60,
    ChestEspRange = 4000, ChestEspFps = 60,
    AgilMin = 1, AgilMax = 400, AgilVal = 1,
    SpdMin = 0, SpdMax = 100, SpdVal = 16,
    ASpdMin = 0.1, ASpdMax = 5.0, ASpdVal = 1.5, MSpdVal = 1.5,
    FpsVal = 60,
    BrightVal = 3,
    FlySpeed = 80,
    PKTMode = "aggressive",
    M1 = "Q,M2", M2 = "", M3 = "",
    AutoBuildUrl = "",
    QuickLoad = "",
}


local S = {
    menu = true,
    pktPlk = false,
    esp = false, espGlobal = true, espBox = false, espLvl = false, espHp = false, htnl = false,
    mobEsp = false, nEsp = false, cEsp = false,
    autoloot = false, spec = false, specRobloxNames = false,
    agil = false, agSpd = false, nc = false, nfd = false, fly = false,
    aSpd = false, mSpd = false, noVis = false, opt = false, fps = false,
    nkb = false, npcFreeze = false,
    modDetector = false, modSound = false, modRepeat = true,
    tp = false,
    humanoidPathfindBreaker = false, attachToBack = false,
    effDisable = false, effHunger = true, effUnderwater = true, effSanity = true,
    sanityHud = false, bright = false,
    kbHud = false, showChat = false,
    autoBuild = false, autoPoints = false,
    gourd = false,
}
local kb = {}
local KB_KEYS = {"pktPlk","esp","espBox","espLvl","espHp","htnl","espGlobal","mobEsp","nEsp","cEsp","autoloot","spec","specRobloxNames","agil","agSpd","mSpd","nc","nfd","fly","aSpd","opt","fps","nkb","npcFreeze","modDetector","humanoidPathfindBreaker","attachToBack","effDisable","sanityHud","bright","kbHud","showChat","autoBuild","autoPoints","gourd","m1","m2","m3","menuKey"}
kb.menuKey = Enum.KeyCode.P

local UI = {}; UI.espF = {}; UI._curTab = "combat"
local kbL = {}
local statics = {}
local listening = nil
local function trk(c) G.ti(statics, c); return c end

do
    G.CFGDIR = "Archive_configs"
    function G.cfgPath(name) return G.CFGDIR .. "/" .. tostring(name) .. ".json" end
    function G.cfgList()
        if type(listfiles) ~= "function" or type(isfolder) ~= "function" then return {} end
        if not isfolder(G.CFGDIR) then return {} end
        local out = {}
        pcall(function()
            for _, f in ipairs(listfiles(G.CFGDIR)) do
                local n = string.match(tostring(f), "([^/\\]+)%.json$")
                if n then G.ti(out, n) end
            end
        end)
        table.sort(out)
        return out
    end
    function G.snapshot()
        local d = {sliders = {}, macros = {}, toggles = {}}
        for _, f in ipairs(KB_KEYS) do
            local kc = kb[f]
            d[f] = kc and kc.Name or ""
        end
        d.sliders.EspRange = CFG.EspRange
        d.sliders.EspFps = CFG.EspFps
        d.sliders.PlrEspRange = CFG.PlrEspRange; d.sliders.PlrEspFps = CFG.PlrEspFps
        d.sliders.MobEspRange = CFG.MobEspRange; d.sliders.MobEspFps = CFG.MobEspFps
        d.sliders.NpcEspRange = CFG.NpcEspRange; d.sliders.NpcEspFps = CFG.NpcEspFps
        d.sliders.ChestEspRange = CFG.ChestEspRange; d.sliders.ChestEspFps = CFG.ChestEspFps
        d.sliders.FlySpeed = CFG.FlySpeed
        d.sliders.AgilVal = CFG.AgilVal; d.sliders.SpdVal = CFG.SpdVal
        d.sliders.ASpdVal = CFG.ASpdVal; d.sliders.MSpdVal = CFG.MSpdVal
        d.sliders.FpsVal = CFG.FpsVal
        d.sliders.BrightVal = CFG.BrightVal
        d.macros.m1 = CFG.M1; d.macros.m2 = CFG.M2; d.macros.m3 = CFG.M3
        d.autoBuildUrl = CFG.AutoBuildUrl
        d.agSpd = S.agSpd
        d.PKTMode = CFG.PKTMode
        if KBHUD and KBHUD.frame and KBHUD.frame.Parent then
            local p = KBHUD.frame.Position
            d.kbHudPos = {sx = p.X.Scale, ox = math.floor(p.X.Offset), sy = p.Y.Scale, oy = math.floor(p.Y.Offset)}
        elseif CFG.KbHudPos then
            d.kbHudPos = CFG.KbHudPos
        end
        if CFG.GourdHudPos then d.gourdHudPos = CFG.GourdHudPos end
        local TOGS = {"pktPlk", "esp", "espGlobal", "espBox", "espLvl", "espHp", "htnl", "mobEsp", "nEsp", "cEsp",
            "autoloot", "spec", "specRobloxNames", "agil", "agSpd", "nc", "nfd", "fly", "aSpd", "mSpd", "noVis", "opt", "fps",
            "nkb", "npcFreeze", "modDetector", "modSound", "modRepeat", "humanoidPathfindBreaker", "attachToBack", "effDisable", "effHunger",
            "effUnderwater", "effSanity", "sanityHud", "bright", "kbHud", "showChat", "autoBuild", "autoPoints", "gourd"}
        for _, k in ipairs(TOGS) do
            d.toggles[k] = S[k]
        end
        return d
    end
    function G.applyData(d, skipToggles)
        if type(d) ~= "table" then return end
        for _, f in ipairs(KB_KEYS) do
            if d[f] ~= nil then
                if d[f] == "" then kb[f] = nil
                else local ok, kc = pcall(function() return Enum.KeyCode[d[f]] end); kb[f] = (ok and kc) or nil end
            end
        end
        if d.sliders then
            for _, k in ipairs({"EspRange", "EspFps", "PlrEspRange", "PlrEspFps", "MobEspRange", "MobEspFps", "NpcEspRange", "NpcEspFps", "ChestEspRange", "ChestEspFps", "FlySpeed", "AgilVal", "SpdVal", "ASpdVal", "MSpdVal", "FpsVal", "BrightVal"}) do
                if d.sliders[k] ~= nil then CFG[k] = d.sliders[k] end
            end
        end
        if d.macros then for _, k in ipairs({"m1", "m2", "m3"}) do if d.macros[k] then CFG["M" .. k:sub(2)] = d.macros[k] end end end
        if d.agSpd ~= nil then S.agSpd = d.agSpd end
        if d.PKTMode then CFG.PKTMode = d.PKTMode end
        if d.autoBuildUrl ~= nil then CFG.AutoBuildUrl = tostring(d.autoBuildUrl) end
        if d.kbHudPos and type(d.kbHudPos) == "table" then CFG.KbHudPos = d.kbHudPos end
        if d.gourdHudPos and type(d.gourdHudPos) == "table" then CFG.GourdHudPos = d.gourdHudPos end
        if d.toggles and not skipToggles then for k, v in pairs(d.toggles) do if S[k] ~= nil then S[k] = v end end end
        pcall(function() if UI and UI._sliders then for k, fn in pairs(UI._sliders) do if CFG[k] ~= nil then fn(CFG[k]) end end end end)
        pcall(function() if UI and UI.updTog then UI.updTog() end end)
        pcall(function() if KBHUD and KBHUD.hintDirty then KBHUD.hintDirty() end end)
    end
    function G.saveConfig(name)
        if type(writefile) ~= "function" then return false end
        if type(makefolder) == "function" and type(isfolder) == "function" then
            pcall(function() if not isfolder(G.CFGDIR) then makefolder(G.CFGDIR) end end)
        end
        local target = name and G.cfgPath(name) or CFG.File
        local ok = pcall(function() writefile(target, G.HS:JSONEncode(G.snapshot())) end)
        return ok
    end
    function G.loadConfig(name, skipToggles)
        if type(readfile) ~= "function" or type(isfile) ~= "function" then return false end
        local target = name and G.cfgPath(name) or CFG.File
        if not isfile(target) then return false end
        local ok = pcall(function()
            local d = G.HS:JSONDecode(readfile(target))
            local old = {}
            for k, v in pairs(S) do old[k] = v end
            G.applyData(d, skipToggles == true)
            G._changedToggles = {}
            if not (skipToggles == true) and type(d.toggles) == "table" then
                for k, v in pairs(d.toggles) do
                    if old[k] ~= nil and old[k] ~= v then
                        G._changedToggles[k] = true
                    end
                end
            end
        end)
        return ok
    end
    function G.deleteConfig(name)
        if type(delfile) ~= "function" or type(isfile) ~= "function" then return false end
        local target = G.cfgPath(name)
        if not isfile(target) then return false end
        local ok = pcall(function() delfile(target) end)
        return ok
    end
    
    function G.freshBoot()
        for k, _ in pairs(S) do
            if k ~= "menu" and k ~= "espGlobal" and k ~= "effHunger" and k ~= "effUnderwater" and k ~= "effSanity" then
                S[k] = false
            end
        end
        S.effHunger, S.effUnderwater, S.effSanity = true, true, true
        S.menu = true
    end
end

do
    local qf = "Archive_quickload.txt"
    if type(readfile) == "function" and type(isfile) == "function" and isfile(qf) then
        pcall(function()
            local v = readfile(qf)
            if type(v) == "string" then v = v:gsub("^%s+", ""):gsub("%s+$", "") end
            if v and v ~= "" then CFG.QuickLoad = v end
        end)
    end
    G.saveQuickLoad = function(name)
        if type(writefile) ~= "function" then return false end
        pcall(function() writefile(qf, tostring(name or "")) end)
        return true
    end
    G.loadQuickLoad = function()
        if type(readfile) ~= "function" or type(isfile) ~= "function" then return "" end
        if not isfile(qf) then return "" end
        local v = ""
        pcall(function() v = readfile(qf) end)
        if type(v) == "string" then v = v:gsub("^%s+", ""):gsub("%s+$", "") end
        return v or ""
    end
end

local P = {
    base = G.RGB(11, 12, 14), panel = G.RGB(17, 19, 24), hover = G.RGB(22, 24, 30),
    brd = G.RGB(35, 39, 48),
    tx = G.RGB(232, 230, 225), mt = G.RGB(110, 116, 128),
    amb = G.RGB(217, 162, 76), dng = G.RGB(200, 96, 92),
    on = G.RGB(217, 162, 76), off = G.RGB(42, 45, 58),
    ok = G.RGB(92, 214, 140),
}
local UC = {}
UC.RN = "A_" .. tostring(Random.new():NextInteger(100000, 999999))
UC.ETOP = G.V3(0, 3, 0); UC.EBOT = G.V3(0, 3.2, 0)

do
    function G.kName(kc)
        if not kc then return "···" end
        local n = kc.Name; if #n == 1 then return n end
        return ({LeftShift = "LSh", RightShift = "RSh", LeftControl = "LCt", LeftAlt = "LAl", Backquote = "`", Space = "Spc", Return = "Ent"})[n] or n
    end
    function G.startL(f)
        local sg = G.getHP():FindFirstChild(UC.RN)
        if not sg then return end
        if G._kbModal then pcall(function() G._kbModal:Destroy() end); G._kbModal = nil end
        local backdrop = G.new("Frame", sg)
        backdrop.Name = "KBModal"
        backdrop.Size = G.UD2(1, 0, 1, 0); backdrop.Position = G.UD2(0, 0, 0, 0)
        backdrop.BackgroundColor3 = G.RGB(0, 0, 0); backdrop.BackgroundTransparency = 0.55
        backdrop.BorderSizePixel = 0; backdrop.ZIndex = 5100
        local box = G.new("Frame", backdrop)
        box.Size = G.UD2(0, 300, 0, 130); box.Position = G.UD2(0.5, -150, 0.5, -65)
        box.BackgroundColor3 = P.panel; box.BorderSizePixel = 0; box.ZIndex = 5101
        G.mkC(box, 4); G.mkS(box, P.brd, 1, 0)
        G.mkL(box, "BIND KEY", 16, 12, 268, 20, 16, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb).ZIndex = 5102
        G.mkL(box, "press any key · ESC or cancel", 16, 38, 268, 16, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt).ZIndex = 5102
        local cancelBtn = G.new("TextButton", box)
        cancelBtn.Position = G.UD2(0.5, -70, 1, -40); cancelBtn.Size = G.UD2(0, 140, 0, 24)
        cancelBtn.BackgroundColor3 = G.RGB(26, 28, 36); cancelBtn.BorderSizePixel = 0; cancelBtn.AutoButtonColor = false
        cancelBtn.Font = Enum.Font.GothamBold; cancelBtn.TextSize = 14; cancelBtn.TextColor3 = P.tx
        cancelBtn.Text = "CANCEL"; cancelBtn.ZIndex = 5102
        G.mkC(cancelBtn, 3); G.mkS(cancelBtn, P.brd, 1, 0)
        cancelBtn.MouseButton1Click:Connect(function()
            if listening == f then listening = nil end
            local b2 = kbL[f]; if b2 then b2.Text = G.kName(kb[f]) end
            pcall(function() backdrop:Destroy() end)
            G._kbModal = nil
        end)
        if listening then local o = kbL[listening]; if o then o.Text = G.kName(kb[listening]) end end
        listening = f
        local b = kbL[f]; if b then b.Text = "..." end
        G._kbModal = backdrop
    end
    function G.endL(kc)
        if not listening then return end
        local f = listening; listening = nil
        if G._kbModal then pcall(function() G._kbModal:Destroy() end); G._kbModal = nil end
        if kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then kb[f] = nil
        elseif kc ~= Enum.KeyCode.Escape then kb[f] = kc end
        local b = kbL[f]; if b then b.Text = G.kName(kb[f]) end
        if UI.rows and UI.rows[f] and UI.rows[f].chip then pcall(UI.rows[f].chip) end
        pcall(function() if KBHUD and KBHUD.gui then KBHUD.hintDirty() end end)
    end
end



do
    G._hp = nil
    function G.getHP()
        if G._hp and G._hp ~= G.WS and G._hp.Parent then return G._hp end
        local pg = G.LP and (G.LP:FindFirstChildOfClass("PlayerGui") or G.LP:FindFirstChild("PlayerGui"))
        if pg then G._hp = pg; return pg end
        if G.LP then pg = G.LP:WaitForChild("PlayerGui", 15); if pg then G._hp = pg; return pg end end
        if type(gethui) == "function" then local ok, r = pcall(gethui); if ok and r and r.Parent then G._hp = r; return r end end
        local ok, cg = pcall(game.GetService, game, "CoreGui"); if ok and cg and cg.Parent then G._hp = cg; return cg end
        return G.WS
    end
    function G.protG(g) pcall(function() if type(syn) == "table" and syn.protect_gui then syn.protect_gui(g) elseif type(protectgui) == "function" then protectgui(g) end end) end
    function G.myR() local ch = G.LP and G.LP.Character; return ch and ch:FindFirstChild("HumanoidRootPart") end
    function G.myH() local ch = G.LP and G.LP.Character; return ch and ch:FindFirstChildOfClass("Humanoid") end

NOTIF = {gui = nil, box = nil, items = {}, queue = {}}
do
    local W, H, GAP, LIFE = 330, 26, 6, 4
    function NOTIF.guiMk()
        if NOTIF.gui and NOTIF.gui.Parent then return NOTIF.gui end
        local hp = G.getHP()
        local tag = UC.RN .. "_TOAST"
        local sg = hp:FindFirstChild(tag)
        if not sg then
            sg = G.new("ScreenGui")
            sg.Name = tag; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
            sg.DisplayOrder = 900; sg:SetAttribute("KI", true)
            G.protG(sg); sg.Parent = hp
        end
        NOTIF.gui = sg
        if not NOTIF.box or not NOTIF.box.Parent then
            local b = G.new("Frame", sg)
            b.Name = "STACK"
            b.Position = G.UD2(0, 12, 0, 100); b.Size = G.UD2(0, W + 20, 1, -110)
            b.BackgroundTransparency = 1; b.BorderSizePixel = 0
            b.ClipsDescendants = false
            NOTIF.box = b
        end
        return sg
    end
    local function layout()
        for i, f in ipairs(NOTIF.items) do
            if f and f.Parent then
                G.TS:Create(f, G.TI(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = G.UD2(0, 0, 0, (i - 1) * (H + GAP))}):Play()
            end
        end
    end
    function NOTIF.send(t, x, dur, danger)
        G.ti(NOTIF.queue, {t = t, x = x, dur = dur, danger = danger})
        NOTIF.pump()
    end
    function NOTIF.pump()
        if #NOTIF.items >= 6 or #NOTIF.queue == 0 then return end
        local e = table.remove(NOTIF.queue, 1)
        NOTIF.show(e.t, e.x, e.dur, e.danger)
        if #NOTIF.queue > 0 then G.ts(function() G.tw(0.15); NOTIF.pump() end) end
    end
    function NOTIF.show(t, x, dur, danger)
        pcall(function()
            local life = tonumber(dur) or LIFE
            local tc = danger and P.dng or P.amb
            NOTIF.guiMk()
            local f = G.new("Frame", NOTIF.box)
            f.Size = G.UD2(0, W, 0, H); f.Position = G.UD2(0, -(W + 20), 0, #NOTIF.items * (H + GAP))
            f.BackgroundColor3 = P.base; f.BackgroundTransparency = 0.15; f.BorderSizePixel = 0
            G.mkC(f, 3); G.mkS(f, P.brd, 1, 0)
            local st = G.spaced(t)
            local tw = 80
            pcall(function()
                local ts = game:GetService("TextService")
                tw = math.ceil(ts:GetTextSize(st, 12, Enum.Font.Garamond, Vector2.new(500, H)).X) + 14
            end)
            tw = G.mc(tw, 40, 150)
            G.mkL(f, st, 10, 0, tw, H, 12, Enum.Font.Garamond, Enum.TextXAlignment.Left, tc)
            local b = G.mkL(f, x, 10 + tw, 0, W - 20 - tw, H, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.tx)
            b.TextTruncate = Enum.TextTruncate.AtEnd
            local bar = G.new("Frame", f)
            bar.AnchorPoint = G.V2(0, 1); bar.Position = G.UD2(0, 4, 1, -2); bar.Size = G.UD2(1, -8, 0, 1)
            bar.BackgroundColor3 = tc; bar.BorderSizePixel = 0
            G.mkC(bar, 1)
            G.ti(NOTIF.items, f)
            G.TS:Create(f, G.TI(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = G.UD2(0, 0, 0, (#NOTIF.items - 1) * (H + GAP))}):Play()
            G.TS:Create(bar, G.TI(life, Enum.EasingStyle.Linear), {Size = G.UD2(0, 0, 0, 1)}):Play()
            G.ts(function()
                G.tw(life)
                for i, v in ipairs(NOTIF.items) do if v == f then table.remove(NOTIF.items, i); break end end
                pcall(function()
                    G.TS:Create(f, G.TI(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = G.UD2(0, -(W + 20), 0, f.Position.Y.Offset)}):Play()
                    G.tw(0.28)
                    f:Destroy()
                end)
                layout()
                NOTIF.pump()
            end)
        end)
    end
    function NOTIF.wipe()
        for _, f in ipairs(NOTIF.items) do pcall(function() f:Destroy() end) end
        G.tc(NOTIF.items); G.tc(NOTIF.queue)
        pcall(function() if NOTIF.gui then NOTIF.gui:Destroy() end end)
        NOTIF.gui, NOTIF.box = nil, nil
    end
end
    function G.mkC(p, r) G.new("UICorner", p).CornerRadius = G.UD(0, r) end
    function G.mkS(p, c, th, tr) local s = G.new("UIStroke", p); s.Color = c; s.Thickness = th or 1; s.Transparency = tr or 0 end
    
    function G.sheen(par, strength)
        local sh = G.new("Frame", par)
        sh.Name = "SHEEN"
        sh.Size = G.UD2(1, 0, 1, 0); sh.BackgroundColor3 = G.RGB(255, 255, 255)
        sh.BackgroundTransparency = 1; sh.BorderSizePixel = 0
        local g = G.new("UIGradient", sh)
        g.Rotation = 35
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.42, 1),
            NumberSequenceKeypoint.new(0.5, strength or 0.93),
            NumberSequenceKeypoint.new(0.58, 1), NumberSequenceKeypoint.new(1, 1),
        })
        G.mkC(sh, 4)
        sh.Active = false
        return sh
    end
    
    G.fAce, G.fAbbr, G.fName = nil, nil, nil
    pcall(function() G.fAce = FontFace.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.SemiBold) end)
    pcall(function() G.fAbbr = FontFace.new("rbxasset://fonts/families/JosefinSans.json", Enum.FontWeight.Bold) end)
    pcall(function() G.fName = FontFace.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.SemiBold) end)
    pcall(function() G.fDiv = FontFace.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular) end)
    function G.fFace(l, which)
        local f = which == "abbr" and G.fAbbr or (which == "name" and G.fName or G.fAce)
        if f then pcall(function() l.FontFace = f end) end
    end
    
    function G.spaced(s)
        s = string.upper(s or "")
        local out = {}
        for i = 1, #s do out[i] = string.sub(s, i, i) end
        return table.concat(out, " ")
    end
    
    
    function G.mkL(par, txt, x, y, w, h, ts, fnt, ax, col, stroke)
        local l = G.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Font = fnt or Enum.Font.GothamMedium
        local ok = ({[8] = 1, [10] = 1, [11] = 1, [12] = 1, [13] = 1, [14] = 1, [16] = 1, [18] = 1, [20] = 1, [22] = 1, [24] = 1, [26] = 1, [28] = 1, [32] = 1})[ts or 12]
        l.TextSize = ok and (ts or 12) or 12
        l.TextColor3 = col or P.tx
        l.TextXAlignment = ax or Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        l.TextScaled = false
        l.RichText = false
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.TextStrokeTransparency = stroke == true and 0.6 or 1
        l.Text = txt or ""
        l.Position = G.UD2(0, math.floor(x), 0, math.floor(y))
        l.Size = G.UD2(0, math.floor(w), 0, math.floor(h))
        l.Parent = par
        return l
    end
    function G.snap(v) return math.floor(v + 0.5) end
end

local PC = {cache = {}, conns = {}, addC = nil, remC = nil}
do
    function PC.add(p)
        if p == G.LP then return end
        local cs = {}; PC.conns[p] = cs
        local function oc(ch)
            if not ch then PC.cache[p] = nil; return end
            local r = ch:FindFirstChild("HumanoidRootPart"); local h = ch:FindFirstChildOfClass("Humanoid")
            if r and h then PC.cache[p] = {R = r, H = h}
            else G.ts(function() local r2 = ch:WaitForChild("HumanoidRootPart", 5); local h2 = ch:WaitForChild("Humanoid", 5)
                if r2 and h2 and ch.Parent then PC.cache[p] = {R = r2, H = h2} end end) end
        end
        G.ti(cs, p.CharacterAdded:Connect(oc)); G.ti(cs, p.CharacterRemoving:Connect(function() PC.cache[p] = nil end))
        if p.Character then oc(p.Character) end
    end
    function PC.init()
        if PC.addC then PC.addC:Disconnect() end; if PC.remC then PC.remC:Disconnect() end
        for _, cs in pairs(PC.conns) do for _, c in ipairs(cs) do c:Disconnect() end end
        G.tc(PC.conns); G.tc(PC.cache)
        PC.addC = G.Plrs.PlayerAdded:Connect(function(p) PC.add(p); if S.esp and not UI.espF[p] and type(UI.mkEF) == "function" then UI.mkEF(p) end end)
        PC.remC = G.Plrs.PlayerRemoving:Connect(function(p)
            local cs = PC.conns[p]; if cs then for _, c in ipairs(cs) do c:Disconnect() end; PC.conns[p] = nil end
            PC.cache[p] = nil
            if UI.espF then local d = UI.espF[p]; if d then pcall(function() d.Ct:Destroy() end); UI.espF[p] = nil end end
        end)
        for _, p in ipairs(G.Plrs:GetPlayers()) do PC.add(p) end
    end
end


PACKET_PLK = {on = false, stop = nil, cc = nil}
do
    local function run(ch)
        if not ch then return function() end end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum then return function() end end
        local ani = hum:FindFirstChildOfClass("Animator")
        if not ani then ani = G.new("Animator"); ani.Parent = hum end
        local animIds = {
            "rbxassetid://6385078248", "rbxassetid://5053295423", "rbxassetid://11328614766",
            "rbxassetid://9726608174", "rbxassetid://6055558740", "rbxassetid://7968088101",
            "rbxassetid://7599155704", "rbxassetid://9657469282", "rbxassetid://15302935464",
            "rbxassetid://10168663111",
        }
        local trs = {}
        for _, id in ipairs(animIds) do
            pcall(function()
                local a = G.new("Animation"); a.AnimationId = id
                local tr = ani:LoadAnimation(a)
                tr.Priority = Enum.AnimationPriority.Action
                G.ti(trs, tr)
            end)
        end
        if #trs == 0 then return function() end end
        local go = true
        G.ts(function()
            local curIdx, reps, cur = 1, 0, nil
            while go do
                if not ch.Parent then break end
                local mode = CFG.PKTMode or "aggressive"
                local playWt, playSpd, playFade = 0.51, 0.08, 1.0
                local priority = Enum.AnimationPriority.Action
                local waitTime = 0.55 + math.random() * 0.3
                if mode == "passive" then
                    playWt, playSpd, playFade, waitTime = 0.18, 0.06, 1.2, 0.9 + math.random() * 0.5
                elseif mode == "blatant" then
                    playWt, playSpd, playFade, priority, waitTime = 0.65, 0.12, 0.7, Enum.AnimationPriority.Action2, 0.25 + math.random() * 0.15
                end
                pcall(function()
                    if not cur or reps <= 0 then
                        local old = cur
                        curIdx = (curIdx % #trs) + 1; cur = trs[curIdx]; reps = math.random(4, 7)
                        if old and old ~= cur then pcall(function() old:Stop(0.6) end); task.wait(0.05) end
                    end
                    cur.Priority = priority
                    cur:Play(playFade, playWt, playSpd)
                    reps = reps - 1
                end)
                task.wait(waitTime)
            end
        end)
        return function() go = false; for _, t in ipairs(trs) do pcall(function() t:Stop(0.3); t:Destroy() end) end end
    end
    local function att(ch)
        if PACKET_PLK.stop then PACKET_PLK.stop() end; PACKET_PLK.stop = nil
        if not PACKET_PLK.on or not ch then return end
        PACKET_PLK.stop = run(ch)
    end
    function PACKET_PLK:start()
        if self.on then return end; self.on = true
        if not self.cc then self.cc = G.LP.CharacterAdded:Connect(att) end
        G.ts(function() att(G.LP.Character or G.LP.CharacterAdded:Wait()) end)
    end
    function PACKET_PLK:stp()
        if not self.on then return end; self.on = false
        if self.stop then self.stop(); self.stop = nil end
        if self.cc then self.cc:Disconnect(); self.cc = nil end
    end
end


local ESPH = {}
do
    function ESPH.gui(name, order)
        local tag = UC.RN .. name
        local hp = G.getHP()
        local ex = hp:FindFirstChild(tag)
        if ex then return ex end
        local sg = G.new("ScreenGui")
        sg.Name = tag; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        sg.DisplayOrder = order or 100; sg:SetAttribute("KI", true)
        G.protG(sg); sg.Parent = hp
        return sg
    end
    function ESPH.box(ct, color)
        local bx = G.new("Frame", ct)
        bx.BackgroundTransparency = 1; bx.Size = G.UD2(1, 0, 1, 0); bx.BorderSizePixel = 0
        local st = G.new("UIStroke", bx); st.Color = color; st.Thickness = 1.2
        return bx
    end
    function ESPH.proj(cam, pos, up, down)
        local r = cam:WorldToViewportPoint(pos)
        if r.Z <= 0 then return nil end
        local t = cam:WorldToViewportPoint(pos + up); local b = cam:WorldToViewportPoint(pos - down)
        local h = G.mx(b.Y - t.Y, 14); local w = h * 0.55; local cx = (t.X + b.X) * 0.5
        return t.Y, h, w, cx
    end
    function ESPH.hpColor(f)
        return G.C3(G.mc((1 - f) * 2, 0, 1), G.mc(f * 2, 0, 1), 0)
    end
end


local function espEff(rK, fK)
    if S.espGlobal then return CFG.EspRange or 4000, CFG.EspFps or 60 end
    return CFG[rK] or 4000, CFG[fK] or 60
end


local function resolveGameName(p)
    local ch = p and p.Character
    if ch then
        if ch.Name and ch.Name ~= p.Name and ch.Name ~= p.DisplayName then return ch.Name end
        local cn = ch:GetAttribute("CharacterName") or ch:GetAttribute("RPName") or ch:GetAttribute("Name")
        if cn and type(cn) == "string" and #cn > 0 then return cn end
    end
    local pn = p and (p:GetAttribute("CharacterName") or p:GetAttribute("RPName"))
    if pn and type(pn) == "string" and #pn > 0 then return pn end
    return p and p.DisplayName or ""
end


local ESP = {gui = nil, conn = nil, lastTick = 0}
do
    function UI.mkEF(p)
        if UI.espF[p] then return end
        local g = ESPH.gui("_E", 100)
        local ct = G.new("Frame"); ct.BackgroundTransparency = 1; ct.BorderSizePixel = 0; ct.Visible = false; ct.Parent = g
        local bx = ESPH.box(ct, G.RGB(255, 60, 60))
        local hb = G.new("Frame", ct); hb.Size = G.UD2(0, 3, 1, 0); hb.Position = G.UD2(0, -6, 0, 0)
        hb.BackgroundColor3 = G.RGB(8, 8, 8); hb.BorderSizePixel = 0
        local hf = G.new("Frame", hb); hf.BackgroundColor3 = G.RGB(0, 255, 0); hf.BorderSizePixel = 0
        hf.Size = G.UD2(1, 0, 1, 0); hf.AnchorPoint = G.V2(0, 1); hf.Position = G.UD2(0, 0, 1, 0)
        local nl = G.new("TextLabel", ct); nl.BackgroundTransparency = 1; nl.AnchorPoint = G.V2(0.5, 1)
        nl.Position = G.UD2(0.5, 0, 0, -3); nl.Size = G.UD2(3, 0, 0, 14)
        nl.Font = Enum.Font.Gotham; nl.TextSize = 12; nl.TextColor3 = G.RGB(255, 255, 255)
        nl.TextStrokeTransparency = 0.3; nl.Text = S.specRobloxNames and p.Name or resolveGameName(p)
        local dl = G.new("TextLabel", ct); dl.BackgroundTransparency = 1; dl.AnchorPoint = G.V2(0.5, 0)
        dl.Position = G.UD2(0.5, 0, 1, 2); dl.Size = G.UD2(3, 0, 0, 11)
        dl.Font = Enum.Font.Gotham; dl.TextSize = 12; dl.TextColor3 = G.RGB(200, 200, 200); dl.TextStrokeTransparency = 0.4
        local ht = G.new("TextLabel", ct); ht.BackgroundTransparency = 1; ht.AnchorPoint = G.V2(0.5, 0)
        ht.Position = G.UD2(0.5, 0, 1, 11); ht.Size = G.UD2(3, 0, 0, 11)
        ht.Font = Enum.Font.Gotham; ht.TextSize = 12; ht.TextColor3 = G.RGB(255, 255, 255); ht.TextStrokeTransparency = 0.4
        UI.espF[p] = {Ct = ct, HF = hf, DL = dl, BX = bx, HT = ht, NM = nl}
    end
    local function lvlOf(p, h)
        local v = p:GetAttribute("Power") or p:GetAttribute("Level")
            or (h.Parent and (h.Parent:GetAttribute("Power") or h.Parent:GetAttribute("Level")))
        if v == nil then
            local d = p:FindFirstChild("Data") or p:FindFirstChild("leaderstats") or p
            local vv = d and (d:FindFirstChild("Power") or d:FindFirstChild("Level"))
            if vv and (vv:IsA("IntValue") or vv:IsA("NumberValue")) then v = vv.Value end
        end
        return v or "?"
    end
    function ESP.upd()
        local now = G.ck()
        local er, ef = espEff("PlrEspRange", "PlrEspFps")
        if now - ESP.lastTick < 1 / ef then return end
        ESP.lastTick = now
        if not S.esp then for _, d in pairs(UI.espF) do if d.Ct.Visible then d.Ct.Visible = false end end; return end
        local cam = G.WS.CurrentCamera; if not cam then return end
        local mr = G.myR(); if not mr then for _, d in pairs(UI.espF) do if d.Ct.Visible then d.Ct.Visible = false end end; return end
        local mp = mr.Position; local rsq = er * er
        for p, c in pairs(PC.cache) do
            if not UI.espF[p] then UI.mkEF(p) end
            local ed = UI.espF[p]; local show = false
            if ed then
                local r, h = c.R, c.H
                if r and r.Parent and h and h.Parent then
                    local rp = r.Position
                    local dx, dy, dz = rp.X - mp.X, rp.Y - mp.Y, rp.Z - mp.Z
                    if dx * dx + dy * dy + dz * dz <= rsq then
                        local y, sh, sw, cx = ESPH.proj(cam, rp, UC.ETOP, UC.EBOT)
                        if y then
                            ed.Ct.Position = G.UD2(0, cx - sw * 0.5, 0, y); ed.Ct.Size = G.UD2(0, sw, 0, sh)
                            local hp2 = G.mc(h.Health / G.mx(1, h.MaxHealth), 0, 1)
                            ed.HF.Size = G.UD2(1, 0, hp2, 0); ed.HF.BackgroundColor3 = ESPH.hpColor(hp2)
                            pcall(function()
                                ed.HT.Text = math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth)
                                ed.HT.TextColor3 = ESPH.hpColor(hp2)
                            end)
                            if ed.BX then ed.BX.Visible = S.espBox end
                            if ed.HT then ed.HT.Visible = S.htnl end
                            local lv = S.espLvl and (" [Lv." .. tostring(lvlOf(p, h)) .. "]") or ""
                            local hp = S.espHp and (" " .. math.floor(hp2 * 100) .. "%") or ""
                            ed.DL.Text = "[" .. G.mr(G.sq(dx * dx + dy * dy + dz * dz)) .. "m]" .. hp .. lv
                            if ed.NM then ed.NM.Text = S.specRobloxNames and p.Name or resolveGameName(p) end
                            show = true
                        end
                    end
                end
                ed.Ct.Visible = show
            end
        end
    end
    function ESP.start() if ESP.conn then return end; ESPH.gui("_E", 100); ESP.conn = G.RS.Heartbeat:Connect(ESP.upd) end
    function ESP.stop()
        if ESP.conn then ESP.conn:Disconnect(); ESP.conn = nil end
        for _, d in pairs(UI.espF) do pcall(function() d.Ct:Destroy() end) end
        G.tc(UI.espF)
        pcall(function() local hp = G.getHP(); local g = hp:FindFirstChild(UC.RN .. "_E"); if g then g:Destroy() end end)
    end
end


local function prettyName(raw)
    if type(raw) ~= "string" or raw == "" then return raw end
    local s = raw:gsub("[%s%p_]+", " ")
    s = s:gsub("%d+", " ")
    s = s:gsub("(%l)(%u)", "%1 %2")
    s = s:gsub("(%u+)(%u%l)", "%1 %2")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" then return raw end
    return (s:gsub("(%a)(%a*)", function(c, r) return c:upper() .. r end))
end


local MESP = {espF = {}, conn = nil, poser = {}, hpConn = {}, lastHp = {}, burstPerHit = nil, wasArmed = false, popped = false, lastTick = 0}
do
    local function mk(m)
        if MESP.espF[m] then return end
        local g = ESPH.gui("_ME", 101)
        local ct = G.new("Frame"); ct.BackgroundTransparency = 1; ct.BorderSizePixel = 0; ct.Visible = false; ct.Parent = g
        local bx = ESPH.box(ct, G.RGB(255, 100, 0)); bx.Name = "Box"
        local hb = G.new("Frame", ct); hb.Size = G.UD2(0, 3, 1, 0); hb.Position = G.UD2(0, -6, 0, 0)
        hb.BackgroundColor3 = G.RGB(8, 8, 8); hb.BorderSizePixel = 0
        local hf = G.new("Frame", hb); hf.BackgroundColor3 = G.RGB(0, 255, 0); hf.BorderSizePixel = 0
        hf.Size = G.UD2(1, 0, 1, 0); hf.AnchorPoint = G.V2(0, 1); hf.Position = G.UD2(0, 0, 1, 0)
        local dl = G.new("TextLabel", ct); dl.BackgroundTransparency = 1; dl.AnchorPoint = G.V2(0.5, 0)
        dl.Position = G.UD2(0.5, 0, 1, 2); dl.Size = G.UD2(0, 250, 0, 12)
        dl.Font = Enum.Font.Gotham; dl.TextSize = 12; dl.TextColor3 = G.RGB(200, 200, 200); dl.TextStrokeTransparency = 0.4
        local kl = G.new("TextLabel", ct); kl.BackgroundTransparency = 1; kl.AnchorPoint = G.V2(0.5, 0)
        kl.Position = G.UD2(0.5, 0, 1, 14); kl.Size = G.UD2(0, 250, 0, 12)
        kl.Font = Enum.Font.Gotham; kl.TextSize = 12; kl.TextColor3 = G.RGB(255, 220, 50); kl.TextStrokeTransparency = 0.4
        MESP.espF[m] = {Ct = ct, HF = hf, DL = dl, KL = kl, NM = prettyName(m.Name)}
    end
    local function armed()
        local ch = G.LP.Character; if not ch then return false end
        if ch:FindFirstChildOfClass("Tool") then return true end
        local rh = ch:FindFirstChild("RightHand") or ch:FindFirstChild("Right Hand")
        return rh and rh:FindFirstChild("HandWeapon") ~= nil
    end
    function MESP.upd()
        local now = G.ck()
        local er, ef = espEff("MobEspRange", "MobEspFps")
        if MESP.lastTick and now - MESP.lastTick < 1 / ef then return end
        MESP.lastTick = now
        if not S.mobEsp then for _, d in pairs(MESP.espF) do if d.Ct.Visible then d.Ct.Visible = false end end; return end
        local cam = G.WS.CurrentCamera; if not cam then return end
        local mr = G.myR(); if not mr then return end
        local mp = mr.Position; local rsq = er * er
        local hasW = armed()
        if not MESP.wasArmed and hasW then for _, ps in pairs(MESP.poser) do ps.hits, ps.atPop = 0, nil end end
        if MESP.wasArmed and not hasW then
            MESP.popped = true
            for _, ps in pairs(MESP.poser) do if ps.hits and ps.hits > 0 then ps.atPop, ps.hits = ps.hits, 0 end end
            G.ts(function() G.tw(1.2); MESP.popped = false; for _, ps in pairs(MESP.poser) do ps.atPop = nil end end)
        end
        MESP.wasArmed = hasW
        local seen = {}
        local live = G.WS:FindFirstChild("Live") or G.WS
        for _, m in ipairs(live:GetChildren()) do
            if m:IsA("Model") and m ~= G.LP.Character and not G.Plrs:GetPlayerFromCharacter(m) then
                local r = m:FindFirstChild("HumanoidRootPart"); local h = m:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    seen[m] = true
                    if not MESP.espF[m] then mk(m) end
                    local ed = MESP.espF[m]
                    local rp = r.Position
                    local dx, dy, dz = rp.X - mp.X, rp.Y - mp.Y, rp.Z - mp.Z
                    local dsq = dx * dx + dy * dy + dz * dz
                    local show = false
                    if dsq <= rsq then
                        local rs = cam:WorldToViewportPoint(rp)
                        if rs.Z > 0 then
                            local y, sh, sw, cx = ESPH.proj(cam, rp, G.V3(0, 3, 0), G.V3(0, 3.5, 0))
                            ed.Ct.Position = G.UD2(0, cx - sw * 0.5, 0, y); ed.Ct.Size = G.UD2(0, sw, 0, sh)
                            local hp2 = G.mc(h.Health / G.mx(1, h.MaxHealth), 0, 1)
                            ed.HF.Size = G.UD2(1, 0, hp2, 0); ed.HF.BackgroundColor3 = ESPH.hpColor(hp2)
                            if not MESP.poser[m] then MESP.poser[m] = {hits = 0} end
                            if not MESP.hpConn[m] then
                                MESP.lastHp[m] = h.Health
                                MESP.hpConn[m] = h:GetPropertyChangedSignal("Health"):Connect(function()
                                    pcall(function()
                                        local cur, old = h.Health, MESP.lastHp[m] or h.Health
                                        local ps = MESP.poser[m]
                                        if cur <= 0 or cur > old then if ps then ps.hits, ps.atPop = 0, nil end
                                        elseif cur < old and ps then
                                            local drop = old - cur
                                            local n = (ps.hits and ps.hits > 0 and ps.hits) or ps.atPop
                                            if MESP.popped and n and n > 0 then
                                                MESP.burstPerHit, MESP.popped = drop / n, false
                                                ps.hits, ps.atPop = 0, nil
                                            elseif armed() then
                                                local ch = G.LP.Character
                                                local rt = ch and ch:FindFirstChild("HumanoidRootPart")
                                                local er = m:FindFirstChild("HumanoidRootPart")
                                                if rt and er and (er.Position - rt.Position).Magnitude < 22 then ps.hits = (ps.hits or 0) + 1 end
                                            end
                                        end
                                        MESP.lastHp[m] = cur
                                    end)
                                end)
                            end
                            local ps = MESP.poser[m]
                            local disp = ps.hits or 0
                            local burst = disp == 0 and ps.atPop and ps.atPop > 0
                            if burst then disp = ps.atPop end
                            local cal = MESP.burstPerHit ~= nil
                            local pred, kill = 0, false
                            if disp > 0 and cal then pred = math.floor(MESP.burstPerHit * disp); kill = pred >= math.floor(h.Health) end
                            local stroke = ed.Ct:FindFirstChild("Box") and ed.Ct.Box:FindFirstChildOfClass("UIStroke")
                            if stroke then stroke.Color = kill and G.RGB(0, 255, 80) or G.RGB(255, 100, 0) end
                            ed.DL.Text = ed.NM .. " [" .. G.mr(G.sq(dsq)) .. "m] " .. math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth) .. " HP"
                            if disp > 0 then
                                if cal then
                                    ed.KL.Text = (burst and "Poser (POP!): " or "Poser: ") .. pred .. " dmg | " .. disp .. " hits " .. (kill and "| KILL" or "| NO")
                                    ed.KL.TextColor3 = kill and G.RGB(0, 255, 80) or G.RGB(255, 80, 80)
                                else
                                    ed.KL.Text = (burst and "Poser (POP!): " or "Poser: ") .. disp .. " hits | pop once to calibrate"
                                    ed.KL.TextColor3 = G.RGB(255, 220, 50)
                                end
                            else
                                ed.KL.Text = cal and ("Calibrated: " .. math.floor(MESP.burstPerHit) .. " burst/hit") or ""
                            end
                            show = true
                        end
                    end
                    ed.Ct.Visible = show
                end
            end
        end
        for m, ed in pairs(MESP.espF) do
            if not seen[m] or not m.Parent then
                pcall(function() ed.Ct:Destroy() end); MESP.espF[m] = nil
                if MESP.hpConn[m] then MESP.hpConn[m]:Disconnect(); MESP.hpConn[m] = nil end
                MESP.lastHp[m], MESP.poser[m] = nil, nil
            end
        end
    end
    function MESP.start() if MESP.conn then return end; ESPH.gui("_ME", 101); MESP.conn = G.RS.Heartbeat:Connect(MESP.upd) end
    function MESP.stop()
        if MESP.conn then MESP.conn:Disconnect(); MESP.conn = nil end
        for _, c in pairs(MESP.hpConn) do pcall(function() c:Disconnect() end) end
        G.tc(MESP.hpConn); G.tc(MESP.lastHp)
        for _, d in pairs(MESP.espF) do pcall(function() d.Ct:Destroy() end) end
        G.tc(MESP.espF)
        pcall(function() local hp = G.getHP(); local g = hp:FindFirstChild(UC.RN .. "_ME"); if g then g:Destroy() end end)
    end
end


local NESP = {espF = {}, conn = nil, lastTick = 0}
do
    local function mk(n)
        if NESP.espF[n] then return end
        local g = ESPH.gui("_NE", 101)
        local ct = G.new("Frame"); ct.BackgroundTransparency = 1; ct.BorderSizePixel = 0; ct.Visible = false; ct.Parent = g
        local bx = ESPH.box(ct, G.RGB(100, 200, 255)); bx.Name = "Box"
        local dl = G.new("TextLabel", ct); dl.BackgroundTransparency = 1; dl.AnchorPoint = G.V2(0.5, 0)
        dl.Position = G.UD2(0.5, 0, 1, 2); dl.Size = G.UD2(0, 250, 0, 12)
        dl.Font = Enum.Font.Gotham; dl.TextSize = 12; dl.TextColor3 = G.RGB(100, 200, 255); dl.TextStrokeTransparency = 0.4
        NESP.espF[n] = {Ct = ct, DL = dl}
    end
    function NESP.upd()
        local now = G.ck()
        local er, ef = espEff("NpcEspRange", "NpcEspFps")
        if NESP.lastTick and now - NESP.lastTick < 1 / ef then return end
        NESP.lastTick = now
        if not S.nEsp then for _, d in pairs(NESP.espF) do if d.Ct.Visible then d.Ct.Visible = false end end; return end
        pcall(function()
            local cam = G.WS.CurrentCamera; if not cam then return end
            local mr = G.myR(); if not mr then return end
            local mp = mr.Position; local rsq = er * er
            local seen = {}
            local fol = G.WS:FindFirstChild("NPCs"); if not fol then return end
            for _, n in ipairs(fol:GetChildren()) do
                if n:IsA("Model") then
                    local r = n:FindFirstChild("HumanoidRootPart"); local h = n:FindFirstChildOfClass("Humanoid")
                    if r and h and h.Health > 0 then
                        seen[n] = true
                        if not NESP.espF[n] then mk(n) end
                        local ed = NESP.espF[n]
                        local rp = r.Position
                        local dx, dy, dz = rp.X - mp.X, rp.Y - mp.Y, rp.Z - mp.Z
                        local show = false
                        if dx * dx + dy * dy + dz * dz <= rsq then
                            local rs = cam:WorldToViewportPoint(rp)
                            if rs.Z > 0 then
                                local y, sh, sw, cx = ESPH.proj(cam, rp, G.V3(0, 3, 0), G.V3(0, 3.5, 0))
                                ed.Ct.Position = G.UD2(0, cx - sw * 0.5, 0, y); ed.Ct.Size = G.UD2(0, sw, 0, sh)
                                ed.DL.Text = n.Name .. " [" .. G.mr(G.sq(dx * dx + dy * dy + dz * dz)) .. "m]"
                                show = true
                            end
                        end
                        ed.Ct.Visible = show
                    end
                end
            end
            for n, ed in pairs(NESP.espF) do if not seen[n] or not n.Parent then pcall(function() ed.Ct:Destroy() end); NESP.espF[n] = nil end end
        end)
    end
    function NESP.start() if NESP.conn then return end; ESPH.gui("_NE", 101); NESP.conn = G.RS.Heartbeat:Connect(NESP.upd) end
    function NESP.stop()
        if NESP.conn then NESP.conn:Disconnect(); NESP.conn = nil end
        for _, d in pairs(NESP.espF) do pcall(function() d.Ct:Destroy() end) end
        G.tc(NESP.espF)
        pcall(function() local hp = G.getHP(); local g = hp:FindFirstChild(UC.RN .. "_NE"); if g then g:Destroy() end end)
    end
end


local CESP = {espF = {}, conn = nil, lastTick = 0}
do
    local function mk(c)
        if CESP.espF[c] then return end
        local g = ESPH.gui("_CE", 101)
        local ct = G.new("Frame"); ct.BackgroundTransparency = 1; ct.BorderSizePixel = 0; ct.Visible = false; ct.Parent = g
        local bx = ESPH.box(ct, G.RGB(255, 249, 161)); bx.Name = "Box"; bx.Size = G.UD2(1, 0, 0.5, 0)
        local dl = G.new("TextLabel", ct); dl.BackgroundTransparency = 1; dl.AnchorPoint = G.V2(0.5, 0)
        dl.Position = G.UD2(0.5, 0, 0.5, 2); dl.Size = G.UD2(0, 250, 0, 12)
        dl.Font = Enum.Font.Gotham; dl.TextSize = 12; dl.TextColor3 = G.RGB(255, 249, 161); dl.TextStrokeTransparency = 0.4
        CESP.espF[c] = {Ct = ct, DL = dl}
    end
    function CESP.upd()
        local now = G.ck()
        local er, ef = espEff("ChestEspRange", "ChestEspFps")
        if CESP.lastTick and now - CESP.lastTick < 1 / ef then return end
        CESP.lastTick = now
        if not S.cEsp then for _, d in pairs(CESP.espF) do if d.Ct.Visible then d.Ct.Visible = false end end; return end
        pcall(function()
            local cam = G.WS.CurrentCamera; if not cam then return end
            local mr = G.myR(); if not mr then return end
            local mp = mr.Position; local rsq = er * er
            local seen = {}
            local function one(c)
                if not c:IsA("Model") then return end
                local r = c:FindFirstChild("RootPart"); if not r then return end
                seen[c] = true
                if not CESP.espF[c] then mk(c) end
                local ed = CESP.espF[c]
                local rp = r.Position
                local dx, dy, dz = rp.X - mp.X, rp.Y - mp.Y, rp.Z - mp.Z
                local show = false
                if dx * dx + dy * dy + dz * dz <= rsq then
                    local rs = cam:WorldToViewportPoint(rp)
                    if rs.Z > 0 then
                        local y, sh, sw, cx = ESPH.proj(cam, rp, G.V3(0, 2, 0), G.V3(0, 2, 0))
                        ed.Ct.Position = G.UD2(0, cx - sw * 0.5, 0, y); ed.Ct.Size = G.UD2(0, sw, 0, sh)
                        ed.DL.Text = "Chest [" .. G.mr(G.sq(dx * dx + dy * dy + dz * dz)) .. "m]"
                        show = true
                    end
                end
                ed.Ct.Visible = show
            end
            local cf = G.WS:FindFirstChild("Chests"); if cf then for _, c in ipairs(cf:GetChildren()) do one(c) end end
            local tf = G.WS:FindFirstChild("Thrown"); if tf then for _, c in ipairs(tf:GetChildren()) do one(c) end end
            for c, ed in pairs(CESP.espF) do if not seen[c] or not c.Parent then pcall(function() ed.Ct:Destroy() end); CESP.espF[c] = nil end end
        end)
    end
    function CESP.start() if CESP.conn then return end; ESPH.gui("_CE", 101); CESP.conn = G.RS.Heartbeat:Connect(CESP.upd) end
    function CESP.stop()
        if CESP.conn then CESP.conn:Disconnect(); CESP.conn = nil end
        for _, d in pairs(CESP.espF) do pcall(function() d.Ct:Destroy() end) end
        G.tc(CESP.espF)
        pcall(function() local hp = G.getHP(); local g = hp:FindFirstChild(UC.RN .. "_CE"); if g then g:Destroy() end end)
    end
end


local AUTOLOOT = {conn = nil, listener = nil, last = 0}
do
    local COOL = 0.15
    local function loot(prompt)
        if not S.autoloot then return false end
        local cf = prompt:FindFirstChild("ChoiceFrame"); if not cf then return false end
        if not cf:FindFirstChild("Options") then return false end
        if G.ck() - AUTOLOOT.last < COOL then return false end
        local remote = prompt:FindFirstChild("Choice")
        if not remote or not remote:IsA("RemoteEvent") then return false end
        AUTOLOOT.last = G.ck()
        pcall(function() remote:FireServer("LOOT_ALL") end)
        return true
    end
    local function onPrompt(p) if p:FindFirstChild("Choice") then loot(p) end end
    function AUTOLOOT.start()
        if AUTOLOOT.conn then return end
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui"); if not pg then return end
        AUTOLOOT.listener = pg.DescendantAdded:Connect(function(ch) if ch.Name == "ChoicePrompt" then onPrompt(ch) end end)
        for _, ch in ipairs(pg:GetDescendants()) do if ch.Name == "ChoicePrompt" and ch:FindFirstChild("Choice") then onPrompt(ch); break end end
        AUTOLOOT.conn = AUTOLOOT.listener
        NOTIF.send("Auto Loot", "Started")
    end
    function AUTOLOOT.stop()
        if AUTOLOOT.listener then AUTOLOOT.listener:Disconnect(); AUTOLOOT.listener = nil end
        AUTOLOOT.conn = nil
    end
end


local MODD = {on = false, seen = {}, checked = {}, told = {}, lastTell = {}}
do
    function MODD.start()
        if MODD.on then return end; MODD.on = true
        G.ts(function()
            while MODD.on do
                if not S.modDetector then break end
                for _, p in pairs(G.Plrs:GetPlayers()) do
                    if p ~= G.LP and not MODD.checked[p] then
                        pcall(function()
                            if G.httpReq then
                                local r = G.httpReq({Url = "https://groups.roblox.com/v2/users/" .. p.UserId .. "/groups/roles", Method = "GET"})
                                if r and r.Body then
                                    local d = G.HS:JSONDecode(r.Body)
                                    for _, g in pairs(d.data or {}) do
                                        if g.group.id == 5212858 and g.role.rank > 0 then MODD.seen[p] = g.role.name; break end
                                    end
                                    MODD.checked[p] = true
                                end
                            end
                        end)
                    end
                end
                for p, role in pairs(MODD.seen) do
                    if p and p.Parent then
                        local now = G.ck()
                        local due = not MODD.told[p] or (S.modRepeat and now - (MODD.lastTell[p] or 0) > 20)
                        if due then
                            MODD.told[p], MODD.lastTell[p] = true, now
                            NOTIF.send("MOD DETECTED", p.Name .. " · " .. role, 20, true)
                            if S.modSound then
                                pcall(function()
                                    local s = G.new("Sound", G.getHP())
                                    s.SoundId = "rbxassetid://1005211806"; s.Volume = 0.5
                                    s:Play()
                                    G.ts(function() G.tw(3); pcall(function() s:Destroy() end) end)
                                end)
                            end
                        end
                    end
                end
                G.tw(3)
            end
        end)
    end
    function MODD.stop() MODD.on = false; MODD.seen, MODD.checked, MODD.told, MODD.lastTell = {}, {}, {}, {} end
end




local function specGetName(p)
    if S.specRobloxNames then return p.Name end
    return resolveGameName(p)
end


local SPEC = {gui = nil, frm = nil, lst = nil, cur = nil, conn = nil, thread = nil, closeBtn = nil}
do
    function SPEC.mk()
        if SPEC.gui and SPEC.gui.Parent then return end
        SPEC.gui = G.new("ScreenGui"); SPEC.gui.Name = UC.RN .. "_SPEC"
        SPEC.gui.ResetOnSpawn = false; SPEC.gui.IgnoreGuiInset = true; SPEC.gui.DisplayOrder = 200
        SPEC.gui:SetAttribute("KI", true); G.protG(SPEC.gui); SPEC.gui.Parent = G.getHP()
        local f = G.new("Frame", SPEC.gui)
        f.AnchorPoint = G.V2(1, 0.5); f.Position = G.UD2(1, -24, 0.5, 0)
        f.Size = G.UD2(0, 240, 0, 360)
        f.BackgroundColor3 = P.base; f.BorderSizePixel = 0
        f.Active = true
        G.mkC(f, 3); G.mkS(f, P.brd, 1, 0)
        SPEC.frm = f
        local dg, ds, fp = false, nil, nil
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dg, ds, fp = true, i.Position, f.Position
            end
        end)
        f.InputChanged:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - ds
                f.Position = G.UD2(fp.X.Scale, fp.X.Offset + d.X, fp.Y.Scale, fp.Y.Offset + d.Y)
            end
        end)
        f.InputEnded:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                dg = false
            end
        end)
        local hdr = G.new("Frame", f)
        hdr.Name = "HDR"
        hdr.Size = G.UD2(1, 0, 0, 32); hdr.BackgroundColor3 = P.panel; hdr.BorderSizePixel = 0
        G.mkC(hdr, 3)
        local accent = G.new("Frame", hdr)
        accent.Size = G.UD2(0, 3, 0, 14); accent.Position = G.UD2(0, 12, 0.5, -7)
        accent.BackgroundColor3 = P.amb; accent.BorderSizePixel = 0; G.mkC(accent, 2)
        G.mkL(hdr, "SPECTATOR", 24, 0, 140, 32, 12, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb)
        local close = G.new("TextButton", hdr)
        close.Name = "Close"
        close.Size = G.UD2(0, 22, 0, 22); close.Position = G.UD2(1, -28, 0.5, -11)
        close.BackgroundTransparency = 1; close.BorderSizePixel = 0; close.AutoButtonColor = false
        close.Font = Enum.Font.GothamBold; close.TextSize = 14
        close.TextColor3 = P.mt
        close.Text = "X"
        close.MouseEnter:Connect(function() close.TextColor3 = P.dng end)
        close.MouseLeave:Connect(function() close.TextColor3 = P.mt end)
        close.MouseButton1Click:Connect(function()
            if S.spec then S.spec = false; pcall(UI.updTog) end
            SPEC.tog()
        end)
        SPEC.closeBtn = close
        local sep = G.new("Frame", f)
        sep.Name = "SEP"
        sep.Size = G.UD2(1, -24, 0, 1); sep.Position = G.UD2(0, 12, 0, 36)
        sep.BackgroundColor3 = P.brd; sep.BorderSizePixel = 0
        local s = G.new("ScrollingFrame", f)
        s.Name = "LIST"
        s.Position = G.UD2(0, 8, 0, 44); s.Size = G.UD2(1, -16, 1, -52)
        s.BackgroundTransparency = 1; s.BorderSizePixel = 0; s.ScrollBarThickness = 3
        s.ScrollBarImageColor3 = P.brd; s.CanvasSize = G.UD2(0, 0, 0, 0)
        s.AutomaticCanvasSize = Enum.AutomaticSize.None
        local lay = G.new("UIListLayout", s); lay.SortOrder = Enum.SortOrder.LayoutOrder; lay.Padding = G.UD(0, 4)
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            s.CanvasSize = G.UD2(0, 0, 0, lay.AbsoluteContentSize.Y + 4)
        end)
        SPEC.lst = s
        SPEC.conn = G.RS.Heartbeat:Connect(function()
            if not SPEC.cur then return end
            if SPEC.cur.Character then
                local hum = SPEC.cur.Character:FindFirstChildOfClass("Humanoid")
                local cam = G.WS.CurrentCamera
                if hum and cam and cam.CameraSubject ~= hum then pcall(function() cam.CameraSubject = hum end) end
            end
        end)
        SPEC.thread = G.ts(function() while S.spec and SPEC.conn do SPEC.upd(); G.tw(2.5) end end)
    end
    function SPEC.upd()
        if not SPEC.frm or not SPEC.lst then return end
        for _, c in ipairs(SPEC.lst:GetChildren()) do
            if c:IsA("GuiObject") and c.Name ~= "Close" then pcall(function() c:Destroy() end) end
        end
        if SPEC.closeBtn and SPEC.closeBtn.Parent == nil then
            pcall(function() SPEC.closeBtn.Parent = SPEC.frm:FindFirstChild("HDR") end)
        end
        local order = 0
        for _, p in ipairs(G.Plrs:GetPlayers()) do
            if p ~= G.LP then
                order = order + 1
                local pf = G.new("TextButton", SPEC.lst)
                pf.Name = "P_" .. p.UserId
                pf.Size = G.UD2(1, 0, 0, 28); pf.LayoutOrder = order
                pf.BackgroundColor3 = (SPEC.cur == p) and P.panel or P.base
                pf.BorderSizePixel = 0; pf.AutoButtonColor = false
                pf.Text = ""
                G.mkC(pf, 3); G.mkS(pf, P.brd, 1, 0)
                local pl = G.mkL(pf, specGetName(p), 10, 0, 130, 28, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left,
                    (SPEC.cur == p) and P.amb or P.tx)
                local tag = G.mkL(pf, "VIEW", 0, 0, 40, 28, 12, Enum.Font.GothamBold, Enum.TextXAlignment.Right, P.mt)
                tag.Position = G.UD2(1, -50, 0, 0)
                pf.MouseButton1Click:Connect(function()
                    SPEC.cur = p
                    local cam = G.WS.CurrentCamera
                    if cam then
                        cam.CameraType = Enum.CameraType.Custom
                        if p.Character then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hum then pcall(function() cam.CameraSubject = hum end) end
                        end
                    end
                    SPEC.upd()
                end)
            end
        end
    end
    function SPEC.tog()
        if not SPEC.gui or not SPEC.gui.Parent then SPEC.gui = nil; SPEC.mk() end
        if not SPEC.frm then return end
        SPEC.frm.Visible = S.spec
        if S.spec then
            SPEC.upd()
            if not SPEC.thread or coroutine.status(SPEC.thread) == "dead" then
                SPEC.thread = G.ts(function() while S.spec and SPEC.conn do SPEC.upd(); G.tw(2.5) end end)
            end
        else
            SPEC.cur = nil
            SPEC.thread = nil
            local cam = G.WS.CurrentCamera
            if cam then
                cam.CameraType = Enum.CameraType.Custom
                local hum = G.myH(); if hum then pcall(function() cam.CameraSubject = hum end) end
            end
        end
    end
end


local AGIL = {conn = nil, gcH = {}, oA = {}, oV = {}, oSpd = 16, snapChar = nil}
do
    function AGIL.snap()
        AGIL.oA, AGIL.oV = {}, {}
        local ch = G.LP and G.LP.Character; if not ch then return end
        local h = ch:FindFirstChildOfClass("Humanoid"); if h then AGIL.oSpd = h.WalkSpeed end
        pcall(function() for _, d in ipairs(ch:GetDescendants()) do
            for k, v in pairs(d:GetAttributes()) do local kl = string.lower(k)
                if string.find(kl, "agil", 1, true) or string.find(kl, "passive", 1, true) then G.ti(AGIL.oA, {o = d, k = k, v = v}) end end
            if d:IsA("ValueBase") then local nl = string.lower(d.Name)
                if string.find(nl, "agil", 1, true) or string.find(nl, "passive", 1, true) then G.ti(AGIL.oV, {o = d, v = d.Value}) end end end end)
    end
    function AGIL.restore()
        for _, e in ipairs(AGIL.oA) do pcall(function() if e.o and e.o.Parent then e.o:SetAttribute(e.k, e.v) end end) end
        for _, e in ipairs(AGIL.oV) do pcall(function() if e.o and e.o.Parent then e.o.Value = e.v end end) end
        for _, h in ipairs(AGIL.gcH) do pcall(function() h.o[h.k] = h.v end) end
    end
    function AGIL.en()
        if AGIL.conn then return end
        AGIL.gcH = {}
        if type(getgc) == "function" then
            pcall(function()
                for _, o in ipairs(getgc(true)) do
                    if type(o) == "table" then
                        for k, v in pairs(o) do
                            if type(k) == "string" and type(v) == "number" then
                                local kl = string.lower(k)
                                if string.find(kl, "agil", 1, true) or string.find(kl, "passive", 1, true) then
                                    G.ti(AGIL.gcH, {o = o, k = k, v = v})
                                end
                            end
                        end
                    end
                end
            end)
        end
        AGIL.snapChar = nil
        local cachedEFR; pcall(function() cachedEFR = require(G.RepS:WaitForChild("EffectReplicator", 5)) end)
        local tick = 0
        AGIL.conn = G.RS.Heartbeat:Connect(function(dt)
            local ch = G.LP and G.LP.Character
            if not ch then AGIL.snapChar = nil; return end
            if S.agil then
                if AGIL.snapChar ~= ch then AGIL.snap(); AGIL.snapChar = ch end
                local val = CFG.AgilVal
                pcall(function() for _, d in ipairs(ch:GetDescendants()) do
                    for k in pairs(d:GetAttributes()) do local kl = string.lower(k)
                        if string.find(kl, "agil", 1, true) or string.find(kl, "passive", 1, true) then d:SetAttribute(k, val) end end
                    if d:IsA("ValueBase") then local nl = string.lower(d.Name)
                        if string.find(nl, "agil", 1, true) or string.find(nl, "passive", 1, true) then d.Value = val end end end end)
                for _, h in ipairs(AGIL.gcH) do pcall(function() h.o[h.k] = val end) end
            elseif AGIL.snapChar then AGIL.restore(); AGIL.snapChar = nil end
            if S.agSpd and not S.fly then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                local knocked = false
                pcall(function() if NC and NC.ER then knocked = NC.ER:HasEffect("Knocked") end end)
                if hum and hrp and CFG.SpdVal and CFG.SpdVal > 0 and not knocked
                    and not hum.Sit and hum.WalkSpeed > 0 and not hrp.Anchored then
                    local seated = (hum:GetState() == Enum.HumanoidStateType.Seated)
                    local onBoat = false
                    pcall(function()
                        for _, w in ipairs(hrp:GetChildren()) do
                            if w:IsA("WeldConstraint") and w.Part0 and w.Part0.Parent and w.Part0.Parent ~= ch then
                                onBoat = true
                            end
                        end
                    end)
                    if not seated and not onBoat then
                        local md = hum.MoveDirection
                        if md.Magnitude > 0.001 then
                            local nudge = md.Unit * CFG.SpdVal * (hum.WalkSpeed / 16) * dt
                            hrp.CFrame = hrp.CFrame + G.V3(nudge.X, 0, nudge.Z)
                        end
                    end
                end
            end
            if S.agil or S.agSpd then
                tick = tick + 1
                if tick >= 30 and cachedEFR then
                    tick = 0
                    pcall(function()
                        if cachedEFR.Effects then
                            for _, ef in pairs(cachedEFR.Effects) do
                                if ef.Class == "SpeedOverride" and ef.Value < 14 then rawset(ef, "Value", 14)
                                elseif ef.Class == "Speed" and ef.Value < 0 then rawset(ef, "Value", 0) end
                            end
                        end
                    end)
                end
            end
        end)
    end
    function AGIL.dis()
        if AGIL.conn then AGIL.conn:Disconnect(); AGIL.conn = nil end
        AGIL.restore()
        local hum = G.myH(); if hum then hum.WalkSpeed = AGIL.oSpd end
        AGIL.oA, AGIL.oV, AGIL.gcH, AGIL.snapChar = {}, {}, {}, nil
    end
end


local NC = {conn = nil, preConn = nil, orig = {}, ER = nil, safe = false}
do
    pcall(function() NC.ER = require(G.RepS:WaitForChild("EffectReplicator", 10)) end)
    local function restore() for p, v in pairs(NC.orig) do pcall(function() if p and p.Parent then p.CanCollide = v end end) end; G.tc(NC.orig) end
    local function knocked()
        if not NC.ER then return false end
        local ok, r = pcall(function() return NC.ER:HasEffect("Knocked") end)
        return ok and r
    end
    local function sweep(c)
        if not c then return end
        for _, p in ipairs(c:QueryDescendants("BasePart[CanCollide = true]")) do
            if NC.orig[p] == nil then NC.orig[p] = p.CanCollide end
            p.CanCollide = false
        end
    end
    function NC.en()
        if NC.conn then return end
        NC.orig, NC.safe = {}, false
        NC.conn = G.RS.Stepped:Connect(function()
            local c = G.LP and G.LP.Character; if not c then return end
            if knocked() then if next(NC.orig) then restore() end; return end
            if NC.ER and not NC.safe then
                pcall(function() if not NC.ER:FindEffect("TPSafe") then NC.ER:CreateEffect("TPSafe") end end)
                NC.safe = true
            end
            sweep(c)
        end)
        NC.preConn = G.RS.PreRender:Connect(function()
            if knocked() then return end
            local c = G.LP and G.LP.Character; if c then sweep(c) end
        end)
    end
    function NC.dis()
        if NC.conn then NC.conn:Disconnect(); NC.conn = nil end
        if NC.preConn then NC.preConn:Disconnect(); NC.preConn = nil end
        if NC.ER then for _, m in ipairs({"RemoveEffect", "DestroyEffect", "DeleteEffect", "StopEffect", "ClearEffect"}) do
            if type(NC.ER[m]) == "function" then pcall(NC.ER[m], NC.ER, "TPSafe") end end end
        restore(); NC.safe = false
    end
end


local NFD = {cc = nil, stConn = nil, velConn = nil, active = false, oldFx = nil, fx = nil}
do
    function NFD.en()
        if NFD.active then return end; NFD.active = true
        pcall(function()
            if not NFD.fx then NFD.fx = require(G.RepS:WaitForChild("EffectReplicator", 5)) end
            if NFD.fx and not NFD.oldFx then
                NFD.oldFx = NFD.fx.HasEffect
                NFD.fx.HasEffect = function(self, name, ...)
                    if NFD.active and (name == "NoFall" or name == "FallDamage" or name == "Fall") then return true end
                    return NFD.oldFx(self, name, ...)
                end
            end
        end)
        local function hook(ch)
            if NFD.stConn then NFD.stConn:Disconnect(); NFD.stConn = nil end
            if NFD.velConn then NFD.velConn:Disconnect(); NFD.velConn = nil end
            if not ch then return end
            local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
            NFD.stConn = hum.StateChanged:Connect(function(_, new)
                if not NFD.active then return end
                if new == Enum.HumanoidStateType.FallingDown then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Landing) end)
                elseif new == Enum.HumanoidStateType.Landed then pcall(function()
                    local root = ch:FindFirstChild("HumanoidRootPart")
                    if root then root.Velocity = G.V3(root.Velocity.X, 0, root.Velocity.Z) end
                end) end
            end)
            local root = ch:FindFirstChild("HumanoidRootPart")
            if root then
                NFD.velConn = G.RS.Heartbeat:Connect(function()
                    if not NFD.active then return end
                    pcall(function()
                        if hum:GetState() == Enum.HumanoidStateType.Freefall and root.Velocity.Y < -120 then
                            root.Velocity = G.V3(root.Velocity.X, -120, root.Velocity.Z)
                        end
                    end)
                end)
            end
        end
        local ch = G.LP and G.LP.Character; if ch then hook(ch) end
        if not NFD.cc then NFD.cc = G.LP.CharacterAdded:Connect(function(c) G.tw(0.3); if NFD.active then hook(c) end end) end
    end
    function NFD.dis()
        NFD.active = false
        if NFD.stConn then NFD.stConn:Disconnect(); NFD.stConn = nil end
        if NFD.velConn then NFD.velConn:Disconnect(); NFD.velConn = nil end
        pcall(function()
            local ch = G.LP and G.LP.Character
            if ch then local hum = ch:FindFirstChildOfClass("Humanoid"); if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end end
        end)
        pcall(function() if NFD.oldFx and NFD.fx then NFD.fx.HasEffect = NFD.oldFx; NFD.oldFx = nil end end)
    end
end


local FLY = {active = false, conn = nil, cc = nil}
do
    function FLY.clr() if FLY.conn then FLY.conn:Disconnect(); FLY.conn = nil end end
    function FLY.en()
        if FLY.active then return end; FLY.active, S.fly = true, true
        local function setup(ch)
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            FLY.clr()
            FLY.conn = G.RS.Heartbeat:Connect(function(dt)
                if not FLY.active or not hrp or not hrp.Parent then return end
                local cam = G.WS.CurrentCamera; if not cam then return end
                local dir = Vector3.zero; local cf = cam.CFrame
                if G.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
                if G.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
                if G.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
                if G.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
                if G.UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + G.V3(0, 1, 0) end
                if G.UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - G.V3(0, 1, 0) end
                pcall(function() hrp.Velocity = G.V3(hrp.Velocity.X, 0, hrp.Velocity.Z) end)
                if dir.Magnitude > 0 then
                    local sp = G.mc(CFG.FlySpeed or 80, 10, 150)
                    hrp.CFrame = hrp.CFrame + dir.Unit * sp * dt
                end
                if hum and hum.Parent then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end) end
            end)
        end
        local ch = G.LP and G.LP.Character; if ch then setup(ch) end
        FLY.cc = G.LP.CharacterAdded:Connect(function(c) G.tw(0.5); if FLY.active then setup(c) end end)
        NOTIF.send("Fly", "Enabled · WASD + Space/Shift")
    end
    function FLY.dis()
        FLY.active, S.fly = false, false
        FLY.clr()
        if FLY.cc then FLY.cc:Disconnect(); FLY.cc = nil end
        NOTIF.send("Fly", "Disabled")
    end
end


local ASPD = {conn = nil, cc = nil}
do
    function ASPD.en()
        if ASPD.conn then return end
        local function hook(ch)
            if ASPD.conn then ASPD.conn:Disconnect(); ASPD.conn = nil end
            if not ch then return end
            local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local ani = hum:FindFirstChildOfClass("Animator"); if not ani then return end
            ASPD.conn = ani.AnimationPlayed:Connect(function(tr)
                if not S.aSpd then return end
                local pr = tr.Priority
                if pr == Enum.AnimationPriority.Action or pr == Enum.AnimationPriority.Movement then
                    pcall(function() tr:AdjustSpeed(CFG.ASpdVal or 1.5) end)
                elseif S.mSpd and (pr == Enum.AnimationPriority.Action2 or pr == Enum.AnimationPriority.Action3 or pr == Enum.AnimationPriority.Action4) then
                    pcall(function() tr:AdjustSpeed(CFG.MSpdVal or 1.5) end)
                end
            end)
        end
        hook(G.LP and G.LP.Character)
        if not ASPD.cc then ASPD.cc = G.LP.CharacterAdded:Connect(function(ch) G.tw(0.3); if S.aSpd then hook(ch) end end) end
    end
    function ASPD.dis() if ASPD.conn then ASPD.conn:Disconnect(); ASPD.conn = nil end end
end


local NOVIS = {conn = nil, bindName = "ArchiveNoFog", conns = {}, _last = 0}
do
    local L = game:GetService("Lighting")
    local function apply()
        if not S.noVis then return end
        pcall(function()
            L.FogStart = 9e9
            L.FogEnd = 9e9
            L.GlobalShadows = false
            local at = L:FindFirstChildOfClass("Atmosphere"); if at then at.Density = 0 end
            local gb = L:FindFirstChild("GenericBlur"); if gb then gb.Enabled = false end
            local ub = L:FindFirstChild("UnderwaterBlur"); if ub then ub.Enabled = false end
        end)
    end
    function NOVIS.en()
        if NOVIS.conn then return end
        NOVIS.conn = G.RS.RenderStepped:Connect(function()
            if not S.noVis then return end
            local now = G.ck(); if now - NOVIS._last < 0.5 then return end; NOVIS._last = now
            apply()
        end)
        pcall(function() G.RS:BindToRenderStep(NOVIS.bindName, 3000, apply) end)
        for _, prop in ipairs({"FogStart","FogEnd"}) do
            local c = L:GetPropertyChangedSignal(prop):Connect(function() if S.noVis then apply() end end)
            table.insert(NOVIS.conns, c)
        end
        local at = L:FindFirstChildOfClass("Atmosphere")
        if at then
            local c = at:GetPropertyChangedSignal("Density"):Connect(function() if S.noVis then apply() end end)
            table.insert(NOVIS.conns, c)
        end
        apply()
    end
    function NOVIS.dis()
        if NOVIS.conn then NOVIS.conn:Disconnect(); NOVIS.conn = nil end
        pcall(function() G.RS:UnbindFromRenderStep(NOVIS.bindName) end)
        for _, c in ipairs(NOVIS.conns) do pcall(function() c:Disconnect() end) end
        NOVIS.conns = {}
    end
end


local BRIGHT = {active = false, bindName = "ArchiveFullBright", conns = {}, orig = nil}
do
    local L = game:GetService("Lighting")
    local white = Color3.fromRGB(255, 255, 255)
    local function apply()
        if not S.bright then return end
        pcall(function()
            local v = CFG.BrightVal or 3
            L.Brightness = v
            L.Ambient = white
            L.OutdoorAmbient = white
        end)
    end
    local function hook(prop)
        local c = L:GetPropertyChangedSignal(prop):Connect(function()
            if not S.bright then return end
            apply()
        end)
        table.insert(BRIGHT.conns, c)
    end
    function BRIGHT.en()
        if BRIGHT.active then return end; BRIGHT.active = true
        pcall(function()
            BRIGHT.orig = {
                Brightness = L.Brightness,
                Ambient = L.Ambient,
                OutdoorAmbient = L.OutdoorAmbient,
                GlobalShadows = L.GlobalShadows,
            }
        end)
        pcall(function() G.RS:BindToRenderStep(BRIGHT.bindName, 3000, apply) end)
        hook("Brightness"); hook("Ambient"); hook("OutdoorAmbient")
        
        local c = L.ChildAdded:Connect(function() if S.bright then task.defer(apply) end end)
        table.insert(BRIGHT.conns, c)
        apply()
        NOTIF.send("Full bright", "Enabled")
    end
    function BRIGHT.dis()
        pcall(function() G.RS:UnbindFromRenderStep(BRIGHT.bindName) end)
        for _, c in ipairs(BRIGHT.conns) do pcall(function() c:Disconnect() end) end
        BRIGHT.conns = {}
        if BRIGHT.active then
            BRIGHT.active = false
            pcall(function()
                if BRIGHT.orig then
                    L.Brightness = BRIGHT.orig.Brightness
                    L.Ambient = BRIGHT.orig.Ambient
                    L.OutdoorAmbient = BRIGHT.orig.OutdoorAmbient
                    L.GlobalShadows = BRIGHT.orig.GlobalShadows
                end
            end)
            BRIGHT.orig = nil
        end
        NOTIF.send("Full bright", "Disabled")
    end
end


local FPS = {active = false, origCap = nil, hasOrig = false}
do
    local function getCap()
        if type(getfpscap) == "function" then
            local ok, v = pcall(getfpscap)
            if ok and type(v) == "number" then return v end
        end
        return nil
    end
    local function setCap(v)
        if type(setfpscap) ~= "function" then return false end
        pcall(function() setfpscap(v) end)
        return true
    end
    function FPS.captureOrig()
        if FPS.hasOrig then return end
        local c = getCap()
        if c ~= nil then FPS.origCap = c; FPS.hasOrig = true end
    end
    function FPS.en(silent)
        if FPS.active then return end
        FPS.active = true
        local v = tonumber(CFG.FpsVal) or 60
        setCap(v)
        if not silent then NOTIF.send("FPS limiter", "Enabled . " .. tostring(v) .. " fps") end
    end
    function FPS.dis()
        if not FPS.active then return end
        FPS.active = false
        if FPS.hasOrig and FPS.origCap ~= nil then
            setCap(FPS.origCap)
        end
        NOTIF.send("FPS limiter", "Disabled")
    end
    function FPS.applyVal(v)
        v = tonumber(v)
        if not v then return end
        v = G.mc(v, 30, 999)
        CFG.FpsVal = v
        if FPS.active and type(setfpscap) == "function" then setCap(v) end
        pcall(function() if UI and UI._sliders and UI._sliders.FpsVal then UI._sliders.FpsVal(v) end end)
        pcall(function() if UI and UI.rows and UI.rows.fps and UI.rows.fps.chip then UI.rows.fps.chip() end end)
    end
end

local OPTIMIZE = {active = false, conn = nil, conn2 = nil}
do
    local function lite(root)
        local n = 0
        for _, v in ipairs(root:GetDescendants()) do
            if not OPTIMIZE.active then break end
            pcall(function()
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    if v.CastShadow ~= false then v.CastShadow = false end
                    if v.Material ~= Enum.Material.SmoothPlastic then v.Material = Enum.Material.SmoothPlastic end
                    if v.Reflectance ~= 0 then v.Reflectance = 0 end
                    if v:IsA("MeshPart") and v.TextureID ~= "" then v.TextureID = "" end
                elseif v:IsA("SpecialMesh") then
                    if v.TextureId ~= "" then v.TextureId = "" end
                elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy()
                elseif v:IsA("ParticleEmitter") then v.Rate = math.clamp(v.Rate * 0.1, 0, 5)
                elseif v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false
                elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false
                elseif v:IsA("PointLight") or v:IsA("SpotLight") then
                    if v.Parent and not v.Parent:FindFirstChildOfClass("Humanoid") then
                        v.Range = math.min(v.Range, 8); v.Brightness = math.min(v.Brightness, 0.5)
                    end
                end
            end)
            n = n + 1; if n % 600 == 0 then task.wait() end
        end
    end
    local function dark()
        pcall(function()
            local L = game:GetService("Lighting")
            L.GlobalShadows = false; L.Brightness = 0
            L.EnvironmentDiffuseScale = 0; L.EnvironmentSpecularScale = 0
            for _, v in ipairs(L:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") then v.Enabled = false end
            end
            local T = G.WS.Terrain
            if T then T.WaterWaveSize, T.WaterWaveSpeed, T.WaterReflectance, T.WaterTransparency, T.Decoration = 0, 0, 0, 1, false end
        end)
    end
    local function onNew(v)
        if not OPTIMIZE.active then return end
        pcall(function()
            if v:IsA("ParticleEmitter") then v.Rate = math.clamp(v.Rate * 0.1, 0, 5)
            elseif v:IsA("BasePart") and not v:IsA("Terrain") then
                if v.CastShadow ~= false then v.CastShadow = false end
                if v.Material ~= Enum.Material.SmoothPlastic then v.Material = Enum.Material.SmoothPlastic end
            elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy()
            elseif v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false
            elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false
            elseif v:IsA("PostEffect") or v:IsA("Atmosphere") then v.Enabled = false end
        end)
    end
    function OPTIMIZE.en()
        if OPTIMIZE.active then return end; OPTIMIZE.active = true
        dark()
        G.ts(function() lite(G.WS) end)
        G.ts(function() pcall(function() lite(G.RepS) end) end)
        OPTIMIZE.conn = G.WS.DescendantAdded:Connect(onNew)
        OPTIMIZE.conn2 = game:GetService("Lighting").ChildAdded:Connect(function(v)
            if OPTIMIZE.active then pcall(function() if v:IsA("PostEffect") or v:IsA("Atmosphere") then v.Enabled = false end end) end
        end)
    end
    function OPTIMIZE.dis()
        OPTIMIZE.active = false
        if OPTIMIZE.conn then OPTIMIZE.conn:Disconnect(); OPTIMIZE.conn = nil end
        if OPTIMIZE.conn2 then OPTIMIZE.conn2:Disconnect(); OPTIMIZE.conn2 = nil end
    end
end


local NKB = {active = false, saved = {}, fakers = {}, conns = {}}
do
    local NAMES = {KillBrick = true, KillPlane = true, LifeField = true, ChasmBrick = true, SuperWall = true}
    local function isKB(part)
        if not part or not part.Parent then return false end
        if NAMES[part.Name] then return true end
        if part.Name == "ThronePart" and game.PlaceId == 6032399813 then return true end
        if part.Parent.Name == "Layer2KillbrickModel" then return true end
        return false
    end
    local function check(child)
        if not NKB.active or not isKB(child) then return end
        NKB.saved[child.Parent] = NKB.saved[child.Parent] or {}
        G.ti(NKB.saved[child.Parent], child)
        child.Parent = nil; child.CanTouch = false
    end
    local function enum(inst)
        if not inst then return end
        for _, c in ipairs(inst:GetChildren()) do pcall(check, c) end
        G.ti(NKB.conns, inst.ChildAdded:Connect(function(c) pcall(check, c) end))
    end
    function NKB.en()
        if NKB.active then return end; NKB.active = true
        enum(G.WS:FindFirstChild("Layer2KillbrickModel", true))
        enum(G.WS:FindFirstChild("Layer2Floor1"))
        if game.PlaceId == 6032399813 then enum(G.WS:FindFirstChild("Thrown")) end
        enum(G.WS)
        NOTIF.send("No Kill Bricks", "Enabled")
    end
    function NKB.dis()
        if not NKB.active then return end; NKB.active = false
        for par, parts in pairs(NKB.saved) do for _, p in ipairs(parts) do pcall(function() p.Parent = par; p.CanTouch = true end) end end
        for _, c in ipairs(NKB.conns) do pcall(function() c:Disconnect() end) end
        for _, p in ipairs(NKB.fakers) do pcall(function() p:Destroy() end) end
        G.tc(NKB.saved); G.tc(NKB.conns); G.tc(NKB.fakers)
        NOTIF.send("No Kill Bricks", "Disabled")
    end
end


local NPC_FREEZER = {conn = nil, frozen = {}}
do
    function NPC_FREEZER.start()
        if NPC_FREEZER.conn then return end
        NPC_FREEZER.conn = G.RS.Heartbeat:Connect(function()
            if not S.npcFreeze then return end
            local live = G.WS:FindFirstChild("Live") or G.WS
            local ch = G.LP.Character
            local root = ch and ch:FindFirstChild("HumanoidRootPart"); if not root then return end
            local mp = root.Position
            local active = {}
            for _, m in ipairs(live:GetChildren()) do
                if m:IsA("Model") and m ~= ch and not G.Plrs:GetPlayerFromCharacter(m) then
                    local hrp = m:FindFirstChild("HumanoidRootPart"); local hum = m:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 and (hrp.Position - mp).Magnitude <= 300 then
                        active[m] = true
                        pcall(function()
                            local an = hum:FindFirstChildOfClass("Animator")
                            if an then for _, tr in ipairs(an:GetPlayingAnimationTracks()) do tr:Stop(0) end end
                        end)
                        if not NPC_FREEZER.frozen[m] then
                            local st = {}
                            for _, part in ipairs(m:GetDescendants()) do
                                if part:IsA("BasePart") then st[part] = part.Anchored; part.Anchored = true end
                            end
                            NPC_FREEZER.frozen[m] = st
                        else
                            for part in pairs(NPC_FREEZER.frozen[m]) do if part and part.Parent then part.Anchored = true end end
                        end
                    end
                end
            end
            for m, st in pairs(NPC_FREEZER.frozen) do
                if not active[m] then
                    for part, o in pairs(st) do if part and part.Parent then pcall(function() part.Anchored = o end) end end
                    NPC_FREEZER.frozen[m] = nil
                end
            end
        end)
    end
    function NPC_FREEZER.stop()
        if NPC_FREEZER.conn then NPC_FREEZER.conn:Disconnect(); NPC_FREEZER.conn = nil end
        for _, st in pairs(NPC_FREEZER.frozen) do for part, o in pairs(st) do if part and part.Parent then pcall(function() part.Anchored = o end) end end end
        NPC_FREEZER.frozen = {}
    end
end

local PATHBREAK = {conn = nil, pre = nil, last = nil}
do
    function PATHBREAK.start()
        if PATHBREAK.conn then return end
        PATHBREAK.conn = G.RS.Heartbeat:Connect(function()
            if not S.humanoidPathfindBreaker then return end
            local ch = G.LP.Character; if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            PATHBREAK.last = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(0, -9e9, 0)
        end)
        if not PATHBREAK.pre then
            PATHBREAK.pre = G.RS.PreRender:Connect(function()
                if not PATHBREAK.last then return end
                local ch = G.LP.Character; if not ch then return end
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.AssemblyLinearVelocity = PATHBREAK.last end
            end)
        end
    end
    function PATHBREAK.stop()
        if PATHBREAK.conn then PATHBREAK.conn:Disconnect(); PATHBREAK.conn = nil end
        if PATHBREAK.pre then PATHBREAK.pre:Disconnect(); PATHBREAK.pre = nil end
        PATHBREAK.last = nil
    end
end

local TWEENQ = {q = {}, dt = 0}
do
    function TWEENQ.cur() return TWEENQ.q[1] end
    function TWEENQ.goal(id, goal, swc)
        for _, d in ipairs(TWEENQ.q) do if d.id == id then d.goal, d.swc, d.done = goal, swc, false; return end end
        G.ti(TWEENQ.q, {id = id, goal = goal, swc = swc, done = false})
    end
    function TWEENQ.stop(id) for i, d in ipairs(TWEENQ.q) do if d.id == id then table.remove(TWEENQ.q, i); return end end end
    function TWEENQ.update()
        local cur = TWEENQ.cur(); if not cur then return end
        local ch = G.LP.Character; if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local sp, tp = hrp.Position, cur.goal.Position
        local diff = tp - sp
        local dist = diff.Magnitude; if dist <= 0.01 then return end
        if dist < 1 then
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        local dir = diff / dist
        local step = 200 * TWEENQ.dt
        local np = step >= dist and tp or (sp + dir * step)
        np = Vector3.new(np.X, tp.Y, np.Z)
        local ok = pcall(function()
            hrp.CFrame = CFrame.new(np) * (cur.goal - cur.goal.Position)
        end)
        if not ok then return end
        if (tp - np).Magnitude < 1.0 then cur.done = true; if cur.swc then TWEENQ.stop(cur.id) end end
    end
end
if shared.ArchiveTQ then pcall(function() shared.ArchiveTQ:Disconnect() end); shared.ArchiveTQ = nil end

local FINDER = {}
do
    function FINDER.near(range, mobsOnly)
        local live = G.WS:FindFirstChild("Live") or G.WS
        local ch = G.LP.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart"); if not root then return nil end
        local mp = root.Position
        local got, dist = {}, {}
        for _, m in ipairs(live:GetChildren()) do
            if m ~= ch then
                local hrp = m:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - mp).Magnitude
                    if d <= range then G.ti(got, m); dist[m] = d end
                end
            end
        end
        table.sort(got, function(a, b) return dist[a] < dist[b] end)
        if not mobsOnly then return got end
        local out = {}
        for _, m in ipairs(got) do if not G.Plrs:GetPlayerFromCharacter(m) then G.ti(out, m) end end
        return out
    end
end

local BACK = {conn = nil, noTgt = 0, hi = nil, lastMove = 0}
do
    local function hl(tgt)
        if BACK.hi and BACK.hi.Parent and BACK.hi.Adornee == tgt then return end
        pcall(function() if BACK.hi then BACK.hi:Destroy() end end)
        BACK.hi = nil
        if not tgt then return end
        pcall(function()
            local h = G.new("Highlight", tgt)
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = P.amb; h.OutlineColor = P.amb
            h.FillTransparency = 0.9; h.OutlineTransparency = 0
            h.Adornee = tgt
            BACK.hi = h
        end)
    end
    function BACK.start()
        if BACK.conn then return end
        local post = G.RS.Heartbeat
        pcall(function() if G.RS.PostSimulation then post = G.RS.PostSimulation end end)
        BACK.conn = post:Connect(function(dt)
            if not S.attachToBack then return end
            local list = FINDER.near(300, true); if not list then hl(nil); return end
            local tgt = S.attachTarget or list[1]
            if not tgt or not tgt.Parent then
                S.attachTarget = nil; hl(nil)
                local now = G.ck()
                if now - BACK.noTgt > 5 then BACK.noTgt = now; NOTIF.send("Attach", "no mob in range") end
                return
            end
            local hrp = tgt:FindFirstChild("HumanoidRootPart"); local hum = tgt:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then S.attachTarget = nil; hl(nil); return end
            hl(tgt)
            local ch = G.LP and G.LP.Character
            local myR = ch and ch:FindFirstChild("HumanoidRootPart")
            if not myR then return end
            local voidY = G.WS:FindFirstChild("Layer2Floor1") and 18.5 or 0
            local tcf = hrp.CFrame
            if tcf.Y < voidY then tcf = G.CF(tcf.X, voidY, tcf.Z) end
            local back = tcf * G.CF(0, 0, 3)
            local dist = ((back.Position - myR.Position) * G.V3(1, 0, 1)).Magnitude
            dt = dt or 0.016
            if dist > 30 then
                local dir = back.Position - myR.Position
                local step = 150 * dt
                if dir.Magnitude > 0 then
                    local np = step >= dir.Magnitude and back.Position or (myR.Position + dir.Unit * step)
                    pcall(function() myR.CFrame = G.CF(np) * (back - back.Position) end)
                end
            else
                pcall(function()
                    myR.CFrame = back
                    myR.AssemblyLinearVelocity = Vector3.zero
                    myR.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end)
    end
    function BACK.stop()
        if BACK.conn then BACK.conn:Disconnect(); BACK.conn = nil end
        TWEENQ.stop("TweenToBack"); S.attachTarget = nil
        pcall(function() if BACK.hi then BACK.hi:Destroy() end end)
        BACK.hi = nil
    end
    function BACK.list() return FINDER.near(300, true) or {} end
end

local TP_LOCS = {
    {n = "Etrean", type = "realm", realm = "EtreanLuminant", stream = G.V3(-514.263, 665.174, -4772.320)},
    {n = "Eastern", type = "realm", realm = "EasternLuminant", stream = G.V3(-2632.860, 628.632, -6707.998)},
    {n = "Depths", type = "depths", stream = G.V3(39911.367, 39980.937, 39708.320)},
    {n = "Trial of One", type = "trial", stream = G.V3(-959.787659, 146.996887, -6659.63037)},
    {n = "[VOI] Shogun", type = "shogun", stream = G.V3(-8983.13477, 894.127563, -4054.67822)},
    {n = "[VOI] Golden Rat", type = "goldenrat", stream = G.V3(-2829.87646, 56.4980431, -3300.2854)},
}
local TELE = {conn = nil, dest = nil, destName = nil, fCount = 0, lastStream = 0}
do
    local efr = nil
    pcall(function() efr = require(G.RepS:FindFirstChild("EffectReplicator") or G.RepS:WaitForChild("EffectReplicator", 2)) end)
    local ALIAS = {
        EasternLuminant = {"EastLuminant", "East Luminant", "EasternLuminant", "Eastern Luminant"},
        EtreanLuminant = {"EtreanLuminant", "Etrean Luminant"},
    }
    local function isRealm(realm, dest)
        for _, a in ipairs(ALIAS[dest] or {dest}) do if realm == a then return true end end
        return false
    end
    local function findRealmTP(realmName)
        for _, path in ipairs({{"ValleyExit", "RealmTeleport"}, {"ValleyExit", "RealmTeleporter"}}) do
            local cur = G.WS; for _, n in ipairs(path) do cur = cur and cur:FindFirstChild(n) end
            if cur and cur:IsA("BasePart") and isRealm(cur:GetAttribute("Realm") or "", realmName) then return cur end
        end
        return nil
    end
    local function findDepthsPit()
        local mo = G.WS:FindFirstChild("ModOffice"); return mo and mo:FindFirstChild("OfficePit")
    end
    local function fireTch(ch, part)
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp or not part then return end
        if type(firetouchinterest) == "function" then
            pcall(firetouchinterest, hrp, part, 0); pcall(firetouchinterest, hrp, part, 1)
            pcall(firetouchinterest, hrp, part, 0); pcall(firetouchinterest, hrp, part, 1)
        end
    end
    local function streamReq(pos)
        local now = G.ck(); if now - TELE.lastStream < 1 then return end; TELE.lastStream = now
        G.ts(function() pcall(function() G.LP:RequestStreamAroundAsync(pos, 0.1) end) end)
    end
    function TELE.go(loc)
        TELE.dest = loc; TELE.destName = loc.n; TELE.fCount = 0; S.tp = true
        if TELE.conn then TELE.conn:Disconnect() end; TELE.lastStream = 0
        streamReq(loc.stream)
        TELE.conn = G.RS.RenderStepped:Connect(function()
            if not S.tp or not TELE.dest then TELE.stop(); return end
            local ch = G.LP and G.LP.Character; if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            TELE.fCount = TELE.fCount + 1
            streamReq(loc.stream)
            if loc.type == "realm" then
                local tp = findRealmTP(loc.realm); if not tp then return end
                ch:PivotTo(tp.CFrame); fireTch(ch, tp)
            elseif loc.type == "depths" then
                local pit = findDepthsPit()
                if pit then ch:PivotTo(pit.CFrame)
                else ch:PivotTo(G.CF(loc.stream)) end
            elseif loc.type == "trial" then
                if efr and efr:FindEffect("Knocked") then TELE.stop(); return end
                local tp = G.WS:FindFirstChild("OneEntrance")
                if not tp then return end
                ch:PivotTo(tp.CFrame)
            elseif loc.type == "shogun" then
                local tp = G.WS:FindFirstChild("ShogunBoundary")
                if not tp then return end
                ch:PivotTo(tp.CFrame); fireTch(ch, tp)
            elseif loc.type == "goldenrat" then
                local tp = G.WS:FindFirstChild("GoldenRatBoundary")
                if not tp then return end
                ch:PivotTo(tp.CFrame); fireTch(ch, tp)
            end
            if TELE.fCount > 5 then
                pcall(function()
                    local pg = G.LP:FindFirstChild("PlayerGui")
                    if pg then for _, desc in ipairs(pg:GetDescendants()) do
                        if desc:IsA("TextLabel") then
                            local coords = string.split(desc.Text, ", ")
                            local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
                            if x and y and z then
                                local gp = G.V3(x, y, z)
                                if loc.type == "depths" and (gp - G.V3(39911, 39980, 39708)).Magnitude < 50 then
                                    TELE.stop(); NOTIF.send("Teleport", "Arrived at Depths!"); return
                                end
                            end
                        end
                    end end
                end)
            end
            if TELE.fCount > 600 then TELE.stop(); NOTIF.send("Teleport", "Timeout — realm may have loaded") end
        end)
        NOTIF.send("Teleport", "Traveling to " .. loc.n .. "...")
    end
    function TELE.stop()
        S.tp = false; TELE.dest = nil; TELE.destName = nil
        if TELE.conn then TELE.conn:Disconnect(); TELE.conn = nil end
    end
end


local EFFECTS = {active = false, pg = nil, watch = nil, tick = nil, last = 0, bindName = "ArchiveEffects", conns = {}, blur = {}, ccc = setmetatable({}, {__mode = "k"}), ter = setmetatable({}, {__mode = "k"})}
do
    local L = game:GetService("Lighting")
    local function terror(n) return n:sub(1, 6) == "Terror" end
    local function scrubBlur(name)
        local b = L:FindFirstChild(name); if not b then return end
        local e = EFFECTS.blur[name]
        if not e or e.inst ~= b then EFFECTS.blur[name] = {inst = b, size = b.Size} end
        if b.Size ~= 0 then pcall(function() b.Size = 0 end) end
    end
    local function backBlur(name)
        local e = EFFECTS.blur[name]; if not e then return end
        if e.inst and e.inst.Parent then pcall(function() e.inst.Size = e.size end) end
        EFFECTS.blur[name] = nil
    end
    local function scrubCCC(cc)
        if not EFFECTS.ccc[cc] then EFFECTS.ccc[cc] = {S = cc.Saturation, C = cc.Contrast, B = cc.Brightness, T = cc.TintColor} end
        pcall(function() cc.Saturation, cc.Contrast, cc.Brightness, cc.TintColor = 0, 0, 0, Color3.new(1, 1, 1) end)
    end
    local function backCCC(cc)
        local c = EFFECTS.ccc[cc]; if not c then return end
        pcall(function() if cc.Parent then cc.Saturation, cc.Contrast, cc.Brightness, cc.TintColor = c.S, c.C, c.B, c.T end end)
        EFFECTS.ccc[cc] = nil
    end
    local function scrubT(g)
        if not terror(g.Name) then return end
        if not EFFECTS.ter[g] then EFFECTS.ter[g] = {img = g.Image, vis = g.Visible, tr = g.ImageTransparency} end
        pcall(function()
            if g.Image ~= "" then g.Image = "" end
            g.Visible = false
            g.ImageTransparency = 1
        end)
    end
    local function backT(g)
        local c = EFFECTS.ter[g]; if not c then return end
        pcall(function()
            g.Image = c.img; g.Visible = c.vis; g.ImageTransparency = c.tr
        end)
        EFFECTS.ter[g] = nil
    end
    function EFFECTS.cleanSanity()
        for _, cc in ipairs(L:GetChildren()) do if cc:IsA("ColorCorrectionEffect") then scrubCCC(cc) end end
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui"); if not pg then return end
        for _, d in ipairs(pg:GetDescendants()) do if terror(d.Name) then scrubT(d) end end
    end
    function EFFECTS.backSanity() for cc in pairs(EFFECTS.ccc) do backCCC(cc) end; for g in pairs(EFFECTS.ter) do backT(g) end end
    local function apply()
        if not EFFECTS.active then return end
        pcall(function()
            if S.effSanity then
                for g in pairs(EFFECTS.ter) do
                    if g and g.Parent then
                        if g.Image ~= "" then g.Image = "" end
                        g.Visible = false
                        g.ImageTransparency = 1
                    end
                end
                for _, cc in ipairs(L:GetChildren()) do if cc:IsA("ColorCorrectionEffect") then scrubCCC(cc) end end
            end
            if S.effHunger then scrubBlur("GenericBlur") end
            if S.effUnderwater then scrubBlur("UnderwaterBlur") end
        end)
    end
    function EFFECTS.en()
        if EFFECTS.active then return end; EFFECTS.active = true
        if S.effSanity then EFFECTS.cleanSanity() end
        if S.effHunger then scrubBlur("GenericBlur") end
        if S.effUnderwater then scrubBlur("UnderwaterBlur") end
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
        if pg then
            if EFFECTS.pg then EFFECTS.pg:Disconnect() end
            EFFECTS.pg = pg.DescendantAdded:Connect(function(d)
                if EFFECTS.active and S.effSanity and terror(d.Name) then scrubT(d) end
            end)
        end
        if EFFECTS.watch then EFFECTS.watch:Disconnect() end
        EFFECTS.watch = L.ChildAdded:Connect(function(c)
            if not EFFECTS.active then return end
            if S.effSanity and c:IsA("ColorCorrectionEffect") then scrubCCC(c)
            elseif c.Name == "GenericBlur" and S.effHunger then scrubBlur("GenericBlur")
            elseif c.Name == "UnderwaterBlur" and S.effUnderwater then scrubBlur("UnderwaterBlur") end
        end)
        pcall(function() G.RS:BindToRenderStep(EFFECTS.bindName, 3000, apply) end)
        local function hookEl(g)
            if not terror(g.Name) then return end
            local c1 = g:GetPropertyChangedSignal("Image"):Connect(function() if S.effSanity then scrubT(g) end end)
            local c2 = g:GetPropertyChangedSignal("Visible"):Connect(function() if S.effSanity then scrubT(g) end end)
            local c3 = g:GetPropertyChangedSignal("Parent"):Connect(function() if S.effSanity and g.Parent then scrubT(g) end end)
            table.insert(EFFECTS.conns, c1); table.insert(EFFECTS.conns, c2); table.insert(EFFECTS.conns, c3)
        end
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
        if pg then
            for _, d in ipairs(pg:GetDescendants()) do if terror(d.Name) then hookEl(d) end end
            if EFFECTS.pg then EFFECTS.pg:Disconnect() end
            EFFECTS.pg = pg.DescendantAdded:Connect(function(d)
                if EFFECTS.active and S.effSanity and terror(d.Name) then scrubT(d); hookEl(d) end
            end)
        end
        for _, cc in ipairs(L:GetChildren()) do
            if cc:IsA("ColorCorrectionEffect") then
                for _, prop in ipairs({"Saturation","Brightness","Contrast","TintColor"}) do
                    local c = cc:GetPropertyChangedSignal(prop):Connect(function() if S.effSanity then scrubCCC(cc) end end)
                    table.insert(EFFECTS.conns, c)
                end
            end
        end
        if not EFFECTS.tick then
            EFFECTS.tick = G.RS.Heartbeat:Connect(function()
                if not EFFECTS.active then return end
                local now = G.ck(); if now - EFFECTS.last < 0.01 then return end; EFFECTS.last = now
                if S.effHunger then scrubBlur("GenericBlur") end
                if S.effUnderwater then scrubBlur("UnderwaterBlur") end
                if S.effSanity then
                    for g in pairs(EFFECTS.ter) do if g then scrubT(g) end end
                    for _, cc in ipairs(L:GetChildren()) do if cc:IsA("ColorCorrectionEffect") then scrubCCC(cc) end end
                end
            end)
        end
        apply()
    end
    function EFFECTS.scrubSanity()
        if not EFFECTS.active then return end
        pcall(EFFECTS.cleanSanity)
    end
    function EFFECTS.restoreSanity()
        for g in pairs(EFFECTS.ter) do pcall(backT, g) end
        for cc in pairs(EFFECTS.ccc) do pcall(backCCC, cc) end
    end
    function EFFECTS.scrubHunger()
        if not EFFECTS.active then return end
        pcall(function() scrubBlur("GenericBlur") end)
    end
    function EFFECTS.restoreHunger()
        pcall(function() backBlur("GenericBlur") end)
    end
    function EFFECTS.scrubUnderwater()
        if not EFFECTS.active then return end
        pcall(function() scrubBlur("UnderwaterBlur") end)
    end
    function EFFECTS.restoreUnderwater()
        pcall(function() backBlur("UnderwaterBlur") end)
    end
    function EFFECTS.dis()
        if not EFFECTS.active then
            pcall(function() G.RS:UnbindFromRenderStep(EFFECTS.bindName) end)
            for _, c in ipairs(EFFECTS.conns) do pcall(function() c:Disconnect() end) end
            EFFECTS.conns = {}
            return
        end
        EFFECTS.active = false
        pcall(function() G.RS:UnbindFromRenderStep(EFFECTS.bindName) end)
        if EFFECTS.pg then EFFECTS.pg:Disconnect(); EFFECTS.pg = nil end
        if EFFECTS.watch then EFFECTS.watch:Disconnect(); EFFECTS.watch = nil end
        if EFFECTS.tick then EFFECTS.tick:Disconnect(); EFFECTS.tick = nil end
        for _, c in ipairs(EFFECTS.conns) do pcall(function() c:Disconnect() end) end
        EFFECTS.conns = {}
        for n in pairs(EFFECTS.blur) do backBlur(n) end
        for cc in pairs(EFFECTS.ccc) do backCCC(cc) end
        for g in pairs(EFFECTS.ter) do backT(g) end
    end
end






local SANITY = {bar = nil, slider = nil, conn = nil}
do
    local SHELL = {0.25098040699959, 0.24705883860588, 0.26274511218071}
    local FILL = {0.10000000149012, 0.14000000059605, 0.31999999284744}
    local TINT = {0.71764707565308, 0.77254909276962, 0.82745105028152}
    local ICON_IMG = "rbxassetid://6763305825"
    local ICON_RECT = {0, 0, 14, 11}
    local ICON_TINT = {0, 0.96986198425293, 1}
    local function rgb(t) return G.C3(t[1], t[2], t[3]) end
    function SANITY.build(ss)
        if not ss then return nil end
        if SANITY.bar and SANITY.bar.Parent == ss then return SANITY.bar end
        pcall(function() if SANITY.bar then SANITY.bar:Destroy() end end)
        SANITY.bar, SANITY.slider = nil, nil
        local hunger = ss:FindFirstChild("Stomach") or ss:FindFirstChild("Water")
        local blood = ss:FindFirstChild("Blood")
        local tpl = hunger or blood
        if not tpl then return nil end
        local bar = G.new("Frame")
        bar.Name = "Sanity"
        bar.AnchorPoint = G.V2(0, 1)
        bar.Position = G.UD2(0, 72, 1, 0)
        bar.Size = G.UD2(0, 14, 0.20000000298023, 50)
        bar.BackgroundColor3 = rgb(SHELL)
        bar.BackgroundTransparency = 0
        bar.BorderSizePixel = 0
        bar.Visible = true
        local slider = G.new("Frame")
        slider.Name = "Slider"
        slider.AnchorPoint = G.V2(0, 1)
        slider.Position = G.UD2(0, 0, 1, 0)
        slider.Size = G.UD2(1, 0, 1, 0)
        slider.BackgroundColor3 = rgb(FILL)
        slider.BackgroundTransparency = 0
        slider.BorderSizePixel = 0
        slider.Parent = bar
        local to = tpl:FindFirstChild("Overlay")
        if to then
            local o = G.new("ImageLabel")
            o.Name = "Overlay"
            o.AnchorPoint = G.V2(0, 0)
            o.Position = G.UD2(0, -4, 0, -5)
            o.Size = G.UD2(1, 8, 1, 10)
            o.BackgroundColor3 = G.C3(1, 1, 1)
            o.BackgroundTransparency = 1
            o.BorderSizePixel = 1
            o.Visible = true
            o.Rotation = 0
            o.LayoutOrder = 0
            o.Image = "rbxassetid://6762787994"
            o.ImageColor3 = G.C3(1, 1, 1)
            o.ImageTransparency = 0
            o.ImageRectOffset = G.V2(0, 0)
            o.ImageRectSize = G.V2(0, 0)
            o.ScaleType = Enum.ScaleType.Slice
            o.SliceCenter = Rect.new(9, 14, 9, 14)
            o.SliceScale = 1
            pcall(function() o:AddTag("UIOverlay") end)
            local p2 = G.new("UIPadding")
            p2.PaddingTop = G.UD(0, 5)
            p2.PaddingBottom = G.UD(0, 5)
            p2.PaddingLeft = G.UD(0, 0)
            p2.PaddingRight = G.UD(0, 0)
            p2.Parent = o
            local pinDefs = {
                {ay = 0.20000000298023, oy = -3, ax = 0},
                {ay = 0.40000000596046, oy = -3, ax = 0},
                {ay = 0.60000002384186, oy = 3, ax = 1},
                {ay = 0.80000001192093, oy = 3, ax = 1},
            }
            for _, pd in ipairs(pinDefs) do
                local pin = G.new("ImageLabel")
                pin.Name = "Pins"
                pin.AnchorPoint = G.V2(0, pd.ax)
                pin.Position = G.UD2(0, 0, pd.ay, pd.oy)
                pin.Size = G.UD2(1, 0, 0, 5)
                pin.BackgroundColor3 = G.C3(1, 1, 1)
                pin.BackgroundTransparency = 1
                pin.BorderSizePixel = 1
                pin.Visible = true
                pin.Rotation = 0
                pin.LayoutOrder = 0
                pin.Image = "http://www.roblox.com/asset/?id=4527814397"
                pin.ImageColor3 = G.C3(TINT[1], TINT[2], TINT[3])
                pin.ImageTransparency = 0
                pin.ImageRectOffset = G.V2(0, 0)
                pin.ImageRectSize = G.V2(0, 0)
                pin.ScaleType = Enum.ScaleType.Slice
                pin.SliceCenter = Rect.new(9, 5, 9, 5)
                pin.SliceScale = 1
                pin.Parent = o
            end
            local tlab = to:FindFirstChild("Label")
            if tlab then
                local lab = G.new("ImageLabel")
                lab.Name = "Label"
                lab.AnchorPoint = G.V2(0.5, 0)
                lab.Position = G.UD2(0.5, 0, 1, 1)
                lab.Size = G.UD2(0, 20, 0, 21)
                lab.BackgroundColor3 = G.C3(1, 1, 1)
                lab.BackgroundTransparency = 1
                lab.BorderSizePixel = 1
                lab.Visible = true
                lab.Rotation = 0
                lab.LayoutOrder = 0
                lab.Image = "rbxassetid://6763288433"
                lab.ImageColor3 = G.C3(TINT[1], TINT[2], TINT[3])
                lab.ImageTransparency = 0
                lab.ImageRectOffset = G.V2(0, 0)
                lab.ImageRectSize = G.V2(0, 0)
                lab.ScaleType = Enum.ScaleType.Stretch
                lab.SliceCenter = Rect.new(0, 0, 0, 0)
                lab.SliceScale = 1
                lab.Parent = o
                local blank = G.new("ImageLabel")
                blank.Name = "Icon"
                blank.AnchorPoint = G.V2(0.5, 0)
                blank.Position = G.UD2(0.5, 0, 0, 7)
                blank.Size = G.UD2(0, 14, 0, 11)
                blank.BackgroundColor3 = G.C3(1, 1, 1)
                blank.BackgroundTransparency = 1
                blank.BorderSizePixel = 1
                blank.Visible = true
                blank.Rotation = 0
                blank.LayoutOrder = 0
                blank.Image = ICON_IMG
                blank.ImageColor3 = G.C3(ICON_TINT[1], ICON_TINT[2], ICON_TINT[3])
                blank.ImageTransparency = 0
                blank.ImageRectOffset = G.V2(ICON_RECT[1], ICON_RECT[2])
                blank.ImageRectSize = G.V2(ICON_RECT[3], ICON_RECT[4])
                blank.ScaleType = Enum.ScaleType.Stretch
                blank.SliceCenter = Rect.new(0, 0, 0, 0)
                blank.SliceScale = 1
                blank.Parent = lab
            end
            o.Parent = bar
        end
        bar.Parent = ss
        SANITY.bar, SANITY.slider = bar, slider
        return bar
    end
    function SANITY.en()
        if SANITY.conn then
            pcall(function()
                local pg = G.LP and G.LP:FindFirstChildOfClass("PlayerGui")
                local ss = pg and pg:FindFirstChild("StatsGui") and pg.StatsGui:FindFirstChild("SurvivalStats")
                if ss then SANITY.build(ss) end
            end)
            return
        end
        pcall(function()
            local pg = G.LP and G.LP:FindFirstChildOfClass("PlayerGui")
            local ss = pg and pg:FindFirstChild("StatsGui") and pg.StatsGui:FindFirstChild("SurvivalStats")
            if ss then SANITY.build(ss) end
        end)
        local last = 0
        SANITY.conn = G.RS.Heartbeat:Connect(function()
            local now = G.ck(); if now - last < 0.1 then return end; last = now
            pcall(function()
                local pg = G.LP and G.LP:FindFirstChildOfClass("PlayerGui")
                local ss = pg and pg:FindFirstChild("StatsGui") and pg.StatsGui:FindFirstChild("SurvivalStats")
                if not ss then return end
                local bar = SANITY.bar
                if not bar or not bar.Parent or bar.Parent ~= ss then bar = SANITY.build(ss) end
                if not bar then return end
                local slider = SANITY.slider
                if not slider or not slider.Parent then
                    slider = bar:FindFirstChild("Slider")
                    SANITY.slider = slider
                end
                if not slider then return end
                local ch = G.LP and G.LP.Character
                local san = ch and ch:FindFirstChild("Sanity")
                if not san then slider.Size = G.UD2(1, 0, 0, 0); return end
                local mn = san.MinValue or 0
                local mx = san.MaxValue or 80
                local v = san.Value or 0
                local span = mx - mn; if span <= 0 then span = 1 end
                local pct = G.mc((v - mn) / span, 0, 1)
                slider.Size = G.UD2(1, 0, pct, 0)
            end)
        end)
    end
    function SANITY.dis()
        if SANITY.conn then SANITY.conn:Disconnect(); SANITY.conn = nil end
        pcall(function() if SANITY.bar then SANITY.bar:Destroy() end end)
        SANITY.bar, SANITY.slider = nil, nil
    end
end


local CHATSHOW = {}
do
    local function cfg()
        local tcs
        pcall(function() tcs = game:GetService("TextChatService") end)
        if not tcs then return nil end
        local c = tcs:FindFirstChild("ChatWindowConfiguration")
        if not c then pcall(function() c = tcs:WaitForChild("ChatWindowConfiguration", 5) end) end
        return c
    end
    function CHATSHOW.dis()
        pcall(function() local c = cfg(); if c then c.Enabled = false end end)
    end
    function CHATSHOW.en()
        pcall(function() local c = cfg(); if c then c.Enabled = true end end)
    end
end


local MACRO = {}
do
    function MACRO.exec(n)
        local seq = CFG["M" .. tostring(n)]; if type(seq) ~= "string" or seq == "" then return end
        for _, raw in ipairs(string.split(string.gsub(seq, "%+", ","), ",")) do
            local cmd = string.match(raw, "^%s*(.-)%s*$")
            if cmd ~= "" then
                local u = string.upper(cmd)
                if u == "M1" then
                    if G.VIM then pcall(function() G.VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1); G.tw(); G.VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1) end)
                    elseif type(mouse1press) == "function" then pcall(function() mouse1press(); G.tw(); mouse1release() end) end
                elseif u == "M2" then G.pressM2()
                else local ok, kc = pcall(function() return Enum.KeyCode[u] end); if ok and kc then G.pressKey(kc) end end
            end
        end
    end
end


local BUILDER = {cfg = nil, url = nil, shrined = false, running = false, points = false, logged = false}
do
    local ATTR = {
        ["Heavy Wep."] = "WeaponHeavy", ["Medium Wep."] = "WeaponMedium", ["Light Wep."] = "WeaponLight",
        ["Strength"] = "Strength", ["Fortitude"] = "Fortitude", ["Agility"] = "Agility",
        ["Intelligence"] = "Intelligence", ["Willpower"] = "Willpower", ["Charisma"] = "Charisma",
        ["Flamecharm"] = "ElementFire", ["Frostdraw"] = "ElementIce", ["Thundercall"] = "ElementLightning",
        ["Galebreathe"] = "ElementWind", ["Shadowcast"] = "ElementShadow", ["Ironsing"] = "ElementMetal",
        ["Bloodrend"] = "ElementBlood",
    }
    local BURN = {
        ["Risky Moves"] = true, ["Observation"] = true, ["Safety Dance"] = true, ["Neuroplasticity"] = true,
        ["Return to the Dark Ages"] = true, ["Eruption Path: Lava Serpent"] = true, ["The Final Act"] = true,
        ["Orbital Ice"] = true, ["Fists of Fortitude"] = true, ["Singularity"] = true, ["Sightless Still"] = true,
        ["Million Ton Piercer"] = true, ["Ether Overdrive"] = true, ["Bulldozer"] = true, ["Dazing Finisher"] = true,
        ["Wraith Path: Twisted Puppets"] = true, ["Azure Flames"] = true, ["Everchanging Aegis"] = true,
    }
    local TRAINS = {
        Fire = {["Squad:Fire"] = true, ["Blade:Fire"] = true},
        Ice = {["Dice:Ice"] = true, ["Beam:Ice"] = true, ["Squad:Ice"] = true},
        Lightning = {["Beam:Lightning"] = true, ["Blade:Lightning"] = true},
        Wind = {["Blade:Wind"] = true, ["HeavyKick:Wind"] = true},
        Shadow = {["Blade:Shadow"] = true, ["Choke:Shadow"] = true},
        Blood = {["Forge:Blood"] = true},
        Metal = {["Eruption:Metal"] = true, ["Toss:Metal"] = true},
        Charisma = {["Taunt:Charisma"] = true},
    }
    local TRAITS = {
        ["Vitality"] = "Health", ["Health"] = "Health",
        ["Erudition"] = "Ether", ["Ether"] = "Ether",
        ["Proficiency"] = "WeaponDamage", ["WeaponDamage"] = "WeaponDamage",
        ["Songchant"] = "MantraDamage", ["MantraDamage"] = "MantraDamage",
    }
    local ROMANS = {{"vi", 6}, {"v", 5}, {"iv", 4}, {"iii", 3}, {"ii", 2}, {"i", 1}}
    local function traitCard(label)
        if not label or label == "" then return nil, nil end
        local lower = string.lower(label)
        for word, key in pairs(TRAITS) do
            local start = string.find(lower, string.lower(word), 1, true)
            if start then
                local after = string.sub(lower, start + #word)
                for _, r in ipairs(ROMANS) do
                    if string.sub(after, 1, #r[1]) == r[1] then
                        return key, r[2]
                    end
                end
            end
        end
        return nil, nil
    end
    local function clean(s)
        if not s or s == "" then return "" end
        return s:lower():gsub("%s*%[.-%]%s*", " "):gsub("^%d+", ""):gsub("z%w+divider", ""):gsub("[^%a%d]", "")
    end
    local function resolve(name)
        if not name then return nil end
        if ATTR[name] then return ATTR[name] end
        local c = clean(name)
        for label, req in pairs(ATTR) do
            if clean(label) == c or clean(req) == c then return req end
        end
        return nil
    end
    local function flat(attrs)
        local out = {}
        if not attrs then return out end
        for _, cat in ipairs({"weapon", "attunement", "base"}) do
            local cs = attrs[cat]
            if cs then for stat, v in pairs(cs) do out[stat] = v end end
        end
        return out
    end
    local function reqs()
        local r = G.RepS:FindFirstChild("Requests")
        return r
    end
    local function playerData()
        for i = 1, 2 do
            local r = reqs()
            local get = r and r:FindFirstChild("Get")
            if get then
                local ok, data = pcall(function() return get:InvokeServer() end)
                if ok and type(data) == "table" and type(data.StatStrength) == "number" then return data end
            end
            if i < 2 then G.tw(0.2) end
        end
        return nil
    end
    local function statOf(data, req) return tonumber(data["Stat" .. req]) or 0 end
    local function trueOf(req)
        local ch = G.LP and G.LP.Character
        if not ch then return nil end
        local v = nil
        pcall(function() v = ch:GetAttribute("Stat_" .. req) end)
        return tonumber(v)
    end
    
    
    local function solidData(want)
        local best, agg = nil, {}
        for _ = 1, 3 do
            local d = playerData()
            if d then
                best = d
                local moved = false
                for _, e in ipairs(want or {}) do
                    local v = statOf(d, e.req)
                    if v > (agg[e.req] or -1) then agg[e.req] = v; moved = true end
                end
                if not moved then break end
            end
            G.tw(0.4)
        end
        return best, agg
    end
    local function pointsOf(data)
        return (tonumber(data.AvailableAttributePoints) or 0)
            + (tonumber(data.FullAttributePoints) or 0) + (tonumber(data.FreeAttributePoints) or 0)
    end
    local function traitOf(data, key) return tonumber(data["Trait" .. key]) or 0 end
    local function traitPointsOf(data) return tonumber(data.TraitPoints) or 0 end
    local function raise(req)
        local r = reqs()
        local inc = r and r:FindFirstChild("IncreaseAttribute")
        if not inc then return false end
        local ok = pcall(function() inc:InvokeServer(req) end)
        return ok
    end
    local function raiseTrait(key)
        local r = reqs()
        local inc = r and r:FindFirstChild("IncreaseTrait")
        if not inc then return false end
        local ok = pcall(function() inc:InvokeServer(key) end)
        return ok
    end
    local function setLock(req, locked)
        local r = reqs()
        local lk = r and r:FindFirstChild("LockAttribute")
        if not lk then return false end
        G.tw(0.3)
        local res = nil
        local ok = pcall(function() res = lk:InvokeServer(req, locked == true) end)
        if not ok then return false end
        return res
    end
    function BUILDER.unlockAll()
        if not BUILDER.locked then return end
        for req, _ in pairs(BUILDER.locked) do
            pcall(function() setLock(req, false) end)
        end
        BUILDER.locked = {}
    end
    local function lockIt(req)
        if BUILDER.locked and BUILDER.locked[req] then return end
        BUILDER.locked = BUILDER.locked or {}
        if setLock(req, true) then
            BUILDER.locked[req] = true
            NOTIF.send("Auto Builder", "Reached " .. tostring(req) .. ", Locking.")
        end
    end
    
    
    local function cardLabel(card)
        return card.MantraName or card.RichName or card.Name
    end
    local function pick(card, isSpecial, wanted)
        local r = reqs()
        local tc = r and r:FindFirstChild("TalentChoice")
        if not tc then return false end
        local ok = pcall(function() tc:InvokeServer(card.Name, isSpecial == true) end)
        local kind = (card.Type == "Mantra" and "mantra") or "talent"
        if ok then
            if wanted then NOTIF.send("Auto Builder", "Wanted " .. kind .. " found in hand: Picked " .. tostring(cardLabel(card)))
            else NOTIF.send("Auto Builder", "No wanted " .. kind .. " in hand: Picked " .. tostring(cardLabel(card))) end
        else
            NOTIF.send("Auto Builder", "pick failed: " .. tostring(cardLabel(card)), 4, true)
        end
        return ok
    end
    local function flash(ok)
        local c = ok and P.ok or P.dng
        pcall(function()
            for _, job in ipairs({{el = UI._autoUrlBox, r = 6, tag = "FLASHVEIL_BOX"}, {el = UI._autoLoadBtn, r = 4, tag = "FLASHVEIL_BTN"}}) do
                local el = job.el
                if el and el.Parent and el.Parent:FindFirstChild(job.tag) then
                    pcall(function() el.Parent[job.tag]:Destroy() end)
                end
                if el and el.Parent then
                    local o = G.new("Frame", el.Parent)
                    o.Name = job.tag
                    o.Position = el.Position; o.Size = el.Size
                    o.BackgroundColor3 = c
                    o.BackgroundTransparency = 0.55; o.BorderSizePixel = 0
                    o.Active = false
                    G.mkC(o, job.r)
                    G.TS:Create(o, G.TI(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                    G.ts(function() G.tw(0.65); pcall(function() o:Destroy() end) end)
                end
            end
        end)
    end
    function BUILDER.status()
        if not BUILDER.cfg then return "no build loaded" end
        local id = BUILDER.url and string.match(BUILDER.url, "id=([%w%d]+)") or "?"
        if not BUILDER.shrined then return "build " .. id .. " · pre-shrine" end
        return "build " .. id .. " · post-shrine"
    end
    function BUILDER.load()
        local url = CFG.AutoBuildUrl or ""
        if url == "" then NOTIF.send("Auto Builder", "paste a builder link first"); flash(false); return false end
        local id = string.match(url, "id=([%w%d]+)")
        if not id then NOTIF.send("Auto Builder", "bad link · no build id"); flash(false); return false end
        local btn = UI._autoLoadBtn
        local ticking = btn ~= nil and btn.Parent ~= nil
        local function btnText(s) if btn and btn.Parent then pcall(function() btn.Text = s end) end end
        local function done(ok)
            ticking = false
            btnText(ok and "    loaded" or "    load build")
            if ok then G.ts(function() G.tw(2); btnText("    load build") end) end
        end
        G.ts(function()
            local n = 0
            while ticking do n = n % 3 + 1; btnText("    loading" .. string.rep(".", n)); G.tw(0.3) end
        end)
        local H = {
            ["Content-Type"] = "application/json", ["Accept"] = "application/json",
            ["Origin"] = "https://deepwoken.co", ["Referer"] = "https://deepwoken.co/builder",
        }
        local function fetch(u)
            local body = G.httpGet(u, H)
            if not body or body == "" then return nil end
            local ok, data = pcall(function() return G.HS:JSONDecode(body) end)
            if ok and type(data) == "table" then return data end
            return nil
        end
        local data = fetch("https://new.deepwoken.co/api/proxy/builds/" .. id)
        if not data then data = fetch("https://deepwoken.co/api/proxy/builds/" .. id) end
        if not data then NOTIF.send("Auto Builder", "build api blocked · try again"); flash(false); done(false); return false end
        local talents = fetch("https://new.deepwoken.co/api/proxy/get?type=all") or {}
        local lookup = {}
        for _, t in ipairs((talents and talents.talents) or {}) do
            if t and t.name then lookup[t.name:lower()] = t end
        end
        local pre, post = flat(data.preShrine), flat(data.attributes)
        local traits = {}
        pcall(function()
            local bt = data.stats and data.stats.traits
            if type(bt) == "table" then
                for name, v in pairs(bt) do
                    local key = TRAITS[name]
                    local n = tonumber(v) or 0
                    if key and n > 0 then traits[key] = n end
                end
            end
        end)
        local cfg = {
            talents = data.talents or {}, mantras = data.mantras or {},
            attributes = post, preShrine = pre, stats = data.stats or {},
            traits = traits,
            preT = {}, postT = {},
        }
        local function meets(t, spread)
            if not t then return false end
            if t.requirements and t.requirements.stats then
                for stat, need in pairs(t.requirements.stats) do
                    if (spread[stat] or 0) < need then return false end
                end
                return true
            end
            if t.reqs then
                for _, cat in ipairs({"base", "weapon", "attunement"}) do
                    local cr = t.reqs[cat]
                    if cr then for stat, need in pairs(cr) do
                        if need > 0 and (spread[stat] or 0) < need then return false end
                    end end
                end
                return true
            end
            return true 
        end
        for _, name in ipairs(cfg.talents) do
            local stripped = name:gsub(" %[HVY%]", ""):gsub(" %[LHT%]", ""):gsub(" %[MED%]", "")
            local t = lookup[name:lower()]
            if t then
                if meets(t, pre) and not meets(t, post) then G.ti(cfg.preT, stripped)
                else G.ti(cfg.postT, stripped) end
            else
                
                G.ti(cfg.postT, stripped)
            end
        end
        BUILDER.cfg, BUILDER.url, BUILDER.shrined, BUILDER.logged = cfg, url, false, false
        BUILDER.spent, BUILDER.baseInv, BUILDER.baselined = {}, {}, false
        BUILDER.tSpent, BUILDER.tBase = {}, nil
        BUILDER.tLogged = false
        BUILDER.tEmpty = false
        pcall(function() BUILDER.unlockAll() end)
        NOTIF.send("Auto Builder", "loaded build " .. id)
        flash(true); done(true)
        pcall(UI.refreshRows)
        pcall(function() BUILDER.preview() end)
        return true
    end
    function BUILDER.targets(data)
        local cfg = BUILDER.cfg
        if not cfg then return nil end
        if not BUILDER.shrined then return cfg.preShrine end
        if cfg.attributes and next(cfg.attributes) then return cfg.attributes end
        return cfg.preShrine
    end
    function BUILDER.ready()
        if not BUILDER.cfg then return false end
        local data = playerData()
        if not data then return false end
        local miss = 0
        for label, target in pairs(BUILDER.cfg.preShrine or {}) do
            target = tonumber(target) or 0
            if target > 0 then
                local req = resolve(label)
                if req then miss = miss + G.mx(0, target - statOf(data, req)) end
            end
        end
        return miss == 0
    end
    function BUILDER.done()
        if not BUILDER.cfg or not BUILDER.shrined then return false end
        local data = playerData()
        if not data then return false end
        local miss = 0
        for label, target in pairs(BUILDER.cfg.attributes or {}) do
            target = tonumber(target) or 0
            if target > 0 then
                local req = resolve(label)
                if req then miss = miss + G.mx(0, target - statOf(data, req)) end
            end
        end
        return miss == 0
    end
    function BUILDER.spend()
        if not BUILDER.cfg then return end
        local data = playerData()
        if not data then return end
        local tg = BUILDER.targets(data)
        if not tg or not next(tg) then return end
        local want = {}
        for label, target in pairs(tg) do
            local req = resolve(label)
            if req then
                local goal = tonumber(target) or 0
                G.ti(want, {req = req, target = goal, misses = 0, budget = 0})
            end
        end
        table.sort(want, function(a, b) return a.req < b.req end)
        local fresh, agg = data, {}
        if not BUILDER.baselined then
            fresh, agg = solidData(want)
            if fresh then data = fresh end
            BUILDER.baselined = true
        else
            agg = {}
            for _, e in ipairs(want) do agg[e.req] = statOf(data, e.req) end
        end
        BUILDER.spent = BUILDER.spent or {}
        BUILDER.baseInv = BUILDER.baseInv or {}
        local lines, funding = {}, 0
        for _, e in ipairs(want) do
            local inv = math.max(statOf(data, e.req), agg[e.req] or 0)
            local tru = trueOf(e.req)
            if tru == nil then tru = inv end
            if BUILDER.baseInv[e.req] == nil then BUILDER.baseInv[e.req] = tru end
            local allowed = G.mx(0, e.target - BUILDER.baseInv[e.req])
            local bought = BUILDER.spent[e.req] or 0
            e.budget = G.mx(0, math.min(allowed - bought, e.target - tru))
            local lockedNow = data.LockedAttributes and data.LockedAttributes[e.req] == true
            if lockedNow and tru < e.target then
                if setLock(e.req, false) then
                    if BUILDER.locked then BUILDER.locked[e.req] = nil end
                    data = playerData() or data
                end
            end
            if e.budget > 0 then funding = funding + 1
            elseif e.target > 0 and tru >= e.target then lockIt(e.req) end
            G.ti(lines, string.format("%s true %s / invested %i / base %i / target %i / bought %i -> %s",
                e.req, tostring(tru), inv, BUILDER.baseInv[e.req], e.target, bought,
                e.budget > 0 and ("fund " .. e.budget) or "skip"))
        end
        if not BUILDER.logged then
            BUILDER.logged = true
        end
        if pointsOf(data) <= 0 then return end
        local raised = true
        while raised do
            raised = false
            for _, e in ipairs(want) do
                if not BUILDER.points then return end
                if pointsOf(data) <= 0 then return end
                local live = playerData()
                if not live then return end
                data = live
                local bought = BUILDER.spent[e.req] or 0
                local allowed = G.mx(0, e.target - (BUILDER.baseInv[e.req] or 0))
                local truNow = trueOf(e.req)
                if truNow == nil then truNow = statOf(data, e.req) end
                if e.misses < 2 and bought < allowed and e.budget > 0 and truNow < e.target then
                    local before = truNow
                    if not raise(e.req) then return end
                    e.budget = e.budget - 1
                    G.tw(0.2)
                    local after = playerData()
                    if not after then return end
                    data = after
                    local now = trueOf(e.req)
                    if now == nil then now = statOf(data, e.req) end
                    local gained = now - before
                    if gained > 0 then
                        BUILDER.spent[e.req] = bought + gained
                        e.misses, raised = 0, true
                        if now >= e.target then lockIt(e.req) end
                    else
                        e.misses = e.misses + 1
                    end
                end
            end
        end
    end
    function BUILDER.spendTraits()
        if not BUILDER.cfg then return end
        local tg = BUILDER.cfg.traits
        if not tg or not next(tg) then
            if not BUILDER.tEmpty then
                BUILDER.tEmpty = true
                NOTIF.send("Auto Builder", "traits: no targets in build", 4, true)
            end
            return
        end
        BUILDER.tEmpty = false
        local data = playerData()
        if not data then return end
        local want = {}
        for key, goal in pairs(tg) do
            goal = tonumber(goal) or 0
            if goal > 0 then G.ti(want, {key = key, target = goal, misses = 0, budget = 0}) end
        end
        if #want == 0 then return end
        table.sort(want, function(a, b) return a.key < b.key end)
        BUILDER.tSpent = BUILDER.tSpent or {}
        if BUILDER.tBase == nil then
            BUILDER.tBase = {}
            local d2 = playerData()
            for _, e in ipairs(want) do
                local a = traitOf(data, e.key)
                local b = (d2 and traitOf(d2, e.key)) or 0
                BUILDER.tBase[e.key] = math.max(a, b)
                if d2 then data = d2 end
            end
        end
        local lines, funding = {}, 0
        for _, e in ipairs(want) do
            local cur = traitOf(data, e.key)
            local base = BUILDER.tBase[e.key] or cur
            local allowed = G.mx(0, e.target - base)
            local bought = BUILDER.tSpent[e.key] or 0
            e.budget = G.mx(0, math.min(allowed - bought, e.target - cur))
            if e.budget > 0 then funding = funding + 1 end
            G.ti(lines, string.format("%s current %i / base %i / target %i / bought %i -> %s",
                e.key, cur, base, e.target, bought, e.budget > 0 and ("fund " .. e.budget) or "skip"))
        end
        if not BUILDER.tLogged then
            BUILDER.tLogged = true
            if funding > 0 then
                NOTIF.send("Auto Builder", "funding " .. funding .. " trait" .. (funding == 1 and "" or "s"))
            else
                NOTIF.send("Auto Builder", "traits: nothing to fund", 4, false)
            end
        end
        if traitPointsOf(data) <= 0 then return end
        local raised = true
        while raised do
            raised = false
            for _, e in ipairs(want) do
                if not BUILDER.points then return end
                if traitPointsOf(data) <= 0 then return end
                local live = playerData()
                if not live then return end
                data = live
                local bought = BUILDER.tSpent[e.key] or 0
                local allowed = G.mx(0, e.target - (BUILDER.tBase[e.key] or 0))
                local cur = traitOf(data, e.key)
                if e.misses < 2 and bought < allowed and e.budget > 0 and cur < e.target then
                    if not raiseTrait(e.key) then return end
                    e.budget = e.budget - 1
                    G.tw(0.2)
                    local after = playerData()
                    if not after then return end
                    data = after
                    local now = traitOf(data, e.key)
                    local gained = now - cur
                    if gained > 0 then
                        BUILDER.tSpent[e.key] = bought + gained
                        e.misses, raised = 0, true
                        NOTIF.send("Auto Builder", "Trait " .. e.key .. " " .. cur .. " → " .. now)
                    else
                        e.misses = e.misses + 1
                    end
                end
            end
        end
    end
    local function elements()
        local out = {}
        if not BUILDER.cfg then return out end
        for _, spread in ipairs({BUILDER.cfg.preShrine or {}, BUILDER.cfg.attributes or {}}) do
            for label, v in pairs(spread) do
                if (tonumber(v) or 0) > 0 then
                    local req = resolve(label)
                    if req and string.find(req, "^Element") then out[string.gsub(req, "^Element", "")] = req end
                end
            end
        end
        return out
    end
    local function needLeft(data)
        local left = {}
        if not data then return left end
        local tg = BUILDER.targets(data)
        if not tg then return left end
        for label, v in pairs(tg) do
            local req = resolve(label)
            if req and string.find(req, "^Element") then
                left[string.gsub(req, "^Element", "")] = G.mx(0, (tonumber(v) or 0) - statOf(data, req))
            end
        end
        return left
    end
    local function owns(data, el)
        for _, m in pairs(data.Mantras or {}) do
            if type(m) == "table" then
                if m.Element == el then return true end
                if type(m.Name) == "string" and string.match(m.Name, ":(%w+)$") == el then return true end
            elseif type(m) == "string" and string.match(m, ":(%w+)$") == el then
                return true
            end
        end
        return false
    end
    function BUILDER.wants(name, alt)
        if not name or not BUILDER.cfg then return false end
        local cl = clean(alt or name)
        if cl ~= "" then
            for _, mn in ipairs(BUILDER.cfg.mantras or {}) do
                if clean(mn) == cl then return true end
            end
        end
        for _, tn in ipairs(BUILDER.cfg.preT) do if name:lower() == tn:lower() then return true end end
        for _, tn in ipairs(BUILDER.cfg.postT) do if name:lower() == tn:lower() then return true end end
        return false
    end
    function BUILDER.handle()
        if not BUILDER.cfg then return end
        local data = playerData()
        if not data then
            if not BUILDER.nodata then
                BUILDER.nodata = true
                NOTIF.send("Auto Builder", "no player data · Get failed", 4, true)
            end
            return
        end
        BUILDER.nodata = false
        local cards, isSpecial = nil, false
        if data.SpecialChoice and data.SpecialChoice.Selection and #data.SpecialChoice.Selection > 0 then
            cards, isSpecial = data.SpecialChoice.Selection, true
        elseif data.TalentChoice and data.TalentChoice.Selection and #data.TalentChoice.Selection > 0 then
            cards, isSpecial = data.TalentChoice.Selection, false
        end
        if cards then
            local got = false
            BUILDER.deckTold = BUILDER.deckTold or {}
            local els = elements()
            local training = data.AttributeTrainingMet or {}
            local left = needLeft(data)
            local best, need = nil, -1
            for _, c in ipairs(cards) do
                local tr = c.Element and TRAINS[c.Element]
                if tr and tr[c.Name] and els[c.Element] and not training[els[c.Element]] and not owns(data, c.Element) then
                    local n = left[c.Element] or 0
                    if n > need then best, need = c, n end
                end
            end
            if best then got = pick(best, isSpecial, true) end
            if not got and BUILDER.cfg.traits then
                for _, c in ipairs(cards) do
                    local tkey, tier = traitCard(cardLabel(c))
                    if tkey and tier then
                        local target = tonumber(BUILDER.cfg.traits[tkey]) or 0
                        local cur = tonumber(data["Trait" .. tkey]) or 0
                        if target > 0 and tier <= target - cur and tier > cur then
                            got = pick(c, isSpecial, true)
                            if got then break end
                        end
                    end
                end
            end
            if not got then
                for _, c in ipairs(cards) do
                    if BUILDER.wants(c.Name, cardLabel(c)) then got = pick(c, isSpecial, true); if got then break end end
                end
            end
            if not got then
                for _, c in ipairs(cards) do
                    if c.Name == "Fold" then got = pick(c, isSpecial, false); break end
                end
            end
            if not got then
                local fb, fn = nil, -1
                for _, c in ipairs(cards) do
                    if not BURN[c.Name] and c.Type == "Mantra" and c.Element and els[c.Element] then
                        local n = left[c.Element] or 0
                        if n > fn then fb, fn = c, n end
                    end
                end
                if not fb then for _, c in ipairs(cards) do if not BURN[c.Name] then fb = c; break end end end
                if fb then pick(fb, isSpecial, false)
                else NOTIF.send("Auto Builder", "hand skipped · all burned", 4, true) end
            end
        end
        if type(firesignal) == "function" then
            pcall(function()
                local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
                local bg = pg and pg:FindFirstChild("BackpackGui")
                local deck = bg and bg:FindFirstChild("LeftFrame") and bg.LeftFrame:FindFirstChild("DeckFrame")
                if deck and deck.Visible then
                    
                    
                    local ts = deck:FindFirstChild("TalentScroll")
                    if ts then
                        for _, c in ipairs(ts:GetChildren()) do
                            if c:IsA("TextButton") then
                                local title = c:FindFirstChild("Title")
                                local nm = (title and title.Text ~= "") and title.Text or c.Name
                                if BUILDER.wants(nm) and not BUILDER.deckTold[nm] then
                                    BUILDER.deckTold[nm] = true
                                    firesignal(c.MouseButton1Click, c)
                                    NOTIF.send("Auto Builder", "Wanted talent found in hand: Picked " .. tostring(nm))
                                end
                            end
                        end
                    end
                end
                local cp = pg and pg:FindFirstChild("ChoicePrompt")
                local sf = cp and cp:FindFirstChild("ScrollingFrame", true)
                if sf then
                    for _, ch in ipairs(sf:GetChildren()) do
                        local cf = ch:FindFirstChild("CardFrame")
                        if cf then
                            local title = cf:FindFirstChild("Title")
                            local nm = (title and title.Text ~= "") and title.Text or cf.Name
                            if BUILDER.wants(nm) and not BUILDER.deckTold[nm] then
                                BUILDER.deckTold[nm] = true
                                firesignal(cf.MouseButton1Click, cf)
                                NOTIF.send("Auto Builder", "Wanted talent found in hand: Picked " .. tostring(nm))
                            end
                        end
                    end
                end
            end)
        end
    end
    function BUILDER.start()
        if BUILDER.running then return end
        if not BUILDER.cfg and not BUILDER.load() then S.autoBuild = false; return end
        BUILDER.running = true
        G.ts(function()
            while BUILDER.running do
                pcall(function() BUILDER.handle() end)
                G.tw(0.5)
            end
        end)
        NOTIF.send("Auto Builder", "talent picker on")
    end
    function BUILDER.stop()
        BUILDER.running = false
        NOTIF.send("Auto Builder", "talent picker off")
    end
    function BUILDER.startPts()
        if BUILDER.points then return end
        if not BUILDER.cfg and not BUILDER.load() then S.autoPoints = false; return end
        BUILDER.points, BUILDER.logged = true, false
        G.ts(function()
            while BUILDER.points do
                pcall(function()
                    if not BUILDER.shrined and BUILDER.ready() then
                        NOTIF.send("Auto Builder", "shrine targets met · mark shrined when done")
                    end
                end)
                pcall(function() BUILDER.spend() end)
                pcall(function() BUILDER.spendTraits() end)
                G.tw(2)
            end
        end)
        NOTIF.send("Auto Builder", "stat spender on")
    end
    function BUILDER.stopPts()
        BUILDER.points = false
        NOTIF.send("Auto Builder", "stat spender off")
    end
    BUILDER.FALLBACK = {
        ElementFire = {ab = "FLM", nm = "Flamecharm", bg = {110, 80, 50}, tx = {243, 216, 189}, st = {48, 36, 20}},
        ElementIce = {ab = "ICE", nm = "Frostdraw", bg = {99, 117, 116}, tx = {232, 248, 247}, st = {48, 36, 20}},
        ElementLightning = {ab = "LTN", nm = "Thundercall", bg = {100, 91, 43}, tx = {236, 228, 185}, st = {48, 36, 20}},
        ElementWind = {ab = "WND", nm = "Galebreathe", bg = {87, 115, 91}, tx = {221, 246, 225}, st = {48, 36, 20}},
        ElementShadow = {ab = "SDW", nm = "Shadowcast", bg = {46, 43, 61}, tx = {196, 194, 209}, st = {48, 36, 20}},
        ElementMetal = {ab = "MTL", nm = "Ironsing", bg = {67, 74, 82}, tx = {210, 217, 224}, st = {48, 36, 20}},
        ElementBlood = {ab = "BLD", nm = "Bloodrend", bg = {110, 69, 70}, tx = {243, 206, 206}, st = {48, 36, 20}},
    }
    BUILDER.ICONS = {
        Strength = "rbxassetid://6403599529", Fortitude = "rbxassetid://6403549017",
        Agility = "rbxassetid://6403481967", Intelligence = "rbxassetid://6403561668",
        Willpower = "rbxassetid://6403585311", Charisma = "rbxassetid://6403575739",
        WeaponHeavy = "rbxassetid://6403599529", WeaponMedium = "rbxassetid://6403599529",
        WeaponLight = "rbxassetid://6403599529",
        ElementFire = "rbxassetid://6403488990", ElementIce = "rbxassetid://6403490326",
        ElementLightning = "rbxassetid://6403492643", ElementWind = "rbxassetid://6459093770",
        ElementShadow = "rbxassetid://6403499496",
    }
    BUILDER.NAMES = {
        Strength = "Strength", Fortitude = "Fortitude", Agility = "Agility",
        Intelligence = "Intelligence", Willpower = "Willpower", Charisma = "Charisma",
        WeaponHeavy = "Heavy", WeaponMedium = "Medium", WeaponLight = "Light",
        ElementFire = "Flamecharm", ElementIce = "Frostdraw", ElementLightning = "Thundercall",
        ElementWind = "Galebreathe", ElementShadow = "Shadowcast", ElementMetal = "Ironsing",
        ElementBlood = "Bloodrend",
    }
    BUILDER.COLS = {
        Strength = G.RGB(128, 89, 74), Fortitude = G.RGB(128, 119, 88),
        Agility = G.RGB(101, 128, 98), Intelligence = G.RGB(98, 99, 128),
        Willpower = G.RGB(89, 122, 128), Charisma = G.RGB(128, 97, 120),
        WeaponHeavy = G.RGB(88, 102, 128), WeaponMedium = G.RGB(128, 108, 83),
        WeaponLight = G.RGB(99, 128, 101),
        ElementFire = G.RGB(110, 80, 50), ElementIce = G.RGB(99, 117, 116),
        ElementLightning = G.RGB(100, 91, 43), ElementWind = G.RGB(87, 114, 91),
        ElementShadow = G.RGB(46, 43, 60), ElementMetal = G.RGB(67, 74, 81),
        ElementBlood = G.RGB(110, 69, 70),
    }
    BUILDER.VCOL = {        Strength = G.RGB(255, 220, 206), Fortitude = G.RGB(255, 247, 219),
        Agility = G.RGB(231, 255, 228), Intelligence = G.RGB(228, 230, 255),
        Willpower = G.RGB(220, 250, 255), Charisma = G.RGB(255, 228, 249),
        WeaponHeavy = G.RGB(219, 231, 255), WeaponMedium = G.RGB(255, 237, 215),
        WeaponLight = G.RGB(229, 255, 231),
        ElementFire = G.RGB(243, 216, 189), ElementIce = G.RGB(232, 248, 247),
        ElementLightning = G.RGB(236, 228, 185), ElementWind = G.RGB(221, 246, 225),
        ElementShadow = G.RGB(196, 194, 209), ElementMetal = G.RGB(210, 217, 224),
        ElementBlood = G.RGB(243, 206, 206),
    }
    BUILDER.ABBR = {Strength = "STR", Fortitude = "FTD", Agility = "AGL", Intelligence = "INT",
        Willpower = "WLL", Charisma = "CHA", WeaponHeavy = "HVY", WeaponMedium = "MED", WeaponLight = "LHT",
        ElementFire = "FLM", ElementIce = "ICE", ElementLightning = "LTN", ElementWind = "WND",
        ElementShadow = "SDW", ElementMetal = "MTL", ElementBlood = "BLD"}
    BUILDER.GROUPS = {
        {label = "BODY", reqs = {"Strength", "Fortitude", "Agility"}},
        {label = "WEAPONS", reqs = {"WeaponHeavy", "WeaponMedium", "WeaponLight"}},
        {label = "MIND", reqs = {"Intelligence", "Willpower", "Charisma"}},
        {label = "ELEMENTS", reqs = {"ElementFire", "ElementIce", "ElementLightning", "ElementWind", "ElementShadow", "ElementMetal", "ElementBlood"}},
    }
    function BUILDER.spread(mode)
        if not BUILDER.cfg then return {} end
        local src = (mode == "post" and BUILDER.cfg.attributes) or BUILDER.cfg.preShrine
        local out = {}
        for label, v in pairs(src or {}) do
            v = tonumber(v) or 0
            if v > 0 then
                local req = resolve(label)
                if req then out[req] = math.max(out[req] or 0, v) end
            end
        end
        return out
    end
    function BUILDER.preview()
        local host = UI._prevStats
        if not host or not host.Parent then return end
        for _, c in ipairs(host:GetChildren()) do pcall(function() c:Destroy() end) end
        local mode = UI._prevMode or "pre"
        if not BUILDER.cfg then
            G.mkL(host, "load a build to preview", 8, 8, 260, 16, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
            if UI._prevBtns then UI._prevBtns(mode) end
            BUILDER.model()
            return
        end
        local got = BUILDER.spread(mode)
        local y = 6
        local src = {}
        pcall(function()
            local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
            local sh = pg and pg:FindFirstChild("BackpackGui")
            local rf = sh and sh:FindFirstChild("RightFrame")
            local jf = rf and rf:FindFirstChild("JournalFrame")
            local pn = jf and jf:FindFirstChild("Panels")
            local af = pn and pn:FindFirstChild("AttributeFrame")
            local sts = af and af:FindFirstChild("Sheets")
            local function grab(c) for _, b in ipairs(c:GetChildren()) do if b:IsA("TextButton") then src[b.Name] = b end end end
            if sts then
                local ls = sts:FindFirstChild("LeftSheets")
                local ac = ls and ls:FindFirstChild("AttrSheet")
                local acc = ac and ac:FindFirstChild("Container", true)
                if acc then grab(acc) end
                local rs = sts:FindFirstChild("RightSheets")
                if rs then
                    local wc = rs:FindFirstChild("WeaponSheet")
                    local wcc = wc and wc:FindFirstChild("Container", true)
                    if wcc then grab(wcc) end
                    local ec = rs:FindFirstChild("ElementSheet")
                    local ecc = ec and ec:FindFirstChild("Container", true)
                    if ecc then grab(ecc) end
                end
            end
        end)
        local function med(x, yy, req, v)
            local RING = "rbxassetid://99030585552528"
            local CREAM = G.RGB(231, 255, 228)
            local DSTROKE = G.RGB(21, 16, 9)
            local s = src[req]
            if s then
                local c = pcall(function()
                    local b = s:Clone()
                    b.Name = "PV_" .. req
                    b.Position = G.UD2(0, x + 10, 0, yy); b.Size = G.UD2(0, 50, 0, 50)
                    b.Visible = true
                    b.AutoButtonColor = false
                    local tr = b:FindFirstChild("Train"); if tr then tr:Destroy() end
                    local it = b:FindFirstChild("Intent"); if it then it:Destroy() end
                    local vv = b:FindFirstChild("Value"); if vv then vv.Text = tostring(v) end
                    b.Parent = host
                    return b
                end)
                if c then return end
            end
            local fb = BUILDER.FALLBACK and BUILDER.FALLBACK[req]
            local chS = fb and src["Charisma"]
            if chS then
                local c = pcall(function()
                    local b = chS:Clone()
                    b.Name = "PV_" .. req
                    b.Position = G.UD2(0, x + 10, 0, yy); b.Size = G.UD2(0, 50, 0, 50)
                    b.Visible = true
                    b.AutoButtonColor = false
                    local tr = b:FindFirstChild("Train"); if tr then tr:Destroy() end
                    local it = b:FindFirstChild("Intent"); if it then it:Destroy() end
                    local bgc = G.RGB(fb.bg[1], fb.bg[2], fb.bg[3])
                    local txc = G.RGB(fb.tx[1], fb.tx[2], fb.tx[3])
                    local stc = G.RGB(fb.st[1], fb.st[2], fb.st[3])
                    local bg = b:FindFirstChild("Background"); if bg then bg.BackgroundColor3 = bgc end
                    local ab = b:FindFirstChild("Abbrev")
                    if ab then
                        ab.Text = fb.ab; ab.TextColor3 = txc
                        local st = ab:FindFirstChildOfClass("UIStroke"); if st then st.Color = stc end
                    end
                    local vv = b:FindFirstChild("Value")
                    if vv then
                        vv.Text = tostring(v); vv.TextColor3 = txc
                        local st = vv:FindFirstChildOfClass("UIStroke"); if st then st.Color = stc end
                    end
                    local lb = b:FindFirstChild("Label")
                    if lb then
                        lb.Text = fb.nm; lb.TextColor3 = txc
                        local st = lb:FindFirstChildOfClass("UIStroke"); if st then st.Color = stc end
                    end
                    b.Parent = host
                    return b
                end)
                if c then return end
            end
            local col = BUILDER.COLS[req] or P.tx
            local ab = BUILDER.ABBR[req] or "???"
            local nm = BUILDER.NAMES[req] or req
            local vc = BUILDER.VCOL[req] or G.RGB(255, 255, 255)
            local abl = G.mkL(host, ab, x, yy, 70, 10, 8, Enum.Font.Code, Enum.TextXAlignment.Center, vc, true)
            G.fFace(abl, "abbr")
            local disc = G.new("Frame", host)
            disc.Position = G.UD2(0, x + 21, 0, yy + 11); disc.Size = G.UD2(0, 28, 0, 28)
            disc.BackgroundColor3 = col; disc.BorderSizePixel = 0
            G.mkC(disc, 14)
            local ring = G.new("ImageLabel", host)
            ring.Position = G.UD2(0, x + 18, 0, yy + 8); ring.Size = G.UD2(0, 34, 0, 36)
            ring.BackgroundTransparency = 1; ring.Image = RING
            ring.ImageRectOffset = G.V2(102, 0); ring.ImageRectSize = G.V2(34, 36)
            ring.ImageColor3 = G.RGB(230, 230, 230)
            local vl = G.new("TextLabel", host)
            vl.Position = G.UD2(0, x + 20, 0, yy + 10); vl.Size = G.UD2(0, 30, 0, 30)
            vl.BackgroundTransparency = 1
            vl.Font = Enum.Font.GothamBold; vl.TextSize = 16; vl.TextColor3 = BUILDER.VCOL[req] or G.RGB(255, 255, 255)
            vl.TextStrokeTransparency = 0.5; vl.TextStrokeColor3 = DSTROKE
            vl.Text = tostring(v)
            G.fFace(vl)
            local nml = G.mkL(host, nm, x, yy + 46, 70, 12, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Center, CREAM, true)
            G.fFace(nml, "name")
        end
        for _, gr in ipairs(BUILDER.GROUPS) do
            local live = {}
            for _, req in ipairs(gr.reqs) do if got[req] and got[req] > 0 then G.ti(live, req) end end
            if #live > 0 then
                local sum = 0
                for _, req in ipairs(live) do sum = sum + (got[req] or 0) end
                local gl = G.mkL(host, gr.label, 8, y, 220, 14, 14, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, G.RGB(255, 255, 255))
                gl.RichText = false
                pcall(function() if G.fDiv then gl.FontFace = G.fDiv end end)
                local gl2 = G.new("Frame", host)
                gl2.Position = G.UD2(0, 8, 0, y + 16); gl2.Size = G.UD2(1, -16, 0, 1)
                gl2.BackgroundColor3 = P.brd; gl2.BorderSizePixel = 0; gl2.BackgroundTransparency = 0.3
                y = y + 22
                for i, req in ipairs(live) do
                    local col4 = (i - 1) % 4
                    local row4 = math.floor((i - 1) / 4)
                    med(2 + col4 * 74, y + row4 * 78, req, got[req])
                end
                y = y + math.ceil(#live / 4) * 78 + 10
            end
        end
        host.CanvasSize = G.UD2(0, 0, 0, y + 12)
        if UI._prevBtns then UI._prevBtns(mode) end
        BUILDER.model()
    end
    function BUILDER.model(force)
        local vp = UI._prevVP
        if not vp or not vp.Parent then return end
        local ch = G.LP and G.LP.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not ch or not hrp then return end
        local wm = vp:FindFirstChild("WM")
        if not force and wm and UI._prevChar == ch and wm:FindFirstChildOfClass("Model") then return end
        UI._prevChar = ch
        if wm then pcall(function() wm:Destroy() end) end
        wm = G.new("WorldModel", vp); wm.Name = "WM"
        local m = pcall(function()
            local c = ch:Clone()
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("LuaSourceContainer") then d:Destroy()
                elseif d:IsA("Animator") or d:IsA("AnimationController") then d:Destroy()
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
                    or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then d:Destroy() end
            end
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("Sound") or d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
                    pcall(function() d:Destroy() end)
                end
            end
            c.Parent = wm
            return c
        end)
        if not m then return end
        local mdl = wm:FindFirstChildOfClass("Model")
        if not mdl then return end
        UI._prevBase = G.CF(0, 3, 0)
        UI._prevRot = UI._prevRot or math.pi
        pcall(function() mdl:PivotTo(UI._prevBase * CFrame.Angles(0, UI._prevRot, 0)) end)
        local cam = vp:FindFirstChildOfClass("Camera") or G.new("Camera", vp)
        vp.CurrentCamera = cam
        cam.CFrame = G.CF(G.V3(1, 3.3, 5.3), G.V3(0, 2.8, 0))
    end
    function BUILDER.wipe()
        BUILDER.stop(); BUILDER.stopPts()
        BUILDER.cfg, BUILDER.url, BUILDER.shrined, BUILDER.logged, BUILDER.nodata = nil, nil, false, false, false
        BUILDER.lastHand, BUILDER.deckTold, BUILDER.spent, BUILDER.baseInv, BUILDER.baselined = nil, {}, {}, {}, false
        BUILDER.tSpent, BUILDER.tBase = {}, nil
        BUILDER.tLogged = false
        BUILDER.tEmpty = false
        pcall(function() BUILDER.unlockAll() end)
        pcall(UI.refreshRows)
        pcall(function() BUILDER.preview() end)
    end
end


local KBHUD = {gui = nil, frame = nil, list = nil, conn = nil, dragConn = nil, rows = {}, last = 0}
do
    local NAMES = {
        pktPlk = "New Breaker", esp = "Player ESP", espBox = "Show Box", espLvl = "Show Level",
        espHp = "Show HP %", htnl = "Health Text", espGlobal = "Use Global Settings",
        mobEsp = "Mob ESP", nEsp = "NPC ESP", cEsp = "Chest ESP", spec = "Spectator",
        specRobloxNames = "View Roblox Names", autoloot = "Auto Loot",
        agil = "Agility + Speed", agSpd = "Speed Bonus", mSpd = "Mantra Speed",
        nc = "No-Clip", nfd = "No Fall Damage", fly = "Fly", aSpd = "Anim Speed",
        opt = "Super Optimize", fps = "FPS Limiter", nkb = "No Kill Bricks",
        npcFreeze = "NPC Freezer", modDetector = "Mod Detector",
        humanoidPathfindBreaker = "Pathfind Breaker", attachToBack = "Attach To Back",
        effDisable = "Effect Disabler", sanityHud = "Sanity HUD", bright = "Full bright", noVis = "Fog Disabler", showChat = "Show Chat", kbHud = "Keybinds",
        autoBuild = "Auto Builder", autoPoints = "Stat Spender",
    }
    local ORDER = {"pktPlk","esp","espBox","espLvl","espHp","htnl","espGlobal","mobEsp","nEsp","cEsp","spec","specRobloxNames","autoloot","agil","agSpd","mSpd","nc","nfd","fly","aSpd","opt","fps","nkb","npcFreeze","modDetector","humanoidPathfindBreaker","attachToBack","effDisable","sanityHud","bright","noVis","showChat","autoBuild","autoPoints"}
    local function rebuild()
        if not KBHUD.list then return end
        for _, r in pairs(KBHUD.rows) do pcall(function() r.row:Destroy() end) end
        G.tc(KBHUD.rows)
        local n = 0
        for _, feat in ipairs(ORDER) do
            if kb[feat] then
                local row = G.new("Frame", KBHUD.list)
                row.Size = G.UD2(1, 0, 0, 18); row.Position = G.UD2(0, 0, 0, n * 18)
                row.BackgroundTransparency = 1; row.BorderSizePixel = 0
                local chip = G.new("TextLabel", row)
                chip.Size = G.UD2(0, 56, 0, 18); chip.Position = G.UD2(0, 6, 0, 0)
                chip.BackgroundTransparency = 1
                chip.Font = Enum.Font.Code; chip.TextSize = 12; chip.TextColor3 = P.amb
                chip.TextStrokeTransparency = 1
                chip.TextXAlignment = Enum.TextXAlignment.Left
                chip.Text = "[" .. G.kName(kb[feat]) .. "]"
                local nm = G.new("TextLabel", row)
                nm.Size = G.UD2(1, -72, 0, 18); nm.Position = G.UD2(0, 80, 0, 0)
                nm.BackgroundTransparency = 1
                nm.Font = Enum.Font.GothamMedium; nm.TextSize = 12; nm.TextColor3 = P.tx
                nm.TextStrokeTransparency = 1
                nm.TextXAlignment = Enum.TextXAlignment.Left
                nm.TextTruncate = Enum.TextTruncate.AtEnd
                nm.Text = NAMES[feat] or feat
                KBHUD.rows[feat] = {row = row, chip = chip, nm = nm}
                n = n + 1
            end
        end
        KBHUD.frame.Size = G.UD2(0, 160, 0, math.max(48, 46 + n * 18))
    end
    local function refresh()
        if not KBHUD.list then return end
        for feat, r in pairs(KBHUD.rows) do
            local on = S[feat] == true
            r.chip.Text = "[" .. G.kName(kb[feat]) .. "]"
            r.chip.TextColor3 = on and P.amb or P.mt
            r.nm.TextColor3 = on and P.tx or P.mt
        end
    end
    function KBHUD.en()
        if KBHUD.gui then rebuild(); return end
        local sg = G.new("ScreenGui"); sg.Name = UC.RN .. "_KEYS"
        sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.DisplayOrder = 151
        sg:SetAttribute("KI", true); G.protG(sg); sg.Parent = G.getHP()
        KBHUD.gui = sg
        local f = G.new("Frame", sg)
        f.Size = G.UD2(0, 160, 0, 48)
        if CFG.KbHudPos and type(CFG.KbHudPos) == "table" then
            f.Position = G.UD2(CFG.KbHudPos.sx or 0.85, math.floor(CFG.KbHudPos.ox or -105), CFG.KbHudPos.sy or 0.4, math.floor(CFG.KbHudPos.oy or 0))
        else
            f.Position = G.UD2(0.85, -105, 0.4, 0)
        end
        f.BackgroundColor3 = P.base; f.BackgroundTransparency = 0.25; f.BorderSizePixel = 0
        G.mkC(f, 3); G.mkS(f, P.brd, 1, 0)
        KBHUD.frame = f
        local drag, dIn, dSt, sPos = false, nil, nil, nil
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag, dSt, sPos = true, i.Position, f.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        drag = false
                        pcall(function()
                            CFG.KbHudPos = {sx = f.Position.X.Scale, ox = math.floor(f.Position.X.Offset), sy = f.Position.Y.Scale, oy = math.floor(f.Position.Y.Offset)}
                        end)
                    end
                end)
            end
        end)
        f.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dIn = i end
        end)
        if KBHUD.dragConn then pcall(function() KBHUD.dragConn:Disconnect() end) end
    KBHUD.dragConn = G.UIS.InputChanged:Connect(function(i)
            if drag and i == dIn then
                local d = i.Position - dSt
                f.Position = G.UD2(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
            end
        end)
        local t = G.new("TextLabel", f)
        t.Size = G.UD2(1, -12, 0, 18); t.Position = G.UD2(0, 6, 0, 4); t.BackgroundTransparency = 1
        t.Font = Enum.Font.Garamond; t.TextSize = 12; t.TextColor3 = P.amb
        t.TextStrokeTransparency = 1
        t.Text = "K E Y B I N D S"; t.TextXAlignment = Enum.TextXAlignment.Left
        local div = G.new("Frame", f)
        div.Size = G.UD2(1, -24, 0, 1); div.Position = G.UD2(0, 12, 0, 26)
        div.BackgroundColor3 = P.brd; div.BorderSizePixel = 0
        local dia = G.new("Frame", f)
        dia.Size = G.UD2(0, 6, 0, 6); dia.Position = G.UD2(0.5, -3, 0, 23)
        dia.BackgroundColor3 = P.amb; dia.BorderSizePixel = 0; dia.Rotation = 45
        local lf = G.new("Frame", f)
        lf.Size = G.UD2(1, -12, 1, -32); lf.Position = G.UD2(0, 6, 0, 30); lf.BackgroundTransparency = 1
        lf.BorderSizePixel = 0
        KBHUD.list = lf
        rebuild(); refresh()
        KBHUD.conn = G.RS.Heartbeat:Connect(function()
            local now = G.ck(); if now - KBHUD.last < 0.25 then return end; KBHUD.last = now
            pcall(refresh)
        end)
    end
    function KBHUD.hintDirty() if KBHUD.gui then rebuild(); refresh() end end
    function KBHUD.dis()
        if KBHUD.conn then KBHUD.conn:Disconnect(); KBHUD.conn = nil end
        if KBHUD.dragConn then pcall(function() KBHUD.dragConn:Disconnect() end); KBHUD.dragConn = nil end
        if KBHUD.gui then pcall(function() KBHUD.gui:Destroy() end); KBHUD.gui = nil end
        KBHUD.frame, KBHUD.list, KBHUD.last = nil, nil, 0
        G.tc(KBHUD.rows)
    end
end


local HALLOW_PLACE = 8668476218
local GOURD = {running = false, token = nil, conns = {}, idle = 0, lastShrine = 0, lastLoot = 0, lastLootRun = 0, ncOwn = false}
do
    local SHRINE = G.V3(-16752.7832, 59, 12144.7754)
    local SAFE = G.V3(-16759.3, 65.7, 12240.1)
    local HOVER, HOLD, SWING, MOB_T = 15, 1.5, 0.9, 30
    local TRAVEL_T, ARRIVE, ARENA = 8, 1.5, 400
    local CHEST_H, CHEST_IDLE, CHEST_T, CHEST_RETRY, LOOT_COOL = 3, 15, 4, 25, 0.2
    local SHRINE_IDLE, SHRINE_COOL = 20, 15

    local function fmt(sec)
        local s = math.max(0, math.floor(sec))
        return string.format("%02d:%02d", math.floor(s / 60), s % 60)
    end

    local function hudMake()
        if GOURD.hud and GOURD.hud.Parent then return GOURD.hud end
        local sg = G.new("ScreenGui")
        sg.Name = "ArchiveGourd"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        sg.DisplayOrder = 999; sg:SetAttribute("KI", true)
        G.protG(sg); sg.Parent = G.getHP()
        local f = G.new("Frame", sg)
        f.Name = "Panel"; f.Size = G.UD2(0, 236, 0, 74)
        local p = CFG.GourdHudPos
        if type(p) == "table" and p.sx ~= nil then
            f.Position = G.UD2(p.sx, p.ox or 20, p.sy, p.oy or 130)
        else
            f.Position = G.UD2(0, 20, 0, 130)
        end
        f.BackgroundColor3 = P.base; f.BackgroundTransparency = 0.1; f.BorderSizePixel = 0
        f.Active = true; f.ClipsDescendants = true
        G.mkC(f, 6); G.mkS(f, P.amb, 1, 0.55)
        G.mkL(f, "HALLOWTIDE", 10, 6, 120, 14, 12, Enum.Font.GothamBold, Enum.TextXAlignment.Left, P.amb)
        local tot = G.mkL(f, "00:00", 0, 6, 90, 14, 12, Enum.Font.GothamBold, Enum.TextXAlignment.Right, P.mt)
        tot.Position = G.UD2(1, -100, 0, 6); tot.Size = G.UD2(0, 90, 0, 14)
        local tl = G.mkL(f, "starting", 10, 26, 216, 18, 12, Enum.Font.Gotham, Enum.TextXAlignment.Left, P.tx)
        tl.TextTruncate = Enum.TextTruncate.AtEnd
        local bar = G.new("Frame", f)
        bar.Position = G.UD2(0, 10, 0, 50); bar.Size = G.UD2(1, -20, 0, 1)
        bar.BackgroundColor3 = P.amb; bar.BackgroundTransparency = 0.8; bar.BorderSizePixel = 0
        local sub = G.mkL(f, "task 00:00", 10, 54, 216, 14, 12, Enum.Font.Gotham, Enum.TextXAlignment.Left, P.mt)
        GOURD.hud, GOURD.frame, GOURD.taskL, GOURD.timeL, GOURD.totalL = sg, f, tl, sub, tot
        GOURD.taskStart, GOURD.totalStart = G.ck(), G.ck()
        local drag, ds, fp = false, nil, nil
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag, ds, fp = true, i.Position, f.Position
            end
        end)
        G.ti(GOURD.conns, G.UIS.InputChanged:Connect(function(i)
            if not drag or not ds or not fp then return end
            if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
            local d = i.Position - ds
            f.Position = G.UD2(fp.X.Scale, math.floor(fp.X.Offset + d.X), fp.Y.Scale, math.floor(fp.Y.Offset + d.Y))
        end))
        G.ti(GOURD.conns, G.UIS.InputEnded:Connect(function(i)
            if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
            if not drag then return end
            drag = false
            local q = f.Position
            CFG.GourdHudPos = {sx = q.X.Scale, ox = math.floor(q.X.Offset), sy = q.Y.Scale, oy = math.floor(q.Y.Offset)}
        end))
        G.ti(GOURD.conns, G.RS.Heartbeat:Connect(function()
            if not GOURD.hud or not GOURD.hud.Parent then return end
            GOURD.totalL.Text = fmt(G.ck() - GOURD.totalStart)
            GOURD.timeL.Text = "task " .. fmt(G.ck() - GOURD.taskStart)
        end))
        return sg
    end

    local function hudKill()
        for _, c in ipairs(GOURD.conns) do pcall(function() c:Disconnect() end) end
        G.tc(GOURD.conns)
        if GOURD.hud then pcall(function() GOURD.hud:Destroy() end) end
        GOURD.hud, GOURD.frame, GOURD.taskL, GOURD.timeL, GOURD.totalL = nil, nil, nil, nil, nil
    end

    local function setTask(text, group)
        GOURD.taskText = text
        if not GOURD.hud or not GOURD.hud.Parent then hudMake() end
        if not GOURD.taskL then return end
        local g = group or text
        if GOURD.group ~= g then GOURD.group, GOURD.taskStart = g, G.ck() end
        if GOURD.taskL.Text ~= text then GOURD.taskL.Text = text end
    end

    local function refs()
        local hrp, hum = G.myR(), G.myH()
        if not hrp or not hum then return false end
        GOURD.hrp, GOURD.hum, GOURD.cam = hrp, hum, G.WS.CurrentCamera
        return true
    end
    local function dead()
        local hum = G.myH()
        return hum == nil or hum.Health <= 0
    end
    local function waitChar()
        while GOURD.running do
            if refs() then return true end
            G.tw(0.5)
        end
        return false
    end
    local function waitRespawn()
        while GOURD.running and dead() do G.tw(0.5); refs() end
        return refs()
    end

    local function pin(goalOf, stopOf, maxT)
        if not GOURD.running or not refs() then return false end
        local conn
        conn = G.RS.Heartbeat:Connect(function(dt)
            local hrp = GOURD.hrp
            if not GOURD.running or not hrp or not hrp.Parent then conn:Disconnect(); return end
            local goal = goalOf()
            if not goal then return end
            local delta = goal - hrp.Position
            local dist = delta.Magnitude
            if dist > 0.1 then hrp.CFrame = hrp.CFrame + delta.Unit * G.mc(dist * 8, 0, 120) * dt end
            hrp.Velocity = G.V3(0, 0, 0)
            if GOURD.cam then GOURD.cam.CFrame = G.CF(hrp.Position, G.V3(goal.X, goal.Y - HOVER, goal.Z)) end
        end)
        local t0, ok = G.ck(), false
        while GOURD.running and (G.ck() - t0) < maxT do
            if stopOf and stopOf() then ok = true; break end
            G.tw()
        end
        conn:Disconnect()
        return ok
    end
    local function travel(pos, maxT)
        return pin(function() return pos end, function()
            local hrp = GOURD.hrp
            return hrp ~= nil and hrp.Parent ~= nil and (hrp.Position - pos).Magnitude <= ARRIVE
        end, maxT or TRAVEL_T)
    end
    local function hover(goalOf, dur) return pin(goalOf, nil, dur) end
    local function inArena()
        local hrp = GOURD.hrp
        return hrp ~= nil and (hrp.Position - SAFE).Magnitude < ARENA
    end

    local function mobAlive(m)
        if not m or not m.Parent then return false end
        local hum = m:FindFirstChildOfClass("Humanoid")
        return hum ~= nil and hum.Health > 0 and m:FindFirstChild("HumanoidRootPart") ~= nil
    end
    local function mobs()
        local list, live = {}, G.WS:FindFirstChild("Live")
        if not live then return list end
        for _, m in ipairs(live:GetChildren()) do
            if m:IsA("Model") and string.find(string.lower(m.Name), "pumpskipper", 1, true) and mobAlive(m) then
                G.ti(list, m)
            end
        end
        table.sort(list, function(a, b)
            local pa, pb = a:FindFirstChild("HumanoidRootPart"), b:FindFirstChild("HumanoidRootPart")
            if not pa or not pb then return false end
            return (pa.Position - SAFE).Magnitude < (pb.Position - SAFE).Magnitude
        end)
        return list
    end

    local function promptText()
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
        local sp = pg and pg:FindFirstChild("SimplePrompt")
        if not sp then return "" end
        local parts = {}
        for _, d in ipairs(sp:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text ~= "" then G.ti(parts, d.Text) end
        end
        return string.lower(table.concat(parts, " | "))
    end
    local function blocked()
        local t = promptText()
        if t == "" then return false end
        for _, w in ipairs({"recover", "wave", "stir", "survive", "remain"}) do
            if string.find(t, w, 1, true) then return true end
        end
        return false
    end
    local function shrine()
        local hw = G.WS:FindFirstChild("HallowtideWaves")
        local a = hw and hw:FindFirstChild("HallowtideShrine")
        if a then return a end
        local th = G.WS:FindFirstChild("Thrown")
        return th and th:FindFirstChild("HallowtideShrine")
    end
    local function fireShrine()
        local sh = shrine()
        if not sh then return false end
        local pp = sh:FindFirstChild("InteractPrompt")
        if not (pp and pp:IsA("ProximityPrompt")) then
            pp = nil
            for _, d in ipairs(sh:GetDescendants()) do
                if d:IsA("ProximityPrompt") then pp = d; break end
            end
        end
        if not pp then return false end
        pcall(fireproximityprompt, pp)
        return true
    end

    local function chestPos(c)
        local r = c and c:FindFirstChild("RootPart")
        if r then return r.Position end
        if c and c:IsA("Model") then
            local ok, p = pcall(function() return c:GetPivot().Position end)
            if ok then return p end
        end
        return nil
    end
    local function isChest(m)
        return m:IsA("Model")
            and m.Name ~= "HallowtideShrine"
            and not string.find(string.lower(m.Name), "pumpskipper", 1, true)
            and m:FindFirstChildOfClass("Humanoid") == nil
            and m:FindFirstChild("RootPart") ~= nil
    end
    local function chests()
        local out, seen = {}, {}
        local function scan(par, depth)
            if not par then return end
            for _, c in ipairs(par:GetChildren()) do
                if not seen[c] then
                    if c:IsA("Model") and isChest(c) then
                        seen[c] = true
                        local p = chestPos(c)
                        if p and (p - SAFE).Magnitude < ARENA * 3 then G.ti(out, c) end
                    elseif depth > 0 and c:IsA("Model") then
                        scan(c, depth - 1)
                    end
                end
            end
        end
        scan(G.WS:FindFirstChild("Chests"), 1)
        scan(G.WS:FindFirstChild("Thrown"), 1)
        table.sort(out, function(a, b)
            local pa, pb = chestPos(a), chestPos(b)
            if not pa or not pb then return false end
            return (pa - SAFE).Magnitude < (pb - SAFE).Magnitude
        end)
        return out
    end
    local function chestPrompt(c)
        local pp = c:FindFirstChild("InteractPrompt")
        if pp and pp:IsA("ProximityPrompt") then return pp end
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("ProximityPrompt") then return d end
        end
        return nil
    end
    local function choicePrompt()
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
        if not pg then return nil end
        for _, d in ipairs(pg:GetDescendants()) do
            if d.Name == "ChoicePrompt" and d:FindFirstChild("ChoiceFrame") and d:FindFirstChild("Choice") then return d end
        end
        return nil
    end
    local function fireLoot()
        if (G.ck() - GOURD.lastLoot) < LOOT_COOL then return false end
        local cp = choicePrompt()
        local r = cp and cp:FindFirstChild("Choice")
        if not (r and r:IsA("RemoteEvent")) then return false end
        GOURD.lastLoot = G.ck()
        pcall(function() r:FireServer("LOOT_ALL") end)
        return true
    end

    local function swing()
        if type(mouse1click) == "function" then pcall(mouse1click); return true end
        if G.VIM then
            local vp = GOURD.cam and GOURD.cam.ViewportSize or G.V2(960, 540)
            local cx, cy = math.floor(vp.X / 2), math.floor(vp.Y / 2)
            pcall(function()
                G.VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                G.VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
            end)
            return true
        end
        return false
    end

    local function killMob(m)
        if not m then return end
        local t0 = G.ck()
        while GOURD.running and mobAlive(m) do
            if (G.ck() - t0) > MOB_T then return end
            if dead() then
                setTask("waiting respawn")
                if not waitRespawn() then return end
                travel(SAFE, TRAVEL_T)
            else
                local function goalOf()
                    local r = m:FindFirstChild("HumanoidRootPart")
                    if r and mobAlive(m) then return r.Position + G.V3(0, HOVER, 0) end
                    return nil
                end
                local arrived = pin(goalOf, function()
                    local r, g = G.myR(), goalOf()
                    return r ~= nil and g ~= nil and (r.Position - g).Magnitude <= ARRIVE * 2
                end, TRAVEL_T)
                if not GOURD.running then return end
                if not mobAlive(m) then break end
                if not arrived then
                    G.tw(0.2)
                else
                    hover(goalOf, HOLD)
                    if not GOURD.running then return end
                    if mobAlive(m) and not dead() and refs() then swing() end
                    hover(goalOf, SWING)
                end
            end
            GOURD.idle = 0
        end
        if not mobAlive(m) then GOURD.idle = 0 end
    end

    local function clearWave()
        while GOURD.running do
            local list = mobs()
            if #list == 0 then return end
            for i, m in ipairs(list) do
                if not GOURD.running then return end
                if mobAlive(m) then
                    setTask("killing gourdskippers " .. i .. "/" .. #list, "killing")
                    killMob(m)
                end
            end
        end
    end

    local function lootOne(c)
        if not c or not c.Parent then return false end
        local function goalOf()
            local p = chestPos(c)
            if p then return p + G.V3(0, CHEST_H, 0) end
            return nil
        end
        local start = goalOf()
        if not start then return false end
        travel(start, TRAVEL_T)
        if not GOURD.running then return false end
        local t0, lastP = G.ck(), 0
        while GOURD.running and (G.ck() - t0) < CHEST_T do
            if not c.Parent then return true end
            if fireLoot() then
                local t1 = G.ck()
                while GOURD.running and (G.ck() - t1) < 1 and choicePrompt() do hover(goalOf, 0.2) end
                return true
            end
            local pp = chestPrompt(c)
            if pp and (G.ck() - lastP) > 0.4 then
                lastP = G.ck()
                pcall(fireproximityprompt, pp)
            end
            hover(goalOf, 0.3)
            if #mobs() > 0 then return false end
        end
        return false
    end

    local function lootAll()
        local list = chests()
        if #list == 0 then GOURD.idle, GOURD.lastLootRun = 0, G.ck(); return 0 end
        local done = 0
        for i, c in ipairs(list) do
            if not GOURD.running then break end
            if #mobs() > 0 then break end
            if c.Parent then
                setTask("looting chests " .. i .. "/" .. #list, "looting")
                if lootOne(c) then done = done + 1 end
            end
        end
        if GOURD.running then setTask("returning to safe"); travel(SAFE, TRAVEL_T) end
        GOURD.lastLootRun, GOURD.idle = G.ck(), 0
        if done > 0 then
            NOTIF.send("Hallowtide", "looted " .. done .. (done == 1 and " chest" or " chests"))
        end
        return done
    end

    local function tryWave(immediate)
        if not immediate and (G.ck() - GOURD.lastShrine) < SHRINE_COOL then return false end
        if blocked() then setTask("shrine locked"); return false end
        GOURD.lastShrine = G.ck()
        setTask("starting trial")
        travel(SHRINE, TRAVEL_T)
        if not GOURD.running then return false end
        local ok = fireShrine()
        if ok then NOTIF.send("Hallowtide", "wave started") end
        setTask("returning to safe")
        travel(SAFE, TRAVEL_T)
        return ok
    end

    local function guard()
        setTask("boot: resolving state")
        if not waitChar() then return end
        if dead() then
            setTask("boot: waiting respawn")
            if not waitRespawn() then return end
        end
        if not inArena() then setTask("boot: moving to arena"); travel(SAFE, TRAVEL_T * 2) end
        if not GOURD.running then return end
        if #mobs() > 0 then setTask("boot: resuming trial"); return end
        if #chests() > 0 then
            setTask("boot: looting chests")
            lootAll()
            if not GOURD.running then return end
        end
        if blocked() then setTask("boot: shrine locked"); return end
        tryWave(true)
    end

    local function step()
        if not GOURD.hud or not GOURD.hud.Parent then
            hudMake()
            if GOURD.taskL and GOURD.taskText then GOURD.taskL.Text = GOURD.taskText end
        end
        if not refs() then G.tw(0.5); return end
        if dead() then
            setTask("waiting respawn")
            if not waitRespawn() then return end
            travel(SAFE, TRAVEL_T)
            return
        end
        if #mobs() > 0 then
            clearWave()
            if GOURD.running then setTask("returning to safe"); travel(SAFE, TRAVEL_T) end
            return
        end
        GOURD.idle = GOURD.idle + 1
        local list = chests()
        if #list > 0 and GOURD.idle >= CHEST_IDLE and (G.ck() - GOURD.lastLootRun) > CHEST_RETRY and not blocked() then
            lootAll()
            return
        end
        if #list > 0 then setTask("waiting: " .. #list .. " chests pending"); G.tw(1); return end
        if GOURD.idle >= SHRINE_IDLE then
            tryWave(false)
            GOURD.idle = 0
            return
        end
        setTask("waiting for wave")
        G.tw(1)
    end

    function GOURD.status()
        if not GOURD.running then
            return game.PlaceId == HALLOW_PLACE and "ready · dungeon" or "requires dungeon place"
        end
        return GOURD.taskText or "running"
    end

    function GOURD.start()
        if GOURD.running then return true end
        if game.PlaceId ~= HALLOW_PLACE then
            NOTIF.send("Hallowtide", "wrong place · requires Dungeon", nil, true)
            return false
        end
        if type(mouse1click) ~= "function" and not G.VIM then
            NOTIF.send("Hallowtide", "executor has no M1 input", nil, true)
            return false
        end
        GOURD.running, GOURD.token = true, tostring(G.ck())
        local tok = GOURD.token
        GOURD.idle, GOURD.lastShrine, GOURD.lastLoot, GOURD.lastLootRun = 0, 0, 0, 0
        GOURD.group, GOURD.taskText = nil, "booting"
        GOURD.ncOwn = NC.conn == nil
        pcall(NC.en)
        hudMake()
        NOTIF.send("Hallowtide", "auto gourdskipper engaged")
        G.ts(function()
            local ok = pcall(function()
                guard()
                while GOURD.running and GOURD.token == tok do
                    if not pcall(step) then G.tw(1) end
                end
            end)
            if not ok then G.tw(1) end
            if GOURD.token == tok then
                GOURD.stop(true)
                S.gourd = false
                pcall(UI.updTog)
            end
        end)
        return true
    end

    function GOURD.stop(silent)
        if not GOURD.running and not GOURD.hud then
            if not silent then NOTIF.send("Hallowtide", "auto gourdskipper stopped") end
            return
        end
        GOURD.running, GOURD.token = false, nil
        if GOURD.ncOwn then pcall(NC.dis) end
        GOURD.ncOwn = false
        pcall(hudKill)
        if not silent then NOTIF.send("Hallowtide", "auto gourdskipper stopped") end
    end
end


local FLIP = {}
do
    function FLIP.pktPlk() S.pktPlk = not S.pktPlk; if S.pktPlk then PACKET_PLK:start() else PACKET_PLK:stp() end; UI.updTog() end
    function FLIP.esp() S.esp = not S.esp; if S.esp then ESP.start() else ESP.stop() end; UI.updTog() end
    function FLIP.espBox() S.espBox = not S.espBox; UI.updTog() end
    function FLIP.espLvl() S.espLvl = not S.espLvl; UI.updTog() end
    function FLIP.espHp() S.espHp = not S.espHp; UI.updTog() end
    function FLIP.htnl() S.htnl = not S.htnl; UI.updTog() end
    function FLIP.espG() S.espGlobal = not S.espGlobal; UI.updTog(); if UI._espDim then UI._espDim() end end
    function FLIP.mobEsp() S.mobEsp = not S.mobEsp; if S.mobEsp then MESP.start() else MESP.stop() end; UI.updTog() end
    function FLIP.nEsp() S.nEsp = not S.nEsp; if S.nEsp then NESP.start() else NESP.stop() end; UI.updTog() end
    function FLIP.cEsp() S.cEsp = not S.cEsp; if S.cEsp then CESP.start() else CESP.stop() end; UI.updTog() end
    function FLIP.autoloot() S.autoloot = not S.autoloot; if S.autoloot then AUTOLOOT.start() else AUTOLOOT.stop() end; UI.updTog() end
    function FLIP.spec() S.spec = not S.spec; SPEC.tog(); UI.updTog() end
    function FLIP.specRobloxNames() S.specRobloxNames = not S.specRobloxNames; UI.updTog(); if S.spec and SPEC.upd then SPEC.upd() end end
    function FLIP.ag() S.agil = not S.agil; if S.agil or S.agSpd then AGIL.en() else AGIL.dis() end; UI.updTog() end
    function FLIP.agSpd() S.agSpd = not S.agSpd; if S.agil or S.agSpd then AGIL.en() else AGIL.dis() end; UI.updTog() end
    function FLIP.nc() S.nc = not S.nc; if S.nc then NC.en() else NC.dis() end; UI.updTog() end
    function FLIP.nf() S.nfd = not S.nfd; if S.nfd then NFD.en() else NFD.dis() end; UI.updTog() end
    function FLIP.fly() S.fly = not S.fly; if S.fly then FLY.en() else FLY.dis() end; UI.updTog() end
    function FLIP.as() S.aSpd = not S.aSpd; if S.aSpd then ASPD.en() else ASPD.dis() end; UI.updTog() end
    function FLIP.mSpd() S.mSpd = not S.mSpd; UI.updTog() end
    function FLIP.nv() S.noVis = not S.noVis; if S.noVis then NOVIS.en() else NOVIS.dis() end; UI.updTog() end
    function FLIP.op() S.opt = not S.opt; if S.opt then OPTIMIZE.en() else OPTIMIZE.dis() end; UI.updTog() end
    function FLIP.fps() S.fps = not S.fps; if S.fps then FPS.en() else FPS.dis() end; UI.updTog() end
    function FLIP.nkb() S.nkb = not S.nkb; if S.nkb then NKB.en() else NKB.dis() end; UI.updTog() end
    function FLIP.npcFreeze() S.npcFreeze = not S.npcFreeze; if S.npcFreeze then NPC_FREEZER.start() else NPC_FREEZER.stop() end; UI.updTog() end
    function FLIP.mod() S.modDetector = not S.modDetector; if S.modDetector then MODD.start() else MODD.stop() end; UI.updTog() end
    function FLIP.modSnd() S.modSound = not S.modSound; UI.updTog() end
    function FLIP.modRep() S.modRepeat = not S.modRepeat; UI.updTog() end
    function FLIP.hpb() S.humanoidPathfindBreaker = not S.humanoidPathfindBreaker; if S.humanoidPathfindBreaker then PATHBREAK.start() else PATHBREAK.stop() end; UI.updTog() end
    function FLIP.back() S.attachToBack = not S.attachToBack; if S.attachToBack then BACK.start() else BACK.stop() end; UI.updTog() end
    function FLIP.eff() S.effDisable = not S.effDisable; if S.effDisable then EFFECTS.en() else EFFECTS.dis() end; UI.updTog() end
    function FLIP.effH() S.effHunger = not S.effHunger; if S.effHunger then pcall(EFFECTS.scrubHunger) else pcall(EFFECTS.restoreHunger) end; UI.updTog() end
    function FLIP.effU() S.effUnderwater = not S.effUnderwater; if S.effUnderwater then pcall(EFFECTS.scrubUnderwater) else pcall(EFFECTS.restoreUnderwater) end; UI.updTog() end
    function FLIP.effS() S.effSanity = not S.effSanity; if S.effSanity then pcall(EFFECTS.scrubSanity) else pcall(EFFECTS.restoreSanity) end; UI.updTog() end
    function FLIP.sanity() S.sanityHud = not S.sanityHud; if S.sanityHud then SANITY.en() else SANITY.dis() end; UI.updTog() end
    function FLIP.bright() S.bright = not S.bright; if S.bright then BRIGHT.en() else BRIGHT.dis() end; UI.updTog() end
    function FLIP.kbHud() S.kbHud = not S.kbHud; if S.kbHud then KBHUD.en() else KBHUD.dis() end; UI.updTog() end
    function FLIP.chat() S.showChat = not S.showChat; if S.showChat then CHATSHOW.en() else CHATSHOW.dis() end; UI.updTog() end
    function FLIP.ab() S.autoBuild = not S.autoBuild; if S.autoBuild then BUILDER.start() else BUILDER.stop() end; UI.updTog() end
    function FLIP.abPts() S.autoPoints = not S.autoPoints; if S.autoPoints then BUILDER.startPts() else BUILDER.stopPts() end; UI.updTog() end
    function FLIP.gourd() 
        if not S.gourd then
            if not GOURD.start() then UI.updTog(); return end
            S.gourd = true
        else
            S.gourd = false
            GOURD.stop(false)
        end
        UI.updTog()
    end
end


do
    function UI.bindInp()
        trk(G.UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            local kc = inp.KeyCode; if kc == Enum.KeyCode.Unknown then return end
            if listening then G.endL(kc); KBHUD.hintDirty(); return end
            if kc == (kb.menuKey or CFG.MenuKey) then UI.togMenu(); return end
            local map = {
                pktPlk = FLIP.pktPlk, esp = FLIP.esp, espBox = FLIP.espBox, espLvl = FLIP.espLvl, espHp = FLIP.espHp, htnl = FLIP.htnl,
                espGlobal = FLIP.espG,
                mobEsp = FLIP.mobEsp, nEsp = FLIP.nEsp, cEsp = FLIP.cEsp, autoloot = FLIP.autoloot, spec = FLIP.spec,
                specRobloxNames = FLIP.specRobloxNames,
                agil = FLIP.ag, agSpd = FLIP.agSpd, mSpd = FLIP.mSpd,
                nc = FLIP.nc, nfd = FLIP.nf, fly = FLIP.fly, aSpd = FLIP.as, opt = FLIP.op, fps = FLIP.fps,
                noVis = FLIP.nv,
                nkb = FLIP.nkb, npcFreeze = FLIP.npcFreeze, modDetector = FLIP.mod,
                humanoidPathfindBreaker = FLIP.hpb, attachToBack = FLIP.back,
                effDisable = FLIP.eff, sanityHud = FLIP.sanity, bright = FLIP.bright, kbHud = FLIP.kbHud, showChat = FLIP.chat,
                autoBuild = FLIP.ab, autoPoints = FLIP.abPts,
                gourd = FLIP.gourd,
            }
            local hit = {}
            for feat, fn in pairs(map) do if kb[feat] and kc == kb[feat] then G.ti(hit, fn) end end
            for _, fn in ipairs(hit) do fn() end
            if kb.m1 and kc == kb.m1 then MACRO.exec(1) end
            if kb.m2 and kc == kb.m2 then MACRO.exec(2) end
            if kb.m3 and kc == kb.m3 then MACRO.exec(3) end
        end))
    end
end


local RST = {}
do
    function RST.go()
        pcall(function()
            local ch = G.LP and G.LP.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            if type(replicatesignal) == "function" and hum then
                replicatesignal(hum.Kill)
                task.delay(1, function()
                    pcall(function()
                        if hum.Health > 1 and root and root.Parent then
                            root.CFrame = root.CFrame * G.CF(0, 9e9, 0)
                        end
                    end)
                end)
            elseif root then
                root.CFrame = root.CFrame * G.CF(0, 9e9, 0)
            end
        end)
        
        pcall(function()
            local ev = G.RepS:FindFirstChild("Requests")
            local r = ev and ev:FindFirstChild("Reset")
            if r and r:IsA("RemoteEvent") then r:FireServer() end
        end)
    end
end

local function destroyOld()
    for _, c in ipairs(statics) do pcall(function() c:Disconnect() end) end; G.tc(statics)
    if GOURD then pcall(GOURD.stop, true) end; S.gourd = false
    ESP.stop(); MESP.stop(); NESP.stop(); CESP.stop(); AUTOLOOT.stop()
    PACKET_PLK:stp(); S.pktPlk = false
    if S.agil or S.agSpd then AGIL.dis(); S.agil, S.agSpd = false, false end
    if S.nc then NC.dis(); S.nc = false end
    if S.aSpd then ASPD.dis(); S.aSpd = false end
    if S.nfd then NFD.dis(); S.nfd = false end
    if NKB then NKB.dis() end; S.nkb = false
    if S.fly then FLY.dis(); S.fly = false end
    if S.noVis then NOVIS.dis(); S.noVis = false end
    if S.opt then OPTIMIZE.dis(); S.opt = false end
    if S.fps then FLIP.fps() end
    if S.kbHud then KBHUD.dis(); S.kbHud = false end
    if NOTIF then NOTIF.wipe() end
    if EFFECTS then EFFECTS.dis() end; S.effDisable = false
    if SANITY then SANITY.dis() end; S.sanityHud = false
    if BRIGHT then BRIGHT.dis() end; S.bright = false
    if NPC_FREEZER and NPC_FREEZER.stop then NPC_FREEZER.stop() end; S.npcFreeze = false
    if PATHBREAK and PATHBREAK.stop then PATHBREAK.stop() end; S.humanoidPathfindBreaker = false
    if BACK and BACK.stop then BACK.stop() end; S.attachToBack = false
    if TELE then TELE.stop() end; S.tp = false
    if SPEC and SPEC.conn then SPEC.conn:Disconnect(); SPEC.conn = nil end
    if MODD then MODD.stop() end; S.modDetector, S.modSound = false, false
    pcall(CHATSHOW.dis); S.showChat = false
    if BUILDER then BUILDER.wipe() end; S.autoBuild, S.autoPoints = false, false
    if ASPD.cc then ASPD.cc:Disconnect(); ASPD.cc = nil end
    if NFD.cc then NFD.cc:Disconnect(); NFD.cc = nil end
    if FLY.cc then FLY.cc:Disconnect(); FLY.cc = nil end
    if PACKET_PLK.cc then PACKET_PLK.cc:Disconnect(); PACKET_PLK.cc = nil end
    if PC.addC then PC.addC:Disconnect() end; if PC.remC then PC.remC:Disconnect() end
    for _, cs in pairs(PC.conns) do for _, c in ipairs(cs) do pcall(function() c:Disconnect() end) end end
    G.tc(PC.conns); G.tc(PC.cache)
    if UI.drgC then UI.drgC:Disconnect(); UI.drgC = nil end
    if UI.resC then UI.resC:Disconnect(); UI.resC = nil end
    if UI.dynConn then UI.dynConn:Disconnect(); UI.dynConn = nil end
    if UI._rc1 then pcall(function() UI._rc1:Disconnect() end); UI._rc1 = nil end
    if UI._rc2 then pcall(function() UI._rc2:Disconnect() end); UI._rc2 = nil end
    UI._drag = nil
    UI._sliders, UI._rowRefs, UI._valChip = {}, {}, {}
    SPEC.thread = nil
    if shared.ArchiveTQ then pcall(function() shared.ArchiveTQ:Disconnect() end); shared.ArchiveTQ = nil end
    UI.mFrame, UI.togs, UI.rows, UI.flipOf, UI.cfgList, UI.mobDrop = nil, nil, nil, nil, nil, nil
    UI._slot, UI._W, UI._rsx, UI._lastDyn = nil, nil, nil, nil
    UI._prevStats, UI._prevVP, UI._prevBtns = nil, nil, nil
    UI._prevChar, UI._prevBase, UI._prevRot = nil, nil, nil
    UI._liveL, UI._liveR, UI._liveTiles, UI._liveRes = nil, nil, nil, nil
    G.tc(kbL)
    local cg; pcall(function() cg = game:GetService("CoreGui") end)
    for _, par in ipairs({G.getHP(), cg}) do if par then pcall(function()
        for _, ch in ipairs(par:GetChildren()) do
            if ch:GetAttribute("KI") == true and not (SPEC and SPEC.gui == ch) and not (KBHUD and KBHUD.gui == ch) then
                ch:Destroy()
            end
        end
    end) end end
end


local function unloadAll()
    pcall(function() if FPS and FPS.active then FPS.dis() end end)
    pcall(function() if FPS and FPS.hasOrig and FPS.origCap ~= nil and type(setfpscap) == "function" then setfpscap(FPS.origCap) end end)
    pcall(destroyOld)
    pcall(function()                        
        local L = game:GetService("Lighting")
        for _, b in ipairs(L:GetChildren()) do
            if b.Name == "ArchiveBlur" then b:Destroy() end
        end
    end)
    if UI._rc1 then pcall(function() UI._rc1:Disconnect() end); UI._rc1 = nil end
    if UI._rc2 then pcall(function() UI._rc2:Disconnect() end); UI._rc2 = nil end
    UI._drag = nil
    pcall(function() if SPEC and SPEC.gui then SPEC.gui:Destroy(); SPEC.gui = nil end end)
    pcall(function() if KBHUD and KBHUD.gui then KBHUD.gui:Destroy(); KBHUD.gui = nil end end)
    pcall(function() if NOTIF then NOTIF.wipe() end end)
    shared.ArchiveCleanup = nil
    S.menu = false
end

function UI.applyV()
    if UI.mFrame then UI.mFrame.Visible = S.menu end
end
function UI.togMenu()
    S.menu = not S.menu
    if not S.menu and G._kbModal then
        pcall(function() G._kbModal:Destroy() end)
        G._kbModal = nil
        listening = nil
    end
    if not UI.mFrame then UI.applyV(); return end
    if S.menu then
        UI.mFrame.Visible = true
        local base = UDim2.new(0, UI._W or 620, 0, UI._H or 420)
        UI.mFrame.Size = UDim2.new(0, (UI._W or 620) * 0.96, 0, (UI._H or 420) * 0.96)
        G.TS:Create(UI.mFrame, G.TI(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = base}):Play()
    else
        local f = UI.mFrame
        local base = UDim2.new(0, UI._W or 620, 0, UI._H or 420)
        local tw = G.TS:Create(f, G.TI(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, (UI._W or 620) * 0.96, 0, (UI._H or 420) * 0.96)})
        tw:Play()
        tw.Completed:Connect(function() if not S.menu then f.Visible = false; f.Size = base end end)
    end
    UI.applyV()
end
function UI.updTog()
    if not UI.rows then return end
    for key, api in pairs(UI.rows) do
        pcall(function()
            local on = S[key] == true
            if api.set then api.set(on) end
            if api.chip then api.chip() end
        end)
    end
    pcall(function() if KBHUD and KBHUD.gui then KBHUD.hintDirty() end end)
    pcall(UI.refreshRows)
    pcall(function() if UI._espDim then UI._espDim() end end)
end
function UI.updDyn(force) if UI.rows then pcall(UI.refreshRows) end end
function UI.mkHint() end
function UI.divider(par, y, w)
    local ln = G.new("Frame", par)
    ln.BackgroundColor3 = P.brd; ln.BorderSizePixel = 0
    ln.Position = G.UD2(0, 12, 0, G.snap(y)); ln.Size = G.UD2(1, -24, 0, 1)
    local d = G.new("Frame", par)
    d.BackgroundColor3 = P.amb; d.BorderSizePixel = 0; d.Rotation = 45
    d.AnchorPoint = G.V2(0.5, 0.5)
    d.Position = G.UD2(0.5, 0, 0, G.snap(y - 3)); d.Size = G.UD2(0, 6, 0, 6)
    return ln
end
function UI.sectHead(par, y, w, txt)
    local l = G.mkL(par, G.spaced(txt), 12, y, w - 24, 18, 12, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb)
    return l
end
function UI.featRow(par, x, y, w, name, desc, key, indent, nobind)
    indent = indent or 0
    local root = G.new("Frame", par)
    root.Name = "R"
    root.BackgroundTransparency = 1; root.BorderSizePixel = 0
    root.Position = G.UD2(0, 0, 0, G.snap(y) + 2); root.Size = G.UD2(1, 0, 0, 30)
    local hoverBg = G.new("Frame", root)
    hoverBg.Name = "HB"
    hoverBg.BackgroundTransparency = 1; hoverBg.BackgroundColor3 = P.hover; hoverBg.BorderSizePixel = 0
    hoverBg.Position = G.UD2(0, 0, 0, 0); hoverBg.Size = G.UD2(1, 0, 0, 30)
    G.mkC(hoverBg, 3)
    local hoverInner = G.new("Frame", hoverBg)
    hoverInner.Name = "HBI"
    hoverInner.BackgroundTransparency = 1; hoverInner.BackgroundColor3 = P.hover; hoverInner.BorderSizePixel = 0
    hoverInner.Position = G.UD2(0, 4, 0, 1); hoverInner.Size = G.UD2(1, -8, 0, 28)
    G.mkC(hoverInner, 3)
    if indent > 0 then
        local b = G.new("Frame", root)
        b.Size = G.UD2(0, 4, 0, 4); b.Position = G.UD2(0, 10, 0.5, -2)
        b.BackgroundColor3 = P.amb; b.BorderSizePixel = 0; b.Rotation = 45
    end
    local nm = G.mkL(root, name, 8 + indent, 1, w - 116, 17, 14, Enum.Font.GothamMedium,
        Enum.TextXAlignment.Left, indent > 0 and P.tx or P.tx)
    nm.Size = G.UD2(1, -116 - indent, 0, 17)
    local sb = G.mkL(root, desc or "", 8 + indent, 17, w - 116, 14, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
    sb.Size = G.UD2(1, -116 - indent, 0, 14)
    local chip
    if not nobind then
        chip = G.new("TextButton", root)
        chip.Position = G.UD2(1, -82, 0, 9); chip.Size = G.UD2(0, 44, 0, 16)
        chip.BackgroundTransparency = 1; chip.BorderSizePixel = 0; chip.AutoButtonColor = false
        chip.Font = Enum.Font.Code; chip.TextSize = 12; chip.TextColor3 = P.amb
        chip.TextStrokeTransparency = 1
        chip.Text = G.kName(kb[key]); chip.TextXAlignment = Enum.TextXAlignment.Center
        G.mkC(chip, 3); G.mkS(chip, P.brd, 1, 0)
        kbL[key] = chip
        chip.MouseButton1Click:Connect(function() G.startL(key) end)
    end
    local hit = G.new("TextButton", root)
    hit.Position = G.UD2(1, -30, 0, 5); hit.Size = G.UD2(0, 24, 0, 24)
    hit.BackgroundTransparency = 1; hit.BorderSizePixel = 0; hit.Text = ""; hit.AutoButtonColor = false
    local boxSize = indent > 0 and 12 or 14
    local boxOffset = (24 - boxSize) / 2
    local box = G.new("Frame", hit)
    box.Size = G.UD2(0, boxSize, 0, boxSize); box.Position = G.UD2(0, boxOffset, 0, boxOffset)
    box.BackgroundTransparency = 1; box.BorderSizePixel = 0
    G.mkC(box, 2); G.mkS(box, P.brd, 1, 0)
    hit.MouseButton1Click:Connect(function()
        local fn = UI.flipOf and UI.flipOf[key]
        if fn then fn() end
    end)
    hit.MouseEnter:Connect(function()
        local st = box:FindFirstChildOfClass("UIStroke")
        if st then G.TS:Create(st, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = P.amb}):Play() end
    end)
    hit.MouseLeave:Connect(function()
        local st = box:FindFirstChildOfClass("UIStroke")
        if st then
            local on = S[key] == true
            G.TS:Create(st, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = on and P.amb or P.brd}):Play()
        end
    end)
    root.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then hoverInner.BackgroundTransparency = 0 end
    end)
    root.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then hoverInner.BackgroundTransparency = 1 end
    end)
    local api = {}
    function api.set(on)
        box.BackgroundTransparency = on and 0 or 1
        box.BackgroundColor3 = on and P.amb or P.base
        local st = box:FindFirstChildOfClass("UIStroke")
        if st then
            st.Color = on and P.amb or P.brd
            G.TS:Create(box, G.TI(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = on and 0 or 1}):Play()
        end
    end
    function api.snapSet(on)
        box.BackgroundTransparency = on and 0 or 1
        box.BackgroundColor3 = on and P.amb or P.base
        local st = box:FindFirstChildOfClass("UIStroke")
        if st then st.Color = on and P.amb or P.brd end
    end
    function api.sub(s) sb.Text = s end
    function api.chip()
        if not chip then return end
        if UI._valChip and UI._valChip[key] then
            if S[key] == true then chip.Text = UI._valChip[key]() else chip.Text = G.kName(kb[key]) end
        else
            chip.Text = G.kName(kb[key])
        end
    end
    function api.val(fn) UI._valChip = UI._valChip or {}; UI._valChip[key] = fn; api.chip() end
    api.root = root
    return api
end
function UI.slideRow(par, x, y, w, label, mn, mx, init, cb, regKey, suffix, step)
    suffix = suffix or ""; step = step or 1
    local lb = G.mkL(par, label, 8, y, w - 110, 14, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
    lb.Size = G.UD2(1, -110, 0, 14)
    local val = G.mkL(par, "", 0, y, 50, 14, 12, Enum.Font.Code, Enum.TextXAlignment.Right, P.amb)
    val.AnchorPoint = G.V2(1, 0)
    val.Position = G.UD2(1, -8, 0, y); val.Size = G.UD2(0, 90, 0, 14)
    local function fmt(v)
        if step < 1 then return string.format("%.1f", v) .. suffix end
        return tostring(G.mr(v)) .. suffix
    end
    local tr = G.new("Frame", par)
    tr.Position = G.UD2(0, 8, 0, G.snap(y + 18)); tr.Size = G.UD2(1, -16, 0, 3)
    tr.BackgroundColor3 = P.off; tr.BorderSizePixel = 0
    G.mkC(tr, 2)
    local pct = G.mc((init - mn) / math.max(1, mx - mn), 0, 1)
    local fl = G.new("Frame", tr)
    fl.Size = G.UD2(pct, 0, 1, 0); fl.BackgroundColor3 = P.amb; fl.BorderSizePixel = 0
    G.mkC(fl, 2)
    local knob = G.new("Frame", tr)
    knob.Size = G.UD2(0, 12, 0, 12); knob.Position = G.UD2(pct, -6, 0.5, -6)
    knob.BackgroundColor3 = P.amb; knob.BorderSizePixel = 0
    G.mkC(knob, 6)
    do
        local iv = G.mc(init, mn, mx)
        if step < 1 then iv = G.mc(mn + G.mr((iv - mn) / step) * step, mn, mx) else iv = G.mr(iv) end
        val.Text = fmt(iv)
    end
    local hit = G.new("TextButton", par)
    hit.BackgroundTransparency = 1; hit.BorderSizePixel = 0; hit.Text = ""; hit.AutoButtonColor = false
    hit.Position = G.UD2(0, 0, 0, G.snap(y + 10)); hit.Size = G.UD2(1, 0, 0, 16)
    local function set(v)
        v = G.mc(v, mn, mx)
        if step < 1 then v = G.mc(mn + G.mr((v - mn) / step) * step, mn, mx) else v = G.mr(v) end
        local pn = (v - mn) / math.max(1, mx - mn)
        fl.Size = G.UD2(pn, 0, 1, 0)
        local kr = knob.Size.X.Offset / 2
        knob.Position = G.UD2(pn, -kr, 0.5, -kr)
        val.Text = fmt(v)
        if cb then cb(v) end
    end
    local function fromInput(px)
        local ap, as = tr.AbsolutePosition, tr.AbsoluteSize
        local pn = G.mc((px - ap.X) / math.max(1, as.X), 0, 1)
        set(mn + pn * (mx - mn))
    end
    local drag = false
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; fromInput(i.Position.X)
        end
    end)
    hit.MouseEnter:Connect(function()
        local pn = knob.Position.X.Scale
        knob.Position = G.UD2(pn, -7.5, 0.5, -7.5)
        G.TS:Create(knob, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = G.UD2(0, 15, 0, 15)}):Play()
    end)
    hit.MouseLeave:Connect(function()
        local pn = knob.Position.X.Scale
        knob.Position = G.UD2(pn, -6, 0.5, -6)
        G.TS:Create(knob, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = G.UD2(0, 12, 0, 12)}):Play()
    end)
    trk(G.UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromInput(i.Position.X) end
    end))
    trk(G.UIS.InputEnded:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then drag = false end
    end))
    UI._sliders = UI._sliders or {}
    if regKey then
        UI._rowRefs = UI._rowRefs or {}
        UI._rowRefs[regKey] = {lb = lb, val = val, tr = tr}
        UI._sliders[regKey] = function(v)
            v = G.mc(v, mn, mx)
            if step < 1 then v = G.mc(mn + G.mr((v - mn) / step) * step, mn, mx) else v = G.mr(v) end
            local pn = (v - mn) / math.max(1, mx - mn)
            fl.Size = G.UD2(pn, 0, 1, 0)
            local kr = knob.Size.X.Offset / 2
            knob.Position = G.UD2(pn, -kr, 0.5, -kr)
            val.Text = fmt(v)
        end
    end
    return set
end

function UI.group(sec, sc, title, h)
    local g = G.new("Frame", sc)
    g.Name = "G_" .. title
    g.BackgroundColor3 = P.panel; g.BackgroundTransparency = 0.15; g.BorderSizePixel = 0
    G.mkC(g, 3); G.mkS(g, P.brd, 1, 0)
    local t = G.mkL(g, string.upper(title), 10, 4, 300, 16, 12, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb)
    local inner = G.new("Frame", g)
    inner.BackgroundTransparency = 1; inner.BorderSizePixel = 0
    inner.Position = G.UD2(0, 0, 0, 22); inner.Size = G.UD2(1, 0, 0, h - 22)
    return g, inner
end

function UI.dropBlock(par, x, y, w, title, items, cur, onPick)
    local resolveItems = function()
        if type(items) == "function" then return items() or {} end
        return items or {}
    end
    local resolveCur = function()
        if type(cur) == "function" then return cur() end
        return cur
    end
    local hasTitle = title and tostring(title) ~= ""
    local btnY = y
    if hasTitle then
        local tl = G.mkL(par, title, 8, y, 200, 14, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
        tl.Size = G.UD2(1, -16, 0, 14)
        btnY = y + 16
    end
    local btn = G.new("TextButton", par)
    btn.Position = G.UD2(0, G.snap(x + 8), 0, G.snap(btnY)); btn.Size = G.UD2(1, -16, 0, 20)
    btn.BackgroundColor3 = G.RGB(26, 28, 36); btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.TextColor3 = P.tx
    btn.Text = "  " .. tostring(resolveCur() or "select..."); btn.TextXAlignment = Enum.TextXAlignment.Left
    G.mkC(btn, 3); G.mkS(btn, P.brd, 1, 0)
    G.btnFx(btn, false)
    local open = false
    local sc = par
    while sc and not sc:IsA("ScrollingFrame") do sc = sc.Parent end
    sc = sc or par.Parent
    local list = G.new("ScrollingFrame", sc)
    list.Position = G.UD2(0, 0, 0, 0); list.Size = G.UD2(1, -16, 0, 0)
    list.BackgroundColor3 = P.panel; list.BorderSizePixel = 0; list.Visible = false
    list.ScrollBarThickness = 2; list.ScrollBarImageColor3 = P.brd
    list.ZIndex = 50
    list.ClipsDescendants = true
    G.mkC(list, 3); G.mkS(list, P.brd, 1, 0)
    local api = {count = #resolveItems()}
    function api.fill(names, sel)
        for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then pcall(function() c:Destroy() end) end end
        local n = 0
        if #names == 0 then
            local empty = G.new("TextButton", list)
            empty.Size = G.UD2(1, 0, 0, 20); empty.Position = G.UD2(0, 0, 0, 0)
            empty.BackgroundTransparency = 1; empty.BorderSizePixel = 0; empty.AutoButtonColor = false
            empty.Font = Enum.Font.GothamMedium; empty.TextSize = 12; empty.TextColor3 = P.mt
            empty.Text = "  no items found"; empty.TextXAlignment = Enum.TextXAlignment.Left
            n = 1
        end
        for _, nm in ipairs(names) do
            n = n + 1
            local b = G.new("TextButton", list)
            b.Size = G.UD2(1, 0, 0, 20); b.Position = G.UD2(0, 0, 0, (n - 1) * 20)
            b.BackgroundTransparency = 1; b.BorderSizePixel = 0; b.AutoButtonColor = false
            b.Font = Enum.Font.Gotham; b.TextSize = 12; b.TextColor3 = P.tx
            b.Text = "  " .. nm; b.TextXAlignment = Enum.TextXAlignment.Left
            b.MouseButton1Click:Connect(function()
                btn.Text = "  " .. nm
                list.Visible = false; list.Size = G.UD2(1, -16, 0, 0); open = false
                if onPick then onPick(nm) end
            end)
        end
        list.CanvasSize = G.UD2(0, 0, 0, n * 20)
        api.count = math.max(n, 1)
        if sel then btn.Text = "  " .. tostring(sel) end
    end
    api.fill(resolveItems(), resolveCur())
    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            api.fill(resolveItems(), resolveCur())
            local count = api.count or 1
            local h = math.max(40, math.min(count * 20, 100))
            local ap = btn.AbsolutePosition
            local scAbs = list.Parent.AbsolutePosition
            local localX = ap.X - scAbs.X
            local localY = ap.Y - scAbs.Y + btn.Size.Y.Offset + 2
            list.Position = G.UD2(0, math.floor(localX), 0, math.floor(localY))
            list.Size = G.UD2(0, math.floor(btn.AbsoluteSize.X), 0, h); list.Visible = true
            list.CanvasSize = G.UD2(0, 0, 0, count * 20)
            list.CanvasPosition = Vector2.new(0, 0)
        else
            list.Visible = false; list.Size = G.UD2(1, -16, 0, 0)
        end
    end)
    return api
end

function G.btnFx(b, danger, restT)
    restT = restT or (danger and G.RGB(232, 132, 128) or P.tx)
    local hovC = danger and G.RGB(70, 42, 40) or G.RGB(58, 50, 36)
    local hovT = danger and G.RGB(240, 170, 165) or G.RGB(235, 205, 150)
    local base, baseP, busy = nil, nil, false
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            G.TS:Create(b, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = hovC, TextColor3 = hovT}):Play()
        end
    end)
    b.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            G.TS:Create(b, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = G.RGB(26, 28, 36), TextColor3 = restT}):Play()
        end
    end)
    b.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        if not base then base, baseP = b.Size, b.Position end
        pcall(function()
            G.TS:Create(b, G.TI(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = G.UD2(base.X.Scale, base.X.Offset - 4, base.Y.Scale, base.Y.Offset - 4),
                Position = G.UD2(baseP.X.Scale, baseP.X.Offset + 2, baseP.Y.Scale, baseP.Y.Offset + 2),
            }):Play()
            G.ts(function()
                G.tw(0.08)
                pcall(function()
                    G.TS:Create(b, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = base, Position = baseP}):Play()
                    G.tw(0.13)
                    busy = false
                end)
            end)
        end)
    end)
end

function UI.info(par, x, y, tip, place, tw, th)
    tw, th = tw or 220, th or 40
    local b = G.new("TextButton", par)
    if x < 0 then b.Position = G.UD2(1, x, 0, y) else b.Position = G.UD2(0, x, 0, y) end
    b.Size = G.UD2(0, 14, 0, 14)
    b.BackgroundTransparency = 1; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.TextColor3 = P.mt
    b.Text = ""
    G.mkC(b, 7); G.mkS(b, P.brd, 1, 0)
    local im = G.new("ImageLabel", b)
    im.Size = G.UD2(1, 0, 1, 0); im.BackgroundTransparency = 1
    im.Image = "rbxassetid://120620848266512"; im.ImageColor3 = P.mt
    local tipF = nil
    b.MouseEnter:Connect(function()
        if tipF then return end
        im.ImageColor3 = P.amb
        local host = UI.mFrame or par
        tipF = G.new("Frame", host)
        pcall(function()
            local mp = UI.mFrame and UI.mFrame.AbsolutePosition or Vector2.new(0, 0)
            local bp = b.AbsolutePosition
            local fw = UI.mFrame and UI.mFrame.AbsoluteSize.X or 620
            local tx = math.floor(bp.X - mp.X)
            if tx + tw > fw then tx = fw - tw - 12 end
            if tx < 12 then tx = 12 end
            tipF.Position = G.UD2(0, tx, 0, math.floor(bp.Y - mp.Y - th - 6))
        end)
        if not tipF.Position or tipF.Position.Y.Offset == 0 then
            tipF.Position = G.UD2(0, x + 20, 0, y - 8)
        end
        tipF.Size = G.UD2(0, tw, 0, th)
        if place then pcall(place, tipF) end
        tipF.BackgroundColor3 = P.base; tipF.BorderSizePixel = 0; tipF.ZIndex = 5000
        G.mkC(tipF, 3); G.mkS(tipF, P.amb, 1, 0.4)
        local l = G.mkL(tipF, tip or "", 8, 4, tw - 16, th - 8, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.tx)
        l.ZIndex = 5001; l.TextWrapped = true
        if th > 40 then l.TextYAlignment = Enum.TextYAlignment.Top end
    end)
    b.MouseLeave:Connect(function()
        im.ImageColor3 = P.mt
        if tipF then pcall(function() tipF:Destroy() end); tipF = nil end
    end)
    return b
end
function UI.actBtn(par, x, y, w, h, txt, danger, cb)
    local b = G.new("TextButton", par)
    b.Position = G.UD2(0, G.snap(x), 0, G.snap(y)); b.Size = G.UD2(1, -24, 0, math.floor(h))
    b.BackgroundColor3 = G.RGB(26, 28, 36); b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = danger and G.RGB(232, 132, 128) or P.tx
    b.TextStrokeTransparency = 1
    b.Text = txt
    G.mkC(b, 4); G.mkS(b, P.brd, 1, 0)
    G.btnFx(b, danger)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end

function UI.confirm(title, body, onYes)
    local sg = G.getHP():FindFirstChild(UC.RN)
    if not sg then return end
    local backdrop = G.new("Frame", sg)
    backdrop.Name = "Confirm"
    backdrop.Size = G.UD2(1, 0, 1, 0); backdrop.Position = G.UD2(0, 0, 0, 0)
    backdrop.BackgroundColor3 = G.RGB(0, 0, 0); backdrop.BackgroundTransparency = 0.55
    backdrop.BorderSizePixel = 0; backdrop.ZIndex = 5000
    local box = G.new("Frame", backdrop)
    box.Size = G.UD2(0, 320, 0, 140); box.Position = G.UD2(0.5, -160, 0.5, -70)
    box.BackgroundColor3 = P.panel; box.BorderSizePixel = 0; box.ZIndex = 5001
    G.mkC(box, 4); G.mkS(box, P.brd, 1, 0)
    local t = G.mkL(box, title, 16, 12, 288, 20, 16, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb); t.ZIndex = 5002
    local b2 = G.mkL(box, body, 16, 40, 288, 48, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.tx); b2.ZIndex = 5002
    b2.TextWrapped = true
    local yBtn = G.new("TextButton", box)
    yBtn.Position = G.UD2(0, 16, 1, -40); yBtn.Size = G.UD2(0, 140, 0, 26)
    yBtn.BackgroundColor3 = G.RGB(26, 28, 36); yBtn.BorderSizePixel = 0; yBtn.AutoButtonColor = false
    yBtn.Font = Enum.Font.GothamBold; yBtn.TextSize = 14; yBtn.TextColor3 = G.RGB(232, 132, 128)
    yBtn.Text = "CONFIRM"; yBtn.ZIndex = 5002
    G.mkC(yBtn, 3); G.mkS(yBtn, P.brd, 1, 0)
    local nBtn = G.new("TextButton", box)
    nBtn.Position = G.UD2(1, -156, 1, -40); nBtn.Size = G.UD2(0, 140, 0, 26)
    nBtn.BackgroundColor3 = G.RGB(26, 28, 36); nBtn.BorderSizePixel = 0; nBtn.AutoButtonColor = false
    nBtn.Font = Enum.Font.GothamBold; nBtn.TextSize = 14; nBtn.TextColor3 = P.tx
    nBtn.Text = "CANCEL"; nBtn.ZIndex = 5002
    G.mkC(nBtn, 3); G.mkS(nBtn, P.brd, 1, 0)
    local function close() pcall(function() backdrop:Destroy() end) end
    nBtn.MouseButton1Click:Connect(close)
    yBtn.MouseButton1Click:Connect(function() close(); if onYes then onYes() end end)
end

local function playIntro(onDone)
    local sg = G.new("ScreenGui"); sg.Name = UC.RN .. "_INTRO"
    sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.DisplayOrder = 2147483647
    sg:SetAttribute("KI", true); G.protG(sg); sg.Parent = G.getHP()
    local bg = G.new("Frame", sg)
    bg.AnchorPoint = G.V2(0.5, 0.5); bg.Position = G.UD2(0.5, 0, 0.5, 0)
    bg.Size = G.UD2(0, 360, 0, 150)
    bg.BackgroundColor3 = P.base; bg.BorderSizePixel = 0; bg.BackgroundTransparency = 1
    bg.ClipsDescendants = true
    G.mkC(bg, 4); G.mkS(bg, P.amb, 1, 0.55)
    local sheenF = G.sheen(bg, 0.94)
    sheenF.BackgroundTransparency = 1
    G.TS:Create(sheenF, G.TI(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
    local function dia(y, s)
        local halo = G.new("Frame", bg)
        halo.Size = G.UD2(0, s + 10, 0, s + 10); halo.AnchorPoint = G.V2(0.5, 0.5); halo.Position = G.UD2(0.5, 0, 0, y)
        halo.BackgroundColor3 = P.amb; halo.BorderSizePixel = 0; halo.Rotation = 45
        halo.BackgroundTransparency = 1
        local shell = G.new("Frame", bg)
        shell.Size = G.UD2(0, s + 4, 0, s + 4); shell.AnchorPoint = G.V2(0.5, 0.5); shell.Position = G.UD2(0.5, 0, 0, y)
        shell.BackgroundColor3 = P.amb; shell.BorderSizePixel = 0; shell.Rotation = 45
        shell.BackgroundTransparency = 1
        local d = G.new("Frame", bg)
        d.Size = G.UD2(0, s, 0, s); d.AnchorPoint = G.V2(0.5, 0.5); d.Position = G.UD2(0.5, 0, 0, y)
        d.BackgroundColor3 = G.RGB(240, 210, 140); d.BorderSizePixel = 0; d.Rotation = 45
        d.BackgroundTransparency = 1
        return d, shell, halo
    end
    local d1, s1, h1 = dia(22, 6)
    local d2, s2, h2 = dia(112, 6)
    local word = "ARCHIVE"
    local letters, halos = {}, {}
    for i = 1, #word do
        local halo = G.new("TextLabel", bg)
        halo.BackgroundTransparency = 1
        halo.Font = Enum.Font.Garamond; halo.TextSize = 32; halo.TextColor3 = P.amb
        halo.TextStrokeTransparency = 1
        halo.Text = string.sub(word, i, i)
        halo.TextTransparency = 1
        halo.TextXAlignment = Enum.TextXAlignment.Center
        halo.AnchorPoint = G.V2(0.5, 0)
        halo.Size = G.UD2(0, 32, 0, 38); halo.Position = G.UD2(0.5, (i - (#word + 1) / 2) * 32, 0, 44)
        halos[i] = halo
        local ch = G.new("TextLabel", bg)
        ch.BackgroundTransparency = 1
        ch.Font = Enum.Font.Garamond; ch.TextSize = 30; ch.TextColor3 = G.RGB(232, 200, 130)
        ch.TextStrokeTransparency = 1
        ch.Text = string.sub(word, i, i)
        ch.TextTransparency = 1
        ch.TextXAlignment = Enum.TextXAlignment.Center
        ch.AnchorPoint = G.V2(0.5, 0)
        ch.Size = G.UD2(0, 32, 0, 38); ch.Position = G.UD2(0.5, (i - (#word + 1) / 2) * 32, 0, 44)
        letters[i] = ch
    end
    local lineHalo = G.new("Frame", bg)
    lineHalo.Size = G.UD2(0, 0, 0, 3); lineHalo.Position = G.UD2(0.5, 0, 0, 92)
    lineHalo.BackgroundColor3 = P.amb; lineHalo.BorderSizePixel = 0
    lineHalo.BackgroundTransparency = 1
    lineHalo.AnchorPoint = G.V2(0.5, 0.5)
    local line = G.new("Frame", bg)
    line.Size = G.UD2(0, 0, 0, 1); line.Position = G.UD2(0.5, 0, 0, 92)
    line.BackgroundColor3 = G.RGB(232, 200, 130); line.BorderSizePixel = 0
    line.BackgroundTransparency = 1
    line.AnchorPoint = G.V2(0.5, 0.5)
    G.TS:Create(bg, G.TI(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
    for _, d in ipairs({d1, d2}) do G.TS:Create(d, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play() end
    for _, s in ipairs({s1, s2}) do G.TS:Create(s, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.45}):Play() end
    for _, h in ipairs({h1, h2}) do G.TS:Create(h, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.8}):Play() end
    for i, ch in ipairs(letters) do
        G.ts(function()
            G.tw(0.15 + (i - 1) * 0.04)
            G.TS:Create(ch, G.TI(0.25, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
            G.TS:Create(halos[i], G.TI(0.25, Enum.EasingStyle.Quad), {TextTransparency = 0.75}):Play()
        end)
    end
    G.ts(function()
        G.tw(0.55)
        G.TS:Create(lineHalo, G.TI(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.75}):Play()
        G.TS:Create(line, G.TI(0.5, Enum.EasingStyle.Quart), {Size = G.UD2(0, 300, 0, 1), BackgroundTransparency = 0}):Play()
        G.TS:Create(lineHalo, G.TI(0.5, Enum.EasingStyle.Quart), {Size = G.UD2(0, 300, 0, 3)}):Play()
    end)
    G.ts(function()
        G.tw(1.5)
        for i, ch in ipairs(letters) do
            G.TS:Create(ch, G.TI(0.25, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
            G.TS:Create(halos[i], G.TI(0.25, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        end
        G.TS:Create(line, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        G.TS:Create(lineHalo, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        for _, d in ipairs({d1, d2}) do G.TS:Create(d, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play() end
        for _, s in ipairs({s1, s2}) do G.TS:Create(s, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play() end
        for _, h in ipairs({h1, h2}) do G.TS:Create(h, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play() end
        G.TS:Create(sheenF, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        G.TS:Create(bg, G.TI(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        G.TS:Create(bg, G.TI(0.35, Enum.EasingStyle.Quad), {Size = G.UD2(0, 620, 0, 420)}):Play()
        G.tw(0.4)
        pcall(function() sg:Destroy() end)
        if onDone then onDone() end
    end)
end

local function createMenu()
    destroyOld(); G.tc(kbL)
    if not S.preserve then G.freshBoot() end
    S.preserve = false
    UI._secY = {}
    local sg = G.new("ScreenGui"); sg.Name = UC.RN; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 1000; sg:SetAttribute("KI", true)
    G.protG(sg); sg.Parent = G.getHP()

    local cam = G.WS.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 900)
    local W = CFG.MenuWidth or 620
    W = G.mc(W, 480, 900)
    local H = math.max(400, math.floor(vp.Y - 40))

    UI.mFrame = G.new("Frame", sg); UI.mFrame.Name = "M"
    UI.mFrame.AnchorPoint = G.V2(0.5, 0.5)
    do
        local c0 = G.WS.CurrentCamera
        local v0 = c0 and c0.ViewportSize or Vector2.new(1920, 900)
        UI.mFrame.Position = G.UD2(0.5, 0, 0.5, 0)
    end
    UI.mFrame.Size = G.UD2(0, W, 0, H)
    UI.mFrame.BackgroundColor3 = P.base; UI.mFrame.BorderSizePixel = 0; UI.mFrame.Visible = S.menu
    UI.mFrame.ClipsDescendants = true
    G.mkS(UI.mFrame, P.amb, 1, 0.72)
    G.mkC(UI.mFrame, 6)
    G.sheen(UI.mFrame, 0.96)
    
    UI._W = W
    UI._H = CFG.MenuHeight or H
    do
        local c0 = G.WS.CurrentCamera
        local v0 = c0 and c0.ViewportSize or Vector2.new(1920, 900)
        UI._H = G.mc(UI._H, 340, 560)
    end
    local function frameH()
        return G.mc(UI._H or 420, 340, 560)
    end
    local function frameW() return G.mc(UI._W or W, 480, 900) end
    UI._bodyY, UI._footH = 110, 40
    UI.mFrame.Size = G.UD2(0, frameW(), 0, frameH())

    G.mkL(UI.mFrame, "ARCHIVE", 16, 10, 220, 26, 24, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.tx)
    G.mkL(UI.mFrame, BUILD, 112, 15, 200, 16, 12, Enum.Font.Code, Enum.TextXAlignment.Left, P.mt)
    UI.divider(UI.mFrame, 40, W)

    local sbox = G.new("TextBox", UI.mFrame)
    sbox.Position = G.UD2(0, 12, 0, 48); sbox.Size = G.UD2(1, -74, 0, 24)
    local qlBtn = G.new("TextButton", UI.mFrame)
    qlBtn.Position = G.UD2(1, -58, 0, 48); qlBtn.Size = G.UD2(0, 46, 0, 24)
    qlBtn.BackgroundColor3 = P.panel; qlBtn.BorderSizePixel = 0; qlBtn.AutoButtonColor = false
    qlBtn.Font = Enum.Font.GothamBold; qlBtn.TextSize = 12; qlBtn.TextColor3 = P.amb
    qlBtn.Text = "LOAD"
    G.mkC(qlBtn, 3); G.mkS(qlBtn, P.brd, 1, 0)
    G.btnFx(qlBtn, false)
    qlBtn.MouseButton1Click:Connect(function()
        local nm = CFG.QuickLoad or ""
        if nm == "" then NOTIF.send("Archive", "no quick-load config set"); return end
        if G.loadConfig(nm) then UI.applyLoaded(); NOTIF.send("Archive", "quick-loaded " .. nm)
        else NOTIF.send("Archive", "not found: " .. nm) end
    end)
    sbox.BackgroundColor3 = P.panel; sbox.BorderSizePixel = 0
    sbox.Font = Enum.Font.Gotham; sbox.TextSize = 12; sbox.TextColor3 = P.tx
    sbox.PlaceholderText = "search"; sbox.PlaceholderColor3 = P.mt
    sbox.Text = ""; sbox.ClearTextOnFocus = false; sbox.TextXAlignment = Enum.TextXAlignment.Left
    G.mkC(sbox, 3); G.mkS(sbox, P.brd, 1, 0)
    local spd = G.new("UIPadding", sbox); spd.PaddingLeft = G.UD(0, 8); spd.PaddingRight = G.UD(0, 8)

    local TABS = {
        {id = "combat", label = "Combat"}, {id = "visual", label = "Visuals"},
        {id = "move", label = "Move"}, {id = "game", label = "Game"},
        {id = "auto", label = "Automation"}, {id = "hallow", label = "Halloween"},
        {id = "util", label = "Utility"}, {id = "setup", label = "Settings"},
    }
    local tabY, tabH = 78, 24
    local tabW = math.floor((W - 24) / #TABS)
    local tabBtns, tabUls, secs = {}, {}, {}
    local cur = "combat"
    local function paintTabs()
        for _, t2 in ipairs(TABS) do
            local on = t2.id == cur
            if secs[t2.id] then secs[t2.id].Visible = on end
            tabBtns[t2.id].TextColor3 = on and P.tx or P.mt
            local u2 = tabUls[t2.id]
            u2.Visible = true
            u2.BackgroundTransparency = on and 0 or 1
        end
        pcall(UI.refreshRows)
    end
    local tabBar = G.new("Frame", UI.mFrame)
    tabBar.Name = "TABBAR"
    tabBar.BackgroundTransparency = 1; tabBar.BorderSizePixel = 0
    tabBar.Position = G.UD2(0, 12, 0, tabY); tabBar.Size = G.UD2(1, -24, 0, tabH + 2)
    for i, td in ipairs(TABS) do
        local b = G.new("TextButton", tabBar)
        b.Name = "TAB_" .. td.id
        b.Position = G.UD2(0, 0, 0, 0); b.Size = G.UD2(0, tabW, 0, tabH)
        b.BackgroundTransparency = 1; b.BorderSizePixel = 0; b.AutoButtonColor = false
        b.Font = Enum.Font.GothamMedium; b.TextSize = 12; b.TextColor3 = P.mt; b.Text = td.label
        b.TextXAlignment = Enum.TextXAlignment.Center; b.TextYAlignment = Enum.TextYAlignment.Center
        b.TextTruncate = Enum.TextTruncate.None
        local ul = G.new("Frame", tabBar)
        ul.Name = "TABU_" .. td.id
        ul.Position = G.UD2(0, 8, 0, tabH); ul.Size = G.UD2(0, tabW - 16, 0, 2)
        ul.BackgroundColor3 = P.amb; ul.BorderSizePixel = 0; ul.Visible = false
        tabBtns[td.id], tabUls[td.id] = b, ul
        b.MouseButton1Click:Connect(function()
            cur = td.id
            UI._curTab = td.id
            for _, t2 in ipairs(TABS) do
                local on = t2.id == cur
                if secs[t2.id] then secs[t2.id].Visible = on end
                tabBtns[t2.id].TextColor3 = on and P.tx or P.mt
                local u2 = tabUls[t2.id]
                u2.Visible = true
                if on then
                    G.TS:Create(u2, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                else
                    u2.BackgroundTransparency = 1
                end
            end
            pcall(UI.refreshRows)
        end)
    end
    local function layoutTabs()
        local barW = math.floor((UI._W or W) - 24)
        if barW < 40 then barW = math.floor(tabBar.AbsoluteSize.X) end
        local n = #TABS
        local ts = game:GetService("TextService")
        local widths, total = {}, 0
        for _, td in ipairs(TABS) do
            local tw = 0
            pcall(function()
                tw = ts:GetTextSize(td.label, 12, Enum.Font.GothamMedium, Vector2.new(1000, 40)).X
            end)
            tw = math.ceil(tw) + 14
            widths[td.id] = tw
            total = total + tw
        end
        local gap = 0
        if total < barW then gap = math.floor((barW - total) / n) end
        local x = 0
        for _, td in ipairs(TABS) do
            local b = tabBtns[td.id]
            local ul = tabUls[td.id]
            local w = widths[td.id] + gap
            b.Position = G.UD2(0, x, 0, 0)
            b.Size = G.UD2(0, w, 0, tabH)
            ul.Position = G.UD2(0, x + 6, 0, tabH)
            ul.Size = G.UD2(0, math.max(4, w - 12), 0, 2)
            x = x + w
        end
    end
    layoutTabs()
    UI._layoutTabs = layoutTabs

    local bodyY, footH = UI._bodyY, UI._footH
    local body = G.new("Frame", UI.mFrame)
    body.Position = G.UD2(0, 0, 0, bodyY); body.Size = G.UD2(1, 0, 0, frameH() - bodyY - footH)
    body.BackgroundTransparency = 1; body.BorderSizePixel = 0
    body.ClipsDescendants = true
    UI._body = body
    local function mkSec(id)
        local sc = G.new("ScrollingFrame", body)
        sc.Name = "SEC_" .. id
        sc.Position = G.UD2(0, 0, 0, 0); sc.Size = G.UD2(1, 0, 1, 0)
        sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0; sc.ScrollBarThickness = 4
        sc.ScrollBarImageColor3 = P.brd; sc.CanvasSize = G.UD2(0, 0, 0, 0)
        sc.Visible = false; sc.Active = true; sc.ScrollingDirection = Enum.ScrollingDirection.Y
        sc.ClipsDescendants = true
        sc.AutomaticCanvasSize = Enum.AutomaticSize.None
        secs[id] = sc
        UI._secs = UI._secs or {}
        UI._secs[id] = sc
        return sc
    end

    UI.rows, UI.flipOf = {}, {}
    UI._groups = {}
    local function reflow(sec)
        if sec then
            local sc = secs[sec]; if not sc then return end
            local childY = 0
            for _, c in ipairs(sc:GetChildren()) do
                if c:IsA("Frame") and c.Visible then
                    local b = c.Position.Y.Offset + c.Size.Y.Offset
                    if b > childY then childY = b end
                end
            end
            sc.CanvasSize = UDim2.new(0, 0, 0, childY + 80)
            return
        end
        for _, s2 in pairs(secs) do
            local childY = 0
            for _, c in ipairs(s2:GetChildren()) do
                if c:IsA("Frame") and c.Visible then
                    local b = c.Position.Y.Offset + c.Size.Y.Offset
                    if b > childY then childY = b end
                end
            end
            s2.CanvasSize = UDim2.new(0, 0, 0, childY + 80)
        end
    end
    UI._reflowAll = reflow
    local function syncCanvas(sec) reflow(sec) end
    local function secY(sec)
        UI._secY = UI._secY or {}
        if UI._secY[sec] == nil then UI._secY[sec] = 0 end
        return UI._secY[sec]
    end
    local function secAdvance(sec, dh)
        UI._secY = UI._secY or {}
        UI._secY[sec] = (UI._secY[sec] or 0) + dh
        local sc = secs[sec]
        if sc then sc.CanvasSize = UDim2.new(0, 0, 0, UI._secY[sec] + 60) end
    end
    
    
    local function group(sec, title, xs, ws)
        xs, ws = xs or 0, ws or 1
        local sc = secs[sec]
        local y = secY(sec)
        local h = G.new("Frame", sc)
        h.Name = "H_" .. title
        h.BackgroundTransparency = 1; h.BorderSizePixel = 0
        h.Position = G.UD2(xs, xs == 0 and 12 or 6, 0, y); h.Size = G.UD2(ws, ws == 1 and 0 or -18, 0, 22)
        UI.sectHead(h, 2, frameW() * ws, title)
        secAdvance(sec, 22)
        local gy = secY(sec)
        local g = G.new("Frame", sc)
        g.Name = "G_" .. title
g.BackgroundColor3 = P.panel; g.BackgroundTransparency = 0.15; g.BorderSizePixel = 0
    G.mkC(g, 5); G.mkS(g, P.brd, 1, 0)
        g.Position = G.UD2(xs, xs == 0 and 12 or 6, 0, gy); g.Size = G.UD2(ws, ws == 1 and -24 or -18, 0, 16)
        local inner = G.new("Frame", g)
        inner.Name = "IN"
        inner.BackgroundTransparency = 1; inner.BorderSizePixel = 0
        inner.Position = G.UD2(0, 8, 0, 8); inner.Size = G.UD2(1, -16, 0, 0)
        local st = {g = g, inner = inner, sec = sec, y = 0, title = title, wf = ws}
        UI._groups[sec] = UI._groups[sec] or {}
        G.ti(UI._groups[sec], st)
        local function grow(dh)
            inner.Size = G.UD2(1, -16, 0, inner.Size.Y.Offset + dh)
            g.Size = G.UD2(ws, ws == 1 and -24 or -18, 0, inner.Size.Y.Offset + 16)
            secAdvance(sec, dh)
        end
        st.grow = grow
        secAdvance(sec, 16)
        return st
    end
    local function growTo(st, dh) st.grow(dh) end
    local function feat(st, key, name, desc, flip, subFn, indent, nobind)
        local w = frameW() * (st.wf or 1) - 16
        local api = UI.featRow(st.inner, 0, st.y, w, name, desc, key, indent, nobind)
        UI.rows[key] = api
        UI.flipOf[key] = flip
        api.snapSet(S[key] == true)
        if subFn then api.sub(subFn()) end
        st.y = st.y + 34
        growTo(st, 34)
        return api
    end 
    local function sect(sec, txt)
        local sc = secs[sec]
        local y = secY(sec)
        local f = G.new("Frame", sc)
        f.Name = "H_" .. txt
        f.BackgroundTransparency = 1; f.BorderSizePixel = 0
        f.Position = G.UD2(0, 0, 0, y); f.Size = G.UD2(1, 0, 0, 30)
        UI.sectHead(f, 6, frameW(), txt)
        UI.divider(f, 26, frameW())
        secAdvance(sec, 30)
    end
    local function block(st, h)
        local f = G.new("Frame", st.inner)
        f.Name = "B" .. tostring(st.y)
        f.BackgroundTransparency = 1; f.BorderSizePixel = 0
        f.Position = G.UD2(0, 0, 0, st.y); f.Size = G.UD2(1, 0, 0, h)
        st.y = st.y + h
        growTo(st, h)
        return f
    end
    
    

    mkSec("combat"); mkSec("visual"); mkSec("move"); mkSec("game"); mkSec("auto"); mkSec("hallow"); mkSec("util"); mkSec("setup")
    UI._meta = {}
    local function meta(key, sec, tab, label, desc, sub)
        UI._meta[key] = {sec = sec, tab = tab, label = label, desc = desc, sub = sub}
    end

    do
        local g = group("combat", "breaker")
        feat(g, "pktPlk", "New breaker", "low-rate anim hybrid", FLIP.pktPlk)
        meta("pktPlk", "combat", "combat", "new breaker", "low-rate anim hybrid")
        local f = block(g, 26)
        local mb = G.new("TextButton", f)
        mb.Position = G.UD2(0, 12, 0, 3); mb.Size = G.UD2(1, -24, 0, 20)
        mb.BackgroundColor3 = G.RGB(26, 28, 36); mb.BorderSizePixel = 0; mb.AutoButtonColor = false
        mb.Font = Enum.Font.GothamBold; mb.TextSize = 14; mb.TextColor3 = P.amb
        mb.Text = "mode: " .. (CFG.PKTMode or "aggressive")
        G.mkC(mb, 3); G.mkS(mb, P.brd, 1, 0)
        G.btnFx(mb, false, P.amb)
        mb.MouseButton1Click:Connect(function()
            local modes = {"passive", "aggressive", "blatant"}
            local idx = table.find(modes, CFG.PKTMode or "aggressive") or 2
            CFG.PKTMode = modes[(idx % #modes) + 1]; mb.Text = "mode: " .. CFG.PKTMode
            if S.pktPlk then PACKET_PLK:stp(); PACKET_PLK:start() end
        end)
    end
    do
        local g = group("visual", "esp")
        local ESTABS = {"main", "player", "mob", "npc", "chest"}
        local ESNM = {main = "Main", player = "Player", mob = "Mob", npc = "NPC", chest = "Chest"}
        local PAGE, PGH = {}, {}
        local esCur = "main"
        local ESTY, ESTH = 2, 22
        for i, id in ipairs(ESTABS) do
            local b = G.new("TextButton", g.inner)
            b.Position = G.UD2((i - 1) / #ESTABS, 0, 0, ESTY); b.Size = G.UD2(1 / #ESTABS, 0, 0, ESTH)
            b.BackgroundTransparency = 1; b.BorderSizePixel = 0; b.AutoButtonColor = false
            b.Font = Enum.Font.GothamMedium; b.TextSize = 12; b.TextColor3 = P.mt; b.Text = ESNM[id]
            b.TextTruncate = Enum.TextTruncate.AtEnd
            local ul = G.new("Frame", g.inner)
            ul.Position = G.UD2((i - 1) / #ESTABS, 8, 0, ESTY + ESTH); ul.Size = G.UD2(1 / #ESTABS, -16, 0, 2)
            ul.BackgroundColor3 = P.amb; ul.BorderSizePixel = 0; ul.Visible = true
            ul.BackgroundTransparency = id == "main" and 0 or 1
            local pg = G.new("Frame", g.inner)
            pg.BackgroundTransparency = 1; pg.BorderSizePixel = 0
            pg.Position = G.UD2(0, 0, 0, ESTY + ESTH + 6); pg.Size = G.UD2(1, 0, 0, 0)
            pg.Visible = id == "main"
            local st = {inner = pg, sec = "visual", y = 0, wf = 1, title = "esp", id = id, b = b, ul = ul}
            function st.grow(dh)
                PGH[id] = st.y
                pg.Size = G.UD2(1, 0, 0, st.y)
            end
            PAGE[id] = st
            if id == "main" then b.TextColor3 = P.tx end
            b.MouseButton1Click:Connect(function() UI._esShow(id) end)
        end
        local function esRefit()
            local h = PGH[esCur] or 0
            local newIn = ESTY + ESTH + 6 + h
            local oldIn = g.inner.Size.Y.Offset
            local dh = newIn - oldIn
            if dh ~= 0 then
                local sc = secs["visual"]
                local bottom = g.g.Position.Y.Offset + g.g.Size.Y.Offset
                for _, c in ipairs(sc:GetChildren()) do
                    if c:IsA("Frame") and c ~= g.g and c.Position.Y.Offset >= bottom - 1 then
                        c.Position = G.UD2(c.Position.X.Scale, c.Position.X.Offset, 0, c.Position.Y.Offset + dh)
                    end
                end
                g.g.Size = G.UD2(g.g.Size.X.Scale, g.g.Size.X.Offset, 0, newIn + 16)
                g.inner.Size = G.UD2(1, -16, 0, newIn)
                secAdvance("visual", dh)
            end
        end
        local function esShow(id)
            if id == esCur then return end
            esCur = id
            for _, o in pairs(PAGE) do
                local on = o.id == id
                o.inner.Visible = on
                o.b.TextColor3 = on and P.tx or P.mt
                o.ul.BackgroundTransparency = on and 0 or 1
            end
            esRefit()
            pcall(UI.refreshRows)
        end
        UI._esShow = esShow
        local ERKEYS = {"PlrEspRange", "PlrEspFps", "MobEspRange", "MobEspFps", "NpcEspRange", "NpcEspFps", "ChestEspRange", "ChestEspFps"}
        local function espDim()
            local c = S.espGlobal and P.mt or P.amb
            local refs = UI._rowRefs or {}
            for _, rk in ipairs(ERKEYS) do
                local r = refs[rk]
                if r and r.val then r.val.TextColor3 = c end
            end
        end
        UI._espDim = espDim
        local pMain = PAGE["main"]
        feat(pMain, "espGlobal", "Use Global Settings", "one range + fps for every ESP", FLIP.espG)
        meta("espGlobal", "visual", "visuals", "use global settings", "one range + fps", "main")
        local b1 = block(pMain, 32)
        UI.slideRow(b1, 0, 0, frameW() - 16, "global range", 50, 4000, CFG.EspRange, function(v) CFG.EspRange = v end, "EspRange", " studs")
        local b2 = block(pMain, 32)
        UI.slideRow(b2, 0, 0, frameW() - 16, "global esp fps", 1, 100, CFG.EspFps or 60, function(v) CFG.EspFps = v end, "EspFps", " fps")
        local pPlr = PAGE["player"]
        feat(pPlr, "esp", "Player ESP", "boxes · health · distance", FLIP.esp)
        meta("esp", "visual", "visuals", "player esp", "boxes health distance", "player")
        UI.slideRow(block(pPlr, 32), 0, 0, frameW() - 16, "range", 50, 4000, CFG.PlrEspRange, function(v) CFG.PlrEspRange = v end, "PlrEspRange", " studs")
        UI.slideRow(block(pPlr, 32), 0, 0, frameW() - 16, "esp fps", 1, 100, CFG.PlrEspFps or 60, function(v) CFG.PlrEspFps = v end, "PlrEspFps", " fps")
        feat(pPlr, "espBox", "Show box", "outline only", FLIP.espBox, nil, 16)
        meta("espBox", "visual", "visuals", "show box", "outline", "player")
        feat(pPlr, "espLvl", "Show level", "power tag", FLIP.espLvl, nil, 16)
        meta("espLvl", "visual", "visuals", "show level", "power tag", "player")
        feat(pPlr, "espHp", "Show hp %", "percent tag", FLIP.espHp, nil, 16)
        meta("espHp", "visual", "visuals", "show hp", "percent", "player")
        feat(pPlr, "htnl", "Health text", "exact values", FLIP.htnl, nil, 16)
        meta("htnl", "visual", "visuals", "health text", "exact values", "player")
        local pMob = PAGE["mob"]
        feat(pMob, "mobEsp", "Mob ESP", "health · poser callout", FLIP.mobEsp)
        meta("mobEsp", "visual", "visuals", "mob esp", "health poser", "mob")
        UI.slideRow(block(pMob, 32), 0, 0, frameW() - 16, "range", 50, 4000, CFG.MobEspRange, function(v) CFG.MobEspRange = v end, "MobEspRange", " studs")
        UI.slideRow(block(pMob, 32), 0, 0, frameW() - 16, "esp fps", 1, 100, CFG.MobEspFps or 60, function(v) CFG.MobEspFps = v end, "MobEspFps", " fps")
        local pNpc = PAGE["npc"]
        feat(pNpc, "nEsp", "NPC ESP", "quest givers", FLIP.nEsp)
        meta("nEsp", "visual", "visuals", "npc esp", "quest", "npc")
        UI.slideRow(block(pNpc, 32), 0, 0, frameW() - 16, "range", 50, 4000, CFG.NpcEspRange, function(v) CFG.NpcEspRange = v end, "NpcEspRange", " studs")
        UI.slideRow(block(pNpc, 32), 0, 0, frameW() - 16, "esp fps", 1, 100, CFG.NpcEspFps or 60, function(v) CFG.NpcEspFps = v end, "NpcEspFps", " fps")
        local pCht = PAGE["chest"]
        feat(pCht, "cEsp", "Chest ESP", "nearby chests", FLIP.cEsp)
        meta("cEsp", "visual", "visuals", "chest esp", "chests", "chest")
        UI.slideRow(block(pCht, 32), 0, 0, frameW() - 16, "range", 50, 4000, CFG.ChestEspRange, function(v) CFG.ChestEspRange = v end, "ChestEspRange", " studs")
        UI.slideRow(block(pCht, 32), 0, 0, frameW() - 16, "esp fps", 1, 100, CFG.ChestEspFps or 60, function(v) CFG.ChestEspFps = v end, "ChestEspFps", " fps")
        esRefit()
        espDim()
    end
    do
        local g = group("visual", "spectator")
        feat(g, "spec", "Spectator", "view players", FLIP.spec)
        meta("spec", "visual", "visuals", "spectator", "view players")
        feat(g, "specRobloxNames", "View Roblox Names", "show roblox usernames instead of game names", FLIP.specRobloxNames, nil, 16)
        meta("specRobloxNames", "visual", "visuals", "view roblox names", "roblox usernames")
    end
    do
        local g = group("visual", "screen")
        feat(g, "effDisable", "Effect disabler", "scrub screen fx", FLIP.eff)
        meta("effDisable", "visual", "visuals", "effect disabler", "screen fx")
        feat(g, "effHunger", "Hunger blur", "generic blur", FLIP.effH, nil, 16, true)
        meta("effHunger", "visual", "visuals", "hunger blur", "generic")
        feat(g, "effUnderwater", "Underwater blur", "dive blur", FLIP.effU, nil, 16, true)
        meta("effUnderwater", "visual", "visuals", "underwater blur", "dive")
        feat(g, "effSanity", "Sanity effects", "terror overlays", FLIP.effS, nil, 16, true)
        meta("effSanity", "visual", "visuals", "sanity effects", "terror")
        feat(g, "sanityHud", "Sanity bar", "docked meter", FLIP.sanity)
        meta("sanityHud", "visual", "visuals", "sanity bar", "meter")
    end
    do
        local g = group("visual", "lighting")
        do local a = feat(g, "bright", "Full bright", "override games brightness", FLIP.bright); a.val(function() return string.format("%.1fx", CFG.BrightVal) end) end
        meta("bright", "visual", "visuals", "full bright", "")
        local f = block(g, 32)
        UI.slideRow(f, 0, 0, frameW() - 16, "brightness", 1, 6, CFG.BrightVal, function(v) CFG.BrightVal = v; if UI.rows.bright then UI.rows.bright.chip() end end, "BrightVal", "x", 0.1)
        feat(g, "noVis", "Fog Disabler", "remove fog", FLIP.nv)
        meta("noVis", "visual", "visuals", "fog disabler", "fog")
    end
    do
        local g = group("move", "agility")
        do local a = feat(g, "agil", "Agility", "spoof agility", FLIP.ag); a.val(function() return tostring(CFG.AgilVal) .. " agil" end) end
        meta("agil", "move", "move", "agility", "spoof")
        local f = block(g, 32)
        UI.slideRow(f, 0, 0, frameW() - 16, "agility", CFG.AgilMin, CFG.AgilMax, CFG.AgilVal, function(v) CFG.AgilVal = v; if UI.rows.agil then UI.rows.agil.chip() end end, "AgilVal", " agil")
        do local a = feat(g, "agSpd", "Speed bonus", "cframe nudge", FLIP.agSpd); a.val(function() return "+" .. tostring(CFG.SpdVal) .. " spd" end) end
        meta("agSpd", "move", "move", "speed bonus", "cframe")
        local f2 = block(g, 32)
        UI.slideRow(f2, 0, 0, frameW(), "speed", CFG.SpdMin, CFG.SpdMax, CFG.SpdVal, function(v) CFG.SpdVal = v; if UI.rows.agSpd then UI.rows.agSpd.chip() end end, "SpdVal", " spd")
    end
    do
        local g = group("move", "travel")
        feat(g, "nc", "No-clip", "through walls", FLIP.nc)
        meta("nc", "move", "move", "no-clip", "walls")
        feat(g, "nfd", "No fall damage", "landing guard", FLIP.nf)
        meta("nfd", "move", "move", "no fall damage", "landing")
        do local a = feat(g, "fly", "Fly", "wasd / space+shift", FLIP.fly); a.val(function() return tostring(CFG.FlySpeed) end) end
        meta("fly", "move", "move", "fly", "wasd space shift")
        local f = block(g, 32)
        UI.slideRow(f, 0, 0, frameW() - 16, "fly speed", 10, 150, CFG.FlySpeed or 80, function(v) CFG.FlySpeed = v; if UI.rows.fly then UI.rows.fly.chip() end end, "FlySpeed", " studs")
    end
    do
        local g = group("move", "animation")
        do local a = feat(g, "aSpd", "Anim speed", "playback rate", FLIP.as); a.val(function() return string.format("%.1fx", CFG.ASpdVal) end) end
        meta("aSpd", "move", "move", "anim speed", "playback")
        local f = block(g, 32)
        UI.slideRow(f, 0, 0, frameW() - 16, "anim", 0.5, 5, CFG.ASpdVal, function(v) CFG.ASpdVal = v; if UI.rows.aSpd then UI.rows.aSpd.chip() end end, "ASpdVal", "x", 0.1)
        feat(g, "mSpd", "Mantra speed", "action2-4 rate", FLIP.mSpd)
        meta("mSpd", "move", "move", "mantra speed", "action")
        local f2 = block(g, 32)
        UI.slideRow(f2, 0, 0, frameW(), "mantra", 0.5, 5, CFG.MSpdVal, function(v) CFG.MSpdVal = v end, "MSpdVal", "x", 0.1)
    end
    do
        local gy0 = secY("game")
        local g = group("game", "mobs", 0, 0.5)        feat(g, "npcFreeze", "Freeze mobs", "hold nearby", FLIP.npcFreeze)
        meta("npcFreeze", "game", "game", "freeze mobs", "hold")
        feat(g, "humanoidPathfindBreaker", "Pathfind breaker", "break npc pathing", FLIP.hpb)
        meta("humanoidPathfindBreaker", "game", "game", "pathfind breaker", "pathing")
        feat(g, "attachToBack", "Attach to back", "follow target", FLIP.back)
        meta("attachToBack", "game", "game", "attach to back", "follow")
        local f = block(g, 64)
        local api = UI.dropBlock(f, 0, 0, frameW() - 16, "mob target", {}, nil, function(nm)
            pcall(function()
                for _, m in ipairs(BACK.list() or {}) do
                    if m.Name == nm then S.attachTarget = m; break end
                end
            end)
        end)
        UI.mobDrop = api
        local btn = G.new("TextButton", f)
        btn.Position = G.UD2(0, 12, 0, 42); btn.Size = G.UD2(0, 140, 0, 18)
        btn.BackgroundColor3 = G.RGB(26, 28, 36); btn.BorderSizePixel = 0; btn.AutoButtonColor = false
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.TextColor3 = P.tx; btn.Text = "refresh targets"
        G.mkC(btn, 3); G.mkS(btn, P.brd, 1, 0)
        G.btnFx(btn, false)
        btn.MouseButton1Click:Connect(function()
            local names = {}
            pcall(function() for _, m in ipairs(BACK.list() or {}) do G.ti(names, m.Name) end end)
            api.fill(names, S.attachTarget and S.attachTarget.Name)
        end)
    end
    do
        local g = group("game", "world", 0, 0.5)
        feat(g, "autoloot", "Auto loot", "opened chests", FLIP.autoloot)
        meta("autoloot", "game", "game", "auto loot", "chests")
        feat(g, "nkb", "No kill bricks", "strip kill parts", FLIP.nkb)
        meta("nkb", "game", "game", "no kill bricks", "kill parts")
    end
    do
        local leftEnd = secY("game")
        UI._secY["game"] = gy0
        local g = group("game", "teleport", 0.5, 0.5)
        for _, loc in ipairs(TP_LOCS) do
            local f = block(g, 38)
            local b = G.new("TextButton", f)
            b.Position = G.UD2(0, 12, 0, 7); b.Size = G.UD2(1, -24, 0, 24)
            b.BackgroundColor3 = G.RGB(26, 28, 36); b.BorderSizePixel = 0; b.AutoButtonColor = false
            b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.TextColor3 = P.tx
            b.Text = "  " .. loc.n; b.TextXAlignment = Enum.TextXAlignment.Left
            G.mkC(b, 4); G.mkS(b, P.brd, 1, 0)
            G.btnFx(b, false)
            b.MouseButton1Click:Connect(function()
                TELE.go(loc)
            end)
            meta("tp_" .. loc.n, "game", "game", string.lower(loc.n), "teleport")
        end
        local f = block(g, 32)
        local stop = G.new("TextButton", f)
        stop.Position = G.UD2(0, 12, 0, 4); stop.Size = G.UD2(1, -24, 0, 24)
        stop.BackgroundColor3 = G.RGB(26, 28, 36); stop.BorderSizePixel = 0; stop.AutoButtonColor = false
        stop.Font = Enum.Font.GothamBold; stop.TextSize = 14; stop.TextColor3 = G.RGB(232, 132, 128)
        stop.Text = "  stop"; stop.TextXAlignment = Enum.TextXAlignment.Left
        G.mkC(stop, 4); G.mkS(stop, P.brd, 1, 0)
        G.btnFx(stop, true)
        stop.MouseButton1Click:Connect(function() TELE.stop(); NOTIF.send("Teleport", "Stopped") end)
        local rightEnd = secY("game")
        UI._secY["game"] = math.max(leftEnd, rightEnd)
        do
            local gs = UI._groups["game"] or {}
            local teleSt, worldSt = gs[#gs], gs[#gs - 1]
            local function pad(st, dh)
                if not st or not st.g or not st.g.Parent or dh <= 0 then return end
                st.inner.Size = G.UD2(1, -16, 0, st.inner.Size.Y.Offset + dh)
                st.g.Size = G.UD2(0.5, -18, 0, st.g.Size.Y.Offset + dh)
            end
            if leftEnd < rightEnd then pad(worldSt, rightEnd - leftEnd)
            elseif rightEnd < leftEnd then pad(teleSt, leftEnd - rightEnd) end
        end
    end
    do
        local g = group("game", "danger")
        local f = block(g, 30)
        UI.actBtn(f, 12, 4, 0, 20, "reset character", true, RST.go)
        meta("resetChar", "game", "game", "reset character", "reset")
    end
    do
        local g = group("hallow", "hallowtide")
        local a = feat(g, "gourd", "Auto Gourdskipper", "wave · kill order · chests", FLIP.gourd, GOURD.status)
        meta("gourd", "hallow", "halloween", "auto gourdskipper", "hallowtide trial")
        UI.info(a.root, -104, 8,
            "Auto Gourdskipper Trial: Automatically start waves, kill gourdskippers and loot chests in order.\n\nSteps:\n1. Equip weapon\n2. Enable shiftlock\n3. Toggle on and hide the menu (" .. G.kName(kb.menuKey or CFG.MenuKey) .. ")",
            nil, 348, 136)
        local f = block(g, 26)
        G.mkL(f, "dungeon only · place 8668476218", 12, 5, 320, 16, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
    end
    do
        local g = group("auto", "auto builder")
        local function autoRow(key, title, getSub, flip, infoTip)
            local f = G.new("Frame", g.inner)
            f.Name = "R_" .. key
            f.BackgroundTransparency = 1; f.BorderSizePixel = 0
            f.Position = G.UD2(0, 0, 0, g.y); f.Size = G.UD2(1, 0, 0, 40)
            local t = G.mkL(f, title, 4, 0, 300, 20, 14, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.tx)
            local s = G.mkL(f, "", 4, 20, 200, 16, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
            s.Size = G.UD2(1, -70, 0, 16)
            s.TextTruncate = Enum.TextTruncate.AtEnd
            local hov = G.new("Frame", f)
            hov.BackgroundColor3 = P.hover; hov.BackgroundTransparency = 1; hov.BorderSizePixel = 0
            hov.Size = G.UD2(1, 0, 1, 0)
            G.mkC(hov, 3)
            local hit = G.new("TextButton", f)
            hit.BackgroundTransparency = 1; hit.BorderSizePixel = 0; hit.Text = ""; hit.AutoButtonColor = false
            hit.Size = G.UD2(1, 0, 1, 0)
            hit.MouseEnter:Connect(function() hov.BackgroundTransparency = 0.75 end)
            hit.MouseLeave:Connect(function() hov.BackgroundTransparency = 1 end)
            hit.MouseButton1Click:Connect(function() if flip then flip() end end)
            local abox = G.new("Frame", f)
            abox.Size = G.UD2(0, 14, 0, 14); abox.Position = G.UD2(1, -22, 0, 13)
            abox.BackgroundTransparency = 1; abox.BorderSizePixel = 0
            G.mkC(abox, 2); G.mkS(abox, P.brd, 1, 0)
            if infoTip then
                local iw = 110
                pcall(function()
                    local ts = game:GetService("TextService"):GetTextSize(title, 14, Enum.Font.GothamMedium, Vector2.new(500, 20)).X
                    if ts and ts > 0 then iw = math.ceil(ts) + 12 end
                end)
                if iw < 20 then iw = 110 end
                UI.info(f, iw, 3, infoTip)
            end
            local api = {root = f}
            local function paint(on)
                s.TextColor3 = on and P.amb or P.mt
                abox.BackgroundTransparency = on and 0 or 1
                abox.BackgroundColor3 = on and P.amb or P.base
                local st = abox:FindFirstChildOfClass("UIStroke")
                if st then st.Color = on and P.amb or P.brd end
            end
            function api.set(on) paint(on) end
            function api.snapSet(on) paint(on) end
            function api.sub(txt) s.Text = txt end
            function api.chip() end
            UI.rows[key] = api
            UI.flipOf[key] = flip
            api.snapSet(S[key] == true)
            api.sub(getSub())
            g.y = g.y + 40
            g.grow(40)
            return api
        end
        autoRow("autoBuild", "Auto builder", function() return BUILDER.status() end, FLIP.ab,
            "Picks talents and mantras from your builder link as hands appear.")
        meta("autoBuild", "auto", "automation", "auto builder", "talents mantras")
        autoRow("autoPoints", "Stat spender", function() return BUILDER.shrined and "post-shrine" or "pre-shrine" end, FLIP.abPts,
            "Spends attribute points pre-shrine, then post-shrine after you mark shrined.")
        meta("autoPoints", "auto", "automation", "stat spender", "stats shrine")
        local f = block(g, 84)
        local url = G.new("TextBox", f)
        url.Position = G.UD2(0, 12, 0, 4); url.Size = G.UD2(1, -24, 0, 26)
        url.BackgroundColor3 = P.base; url.BorderSizePixel = 0
        url.Font = Enum.Font.Code; url.TextSize = 12; url.TextColor3 = P.tx
        url.PlaceholderText = "deepwoken builder link"; url.PlaceholderColor3 = P.mt
        url.Text = CFG.AutoBuildUrl or ""; url.TextXAlignment = Enum.TextXAlignment.Left; url.ClearTextOnFocus = false
        G.mkC(url, 6); G.mkS(url, P.brd, 1, 0)
        local pd = G.new("UIPadding", url); pd.PaddingLeft = G.UD(0, 10); pd.PaddingRight = G.UD(0, 10)
        UI._autoUrlBox = url
        url.FocusLost:Connect(function() CFG.AutoBuildUrl = url.Text end)
        local function pairBtn(half, txt, icon, cb)
            local b = G.new("TextButton", f)
            if half == 0 then
                b.Position = G.UD2(0, 12, 0, 38); b.Size = G.UD2(0.5, -18, 0, 26)
            else
                b.Position = G.UD2(0.5, 6, 0, 38); b.Size = G.UD2(0.5, -18, 0, 26)
            end
            b.BackgroundColor3 = G.RGB(26, 28, 36); b.BorderSizePixel = 0; b.AutoButtonColor = false
            b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.TextColor3 = P.tx
            b.Text = (icon and "    " or "") .. txt
            G.mkC(b, 4); G.mkS(b, P.brd, 1, 0)
            G.btnFx(b, false)
            if icon then
                local im = G.new("ImageLabel", b)
                im.Size = G.UD2(0, 14, 0, 14); im.Position = G.UD2(0.5, -52, 0.5, -7)
                im.BackgroundTransparency = 1; im.Image = "rbxassetid://109698732019071"
            end
            b.MouseButton1Click:Connect(function() if cb then cb() end end)
            return b
        end
        UI._autoLoadBtn = pairBtn(0, "load build", true, function()
            CFG.AutoBuildUrl = url.Text
            BUILDER.load()
        end)
        pairBtn(1, "i have shrined", false, function()
            BUILDER.shrined, BUILDER.logged = true, false
            BUILDER.spent, BUILDER.baseInv, BUILDER.baselined = {}, {}, false
        BUILDER.tSpent, BUILDER.tBase = {}, nil
        BUILDER.tLogged = false
        BUILDER.tEmpty = false
            pcall(function() BUILDER.unlockAll() end)
            UI._prevMode = "post"
            NOTIF.send("Auto Builder", "post-shrine spread live")
            pcall(UI.refreshRows)
            pcall(function() BUILDER.preview() end)
        end)
        local clr = G.new("TextButton", f)
        clr.Position = G.UD2(1, -70, 0, 66); clr.Size = G.UD2(0, 58, 0, 14)
        clr.BackgroundTransparency = 1; clr.BorderSizePixel = 0; clr.AutoButtonColor = false
        clr.Font = Enum.Font.GothamMedium; clr.TextSize = 12; clr.TextColor3 = P.mt
        clr.Text = "clear"; clr.TextXAlignment = Enum.TextXAlignment.Right
        clr.MouseEnter:Connect(function() clr.TextColor3 = P.dng end)
        clr.MouseLeave:Connect(function() clr.TextColor3 = P.mt end)
        clr.MouseButton1Click:Connect(function()
            BUILDER.wipe()
            NOTIF.send("Auto Builder", "build cleared")
        end)
    end
    do
        local g = group("auto", "build preview")
        UI._prevMode = UI._prevMode or "pre"
        local f = block(g, 490)
        local segBG = G.new("Frame", f)
        segBG.Position = G.UD2(0, 12, 0, 4); segBG.Size = G.UD2(1, -24, 0, 30)
        segBG.BackgroundColor3 = G.RGB(26, 28, 36); segBG.BorderSizePixel = 0
        G.mkC(segBG, 4); G.mkS(segBG, P.brd, 1, 0)
        local segDiv = G.new("Frame", segBG)
        segDiv.AnchorPoint = G.V2(0.5, 0); segDiv.Position = G.UD2(0.5, 0, 0, 5); segDiv.Size = G.UD2(0, 1, 1, -10)
        segDiv.BackgroundColor3 = P.brd; segDiv.BorderSizePixel = 0
        local preB = G.new("TextButton", segBG)
        preB.Position = G.UD2(0, 0, 0, 0); preB.Size = G.UD2(0.5, 0, 1, -3)
        preB.BackgroundTransparency = 1; preB.BorderSizePixel = 0; preB.AutoButtonColor = false
        preB.Font = Enum.Font.GothamMedium; preB.TextSize = 14; preB.TextColor3 = P.tx; preB.Text = "PRE"
        local preU = G.new("Frame", segBG)
        preU.AnchorPoint = G.V2(0.5, 1); preU.Position = G.UD2(0.25, 0, 1, -2); preU.Size = G.UD2(0.5, -20, 0, 2)
        preU.BackgroundColor3 = P.amb; preU.BorderSizePixel = 0
        local postB = G.new("TextButton", segBG)
        postB.Position = G.UD2(0.5, 0, 0, 0); postB.Size = G.UD2(0.5, 0, 1, -3)
        postB.BackgroundTransparency = 1; postB.BorderSizePixel = 0; postB.AutoButtonColor = false
        postB.Font = Enum.Font.GothamMedium; postB.TextSize = 14; postB.TextColor3 = P.mt; postB.Text = "POST"
        local postU = G.new("Frame", segBG)
        postU.AnchorPoint = G.V2(0.5, 1); postU.Position = G.UD2(0.75, 0, 1, -2); postU.Size = G.UD2(0.5, -20, 0, 2)
        postU.BackgroundColor3 = P.amb; postU.BorderSizePixel = 0; postU.BackgroundTransparency = 1
        local function paint(mode)
            preB.TextColor3 = mode == "pre" and P.tx or P.mt
            preU.BackgroundTransparency = mode == "pre" and 0 or 1
            postB.TextColor3 = mode == "post" and P.tx or P.mt
            postU.BackgroundTransparency = mode == "post" and 0 or 1
        end
        UI._prevBtns = paint
        for _, job in ipairs({{b = preB, u = preU}, {b = postB, u = postU}}) do
            job.b.MouseEnter:Connect(function()
                G.TS:Create(job.b, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = P.amb}):Play()
            end)
            job.b.MouseLeave:Connect(function()
                local on = (job.b == preB and UI._prevMode == "pre") or (job.b == postB and UI._prevMode == "post")
                G.TS:Create(job.b, G.TI(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = on and P.tx or P.mt}):Play()
            end)
        end
        preB.MouseButton1Click:Connect(function() UI._prevMode = "pre"; BUILDER.preview() end)
        postB.MouseButton1Click:Connect(function() UI._prevMode = "post"; BUILDER.preview() end)
        local stats = G.new("ScrollingFrame", f)
        stats.Position = G.UD2(0, 12, 0, 44); stats.Size = G.UD2(0.55, -18, 0, 296)
        stats.BackgroundTransparency = 1; stats.BorderSizePixel = 0; stats.ScrollBarThickness = 3
        stats.ScrollBarImageColor3 = P.brd; stats.CanvasSize = G.UD2(0, 0, 0, 0)
        stats.AutomaticCanvasSize = Enum.AutomaticSize.Y
        UI._prevStats = stats
        local vpf = G.new("Frame", f)
        vpf.Position = G.UD2(0.55, 0, 0, 44); vpf.Size = G.UD2(0.45, -12, 0, 296)
        vpf.BackgroundColor3 = G.RGB(8, 9, 12); vpf.BorderSizePixel = 0
        G.mkC(vpf, 4)
        local vp = G.new("ViewportFrame", vpf)
        vp.Size = G.UD2(1, 0, 1, 0); vp.BackgroundTransparency = 1; vp.BorderSizePixel = 0
        vp.LightColor = Color3.new(1, 0.96, 0.9); vp.LightDirection = Vector3.new(0.4, -0.8, 0.6)
        vp.Ambient = Color3.new(0.7, 0.7, 0.7)
        G.mkC(vp, 4)
        UI._prevVP = vp
        BUILDER.preview()
        G.ts(function()
            local frame = UI.mFrame
            while frame and frame.Parent do
                G.tw(5)
                if frame and frame.Parent then
                    pcall(function() BUILDER.model(true) end)
                end
            end
        end)
        G.mkL(f, "S T A T S", 12, 348, 200, 14, 12, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb)
        G.mkL(f, "R E S I S T A N C E S", 12, 348, 200, 14, 12, Enum.Font.Garamond, Enum.TextXAlignment.Left, P.amb).Position = G.UD2(0.5, 6, 0, 348)
        local sl = G.new("Frame", f)
        sl.Position = G.UD2(0, 12, 0, 366); sl.Size = G.UD2(0.5, -18, 0, 112)
        sl.BackgroundTransparency = 1; sl.BorderSizePixel = 0
        local sr = G.new("ScrollingFrame", f)
        sr.Position = G.UD2(0.5, 6, 0, 366); sr.Size = G.UD2(0.5, -18, 0, 112)
        sr.BackgroundTransparency = 1; sr.BorderSizePixel = 0; sr.ScrollBarThickness = 2
        sr.ScrollBarImageColor3 = P.brd; sr.CanvasSize = G.UD2(0, 0, 0, 0)
        sr.AutomaticCanvasSize = Enum.AutomaticSize.Y
        UI._liveL, UI._liveR = sl, sr
        local order = {"Health", "Ether", "Posture", "Tempo", "Sanity", "Stealth", "WeaponPEN", "MantraPEN"}
        UI._liveTiles = {}
        for i, nm in ipairs(order) do
            local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
            local t = G.new("Frame", sl)
            t.Position = G.UD2(col * 0.333, col == 0 and 0 or 3, 0, row * 36)
            t.Size = G.UD2(0.333, -4, 0, 30)
            t.BackgroundColor3 = G.RGB(26, 28, 36); t.BorderSizePixel = 0
            G.mkC(t, 4); G.mkS(t, P.brd, 1, 0)
            local im = G.new("ImageLabel", t)
            im.Position = G.UD2(0, 5, 0.5, -8); im.Size = G.UD2(0, 16, 0, 16)
            im.BackgroundTransparency = 1
            local vv = G.mkL(t, "--", 26, 0, 80, 30, 12, Enum.Font.Code, Enum.TextXAlignment.Left, P.tx)
            vv.Size = G.UD2(1, -30, 1, 0)
            UI._liveTiles[nm] = {im = im, vv = vv}
        end
        UI._liveRes = {}
    end
    do
        local g = group("util", "safety")
        feat(g, "modDetector", "Mod detector", "staff alerts", FLIP.mod)
        meta("modDetector", "util", "utility", "mod detector", "staff alerts")
        feat(g, "modSound", "Detector sound", "alert chime", FLIP.modSnd, nil, 16, true)
        meta("modSound", "util", "utility", "detector sound", "chime")
        feat(g, "modRepeat", "Repeat alerts", "remind constantly", FLIP.modRep, nil, 16, true)
        meta("modRepeat", "util", "utility", "repeat alerts", "remind")
    end
    do
        local g = group("util", "performance")
        feat(g, "opt", "Super optimize", "lite the world", FLIP.op)
        meta("opt", "util", "utility", "super optimize", "lite")
        do local a = feat(g, "fps", "FPS limiter", "frame cap", FLIP.fps); a.val(function() return tostring(CFG.FpsVal) end) end
        meta("fps", "util", "utility", "fps limiter", "frame cap")
        local f = block(g, 52)
        UI.slideRow(f, 0, 0, frameW() - 16, "max fps", 30, 999, CFG.FpsVal, function(v) FPS.applyVal(v) end, "FpsVal", " fps")
        local tb = G.new("TextBox", f)
        tb.Position = G.UD2(0, 12, 0, 34); tb.Size = G.UD2(1, -24, 0, 16)
        tb.BackgroundColor3 = P.base; tb.BorderSizePixel = 0
        tb.Font = Enum.Font.Code; tb.TextSize = 12; tb.TextColor3 = P.tx
        tb.Text = tostring(CFG.FpsVal); tb.PlaceholderText = "custom fps number"; tb.PlaceholderColor3 = P.mt
        tb.TextXAlignment = Enum.TextXAlignment.Left; tb.ClearTextOnFocus = false
        G.mkC(tb, 3); G.mkS(tb, P.brd, 1, 0)
        local pd = G.new("UIPadding", tb); pd.PaddingLeft = G.UD(0, 8)
        tb.FocusLost:Connect(function()
            local n = tonumber(tb.Text)
            if n and n > 0 then FPS.applyVal(n); tb.Text = tostring(CFG.FpsVal) end
        end)
    end
    do
        local g = group("util", "miscellaneous")
        feat(g, "kbHud", "Keybinds HUD", "on-screen binds", FLIP.kbHud)
        meta("kbHud", "util", "utility", "keybinds hud", "binds")
        feat(g, "showChat", "Show chat", "chat window", FLIP.chat)
        meta("showChat", "util", "utility", "show chat", "chat window")
    end
    do
        local g = group("util", "macros")
        for i = 1, 3 do
            local nm = "M" .. i
            local kk = "m" .. i
            local f = block(g, 34)
            local lab = G.mkL(f, nm, 12, 0, 24, 34, 12, Enum.Font.Code, Enum.TextXAlignment.Left, P.mt)
            local tb = G.new("TextBox", f)
            tb.Position = G.UD2(0, 40, 0, 7); tb.Size = G.UD2(1, -110, 0, 20)
            tb.BackgroundColor3 = P.base; tb.BorderSizePixel = 0
            tb.Font = Enum.Font.Code; tb.TextSize = 12; tb.TextColor3 = P.tx
            tb.Text = CFG[nm]; tb.PlaceholderText = "Q, M2"; tb.PlaceholderColor3 = P.mt
            tb.TextXAlignment = Enum.TextXAlignment.Left; tb.ClearTextOnFocus = false
            G.mkC(tb, 3); G.mkS(tb, P.brd, 1, 0)
            local pd = G.new("UIPadding", tb); pd.PaddingLeft = G.UD(0, 8)
            tb.FocusLost:Connect(function() CFG[nm] = tb.Text end)
            UI._macroBox = UI._macroBox or {}
            UI._macroBox[i] = tb
            local chip = G.new("TextButton", f)
            chip.Position = G.UD2(1, -40, 0.5, -8); chip.Size = G.UD2(0, 28, 0, 16)
            chip.BackgroundTransparency = 1; chip.BorderSizePixel = 0; chip.AutoButtonColor = false
            chip.Font = Enum.Font.Code; chip.TextSize = 12; chip.TextColor3 = P.amb
            chip.Text = G.kName(kb[kk])
            G.mkC(chip, 3); G.mkS(chip, P.brd, 1, 0)
            kbL[kk] = chip
            chip.MouseButton1Click:Connect(function() G.startL(kk) end)
            meta(kk, "util", "utility", "macro " .. nm, "sequence")
        end
    end
    do
        local g = group("setup", "configs")
        local fDrop = block(g, 34)
        local cfgDrop = UI.dropBlock(fDrop, 0, 0, 0, "select config", G.cfgList() or {}, nil, function(nm)
            if UI._cfgInput then UI._cfgInput.Text = nm end
        end)
        UI.cfgDrop = cfgDrop
        meta("cfgSelect", "setup", "settings", "select config", "config")
        meta("cfgRefresh", "setup", "settings", "refresh list", "config")
        local refreshBtn = G.new("TextButton", fDrop)
        refreshBtn.Position = G.UD2(0, 12, 0, 42); refreshBtn.Size = G.UD2(0, 140, 0, 18)
        refreshBtn.BackgroundColor3 = G.RGB(26, 28, 36); refreshBtn.BorderSizePixel = 0; refreshBtn.AutoButtonColor = false
        refreshBtn.Font = Enum.Font.GothamBold; refreshBtn.TextSize = 14; refreshBtn.TextColor3 = P.tx; refreshBtn.Text = "refresh list"
        G.mkC(refreshBtn, 3); G.mkS(refreshBtn, P.brd, 1, 0)
        refreshBtn.MouseButton1Click:Connect(function()
            cfgDrop.fill(G.cfgList() or {}, nil)
        end)
        local f = block(g, 88)
        local name = G.new("TextBox", f)
        name.Position = G.UD2(0, 12, 0, 4); name.Size = G.UD2(1, -24, 0, 22)
        name.BackgroundColor3 = P.base; name.BorderSizePixel = 0
        name.Font = Enum.Font.GothamMedium; name.TextSize = 12; name.TextColor3 = P.tx
        name.PlaceholderText = "config name"; name.PlaceholderColor3 = P.mt
        name.Text = ""; name.TextXAlignment = Enum.TextXAlignment.Left; name.ClearTextOnFocus = false
        G.mkC(name, 3); G.mkS(name, P.brd, 1, 0)
        local pd = G.new("UIPadding", name); pd.PaddingLeft = G.UD(0, 8)
        UI._cfgInput = name
        UI.actBtn(f, 12, 32, 0, 20, "save new", false, function()
            local nm = string.match(name.Text, "^%s*(.-)%s*$")
            if nm == "" then NOTIF.send("Archive", "name the config first"); return end
            local exists = table.find(G.cfgList() or {}, nm) ~= nil
            if exists then
                UI.confirm("OVERWRITE CONFIG", "A config named " .. nm .. " already exists. Overwrite?", function()
                    G.saveConfig(nm)
                    NOTIF.send("Archive", "overwrote " .. nm)
                    cfgDrop.fill(G.cfgList() or {}, nil)
                end)
            else
                G.saveConfig(nm)
                NOTIF.send("Archive", "saved " .. nm)
                cfgDrop.fill(G.cfgList() or {}, nil)
            end
        end)
        do
            local sb = f:GetChildren()[#f:GetChildren()]
            sb.Position = G.UD2(0, 12, 0, 32); sb.Size = G.UD2(0.5, -18, 0, 20)
        end
        UI.actBtn(f, 0, 32, 0, 20, "load", false, function()
            local nm = string.match(name.Text, "^%s*(.-)%s*$")
            if nm == "" then NOTIF.send("Archive", "select a config first"); return end
            if G.loadConfig(nm) then UI.applyLoaded(); NOTIF.send("Archive", "loaded " .. nm)
            else NOTIF.send("Archive", "not found: " .. nm) end
        end)
        do
            local lb = f:GetChildren()[#f:GetChildren()]
            lb.Position = G.UD2(0.5, 6, 0, 32); lb.Size = G.UD2(0.5, -18, 0, 20)
        end
        UI.actBtn(f, 12, 60, 0, 20, "delete", true, function()
            local nm = string.match(name.Text, "^%s*(.-)%s*$")
            if nm == "" then return end
            G.deleteConfig(nm); NOTIF.send("Archive", "deleted " .. nm)
            cfgDrop.fill(G.cfgList() or {}, nil); name.Text = ""
        end)
        meta("cfgSave", "setup", "settings", "save new", "config")
        meta("cfgLoad", "setup", "settings", "load", "config")
        meta("cfgDelete", "setup", "settings", "delete", "config")
    end
    do
        local g = group("setup", "quick load")
        local fDrop = block(g, 34)
        local qlDrop = UI.dropBlock(fDrop, 0, 0, 0, "quick load config", function() return G.cfgList() or {} end, function() return CFG.QuickLoad ~= "" and CFG.QuickLoad or nil end, function(nm)
            CFG.QuickLoad = nm
            if G.saveQuickLoad then pcall(function() G.saveQuickLoad(nm) end) end
            if UI._qlLabel then pcall(function() UI._qlLabel.Text = "quick load: " .. (CFG.QuickLoad ~= "" and CFG.QuickLoad or "none") end) end
            NOTIF.send("Archive", "quick load set to " .. nm)
        end)
        UI.qlDrop = qlDrop
    end
    do
        local g = group("setup", "menu")
        local f = block(g, 61)
        G.mkL(f, "menu key", 12, 9, 120, 16, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
        local chip = G.new("TextButton", f)
        chip.Position = G.UD2(1, -40, 0, 9); chip.Size = G.UD2(0, 28, 0, 16)
        chip.BackgroundTransparency = 1; chip.BorderSizePixel = 0; chip.AutoButtonColor = false
        chip.Font = Enum.Font.Code; chip.TextSize = 12; chip.TextColor3 = P.amb
        chip.Text = G.kName(kb.menuKey); chip.TextXAlignment = Enum.TextXAlignment.Center
        G.mkC(chip, 3); G.mkS(chip, P.brd, 1, 0)
        kbL.menuKey = chip
        chip.MouseButton1Click:Connect(function() G.startL("menuKey") end)
        meta("menuKey", "setup", "settings", "menu key", "keybind")
        UI.actBtn(f, 12, 37, 0, 20, "unload script", true, function()
            UI.confirm("UNLOAD ARCHIVE", "This removes the menu and stops all features. Continue?", function()
                unloadAll()
            end)
        end)
        meta("unload", "setup", "settings", "unload script", "unload")
    end

    
    
    UI._searchHi = nil
    UI._searchDrop = nil
    local function clearSearch()
        if UI._searchTween then pcall(function() UI._searchTween:Cancel() end); UI._searchTween = nil end
        if UI._searchHi then pcall(function() UI._searchHi:Destroy() end); UI._searchHi = nil end
        if UI._searchDrop then pcall(function() UI._searchDrop:Destroy() end); UI._searchDrop = nil end
        for _, api in pairs(UI.rows or {}) do
            pcall(function()
                if api.root then
                    local hb = api.root:FindFirstChild("HB")
                    if hb then
                        local hbi = hb:FindFirstChild("HBI")
                        if hbi then hbi.BackgroundTransparency = 1; hbi.BackgroundColor3 = P.hover end
                    end
                end
            end)
        end
    end
    local function jumpTo(key)
        local m = UI._meta and UI._meta[key]
        if not m then return end
        cur = m.sec
        UI._curTab = m.sec
        for _, t2 in ipairs(TABS) do
            local on = t2.id == cur
            if secs[t2.id] then secs[t2.id].Visible = on end
            tabBtns[t2.id].TextColor3 = on and P.tx or P.mt
            local u2 = tabUls[t2.id]
            u2.Visible = true
            u2.BackgroundTransparency = on and 0 or 1
        end
        local sc = secs[m.sec]
        local api = UI.rows and UI.rows[key]
        if not sc then return end
        if m.sub and UI._esShow then UI._esShow(m.sub) end
        if not (api and api.root) then return end
        G.ts(function()
            G.tw(0.05)
            local r = api.root
            pcall(function()
                local target = sc.CanvasPosition.Y + (r.AbsolutePosition.Y - sc.AbsolutePosition.Y) - 12
                sc.CanvasPosition = Vector2.new(0, math.max(0, target))
            end)
            local hb = r:FindFirstChild("HB")
            local hbi = hb and hb:FindFirstChild("HBI")
            if hbi then
                if UI._searchTween then pcall(function() UI._searchTween:Cancel() end); UI._searchTween = nil end
                hbi.BackgroundTransparency = 0
                hbi.BackgroundColor3 = P.amb
                UI._searchTween = G.TS:Create(hbi, G.TI(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                UI._searchTween:Play()
                G.ts(function()
                    G.tw(0.55)
                    pcall(function() if hbi and hbi.Parent then hbi.BackgroundTransparency = 1; hbi.BackgroundColor3 = P.hover end end)
                    UI._searchTween = nil
                end)
            end
        end)
    end
    UI._searchDeb = 0
    sbox:GetPropertyChangedSignal("Text"):Connect(function()
        local now = G.ck()
        if now - (UI._searchDeb or 0) < 0.15 then return end
        UI._searchDeb = now
        local q = string.lower(string.match(sbox.Text or "", "^%s*(.-)%s*$"))
        clearSearch()
        if q == "" then return end
        
        local hits = {}
        for key, m in pairs(UI._meta or {}) do
            local nm = string.lower(m.label or "")
            if string.find(nm, q, 1, true) then G.ti(hits, {key = key, m = m}) end
        end
        
        for key, api in pairs(UI.rows or {}) do
            local keep = false
            for _, h in ipairs(hits) do if h.key == key then keep = true; break end end
            pcall(function()
                if api.root then
                    local hb = api.root:FindFirstChild("HB")
                    if hb then
                        local hbi = hb:FindFirstChild("HBI")
                        if hbi then
                            hbi.BackgroundTransparency = keep and 1 or 0.65
                            if not keep then hbi.BackgroundColor3 = P.panel end
                        end
                    end
                end
            end)
        end
        if #hits == 0 then
            local dd = G.new("Frame", UI.mFrame)
            dd.Position = G.UD2(0, 12, 0, 74); dd.Size = G.UD2(1, -24, 0, 24)
            dd.BackgroundColor3 = P.panel; dd.BorderSizePixel = 0
            G.mkC(dd, 3); G.mkS(dd, P.brd, 1, 0)
            G.mkL(dd, "no features match \"" .. q .. "\"", 10, 0, frameW() - 44, 24, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)
            UI._searchDrop = dd
            return
        end
        if #hits == 1 then jumpTo(hits[1].key); return end
        
        local dd = G.new("ScrollingFrame", UI.mFrame)
        dd.Position = G.UD2(0, 12, 0, 74); dd.Size = G.UD2(1, -24, 0, math.min(#hits * 22, 110))
        dd.BackgroundColor3 = P.panel; dd.BorderSizePixel = 0
        dd.ScrollBarThickness = 2; dd.ScrollBarImageColor3 = P.brd
        dd.CanvasSize = G.UD2(0, 0, 0, #hits * 22)
        G.mkC(dd, 3); G.mkS(dd, P.brd, 1, 0)
        UI._searchDrop = dd
        for i, h in ipairs(hits) do
            local b = G.new("TextButton", dd)
            b.Size = G.UD2(1, 0, 0, 22); b.Position = G.UD2(0, 0, 0, (i - 1) * 22)
            b.BackgroundTransparency = 1; b.BorderSizePixel = 0; b.AutoButtonColor = false
            b.Font = Enum.Font.GothamMedium; b.TextSize = 12; b.TextColor3 = P.tx
            b.Text = "  " .. h.m.label .. "  ·  " .. h.m.tab .. (h.m.sub and (" · " .. h.m.sub) or "")
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.MouseButton1Click:Connect(function()
                sbox.Text = h.m.label
                pcall(function() dd:Destroy() end)
                if UI._searchDrop == dd then UI._searchDrop = nil end
                jumpTo(h.key)
            end)
        end
    end)
    sbox.FocusLost:Connect(function(enter)
        if not enter then
            G.ts(function()
                G.tw(0.25)
                if UI._searchDrop and UI._searchDrop.Parent then
                    pcall(function() UI._searchDrop:Destroy() end)
                    UI._searchDrop = nil
                end
            end)
        end
    end)

    function UI.liveUpd()
        if not UI._liveL or not UI._liveL.Parent then return end
        local pg = G.LP and G.LP:FindFirstChild("PlayerGui")
        local bg = pg and pg:FindFirstChild("BackpackGui")
        local rf = bg and bg:FindFirstChild("RightFrame")
        local jf = rf and rf:FindFirstChild("JournalFrame")
        local pn = jf and jf:FindFirstChild("Panels")
        local stats = pn and pn:FindFirstChild("StatsFrame")
        if not stats then return end
        local function clean(s) return tostring(s or "--"):gsub("<[^>]+>", "") end
        local st = stats:FindFirstChild("StatSheet", true)
        local box = st and st:FindFirstChild("Stats", true)
        if box then
            for _, r in ipairs(box:GetChildren()) do
                if r:IsA("Frame") then
                    local tile = UI._liveTiles and UI._liveTiles[r.Name]
                    if tile then
                        local ic = r:FindFirstChild("Icon")
                        local v = r:FindFirstChild("Value")
                        if ic and ic.Image ~= "" then
                            tile.im.Image = ic.Image
                            pcall(function()
                                tile.im.ImageRectOffset = ic.ImageRectOffset
                                tile.im.ImageRectSize = ic.ImageRectSize
                            end)
                        end
                        if v then tile.vv.Text = clean(v.Text) end
                    end
                end
            end
        end
        local rs = stats:FindFirstChild("ResistSheet", true)
        local rbox = rs and rs:FindFirstChild("Container", true)
        local host = UI._liveR
        if rbox and host then
            local seen = {}
            for _, r in ipairs(rbox:GetChildren()) do
                if r:IsA("Frame") and r.Name ~= "Divider" then
                    local key = r:GetAttribute("Tip_Title") or r.Name
                    local ic = r:FindFirstChild("Icon", true)
                    local v = r:FindFirstChild("Value", true) or r:FindFirstChildOfClass("TextLabel")
                    if ic and v and ic.Image ~= "" then
                        seen[key] = true
                        local tile = UI._liveRes[key]
                        if not tile or not tile.f.Parent then
                            local n = 0
                            for _, t2 in pairs(UI._liveRes) do if t2.f.Parent then n = n + 1 end end
                            local col, row = n % 3, math.floor(n / 3)
                            local t = G.new("Frame", host)
                            t.Position = G.UD2(col * 0.333, col == 0 and 0 or 3, 0, row * 36)
                            t.Size = G.UD2(0.333, -4, 0, 30)
                            t.BackgroundColor3 = G.RGB(26, 28, 36); t.BorderSizePixel = 0
                            G.mkC(t, 4); G.mkS(t, P.brd, 1, 0)
                            local im = G.new("ImageLabel", t)
                            im.Position = G.UD2(0, 4, 0.5, -6); im.Size = G.UD2(0, 12, 0, 12)
                            im.BackgroundTransparency = 1
                            local vv = G.mkL(t, "", 20, 0, 60, 30, 12, Enum.Font.Code, Enum.TextXAlignment.Left, P.tx)
                            vv.Size = G.UD2(1, -24, 1, 0)
                            tile = {f = t, im = im, vv = vv}
                            UI._liveRes[key] = tile
                        end
                        tile.im.Image = ic.Image
                        pcall(function()
                            tile.im.ImageRectOffset = ic.ImageRectOffset
                            tile.im.ImageRectSize = ic.ImageRectSize
                        end)
                        tile.vv.Text = clean(v.Text)
                    end
                end
            end
            local maxY = 0
            for _, t2 in pairs(UI._liveRes) do
                if t2.f.Parent then
                    maxY = math.max(maxY, t2.f.Position.Y.Offset + t2.f.Size.Y.Offset)
                end
            end
            host.CanvasSize = G.UD2(0, 0, 0, maxY + 8)
        end
    end
    function UI.refreshRows()
        if not UI.rows then return end
        pcall(UI.liveUpd)
        pcall(function()
            local c = 0; for _, d in pairs(UI.espF) do if d.Ct.Visible then c = c + 1 end end
            if UI.rows.esp then UI.rows.esp.sub("tracking [" .. c .. "]" .. (S.espGlobal and " · global" or "")) end
        end)
        pcall(function()
            local c = 0; for _ in pairs(MESP.espF) do c = c + 1 end
            if UI.rows.mobEsp then UI.rows.mobEsp.sub("tracking [" .. c .. "]" .. (S.espGlobal and " · global" or "")) end
        end)
        pcall(function()
            local c = 0; for _ in pairs(NESP.espF) do c = c + 1 end
            if UI.rows.nEsp then UI.rows.nEsp.sub("tracking [" .. c .. "]" .. (S.espGlobal and " · global" or "")) end
        end)
        pcall(function()
            local c = 0; for _ in pairs(CESP.espF) do c = c + 1 end
            if UI.rows.cEsp then UI.rows.cEsp.sub("tracking [" .. c .. "]" .. (S.espGlobal and " · global" or "")) end
        end)
        pcall(function()
            if UI.rows.autoBuild then UI.rows.autoBuild.sub(BUILDER.status()) end
            if UI.rows.autoPoints then UI.rows.autoPoints.sub(BUILDER.shrined and "post-shrine" or "pre-shrine") end
        end)
        pcall(function() if UI.rows.gourd then UI.rows.gourd.sub(GOURD.status()) end end)
    end

    
    
    function UI.applyLoaded()
        for _, api in pairs(UI.rows) do if api.chip then pcall(api.chip) end end
        
        pcall(function()
            local sl = UI._sliders or {}
            if sl.EspRange then sl.EspRange(CFG.EspRange) end
            if sl.EspFps then sl.EspFps(CFG.EspFps or 60) end
            if sl.PlrEspRange then sl.PlrEspRange(CFG.PlrEspRange or 4000) end
            if sl.PlrEspFps then sl.PlrEspFps(CFG.PlrEspFps or 60) end
            if sl.MobEspRange then sl.MobEspRange(CFG.MobEspRange or 4000) end
            if sl.MobEspFps then sl.MobEspFps(CFG.MobEspFps or 60) end
            if sl.NpcEspRange then sl.NpcEspRange(CFG.NpcEspRange or 4000) end
            if sl.NpcEspFps then sl.NpcEspFps(CFG.NpcEspFps or 60) end
            if sl.ChestEspRange then sl.ChestEspRange(CFG.ChestEspRange or 4000) end
            if sl.ChestEspFps then sl.ChestEspFps(CFG.ChestEspFps or 60) end
            if sl.AgilVal then sl.AgilVal(CFG.AgilVal) end
            if sl.SpdVal then sl.SpdVal(CFG.SpdVal) end
            if sl.FlySpeed then sl.FlySpeed(CFG.FlySpeed or 80) end
            if sl.ASpdVal then sl.ASpdVal(CFG.ASpdVal) end
            if sl.MSpdVal then sl.MSpdVal(CFG.MSpdVal) end
            if sl.FpsVal then sl.FpsVal(CFG.FpsVal) end
            if sl.BrightVal then sl.BrightVal(CFG.BrightVal or 3) end
        end)
        
        pcall(function()
            for i = 1, 3 do
                local box = UI._macroBox and UI._macroBox[i]
                if box and box.Parent then box.Text = CFG["M" .. i] or "" end
            end
            if UI._autoUrlBox and UI._autoUrlBox.Parent then UI._autoUrlBox.Text = CFG.AutoBuildUrl or "" end
            if UI._qlLabel and UI._qlLabel.Parent then UI._qlLabel.Text = "quick load: " .. (CFG.QuickLoad ~= "" and CFG.QuickLoad or "none") end
        end)
        local stopper = {
            pktPlk = function() pcall(PACKET_PLK.stp, PACKET_PLK) end,
            esp = function() pcall(ESP.stop) end,
            mobEsp = function() pcall(MESP.stop) end,
            nEsp = function() pcall(NESP.stop) end,
            cEsp = function() pcall(CESP.stop) end,
            autoloot = function() pcall(AUTOLOOT.stop) end,
            spec = function() pcall(function() S.spec = false; if SPEC.gui and SPEC.gui.Parent then SPEC.tog() end end) end,
            agil = function() pcall(AGIL.dis) end,
            agSpd = function() end,
            nc = function() pcall(NC.dis) end,
            nfd = function() pcall(NFD.dis) end,
            fly = function() pcall(function() if FLY.active then FLY.dis() end end) end,
            aSpd = function() pcall(ASPD.dis) end,
            opt = function() pcall(OPTIMIZE.dis) end,
            fps = function() if S.fps then pcall(FPS.dis) end end,
            nkb = function() pcall(NKB.dis) end,
            noVis = function() pcall(NOVIS.dis) end,
            npcFreeze = function() pcall(NPC_FREEZER.stop) end,
            modDetector = function() pcall(MODD.stop) end,
            humanoidPathfindBreaker = function() pcall(PATHBREAK.stop) end,
            attachToBack = function() pcall(BACK.stop) end,
            effDisable = function() pcall(EFFECTS.dis) end,
            sanityHud = function() pcall(SANITY.dis) end,
            bright = function() pcall(function() if BRIGHT.active then BRIGHT.dis() end end) end,
            kbHud = function() pcall(KBHUD.dis) end,
            showChat = function() pcall(CHATSHOW.dis) end,
            autoBuild = function() pcall(function() if BUILDER.running then BUILDER.stop() end end) end,
            autoPoints = function() pcall(function() if BUILDER.points then BUILDER.stopPts() end end) end,
            gourd = function() pcall(function() GOURD.stop(true) end) end,
        }
        local changed = G._changedToggles or {}
        local hasChanged = false
        for _ in pairs(changed) do hasChanged = true; break end
        if hasChanged then
            for k, fn in pairs(stopper) do
                if changed[k] then pcall(fn) end
            end
        end
        local order = {"pktPlk", "esp", "mobEsp", "nEsp", "cEsp", "autoloot", "spec", "agil", "agSpd", "nc", "nfd", "fly", "aSpd", "opt", "fps", "nkb", "noVis", "npcFreeze", "modDetector", "humanoidPathfindBreaker", "attachToBack", "effDisable", "sanityHud", "bright", "kbHud", "showChat", "autoBuild", "autoPoints", "gourd"}
        local starter = {
            pktPlk = function() PACKET_PLK:start() end,
            esp = function() ESP.start() end,
            mobEsp = function() MESP.start() end,
            nEsp = function() NESP.start() end,
            cEsp = function() CESP.start() end,
            autoloot = function() AUTOLOOT.start() end,
            spec = function() if not S.spec then S.spec = true end; SPEC.tog() end,
            agil = function() AGIL.en() end, agSpd = function() AGIL.en() end,
            nc = function() NC.en() end, nfd = function() NFD.en() end,
            fly = function() FLY.en() end, aSpd = function() ASPD.en() end,
            opt = function() OPTIMIZE.en() end,
            fps = function() S.fps = true; FPS.en(true) end,
            nkb = function() NKB.en() end,
            noVis = function() NOVIS.en() end,
            npcFreeze = function() NPC_FREEZER.start() end,
            modDetector = function() MODD.start() end,
            humanoidPathfindBreaker = function() PATHBREAK.start() end,
            attachToBack = function() BACK.start() end,
            effDisable = function() EFFECTS.en() end,
            sanityHud = function() SANITY.en() end,
            bright = function() BRIGHT.en() end,
            kbHud = function() KBHUD.en() end,
            showChat = function() CHATSHOW.en() end,
            autoBuild = function() BUILDER.start() end,
            autoPoints = function() BUILDER.startPts() end,
            gourd = function() if not GOURD.start() then S.gourd = false end end,
        }
        for _, k in ipairs(order) do
            if S[k] == true and starter[k] then
                if (not hasChanged) or changed[k] then pcall(starter[k]) end
            end
        end
        UI.updTog()
    end

    local foot = G.new("Frame", UI.mFrame)
    foot.Position = G.UD2(0, 0, 1, -28); foot.Size = G.UD2(1, 0, 0, 28)
    foot.BackgroundTransparency = 1; foot.BorderSizePixel = 0
    UI._foot = foot
    UI.divider(foot, 0, frameW())
    G.mkL(foot, "archive", 16, 6, 200, 16, 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, P.mt)

    
    do
        local dh = G.new("Frame", UI.mFrame)
        dh.BackgroundTransparency = 1; dh.BorderSizePixel = 0
        dh.Position = G.UD2(0, 0, 0, 0); dh.Size = G.UD2(1, 0, 0, 40)
        local dg, ds, fp = false, nil, nil
        dh.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dg, ds, fp = true, i.Position, UI.mFrame.Position
            end
        end)
        trk(G.UIS.InputChanged:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - ds
                local cam = G.WS.CurrentCamera
                local vw = cam and cam.ViewportSize.X or 1920
                local vh = cam and cam.ViewportSize.Y or 900
                local nx = G.mc(fp.X.Offset + d.X, -vw * 0.5, vw * 0.5)
                local ny = G.mc(fp.Y.Offset + d.Y, -vh * 0.5, vh * 0.5)
                UI.mFrame.Position = G.UD2(fp.X.Scale, math.floor(nx), fp.Y.Scale, math.floor(ny))
            end
        end))
        trk(G.UIS.InputEnded:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                dg = false
            end
        end))
    end
    do
        local function grip(side)
            local rh = G.new("TextButton", UI.mFrame)
            rh.Size = G.UD2(0, 18, 0, 18)
            if side < 0 then rh.Position = G.UD2(0, 0, 1, -18) else rh.Position = G.UD2(1, -18, 1, -18) end
            rh.BackgroundTransparency = 1; rh.BorderSizePixel = 0
            rh.Text = ""; rh.AutoButtonColor = false
            local dot = G.new("Frame", rh)
            dot.Size = G.UD2(0, 8, 0, 8)
            if side < 0 then dot.Position = G.UD2(0, 2, 1, -10) else dot.Position = G.UD2(1, -10, 1, -10) end
            dot.BackgroundColor3 = P.brd; dot.BorderSizePixel = 0; dot.Rotation = 45
            rh.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    UI._drag = {
                        rw = UI._W or W,
                        rhh = UI._H or H,
                        sx = i.Position.X,
                        sy = i.Position.Y,
                        side = side,
                    }
                end
            end)
        end
        grip(-1); grip(1)
    end
    cur = UI._curTab or "combat"; paintTabs()
    reflow()

    UI.bindInp()
    UI.applyV(); UI.updTog()
    pcall(UI.applyLoaded)
    if UI.dynConn then UI.dynConn:Disconnect() end
    UI.dynConn = G.RS.Heartbeat:Connect(function()
        local now = G.ck()
        UI._lastDyn = UI._lastDyn or 0
        if now - UI._lastDyn < 0.5 then return end
        UI._lastDyn = now
        pcall(UI.refreshRows)
    end)
    if not UI._rc1 then
        UI._rc1 = G.UIS.InputChanged:Connect(function(ch)
            local d = UI._drag
            if not d then return end
            if ch.UserInputType ~= Enum.UserInputType.MouseMovement and ch.UserInputType ~= Enum.UserInputType.Touch then return end
            local cam = G.WS.CurrentCamera
            local vw = cam and cam.ViewportSize.X or 1920
            local vh = cam and cam.ViewportSize.Y or 900
            local dx = (ch.Position.X - d.sx) * d.side
            local dy = ch.Position.Y - d.sy
            UI._W = math.floor(G.mc(d.rw + dx, 480, math.min(1200, vw - 60)))
            UI._H = math.floor(G.mc(d.rhh + dy, 300, math.min(900, vh - 60)))
            CFG.MenuWidth = UI._W
            CFG.MenuHeight = UI._H
            if UI.mFrame then UI.mFrame.Size = G.UD2(0, UI._W, 0, UI._H) end
            if UI._body then UI._body.Size = G.UD2(1, 0, 0, UI._H - UI._bodyY - UI._footH) end
            pcall(function() if UI._layoutTabs then UI._layoutTabs() end end)
        end)
    end
    if not UI._rc2 then
        UI._rc2 = G.UIS.InputEnded:Connect(function(ch)
            if ch.UserInputType ~= Enum.UserInputType.MouseButton1 and ch.UserInputType ~= Enum.UserInputType.Touch then return end
            if not UI._drag then return end
            UI._drag = nil
            CFG.MenuWidth = UI._W
            CFG.MenuHeight = UI._H
        end)
    end
    return true
end

pcall(FPS.captureOrig)
local ok, err = pcall(function()
    playIntro(function()
        createMenu()
        PC.init()
        NOTIF.send("Archive", "Loaded · Press P")
    end)
end)
if not ok then warn("[Archive] " .. tostring(err)) end
shared.ArchiveCleanup = function()
    pcall(destroyOld)
    pcall(function() if FLY then FLY.dis() end end)
end
-- build 1.0.49
