local success,err = pcall(function()
getgenv().deletewhendupefound = true
getgenv().deletewhendupefound = true
localplr = game.Players.LocalPlayer
http = game:GetService("HttpService")
do
	local HttpService = game:GetService("HttpService")
	local CFG_FILE = "guyhub_tco_config.json"
	local function canFS()
		return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
	end
	local function defaultCfg()
		return {
			skipIntro = false,
			loadMain = true,
			loadCmds = false,
			reloadOnExecute = false,
			activeConfig = "default",
			configs = {
				default = {
					skipIntro = false,
					loadMain = true,
					loadCmds = false,
				}
			},
			joinHi = false,
			joinHiMsg = "hi {name} welcome",
			joinFling = false,
			joinCmd = false,
			joinCmdMsg = "freeze {name}",
			theme = "Dark",
		}
	end
	local function loadDisk()
		if not canFS() then return nil end
		local ok, data = pcall(function()
			if isfile(CFG_FILE) then
				return HttpService:JSONDecode(readfile(CFG_FILE))
			end
		end)
		if ok and type(data) == "table" then return data end
		return nil
	end
	local function saveDisk(data)
		if not canFS() then
			getgenv()._tcoCfgMem = data
			return false
		end
		pcall(function()
			writefile(CFG_FILE, HttpService:JSONEncode(data))
		end)
		getgenv()._tcoCfgMem = data
		return true
	end
	local data = loadDisk() or getgenv()._tcoCfgMem or defaultCfg()
	if not data.configs then data.configs = { default = {} } end
	getgenv()._tcoCfg = data
	local function applyRootFlags()
		local d = getgenv()._tcoCfg
		if d.reloadOnExecute and d.activeConfig and d.configs and d.configs[d.activeConfig] then
			local ac = d.configs[d.activeConfig]
			for k, v in pairs(ac) do d[k] = v end
		end
		getgenv()._tcoSkipIntro = d.skipIntro and true or false
		getgenv()._tcoLoadMain = d.loadMain ~= false
		getgenv()._tcoLoadCmds = d.loadCmds and true or false
		if d.theme and getgenv()._guyHubThemes and getgenv()._guyHubThemes[d.theme] then
			getgenv()._guyHubThemeName = d.theme
			getgenv()._guyHubTheme = getgenv()._guyHubThemes[d.theme]
		end
	end
	applyRootFlags()
	getgenv()._tcoSaveCfg = function()
		saveDisk(getgenv()._tcoCfg)
	end
	getgenv()._tcoApplyCfg = applyRootFlags
end
local TCO_CHANGELOG_VERSION = "2026-11-13-build-aura-gear-update-1"
do
	local cfg = getgenv()._tcoCfg or {}
	if cfg.changelogVersion ~= TCO_CHANGELOG_VERSION then
		cfg.changelogVersion = TCO_CHANGELOG_VERSION
		getgenv()._tcoCfg = cfg
		pcall(function() if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end end)
		task.defer(function()
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Guy Hub updated",
					Text = "Build saves, Delete Aura, rejoin, and gears were updated. See the new controls in Player Stuff and Gears.",
					Duration = 12
				})
			end)
		end)
	end
end
mult = 4
built = false
colorbool = false
stopped = false
skipblock = false
on = true
pcall(function()
	if typeof(getgenv()._tcoSetSpyChat) == "function" then getgenv()._tcoSetSpyChat(false) end
end)
spychat = false
isog = workspace:FindFirstChild("Cubes")
conn = {}
highlight = Instance.new("Highlight")
highlight.Parent = game.CoreGui
highlight.FillColor = Color3.fromRGB(255,255,255)
highlight.FillTransparency = .9
mouse = localplr:GetMouse()
getgenv()._tcoUseDisplayName = getgenv()._tcoUseDisplayName or false
function playerOptLabel(p)
	if not p then return "?" end
	if getgenv()._tcoUseDisplayName then return p.DisplayName end
	return p.Name
end
function resolvePlayerFromOpt(sel)
	if not sel or sel == "" or sel == "(none)" then return nil end
	if sel == "me" then return localplr end
	local pl = game.Players:FindFirstChild(sel)
	if pl then return pl end
	local low = tostring(sel):lower()
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Name:lower() == low or p.DisplayName:lower() == low then return p end
	end
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Name:lower():find(low, 1, true) or p.DisplayName:lower():find(low, 1, true) then return p end
	end
	return nil
end
function playerDropdownList(includeMe)
	local t = {}
	if includeMe then
		t[1] = "me"
		for _, p in pairs(game.Players:GetPlayers()) do
			if p ~= localplr then table.insert(t, playerOptLabel(p)) end
		end
	else
		t[1] = "(none)"
		for _, p in pairs(game.Players:GetPlayers()) do
			table.insert(t, playerOptLabel(p))
		end
	end
	return t
end
sbox = Instance.new("SelectionBox")
sbox.Color3 = Color3.fromRGB(0,170,255)
sbox.LineThickness = -1
sbox.SurfaceColor3 = Color3.fromRGB(13,105,172)
sbox.SurfaceTransparency = 1
sbox.Transparency = 0
sbox.Parent = game.CoreGui
bbsbox = Instance.new("SelectionBox")
bbsbox.Color3 = Color3.fromRGB(0,170,255)
bbsbox.LineThickness = -1
bbsbox.SurfaceColor3 = Color3.fromRGB(13,105,172)
bbsbox.SurfaceTransparency = 1
bbsbox.Transparency = 0
bbsbox.Parent = game.CoreGui
bannedsymbols = {}
bannedsymbols["\""] = "''"
bannedsymbols["*"] = "\u{2605}"
bannedsymbols[":"] = ";"
bannedsymbols["<"] = "\u{2264}"
bannedsymbols[">"] = "\u{2265}"
bannedsymbols["?"] = "\u{00BF}"
bannedsymbols["\\"] = ""
bannedsymbols["|"] = "I"
bannedsymbols["/"] = "\u{2215}"
function validate(name)
	for i,v in pairs(bannedsymbols) do
		name = name:gsub(i,v)
	end
	local s = string.find(name,"%.txt") or string.find(name,"%.json")
	if s then
		local addafter = string.sub(name,s)
		name = string.sub(name,1,s-1)
		name = name:gsub("%.","·")
		name = name..addafter
	else
		name = name:gsub("%.","·")
	end
	return name
end
lib = {}
do
	local CoreGui = game:GetService("CoreGui")
	local UIS = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local function themeCols()
		local t = getgenv()._guyHubTheme
		if t then return t end
		return {
			BG = Color3.fromRGB(25, 27, 32),
			BG2 = Color3.fromRGB(40, 42, 50),
			BG3 = Color3.fromRGB(48, 50, 58),
			STROKE = Color3.fromRGB(60, 60, 70),
			TEXT = Color3.fromRGB(230, 230, 235),
			SUB = Color3.fromRGB(140, 142, 150),
			ACCENT = Color3.fromRGB(70, 72, 82),
			BTN = Color3.fromRGB(48, 50, 58),
			TOGGLE_OFF = Color3.fromRGB(60, 62, 70),
			TOGGLE_ON = Color3.fromRGB(90, 95, 110),
		}
	end
	local TC = themeCols()
	local BG, BG2, BG3 = TC.BG, TC.BG2, TC.BG3
	local STROKE, TEXT, SUB = TC.STROKE, TC.TEXT, TC.SUB
	local ACCENT, BTN = TC.ACCENT, TC.BTN
	local TOGGLE_OFF, TOGGLE_ON = TC.TOGGLE_OFF, TC.TOGGLE_ON
	local sg, main, tabBar, content, titleLbl
	local tabs = {}
	local currentTab = nil
	local elements = {}
	local drag = {on=false, start=nil, pos=nil}
	local function corner(o, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r or 10)
		c.Parent = o
		return c
	end
	local function stroke(o, col, th)
		local s = Instance.new("UIStroke")
		s.Color = col or STROKE
		s.Thickness = th or 1.2
		s.Transparency = 0.35
		s.Parent = o
		return s
	end
	local function pad(o, t, b, l, r)
		local p = Instance.new("UIPadding")
		p.PaddingTop = UDim.new(0, t or 8)
		p.PaddingBottom = UDim.new(0, b or 8)
		p.PaddingLeft = UDim.new(0, l or 10)
		p.PaddingRight = UDim.new(0, r or 10)
		p.Parent = o
		return p
	end
	local CLICK_IDS = {6895079853, 421058925, 12222216, 15658610, 4612373902, 10066906500}
	local function playUiClick(vol)
		task.spawn(function()
			for _, id in ipairs(CLICK_IDS) do
				local ok = pcall(function()
					local s = Instance.new("Sound")
					s.Name = "GuyHubClick"
					s.SoundId = "rbxassetid://" .. tostring(id)
					s.Volume = vol or 0.7
					s.Looped = false
					s.PlayOnRemove = false
					pcall(function() s.Parent = game:GetService("SoundService") end)
					if not s.Parent then
						s.Parent = localplr:FindFirstChild("PlayerGui") or workspace
					end
					local t0 = tick()
					while not s.IsLoaded and tick() - t0 < 1.5 do
						task.wait(0.05)
					end
					s.TimePosition = 0
					s:Play()
					task.delay(2.5, function()
						pcall(function() s:Destroy() end)
					end)
				end)
				if ok then break end
			end
		end)
	end
	lib.playClick = playUiClick
	function lib.makelib(title)
		TC = themeCols()
		BG, BG2, BG3 = TC.BG, TC.BG2, TC.BG3
		STROKE, TEXT, SUB = TC.STROKE, TC.TEXT, TC.SUB
		ACCENT, BTN = TC.ACCENT, TC.BTN
		TOGGLE_OFF, TOGGLE_ON = TC.TOGGLE_OFF, TC.TOGGLE_ON
		pcall(function()
			local old = CoreGui:FindFirstChild("TCOSettingsUI")
			if old then old:Destroy() end
		end)
		sg = Instance.new("ScreenGui")
		sg.Name = "TCOSettingsUI"
		sg.ResetOnSpawn = false
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.DisplayOrder = 120
		pcall(function() sg.Parent = CoreGui end)
		if not sg.Parent then
			sg.Parent = localplr:WaitForChild("PlayerGui")
		end
		main = Instance.new("Frame")
		main.Name = "Main"
		main.Size = UDim2.new(0, 460, 0, 280)
		main.Position = UDim2.new(0.5, -230, 0.5, -140)
		main.BackgroundColor3 = BG
		main.BackgroundTransparency = 0.35
		main.BorderSizePixel = 0
		main.Active = true
		main.Parent = sg
		corner(main, 8)
		local top = Instance.new("Frame")
		top.Size = UDim2.new(1, 0, 0, 34)
		top.BackgroundColor3 = BG2
		top.BackgroundTransparency = 0.4
		top.BorderSizePixel = 0
		top.Parent = main
		corner(top, 8)
		local topFix = Instance.new("Frame")
		topFix.Size = UDim2.new(1, 0, 0, 16)
		topFix.Position = UDim2.new(0, 0, 1, -16)
		topFix.BackgroundColor3 = BG2
		topFix.BackgroundTransparency = 0.4
		topFix.BorderSizePixel = 0
		topFix.Parent = top
		titleLbl = Instance.new("TextLabel")
		titleLbl.BackgroundTransparency = 1
		titleLbl.Size = UDim2.new(1, -90, 1, 0)
		titleLbl.Position = UDim2.new(0, 14, 0, 0)
		titleLbl.Font = Enum.Font.GothamBold
		titleLbl.TextSize = 16
		titleLbl.TextColor3 = TEXT
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.Text = tostring(title or "TCO")
		titleLbl.Parent = top
		getgenv()._tcoMainTitleLabel = titleLbl
		local minBtn = Instance.new("TextButton")
		minBtn.Size = UDim2.new(0, 32, 0, 28)
		minBtn.Position = UDim2.new(1, -72, 0.5, -14)
		minBtn.BackgroundColor3 = BTN
		minBtn.Text = "-"
		minBtn.TextColor3 = TEXT
		minBtn.Font = Enum.Font.GothamBold
		minBtn.TextSize = 18
		minBtn.Parent = top
		corner(minBtn, 6)
		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 32, 0, 28)
		closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
		closeBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 50)
		closeBtn.Text = "X"
		closeBtn.TextColor3 = TEXT
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 14
		closeBtn.Parent = top
		corner(closeBtn, 6)
		tabBar = Instance.new("ScrollingFrame")
		tabBar.Name = "TabBar"
		tabBar.Size = UDim2.new(1, -16, 0, 28)
		tabBar.Position = UDim2.new(0, 8, 0, 38)
		tabBar.BackgroundTransparency = 1
		tabBar.BorderSizePixel = 0
		tabBar.ScrollBarThickness = 2
		tabBar.ScrollingDirection = Enum.ScrollingDirection.X
		tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabBar.Parent = main
		local tabList = Instance.new("UIListLayout")
		tabList.FillDirection = Enum.FillDirection.Horizontal
		tabList.SortOrder = Enum.SortOrder.LayoutOrder
		tabList.Padding = UDim.new(0, 5)
		tabList.Parent = tabBar
		content = Instance.new("Frame")
		content.Name = "Content"
		content.Size = UDim2.new(1, -16, 1, -72)
		content.Position = UDim2.new(0, 8, 0, 68)
		content.BackgroundTransparency = 1
		content.Parent = main
		top.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				drag.on = true
				drag.start = input.Position
				drag.pos = main.Position
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if drag.on and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - drag.start
				main.Position = UDim2.new(drag.pos.X.Scale, drag.pos.X.Offset + d.X, drag.pos.Y.Scale, drag.pos.Y.Offset + d.Y)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				drag.on = false
			end
		end)
		local function addCornerResize(frame, minW, minH)
			minW, minH = minW or 280, minH or 160
			local function makeHandle(name, anchor, pos)
				local h = Instance.new("TextButton")
				h.Name = name
				h.Size = UDim2.new(0, 18, 0, 18)
				h.AnchorPoint = anchor
				h.Position = pos
				h.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
				h.BackgroundTransparency = 0.3
				h.Text = ""
				h.ZIndex = 50
				h.Parent = frame
				Instance.new("UICorner", h).CornerRadius = UDim.new(1, 0)
				return h
			end
			local tl = makeHandle("ResizeTL", Vector2.new(0, 0), UDim2.new(0, 0, 0, 0))
			local br = makeHandle("ResizeBR", Vector2.new(1, 1), UDim2.new(1, 0, 1, 0))
			local resizing, mode, startIn, startSize, startPos
			local function begin(m, input)
				resizing = true
				mode = m
				startIn = input.Position
				startSize = frame.AbsoluteSize
				startPos = frame.AbsolutePosition
			end
			tl.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					begin("tl", input)
				end
			end)
			br.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					begin("br", input)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if not resizing then return end
				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
				local d = input.Position - startIn
				if mode == "br" then
					local nw = math.max(minW, startSize.X + d.X)
					local nh = math.max(minH, startSize.Y + d.Y)
					frame.Size = UDim2.new(0, nw, 0, nh)
				else
					local nw = math.max(minW, startSize.X - d.X)
					local nh = math.max(minH, startSize.Y - d.Y)
					local usedX = startSize.X - nw
					local usedY = startSize.Y - nh
					frame.Size = UDim2.new(0, nw, 0, nh)
					frame.Position = UDim2.new(0, startPos.X + usedX, 0, startPos.Y + usedY)
				end
			end)
			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					resizing = false
				end
			end)
		end
		addCornerResize(main, 300, 180)
		local miniSg = Instance.new("ScreenGui")
		miniSg.Name = "TCOMinimizeBtn_DISABLED"
		miniSg.ResetOnSpawn = false
		miniSg.DisplayOrder = 121
		miniSg.Enabled = false
		pcall(function() miniSg.Parent = CoreGui end)
		if not miniSg.Parent then miniSg.Parent = localplr:WaitForChild("PlayerGui") end
		local miniBtn = Instance.new("TextButton")
		miniBtn.Size = UDim2.new(0, 48, 0, 48)
		miniBtn.Position = UDim2.new(0, 16, 0.5, -26)
		miniBtn.BackgroundColor3 = BG2
		miniBtn.Text = "guy"
		miniBtn.TextColor3 = TEXT
		miniBtn.Font = Enum.Font.GothamBold
		miniBtn.TextSize = 12
		miniBtn.Parent = miniSg
		corner(miniBtn, 8)
		local function showMain(v)
			main.Visible = v
			miniSg.Enabled = not v
		end
		minBtn.MouseButton1Click:Connect(function() showMain(false) end)
		miniBtn.MouseButton1Click:Connect(function() showMain(true) end)
		closeBtn.MouseButton1Click:Connect(function()
			if lib.ondestroyedfunc then pcall(lib.ondestroyedfunc) end
			sg:Destroy()
			miniSg:Destroy()
		end)
		libgui = {
			Destroy = function()
				if lib.ondestroyedfunc then pcall(lib.ondestroyedfunc) end
				pcall(function() sg:Destroy() end)
				pcall(function() miniSg:Destroy() end)
			end
		}
		return libgui
	end
	local function switchTab(name)
		currentTab = name
		for n, t in pairs(tabs) do
			t.page.Visible = (n == name)
			if n == name then
				t.btn.BackgroundColor3 = Color3.fromRGB(55, 58, 68)
				t.btn.TextColor3 = TEXT
			else
				t.btn.BackgroundColor3 = BG3
				t.btn.TextColor3 = SUB
			end
		end
	end
	local TAB_ORDER = {
		["dashboard"] = 0,
		["build and load stuff"] = 1,
		["esp"] = 14,
		["build settings"] = 3,
		["tools"] = 4,
		["gears"] = 5,
		["spy chat"] = 6,
		["grief detection"] = 7,
		["commands"] = 8,
		["anti"] = 9,
		["jail"] = 10,
		["grief"] = 11,
		["player stuff"] = 12,
		["shaders"] = 13,
		["enlighten stuff"] = 15,
		["fling"] = 16,
		["animations"] = 98,
		["boombox ids"] = 17,
		["blame people lol"] = 18,
		["settings"] = 99,
	}
	function lib.maketab(name)
		name = tostring(name)
		local order = TAB_ORDER[name] or (100 + #tabs)
		local btn = Instance.new("TextButton")
		btn.LayoutOrder = order
		btn.Size = UDim2.new(0, math.clamp(#name * 7 + 18, 58, 140), 0, 26)
		btn.BackgroundColor3 = BG3
		btn.Text = name
		btn.TextColor3 = SUB
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 11
		btn.AutoButtonColor = true
		btn.Parent = tabBar
		corner(btn, 5)
		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.Visible = false
		page.Parent = content
		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 4)
		layout.Parent = page
		pad(page, 2, 8, 2, 4)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
		end)
		tabs[name] = {btn = btn, page = page, layout = layout, order = order}
		local tl = tabBar:FindFirstChildOfClass("UIListLayout")
		if tl then
			tl.SortOrder = Enum.SortOrder.LayoutOrder
			tabBar.CanvasSize = UDim2.new(0, tl.AbsoluteContentSize.X + 16, 0, 0)
		end
		btn.MouseButton1Click:Connect(function()
			playUiClick(0.45)
			switchTab(name)
		end)
		if name == "dashboard" or not currentTab then
			switchTab(name)
		end
		return name
	end
	local function rowFrame(parent)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -4, 0, 44)
		f.BackgroundColor3 = BG2
		f.BackgroundTransparency = 0.25
		f.BorderSizePixel = 0
		f.Parent = parent
		corner(f, 6)
		return f
	end
	function lib.getpage(tab)
		return tabs[tab] and tabs[tab].page
	end
	function lib.makelabel(text, tab)
		local page = tabs[tab] and tabs[tab].page
		if not page then return end
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -4, 0, 22)
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.GothamMedium
		l.TextSize = 13
		l.TextColor3 = SUB
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Text = tostring(text or "")
		l.Parent = page
		return l
	end
	function lib.makebutton(text, tab, cb)
		local page = tabs[tab] and tabs[tab].page
		if not page then return end
		local f = rowFrame(page)
		f.Size = UDim2.new(1, -4, 0, 44)
		local baseCol = f.BackgroundColor3
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 1, 0)
		b.BackgroundTransparency = 1
		b.Text = tostring(text or "Button")
		b.TextColor3 = TEXT
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 14
		b.Parent = f
		local held = false
		b.MouseButton1Down:Connect(function()
			held = true
			f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			f.BackgroundTransparency = 0.1
			b.TextColor3 = Color3.fromRGB(20, 20, 25)
		end)
		b.MouseButton1Up:Connect(function()
			held = false
			f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			f.BackgroundTransparency = 0.1
			b.TextColor3 = Color3.fromRGB(20, 20, 25)
			task.delay(0.12, function()
				if not held and f.Parent then
					f.BackgroundColor3 = baseCol
					f.BackgroundTransparency = 0.25
					b.TextColor3 = TEXT
				end
			end)
		end)
		b.MouseLeave:Connect(function()
			if held then
				held = false
				f.BackgroundColor3 = baseCol
				f.BackgroundTransparency = 0.25
				b.TextColor3 = TEXT
			end
		end)
		b.MouseButton1Click:Connect(function()
			playUiClick(0.7)
			if cb then pcall(cb) end
		end)
		return b
	end
	function lib.maketoggle(text, tab, cb, default)
		local page = tabs[tab] and tabs[tab].page
		if not page then return end
		local state = default and true or false
		local f = rowFrame(page)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, -70, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 14
		label.TextColor3 = TEXT
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = tostring(text or "Toggle")
		label.Parent = f
		local track = Instance.new("Frame")
		track.Size = UDim2.new(0, 46, 0, 26)
		track.Position = UDim2.new(1, -58, 0.5, -13)
		track.BackgroundColor3 = state and TOGGLE_ON or TOGGLE_OFF
		track.BorderSizePixel = 0
		track.Parent = f
		corner(track, 13)
		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 22, 0, 22)
		knob.Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
		knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
		knob.BorderSizePixel = 0
		knob.Parent = track
		corner(knob, 11)
		local hit = Instance.new("TextButton")
		hit.Size = UDim2.new(1, 0, 1, 0)
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.Parent = f
		hit.MouseButton1Down:Connect(function()
			f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			f.BackgroundTransparency = 0.1
		end)
		hit.MouseButton1Up:Connect(function()
			task.delay(0.1, function()
				if f.Parent then
					f.BackgroundColor3 = BG2
					f.BackgroundTransparency = 0.25
				end
			end)
		end)
		hit.MouseButton1Click:Connect(function()
			playUiClick(0.7)
			state = not state
			track.BackgroundColor3 = state and TOGGLE_ON or TOGGLE_OFF
			knob.Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
			if cb then pcall(cb, state) end
		end)
		return {set = function(v)
			state = not not v
			track.BackgroundColor3 = state and TOGGLE_ON or TOGGLE_OFF
			knob.Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
		end}
	end
	function lib.maketextbox(placeholder, tab, cb)
		local page = tabs[tab] and tabs[tab].page
		if not page then return end
		local f = rowFrame(page)
		f.Size = UDim2.new(1, -4, 0, 48)
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, -20, 1, -12)
		box.Position = UDim2.new(0, 10, 0, 6)
		box.BackgroundColor3 = BG3
		box.BorderSizePixel = 0
		box.Font = Enum.Font.Gotham
		box.TextSize = 14
		box.TextColor3 = TEXT
		box.PlaceholderColor3 = SUB
		box.PlaceholderText = tostring(placeholder or "")
		box.Text = ""
		box.ClearTextOnFocus = false
		box.Parent = f
		corner(box, 8)
		box.FocusLost:Connect(function(enter)
			if cb then pcall(cb, box.Text) end
		end)
		return box
	end
	function lib.makedropdown(text, tab, options, cb)
		local page = tabs[tab] and tabs[tab].page
		if not page then return end
		options = options or {"(none)"}
		local selected = options[1]
		local f = rowFrame(page)
		f.Size = UDim2.new(1, -4, 0, 52)
		f.ZIndex = 5
		local keylessBanner = Instance.new("TextLabel")
	keylessBanner.Size = UDim2.new(0.72, 0, 0, 28)
	keylessBanner.Position = UDim2.new(0.06, 0, 0.095, 0)
	keylessBanner.BackgroundTransparency = 1
	keylessBanner.Font = Enum.Font.GothamBold
	keylessBanner.TextSize = 15
	keylessBanner.TextColor3 = Color3.fromRGB(255, 214, 64)
	keylessBanner.TextStrokeColor3 = Color3.fromRGB(55, 42, 8)
	keylessBanner.TextStrokeTransparency = 0.35
	keylessBanner.TextXAlignment = Enum.TextXAlignment.Left
	keylessBanner.Text = "THIS SCRIPT IS KEYLESS!!"
	keylessBanner.ZIndex = 12
	keylessBanner.Parent = cover
	task.spawn(function()
		local t = 0
		while introSg.Parent and not introDone and keylessBanner.Parent do
			t = t + 0.08
			local pulse = (math.sin(t) + 1) * 0.5
			keylessBanner.TextTransparency = 0.04 + pulse * 0.24
			keylessBanner.TextStrokeTransparency = 0.18 + pulse * 0.32
			keylessBanner.Position = UDim2.new(0.06, 0, 0.095 + math.sin(t * 0.7) * 0.003, 0)
			task.wait(0.03)
		end
	end)
	local title = Instance.new("TextLabel")
		title.BackgroundTransparency = 1
		title.Size = UDim2.new(0.45, 0, 1, 0)
		title.Position = UDim2.new(0, 12, 0, 0)
		title.Font = Enum.Font.GothamMedium
		title.TextSize = 13
		title.TextColor3 = TEXT
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = tostring(text or "Select")
		title.Parent = f
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.5, -16, 0, 30)
		btn.Position = UDim2.new(0.5, 0, 0.5, -15)
		btn.BackgroundColor3 = BG3
		btn.Text = tostring(selected)
		btn.TextColor3 = TEXT
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 12
		btn.TextTruncate = Enum.TextTruncate.AtEnd
		btn.Parent = f
		corner(btn, 8)
		local open = false
		local listFrame = Instance.new("ScrollingFrame")
		listFrame.Size = UDim2.new(0.5, -16, 0, 0)
		listFrame.Position = UDim2.new(0.5, 0, 1, 2)
		listFrame.BackgroundColor3 = BG
		listFrame.BorderSizePixel = 0
		listFrame.Visible = false
		listFrame.ZIndex = 20
		listFrame.ScrollBarThickness = 3
		listFrame.Parent = f
		corner(listFrame, 6)
		local listLayout = Instance.new("UIListLayout")
		listLayout.Parent = listFrame
		local function rebuild(opts)
			options = opts or options
			for _, c in pairs(listFrame:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local ob = Instance.new("TextButton")
				ob.Size = UDim2.new(1, -4, 0, 28)
				ob.BackgroundColor3 = BG2
				ob.Text = tostring(opt)
				ob.TextColor3 = TEXT
				ob.Font = Enum.Font.Gotham
				ob.TextSize = 12
				ob.ZIndex = 21
				ob.Parent = listFrame
				corner(ob, 6)
				ob.MouseButton1Click:Connect(function()
					playUiClick(0.5)
					selected = opt
					btn.Text = tostring(opt)
					listFrame.Visible = false
					open = false
					f.Size = UDim2.new(1, -4, 0, 52)
					if cb then pcall(cb, selected) end
				end)
			end
			listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
			listFrame.Size = UDim2.new(0.5, -16, 0, math.min(140, #options * 30 + 4))
		end
		rebuild(options)
		btn.MouseButton1Click:Connect(function()
			playUiClick(0.5)
			open = not open
			listFrame.Visible = open
			if open then
				f.Size = UDim2.new(1, -4, 0, 52 + math.min(140, #options * 30 + 8))
			else
				f.Size = UDim2.new(1, -4, 0, 52)
			end
		end)
		local dd = {btn = btn, rebuild = rebuild, get = function() return selected end}
		return dd
	end
	function lib.updatedropdown(dd, options)
		if not dd then return end
		if type(dd) == "table" and dd.rebuild then
			dd.rebuild(options)
			if options and options[1] and dd.btn then
				dd.btn.Text = tostring(options[1])
			end
		end
	end
	lib.ondestroyedfunc = nil
end
getgenv()._guyHubThemes = {
	Dark = {
		BG = Color3.fromRGB(25, 27, 32), BG2 = Color3.fromRGB(40, 42, 50), BG3 = Color3.fromRGB(48, 50, 58),
		STROKE = Color3.fromRGB(60, 60, 70), TEXT = Color3.fromRGB(230, 230, 235), SUB = Color3.fromRGB(140, 142, 150),
		ACCENT = Color3.fromRGB(70, 72, 82), BTN = Color3.fromRGB(48, 50, 58),
		TOGGLE_OFF = Color3.fromRGB(60, 62, 70), TOGGLE_ON = Color3.fromRGB(90, 95, 110),
	},
	Blue = {
		BG = Color3.fromRGB(18, 24, 36), BG2 = Color3.fromRGB(28, 38, 55), BG3 = Color3.fromRGB(35, 48, 70),
		STROKE = Color3.fromRGB(50, 80, 120), TEXT = Color3.fromRGB(230, 235, 245), SUB = Color3.fromRGB(140, 160, 190),
		ACCENT = Color3.fromRGB(50, 100, 170), BTN = Color3.fromRGB(35, 50, 75),
		TOGGLE_OFF = Color3.fromRGB(40, 55, 75), TOGGLE_ON = Color3.fromRGB(60, 130, 210),
	},
	Red = {
		BG = Color3.fromRGB(32, 18, 20), BG2 = Color3.fromRGB(50, 28, 30), BG3 = Color3.fromRGB(60, 35, 38),
		STROKE = Color3.fromRGB(100, 50, 50), TEXT = Color3.fromRGB(245, 230, 230), SUB = Color3.fromRGB(180, 140, 140),
		ACCENT = Color3.fromRGB(140, 50, 55), BTN = Color3.fromRGB(60, 35, 38),
		TOGGLE_OFF = Color3.fromRGB(55, 35, 38), TOGGLE_ON = Color3.fromRGB(180, 60, 65),
	},
	Green = {
		BG = Color3.fromRGB(18, 28, 22), BG2 = Color3.fromRGB(28, 42, 32), BG3 = Color3.fromRGB(35, 55, 40),
		STROKE = Color3.fromRGB(50, 90, 60), TEXT = Color3.fromRGB(230, 240, 230), SUB = Color3.fromRGB(140, 170, 150),
		ACCENT = Color3.fromRGB(50, 120, 70), BTN = Color3.fromRGB(35, 55, 42),
		TOGGLE_OFF = Color3.fromRGB(40, 55, 45), TOGGLE_ON = Color3.fromRGB(60, 150, 90),
	},
	Purple = {
		BG = Color3.fromRGB(24, 20, 34), BG2 = Color3.fromRGB(38, 32, 52), BG3 = Color3.fromRGB(48, 40, 65),
		STROKE = Color3.fromRGB(90, 70, 130), TEXT = Color3.fromRGB(235, 230, 245), SUB = Color3.fromRGB(160, 150, 180),
		ACCENT = Color3.fromRGB(110, 80, 170), BTN = Color3.fromRGB(48, 40, 65),
		TOGGLE_OFF = Color3.fromRGB(50, 42, 65), TOGGLE_ON = Color3.fromRGB(130, 90, 200),
	},
	Orange = {
		BG = Color3.fromRGB(32, 24, 16), BG2 = Color3.fromRGB(50, 36, 22), BG3 = Color3.fromRGB(65, 45, 28),
		STROKE = Color3.fromRGB(140, 90, 40), TEXT = Color3.fromRGB(245, 235, 220), SUB = Color3.fromRGB(190, 160, 120),
		ACCENT = Color3.fromRGB(200, 120, 40), BTN = Color3.fromRGB(65, 45, 28),
		TOGGLE_OFF = Color3.fromRGB(55, 40, 25), TOGGLE_ON = Color3.fromRGB(220, 140, 50),
	},
	Cyan = {
		BG = Color3.fromRGB(14, 26, 30), BG2 = Color3.fromRGB(22, 40, 46), BG3 = Color3.fromRGB(28, 52, 58),
		STROKE = Color3.fromRGB(40, 120, 140), TEXT = Color3.fromRGB(230, 245, 250), SUB = Color3.fromRGB(130, 180, 190),
		ACCENT = Color3.fromRGB(40, 170, 190), BTN = Color3.fromRGB(28, 52, 58),
		TOGGLE_OFF = Color3.fromRGB(30, 50, 55), TOGGLE_ON = Color3.fromRGB(50, 200, 220),
	},
	Pink = {
		BG = Color3.fromRGB(32, 18, 28), BG2 = Color3.fromRGB(50, 28, 42), BG3 = Color3.fromRGB(65, 36, 55),
		STROKE = Color3.fromRGB(160, 80, 130), TEXT = Color3.fromRGB(250, 230, 240), SUB = Color3.fromRGB(190, 140, 170),
		ACCENT = Color3.fromRGB(210, 90, 150), BTN = Color3.fromRGB(65, 36, 55),
		TOGGLE_OFF = Color3.fromRGB(55, 30, 45), TOGGLE_ON = Color3.fromRGB(230, 100, 160),
	},
	White = {
		BG = Color3.fromRGB(235, 235, 240), BG2 = Color3.fromRGB(220, 220, 228), BG3 = Color3.fromRGB(200, 200, 210),
		STROKE = Color3.fromRGB(160, 160, 170), TEXT = Color3.fromRGB(30, 30, 35), SUB = Color3.fromRGB(90, 90, 100),
		ACCENT = Color3.fromRGB(80, 80, 90), BTN = Color3.fromRGB(200, 200, 210),
		TOGGLE_OFF = Color3.fromRGB(170, 170, 180), TOGGLE_ON = Color3.fromRGB(60, 60, 70),
	},
	Rainbow = {
		BG = Color3.fromRGB(25, 27, 32), BG2 = Color3.fromRGB(40, 42, 50), BG3 = Color3.fromRGB(48, 50, 58),
		STROKE = Color3.fromRGB(60, 60, 70), TEXT = Color3.fromRGB(230, 230, 235), SUB = Color3.fromRGB(140, 142, 150),
		ACCENT = Color3.fromRGB(70, 72, 82), BTN = Color3.fromRGB(48, 50, 58),
		TOGGLE_OFF = Color3.fromRGB(60, 62, 70), TOGGLE_ON = Color3.fromRGB(90, 95, 110),
		_rainbow = true,
	},
}
getgenv()._guyHubTheme = getgenv()._guyHubThemes.Dark
getgenv()._guyHubThemeName = "Dark"
do
	local skip = getgenv()._tcoSkipIntro and true or false
	local mainOn = getgenv()._tcoLoadMain ~= false
	local cmdsOn = getgenv()._tcoLoadCmds and true or false
	if skip and (not mainOn) and (not cmdsOn) then
		local chosen = nil
		local CoreGui = game:GetService("CoreGui")
		local sg = Instance.new("ScreenGui")
		sg.Name = "TCOBootstrapPicker"
		sg.ResetOnSpawn = false
		sg.DisplayOrder = 200
		sg.IgnoreGuiInset = true
		pcall(function() sg.Parent = CoreGui end)
		if not sg.Parent then
			sg.Parent = localplr:WaitForChild("PlayerGui")
		end
		local dim = Instance.new("Frame")
		dim.Size = UDim2.new(1, 0, 1, 0)
		dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dim.BackgroundTransparency = 0.35
		dim.BorderSizePixel = 0
		dim.Parent = sg
		local f = Instance.new("Frame")
		f.Size = UDim2.new(0, 280, 0, 220)
		f.Position = UDim2.new(0.5, -140, 0.5, -110)
		f.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
		f.BorderSizePixel = 0
		f.Parent = sg
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -20, 0, 36)
		title.Position = UDim2.new(0, 10, 0, 10)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 16
		title.TextColor3 = Color3.fromRGB(240, 240, 245)
		title.Text = "Nothing selected to load"
		title.Parent = f
		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, -20, 0, 28)
		sub.Position = UDim2.new(0, 10, 0, 42)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 12
		sub.TextColor3 = Color3.fromRGB(160, 160, 170)
		sub.Text = "Pick one to continue"
		sub.Parent = f
		local function mk(text, y, key)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, -24, 0, 36)
			b.Position = UDim2.new(0, 12, 0, y)
			b.BackgroundColor3 = Color3.fromRGB(48, 50, 58)
			b.Text = text
			b.TextColor3 = Color3.fromRGB(235, 235, 240)
			b.Font = Enum.Font.GothamMedium
			b.TextSize = 14
			b.Parent = f
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
			b.MouseButton1Click:Connect(function()
				chosen = key
			end)
			return b
		end
		mk("Load Intro", 78, "intro")
		mk("Load Main GUI", 120, "main")
		mk("Load Commands", 162, "cmds")
		while not chosen and sg.Parent do
			task.wait()
		end
		pcall(function() sg:Destroy() end)
		if chosen == "intro" then
			getgenv()._tcoSkipIntro = false
			getgenv()._tcoLoadMain = true
			if getgenv()._tcoCfg then
				getgenv()._tcoCfg.skipIntro = false
				getgenv()._tcoCfg.loadMain = true
				if getgenv()._tcoSaveCfg then pcall(getgenv()._tcoSaveCfg) end
			end
		elseif chosen == "main" then
			getgenv()._tcoSkipIntro = true
			getgenv()._tcoLoadMain = true
			if getgenv()._tcoCfg then
				getgenv()._tcoCfg.skipIntro = true
				getgenv()._tcoCfg.loadMain = true
				if getgenv()._tcoSaveCfg then pcall(getgenv()._tcoSaveCfg) end
			end
		elseif chosen == "cmds" then
			getgenv()._tcoSkipIntro = true
			getgenv()._tcoLoadMain = false
			getgenv()._tcoLoadCmds = true
			if getgenv()._tcoCfg then
				getgenv()._tcoCfg.skipIntro = true
				getgenv()._tcoCfg.loadMain = false
				getgenv()._tcoCfg.loadCmds = true
				if getgenv()._tcoSaveCfg then pcall(getgenv()._tcoSaveCfg) end
			end
		end
	end
end
do
	if getgenv()._tcoSkipIntro then
	else
	local CoreGui = game:GetService("CoreGui")
	local TweenService = game:GetService("TweenService")
	local SoundService = game:GetService("SoundService")
	local introDone = false
		local function playSound(id, vol, looped)
		local s = Instance.new("Sound")
		s.Name = "GuyHubSFX"
		s.SoundId = "rbxassetid://" .. tostring(id)
		s.Volume = vol or 0.7
		s.Looped = looped and true or false
		s.PlayOnRemove = false
		pcall(function() s.Parent = game:GetService("SoundService") end)
		if not s.Parent then
			local host = localplr:FindFirstChild("PlayerGui") or localplr
			s.Parent = host
		end
		task.spawn(function()
			local t0 = tick()
			while not s.IsLoaded and tick() - t0 < 2 do
				task.wait(0.05)
			end
			pcall(function()
				s.TimePosition = 0
				s:Play()
			end)
		end)
		if not looped then
			task.delay(8, function()
				pcall(function() if s then s:Destroy() end end)
			end)
		end
		return s
	end
	local SFX_WHOOSH = 9113077334
	local SFX_COIN = 13133749
	local SFX_COIN_BIG = 12222225
	local SFX_ERROR = 138081500
	local SFX_CLICK = 6895079853
	local SFX_MUSIC = 1841647093
local introSg = Instance.new("ScreenGui")
	introSg.Name = "GuyHubIntro"
	introSg.ResetOnSpawn = false
	introSg.DisplayOrder = 200
	introSg.IgnoreGuiInset = true
	pcall(function() introSg.Parent = CoreGui end)
	if not introSg.Parent then
		introSg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	local root = Instance.new("Frame")
	root.Size = UDim2.new(1, 0, 1, 0)
	root.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	root.BorderSizePixel = 0
	root.Parent = introSg
	local cover = Instance.new("Frame")
	cover.AnchorPoint = Vector2.new(0.5, 0.5)
	cover.Position = UDim2.new(0.5, 0, 0.5, 0)
	cover.Size = UDim2.new(0.12, 0, 0.12, 0)
	cover.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
	cover.BorderSizePixel = 0
	cover.ClipsDescendants = true
	cover.Parent = root
	local sky = Instance.new("Frame")
	sky.Size = UDim2.new(1, 0, 0.55, 0)
	sky.BackgroundColor3 = Color3.fromRGB(120, 180, 230)
	sky.BorderSizePixel = 0
	sky.Parent = cover
	local grass = Instance.new("Frame")
	grass.Size = UDim2.new(1, 0, 0.5, 0)
	grass.Position = UDim2.new(0, 0, 0.5, 0)
	grass.BackgroundColor3 = Color3.fromRGB(55, 140, 55)
	grass.BorderSizePixel = 0
	grass.Parent = cover
	local pad = Instance.new("Frame")
	pad.AnchorPoint = Vector2.new(0.5, 0.5)
	pad.Position = UDim2.new(0.55, 0, 0.58, 0)
	pad.Size = UDim2.new(0, 90, 0, 90)
	pad.BackgroundColor3 = Color3.fromRGB(180, 185, 190)
	pad.BorderSizePixel = 0
	pad.Parent = cover
	Instance.new("UICorner", pad).CornerRadius = UDim.new(0, 8)
	local padInner = Instance.new("Frame")
	padInner.Size = UDim2.new(0.7, 0, 0.7, 0)
	padInner.Position = UDim2.new(0.15, 0, 0.15, 0)
	padInner.BackgroundColor3 = Color3.fromRGB(150, 155, 160)
	padInner.BorderSizePixel = 0
	padInner.Parent = pad
	Instance.new("UICorner", padInner).CornerRadius = UDim.new(0, 6)
	task.spawn(function()
		local a = 0
		while introSg.Parent and not introDone do
			a = a + 0.02
			pad.Rotation = a * 20
			pad.Position = UDim2.new(0.55 + math.cos(a) * 0.04, 0, 0.58 + math.sin(a) * 0.03, 0)
			task.wait(0.03)
		end
	end)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.5, 0, 0, 50)
	title.Position = UDim2.new(0.06, 0, 0.18, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 36
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "guy hub tco"
	title.Parent = cover
	local menu = Instance.new("Frame")
	menu.Size = UDim2.new(0, 220, 0, 198)
	menu.Position = UDim2.new(0.06, 0, 0.36, 0)
	menu.BackgroundTransparency = 1
	menu.ZIndex = 10
	menu.Parent = cover
	local function menuBtn(txt, y)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 0, 32)
		b.Position = UDim2.new(0, 0, 0, y)
		b.BackgroundTransparency = 1
		b.Font = Enum.Font.Gotham
		b.TextSize = 22
		b.TextColor3 = Color3.fromRGB(240, 240, 245)
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Text = txt
		b.ZIndex = 11
		b.Parent = menu
		b.MouseButton1Click:Connect(function()
			if lib.playClick then
				lib.playClick(0.75)
			else
				playSound(SFX_CLICK, 0.75, false)
			end
		end)
		return b
	end
	local startBtn = menuBtn("Start", 0)
	local chooseBtn = menuBtn("Choose GUI", 36)
	local setBtn = menuBtn("Settings", 72)
	local gamesBtn = menuBtn("Supported games", 108)
	local creditsBtn = menuBtn("Credits", 144)
	if getgenv()._tcoCfg then
		getgenv()._tcoLoadMain = getgenv()._tcoCfg.loadMain ~= false
		getgenv()._tcoLoadCmds = getgenv()._tcoCfg.loadCmds and true or false
	else
		getgenv()._tcoLoadMain = true
		getgenv()._tcoLoadCmds = false
	end
	local choosePanel = Instance.new("Frame")
	choosePanel.Size = UDim2.new(0, 380, 0, 260)
	choosePanel.Position = UDim2.new(0.5, -140, 0.5, -85)
	choosePanel.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
	choosePanel.Visible = false
	choosePanel.ZIndex = 30
	choosePanel.Parent = cover
	Instance.new("UICorner", choosePanel).CornerRadius = UDim.new(0, 8)
	local cTitle = Instance.new("TextLabel")
	cTitle.Size = UDim2.new(1, -16, 0, 28)
	cTitle.Position = UDim2.new(0, 8, 0, 6)
	cTitle.BackgroundTransparency = 1
	cTitle.Font = Enum.Font.GothamBold
	cTitle.TextSize = 15
	cTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
	cTitle.TextXAlignment = Enum.TextXAlignment.Left
	cTitle.Text = "Choose GUI (multi-select)"
	cTitle.ZIndex = 31
	cTitle.Parent = choosePanel
	local function makeChk(text, y, get, set)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -20, 0, 32)
		b.Position = UDim2.new(0, 10, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(45, 47, 55)
		b.TextColor3 = Color3.fromRGB(235, 235, 240)
		b.Font = Enum.Font.Gotham
		b.TextSize = 14
		b.ZIndex = 31
		b.Parent = choosePanel
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		local function refresh()
			b.Text = (get() and "[X] " or "[ ] ") .. text
			b.BackgroundColor3 = get() and Color3.fromRGB(50, 90, 60) or Color3.fromRGB(45, 47, 55)
		end
		refresh()
		b.MouseButton1Click:Connect(function()
			if lib.playClick then lib.playClick(0.6) end
			set(not get())
			refresh()
		end)
	end
	makeChk("Main GUI", 40, function() return getgenv()._tcoLoadMain end, function(v)
		getgenv()._tcoLoadMain = v
		getgenv()._tcoCfg = getgenv()._tcoCfg or {}
		getgenv()._tcoCfg.loadMain = v
		if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
	end)
	makeChk("Commands GUI", 78, function() return getgenv()._tcoLoadCmds end, function(v)
		getgenv()._tcoLoadCmds = v
		getgenv()._tcoCfg = getgenv()._tcoCfg or {}
		getgenv()._tcoCfg.loadCmds = v
		if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
	end)
	local cBack = Instance.new("TextButton")
	cBack.Size = UDim2.new(1, -20, 0, 32)
	cBack.Position = UDim2.new(0, 10, 1, -42)
	cBack.BackgroundColor3 = Color3.fromRGB(60, 40, 45)
	cBack.Text = "Back"
	cBack.TextColor3 = Color3.fromRGB(235, 235, 240)
	cBack.Font = Enum.Font.Gotham
	cBack.TextSize = 14
	cBack.ZIndex = 31
	cBack.Parent = choosePanel
	Instance.new("UICorner", cBack).CornerRadius = UDim.new(0, 6)
	cBack.MouseButton1Click:Connect(function()
		if lib.playClick then lib.playClick(0.5) end
		choosePanel.Visible = false
	end)
	playSound(SFX_WHOOSH, 1, false)
	TweenService:Create(cover, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	local music = playSound(SFX_MUSIC, 0.45, true)
	task.spawn(function()
		task.wait(0.3)
		pcall(function()
			if music and music.Parent then
				music.Volume = 0.45
				if not music.IsPlaying then music:Play() end
			end
		end)
	end)
	local setPanel = Instance.new("Frame")
	setPanel.Size = UDim2.new(0, 320, 0, 280)
	setPanel.Position = UDim2.new(0.5, -160, 0.5, -140)
	setPanel.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
	setPanel.BackgroundTransparency = 0.05
	setPanel.Visible = false
	setPanel.ZIndex = 20
	setPanel.Parent = cover
	Instance.new("UICorner", setPanel).CornerRadius = UDim.new(0, 8)
	local setTitle = Instance.new("TextLabel")
	setTitle.Size = UDim2.new(1, -16, 0, 28)
	setTitle.Position = UDim2.new(0, 8, 0, 6)
	setTitle.BackgroundTransparency = 1
	setTitle.Font = Enum.Font.GothamBold
	setTitle.TextSize = 16
	setTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
	setTitle.TextXAlignment = Enum.TextXAlignment.Left
	setTitle.Text = "Settings"
	setTitle.ZIndex = 21
	setTitle.Parent = setPanel
	local themeNames = {"Dark", "Blue", "Red", "Green", "Purple", "Orange", "Cyan", "Pink", "White", "Rainbow"}
	local themeDrop = Instance.new("TextButton")
	themeDrop.Size = UDim2.new(1, -16, 0, 34)
	themeDrop.Position = UDim2.new(0, 8, 0, 44)
	themeDrop.BackgroundColor3 = Color3.fromRGB(45, 47, 55)
	themeDrop.Text = "Theme: Dark ▼"
	themeDrop.TextColor3 = Color3.fromRGB(235, 235, 240)
	themeDrop.Font = Enum.Font.Gotham
	themeDrop.TextSize = 14
	themeDrop.ZIndex = 21
	themeDrop.Parent = setPanel
	Instance.new("UICorner", themeDrop).CornerRadius = UDim.new(0, 6)
	local dropList = Instance.new("ScrollingFrame")
	dropList.Size = UDim2.new(1, -16, 0, 0)
	dropList.Position = UDim2.new(0, 8, 0, 80)
	dropList.BackgroundColor3 = Color3.fromRGB(22, 24, 28)
	dropList.BorderSizePixel = 0
	dropList.Visible = false
	dropList.ZIndex = 25
	dropList.ScrollBarThickness = 3
	dropList.Parent = setPanel
	Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
	local dropLay = Instance.new("UIListLayout")
	dropLay.Parent = dropList
	for _, n in ipairs(themeNames) do
		local ob = Instance.new("TextButton")
		ob.Size = UDim2.new(1, -4, 0, 26)
		ob.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
		ob.Text = n
		ob.TextColor3 = Color3.fromRGB(230, 230, 235)
		ob.Font = Enum.Font.Gotham
		ob.TextSize = 13
		ob.ZIndex = 26
		ob.Parent = dropList
		ob.MouseButton1Click:Connect(function()
			getgenv()._guyHubThemeName = n
			getgenv()._guyHubTheme = getgenv()._guyHubThemes[n]
			themeDrop.Text = "Theme: " .. n .. " ▼"
			dropList.Visible = false
			dropList.Size = UDim2.new(1, -16, 0, 0)
			playSound(SFX_CLICK, 0.4, false)
		end)
	end
	themeDrop.MouseButton1Click:Connect(function()
		dropList.Visible = not dropList.Visible
		if dropList.Visible then
			dropList.Size = UDim2.new(1, -16, 0, math.min(160, #themeNames * 28))
			dropList.CanvasSize = UDim2.new(0, 0, 0, #themeNames * 28)
		else
			dropList.Size = UDim2.new(1, -16, 0, 0)
		end
		playSound(SFX_CLICK, 0.35, false)
	end)
	local backBtn = Instance.new("TextButton")
	backBtn.Size = UDim2.new(1, -16, 0, 34)
	backBtn.Position = UDim2.new(0, 8, 1, -40)
	backBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 45)
	backBtn.Text = "Back"
	backBtn.TextColor3 = Color3.fromRGB(235, 235, 240)
	backBtn.Font = Enum.Font.Gotham
	backBtn.TextSize = 14
	backBtn.ZIndex = 21
	backBtn.Parent = setPanel
	Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)
	local function introChk(text, y, get, set)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -16, 0, 28)
		b.Position = UDim2.new(0, 8, 0, y)
		b.BackgroundColor3 = Color3.fromRGB(45, 47, 55)
		b.TextColor3 = Color3.fromRGB(235, 235, 240)
		b.Font = Enum.Font.Gotham
		b.TextSize = 13
		b.ZIndex = 21
		b.Parent = setPanel
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		local function refresh()
			b.Text = (get() and "[X] " or "[ ] ") .. text
		end
		refresh()
		b.MouseButton1Click:Connect(function()
			playSound(SFX_CLICK, 0.4, false)
			set(not get())
			refresh()
			if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
		end)
	end
	introChk("Skip intro next time", 120, function()
		return getgenv()._tcoCfg and getgenv()._tcoCfg.skipIntro
	end, function(v)
		getgenv()._tcoCfg = getgenv()._tcoCfg or {}
		getgenv()._tcoCfg.skipIntro = v
		getgenv()._tcoSkipIntro = v
	end)
	introChk("Load Main GUI", 150, function()
		return not getgenv()._tcoCfg or getgenv()._tcoCfg.loadMain ~= false
	end, function(v)
		getgenv()._tcoCfg = getgenv()._tcoCfg or {}
		getgenv()._tcoCfg.loadMain = v
		getgenv()._tcoLoadMain = v
	end)
	introChk("Load Commands GUI", 180, function()
		return getgenv()._tcoCfg and getgenv()._tcoCfg.loadCmds
	end, function(v)
		getgenv()._tcoCfg = getgenv()._tcoCfg or {}
		getgenv()._tcoCfg.loadCmds = v
		getgenv()._tcoLoadCmds = v
	end)
	introChk("Reload config on execute", 210, function()
		return getgenv()._tcoCfg and getgenv()._tcoCfg.reloadOnExecute
	end, function(v)
		getgenv()._tcoCfg = getgenv()._tcoCfg or {}
		getgenv()._tcoCfg.reloadOnExecute = v
	end)
	backBtn.MouseButton1Click:Connect(function()
		setPanel.Visible = false
		playSound(SFX_CLICK, 0.4, false)
	end)
	setBtn.MouseButton1Click:Connect(function()
		setPanel.Visible = true
	end)
	local gamesPanel = Instance.new("Frame")
	gamesPanel = gamesPanel
	gamesPanel.Size = UDim2.new(0, 300, 0, 160)
	gamesPanel.Position = UDim2.new(0.5, -150, 0.5, -80)
	gamesPanel.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
	gamesPanel.BackgroundTransparency = 0.05
	gamesPanel.Visible = false
	gamesPanel.ZIndex = 20
	gamesPanel.Parent = cover
	Instance.new("UICorner", gamesPanel).CornerRadius = UDim.new(0, 8)
	local gTitle = Instance.new("TextLabel")
	gTitle.Size = UDim2.new(1, -16, 0, 28)
	gTitle.Position = UDim2.new(0, 8, 0, 8)
	gTitle.BackgroundTransparency = 1
	gTitle.Font = Enum.Font.GothamBold
	gTitle.TextSize = 16
	gTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
	gTitle.TextXAlignment = Enum.TextXAlignment.Left
	gTitle.Text = "Supported games"
	gTitle.ZIndex = 21
	gTitle.Parent = gamesPanel
	local gList = Instance.new("TextLabel")
	gList.Size = UDim2.new(1, -16, 0, 50)
	gList.Position = UDim2.new(0, 8, 0, 48)
	gList.BackgroundTransparency = 1
	gList.Font = Enum.Font.Gotham
	gList.TextSize = 15
	gList.TextColor3 = Color3.fromRGB(200, 200, 210)
	gList.TextXAlignment = Enum.TextXAlignment.Left
	gList.TextYAlignment = Enum.TextYAlignment.Top
	gList.Text = "• The Chosen One"
	gList.ZIndex = 21
	gList.Parent = gamesPanel
	local gBack = Instance.new("TextButton")
	gBack.Size = UDim2.new(1, -16, 0, 34)
	gBack.Position = UDim2.new(0, 8, 1, -44)
	gBack.BackgroundColor3 = Color3.fromRGB(60, 40, 45)
	gBack.Text = "Back"
	gBack.TextColor3 = Color3.fromRGB(235, 235, 240)
	gBack.Font = Enum.Font.Gotham
	gBack.TextSize = 14
	gBack.ZIndex = 21
	gBack.Parent = gamesPanel
	Instance.new("UICorner", gBack).CornerRadius = UDim.new(0, 6)
	gBack.MouseButton1Click:Connect(function()
		playSound(SFX_CLICK, 0.6, false)
		gamesPanel.Visible = false
	end)
	local creditsPanel
	gamesBtn.MouseButton1Click:Connect(function()
		setPanel.Visible = false
		creditsPanel.Visible = false
		gamesPanel.Visible = true
	end)
	creditsPanel = Instance.new("Frame")
	creditsPanel.Size = UDim2.new(0, 390, 0, 286)
	creditsPanel.Position = UDim2.new(0.5, -195, 0.5, -143)
	creditsPanel.BackgroundColor3 = Color3.fromRGB(23, 26, 33)
	creditsPanel.BackgroundTransparency = 0.02
	creditsPanel.Visible = false
	creditsPanel.ZIndex = 20
	creditsPanel.Parent = cover
	Instance.new("UICorner", creditsPanel).CornerRadius = UDim.new(0, 10)
	local creditsTitle = Instance.new("TextLabel")
	creditsTitle.Size = UDim2.new(1, -24, 0, 30)
	creditsTitle.Position = UDim2.new(0, 12, 0, 10)
	creditsTitle.BackgroundTransparency = 1
	creditsTitle.Font = Enum.Font.GothamBold
	creditsTitle.TextSize = 17
	creditsTitle.TextColor3 = Color3.fromRGB(255, 214, 64)
	creditsTitle.TextXAlignment = Enum.TextXAlignment.Left
	creditsTitle.Text = "Credits"
	creditsTitle.ZIndex = 21
	creditsTitle.Parent = creditsPanel
	local creditsSub = Instance.new("TextLabel")
	creditsSub.Size = UDim2.new(1, -24, 0, 22)
	creditsSub.Position = UDim2.new(0, 12, 0, 40)
	creditsSub.BackgroundTransparency = 1
	creditsSub.Font = Enum.Font.Gotham
	creditsSub.TextSize = 12
	creditsSub.TextColor3 = Color3.fromRGB(155, 165, 180)
	creditsSub.TextXAlignment = Enum.TextXAlignment.Left
	creditsSub.Text = "People who helped shape the script"
	creditsSub.ZIndex = 21
	creditsSub.Parent = creditsPanel
	local creditsList = Instance.new("ScrollingFrame")
	creditsList.Size = UDim2.new(1, -24, 0, 164)
	creditsList.Position = UDim2.new(0, 12, 0, 70)
	creditsList.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
	creditsList.BorderSizePixel = 0
	creditsList.ScrollBarThickness = 3
	creditsList.CanvasSize = UDim2.new(0, 0, 0, 0)
	creditsList.ZIndex = 21
	creditsList.Parent = creditsPanel
	Instance.new("UICorner", creditsList).CornerRadius = UDim.new(0, 7)
	local creditsLayout = Instance.new("UIListLayout")
	creditsLayout.Padding = UDim.new(0, 3)
	creditsLayout.Parent = creditsList
	local creditUsers = {"therealthanosnap", "lostminiacc", "wrapmeinplastiec", "mohablikesnay", "guymanguy", "thelastpoopkaka"}
	for i, username in ipairs(creditUsers) do
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, -12, 0, 24)
		row.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(24, 28, 36) or Color3.fromRGB(20, 23, 30)
		row.BackgroundTransparency = 0.15
		row.Font = Enum.Font.Gotham
		row.TextSize = 13
		row.TextColor3 = Color3.fromRGB(222, 226, 235)
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Text = string.format("  %02d   %s", i, username)
		row.ZIndex = 22
		row.Parent = creditsList
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
	end
	creditsList.CanvasSize = UDim2.new(0, 0, 0, #creditUsers * 27)
	local creditsBack = Instance.new("TextButton")
	creditsBack.Size = UDim2.new(1, -24, 0, 32)
	creditsBack.Position = UDim2.new(0, 12, 1, -44)
	creditsBack.BackgroundColor3 = Color3.fromRGB(52, 58, 72)
	creditsBack.Text = "Back"
	creditsBack.TextColor3 = Color3.fromRGB(240, 242, 248)
	creditsBack.Font = Enum.Font.GothamBold
	creditsBack.TextSize = 13
	creditsBack.ZIndex = 21
	creditsBack.Parent = creditsPanel
	Instance.new("UICorner", creditsBack).CornerRadius = UDim.new(0, 6)
	creditsBack.MouseButton1Click:Connect(function()
		creditsPanel.Visible = false
		playSound(SFX_CLICK, 0.5, false)
	end)
	creditsBtn.MouseButton1Click:Connect(function()
		setPanel.Visible = false
		gamesPanel.Visible = false
		creditsPanel.Visible = true
	end)
	chooseBtn.MouseButton1Click:Connect(function()
		setPanel.Visible = false
		gamesPanel.Visible = false
		creditsPanel.Visible = false
		choosePanel.Visible = true
	end)
	local function runLoadSequence()
		playSound(SFX_CLICK, 0.75, false)
		setPanel.Visible = false
		gamesPanel.Visible = false
		creditsPanel.Visible = false
		menu.Visible = false
		title.Visible = false
		pcall(function()
			if music then
				music:Stop()
				music:Destroy()
				music = nil
			end
		end)
		pcall(function() sky.Visible = false end)
		pcall(function() grass.Visible = false end)
		pcall(function() pad.Visible = false end)
		cover.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
		root.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
		local laptop = Instance.new("Frame")
		laptop.Name = "LaptopBG"
		laptop.Size = UDim2.new(1, 0, 1, 0)
		laptop.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
		laptop.BorderSizePixel = 0
		laptop.ZIndex = 40
		laptop.Parent = cover
		local hill = Instance.new("Frame")
		hill.Size = UDim2.new(1.2, 0, 0.35, 0)
		hill.Position = UDim2.new(-0.1, 0, 0.55, 0)
		hill.BackgroundColor3 = Color3.fromRGB(34, 120, 60)
		hill.BorderSizePixel = 0
		hill.Rotation = -3
		hill.ZIndex = 41
		hill.Parent = cover
		local hill2 = Instance.new("Frame")
		hill2.Size = UDim2.new(1.2, 0, 0.28, 0)
		hill2.Position = UDim2.new(-0.05, 0, 0.62, 0)
		hill2.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
		hill2.BorderSizePixel = 0
		hill2.Rotation = 2
		hill2.ZIndex = 41
		hill2.Parent = cover
		for i, name in ipairs({"This PC", "Recycle", "Folder", "Edge"}) do
			local icon = Instance.new("Frame")
			icon.Size = UDim2.new(0, 48, 0, 52)
			icon.Position = UDim2.new(0, 16, 0, 12 + (i - 1) * 60)
			icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			icon.BackgroundTransparency = 0.85
			icon.BorderSizePixel = 0
			icon.ZIndex = 42
			icon.Parent = cover
			local il = Instance.new("TextLabel")
			il.Size = UDim2.new(1, 0, 1, 0)
			il.BackgroundTransparency = 1
			il.Font = Enum.Font.Gotham
			il.TextSize = 11
			il.TextColor3 = Color3.fromRGB(255, 255, 255)
			il.Text = name
			il.TextYAlignment = Enum.TextYAlignment.Bottom
			il.ZIndex = 43
			il.Parent = icon
		end
		local win = Instance.new("Frame")
		win.Size = UDim2.new(0.55, 0, 0.45, 0)
		win.Position = UDim2.new(0.28, 0, 0.2, 0)
		win.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
		win.BorderSizePixel = 0
		win.ZIndex = 42
		win.Parent = cover
		Instance.new("UICorner", win).CornerRadius = UDim.new(0, 4)
		local winTop = Instance.new("Frame")
		winTop.Size = UDim2.new(1, 0, 0, 28)
		winTop.BackgroundColor3 = Color3.fromRGB(0, 99, 177)
		winTop.BorderSizePixel = 0
		winTop.ZIndex = 43
		winTop.Parent = win
		local winTitle = Instance.new("TextLabel")
		winTitle.Size = UDim2.new(1, -10, 1, 0)
		winTitle.Position = UDim2.new(0, 8, 0, 0)
		winTitle.BackgroundTransparency = 1
		winTitle.Font = Enum.Font.Gotham
		winTitle.TextSize = 13
		winTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		winTitle.TextXAlignment = Enum.TextXAlignment.Left
		winTitle.Text = "guy hub - Windows"
		winTitle.ZIndex = 44
		winTitle.Parent = winTop
		local taskbar = Instance.new("Frame")
		taskbar.Size = UDim2.new(1, 0, 0, 40)
		taskbar.Position = UDim2.new(0, 0, 1, -40)
		taskbar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
		taskbar.BackgroundTransparency = 0.15
		taskbar.BorderSizePixel = 0
		taskbar.ZIndex = 50
		taskbar.Parent = cover
		local startWin = Instance.new("TextLabel")
		startWin.Size = UDim2.new(0, 90, 1, 0)
		startWin.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
		startWin.BackgroundTransparency = 0.2
		startWin.Font = Enum.Font.GothamBold
		startWin.TextSize = 14
		startWin.TextColor3 = Color3.fromRGB(255, 255, 255)
		startWin.Text = "  ⊞ Start"
		startWin.TextXAlignment = Enum.TextXAlignment.Left
		startWin.ZIndex = 51
		startWin.Parent = taskbar
		local clock = Instance.new("TextLabel")
		clock.Size = UDim2.new(0, 80, 1, 0)
		clock.Position = UDim2.new(1, -90, 0, 0)
		clock.BackgroundTransparency = 1
		clock.Font = Enum.Font.Gotham
		clock.TextSize = 12
		clock.TextColor3 = Color3.fromRGB(230, 230, 235)
		clock.Text = os.date("%H:%M")
		clock.ZIndex = 51
		clock.Parent = taskbar
		task.spawn(function()
			for step = 1, 10 do
				if not cover.Parent then break end
				local t = step / 10
				laptop.BackgroundColor3 = Color3.fromRGB(
					math.clamp(0 + step * 12, 0, 120),
					math.clamp(99 - step * 8, 0, 99),
					math.clamp(177 - step * 10, 40, 177)
				)
				for _ = 1, math.min(step, 7) do
					local bar = Instance.new("Frame")
					bar.Size = UDim2.new(math.random(10, 100) / 100, 0, 0, math.random(2, 16))
					bar.Position = UDim2.new(math.random() * 0.85, 0, math.random() * 0.9, 0)
					bar.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 60), math.random(80, 255))
					bar.BackgroundTransparency = 0.2
					bar.BorderSizePixel = 0
					bar.ZIndex = 55
					bar.Parent = cover
					task.delay(0.45, function() pcall(function() bar:Destroy() end) end)
				end
				pcall(function()
					win.Position = UDim2.new(0.28 + (math.random() - 0.5) * t * 0.15, 0, 0.2 + (math.random() - 0.5) * t * 0.1, 0)
					win.BackgroundColor3 = Color3.fromRGB(
						math.clamp(240 - step * 15, 40, 240),
						math.clamp(240 - step * 20, 20, 240),
						math.clamp(245 - step * 5, 80, 245)
					)
				end)
				task.wait(0.5)
			end
		end)
		local t0 = tick()
		local delay = 0.45
		while tick() - t0 < 5 do
			local lab = Instance.new("TextLabel")
			lab.Size = UDim2.new(0, 140, 0, 48)
			lab.Position = UDim2.new(math.random() * 0.75 + 0.05, 0, math.random() * 0.75 + 0.05, 0)
			lab.BackgroundTransparency = 1
			lab.Font = Enum.Font.GothamBlack
			lab.TextSize = math.random(30, 56)
			lab.TextColor3 = Color3.fromRGB(255, 20, 20)
			lab.Text = "GUY"
			lab.Rotation = math.random(-30, 30)
			lab.ZIndex = 55
			lab.Parent = cover
			playSound(SFX_ERROR, 0.4, false)
			task.spawn(function()
				task.wait(0.5)
				if lab then lab:Destroy() end
			end)
			task.wait(delay)
			delay = math.max(0.05, delay * 0.78)
		end
		playSound(SFX_COIN_BIG, 1, false)
		task.delay(0.15, function()
			playSound(SFX_COIN, 0.8, false)
		end)
		local reward = Instance.new("Frame")
		reward.AnchorPoint = Vector2.new(0.5, 0.5)
		reward.Position = UDim2.new(0.5, 0, 0.5, 0)
		reward.Size = UDim2.new(0, 50, 0, 36)
		reward.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
		reward.BorderSizePixel = 0
		reward.ZIndex = 70
		reward.Parent = cover
		Instance.new("UICorner", reward).CornerRadius = UDim.new(0, 12)
		local rTitle = Instance.new("TextLabel")
		rTitle.Size = UDim2.new(1, -20, 0, 70)
		rTitle.Position = UDim2.new(0, 10, 0, 28)
		rTitle.BackgroundTransparency = 1
		rTitle.Font = Enum.Font.GothamBold
		rTitle.TextSize = 22
		rTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
		rTitle.Text = "you have obtained\nguy hub!"
		rTitle.ZIndex = 71
		rTitle.Parent = reward
		local okBtn = Instance.new("TextButton")
		okBtn.Size = UDim2.new(0, 120, 0, 40)
		okBtn.Position = UDim2.new(0.5, -60, 1, -58)
		okBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 70)
		okBtn.Text = "ok!"
		okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		okBtn.Font = Enum.Font.GothamBold
		okBtn.TextSize = 18
		okBtn.ZIndex = 71
		okBtn.Parent = reward
		Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0, 8)
		task.spawn(function()
			local rot = 0
			local start = tick()
			while reward.Parent and tick() - start < 1.4 do
				rot = rot + 14
				reward.Rotation = rot
				task.wait()
			end
			for i = 1, 10 do
				if not reward.Parent then break end
				reward.Rotation = reward.Rotation + (10 - i)
				task.wait()
			end
			reward.Rotation = 0
		end)
		TweenService:Create(reward, TweenInfo.new(0.95, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 280, 0, 190)
		}):Play()
		local clicked = false
		okBtn.MouseButton1Click:Connect(function()
			if clicked then return end
			clicked = true
			playSound(SFX_CLICK, 0.8, false)
			task.wait(0.12)
			if music then pcall(function() music:Stop() music:Destroy() end) end
			TweenService:Create(root, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
			for _, d in pairs(cover:GetDescendants()) do
				pcall(function()
					if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("ImageLabel") then
						TweenService:Create(d, TweenInfo.new(0.35), {TextTransparency = 1, BackgroundTransparency = 1, ImageTransparency = 1}):Play()
					elseif d:IsA("Frame") then
						TweenService:Create(d, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
					end
				end)
			end
			task.wait(0.45)
			introDone = true
			introSg:Destroy()
		end)
	end
	startBtn.MouseButton1Click:Connect(function()
		task.spawn(runLoadSequence)
	end)
	while introSg.Parent and not introDone do
		task.wait()
	end
	pcall(function() if introSg.Parent then introSg:Destroy() end end)
	pcall(function() if music then music:Stop() music:Destroy() end end)
	end
end
if getgenv()._tcoLoadMain ~= false and not getgenv()._tcoSkipTCOBody then
	libgui = lib.makelib("guy hub for tco")
else
	libgui = { Destroy = function() end }
	lib.maketab = function(name) return tostring(name) end
	lib.getpage = function() return nil end
	lib.makelabel = function() end
	lib.makebutton = function() end
	lib.maketoggle = function() return { set = function() end } end
	lib.maketextbox = function() end
	lib.makedropdown = function() return { btn = nil, rebuild = function() end, get = function() end } end
	lib.updatedropdown = function() end
	lib.updatelabel = function() end
	print("[guy hub] Main GUI skipped")
end
pcall(function()
    if getgenv()._tcoTitleStatsConn and getgenv()._tcoTitleStatsConn.Disconnect then getgenv()._tcoTitleStatsConn:Disconnect() end
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local frames, elapsed = 0, 0
    getgenv()._tcoTitleStatsConn = RunService.RenderStepped:Connect(function(dt)
        frames = frames + 1; elapsed = elapsed + (dt or 0)
        if elapsed < 0.5 then return end
        local fps = math.floor(frames / math.max(elapsed, 0.001) + 0.5)
        getgenv()._tcoCurrentFPS = fps
        frames, elapsed = 0, 0
        local ping = "?"
        pcall(function()
            local item = Stats.Network.ServerStatsItem["Data Ping"]
            if item then ping = tostring(math.floor(item:GetValue() + 0.5)) end
        end)
        local label = getgenv()._tcoMainTitleLabel
        if label and label.Parent then label.Text = "guy hub for tco - "..fps.." FPS - "..ping.." ms" end
    end)
end)
getgenv()._tcoSkipIntro = getgenv()._tcoSkipIntro or false
if getgenv()._tcoLoadCmds and not getgenv()._tcoSkipTCOBody then
	pcall(function()
		for _, conn in ipairs(getgenv()._tcoCmdConnections or {}) do
			if conn and conn.Disconnect then conn:Disconnect() end
		end
		getgenv()._tcoCmdConnections = {}
		for _, name in ipairs({"TCOCmdGui", "TCOCmdMini"}) do
			for _, parent in ipairs({game.CoreGui, localplr:FindFirstChild("PlayerGui")}) do
				local old = parent and parent:FindFirstChild(name)
				if old then old:Destroy() end
			end
		end
	end)
	task.spawn(function()
		getgenv()._tcoPrefix = getgenv()._tcoPrefix or ":"
		local function notifyC(t)
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Cmds", Text = tostring(t), Duration = 2})
			end)
		end
		local function findPlr(str)
			if not str or str == "" then return nil end
			local raw = str:lower()
			local compact = raw:gsub("%s", "")
			for _, p in pairs(game.Players:GetPlayers()) do
				if p.Name:lower() == raw or p.DisplayName:lower() == raw then return p end
				if p.Name:lower() == compact or p.DisplayName:lower():gsub("%s", "") == compact then return p end
			end
			for _, p in pairs(game.Players:GetPlayers()) do
				local n, d = p.Name:lower(), p.DisplayName:lower()
				if n:find(compact, 1, true) or d:gsub("%s", ""):find(compact, 1, true) or d:find(raw, 1, true) then
					return p
				end
			end
			return nil
		end
		local function chat(msg)
			msg = tostring(msg or "")
			if getgenv()._tcoMuteSoften then
				msg = getgenv()._tcoMuteSoften(msg)
			end
			pcall(function()
				local tcs = game:GetService("TextChatService")
				if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
					local ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
					if ch then ch:SendAsync(msg) return end
				end
			end)
			pcall(function()
				game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
			end)
		end
		local cmdStates = getgenv()._tcoCmdStates or {}
		getgenv()._tcoCmdStates = cmdStates
		local function runCmd(line)
			line = tostring(line or ""):gsub("^%s+", ""):gsub("%s+$", "")
			local pref = getgenv()._tcoPrefix or ":"
			if line:sub(1, #pref) == pref then
				line = line:sub(#pref + 1)
			end
			local args = {}
			for w in line:gmatch("%S+") do args[#args + 1] = w end
			if #args == 0 then return end
			local cmd = args[1]:lower()
			local a2, a3, a4 = args[2], args[3], args[4]
			local rest = table.concat(args, " ", 2)
			local function onOff(defaultOn)
				if a2 and a2:lower() == "off" then return false end
				if a2 and a2:lower() == "on" then return true end
				if defaultOn ~= nil then return defaultOn end
				return true
			end
			local function S()
				getgenv()._tcoP = getgenv()._tcoP or {}
				return getgenv()._tcoP
			end
			local function hrp()
				return localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
			end
			local function hum()
				return localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
			end
			if cmd == "whitelist" then
				local p = findPlr(rest ~= "" and rest or a2)
				if not p then notifyC("player not found") return end
				getgenv()._tcoWhitelist = getgenv()._tcoWhitelist or {}
				getgenv()._tcoWhitelist[p.UserId] = p.Name
				notifyC("whitelisted " .. p.Name)
				return
			end
			if cmd == "unwhitelist" then
				local p = findPlr(rest ~= "" and rest or a2)
				getgenv()._tcoWhitelist = getgenv()._tcoWhitelist or {}
				if p then
					getgenv()._tcoWhitelist[p.UserId] = nil
					notifyC("unwhitelisted " .. p.Name)
				else
					notifyC("player not found")
				end
				return
			end
			if cmd == "whitelists" then
				getgenv()._tcoWhitelist = getgenv()._tcoWhitelist or {}
				local n = 0
				for id, name in pairs(getgenv()._tcoWhitelist) do
					n = n + 1
					notifyC(tostring(name) .. " (" .. tostring(id) .. ")")
				end
				if n == 0 then notifyC("whitelist empty") end
				return
			end
			if cmd == "prefix" then
				local sg = Instance.new("ScreenGui")
				sg.Name = "TCOPrefixGui"
				sg.ResetOnSpawn = false
				pcall(function() sg.Parent = game.CoreGui end)
				if not sg.Parent then sg.Parent = localplr.PlayerGui end
				local f = Instance.new("Frame")
				f.Size = UDim2.new(0, 260, 0, 120)
				f.Position = UDim2.new(0.5, -130, 0.5, -60)
				f.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
				f.Parent = sg
				Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
				local tb = Instance.new("TextBox")
				tb.Size = UDim2.new(1, -20, 0, 34)
				tb.Position = UDim2.new(0, 10, 0, 20)
				tb.BackgroundColor3 = Color3.fromRGB(45, 47, 55)
				tb.Text = getgenv()._tcoPrefix or ":"
				tb.TextColor3 = Color3.fromRGB(240, 240, 245)
				tb.Font = Enum.Font.Gotham
				tb.TextSize = 16
				tb.Parent = f
				Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
				local ap = Instance.new("TextButton")
				ap.Size = UDim2.new(1, -20, 0, 34)
				ap.Position = UDim2.new(0, 10, 0, 70)
				ap.BackgroundColor3 = Color3.fromRGB(60, 140, 70)
				ap.Text = "Apply"
				ap.TextColor3 = Color3.fromRGB(255, 255, 255)
				ap.Font = Enum.Font.GothamBold
				ap.TextSize = 15
				ap.Parent = f
				Instance.new("UICorner", ap).CornerRadius = UDim.new(0, 6)
				ap.MouseButton1Click:Connect(function()
					local pfx = tb.Text
					if pfx and #pfx > 0 and #pfx <= 3 then
						getgenv()._tcoPrefix = pfx
						notifyC("Prefix = " .. pfx)
					end
					sg:Destroy()
				end)
				return
			end
			if cmd == "cmds" or cmd == "help" then
				pcall(function()
					local old = game.CoreGui:FindFirstChild("TCOCmdsList")
					if old then old:Destroy() end
				end)
				local list = {
					":fling name", ":flingloop name", ":flingall", ":walkfling [power|off]",
					":tp name", ":goto name", ":view name", ":unview", ":orbit name", ":spamtp name",
					":bubblechat name", ":freeze name", ":reset name", ":glitch name", ":jail name", ":grief name", ":minorgrief name sec", ":disablebkit name|off",
					":ws n", ":jp n", ":infjump", ":fly", ":flyspeed n", ":arken", ":rejoin", ":serverhop",
					":jailaura", ":dihaura", ":deleteaura [range|off]", ":buildaura", ":signaura", ":blackaura [user]", ":woodaura", ":iceaura", ":metalaura", ":glassaura", ":toxifyaura", ":rainbowaura", ":tweenunder user", ":abuse user", ":control user", ":phantom", ":riftslash", ":soulsnatch", ":barrage", ":voiddomain", ":sonic",
					":unanchoraura", ":blackaura [user]", ":woodaura", ":iceaura", ":metalaura",
					":glassaura", ":ffaura", ":whiteaura", ":toxifyaura", ":rainbowaura",
					":tweenunder user", ":abuse user", ":control user", ":gojo", ":blue", ":red", ":purple", ":domain",
					":sonic", ":aurarange n",
					":spamblocks", ":spamsigns", ":equipall", ":dropall", ":noclip", ":esp",
					":spychat", ":prefix", ":say text", ":spam text", ":mainui",
					":whitelist name", ":unwhitelist name", ":whitelists",
					":standcmds", ":grief name", ":griefall", ":deleteaura [range|off]",
					":deletebarrage", ":barragefling", ":throwblock", ":standstop",
					":antitoxify", ":antiblind", ":antiglitch", ":antifreeze", ":antijail", ":spamr6",
				}
				local sg = Instance.new("ScreenGui")
				sg.Name = "TCOCmdsList"
				sg.ResetOnSpawn = false
				sg.DisplayOrder = 160
				pcall(function() sg.Parent = game.CoreGui end)
				if not sg.Parent then sg.Parent = localplr.PlayerGui end
				local f = Instance.new("Frame")
				f.Size = UDim2.new(0, 360, 0, 320)
				f.Position = UDim2.new(0.5, -180, 0.5, -160)
				f.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
				f.Parent = sg
				Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
				local top = Instance.new("Frame")
				top.Size = UDim2.new(1, 0, 0, 34)
				top.BackgroundColor3 = Color3.fromRGB(36, 38, 46)
				top.Parent = f
				local tl = Instance.new("TextLabel")
				tl.Size = UDim2.new(1, -40, 1, 0)
				tl.Position = UDim2.new(0, 10, 0, 0)
				tl.BackgroundTransparency = 1
				tl.Font = Enum.Font.GothamBold
				tl.TextSize = 14
				tl.TextColor3 = Color3.fromRGB(240, 240, 245)
				tl.TextXAlignment = Enum.TextXAlignment.Left
				tl.Text = "Commands"
				tl.Parent = top
				local xb = Instance.new("TextButton")
				xb.Size = UDim2.new(0, 28, 0, 24)
				xb.Position = UDim2.new(1, -32, 0.5, -12)
				xb.BackgroundColor3 = Color3.fromRGB(90, 40, 50)
				xb.Text = "X"
				xb.TextColor3 = Color3.fromRGB(255, 255, 255)
				xb.Font = Enum.Font.GothamBold
				xb.Parent = top
				Instance.new("UICorner", xb).CornerRadius = UDim.new(0, 6)
				xb.MouseButton1Click:Connect(function() sg:Destroy() end)
				local search = Instance.new("TextBox")
				search.Size = UDim2.new(1, -16, 0, 30)
				search.Position = UDim2.new(0, 8, 0, 40)
				search.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
				search.PlaceholderText = "Search commands..."
				search.Text = ""
				search.TextColor3 = Color3.fromRGB(255, 255, 255)
				search.Font = Enum.Font.Gotham
				search.TextSize = 14
				search.Parent = f
				Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)
				local scroll = Instance.new("ScrollingFrame")
				scroll.Size = UDim2.new(1, -16, 1, -84)
				scroll.Position = UDim2.new(0, 8, 0, 78)
				scroll.BackgroundTransparency = 1
				scroll.ScrollBarThickness = 4
				scroll.Parent = f
				local lay = Instance.new("UIListLayout")
				lay.Parent = scroll
				lay.Padding = UDim.new(0, 4)
				local function rebuild(filter)
					for _, ch in pairs(scroll:GetChildren()) do
						if ch:IsA("TextLabel") or ch:IsA("TextButton") then ch:Destroy() end
					end
					filter = (filter or ""):lower()
					local n = 0
					for _, line in ipairs(list) do
						if filter == "" or line:lower():find(filter, 1, true) then
							local l = Instance.new("TextLabel")
							l.Size = UDim2.new(1, -4, 0, 22)
							l.BackgroundTransparency = 1
							l.Font = Enum.Font.Gotham
							l.TextSize = 13
							l.TextColor3 = Color3.fromRGB(220, 220, 230)
							l.TextXAlignment = Enum.TextXAlignment.Left
							l.Text = line
							l.Parent = scroll
							n = n + 1
						end
					end
					scroll.CanvasSize = UDim2.new(0, 0, 0, n * 26)
				end
				rebuild("")
				search:GetPropertyChangedSignal("Text"):Connect(function()
					rebuild(search.Text)
				end)
				notifyC("cmds list opened")
				return
			end
			local function cmdFindBuildFolder(name)
				if typeof(findBuildFolder) == "function" then
					return findBuildFolder(name)
				end
				local bricks = workspace:FindFirstChild("Bricks")
				if not bricks or not name then return nil end
				local f = bricks:FindFirstChild(name)
				if f then return f end
				local low = name:lower()
				for _, ch in pairs(bricks:GetChildren()) do
					if ch.Name:lower() == low then return ch end
				end
				return nil
			end
			local function cmdCollectOwnerParts(p)
				local parts = {}
				local folder = cmdFindBuildFolder(p.Name)
				if folder then
					for _, part in pairs(folder:GetDescendants()) do
						if part:IsA("BasePart") then
							parts[#parts + 1] = part
						end
					end
					if #parts > 0 then return parts end
				end
				local bricks = workspace:FindFirstChild("Bricks")
				if not bricks then return parts end
				local low = p.Name:lower()
				local dlow = p.DisplayName and p.DisplayName:lower() or low
				for _, part in pairs(bricks:GetDescendants()) do
					if part:IsA("BasePart") then
						local fold = part.Parent
						while fold and fold ~= bricks and fold ~= workspace do
							local fn = fold.Name:lower()
							if fn == low or fn == dlow then
								parts[#parts + 1] = part
								break
							end
							fold = fold.Parent
						end
					end
				end
				return parts
			end
			local function griefPlayer(p, maxSec)
				if not p then return end
				getgenv()._tcoGriefRun = getgenv()._tcoGriefRun or {}
				local key = p.UserId
				getgenv()._tcoGriefRun[key] = true
				task.spawn(function()
					local t0 = tick()
					notifyC("grief " .. p.Name .. (maxSec and (" " .. maxSec .. "s") or " until clear"))
					pcall(function()
						if typeof(refreshDeleteTool) == "function" then refreshDeleteTool() end
						if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
					end)
					local empty = 0
					while getgenv()._tcoGriefRun[key] do
						if maxSec and (tick() - t0) >= maxSec then break end
						local left = 0
						pcall(function()
							if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
							local parts = cmdCollectOwnerParts(p)
							left = #parts
							if left == 0 then return end
							if typeof(fireDeleteBurst) == "function" then
								fireDeleteBurst(parts)
							elseif typeof(fireDelete) == "function" then
								for i = 1, math.min(#parts, 80) do
									fireDelete(parts[i])
									if i % 25 == 0 then task.wait() end
								end
							else
								notifyC("delete remote missing - open main GUI once")
							end
						end)
						if left == 0 then
							empty = empty + 1
							if not maxSec and empty >= 4 then break end
						else
							empty = 0
						end
						task.wait(0.08)
					end
					getgenv()._tcoGriefRun[key] = false
					notifyC("grief done " .. p.Name)
				end)
			end
			if cmd == "grief" then
				if a2 and a2:lower() == "off" then
					getgenv()._tcoGriefRun = {}
					notifyC("grief stopped")
					return
				end
				local p = findPlr(a2)
				if not p then notifyC("no player") return end
				griefPlayer(p, nil)
				return
			end
			if cmd == "minorgrief" then
				local p = findPlr(a2)
				local sec = tonumber(a3) or 5
				if not p then notifyC("usage: minorgrief name seconds") return end
				griefPlayer(p, sec)
				return
			end
			if cmd == "disablebkit" or cmd == "blockbkit" then
				if a2 and a2:lower() == "off" then
					if getgenv()._tcoStopDisableBkit then getgenv()._tcoStopDisableBkit() end
					notifyC("disablebkit off")
					return
				end
				local p = findPlr(a2)
				if not p then notifyC("usage: disablebkit name | disablebkit off") return end
				if getgenv()._tcoStartDisableBkit then
					local ok = getgenv()._tcoStartDisableBkit(p.Name)
					notifyC(ok and ("disablebkit " .. p.Name) or "disablebkit failed")
				else
					notifyC("disablebkit needs main GUI loaded once")
				end
				return
			end
			if cmd == "fling" then
				local p = findPlr(a2)
				if not p or not p.Character then notifyC("no player") return end
				local th = p.Character:FindFirstChild("HumanoidRootPart")
				if not th then return end
				task.spawn(function()
					if typeof(flingWithReturn) == "function" then
						flingWithReturn(th, 30)
					end
				end)
				notifyC("fling " .. p.Name .. " (return)")
				return
			end
			if cmd == "flingloop" then
				local st = S()
				st.flingSel = onOff(true)
				if a2 and a2:lower() ~= "off" and a2:lower() ~= "on" then
					st.selName = findPlr(a2) and findPlr(a2).Name or a2
				end
				if st.flingSel then
					task.spawn(function()
						while st.flingSel do
							pcall(function()
								local p = findPlr(st.selName)
								local th = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
								local my = hrp()
								if th and my then
									my.CFrame = th.CFrame
									th.AssemblyLinearVelocity = Vector3.new((math.random()-0.5)*2e4, 2e4, (math.random()-0.5)*2e4)
									th.Velocity = th.AssemblyLinearVelocity
								end
							end)
							task.wait()
						end
					end)
				end
				notifyC("flingloop " .. tostring(st.flingSel))
				return
			end
			if cmd == "flingall" then
				local loop = a2 and a2:lower() == "loop"
				local st = S()
				if a2 and a2:lower() == "off" then st.loopFlingAll = false notifyC("flingall off") return end
				if loop then
					st.loopFlingAll = true
					task.spawn(function()
						while st.loopFlingAll do
							pcall(function()
								local my = hrp()
								if not my then return end
								for _, p in pairs(game.Players:GetPlayers()) do
									if not st.loopFlingAll then break end
									if p ~= localplr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
										local th = p.Character.HumanoidRootPart
										my.CFrame = th.CFrame
										th.AssemblyLinearVelocity = Vector3.new((math.random()-0.5)*2e4, 2e4, (math.random()-0.5)*2e4)
									end
								end
							end)
							task.wait()
						end
					end)
					notifyC("flingall loop on")
				else
					task.spawn(function()
						local my = hrp()
						if not my then return end
						for _, p in pairs(game.Players:GetPlayers()) do
							if p ~= localplr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
								local th = p.Character.HumanoidRootPart
								for i = 1, 12 do
									pcall(function()
										my.CFrame = th.CFrame
										th.AssemblyLinearVelocity = Vector3.new((math.random()-0.5)*3e4, 3e4, (math.random()-0.5)*3e4)
									end)
									task.wait()
								end
							end
						end
					end)
					notifyC("flingall once")
				end
				return
			end
			if cmd == "walkfling" then
				local st = S()
				st.walkFling = onOff(true)
				if a2 and tonumber(a2) then st.wfPower = tonumber(a2) end
				if st.walkFling then
					task.spawn(function()
						local RS = game:GetService("RunService")
						local Movel = 0.1
						while st.walkFling do
							pcall(function()
								local r = hrp()
								if not r then return end
								local power = st.wfPower or 10000
								local near = false
								for _, p in pairs(game.Players:GetPlayers()) do
									if p ~= localplr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
										if (p.Character.HumanoidRootPart.Position - r.Position).Magnitude <= 5 then near = true break end
									end
								end
								if near then
									local Velocity = r.Velocity
									r.Velocity = Velocity * power + Vector3.new(0, power, 0)
									RS.RenderStepped:Wait()
									if r.Parent then r.Velocity = Velocity end
									RS.Stepped:Wait()
									if r.Parent then r.Velocity = Velocity + Vector3.new(0, Movel, 0) Movel = Movel * -1 end
								end
							end)
							task.wait()
						end
					end)
				end
				notifyC("walkfling " .. tostring(st.walkFling))
				return
			end
			if cmd == "tp" then
				local p = findPlr(a2)
				if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and hrp() then
					hrp().CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
					notifyC("tp " .. p.Name)
				else notifyC("no player") end
				return
			end
			if cmd == "view" then
				local p = findPlr(a2)
				if p and p.Character then
					local h = p.Character:FindFirstChildOfClass("Humanoid")
					if h then workspace.CurrentCamera.CameraSubject = h end
					notifyC("view " .. p.Name)
				end
				return
			end
			if cmd == "unview" then
				local h = hum()
				if h then workspace.CurrentCamera.CameraSubject = h end
				notifyC("unview")
				return
			end
			if cmd == "orbit" then
				local st = S()
				st.orbit = onOff(true)
				if a2 and a2:lower() ~= "off" and a2:lower() ~= "on" then st.selName = (findPlr(a2) and findPlr(a2).Name) or a2 end
				if st.orbit then
					task.spawn(function()
						local ang = 0
						while st.orbit do
							pcall(function()
								local p = findPlr(st.selName)
								local my = hrp()
								if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and my then
									ang = ang + 0.25
									local t = p.Character.HumanoidRootPart.Position
									my.CFrame = CFrame.new(t + Vector3.new(math.cos(ang)*6, 3, math.sin(ang)*6), t)
								end
							end)
							task.wait()
						end
					end)
				end
				notifyC("orbit " .. tostring(st.orbit))
				return
			end
			if cmd == "spamtp" then
				local st = S()
				st.spamTP = onOff(true)
				if a2 and a2:lower() ~= "off" and a2:lower() ~= "on" then st.selName = (findPlr(a2) and findPlr(a2).Name) or a2 end
				if st.spamTP then
					task.spawn(function()
						while st.spamTP do
							pcall(function()
								local p = findPlr(st.selName)
								if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and hrp() then
									hrp().CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
								end
							end)
							task.wait(0.15)
						end
					end)
				end
				notifyC("spamtp " .. tostring(st.spamTP))
				return
			end
			if cmd == "bubblechat" or cmd == "bubble" then
				local st = S()
				st.bubbleChat = onOff(true)
				if a2 and a2:lower() ~= "off" and a2:lower() ~= "on" then st.selName = (findPlr(a2) and findPlr(a2).Name) or a2 end
				if st.bubbleChat then
					task.spawn(function()
						while st.bubbleChat do
							pcall(function()
								local p = findPlr(st.selName)
								local my = hrp()
								local th = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
								if th and my then
									my.CFrame = th.CFrame
									my.AssemblyLinearVelocity = th.AssemblyLinearVelocity
								end
							end)
							task.wait()
						end
					end)
				end
				notifyC("bubblechat " .. tostring(st.bubbleChat))
				return
			end
			if cmd == "freeze" or cmd == "reset" or cmd == "glitch" or cmd == "kill" or cmd == "blind" or cmd == "toxify" then
				local p = findPlr(a2)
				if not p then notifyC("no player") return end
				chat(cmd .. " " .. p.Name)
				notifyC(cmd .. " " .. p.Name)
				return
			end
			if cmd == "ws" or cmd == "walkspeed" or cmd == "speed" then
				local n = tonumber(a2)
				local st = S()
				if a2 and a2:lower() == "off" then st.loopWS = false notifyC("ws off") return end
				if n then st.ws = n st.loopWS = true
					task.spawn(function()
						while st.loopWS do
							pcall(function() local h = hum() if h then h.WalkSpeed = st.ws end end)
							task.wait(0.1)
						end
					end)
					notifyC("ws " .. n)
				end
				return
			end
			if cmd == "jp" or cmd == "jumppower" or cmd == "jump" then
				local n = tonumber(a2)
				local st = S()
				if a2 and a2:lower() == "off" then st.loopJP = false notifyC("jp off") return end
				if n then st.jp = n st.loopJP = true
					task.spawn(function()
						while st.loopJP do
							pcall(function()
								local h = hum()
								if h then h.JumpPower = st.jp pcall(function() h.JumpHeight = st.jp/20 end) end
							end)
							task.wait(0.1)
						end
					end)
					notifyC("jp " .. n)
				end
				return
			end
			if cmd == "infjump" or cmd == "infinitejump" then
				local st = S()
				st.infJump = onOff(true)
				if st.infJumpConn then pcall(function() st.infJumpConn:Disconnect() end) st.infJumpConn = nil end
				if st.infJump then
					st.infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
						if not st.infJump then return end
						pcall(function() local h = hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
					end)
				end
				notifyC("infjump " .. tostring(st.infJump))
				return
			end
			if cmd == "fly" or cmd == "chosenfly" then
				local st = S()
				local want = onOff(true)
				st.chosenFly = want
				st.flyOn = want
				st.flySpeed = st.flySpeed or 50
				pcall(function()
					local r = hrp()
					if r then
						for _, n in pairs({"FlyBV", "FlyBG"}) do
							local x = r:FindFirstChild(n)
							if x then x:Destroy() end
						end
					end
					local h = hum()
					if h then h.PlatformStand = false end
				end)
				if st.flyRender then pcall(function() st.flyRender:Disconnect() end) st.flyRender = nil end
				if not want then notifyC("fly off") return end
				local r = hrp()
				local h = hum()
				if not r or not h then notifyC("no character") return end
				h.PlatformStand = true
				local bv = Instance.new("BodyVelocity")
				bv.Name = "FlyBV"
				bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				bv.Velocity = Vector3.new()
				bv.Parent = r
				local bg = Instance.new("BodyGyro")
				bg.Name = "FlyBG"
				bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
				bg.P = 9e4
				bg.CFrame = r.CFrame
				bg.Parent = r
				st.flyBV, st.flyBG = bv, bg
				st.flyRender = game:GetService("RunService").RenderStepped:Connect(function()
					if not st.chosenFly or not st.flyOn then return end
					pcall(function()
						local r2, h2 = hrp(), hum()
						local cam = workspace.CurrentCamera
						if not r2 or not h2 or not cam then return end
						if not st.flyBV or not st.flyBV.Parent then return end
						local md = h2.MoveDirection
						local look = cam.CFrame.LookVector
						local dir = Vector3.new()
						if md.Magnitude > 0.05 then
							local flat = Vector3.new(look.X, 0, look.Z)
							if flat.Magnitude > 0.01 then flat = flat.Unit end
							local right = Vector3.new(flat.Z, 0, -flat.X)
							dir = look * md:Dot(flat) + cam.CFrame.RightVector * md:Dot(Vector3.new(right.X,0,right.Z).Unit)
							if dir.Magnitude > 0 then dir = dir.Unit end
						end
						local UIS = game:GetService("UserInputService")
						if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
						if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
						if dir.Magnitude > 0 then dir = dir.Unit end
						st.flyBV.Velocity = dir * (st.flySpeed or 50)
						st.flyBG.CFrame = CFrame.new(r2.Position, r2.Position + look)
						h2.PlatformStand = true
					end)
				end)
				notifyC("fly on")
				return
			end
			if cmd == "flyspeed" then
				local n = tonumber(a2)
				if n then S().flySpeed = n notifyC("flyspeed " .. n) end
				return
			end
			if cmd == "arken" or cmd == "arkenstone" or cmd == "enlighten" then
				local st = S()
				st.enlightenBypass = onOff(true)
				notifyC("arken bypass " .. tostring(st.enlightenBypass))
				return
			end
			if cmd == "rejoin" then
				pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, localplr) end)
				return
			end
			if cmd == "serverhop" or cmd == "hop" then
				task.spawn(function()
					pcall(function()
						local ts = game:GetService("TeleportService")
						local http = game:GetService("HttpService")
						local placeId, jobId = game.PlaceId, game.JobId
						local body = game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
						local data = http:JSONDecode(body)
						local servers = {}
						if data and data.data then
							for _, s in pairs(data.data) do
								if s.id ~= jobId and s.playing < s.maxPlayers then table.insert(servers, s.id) end
							end
						end
						if #servers > 0 then ts:TeleportToPlaceInstance(placeId, servers[math.random(1,#servers)], localplr)
						else ts:Teleport(placeId) end
					end)
				end)
				notifyC("serverhop")
				return
			end
			if cmd == "jailaura" then
				getgenv()._tcoJailAura = onOff(true)
				if tonumber(a2) then getgenv()._tcoJailRange = tonumber(a2) end
				notifyC("jailaura " .. tostring(getgenv()._tcoJailAura))
				return
			end
			if cmd == "jailrange" then
				local n = tonumber(a2) if n then getgenv()._tcoJailRange = n notifyC("jailrange "..n) end
				return
			end
			if cmd == "dihaura" or cmd == "builddih" then
				getgenv()._tcoDihAura = onOff(true)
				notifyC("dihaura " .. tostring(getgenv()._tcoDihAura))
				return
			end
			if cmd == "deleteaura" then
				getgenv()._tcoCmdDeleteAura_gen = (getgenv()._tcoCmdDeleteAura_gen or 0) + 1
				local deleteGen = getgenv()._tcoCmdDeleteAura_gen
				if a2 and a2:lower() == "off" then
					getgenv()._tcoCmdDeleteAura = false
					pcall(function() daura = false end)
					notifyC("deleteaura off")
					return
				end
				local range = tonumber(a2) or getgenv()._tcoAuraRange or 35
				getgenv()._tcoAuraRange = range
				getgenv()._tcoCmdDeleteAura = true
				pcall(function()
					daurarange = range
					daura = true
					if daurapart then daurapart.Size = Vector3.new(range, range, range) end
				end)
				task.spawn(function()
					while getgenv()._tcoCmdDeleteAura and getgenv()._tcoCmdDeleteAura_gen == deleteGen do
						pcall(function()
							local char = localplr.Character
							local my = char and char:FindFirstChild("HumanoidRootPart")
							if not my then return end
							if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
							local bricks = workspace:FindFirstChild("Bricks")
							if not bricks then return end
							local targets = {}
							for _, part in pairs(bricks:GetDescendants()) do
								if part:IsA("BasePart") and (part.Position - my.Position).Magnitude <= range then
									targets[#targets + 1] = part
								end
							end
							if typeof(fireDeleteBurst) == "function" then
								fireDeleteBurst(targets)
							elseif typeof(fireDelete) == "function" then
								for i = 1, math.min(#targets, 40) do
									fireDelete(targets[i])
								end
							end
						end)
						task.wait(0.15)
					end
					pcall(function() daura = false end)
				end)
				notifyC("deleteaura on range " .. tostring(range))
				return
			end
			if cmd == "buildaura" then
				local on = onOff(true)
				if on then tcoStartBuildAura() else tcoStopBuildAura() end
				notifyC("buildaura " .. tostring(getgenv()._tcoBuildAura))
				return
			end
			if cmd == "signaura" then
				local on = onOff(true)
				getgenv()._tcoSignAura = on
				getgenv()._tcoSignAura_gen = (getgenv()._tcoSignAura_gen or 0) + 1
				local gen = getgenv()._tcoSignAura_gen
				if on then
					task.spawn(function()
						while getgenv()._tcoSignAura and getgenv()._tcoSignAura_gen == gen do
							pcall(function()
								local o = getAuraOrigin()
								if o and fireSignAt then fireSignAt(o + Vector3.new(math.random(-5,5), -1.5, math.random(-5,5))) end
							end)
							task.wait(0.05)
						end
					end)
				end
				notifyC("signaura " .. tostring(on))
				return
			end
			if cmd == "unanchoraura" then
				local on = onOff(true)
				getgenv()._tcoUnanchorAura = on
				getgenv()._tcoUnanchorAura_gen = (getgenv()._tcoUnanchorAura_gen or 0) + 1
				local gen = getgenv()._tcoUnanchorAura_gen
				if on then
					task.spawn(function()
						while getgenv()._tcoUnanchorAura and getgenv()._tcoUnanchorAura_gen == gen do
							pcall(function()
								local o = getAuraOrigin()
								if o and paintAround then paintAround("unanchor", nil, o, getgenv()._tcoAuraRange or 35, "_tcoUnanchorAura") end
							end)
							task.wait(0.10)
						end
					end)
				end
				notifyC("unanchoraura " .. tostring(on))
				return
			end
			if cmd == "blackaura" or cmd == "paintneonblackaura" or cmd == "neonblackaura" then
				local on = onOff(true)
				local tgt = a2
				if tgt and tgt:lower() ~= "on" and tgt:lower() ~= "off" and not tonumber(tgt) then
					getgenv()._tcoCmdAuraTarget = tgt
				elseif on == false then
					getgenv()._tcoCmdAuraTarget = nil
				end
				getgenv()._tcoBlackAura = on
				getgenv()._tcoBlackAura_gen = (getgenv()._tcoBlackAura_gen or 0) + 1
				local gen = getgenv()._tcoBlackAura_gen
				if on then
					task.spawn(function()
						while getgenv()._tcoBlackAura and getgenv()._tcoBlackAura_gen == gen do
							pcall(function()
								local o = getAuraOrigin and getAuraOrigin()
								if getgenv()._tcoCmdAuraTarget and typeof(resolvePlayer) == "function" then
									local p = resolvePlayer(getgenv()._tcoCmdAuraTarget)
									local h = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
									if h then o = h.Position end
								end
								local pa = paintAround or getgenv().paintAround
if o and pa then pa("black", nil, o, getgenv()._tcoAuraRange or 35, "_tcoBlackAura") end
							end)
							task.wait(0.10)
						end
					end)
				end
				notifyC("blackaura " .. tostring(on))
				return
			end
			local paintCmdMap = {
				woodaura = "wood", iceaura = "ice", metalaura = "metal", glassaura = "glass",
				forcefieldaura = "forcefield", ffaura = "forcefield", whiteaura = "plastic",
				plasticaura = "plastic", toxifyaura = "toxic", rainbowaura = "rainbow",
				neonaura = "neon", yellowaura = "yellow", yellowunanchoraura = "yellow_unanchor",
				tinyyellow = "yellow_unanchor", blackneonaura = "black",
			}
			if paintCmdMap[cmd] then
				local mode = paintCmdMap[cmd]
				local on = onOff(true)
				local tgtArg = a2
				if tgtArg and tgtArg:lower() ~= "on" and tgtArg:lower() ~= "off" and not tonumber(tgtArg) then
					getgenv()._tcoCmdAuraTarget = tgtArg
					on = onOff(true)
					if a3 and a3:lower() == "off" then on = false end
				end
				local flag = "_tcoCmdPaint_" .. mode
				getgenv()[flag] = on
				getgenv()[flag .. "_gen"] = (getgenv()[flag .. "_gen"] or 0) + 1
				local gen = getgenv()[flag .. "_gen"]
				if on then
					task.spawn(function()
						while getgenv()[flag] and getgenv()[flag .. "_gen"] == gen do
							pcall(function()
								local o = getAuraOrigin and getAuraOrigin()
								if getgenv()._tcoCmdAuraTarget then
									local nm = getgenv()._tcoCmdAuraTarget
									local p = game.Players:FindFirstChild(nm)
									if not p then
										for _, pl in pairs(game.Players:GetPlayers()) do
											if pl.Name:lower()==nm:lower() or pl.DisplayName:lower()==nm:lower() then p=pl break end
										end
									end
									local h = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
									if h then o = h.Position end
								end
								local pa = paintAround or getgenv().paintAround
								if o and pa then
									if mode == "rainbow" then
										local col = Color3.fromHSV((tick()%5)/5, 1, 1)
										pa("black", col, o, getgenv()._tcoAuraRange or 35, flag)
									else
										pa(mode, nil, o, getgenv()._tcoAuraRange or 35, flag)
									end
								end
							end)
							task.wait(0.10)
						end
					end)
				end
				notifyC(cmd .. " " .. tostring(on))
				return
			end
			if cmd == "tweenunder" or cmd == "under" then
				local on = onOff(true)
				getgenv()._tcoBlameUnder = on
				if on then
					local tgt = a2
					if tgt and tgt:lower() ~= "on" then
						getgenv()._tcoBlameSel = tgt
					end
					pcall(function()
						local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
						if my then getgenv()._tcoBlameHomeCF = my.CFrame end
					end)
					task.spawn(function()
						while getgenv()._tcoBlameUnder do
							pcall(function()
								local nm = getgenv()._tcoBlameSel
								local p = nm and game.Players:FindFirstChild(nm)
								if not p and nm then
									for _, pl in pairs(game.Players:GetPlayers()) do
										if pl.Name:lower()==nm:lower() or pl.DisplayName:lower()==nm:lower() then p=pl break end
									end
								end
								local h = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
								if h and tcoInstantNoclipUnder then tcoInstantNoclipUnder(h.Position) end
							end)
							task.wait()
						end
						if tcoClearUnderHold then tcoClearUnderHold() end
						if tcoSoftReturnHome and getgenv()._tcoBlameHomeCF then tcoSoftReturnHome(getgenv()._tcoBlameHomeCF) end
					end)
				else
					if tcoClearUnderHold then tcoClearUnderHold() end
					if tcoSoftReturnHome and getgenv()._tcoBlameHomeCF then tcoSoftReturnHome(getgenv()._tcoBlameHomeCF) end
				end
				notifyC("tweenunder " .. tostring(on))
				return
			end
			if cmd == "abuse" then
				local nm = a2
				if not nm then notifyC("usage: abuse user") return end
				task.spawn(function()
					for _, x in ipairs({";mute "..nm, ";glitch "..nm, ";freeze "..nm, ";blind "..nm, ";dumb "..nm}) do
						pcall(function()
							local tcs = game:GetService("TextChatService")
							if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
								local ch = tcs.TextChannels and tcs.TextChannels:FindFirstChild("RBXGeneral")
								if ch then ch:SendAsync(x) return end
							end
							local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
							if ev and ev.SayMessageRequest then ev.SayMessageRequest:FireServer(x, "All") end
						end)
						task.wait(1.5)
					end
				end)
				notifyC("abusing " .. nm)
				return
			end
			if cmd == "control" or cmd == "drag" then
				local nm = a2
				if not nm or nm:lower()=="off" then
					getgenv()._tcoEnlightDrag = false
					notifyC("control off")
					return
				end
				getgenv()._tcoEnlightSel = nm
				getgenv()._tcoEnlightDrag = true
				local targetPlr = game.Players:FindFirstChild(nm)
				if not targetPlr then
					for _, pl in pairs(game.Players:GetPlayers()) do
						if pl.Name:lower()==nm:lower() or pl.DisplayName:lower()==nm:lower() then
							targetPlr = pl
							nm = pl.Name
							break
						end
					end
				end
				if not targetPlr then notifyC("player not found") getgenv()._tcoEnlightDrag = false return end
				task.spawn(function()
					local function say(m)
						pcall(function()
							local tcs = game:GetService("TextChatService")
							if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
								local ch = tcs.TextChannels and tcs.TextChannels:FindFirstChild("RBXGeneral")
								if ch then ch:SendAsync(m) return end
							end
							local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
							if ev and ev.SayMessageRequest then ev.SayMessageRequest:FireServer(m, "All") end
						end)
					end
					say(";invisible me")
					task.wait(1.5)
					if not getgenv()._tcoEnlightDrag then return end
					say(";mute me")
					task.wait(1.5)
					if not getgenv()._tcoEnlightDrag then return end
					say(";mute " .. nm)
					task.wait(1.5)
					if not getgenv()._tcoEnlightDrag then return end
					say(";speed " .. nm .. " 0")
					pcall(function()
						local char = localplr.Character
						if not char then return end
						for _, d in pairs(char:GetDescendants()) do
							if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 d.CanCollide = false end
						end
					end)
					local lastBring = 0
					while getgenv()._tcoEnlightDrag do
						pcall(function()
							local th = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
							local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
							local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
							local thum = targetPlr.Character and targetPlr.Character:FindFirstChildOfClass("Humanoid")
							if not th or not my or not hum then return end
							if thum then workspace.CurrentCamera.CameraSubject = thum end
							local move = hum.MoveDirection
							local look = th.CFrame.LookVector
							local front = th.Position + look * 3 + Vector3.new(0, 1, 0)
							if move.Magnitude > 0.08 then
								my.CFrame = CFrame.new(front + move.Unit * 6, front + look)
								if (tick() - lastBring) >= 1.5 then lastBring = tick() say(";bring " .. nm) end
							else
								my.CFrame = CFrame.new(front, front + look)
							end
						end)
						task.wait()
					end
					pcall(function()
						local char = localplr.Character
						if char then
							for _, d in pairs(char:GetDescendants()) do
								if d:IsA("BasePart") then d.LocalTransparencyModifier = 0 d.CanCollide = true end
							end
							local hum = char:FindFirstChildOfClass("Humanoid")
							if hum then workspace.CurrentCamera.CameraSubject = hum end
						end
						say(";visible me")
					end)
				end)
				notifyC("control " .. nm)
				return
			end
			if cmd == "sonic" or cmd == "temu" or cmd == "animation" then
				local on = onOff(true)
				getgenv()._tcoSonicOn = on
				if typeof(getgenv()._tcoSonicSetEnabled) == "function" then
					getgenv()._tcoSonicSetEnabled(on)
				end
				notifyC("sonic " .. tostring(on))
				return
			end
			if cmd == "spindash" or cmd == "spin" then
				if typeof(getgenv()._tcoSonicUse) == "function" then getgenv()._tcoSonicUse("spin") end
				return
			end
			if cmd == "sprint" or cmd == "temuoverride" then
				if typeof(getgenv()._tcoSonicUse) == "function" then getgenv()._tcoSonicUse("sprint") end
				return
			end
			if cmd == "surprise" or cmd == "surpriseattack" then
				if typeof(getgenv()._tcoSonicUse) == "function" then getgenv()._tcoSonicUse("tp") end
				return
			end
			if cmd == "tornado" and not a2 then
				if typeof(getgenv()._tcoSonicUse) == "function" then getgenv()._tcoSonicUse("tornado") end
				return
			end
			if cmd == "dash" then
				if typeof(getgenv()._tcoSonicUse) == "function" then getgenv()._tcoSonicUse("dash") end
				return
			end
			if cmd == "griefer" or cmd == "griefmoveset" then
				local on = onOff(true)
				if typeof(getgenv().tcoGrieferSetEnabled) == "function" then getgenv().tcoGrieferSetEnabled(on) end
				notifyC("griefer " .. tostring(on))
				return
			end
			if cmd == "griefmadness" or cmd == "madness" then
				if typeof(getgenv().tcoGrieferCast) == "function" then getgenv().tcoGrieferCast("madness") end
				return
			end
			if cmd == "griefscream" or cmd == "scream" then
				if typeof(getgenv().tcoGrieferCast) == "function" then getgenv().tcoGrieferCast("scream") end
				return
			end
			if cmd == "griefpunch" or cmd == "punch" then
				if typeof(getgenv().tcoGrieferCast) == "function" then getgenv().tcoGrieferCast("punch") end
				return
			end
			if cmd == "finalgrief" then
				if typeof(getgenv().tcoGrieferCast) == "function" then getgenv().tcoGrieferCast("final") end
				return
			end
			if cmd == "phantom" or cmd == "voidphantom" or cmd == "void" then
				local on = onOff(true)
				getgenv()._tcoPhantomOn = on
				if typeof(tcoPhantomSetEnabled) == "function" then tcoPhantomSetEnabled(on)
				elseif typeof(getgenv().tcoPhantomSetEnabled) == "function" then getgenv().tcoPhantomSetEnabled(on) end
				notifyC("void phantom " .. tostring(on))
				return
			end
			if cmd == "riftslash" or cmd == "slash" then
				if typeof(tcoPhantomCast) == "function" then tcoPhantomCast("slash")
				elseif typeof(getgenv().tcoPhantomCast) == "function" then getgenv().tcoPhantomCast("slash") end
				return
			end
			if cmd == "soulsnatch" or cmd == "snatch" then
				if typeof(tcoPhantomCast) == "function" then tcoPhantomCast("snatch")
				elseif typeof(getgenv().tcoPhantomCast) == "function" then getgenv().tcoPhantomCast("snatch") end
				return
			end
			if cmd == "barrage" or cmd == "phantombarrage" then
				if typeof(tcoPhantomCast) == "function" then tcoPhantomCast("barrage")
				elseif typeof(getgenv().tcoPhantomCast) == "function" then getgenv().tcoPhantomCast("barrage") end
				return
			end
			if cmd == "voiddomain" or cmd == "domain" then
				if typeof(tcoPhantomCast) == "function" then tcoPhantomCast("domain")
				elseif typeof(getgenv().tcoPhantomCast) == "function" then getgenv().tcoPhantomCast("domain") end
				return
			end
			if cmd == "joinhi" then
				getgenv()._tcoCfg = getgenv()._tcoCfg or {}
				local st = onOff(true)
				getgenv()._tcoCfg.joinHi = st
				if getgenv()._tcoSaveCfg then pcall(getgenv()._tcoSaveCfg) end
				notifyC("joinhi " .. tostring(st))
				return
			end
			if cmd == "joinhimsg" then
				getgenv()._tcoCfg = getgenv()._tcoCfg or {}
				local msg = table.concat({a2,a3,a4,a5,a6}, " "):gsub("^%s+",""):gsub("%s+$","")
				if msg == "" then notifyC("usage: joinhimsg hi {name}") return end
				getgenv()._tcoCfg.joinHiMsg = msg
				if getgenv()._tcoSaveCfg then pcall(getgenv()._tcoSaveCfg) end
				notifyC("joinhimsg set")
				return
			end
			if cmd == "joinfling" then
				getgenv()._tcoCfg = getgenv()._tcoCfg or {}
				local st = onOff(true)
				getgenv()._tcoCfg.joinFling = st
				if getgenv()._tcoSaveCfg then pcall(getgenv()._tcoSaveCfg) end
				notifyC("joinfling " .. tostring(st))
				return
			end
			if cmd == "joincmd" then
				getgenv()._tcoCfg = getgenv()._tcoCfg or {}
				local st = onOff(true)
				getgenv()._tcoCfg.joinCmd = st
				if getgenv()._tcoSaveCfg then pcall(getgenv()._tcoSaveCfg) end
				notifyC("joincmd " .. tostring(st))
				return
			end
			if cmd == "yellowtiny" or cmd == "yellowaura" then
				if typeof(setAuraCmd) == "function" then setAuraCmd("_tcoYellowTiny", a2, a3, "yellowtiny")
				else
					getgenv()._tcoYellowTiny = onOff(true)
					notifyC("yellowtiny " .. tostring(getgenv()._tcoYellowTiny))
				end
				return
			end
			if cmd == "aurasettings" then
				pcall(function()
					local old = game.CoreGui:FindFirstChild("TCOAuraSettings") or (localplr.PlayerGui and localplr.PlayerGui:FindFirstChild("TCOAuraSettings"))
					if old then old:Destroy() return end
					local sg = Instance.new("ScreenGui")
					sg.Name = "TCOAuraSettings"
					sg.ResetOnSpawn = false
					pcall(function() sg.Parent = game.CoreGui end)
					if not sg.Parent then sg.Parent = localplr.PlayerGui end
					local f = Instance.new("Frame")
					f.Size = UDim2.new(0, 260, 0, 220)
					f.Position = UDim2.new(0.5, -130, 0.35, 0)
					f.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
					f.Active = true
					f.Draggable = true
					f.Parent = sg
					Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
					local title = Instance.new("TextLabel")
					title.Size = UDim2.new(1, -60, 0, 28)
					title.Position = UDim2.new(0, 10, 0, 4)
					title.BackgroundTransparency = 1
					title.Text = "Aura Settings"
					title.TextColor3 = Color3.new(1,1,1)
					title.Font = Enum.Font.GothamBold
					title.TextSize = 15
					title.TextXAlignment = Enum.TextXAlignment.Left
					title.Parent = f
					local minB = Instance.new("TextButton")
					minB.Size = UDim2.new(0, 28, 0, 28)
					minB.Position = UDim2.new(1, -60, 0, 4)
					minB.Text = "-"
					minB.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
					minB.TextColor3 = Color3.new(1,1,1)
					minB.Parent = f
					Instance.new("UICorner", minB).CornerRadius = UDim.new(0, 6)
					local closeB = Instance.new("TextButton")
					closeB.Size = UDim2.new(0, 28, 0, 28)
					closeB.Position = UDim2.new(1, -28, 0, 4)
					closeB.Text = "X"
					closeB.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
					closeB.TextColor3 = Color3.new(1,1,1)
					closeB.Parent = f
					Instance.new("UICorner", closeB).CornerRadius = UDim.new(0, 6)
					local body = Instance.new("Frame")
					body.Size = UDim2.new(1, -16, 1, -40)
					body.Position = UDim2.new(0, 8, 0, 36)
					body.BackgroundTransparency = 1
					body.Parent = f
					local y = 0
					local function addToggle(name, key, onOffExtra)
						local b = Instance.new("TextButton")
						b.Size = UDim2.new(1, 0, 0, 32)
						b.Position = UDim2.new(0, 0, 0, y)
						y = y + 36
						b.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
						b.TextColor3 = Color3.new(1,1,1)
						b.Font = Enum.Font.Gotham
						b.TextSize = 13
						b.Parent = body
						Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
						local function refresh()
							b.Text = name .. (getgenv()[key] and "  [ON]" or "  [OFF]")
						end
						refresh()
						b.MouseButton1Click:Connect(function()
							getgenv()[key] = not getgenv()[key]
							if onOffExtra then onOffExtra(getgenv()[key]) end
							refresh()
						end)
					end
										addToggle("Safe mode", "_tcoSafeMode")
					addToggle("Invisible mode", "_tcoInvisMode", function(v)
						if v then getgenv()._tcoUG = false tcoSaveHome()
						else tcoStopTargetMode() end
					end)
					local tb = Instance.new("TextBox")
					tb.Size = UDim2.new(1, 0, 0, 32)
					tb.Position = UDim2.new(0, 0, 0, y)
					tb.PlaceholderText = "Aura range (num)"
					tb.Text = tostring(getgenv()._tcoAuraRange or 35)
					tb.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
					tb.TextColor3 = Color3.new(1,1,1)
					tb.Font = Enum.Font.Gotham
					tb.Parent = body
					Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
					tb.FocusLost:Connect(function()
						local n = tonumber(tb.Text)
						if n and n > 0 then getgenv()._tcoAuraRange = n end
					end)
					local minimized = false
					minB.MouseButton1Click:Connect(function()
						minimized = not minimized
						body.Visible = not minimized
						f.Size = minimized and UDim2.new(0, 260, 0, 36) or UDim2.new(0, 260, 0, 220)
					end)
					closeB.MouseButton1Click:Connect(function() sg:Destroy() end)
				end)
				notifyC("aurasettings")
				return
			end
if cmd == "aurarange" then
				local n = tonumber(a2)
				if n then getgenv()._tcoAuraRange = n notifyC("aurarange "..n) end
				return
			end
			local antiMap = {
				antitoxify = "antiToxify", antiblind = "antiBlind", antiglitch = "antiGlitch",
				antifreeze = "antiFreeze", antijail = "antiJail", antistun = "antiStun",
				antiinvis = "antiInvis", antivoid = "antiVoid", antisit = "antiSit",
				antiafk = "antiAFK", antimyopic = "antiMyopic", antiglow = "antiGlow",
				antifog = "antiFog", antismoke = "antiSmoke",
			}
			antiMap.antiglow = "antiGlow"
			if antiMap[cmd] then
				getgenv()._tcoAnti = getgenv()._tcoAnti or {}
				getgenv()._tcoAnti[antiMap[cmd]] = onOff(true)
				notifyC(cmd .. " " .. tostring(getgenv()._tcoAnti[antiMap[cmd]]) .. " (use anti GUI for full effect)")
				return
			end
			if cmd == "spamr6" then
				getgenv()._tcoAnti = getgenv()._tcoAnti or {}
				getgenv()._tcoAnti.spamR6 = onOff(true)
				notifyC("spamr6 " .. tostring(getgenv()._tcoAnti.spamR6))
				return
			end
			if cmd == "equipall" then
				pcall(function()
					local char = localplr.Character
					local hum = hum()
					for _, t in pairs(localplr.Backpack:GetChildren()) do
						if t:IsA("Tool") and hum then hum:EquipTool(t) task.wait(0.05) end
					end
				end)
				notifyC("equipall")
				return
			end
			if cmd == "dropall" then
				pcall(function()
					local char = localplr.Character
					if not char then return end
					for _, t in pairs(char:GetChildren()) do
						if t:IsA("Tool") then t.Parent = workspace end
					end
					for _, t in pairs(localplr.Backpack:GetChildren()) do
						if t:IsA("Tool") then t.Parent = workspace end
					end
				end)
				notifyC("dropall")
				return
			end
			if cmd == "spamequip" then
				getgenv()._tcoSpamEquip = onOff(true)
				if getgenv()._tcoSpamEquip then
					task.spawn(function()
						while getgenv()._tcoSpamEquip do
							pcall(function()
								local hum = hum()
								for _, t in pairs(localplr.Backpack:GetChildren()) do
									if t:IsA("Tool") and hum then hum:EquipTool(t) end
								end
							end)
							task.wait(0.1)
						end
					end)
				end
				notifyC("spamequip " .. tostring(getgenv()._tcoSpamEquip))
				return
			end
			if cmd == "autodrop" then
				getgenv()._tcoAutoDrop = onOff(true)
				notifyC("autodrop " .. tostring(getgenv()._tcoAutoDrop))
				return
			end
			if cmd == "say" or cmd == "chat" then
				if rest ~= "" then chat(rest) end
				return
			end
			if cmd == "spam" then
				if a2 and a2:lower() == "off" then
					getgenv()._tcoCmdSpam = false
					notifyC("spam off")
					return
				end
				local msg = rest
				local delay = 1
				if tonumber(a2) then delay = tonumber(a2) msg = table.concat(args, " ", 3) end
				getgenv()._tcoCmdSpam = true
				task.spawn(function()
					while getgenv()._tcoCmdSpam do
						if msg and msg ~= "" then chat(msg) end
						task.wait(delay)
					end
				end)
				notifyC("spam on")
				return
			end
			if cmd == "hide" then
				getgenv()._tcoHideChat = onOff(true)
				notifyC("hide chat prefix " .. tostring(getgenv()._tcoHideChat) .. " — spam/cmds add ; when ON")
				return
			end
			if cmd == "spamblocks" or cmd == "spamblock" then
				local on = onOff(true)
				pcall(function() spmbl = on end)
				if on then
					task.spawn(function()
						while spmbl do
							pcall(function()
								local char = localplr.Character
								if not char or not char:FindFirstChild("HumanoidRootPart") then return end
								if not char:FindFirstChild("Build") then
									local b = localplr.Backpack:FindFirstChild("Build")
									if b then b.Parent = char end
								end
								local tool = char:FindFirstChild("Build")
								if not tool then return end
								local s = "normal"
								local pos = char.HumanoidRootPart.Position - Vector3.new(0, 1.5, 0)
								if tool:FindFirstChild("origevent") then
									tool.origevent:Invoke(workspace.Terrain, Enum.NormalId.Top, pos, s)
								elseif tool.Script and tool.Script:FindFirstChild("Event") then
									tool.Script.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, pos, s)
								end
							end)
							task.wait(0.05)
						end
					end)
				end
				notifyC("spamblocks " .. tostring(on))
				return
			end
			if cmd == "spamsigns" or cmd == "spamsign" then
				local on = onOff(true)
				pcall(function() spmsi = on end)
				if on then
					task.spawn(function()
						while spmsi do
							pcall(function()
								local char = localplr.Character
								if not char or not char:FindFirstChild("HumanoidRootPart") then return end
								if not char:FindFirstChild("Sign") then
									local s = localplr.Backpack:FindFirstChild("Sign")
									if s then s.Parent = char end
								end
								local tool = char:FindFirstChild("Sign")
								if not tool then return end
								local pos = char.HumanoidRootPart.Position - Vector3.new(0, 1.5, 0)
								if tool:FindFirstChild("origevent") then
									tool.origevent:Invoke(workspace.Terrain, Enum.NormalId.Top, pos, "normal")
								elseif tool.Script and tool.Script:FindFirstChild("Event") then
									tool.Script.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, pos, "normal")
								end
							end)
							task.wait(0.08)
						end
					end)
				end
				notifyC("spamsigns " .. tostring(on))
				return
			end
			if cmd == "toxify" and a2 then
				local p = findPlr(a2)
				if p then chat("toxify " .. p.Name) notifyC("toxify " .. p.Name) return end
			end
			if cmd == "gearme" then
				local id = a2 or ""
				if id ~= "" then chat("gear me " .. id) notifyC("gear me " .. id) end
				return
			end
			if cmd == "gearall" then
				local id = a2 or ""
				if id ~= "" then chat("gear all " .. id) notifyC("gear all " .. id) end
				return
			end
			if cmd == "gear" then
				if a2 == "me" or a2 == "all" then
					local id = a3 or ""
					if id ~= "" then chat("gear " .. a2 .. " " .. id) notifyC("gear " .. a2 .. " " .. id) end
				elseif a2 then
					chat("gear me " .. a2)
					notifyC("gear me " .. a2)
				end
				return
			end
			if cmd == "autopickup" or cmd == "pickup" then
				local on = onOff(true)
				pcall(function() pickuptools = on end)
				getgenv()._tcoAutoPickup = on
				notifyC("autopickup " .. tostring(on))
				return
			end
			if cmd == "spamequiptools" then
				local on = onOff(true)
				pcall(function()
				end)
				getgenv()._tcoSpamEquip = on
				notifyC("spamequiptools " .. tostring(on))
				return
			end
			if cmd == "griefdetect" or cmd == "detectdelete" then
				pcall(function()
					if typeof(detectDelete) == "function" then detectDelete() end
				end)
				notifyC("griefdetect (delete) fired if available")
				return
			end
			if cmd == "paintdetect" then
				notifyC("paintdetect - use grief detection tab for full UI")
				return
			end
			if cmd == "spamdetect" then
				notifyC("spamdetect - use grief detection tab")
				return
			end
			if cmd == "exploitdetect" then
				notifyC("exploitdetect - use grief detection tab")
				return
			end
			if cmd == "detectall" then
				notifyC("detectall - enable all in grief detection tab")
				return
			end
			if cmd == "detectoff" then
				notifyC("detectoff - turn off in grief detection tab")
				return
			end
			if cmd == "whitelist" then
				notifyC("whitelist - use grief detection tab")
				return
			end
			if cmd == "spychat" then
				local on = onOff(true)
				pcall(function() spychat = on end)
				notifyC("spychat " .. tostring(on))
				return
			end
			if cmd == "copybb" or cmd == "boomboxid" then
				pcall(function()
					if bbid and bbid ~= "" then
						setclipboard(tostring(bbid))
						notifyC("copied boombox id " .. tostring(bbid))
					else
						notifyC("no boombox selected")
					end
				end)
				return
			end
			if cmd == "loadanti" or cmd == "antigui" then
				pcall(function()
					if typeof(loadAntiGui) == "function" then loadAntiGui() notifyC("anti gui loaded")
					else notifyC("open anti tab > Load Anti GUI") end
				end)
				return
			end
			if cmd == "loadspam" or cmd == "dualspam" then
				pcall(function()
					if typeof(loadDualSpamGui) == "function" then loadDualSpamGui() notifyC("2 cmd spam gui")
					else notifyC("use commands tab button") end
				end)
				return
			end
			if cmd == "goto" then
				local p = findPlr(a2)
				if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and hrp() then
					hrp().CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
					notifyC("goto " .. p.Name)
				else notifyC("no player") end
				return
			end
			if cmd == "bring" then
				local p = findPlr(a2)
				if p then chat("bring " .. p.Name) notifyC("bring " .. p.Name) end
				return
			end
			if cmd == "jail" then
				local p = findPlr(a2)
				if p then chat("jail " .. p.Name) notifyC("jail " .. p.Name) end
				return
			end
			if cmd == "unjail" then
				local p = findPlr(a2)
				if p then chat("unjail " .. p.Name) notifyC("unjail " .. p.Name) end
				return
			end
			if cmd == "admin" or cmd == "flingadmin" then
				task.spawn(function()
					local found = 0
					for _, p in pairs(game.Players:GetPlayers()) do
						if p ~= localplr then
							local isAdmin = false
							pcall(function()
								if p.Neutral == false then isAdmin = true end
							end)
							pcall(function()
								if p:GetAttribute("Arken") == true then isAdmin = true end
							end)
							if isAdmin then
								found = found + 1
								pcall(function() runCmd("fling " .. p.Name) end)
								notifyC("fling admin " .. p.Name)
								task.wait(0.35)
							end
						end
					end
					if found == 0 then notifyC("no admin found") end
				end)
				return
			end
			if cmd == "tpadmin" then
				for _, p in pairs(game.Players:GetPlayers()) do
					if p ~= localplr and p.Neutral == false and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and hrp() then
						hrp().CFrame = p.Character.HumanoidRootPart.CFrame
						notifyC("tp admin " .. p.Name)
						return
					end
				end
				notifyC("no admin")
				return
			end
			if cmd == "esp" then
				local on = onOff(true)
				if typeof(getgenv()._tcoSetESP) == "function" then
					getgenv()._tcoSetESP(on)
					notifyC("esp " .. tostring(on))
					return
				end
				getgenv()._tcoESP = on
				if on then
					task.spawn(function()
						while getgenv()._tcoESP do
							pcall(function()
								for _, p in pairs(game.Players:GetPlayers()) do
									if p ~= localplr and p.Character then
										if not p.Character:FindFirstChild("TCOESP") then
											local h = Instance.new("Highlight")
											h.Name = "TCOESP"
											h.FillTransparency = 0.7
											h.Parent = p.Character
										end
									end
								end
							end)
							task.wait(1)
						end
						for _, p in pairs(game.Players:GetPlayers()) do
							pcall(function()
								if p.Character and p.Character:FindFirstChild("TCOESP") then
									p.Character.TCOESP:Destroy()
								end
							end)
						end
					end)
				end
				notifyC("esp " .. tostring(on))
				return
			end
			if cmd == "spamdelay" then
				local n = tonumber(a2)
				if n then getgenv()._tcoSpamDelay = n notifyC("spamdelay " .. n) end
				return
			end
			if cmd == "mainui" or cmd == "gui" then
				pcall(function()
					local sg = game.CoreGui:FindFirstChild("TCOSettingsUI")
					if sg then sg.Enabled = not sg.Enabled notifyC("main ui " .. tostring(sg.Enabled)) end
				end)
				return
			end
			if cmd == "noclip" then
				getgenv()._tcoNoclip = onOff(true)
				if getgenv()._tcoNoclip then
					task.spawn(function()
						while getgenv()._tcoNoclip do
							pcall(function()
								local char = localplr.Character
								if char then
									for _, p in pairs(char:GetDescendants()) do
										if p:IsA("BasePart") then p.CanCollide = false end
									end
								end
							end)
							task.wait(0.1)
						end
					end)
				end
				notifyC("noclip " .. tostring(getgenv()._tcoNoclip))
				return
			end
			notifyC("unknown: " .. cmd .. " (type cmds)")
		end
		local csg = Instance.new("ScreenGui")
		csg.Name = "TCOCmdGui"
		csg.ResetOnSpawn = false
		csg.DisplayOrder = 150
		pcall(function() csg.Parent = game.CoreGui end)
		if not csg.Parent then csg.Parent = localplr:WaitForChild("PlayerGui") end
		local mainF = Instance.new("Frame")
		mainF.Name = "CmdMain"
		mainF.Size = UDim2.new(0, 340, 0, 160)
		mainF.Position = UDim2.new(0.5, -170, 0.75, 0)
		mainF.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
		mainF.BorderSizePixel = 0
		mainF.Active = true
		mainF.Parent = csg
		Instance.new("UICorner", mainF).CornerRadius = UDim.new(0, 10)
		do
			local UIS = game:GetService("UserInputService")
			local function makeHandle(anchor, pos)
				local h = Instance.new("TextButton")
				h.Size = UDim2.new(0, 18, 0, 18)
				h.AnchorPoint = anchor
				h.Position = pos
				h.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
				h.BackgroundTransparency = 0.3
				h.Text = ""
				h.ZIndex = 50
				h.Parent = mainF
				Instance.new("UICorner", h).CornerRadius = UDim.new(1, 0)
				return h
			end
			local tl = makeHandle(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0))
			local br = makeHandle(Vector2.new(1, 1), UDim2.new(1, 0, 1, 0))
			local resizing, mode, startIn, startSize, startPos
			local function begin(m, input)
				resizing = true
				mode = m
				startIn = input.Position
				startSize = mainF.AbsoluteSize
				startPos = mainF.AbsolutePosition
			end
			tl.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then begin("tl", input) end
			end)
			br.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then begin("br", input) end
			end)
			UIS.InputChanged:Connect(function(input)
				if not resizing then return end
				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
				local d = input.Position - startIn
				if mode == "br" then
					mainF.Size = UDim2.new(0, math.max(220, startSize.X + d.X), 0, math.max(120, startSize.Y + d.Y))
				else
					local nw = math.max(220, startSize.X - d.X)
					local nh = math.max(120, startSize.Y - d.Y)
					mainF.Size = UDim2.new(0, nw, 0, nh)
					mainF.Position = UDim2.new(0, startPos.X + (startSize.X - nw), 0, startPos.Y + (startSize.Y - nh))
				end
			end)
			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
			end)
		end
		local top = Instance.new("Frame")
		top.Size = UDim2.new(1, 0, 0, 32)
		top.BackgroundColor3 = Color3.fromRGB(36, 38, 46)
		top.BorderSizePixel = 0
		top.Parent = mainF
		Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)
		local topFix = Instance.new("Frame")
		topFix.Size = UDim2.new(1, 0, 0, 12)
		topFix.Position = UDim2.new(0, 0, 1, -12)
		topFix.BackgroundColor3 = Color3.fromRGB(36, 38, 46)
		topFix.BorderSizePixel = 0
		topFix.Parent = top
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -80, 1, 0)
		title.Position = UDim2.new(0, 12, 0, 0)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextColor3 = Color3.fromRGB(235, 235, 240)
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = "guy hub commands"
		title.Parent = top
		local minBtn = Instance.new("TextButton")
		minBtn.Size = UDim2.new(0, 28, 0, 24)
		minBtn.Position = UDim2.new(1, -64, 0.5, -12)
		minBtn.BackgroundColor3 = Color3.fromRGB(50, 52, 60)
		minBtn.Text = "-"
		minBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
		minBtn.Font = Enum.Font.GothamBold
		minBtn.TextSize = 16
		minBtn.Parent = top
		Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 28, 0, 24)
		closeBtn.Position = UDim2.new(1, -32, 0.5, -12)
		closeBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 50)
		closeBtn.Text = "X"
		closeBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 14
		closeBtn.Parent = top
		Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
		local hint = Instance.new("TextLabel")
		hint.Size = UDim2.new(1, -16, 0, 36)
		hint.Position = UDim2.new(0, 8, 0, 38)
		hint.BackgroundTransparency = 1
		hint.Font = Enum.Font.Gotham
		hint.TextSize = 12
		hint.TextColor3 = Color3.fromRGB(160, 160, 170)
		hint.TextXAlignment = Enum.TextXAlignment.Left
		hint.TextWrapped = true
		hint.Text = "Prefix chat or type below. :cmds for list. Works without main GUI."
		hint.Parent = mainF
		local input = Instance.new("TextBox")
		input.Size = UDim2.new(1, -16, 0, 36)
		input.Position = UDim2.new(0, 8, 0, 80)
		input.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
		input.Font = Enum.Font.Gotham
		input.TextSize = 15
		input.TextColor3 = Color3.fromRGB(255, 255, 255)
		input.PlaceholderText = (getgenv()._tcoPrefix or ":") .. "command"
		input.Text = ""
		input.ClearTextOnFocus = false
		input.Parent = mainF
		Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
		local runBtn = Instance.new("TextButton")
		runBtn.Size = UDim2.new(1, -16, 0, 30)
		runBtn.Position = UDim2.new(0, 8, 0, 122)
		runBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 80)
		runBtn.Text = "Run"
		runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		runBtn.Font = Enum.Font.GothamBold
		runBtn.TextSize = 14
		runBtn.Parent = mainF
		Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0, 6)
		local function doRun()
			runCmd(input.Text)
			input.Text = ""
			input.PlaceholderText = (getgenv()._tcoPrefix or ":") .. "command"
		end
		runBtn.MouseButton1Click:Connect(doRun)
		input.FocusLost:Connect(function(enter)
			if enter then doRun() end
		end)
		local dragging, d0, p0 = false, nil, nil
		top.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				d0 = inp.Position
				p0 = mainF.Position
			end
		end)
		game:GetService("UserInputService").InputChanged:Connect(function(inp)
			if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local d = inp.Position - d0
				mainF.Position = UDim2.new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
			end
		end)
		game:GetService("UserInputService").InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		local miniSg = Instance.new("ScreenGui")
		miniSg.Name = "TCOCmdMini"
		miniSg.ResetOnSpawn = false
		miniSg.DisplayOrder = 151
		miniSg.Enabled = false
		pcall(function() miniSg.Parent = game.CoreGui end)
		if not miniSg.Parent then miniSg.Parent = localplr.PlayerGui end
		local miniBtn = Instance.new("TextButton")
		miniBtn.Size = UDim2.new(0, 48, 0, 48)
		miniBtn.Position = UDim2.new(0, 16, 0.62, 0)
		miniBtn.BackgroundColor3 = Color3.fromRGB(36, 38, 46)
		miniBtn.Text = ":"
		miniBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
		miniBtn.Font = Enum.Font.GothamBold
		miniBtn.TextSize = 20
		miniBtn.Parent = miniSg
		Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1, 0)
		minBtn.MouseButton1Click:Connect(function()
			mainF.Visible = false
			miniSg.Enabled = true
		end)
		miniBtn.MouseButton1Click:Connect(function()
			mainF.Visible = true
			miniSg.Enabled = false
		end)
		closeBtn.MouseButton1Click:Connect(function()
			for _, conn in ipairs(getgenv()._tcoCmdConnections or {}) do
				if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
			end
			getgenv()._tcoCmdConnections = {}
			csg:Destroy()
			miniSg:Destroy()
			getgenv()._tcoLoadCmds = false
		end)
		notifyC("Commands GUI ready - prefix " .. (getgenv()._tcoPrefix or ":"))
		local cmdConnections = getgenv()._tcoCmdConnections or {}
		getgenv()._tcoCmdConnections = cmdConnections
		local lastChatCommand, lastChatCommandAt = nil, 0
		local function handleChatCommand(t)
			t = tostring(t or "")
			local pref = getgenv()._tcoPrefix or ":"
			if t:sub(1, #pref) ~= pref then return end
			local now = tick()
			if t == lastChatCommand and now - lastChatCommandAt < 0.20 then return end
			lastChatCommand, lastChatCommandAt = t, now
			runCmd(t)
		end
		pcall(function()
			local tcs = game:GetService("TextChatService")
			if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
				table.insert(cmdConnections, tcs.SendingMessage:Connect(function(m)
					if m.TextSource and m.TextSource.UserId == localplr.UserId then
						handleChatCommand(m.Text)
					end
				end))
			else
				table.insert(cmdConnections, localplr.Chatted:Connect(handleChatCommand))
			end
		end)
	end)
end
getgenv()._tcoWhitelist = getgenv()._tcoWhitelist or {}
getgenv()._tcoStand = getgenv()._tcoStand or {
	userId = nil,
	active = false,
	model = nil,
	track = nil,
	range = 35,
	deleteAura = false,
	barrage = false,
	barrageFling = false,
}
task.spawn(function()
	while true do
		task.wait(0.4)
		pcall(function()
			if getgenv()._guyHubThemeName ~= "Rainbow" then return end
			local h = (tick() * 0.15) % 1
			local c = Color3.fromHSV(h, 0.55, 0.35)
			local c2 = Color3.fromHSV((h + 0.08) % 1, 0.5, 0.45)
			local sg = game.CoreGui:FindFirstChild("TCOSettingsUI")
			if not sg then return end
			for _, d in pairs(sg:GetDescendants()) do
				if d:IsA("Frame") and d.Name == "Main" then
					d.BackgroundColor3 = c
				elseif d:IsA("TextButton") and d.Parent and d.Parent.Name == "TabBar" then
				end
			end
		end)
	end
end)
Players = game:GetService("Players")
getgenv()._tcoCloseMiniGames = function()
	pcall(function()
		for _, parent in ipairs({game.CoreGui, game.Players.LocalPlayer:FindFirstChild("PlayerGui")}) do
			if parent then
				local g = parent:FindFirstChild("TCOMiniGames")
				if g then g:Destroy() end
			end
		end
		for _, s in pairs(game:GetService("SoundService"):GetChildren()) do
			if s:IsA("Sound") and (s.Name == "TCOMiniMusic" or s.Name == "TCOMiniSfx") then
				pcall(function() s:Stop() s:Destroy() end)
			end
		end
	end)
end
getgenv()._tcoOpenMiniGames = function()
	getgenv()._tcoCloseMiniGames()
	local CoreGui = game:GetService("CoreGui")
	local UIS = game:GetService("UserInputService")
	local SoundService = game:GetService("SoundService")
	local lp = game.Players.LocalPlayer
	local sg = Instance.new("ScreenGui")
	sg.Name = "TCOMiniGames"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 200
	sg.IgnoreGuiInset = true
	pcall(function() sg.Parent = CoreGui end)
	if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end
	local function playSfx(id, vol)
		task.spawn(function()
			pcall(function()
				local s = Instance.new("Sound")
				s.Name = "TCOMiniSfx"
				s.SoundId = "rbxassetid://" .. tostring(id or 6895079853)
				s.Volume = vol or 0.6
				s.Parent = SoundService
				s:Play()
				task.delay(2.5, function() pcall(function() s:Destroy() end) end)
			end)
		end)
	end
	pcall(function()
		local music = Instance.new("Sound")
		music.Name = "TCOMiniMusic"
		music.SoundId = "rbxassetid://1844702927"
		music.Volume = 0.28
		music.Looped = true
		music.Parent = SoundService
		music:Play()
	end)
	local handle = Instance.new("TextButton")
	handle.Size = UDim2.new(0, 44, 0, 44)
	handle.Position = UDim2.new(0, 10, 0.55, 0)
	handle.BackgroundColor3 = Color3.fromRGB(29, 34, 44)
	handle.Text = "ARCADE"
	handle.TextColor3 = Color3.fromRGB(230, 230, 235)
	handle.Font = Enum.Font.GothamBold
	handle.TextSize = 10
	handle.ZIndex = 10
	handle.Parent = sg
	Instance.new("UICorner", handle).CornerRadius = UDim.new(0, 10)
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 300, 0, 340)
	panel.Position = UDim2.new(0, 66, 0.55, -170)
	panel.BackgroundColor3 = Color3.fromRGB(18, 21, 28)
	panel.ZIndex = 5
	panel.Parent = sg
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)
	local top = Instance.new("TextButton")
	top.Size = UDim2.new(1, 0, 0, 30)
	top.BackgroundColor3 = Color3.fromRGB(31, 39, 52)
	top.Text = "  ARCADE / MINI GAMES"
	top.TextColor3 = Color3.new(1,1,1)
	top.Font = Enum.Font.GothamBold
	top.TextSize = 12
	top.TextXAlignment = Enum.TextXAlignment.Left
	top.ZIndex = 6
	top.Parent = panel
	Instance.new("UICorner", top).CornerRadius = UDim.new(0, 8)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.Position = UDim2.new(1, -28, 0, 2)
	closeBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.ZIndex = 7
	closeBtn.Parent = top
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -14, 1, -44)
	list.Position = UDim2.new(0, 7, 0, 38)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 3
	list.CanvasSize = UDim2.new(0, 0, 0, 900)
	list.ZIndex = 6
	list.Parent = panel
	Instance.new("UIListLayout", list).Padding = UDim.new(0, 4)
	local play = Instance.new("Frame")
	play.Size = UDim2.new(1, -14, 1, -44)
	play.Position = UDim2.new(0, 7, 0, 38)
	play.BackgroundColor3 = Color3.fromRGB(11, 14, 19)
	play.Visible = false
	play.ZIndex = 6
	play.ClipsDescendants = true
	play.Parent = panel
	Instance.new("UICorner", play).CornerRadius = UDim.new(0, 6)
	local gTitle = Instance.new("TextLabel")
	gTitle.Size = UDim2.new(1, -8, 0, 22)
	gTitle.Position = UDim2.new(0, 4, 0, 2)
	gTitle.BackgroundTransparency = 1
	gTitle.TextColor3 = Color3.fromRGB(255, 214, 92)
	gTitle.Font = Enum.Font.GothamBold
	gTitle.TextSize = 12
	gTitle.TextXAlignment = Enum.TextXAlignment.Left
	gTitle.ZIndex = 7
	gTitle.Parent = play
	local scoreL = Instance.new("TextLabel")
	scoreL.Size = UDim2.new(1, -8, 0, 18)
	scoreL.Position = UDim2.new(0, 4, 0, 22)
	scoreL.BackgroundTransparency = 1
	scoreL.Text = "Score: 0"
	scoreL.TextColor3 = Color3.fromRGB(120, 220, 255)
	scoreL.Font = Enum.Font.Gotham
	scoreL.TextSize = 12
	scoreL.TextXAlignment = Enum.TextXAlignment.Left
	scoreL.ZIndex = 7
	scoreL.Parent = play
	local field = Instance.new("Frame")
	field.Size = UDim2.new(1, -8, 1, -78)
	field.Position = UDim2.new(0, 4, 0, 42)
	field.BackgroundColor3 = Color3.fromRGB(12, 17, 25)
	field.ClipsDescendants = true
	field.ZIndex = 7
	field.Parent = play
	Instance.new("UICorner", field).CornerRadius = UDim.new(0, 4)
	local btnRow = Instance.new("Frame")
	btnRow.Size = UDim2.new(1, -8, 0, 28)
	btnRow.Position = UDim2.new(0, 4, 1, -32)
	btnRow.BackgroundTransparency = 1
	btnRow.ZIndex = 7
	btnRow.Parent = play
	local backBtn = Instance.new("TextButton")
	backBtn.Size = UDim2.new(0.48, -2, 1, 0)
	backBtn.BackgroundColor3 = Color3.fromRGB(50, 52, 60)
	backBtn.Text = "Menu"
	backBtn.TextColor3 = Color3.new(1,1,1)
	backBtn.Font = Enum.Font.Gotham
	backBtn.TextSize = 12
	backBtn.ZIndex = 8
	backBtn.Parent = btnRow
	Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 5)
	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(0.48, -2, 1, 0)
	resetBtn.Position = UDim2.new(0.52, 0, 0, 0)
	resetBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 160)
	resetBtn.Text = "Restart"
	resetBtn.TextColor3 = Color3.new(1,1,1)
	resetBtn.Font = Enum.Font.Gotham
	resetBtn.TextSize = 12
	resetBtn.ZIndex = 8
	resetBtn.Parent = btnRow
	Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 5)
	local function makeDrag(guiObj, moveTarget)
		moveTarget = moveTarget or guiObj
		local dragging, startIn, startPos
		guiObj.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				startIn = input.Position
				startPos = moveTarget.Position
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - startIn
				moveTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end
	makeDrag(top, panel)
	makeDrag(handle, handle)
	local gen = 0
	local score = 0
	local currentStart = nil
	local function clearField()
		for _, ch in pairs(field:GetChildren()) do
			if not ch:IsA("UICorner") then ch:Destroy() end
		end
	end
	local function setScore(n)
		score = n
		scoreL.Text = "Score: " .. tostring(score)
	end
	local function diff()
		return 1 + math.min(score, 80) * 0.028
	end
	local function die(msg)
		gen = gen + 1
		gTitle.Text = msg or "You died - Restart"
		playSfx(138081500, 0.55)
	end
	local function startFruit()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🍎 FRUIT RUN  |  Avoid 💣"
		clearField()
		local fruits = {"🍎","🍊","🍋","🍇","🍓","🍑","🍒","🥝"}
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent do
				local fw = math.max(field.AbsoluteSize.X, 100)
				local fh = math.max(field.AbsoluteSize.Y, 100)
				local isBomb = math.random() < math.clamp(0.12 + diff() * 0.04, 0.12, 0.42)
				local f = Instance.new("TextButton")
				f.Size = UDim2.new(0, 42, 0, 42)
				f.Position = UDim2.new(0, math.random(4, math.max(5, fw - 46)), 0, fh + 4)
				f.BackgroundColor3 = isBomb and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(60, 40, 40)
				f.Text = isBomb and "💣" or fruits[math.random(1, #fruits)]
				f.TextSize = 20
				f.ZIndex = 9
				f.Parent = field
				Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
				local alive = true
				local function onHit()
					if not alive or gen ~= my then return end
					alive = false
					if isBomb then
						playSfx(138081500, 0.7)
						f:Destroy()
						die("💣 BOOM!  |  RESTART")
						return
					end
					setScore(score + 1)
					playSfx(6895079853, 0.5)
					f:Destroy()
				end
				f.Activated:Connect(onHit)
				local y = fh + 4
				local steps = math.max(18, math.floor(42 / diff()))
				for _ = 1, steps do
					if not f.Parent or gen ~= my then break end
					y = y - (fh + 50) / steps
					f.Position = UDim2.new(0, f.Position.X.Offset, 0, y)
					task.wait(math.clamp(0.034 / diff(), 0.014, 0.034))
				end
				if f.Parent then f:Destroy() end
				task.wait(math.clamp(0.45 / diff(), 0.18, 0.45))
			end
		end)
	end
	local function startFlappy()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🐦 FLAPPY BLOCK  |  Tap to flap"
		clearField()
		local bird = Instance.new("TextLabel")
		bird.Size = UDim2.new(0, 28, 0, 28)
		bird.Position = UDim2.new(0, 24, 0.4, 0)
		bird.BackgroundColor3 = Color3.fromRGB(50, 50, 30)
		bird.Text = "🐦"
		bird.TextSize = 18
		bird.ZIndex = 9
		bird.Parent = field
		Instance.new("UICorner", bird).CornerRadius = UDim.new(0, 6)
		local vy = 0
		local dead = false
		local pipes = {}
		local function flap()
			if dead or gen ~= my then return end
			vy = -3.2
			playSfx(6895079853, 0.28)
		end
		field.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				flap()
			end
		end)
		task.spawn(function()
			local t = 0
			while gen == my and play.Visible and sg.Parent and not dead do
				t = t + 1
				local fh = math.max(field.AbsoluteSize.Y, 80)
				local fw = math.max(field.AbsoluteSize.X, 80)
				vy = vy + (0.16 + diff() * 0.03)
				if vy > (3.2 + diff() * 0.35) then vy = 3.2 + diff() * 0.35 end
				local ny = bird.Position.Y.Offset + vy
				if ny < 0 then ny = 0; vy = 0 end
				if ny > fh - 28 then
					dead = true
					die("🐦 CRASHED  |  RESTART")
					break
				end
				bird.Position = UDim2.new(0, 24, 0, ny)
				if t % math.max(40, math.floor(75 / diff())) == 0 then
					local gapY = math.random(16, math.max(24, fh - 120))
					local gapSize = math.max(52, math.floor(82 - diff() * 6))
					local top = Instance.new("TextLabel")
					top.Size = UDim2.new(0, 26, 0, gapY)
					top.Position = UDim2.new(0, fw, 0, 0)
					top.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
					top.Text = ""
					top.ZIndex = 8
					top.Parent = field
					local bot = Instance.new("TextLabel")
					local botY = gapY + gapSize
					local botH = math.max(12, fh - botY)
					bot.Size = UDim2.new(0, 26, 0, botH)
					bot.Position = UDim2.new(0, fw, 0, botY)
					bot.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
					bot.Text = ""
					bot.ZIndex = 8
					bot.Parent = field
					table.insert(pipes, {top = top, bot = bot, scored = false})
				end
				for i = #pipes, 1, -1 do
					local p = pipes[i]
					if not p.top.Parent then table.remove(pipes, i)
					else
						local x = p.top.Position.X.Offset - (2.0 + diff() * 0.35)
						p.top.Position = UDim2.new(0, x, 0, 0)
						p.bot.Position = UDim2.new(0, x, 0, p.bot.Position.Y.Offset)
						local bx, by = 24, bird.Position.Y.Offset
						if x < bx + 26 and x + 26 > bx then
							local gapTop = p.top.Size.Y.Offset
							local gapBot = p.bot.Position.Y.Offset
							if by < gapTop - 2 or by + 26 > gapBot + 2 then
								dead = true
								die("🐦 HIT PIPE  |  RESTART")
								break
							end
						end
						if x + 26 < bx and not p.scored then
							p.scored = true
							setScore(score + 1)
							playSfx(4612373902, 0.35)
						end
						if x < -30 then
							p.top:Destroy(); p.bot:Destroy()
							table.remove(pipes, i)
						end
					end
				end
				if dead then break end
				task.wait(0.032)
			end
		end)
	end
	local function startReaction()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🎯 REACTION  |  Hit the targets"
		clearField()
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent do
				local fw = math.max(field.AbsoluteSize.X, 80)
				local fh = math.max(field.AbsoluteSize.Y, 80)
				local t = Instance.new("TextButton")
				t.Size = UDim2.new(0, 40, 0, 40)
				t.Position = UDim2.new(0, math.random(4, math.max(5, fw - 44)), 0, math.random(4, math.max(5, fh - 44)))
				t.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
				t.Text = "🎯"
				t.TextSize = 18
				t.ZIndex = 9
				t.Parent = field
				Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)
				local hit = false
				t.Activated:Connect(function()
					if hit or gen ~= my then return end
					hit = true
					setScore(score + 1)
					playSfx(6895079853, 0.45)
					t:Destroy()
				end)
				task.delay(math.clamp(1.15 / diff(), 0.45, 1.15), function() if t.Parent then t:Destroy() end end)
				task.wait(math.clamp(0.65 / diff(), 0.28, 0.65))
			end
		end)
	end
	local function startMemory()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🧠 MEMORY  |  Match pairs"
		clearField()
		local icons = {"🔥","💧","🌿","⚡","⭐","🌙","💎","🎯"}
		local deck = {}
		for i = 1, 8 do deck[#deck+1] = icons[i]; deck[#deck+1] = icons[i] end
		for i = #deck, 2, -1 do
			local j = math.random(i)
			deck[i], deck[j] = deck[j], deck[i]
		end
		local first, lock = nil, false
		for i, ic in ipairs(deck) do
			local r = math.floor((i - 1) / 4)
			local col = (i - 1) % 4
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 48, 0, 48)
			b.Position = UDim2.new(0, 6 + col * 54, 0, 4 + r * 54)
			b.BackgroundColor3 = Color3.fromRGB(48, 52, 64)
			b.Text = "?"
			b.TextSize = 18
			b.ZIndex = 9
			b.Parent = field
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			local open = false
			b.Activated:Connect(function()
				if lock or open or gen ~= my then return end
				open = true
				b.Text = ic
				playSfx(6895079853, 0.28)
				if not first then
					first = {btn = b, face = ic, close = function() open = false end}
				else
					lock = true
					if first.face == ic then
						setScore(score + 1)
						playSfx(4612373902, 0.4)
						first = nil
						lock = false
						if score >= 8 then gTitle.Text = "CLEARED!" end
					else
						local a, fr = b, first
						task.delay(0.5, function()
							if a then a.Text = "?" end
							open = false
							if fr and fr.btn then fr.btn.Text = "?"; fr.close() end
							first = nil
							lock = false
						end)
					end
				end
			end)
		end
	end
	local function startDodge()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🏃 DODGE FALL  |  Move to survive"
		clearField()
		local player = Instance.new("TextButton")
		player.Size = UDim2.new(0, 36, 0, 36)
		player.Position = UDim2.new(0.5, -18, 1, -44)
		player.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
		player.Text = "😎"
		player.TextSize = 18
		player.ZIndex = 10
		player.Parent = field
		Instance.new("UICorner", player).CornerRadius = UDim.new(1, 0)
		local dead = false
		field.InputBegan:Connect(function(inp)
			if dead or gen ~= my then return end
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				local fw = math.max(field.AbsoluteSize.X, 80)
				local x = inp.Position.X - field.AbsolutePosition.X - 18
				x = math.clamp(x, 0, fw - 36)
				player.Position = UDim2.new(0, x, 1, -44)
			end
		end)
		UIS.InputChanged:Connect(function(inp)
			if dead or gen ~= my then return end
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
				if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or inp.UserInputType == Enum.UserInputType.Touch then
					local fw = math.max(field.AbsoluteSize.X, 80)
					local x = inp.Position.X - field.AbsolutePosition.X - 18
					x = math.clamp(x, 0, fw - 36)
					player.Position = UDim2.new(0, x, 1, -44)
				end
			end
		end)
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent and not dead do
				local fw = math.max(field.AbsoluteSize.X, 80)
				local fh = math.max(field.AbsoluteSize.Y, 80)
				local rock = Instance.new("TextLabel")
				rock.Size = UDim2.new(0, 28, 0, 28)
				rock.Position = UDim2.new(0, math.random(0, fw - 28), 0, -30)
				rock.BackgroundTransparency = 1
				rock.Text = "☄️"
				rock.TextSize = 20
				rock.ZIndex = 9
				rock.Parent = field
				task.spawn(function()
					local y = -30
					while rock.Parent and gen == my do
						y = y + (3.2 + diff() * 0.55)
						rock.Position = UDim2.new(0, rock.Position.X.Offset, 0, y)
						local px = player.Position.X.Offset
						if y > fh - 70 and y < fh - 20 then
							if math.abs(px + 18 - (rock.Position.X.Offset + 14)) < 28 then
								dead = true
								rock:Destroy()
								die("☄️ SQUASHED  |  RESTART")
								return
							end
						end
						if y > fh then
							rock:Destroy()
							if gen == my and not dead then setScore(score + 1) end
							return
						end
						task.wait(0.03)
					end
				end)
				task.wait(math.clamp(0.6 / diff(), 0.25, 0.6))
			end
		end)
	end
	local function startCatch()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🧺 CATCH FOOD  |  Move the basket"
		clearField()
		local basket = Instance.new("TextButton")
		basket.Size = UDim2.new(0, 48, 0, 32)
		basket.Position = UDim2.new(0.5, -24, 1, -40)
		basket.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
		basket.Text = "🧺"
		basket.TextSize = 18
		basket.ZIndex = 10
		basket.Parent = field
		Instance.new("UICorner", basket).CornerRadius = UDim.new(0, 6)
		field.InputBegan:Connect(function(inp)
			if gen ~= my then return end
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				local fw = math.max(field.AbsoluteSize.X, 80)
				local x = math.clamp(inp.Position.X - field.AbsolutePosition.X - 24, 0, fw - 48)
				basket.Position = UDim2.new(0, x, 1, -40)
			end
		end)
		local foods = {"🍎","🧀","🍪","🍩","🍕"}
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent do
				local fw = math.max(field.AbsoluteSize.X, 80)
				local fh = math.max(field.AbsoluteSize.Y, 80)
				local food = Instance.new("TextLabel")
				food.Size = UDim2.new(0, 28, 0, 28)
				food.Position = UDim2.new(0, math.random(0, fw - 28), 0, -20)
				food.BackgroundTransparency = 1
				food.Text = foods[math.random(1, #foods)]
				food.TextSize = 18
				food.ZIndex = 9
				food.Parent = field
				task.spawn(function()
					local y = -20
					while food.Parent and gen == my do
						y = y + 3.2
						food.Position = UDim2.new(0, food.Position.X.Offset, 0, y)
						local bx = basket.Position.X.Offset
						if y > fh - 55 and y < fh - 20 then
							if math.abs(bx + 24 - (food.Position.X.Offset + 14)) < 32 then
								setScore(score + 1)
								playSfx(4612373902, 0.35)
								food:Destroy()
								return
							end
						end
						if y > fh then food:Destroy() return end
						task.wait(0.03)
					end
				end)
				task.wait(0.7)
			end
		end)
	end
	local function startWhack()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🔨 WHACK-A-MOLE"
		clearField()
		local holes = {}
		for i = 1, 6 do
			local r = math.floor((i - 1) / 3)
			local col = (i - 1) % 3
			local h = Instance.new("TextButton")
			h.Size = UDim2.new(0, 64, 0, 64)
			h.Position = UDim2.new(0, 12 + col * 72, 0, 16 + r * 78)
			h.BackgroundColor3 = Color3.fromRGB(40, 35, 30)
			h.Text = "🕳️"
			h.TextSize = 22
			h.ZIndex = 9
			h.Parent = field
			Instance.new("UICorner", h).CornerRadius = UDim.new(1, 0)
			holes[i] = {btn = h, up = false}
			h.Activated:Connect(function()
				if gen ~= my then return end
				if holes[i].up then
					holes[i].up = false
					h.Text = "🕳️"
					setScore(score + 1)
					playSfx(6895079853, 0.4)
				end
			end)
		end
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent do
				local i = math.random(1, 6)
				local h = holes[i]
				h.up = true
				h.btn.Text = "🐹"
				task.delay(math.clamp(0.9 / diff(), 0.35, 0.9), function()
					if gen == my and h.up then
						h.up = false
						h.btn.Text = "."
					end
				end)
				task.wait(math.clamp(0.6 / diff(), 0.25, 0.6))
			end
		end)
	end
	local function startRhythm()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🎵 RHYTHM  |  Tap when ❤️ hits zone"
		clearField()
		local zone = Instance.new("Frame")
		zone.Size = UDim2.new(1, -8, 0, 36)
		zone.Position = UDim2.new(0, 4, 1, -48)
		zone.BackgroundColor3 = Color3.fromRGB(40, 80, 50)
		zone.ZIndex = 8
		zone.Parent = field
		Instance.new("UICorner", zone).CornerRadius = UDim.new(0, 4)
		local canHit = false
		local cur = nil
		field.InputBegan:Connect(function(inp)
			if gen ~= my then return end
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				if canHit and cur and cur.Parent then
					setScore(score + 1)
					playSfx(4612373902, 0.4)
					cur:Destroy()
					canHit = false
					cur = nil
				end
			end
		end)
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent do
				local note = Instance.new("TextLabel")
				note.Size = UDim2.new(0, 36, 0, 36)
				note.Position = UDim2.new(0.5, -18, 0, -30)
				note.BackgroundTransparency = 1
				note.Text = "❤️"
				note.TextSize = 22
				note.ZIndex = 9
				note.Parent = field
				cur = note
				local y = -30
				local fh = math.max(field.AbsoluteSize.Y, 80)
				while note.Parent and gen == my do
					y = y + 3.5
					note.Position = UDim2.new(0.5, -18, 0, y)
					canHit = (y > fh - 70 and y < fh - 20)
					if y > fh then
						note:Destroy()
						canHit = false
						break
					end
					task.wait(0.03)
				end
				task.wait(0.5)
			end
		end)
	end
	local function startAim()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🎯 AIM TRAINER"
		clearField()
		local function spawnTarget()
			if gen ~= my then return end
			local fw = math.max(field.AbsoluteSize.X, 80)
			local fh = math.max(field.AbsoluteSize.Y, 80)
			local t = Instance.new("TextButton")
			local sz = math.random(28, 44)
			t.Size = UDim2.new(0, sz, 0, sz)
			t.Position = UDim2.new(0, math.random(4, math.max(5, fw - sz)), 0, math.random(4, math.max(5, fh - sz)))
			t.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
			t.Text = "🎯"
			t.TextSize = 16
			t.ZIndex = 9
			t.Parent = field
			Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)
			t.Activated:Connect(function()
				if gen ~= my then return end
				setScore(score + 1)
				playSfx(6895079853, 0.4)
				t:Destroy()
				spawnTarget()
			end)
			task.delay(1.4, function()
				if t.Parent and gen == my then
					t:Destroy()
					spawnTarget()
				end
			end)
		end
		spawnTarget()
	end
	local function startStack()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "📦 STACK DROP  |  Tap to place"
		clearField()
		local yBase = math.max(field.AbsoluteSize.Y, 100) - 20
		local moving = Instance.new("TextButton")
		moving.Size = UDim2.new(0, 70, 0, 18)
		moving.Position = UDim2.new(0, 10, 0, 20)
		moving.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
		moving.Text = "📦"
		moving.ZIndex = 9
		moving.Parent = field
		Instance.new("UICorner", moving).CornerRadius = UDim.new(0, 4)
		local dir = 3
		local lastX = nil
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent and moving.Parent do
				local fw = math.max(field.AbsoluteSize.X, 80)
				local x = moving.Position.X.Offset + dir
				if x < 4 or x > fw - 74 then dir = -dir end
				moving.Position = UDim2.new(0, x + (dir > 0 and 0 or 0), 0, moving.Position.Y.Offset)
				moving.Position = UDim2.new(0, moving.Position.X.Offset + dir, 0, 20)
				task.wait(0.03)
			end
		end)
		field.InputBegan:Connect(function(inp)
			if gen ~= my or not moving.Parent then return end
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				local x = moving.Position.X.Offset
				if lastX and math.abs(x - lastX) > 40 then
					die("📦 MISSED  |  RESTART")
					moving:Destroy()
					return
				end
				lastX = x
				local block = Instance.new("Frame")
				block.Size = UDim2.new(0, 70, 0, 18)
				block.Position = UDim2.new(0, x, 0, yBase - score * 18)
				block.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
				block.ZIndex = 8
				block.Parent = field
				Instance.new("UICorner", block).CornerRadius = UDim.new(0, 4)
				setScore(score + 1)
				playSfx(4612373902, 0.35)
				moving.Position = UDim2.new(0, 10, 0, 20)
			end
		end)
	end
	local function startColorTap()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🎨 COLOR MATCH  |  Tap the color"
		clearField()
		local colors = {
			{ "🔴", Color3.fromRGB(200, 50, 50) },
			{ "🟢", Color3.fromRGB(50, 180, 80) },
			{ "🔵", Color3.fromRGB(50, 100, 220) },
			{ "🟡", Color3.fromRGB(220, 200, 50) },
		}
		local targetL = Instance.new("TextLabel")
		targetL.Size = UDim2.new(1, 0, 0, 28)
		targetL.BackgroundTransparency = 1
		targetL.Text = ""
		targetL.TextSize = 20
		targetL.ZIndex = 9
		targetL.Parent = field
		local target = colors[1]
		local function nextRound()
			if gen ~= my then return end
			target = colors[math.random(1, #colors)]
			targetL.Text = "Tap: " .. target[1]
			for _, ch in pairs(field:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			local order = {1,2,3,4}
			for i = #order, 2, -1 do
				local j = math.random(i)
				order[i], order[j] = order[j], order[i]
			end
			for i, idx in ipairs(order) do
				local cinfo = colors[idx]
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(0, 50, 0, 50)
				b.Position = UDim2.new(0, 20 + ((i-1)%2)*60, 0, 50 + math.floor((i-1)/2)*60)
				b.BackgroundColor3 = cinfo[2]
				b.Text = cinfo[1]
				b.TextSize = 22
				b.ZIndex = 9
				b.Parent = field
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
				b.Activated:Connect(function()
					if gen ~= my then return end
					if cinfo[1] == target[1] then
						setScore(score + 1)
						playSfx(4612373902, 0.35)
						nextRound()
					else
						die("🎨 WRONG COLOR  |  RESTART")
					end
				end)
			end
		end
		nextRound()
	end
	local function startBubble()
		local my = gen + 1
		gen = my
		setScore(0)
		gTitle.Text = "🫧 BUBBLE POP"
		clearField()
		task.spawn(function()
			while gen == my and play.Visible and sg.Parent do
				local fw = math.max(field.AbsoluteSize.X, 80)
				local fh = math.max(field.AbsoluteSize.Y, 80)
				local b = Instance.new("TextButton")
				local sz = math.random(30, 48)
				b.Size = UDim2.new(0, sz, 0, sz)
				b.Position = UDim2.new(0, math.random(4, math.max(5, fw - sz)), 0, math.random(4, math.max(5, fh - sz)))
				b.BackgroundColor3 = Color3.fromRGB(80, 160, 220)
				b.BackgroundTransparency = 0.3
				b.Text = "🫧"
				b.TextSize = 18
				b.ZIndex = 9
				b.Parent = field
				Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
				b.Activated:Connect(function()
					if gen ~= my then return end
					setScore(score + 1)
					playSfx(6895079853, 0.35)
					b:Destroy()
				end)
				task.delay(math.clamp(1.7 / diff(), 0.6, 1.7), function() if b.Parent then b:Destroy() end end)
				task.wait(math.clamp(0.45 / diff(), 0.18, 0.45))
			end
		end)
	end
	currentStart = startFruit
	local games = {
		{"01  🍎  FRUIT RUN", startFruit},
		{"02  🐦  FLAPPY BLOCK", startFlappy},
		{"03  🎯  REACTION", startReaction},
		{"04  🧠  MEMORY", startMemory},
		{"05  ☄️  DODGE FALL", startDodge},
		{"06  🧺  CATCH FOOD", startCatch},
		{"07  🔨  WHACK-A-MOLE", startWhack},
		{"08  🎵  RHYTHM", startRhythm},
		{"09  🎯  AIM TRAINER", startAim},
		{"10  📦  STACK DROP", startStack},
		{"11  🎨  COLOR MATCH", startColorTap},
		{"12  🫧  BUBBLE POP", startBubble},
	}
	for _, g in ipairs(games) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -4, 0, 28)
		b.BackgroundColor3 = Color3.fromRGB(28, 34, 45)
		b.Text = g[1]
		b.TextColor3 = Color3.fromRGB(218, 224, 235)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 12
		b.ZIndex = 7
		b.Parent = list
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(function()
			gen = gen + 1
			currentStart = g[2]
			list.Visible = false
			play.Visible = true
			g[2]()
		end)
	end
	backBtn.MouseButton1Click:Connect(function()
		gen = gen + 1
		clearField()
		play.Visible = false
		list.Visible = true
		playSfx(421058925, 0.25)
	end)
	resetBtn.MouseButton1Click:Connect(function()
		gen = gen + 1
		task.wait()
		if currentStart then currentStart() end
	end)
	closeBtn.MouseButton1Click:Connect(function()
		gen = gen + 1
		getgenv()._tcoCloseMiniGames()
	end)
	local shown = true
	handle.MouseButton1Click:Connect(function()
		shown = not shown
		panel.Visible = shown
	end)
end
dashtab = lib.maketab("dashboard")
bsaltab = lib.maketab("build and load stuff")
esptab = lib.maketab("esp")
shadertab = lib.maketab("shaders")
buildtab = lib.maketab("build settings")
tooltab = lib.maketab("tools")
geartab = lib.maketab("gears")
modtab = lib.maketab("spy chat")
scripttab = lib.maketab("grief detection")
cmdspamtab = lib.maketab("commands")
antitab = lib.maketab("anti")
commandtab = antitab
loadDualSpamGui = nil
jailtab = lib.maketab("jail")
grieftab = lib.maketab("grief")
emotestab = lib.maketab("emotes")
do
    local Players = game:GetService("Players")
    local dashPage = lib.getpage(dashtab)
    if dashPage then
        local dashFrame = Instance.new("Frame")
        dashFrame.Name = "Dashboard"
        dashFrame.Size = UDim2.new(1, -4, 0, 290)
        dashFrame.BackgroundColor3 = Color3.fromRGB(30, 34, 44)
        dashFrame.BackgroundTransparency = .12
        dashFrame.BorderSizePixel = 0
        dashFrame.Parent = dashPage
        Instance.new("UICorner", dashFrame).CornerRadius = UDim.new(0, 10)
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 76, 0, 76)
        avatar.Position = UDim2.new(0, 12, 0, 12)
        avatar.BackgroundColor3 = Color3.fromRGB(45, 50, 64)
        avatar.BorderSizePixel = 0
        avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..tostring(localplr.UserId).."&w=150&h=150"
        avatar.Parent = dashFrame
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
        local profile = Instance.new("TextLabel")
        profile.Size = UDim2.new(1, -112, 0, 34)
        profile.Position = UDim2.new(0, 100, 0, 16)
        profile.BackgroundTransparency = 1
        profile.TextColor3 = Color3.fromRGB(245, 245, 250)
        profile.Font = Enum.Font.GothamBold
        profile.TextSize = 18
        profile.TextXAlignment = Enum.TextXAlignment.Left
        profile.Text = localplr.DisplayName.."  @"..localplr.Name
        profile.Parent = dashFrame
        local stats = Instance.new("TextLabel")
        stats.Size = UDim2.new(1, -112, 0, 42)
        stats.Position = UDim2.new(0, 100, 0, 50)
        stats.BackgroundTransparency = 1
        stats.TextColor3 = Color3.fromRGB(165, 205, 235)
        stats.Font = Enum.Font.Gotham
        stats.TextSize = 12
        stats.TextWrapped = true
        stats.TextXAlignment = Enum.TextXAlignment.Left
        stats.Parent = dashFrame
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, -24, 0, 105)
        status.Position = UDim2.new(0, 12, 0, 103)
        status.BackgroundColor3 = Color3.fromRGB(20, 23, 31)
        status.BackgroundTransparency = .12
        status.TextColor3 = Color3.fromRGB(225, 230, 240)
        status.Font = Enum.Font.GothamMedium
        status.TextSize = 13
        status.TextWrapped = true
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.TextYAlignment = Enum.TextYAlignment.Top
        status.Parent = dashFrame
        Instance.new("UICorner", status).CornerRadius = UDim.new(0, 7)
        local credits = Instance.new("TextLabel")
        credits.Size = UDim2.new(1, -24, 0, 58)
        credits.Position = UDim2.new(0, 12, 0, 220)
        credits.BackgroundTransparency = 1
        credits.TextColor3 = Color3.fromRGB(180, 185, 200)
        credits.Font = Enum.Font.Gotham
        credits.TextSize = 12
        credits.TextWrapped = true
        credits.TextXAlignment = Enum.TextXAlignment.Left
        credits.TextYAlignment = Enum.TextYAlignment.Top
        credits.Text = "Credits: therealthanosnap • lostminiacc • wrapmeinplastiec • mohablikesnay • guymanguy • thelastpoopkaka\nScriptBlox profile: guyhubkeyless"
        credits.Parent = dashFrame
        local function hasArken(plr)
            if plr:GetAttribute("Arken") == true or plr:GetAttribute("HasArkenstone") == true then return true end
            for _, parent in ipairs({plr.Character, plr:FindFirstChildOfClass("Backpack")}) do
                if parent and (parent:FindFirstChild("The Arkenstone") or parent:FindFirstChild("Arkenstone") or parent:FindFirstChild("Enlighten")) then return true end
            end
            return false
        end
        local function refresh()
            local admins, arkens = {}, {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Neutral == false or plr:GetAttribute("ChosenOneAdmin") == true then admins[#admins+1] = plr.DisplayName end
                if hasArken(plr) then arkens[#arkens+1] = plr.DisplayName end
            end
            local adminText = #admins > 0 and table.concat(admins, ", ") or "None detected"
            local arkenText = #arkens > 0 and table.concat(arkens, ", ") or "None detected"
            status.Text = "ADMIN\n"..adminText.."\n\nARKENSTONE HOLDERS ("..#arkens..")\n"..arkenText
            local ping, fps = "?", "?"
            pcall(function()
                local item = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
                if item then ping = tostring(math.floor(item:GetValue()+.5)) end
            end)
            local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
            stats.Text = "Players: "..#Players:GetPlayers().."    FPS: "..tostring(getgenv()._tcoCurrentFPS or "?").."    Ping: "..ping.." ms    Health: "..(hum and math.floor(hum.Health+.5) or "?")
        end
        task.spawn(function()
            while dashFrame.Parent do refresh(); task.wait(1) end
        end)
    end
end
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local esp = getgenv()._tcoESPState or {enabled=false,name=true,distance=true,health=true,tools=false,arkenstone=true,admin=true,style="Box",color=Color3.fromRGB(255,90,90)}
    getgenv()._tcoESPState = esp
    local root
    local function getRoot()
        if root and root.Parent then return root end
        root = Instance.new("Folder"); root.Name = "TCOPlayerESP"
        pcall(function() root.Parent = game:GetService("CoreGui") end)
        if not root.Parent then root.Parent = localplr:WaitForChild("PlayerGui") end
        return root
    end
    local function toolsFor(plr)
        local out, seen = {}, {}
        for _, parent in ipairs({plr.Character, plr:FindFirstChildOfClass("Backpack")}) do
            if parent then for _, d in ipairs(parent:GetChildren()) do
                if d:IsA("Tool") and not seen[d.Name] then seen[d.Name]=true; out[#out+1]=d.Name end
            end end
        end
        table.sort(out); return out
    end
    local function hasArken(plr)
        if plr:GetAttribute("Arken") == true or plr:GetAttribute("HasArkenstone") == true then return true end
        for _, parent in ipairs({plr.Character, plr:FindFirstChildOfClass("Backpack")}) do
            if parent and (parent:FindFirstChild("The Arkenstone") or parent:FindFirstChild("Arkenstone") or parent:FindFirstChild("Enlighten")) then return true end
        end
        return false
    end
    local function isChosenOneAdmin(plr)
        if plr.Neutral == false then return true end
        if plr:GetAttribute("ChosenOneAdmin") == true then return true end
        return false
    end
    local function clearSkeleton(folder, char)
        for _, d in ipairs(folder:GetChildren()) do if d:IsA("Beam") then d:Destroy() end end
        if char then for _, d in ipairs(char:GetDescendants()) do if d:IsA("Attachment") and d.Name:sub(1,7)=="TCOESP_" then d:Destroy() end end end
    end
    local function skeleton(folder, char, lineColor)
        local pairsList={{"Head","UpperTorso"},{"Head","Torso"},{"UpperTorso","LowerTorso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},{"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},{"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},{"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},{"LeftLowerArm","LeftHand"},{"RightLowerArm","RightHand"},{"LeftLowerLeg","LeftFoot"},{"RightLowerLeg","RightFoot"}}
        for i,pair in ipairs(pairsList) do
            local a,b=char:FindFirstChild(pair[1]),char:FindFirstChild(pair[2])
            if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
                local aa=a:FindFirstChild("TCOESP_A"..i) or Instance.new("Attachment"); aa.Name="TCOESP_A"..i; aa.Parent=a
                local bb=b:FindFirstChild("TCOESP_B"..i) or Instance.new("Attachment"); bb.Name="TCOESP_B"..i; bb.Parent=b
                local beam=folder:FindFirstChild("Bone"..i) or Instance.new("Beam"); beam.Name="Bone"..i; beam.Attachment0=aa; beam.Attachment1=bb; beam.Width0=.055; beam.Width1=.055; beam.FaceCamera=true; beam.LightEmission=1; beam.Color=ColorSequence.new(lineColor or esp.color); beam.Parent=folder
            end
        end
    end
    local function remove(plr)
        local f=root and root:FindFirstChild("P_"..plr.UserId)
        if f then clearSkeleton(f,plr.Character); f:Destroy() end
    end
    local function render(plr)
        if plr==localplr or not esp.enabled then return end
        local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then remove(plr); return end
        local f=getRoot():FindFirstChild("P_"..plr.UserId) or Instance.new("Folder")
        f.Name="P_"..plr.UserId; f.Parent=getRoot()
        local hasArken = hasArken(plr)
        local chosenAdmin = isChosenOneAdmin(plr)
        local displayColor = chosenAdmin and Color3.fromRGB(255, 220, 45) or (hasArken and Color3.fromRGB(45, 150, 255) or esp.color)
        local h=f:FindFirstChild("Highlight") or Instance.new("Highlight"); h.Name="Highlight"; h.Adornee=char; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.OutlineColor=displayColor; h.FillColor=displayColor; h.Parent=f
        if esp.style=="Outline" then h.FillTransparency=1; h.OutlineTransparency=0; clearSkeleton(f,char)
        elseif esp.style=="Skeleton" then h.FillTransparency=1; h.OutlineTransparency=1; skeleton(f,char,displayColor)
        else h.FillTransparency=.78; h.OutlineTransparency=0; clearSkeleton(f,char) end
        local bb=f:FindFirstChild("Info") or Instance.new("BillboardGui"); bb.Name="Info"; bb.Adornee=hrp; bb.AlwaysOnTop=true; bb.MaxDistance=300; bb.Size=UDim2.new(0,280,0,100); bb.StudsOffset=Vector3.new(0,3.2,0); bb.Parent=f
        local label=bb:FindFirstChild("Label") or Instance.new("TextLabel"); label.Name="Label"; label.Size=UDim2.new(1,0,1,0); label.BackgroundTransparency=1; label.TextColor3=displayColor; label.TextStrokeTransparency=.35; label.Font=Enum.Font.GothamBold; label.TextSize=13; label.TextWrapped=true; label.Parent=bb
        local lines={}; if esp.name then lines[#lines+1]=plr.DisplayName.." ["..plr.Name.."]" end
        local my=localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart"); if esp.distance and my then lines[#lines+1]="Distance: "..math.floor((hrp.Position-my.Position).Magnitude+.5) end
        local hum=char:FindFirstChildOfClass("Humanoid"); if esp.health and hum then lines[#lines+1]="HP: "..math.floor(hum.Health+.5).."/"..math.floor(hum.MaxHealth+.5) end
        if esp.arkenstone and hasArken then lines[#lines+1]="★ THE ARKENSTONE" end
        if esp.admin and chosenAdmin then lines[#lines+1]="⚠ THE CHOSEN ONE ADMIN" end
        if esp.tools then local ts=toolsFor(plr); if #ts>0 then lines[#lines+1]="Tools: "..table.concat(ts,", ") end end
        label.Text=table.concat(lines,"\n"); label.Visible=#lines>0
    end
    local function clearAll()
        if root then for _,plr in ipairs(Players:GetPlayers()) do remove(plr) end; root:Destroy(); root=nil end
    end
    local function setESP(v) esp.enabled=v and true or false; getgenv()._tcoESP=esp.enabled; if not esp.enabled then clearAll() end end
    getgenv()._tcoSetESP=setESP
    if getgenv()._tcoESPConn and getgenv()._tcoESPConn.Disconnect then getgenv()._tcoESPConn:Disconnect() end
    getgenv()._tcoESPConn=RunService.Heartbeat:Connect(function() if esp.enabled then for _,plr in ipairs(Players:GetPlayers()) do pcall(render,plr) end end end)
    Players.PlayerRemoving:Connect(remove)
    lib.makelabel("Player overlays and status markers",esptab)
    lib.maketoggle("Enable ESP",esptab,setESP,esp.enabled)
    lib.maketoggle("Names",esptab,function(v) esp.name=v end,esp.name)
    lib.maketoggle("Distance",esptab,function(v) esp.distance=v end,esp.distance)
    lib.maketoggle("Health",esptab,function(v) esp.health=v end,esp.health)
    lib.maketoggle("Tools ESP",esptab,function(v) esp.tools=v end,esp.tools)
    lib.maketoggle("Arkenstone ESP",esptab,function(v) esp.arkenstone=v end,esp.arkenstone)
    lib.maketoggle("Admin ESP",esptab,function(v) esp.admin=v end,esp.admin)
    lib.makedropdown("Display style",esptab,{"Box","Outline","Skeleton"},function(v) esp.style=v end)
    local espPalette = {
        Red=Color3.fromRGB(255,90,90), Cyan=Color3.fromRGB(0,210,255), Green=Color3.fromRGB(80,255,140),
        Purple=Color3.fromRGB(190,100,255), White=Color3.fromRGB(245,245,255), Orange=Color3.fromRGB(255,155,60),
    }
    lib.makedropdown("ESP color palette",esptab,{"Red","Cyan","Green","Purple","White","Orange"},function(v)
        esp.color=espPalette[v] or esp.color
    end)
    lib.makebutton("Clear ESP now",esptab,clearAll)
end
do
	local ptab = lib.maketab("player stuff")
	local shaderState = getgenv()._tcoShaderState or {fps=false}
	getgenv()._tcoShaderState = shaderState
	local fpsSaved = {}
	local function setFPSBoost(on)
		shaderState.fps = on and true or false
		getgenv()._tcoFPSBoost = shaderState.fps
		local lighting = game:GetService("Lighting")
		if shaderState.fps then
			fpsSaved.GlobalShadows = lighting.GlobalShadows
			fpsSaved.FogEnd = lighting.FogEnd
			fpsSaved.TerrainDecoration = workspace.Terrain.Decoration
			lighting.GlobalShadows = false
			lighting.FogEnd = 100000
			workspace.Terrain.Decoration = false
			for _, d in ipairs(lighting:GetChildren()) do
				if d:IsA("PostEffect") then fpsSaved[d] = d.Enabled; d.Enabled = false end
			end
		else
			if fpsSaved.GlobalShadows ~= nil then lighting.GlobalShadows = fpsSaved.GlobalShadows end
			if fpsSaved.FogEnd ~= nil then lighting.FogEnd = fpsSaved.FogEnd end
			if fpsSaved.TerrainDecoration ~= nil then workspace.Terrain.Decoration = fpsSaved.TerrainDecoration end
			for d, value in pairs(fpsSaved) do
				if typeof(d) == "Instance" and d.Parent and d:IsA("PostEffect") then d.Enabled = value end
			end
			fpsSaved = {}
		end
	end
	lib.maketoggle("FPS Booster", ptab, setFPSBoost, shaderState.fps)
	local shadertab = shadertab
	local function shaderEffect(name, on, cfg)
		local lighting = game:GetService("Lighting")
		local prefix = "TCOShader_"..name
		for _, d in ipairs(lighting:GetChildren()) do if d.Name:sub(1,#prefix)==prefix then d:Destroy() end end
		if not on then return end
		if cfg.cc then local e=Instance.new("ColorCorrectionEffect"); e.Name=prefix.."_Color"; for k,v in pairs(cfg.cc) do e[k]=v end; e.Parent=lighting end
		if cfg.bloom then local e=Instance.new("BloomEffect"); e.Name=prefix.."_Bloom"; for k,v in pairs(cfg.bloom) do e[k]=v end; e.Parent=lighting end
		if cfg.rays then local e=Instance.new("SunRaysEffect"); e.Name=prefix.."_Rays"; for k,v in pairs(cfg.rays) do e[k]=v end; e.Parent=lighting end
		if cfg.atmo then local e=Instance.new("Atmosphere"); e.Name=prefix.."_Atmosphere"; for k,v in pairs(cfg.atmo) do e[k]=v end; e.Parent=lighting end
		if cfg.dof then local e=Instance.new("DepthOfFieldEffect"); e.Name=prefix.."_Depth"; for k,v in pairs(cfg.dof) do e[k]=v end; e.Parent=lighting end
	end
	local presets={
		["Cherry Blossom"]={cc={TintColor=Color3.fromRGB(255,190,215),Saturation=.18,Contrast=.08,Brightness=.03},bloom={Intensity=.22,Size=24,Threshold=.8}},
		Realistic={cc={Saturation=-.05,Contrast=.12,Brightness=.01},rays={Intensity=.08,Spread=.8},atmo={Density=.22,Haze=1.2,Glare=.12}},
		Rain={cc={TintColor=Color3.fromRGB(175,205,255),Saturation=-.18,Contrast=.12,Brightness=-.02},atmo={Density=.38,Haze=2,Color=Color3.fromRGB(165,190,235)}},
		Aurora={cc={TintColor=Color3.fromRGB(165,255,220),Saturation=.25,Contrast=.08},bloom={Intensity=.35,Size=32,Threshold=.7}},
		Sunset={cc={TintColor=Color3.fromRGB(255,185,125),Saturation=.22,Contrast=.1,Brightness=.02},rays={Intensity=.16,Spread=.75}},
		Noir={cc={Saturation=-1,Contrast=.3,Brightness=-.02}},
		Dreamy={cc={TintColor=Color3.fromRGB(220,190,255),Saturation=.2,Contrast=-.08,Brightness=.05},bloom={Intensity=.42,Size=36,Threshold=.7},dof={FarIntensity=.12,FocusDistance=55,InFocusRadius=30}},
		Ocean={cc={TintColor=Color3.fromRGB(120,210,255),Saturation=.15,Contrast=.1},atmo={Density=.3,Haze=1.5,Color=Color3.fromRGB(120,190,255)}},
		Autumn={cc={TintColor=Color3.fromRGB(255,190,120),Saturation=.2,Contrast=.12},bloom={Intensity=.16,Size=20,Threshold=.9}},
	}
	lib.makelabel("Visual presets (toggle any combination)",shadertab)
	for name,cfg in pairs(presets) do
		lib.maketoggle(name,shadertab,function(v) shaderEffect(name,v,cfg) end,false)
	end
	lib.makebutton("Clear all shaders",shadertab,function()
		for name in pairs(presets) do shaderEffect(name,false,presets[name]) end
	end)
	local enlighttab = lib.maketab("enlighten stuff")
	do
		local function enlightNotify(t)
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {Title="Enlighten", Text=tostring(t), Duration=2})
			end)
		end
		local function enlightSay(msg)
			pcall(function()
				local tcs = game:GetService("TextChatService")
				if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
					local ch = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
					if ch then ch:SendAsync(msg) return end
				end
				local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
				if ev and ev:FindFirstChild("SayMessageRequest") then
					ev.SayMessageRequest:FireServer(msg, "All")
				end
			end)
		end
		getgenv()._tcoEnlightTargets = getgenv()._tcoEnlightTargets or {}
		local function enlightList()
			local t = {"(none)", "(all / others)"}
			for _, p in pairs(game.Players:GetPlayers()) do
				if p ~= localplr then
					t[#t+1] = p.DisplayName .. " [" .. p.Name .. "]"
				end
			end
			return t
		end
		local function resolveEnlightName(sel)
			if not sel or sel == "(none)" then return nil end
			if sel == "(all / others)" then return "others" end
			local name = sel:match("%[(.-)%]") or sel
			return name
		end
		lib.makelabel("Select target(s) then Abuse / Drag", enlighttab)
		local edrop = lib.makedropdown("Enlighten target", enlighttab, enlightList(), function(sel)
			getgenv()._tcoEnlightSel = sel
		end)
		lib.makebutton("Refresh enlighten list", enlighttab, function()
			pcall(function() lib.updatedropdown(edrop, enlightList()) end)
		end)
		lib.makebutton("Add selected to multi", enlighttab, function()
			local n = resolveEnlightName(getgenv()._tcoEnlightSel)
			if not n or n == "others" then return end
			getgenv()._tcoEnlightTargets[n] = true
			enlightNotify("Added " .. n)
		end)
		lib.makebutton("Clear multi targets", enlighttab, function()
			getgenv()._tcoEnlightTargets = {}
			enlightNotify("Cleared multi")
		end)
		local function abuseNames()
			local multi = getgenv()._tcoEnlightTargets
			if multi and next(multi) then
				local t = {}
				for n, on in pairs(multi) do if on then t[#t+1] = n end end
				return t
			end
			local one = resolveEnlightName(getgenv()._tcoEnlightSel)
			if one == "others" then return {"others"} end
			if one then return {one} end
			return {}
		end
		local function runAbuseOn(name)
			if not name or name == "" then return end
			if name ~= "others" then
				local p = game.Players:FindFirstChild(name)
				if p == localplr then return end
				if not p then
					for _, pl in pairs(game.Players:GetPlayers()) do
						if pl.Name:lower() == name:lower() or pl.DisplayName:lower() == name:lower() then
							if pl == localplr then return end
							name = pl.Name
							break
						end
					end
				end
			end
			local cmds = {
				";mute " .. name,
				";glitch " .. name,
				";freeze " .. name,
				";blind " .. name,
				";dumb " .. name,
			}
			for _, cmd in ipairs(cmds) do
				if not getgenv()._tcoEnlightAbuseRun and not getgenv()._tcoEnlightLoopAbuse then break end
				enlightSay(cmd)
				task.wait(1)
			end
		end
		lib.makebutton("Abuse them", enlighttab, function()
			local names = abuseNames()
			if #names == 0 then enlightNotify("Select a target first") return end
			getgenv()._tcoEnlightAbuseRun = true
			task.spawn(function()
				for _, name in ipairs(names) do
					runAbuseOn(name)
				end
				getgenv()._tcoEnlightAbuseRun = false
				enlightNotify("Abuse done")
			end)
		end)
		lib.maketoggle("Loop abuse them", enlighttab, function(bool)
			getgenv()._tcoEnlightLoopAbuse = bool
			if not bool then
				getgenv()._tcoEnlightLoopGen = (getgenv()._tcoEnlightLoopGen or 0) + 1
				return
			end
			local gen = (getgenv()._tcoEnlightLoopGen or 0) + 1
			getgenv()._tcoEnlightLoopGen = gen
			local abusedChar = {}
			local function hookPlayer(p)
				if not p or p == localplr then return end
				pcall(function()
					if p.Character then
						abusedChar[p] = nil
					end
					table.insert(getgenv()._tcoEnlightCharConns or {}, p.CharacterAdded:Connect(function(char)
						if not getgenv()._tcoEnlightLoopAbuse or getgenv()._tcoEnlightLoopGen ~= gen then return end
						task.spawn(function()
							task.wait(1.2)
							if not getgenv()._tcoEnlightLoopAbuse or getgenv()._tcoEnlightLoopGen ~= gen then return end
							if not char or not char.Parent then return end
							local hum = char:FindFirstChildOfClass("Humanoid")
							if not hum or hum.Health <= 0 then return end
							if abusedChar[p] == char then return end
							abusedChar[p] = char
							getgenv()._tcoEnlightAbuseRun = true
							runAbuseOn(p.Name)
							getgenv()._tcoEnlightAbuseRun = false
						end)
					end))
				end)
			end
			getgenv()._tcoEnlightCharConns = {}
			task.spawn(function()
				local names = abuseNames()
				for _, name in ipairs(names) do
					if name == "others" then
						for _, p in pairs(game.Players:GetPlayers()) do
							if p ~= localplr then
								hookPlayer(p)
								if p.Character then
									abusedChar[p] = p.Character
									getgenv()._tcoEnlightAbuseRun = true
									runAbuseOn(p.Name)
									getgenv()._tcoEnlightAbuseRun = false
									task.wait(0.2)
								end
							end
						end
					else
						local p = game.Players:FindFirstChild(name)
						if not p then
							for _, pl in pairs(game.Players:GetPlayers()) do
								if pl.Name:lower() == name:lower() or pl.DisplayName:lower() == name:lower() then
									p = pl
									break
								end
							end
						end
						if p and p ~= localplr then
							hookPlayer(p)
							if p.Character then
								abusedChar[p] = p.Character
								getgenv()._tcoEnlightAbuseRun = true
								runAbuseOn(p.Name)
								getgenv()._tcoEnlightAbuseRun = false
							end
						end
					end
				end
				local joinConn = game.Players.PlayerAdded:Connect(function(p)
					if not getgenv()._tcoEnlightLoopAbuse or getgenv()._tcoEnlightLoopGen ~= gen then return end
					if p == localplr then return end
					local names = abuseNames()
					local want = false
					for _, n in ipairs(names) do
						if n == "others" or n:lower() == p.Name:lower() then want = true end
					end
					if want then
						hookPlayer(p)
					end
				end)
				while getgenv()._tcoEnlightLoopAbuse and getgenv()._tcoEnlightLoopGen == gen do
					task.wait(1)
				end
				pcall(function() joinConn:Disconnect() end)
				for _, cn in pairs(getgenv()._tcoEnlightCharConns or {}) do
					pcall(function() cn:Disconnect() end)
				end
				getgenv()._tcoEnlightCharConns = {}
			end)
		end, false)
		lib.makelabel("--- Drag control ---", enlighttab)
		lib.makelabel(";invisible me first; 1.5s between cmds; jump = Space", enlighttab)
		lib.maketoggle("Drag control (selected)", enlighttab, function(bool)
			getgenv()._tcoEnlightDrag = bool
			if not bool then
				pcall(function()
					local char = localplr.Character
					if not char then return end
					for _, d in pairs(char:GetDescendants()) do
						if d:IsA("BasePart") then
							d.LocalTransparencyModifier = 0
							d.CanCollide = true
						elseif d:IsA("Decal") then
							d.Transparency = 0
						end
					end
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then workspace.CurrentCamera.CameraSubject = hum end
				end)
				enlightSay(";visible me")
				return
			end
			local name = resolveEnlightName(getgenv()._tcoEnlightSel)
			if not name or name == "others" then
				enlightNotify("Select one player")
				getgenv()._tcoEnlightDrag = false
				return
			end
			local targetPlr = game.Players:FindFirstChild(name)
			if not targetPlr then
				for _, pl in pairs(game.Players:GetPlayers()) do
					if pl.Name:lower() == name:lower() or pl.DisplayName:lower() == name:lower() then
						targetPlr = pl
						name = pl.Name
						break
					end
				end
			end
			if not targetPlr or targetPlr == localplr then
				enlightNotify("Invalid target")
				getgenv()._tcoEnlightDrag = false
				return
			end
			task.spawn(function()
				enlightSay(";invisible me")
				task.wait(1.5)
				if not getgenv()._tcoEnlightDrag then return end
				enlightSay(";mute me")
				task.wait(1.5)
				if not getgenv()._tcoEnlightDrag then return end
				enlightSay(";mute " .. name)
				task.wait(1.5)
				if not getgenv()._tcoEnlightDrag then return end
				enlightSay(";speed " .. name .. " 0")
			end)
			pcall(function()
				local char = localplr.Character
				if not char then return end
				for _, d in pairs(char:GetDescendants()) do
					if d:IsA("BasePart") then
						d.LocalTransparencyModifier = 1
						d.CanCollide = false
					elseif d:IsA("Decal") then
						d.Transparency = 1
					end
				end
			end)
			task.spawn(function()
				local lastBring = 0
				local spaceHeld = false
				local UIS = game:GetService("UserInputService")
				local jumpConn1 = UIS.InputBegan:Connect(function(inp, gp)
					if gp then return end
					if inp.KeyCode == Enum.KeyCode.Space or inp.KeyCode == Enum.KeyCode.ButtonA then
						spaceHeld = true
					end
				end)
				local jumpConn2 = UIS.InputEnded:Connect(function(inp)
					if inp.KeyCode == Enum.KeyCode.Space or inp.KeyCode == Enum.KeyCode.ButtonA then
						spaceHeld = false
					end
				end)
				while getgenv()._tcoEnlightDrag do
					pcall(function()
						if not targetPlr.Parent then return end
						local th = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
						local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
						local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
						local thum = targetPlr.Character and targetPlr.Character:FindFirstChildOfClass("Humanoid")
						if not th or not my or not hum then return end
						for _, d in pairs(localplr.Character:GetDescendants()) do
							if d:IsA("BasePart") then
								d.LocalTransparencyModifier = 1
								d.CanCollide = false
							end
						end
						if thum and workspace.CurrentCamera then
							workspace.CurrentCamera.CameraSubject = thum
						end
						local move = hum.MoveDirection
						local look = th.CFrame.LookVector
						local yOff = spaceHeld and 6 or 1
						local front = th.Position + look * 3 + Vector3.new(0, yOff, 0)
						if move.Magnitude > 0.08 then
							local dest = front + move.Unit * 6
							my.CFrame = CFrame.new(dest, dest + look)
							my.AssemblyLinearVelocity = move.Unit * 28 + (spaceHeld and Vector3.new(0, 20, 0) or Vector3.zero)
							if (tick() - lastBring) >= 1.5 then
								lastBring = tick()
								enlightSay(";bring " .. name)
							end
						elseif spaceHeld then
							my.CFrame = CFrame.new(front, front + look)
							my.AssemblyLinearVelocity = Vector3.new(0, 20, 0)
							if (tick() - lastBring) >= 1.5 then
								lastBring = tick()
								enlightSay(";bring " .. name)
							end
						else
							my.CFrame = CFrame.new(front, front + look)
							my.AssemblyLinearVelocity = Vector3.zero
						end
					end)
					task.wait()
				end
				pcall(function() jumpConn1:Disconnect() end)
				pcall(function() jumpConn2:Disconnect() end)
				pcall(function()
					local char = localplr.Character
					if char then
						for _, d in pairs(char:GetDescendants()) do
							if d:IsA("BasePart") then
								d.LocalTransparencyModifier = 0
								d.CanCollide = true
							elseif d:IsA("Decal") then
								d.Transparency = 0
							end
						end
						local hum = char:FindFirstChildOfClass("Humanoid")
						if hum then workspace.CurrentCamera.CameraSubject = hum end
					end
					enlightSay(";visible me")
				end)
			end)
		end, false)
	end
	local flingtab = lib.maketab("fling")
	local animtab = lib.maketab("animations")
	do
		local UIS = game:GetService("UserInputService")
		local HttpService = game:GetService("HttpService")
		local emoteCatalogUrl = "https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/EmoteSniper.json"
		local emoteState = {
			gui = nil, page = nil, speedPage = nil, settingsPage = nil,
			search = "", pageNo = 1, pageSize = 40, data = {}, filtered = {},
			track = nil, speed = 1, loop = true, freeze = false,
			stopPrevious = true, stopOnRespawn = true, showIds = false,
			favoritesOnly = false, favorites = {}, connections = {}, minimized = false,
			settingsFile = "tco_emote_settings.json"
		}
		local fallbackEmotes = {
			{id=3360686498,name="Stadium"},{id=3360692915,name="Tilt"},
			{id=3576968026,name="Shrug"},{id=3360689775,name="Salute"}
		}
		local function notifyEmote(text)
			pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Guy Hub • Emotes",Text=tostring(text),Duration=3}) end)
		end
		local function loadEmoteSettings()
			local decoded
			pcall(function()
				if isfile and isfile(emoteState.settingsFile) then decoded=HttpService:JSONDecode(readfile(emoteState.settingsFile)) end
			end)
			if type(decoded) == "table" then
				emoteState.speed = math.clamp(tonumber(decoded.speed) or 1, 0, 5)
				emoteState.loop = decoded.loop ~= false
				emoteState.stopPrevious = decoded.stopPrevious ~= false
				emoteState.stopOnRespawn = decoded.stopOnRespawn ~= false
				emoteState.showIds = decoded.showIds == true
				emoteState.favoritesOnly = decoded.favoritesOnly == true
				emoteState.favorites = type(decoded.favorites)=="table" and decoded.favorites or {}
			end
		end
		local function saveEmoteSettings()
			pcall(function()
				if writefile then writefile(emoteState.settingsFile, HttpService:JSONEncode({speed=emoteState.speed,loop=emoteState.loop,stopPrevious=emoteState.stopPrevious,stopOnRespawn=emoteState.stopOnRespawn,showIds=emoteState.showIds,favoritesOnly=emoteState.favoritesOnly,favorites=emoteState.favorites})) end
			end)
		end
		local function stopEmote()
			if emoteState.track then pcall(function() emoteState.track:Stop(0.12) end) end
			emoteState.track=nil
			if emoteState.stopPrevious then
				local c=localplr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
				if h then pcall(function() for _,t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop(0.12) end end) end
			end
		end
		local function getHumanoid()
			local c=localplr.Character; return c and c:FindFirstChildOfClass("Humanoid")
		end
		local function playEmote(item)
			local h=getHumanoid(); if not h then notifyEmote("R15 character not ready") return end
			if h.RigType ~= Enum.HumanoidRigType.R15 then notifyEmote("This emote browser supports R15 only") return end
			if emoteState.stopPrevious then stopEmote() end
			local track
			local ok=pcall(function() track=h:PlayEmoteAndGetAnimTrackById(tonumber(item.id)) end)
			if not track then
				local a=Instance.new("Animation"); a.AnimationId="rbxassetid://"..tostring(item.id)
				local animator=h:FindFirstChildOfClass("Animator") or Instance.new("Animator",h)
				ok,track=pcall(function() return animator:LoadAnimation(a) end)
			end
			if not ok or not track then notifyEmote("Could not load "..tostring(item.name)); return end
			emoteState.track=track
			track.Priority=Enum.AnimationPriority.Action
			track.Looped=emoteState.loop
			track:Play(0.12)
			track:AdjustSpeed(emoteState.freeze and 0 or emoteState.speed)
			notifyEmote("Playing "..tostring(item.name))
		end
		local function make(class, props, parent)
			local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end; o.Parent=parent; return o
		end
		local function styleButton(b, accent)
			b.BackgroundColor3=accent and Color3.fromRGB(70,92,150) or Color3.fromRGB(44,48,62); b.TextColor3=Color3.fromRGB(235,240,255); b.Font=Enum.Font.GothamSemibold; b.TextSize=12; make("UICorner",{CornerRadius=UDim.new(0,6)},b)
		end
		local function clearConnections()
			for _,c in ipairs(emoteState.connections) do pcall(function() c:Disconnect() end) end; emoteState.connections={}
		end
		local function filterData()
			emoteState.filtered={}; local q=emoteState.search:lower()
			for _,item in ipairs(emoteState.data) do
				local match=q=="" or tostring(item.name):lower():find(q,1,true) or tostring(item.id):find(q,1,true)
				local fav=emoteState.favorites[tostring(item.id)]==true
				if match and (not emoteState.favoritesOnly or fav) then table.insert(emoteState.filtered,item) end
			end
			emoteState.pageNo=math.max(1,math.min(emoteState.pageNo,math.max(1,math.ceil(#emoteState.filtered/emoteState.pageSize))))
		end
		local renderCards
		local function loadCatalog()
			task.spawn(function()
				local loaded
				pcall(function()
					local raw=game:HttpGet(emoteCatalogUrl); local json=HttpService:JSONDecode(raw); local rows=json and json.data or json
					if type(rows)=="table" then loaded={}; for _,v in pairs(rows) do local id=tonumber(v.id); if id and id>0 then table.insert(loaded,{id=id,name=v.name or ("Emote "..id)}) end end end
				end)
				emoteState.data=(loaded and #loaded>0) and loaded or fallbackEmotes; filterData(); if renderCards then renderCards() end
				notifyEmote(#emoteState.data.." R15 emotes available")
			end)
		end
		local function makeWindow()
			if emoteState.gui and emoteState.gui.Parent then emoteState.gui.Enabled=true; return end
			loadEmoteSettings()
			local sg=make("ScreenGui",{Name="TCOEmotes",ResetOnSpawn=false,DisplayOrder=120},nil); pcall(function() sg.Parent=game:GetService("CoreGui") end); if not sg.Parent then sg.Parent=localplr:WaitForChild("PlayerGui") end; emoteState.gui=sg
			local panel=make("Frame",{Name="Main",Size=UDim2.fromOffset(500,430),Position=UDim2.new(.5,-250,.5,-215),BackgroundColor3=Color3.fromRGB(24,27,38),Active=true},sg); make("UICorner",{CornerRadius=UDim.new(0,10)},panel); make("UIStroke",{Color=Color3.fromRGB(93,115,190),Thickness=1.5,Transparency=.25},panel)
			local bar=make("TextButton",{Name="TitleBar",Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(32,36,50),Text="  GUY HUB  •  R15 EMOTES",TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false},panel); styleButton(bar,true)
			local close=make("TextButton",{Size=UDim2.fromOffset(30,28),Position=UDim2.new(1,-34,0,4),Text="X",BackgroundColor3=Color3.fromRGB(120,55,70)},bar); styleButton(close,false)
			local mini=make("TextButton",{Size=UDim2.fromOffset(30,28),Position=UDim2.new(1,-68,0,4),Text="-"},bar); styleButton(mini,false)
			local tabs=make("Frame",{Size=UDim2.new(1,-16,0,34),Position=UDim2.fromOffset(8,44),BackgroundTransparency=1},panel)
			local tabButtons={}; local pages={}
			local function addTab(name,x)
				local b=make("TextButton",{Size=UDim2.new(1/3,-5,1,0),Position=UDim2.new(x,0,0,0),Text=name,BackgroundColor3=Color3.fromRGB(44,48,62)},tabs); styleButton(b,false); tabButtons[name]=b
				local pg=make("Frame",{Name=name.."Page",Size=UDim2.new(1,-16,1,-88),Position=UDim2.fromOffset(8,82),BackgroundTransparency=1,Visible=name=="Emotes"},panel); pages[name]=pg
				b.MouseButton1Click:Connect(function() for n,p in pairs(pages) do p.Visible=n==name end end)
				return pg
			end
			local ep=addTab("Emotes",0); local sp=addTab("Speed",1/3); local stp=addTab("Settings",2/3); emoteState.page=ep; emoteState.speedPage=sp; emoteState.settingsPage=stp
			local search=make("TextBox",{Size=UDim2.new(1,-150,0,30),Position=UDim2.fromOffset(0,0),PlaceholderText="Search emote name or ID...",Text="",ClearTextOnFocus=false,BackgroundColor3=Color3.fromRGB(38,42,55),TextColor3=Color3.new(1,1,1),PlaceholderColor3=Color3.fromRGB(150,155,170),Font=Enum.Font.Gotham,TextSize=12},ep); make("UICorner",{CornerRadius=UDim.new(0,6)},search)
			local refresh=make("TextButton",{Size=UDim2.fromOffset(70,30),Position=UDim2.new(1,-70,0,0),Text="Refresh"},ep); styleButton(refresh,true)
			local stop=make("TextButton",{Size=UDim2.fromOffset(70,30),Position=UDim2.new(1,-145,0,0),Text="Stop"},ep); styleButton(stop,false)
			local grid=make("ScrollingFrame",{Size=UDim2.new(1,0,1,-72),Position=UDim2.fromOffset(0,38),BackgroundTransparency=1,ScrollBarThickness=5,CanvasSize=UDim2.new()},ep); local layout=make("UIGridLayout",{CellSize=UDim2.fromOffset(112,130),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder},grid)
			local pageLabel=make("TextLabel",{Size=UDim2.fromOffset(180,26),Position=UDim2.new(.5,-90,1,-28),BackgroundTransparency=1,TextColor3=Color3.fromRGB(210,220,240),Text="",Font=Enum.Font.Gotham,TextSize=12},ep)
			local prev=make("TextButton",{Size=UDim2.fromOffset(70,26),Position=UDim2.fromOffset(0,0),Text="Previous"},ep); styleButton(prev,false); prev.Position=UDim2.new(0,0,1,-28)
			local next=make("TextButton",{Size=UDim2.fromOffset(70,26),Position=UDim2.new(1,-70,1,-28),Text="Next"},ep); styleButton(next,false)
			local function addSetting(parent,y,label,value,cb)
				local b=make("TextButton",{Size=UDim2.new(1,0,0,34),Position=UDim2.fromOffset(0,y),Text=label..": "..tostring(value),TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=Color3.fromRGB(38,42,55)},parent); styleButton(b,false); b.MouseButton1Click:Connect(function() local v=cb(); b.Text=label..": "..tostring(v) end); return b
			end
			local speedBox=make("TextBox",{Size=UDim2.new(1,0,0,34),Position=UDim2.fromOffset(0,0),Text=tostring(emoteState.speed),PlaceholderText="Speed 0–5",BackgroundColor3=Color3.fromRGB(38,42,55),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=13},sp); make("UICorner",{CornerRadius=UDim.new(0,6)},speedBox)
			local speedHint=make("TextLabel",{Size=UDim2.new(1,0,0,45),Position=UDim2.fromOffset(0,40),BackgroundTransparency=1,Text="Playback speed. 0 freezes the current emote; values above 1 are faster.",TextWrapped=true,TextColor3=Color3.fromRGB(180,190,210),Font=Enum.Font.Gotham,TextSize=12},sp)
			local apply=make("TextButton",{Size=UDim2.new(1,0,0,34),Position=UDim2.fromOffset(0,90),Text="Apply speed"},sp); styleButton(apply,true)
			addSetting(sp,135,"Loop emotes",emoteState.loop,function() emoteState.loop=not emoteState.loop; saveEmoteSettings(); return emoteState.loop end)
			addSetting(sp,175,"Freeze emote",emoteState.freeze,function() emoteState.freeze=not emoteState.freeze; if emoteState.track then pcall(function() emoteState.track:AdjustSpeed(emoteState.freeze and 0 or emoteState.speed) end) end; return emoteState.freeze end)
			addSetting(stp,0,"Stop previous tracks",emoteState.stopPrevious,function() emoteState.stopPrevious=not emoteState.stopPrevious; saveEmoteSettings(); return emoteState.stopPrevious end)
			addSetting(stp,40,"Stop on respawn",emoteState.stopOnRespawn,function() emoteState.stopOnRespawn=not emoteState.stopOnRespawn; saveEmoteSettings(); return emoteState.stopOnRespawn end)
			addSetting(stp,80,"Show asset IDs",emoteState.showIds,function() emoteState.showIds=not emoteState.showIds; saveEmoteSettings(); if renderCards then renderCards() end; return emoteState.showIds end)
			addSetting(stp,120,"Favorites only",emoteState.favoritesOnly,function() emoteState.favoritesOnly=not emoteState.favoritesOnly; saveEmoteSettings(); filterData(); if renderCards then renderCards() end; return emoteState.favoritesOnly end)
			make("TextLabel",{Size=UDim2.new(1,0,0,80),Position=UDim2.fromOffset(0,170),BackgroundTransparency=1,Text="R15 only\nCatalog supplied by 7yd7/sniper-Emote\nClick the star on a card to save favorites.",TextColor3=Color3.fromRGB(180,190,210),Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true},stp)
			renderCards=function()
				for _,c in ipairs(grid:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
				filterData(); local total=math.max(1,math.ceil(#emoteState.filtered/emoteState.pageSize)); local first=(emoteState.pageNo-1)*emoteState.pageSize+1; local last=math.min(#emoteState.filtered,first+emoteState.pageSize-1)
				for i=first,last do local item=emoteState.filtered[i]; local card=make("Frame",{BackgroundColor3=Color3.fromRGB(32,36,48)},grid); make("UICorner",{CornerRadius=UDim.new(0,7)},card); local img=make("ImageButton",{Size=UDim2.new(1,-10,0,82),Position=UDim2.fromOffset(5,5),BackgroundColor3=Color3.fromRGB(22,25,34),Image="rbxthumb://type=Asset&id="..tostring(item.id).."&w=150&h=150",ScaleType=Enum.ScaleType.Fit},card); make("UICorner",{CornerRadius=UDim.new(0,6)},img); local name=make("TextLabel",{Size=UDim2.new(1,-8,0,30),Position=UDim2.fromOffset(4,88),BackgroundTransparency=1,Text=tostring(item.name)..(emoteState.showIds and "\n"..tostring(item.id) or ""),TextColor3=Color3.fromRGB(235,240,255),Font=Enum.Font.GothamSemibold,TextSize=10,TextWrapped=true},card); local fav=make("TextButton",{Size=UDim2.fromOffset(22,22),Position=UDim2.new(1,-26,0,4),Text=emoteState.favorites[tostring(item.id)] and "★" or "☆",BackgroundTransparency=0.25,BackgroundColor3=Color3.fromRGB(45,48,60),TextColor3=Color3.fromRGB(255,220,90),TextSize=16},card); make("UICorner",{CornerRadius=UDim.new(1,0)},fav); img.MouseButton1Click:Connect(function() playEmote(item) end); fav.MouseButton1Click:Connect(function() local k=tostring(item.id); emoteState.favorites[k]=not emoteState.favorites[k]; fav.Text=emoteState.favorites[k] and "★" or "☆"; saveEmoteSettings() end) end
				pageLabel.Text=(#emoteState.filtered==0 and "No matching emotes" or ("Page "..emoteState.pageNo.." / "..total.."  •  "..#emoteState.filtered.." results)); grid.CanvasSize=UDim2.fromOffset(0,math.ceil(math.max(1,last-first+1)/4)*138)
			end
			search:GetPropertyChangedSignal("Text"):Connect(function() emoteState.search=search.Text; emoteState.pageNo=1; renderCards() end); refresh.MouseButton1Click:Connect(loadCatalog); stop.MouseButton1Click:Connect(stopEmote); prev.MouseButton1Click:Connect(function() emoteState.pageNo=math.max(1,emoteState.pageNo-1); renderCards() end); next.MouseButton1Click:Connect(function() emoteState.pageNo=emoteState.pageNo+1; renderCards() end); apply.MouseButton1Click:Connect(function() emoteState.speed=math.clamp(tonumber(speedBox.Text) or 1,0,5); speedBox.Text=tostring(emoteState.speed); saveEmoteSettings(); if emoteState.track then pcall(function() emoteState.track:AdjustSpeed(emoteState.freeze and 0 or emoteState.speed) end) end end)
			local dragging=false; local dragStart, panelStart
			emoteState.connections[#emoteState.connections+1]=bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=i.Position; panelStart=panel.Position end end)
			emoteState.connections[#emoteState.connections+1]=UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dragStart; panel.Position=UDim2.new(panelStart.X.Scale,panelStart.X.Offset+d.X,panelStart.Y.Scale,panelStart.Y.Offset+d.Y) end end)
		emoteState.connections[#emoteState.connections+1]=UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
			mini.MouseButton1Click:Connect(function() emoteState.minimized=not emoteState.minimized; for _,v in ipairs(panel:GetChildren()) do if v~=bar and v~=close and v~=mini and v:IsA("GuiObject") then v.Visible=not emoteState.minimized end end; panel.Size=emoteState.minimized and UDim2.fromOffset(500,36) or UDim2.fromOffset(500,430) end)
			close.MouseButton1Click:Connect(function() stopEmote(); clearConnections(); sg:Destroy(); emoteState.gui=nil end)
			if emoteState.stopOnRespawn then emoteState.connections[#emoteState.connections+1]=localplr.CharacterAdded:Connect(function() stopEmote() end) end
			renderCards(); loadCatalog()
		end
		lib.makebutton("Load Emote GUI", emotestab, makeWindow)
		lib.makelabel("R15 emote browser • search, speed, freeze, favorites", emotestab)
	end
	getgenv()._tcoP = getgenv()._tcoP or {}
	local S = getgenv()._tcoP
	local function hum()
		local c = localplr.Character
		return c and c:FindFirstChildOfClass("Humanoid")
	end
	local function hrp()
		local c = localplr.Character
		return c and c:FindFirstChild("HumanoidRootPart")
	end
	local function notifyP(t)
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Player", Text = tostring(t), Duration = 2})
		end)
	end
	local function playerNames()
		return playerDropdownList(false)
	end
	local function getSel()
		if not S.selName then return nil end
		return game.Players:FindFirstChild(S.selName)
	end
	lib.makelabel("
	local function getEnlightenTool()
		local function findArk(container)
			if not container then return nil end
			local t = container:FindFirstChild("The Arkenstone") or container:FindFirstChild("Enlighten") or container:FindFirstChild("Arkenstone")
			return t
		end
		return findArk(localplr.Backpack) or findArk(localplr.Character)
	end
	local function hideToolVisual(tool)
		if not tool then return end
		pcall(function()
			for _, d in pairs(tool:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Transparency = 1
					d.CanCollide = false
					d.Size = Vector3.new(0.05, 0.05, 0.05)
				elseif d:IsA("Decal") or d:IsA("Texture") then
					d.Transparency = 1
				elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
					d.Enabled = false
				end
			end
			if tool:IsA("Tool") then
				pcall(function()
					tool.RequiresHandle = false
					tool.CanBeDropped = false
					tool.Grip = CFrame.new(0, -2, -1)
				end)
			end
		end)
	end
	local function stopToolHoldAnim()
		pcall(function()
			local char = localplr.Character
			if not char then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				for _, track in pairs(hum:GetPlayingAnimationTracks()) do
					local n = string.lower(track.Name or "")
					if string.find(n, "tool") or string.find(n, "animation") then
						track:Stop(0)
					end
				end
			end
			for _, d in pairs(char:GetDescendants()) do
				if d.Name == "RightGrip" or d.Name == "LeftGrip" then
					d:Destroy()
				end
			end
			local rh = char:FindFirstChild("RightHand")
			if rh then
				for _, d in pairs(rh:GetChildren()) do
					if d:IsA("Motor6D") and (d.Name == "RightGrip" or string.find(string.lower(d.Name), "grip")) then
						d:Destroy()
					end
				end
			end
		end)
	end
	local function refreshEnlightenTool()
		local tool = getEnlightenTool()
		if not tool then return false end
		local char = localplr.Character
		if not char then return false end
		if tool.Parent == char then
			local t = 0
			while tool.Parent == char and t < 12 do
				pcall(function() tool.Parent = localplr.Backpack end)
				t = t + 1
				task.wait()
			end
			return true
		end
		pcall(function()
			if tool.Parent == localplr.Backpack then tool.Parent = char end
		end)
		local t = 0
		while tool.Parent == char and t < 12 do
			pcall(function() tool.Parent = localplr.Backpack end)
			t = t + 1
			task.wait()
		end
		return true
	end
	local function refreshArkenstoneTool()
		local tool = getEnlightenTool()
		if not tool then return false end
		local char = localplr.Character
		local bag = localplr.Backpack
		if not char or not bag then return false end
		hideToolVisual(tool)
		pcall(function()
			if tool.Parent == bag then
				tool.Parent = char
			end
		end)
		pcall(function()
			game:GetService("RunService").Heartbeat:Wait()
		end)
		pcall(function()
			if tool.Parent == char then
				tool.Parent = bag
			end
		end)
		stopToolHoldAnim()
		hideToolVisual(tool)
		return true
	end
	local function joinChosenOneServer(kind)
		task.spawn(function()
			local ok, err = pcall(function()
				local ts = game:GetService("TeleportService")
				local hs = game:GetService("HttpService")
				local placeId, current = game.PlaceId, game.JobId
				local body = game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
				local data = hs:JSONDecode(body)
				local candidates = {}
				for _, server in ipairs((data and data.data) or {}) do
					if server.id ~= current and server.playing < server.maxPlayers then candidates[#candidates+1] = server end
				end
				if #candidates == 0 then ts:Teleport(placeId, localplr) return end
				local chosen = candidates[1]
				if kind == "xl" then
					for _, server in ipairs(candidates) do
						if server.maxPlayers > chosen.maxPlayers or (server.maxPlayers == chosen.maxPlayers and server.playing < chosen.playing) then chosen = server end
					end
				else
					for _, server in ipairs(candidates) do if server.playing < chosen.playing then chosen = server end end
				end
				ts:TeleportToPlaceInstance(placeId, chosen.id, localplr)
			end)
			if not ok then notifyP("Server join failed: "..tostring(err)) end
		end)
	end
	lib.makebutton("Join XL server", ptab, function() joinChosenOneServer("xl") end)
	lib.makebutton("Join OG server", ptab, function() joinChosenOneServer("og") end)
	lib.makebutton("Rejoin", ptab, function()
		local ok, err = pcall(function()
			game:GetService("TeleportService"):Teleport(game.PlaceId, localplr)
		end)
		if not ok then notifyP("Rejoin failed: "..tostring(err)) end
	end)
	lib.makebutton("Server hop", ptab, function()
		task.spawn(function()
			pcall(function()
				local ts = game:GetService("TeleportService")
				local http = game:GetService("HttpService")
				local placeId = game.PlaceId
				local jobId = game.JobId
				local servers = {}
				local cursor = ""
				local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
				local body = game:HttpGet(url)
				local data = http:JSONDecode(body)
				if data and data.data then
					for _, s in pairs(data.data) do
						if s.id ~= jobId and s.playing < s.maxPlayers then
							table.insert(servers, s.id)
						end
					end
				end
				if #servers > 0 then
					ts:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], localplr)
				else
					ts:Teleport(placeId)
				end
			end)
		end)
	end)
	lib.makelabel("--- Movement ---", ptab)
	lib.maketextbox("WalkSpeed value", ptab, function(txt)
		local n = tonumber(txt)
		if n then S.ws = n notifyP("WS set " .. n) end
	end)
	lib.maketoggle("Loop WalkSpeed", ptab, function(bool)
		S.loopWS = bool
		if not bool then return end
		task.spawn(function()
			while S.loopWS do
				pcall(function()
					local h = hum()
					if h then h.WalkSpeed = S.ws or 16 end
				end)
				task.wait(0.1)
			end
		end)
	end, false)
	lib.maketextbox("JumpPower value", ptab, function(txt)
		local n = tonumber(txt)
		if n then S.jp = n notifyP("JP set " .. n) end
	end)
	lib.maketoggle("Loop JumpPower", ptab, function(bool)
		S.loopJP = bool
		if not bool then return end
		task.spawn(function()
			while S.loopJP do
				pcall(function()
					local h = hum()
					if h then
						h.JumpPower = S.jp or 50
						pcall(function() h.JumpHeight = (S.jp or 50) / 20 end)
					end
				end)
				task.wait(0.1)
			end
		end)
	end, false)
	lib.maketoggle("Infinite Jump", ptab, function(bool)
		S.infJump = bool
		if S.infJumpConn then pcall(function() S.infJumpConn:Disconnect() end) S.infJumpConn = nil end
		if not bool then return end
		S.infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
			if not S.infJump then return end
			pcall(function()
				local h = hum()
				if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		end)
	end, false)
	lib.makelabel("--- Fling target ---", flingtab)
	local function flingNotify(t)
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Fling", Text = tostring(t), Duration = 2})
		end)
	end
	local flingDrop = lib.makedropdown("Fling target", flingtab, playerNames(), function(sel)
		S.selName = sel
		getgenv()._tcoFlingTarget = sel
		flingNotify("Target: " .. tostring(sel))
	end)
	lib.makebutton("Refresh fling targets", flingtab, function()
		pcall(function() lib.updatedropdown(flingDrop, playerNames()) end)
	end)
	lib.makebutton("Give target tool (click a player)", flingtab, function()
		pcall(function()
			local bag = localplr.Backpack
			local old = bag:FindFirstChild("TCO Target Tool") or (localplr.Character and localplr.Character:FindFirstChild("TCO Target Tool"))
			if old then old:Destroy() end
			local tool = Instance.new("Tool")
			tool.Name = "TCO Target Tool"
			tool.RequiresHandle = true
			tool.CanBeDropped = false
			local handle = Instance.new("Part")
			handle.Name = "Handle"
			handle.Size = Vector3.new(1, 1, 1)
			handle.Transparency = 0.3
			handle.Color = Color3.fromRGB(255, 80, 80)
			handle.Parent = tool
			tool.Parent = bag
			tool.Activated:Connect(function()
				pcall(function()
					local mouse = localplr:GetMouse()
					local target = mouse.Target
					if not target then return end
					local model = target:FindFirstAncestorOfClass("Model")
					local plr = model and game.Players:GetPlayerFromCharacter(model)
					if plr and plr ~= localplr then
						S.selName = plr.Name
						getgenv()._tcoFlingTarget = plr.Name
						flingNotify("Selected " .. plr.DisplayName)
					end
				end)
			end)
			local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum:EquipTool(tool) end
			flingNotify("Target tool ready - click a player")
		end)
	end)
		lib.makelabel("--- Walk fling ---", flingtab)
	lib.maketextbox("Walk fling power (default 10000)", flingtab, function(txt)
		local n = tonumber(txt)
		if n then S.wfPower = n flingNotify("Power " .. n) end
	end)
	getgenv()._tcoHiddenFling = false
	lib.maketoggle("Walk Fling", flingtab, function(bool)
		S.walkFling = bool
		getgenv()._tcoHiddenFling = bool
		if not bool then return end
		task.spawn(function()
			local RS = game:GetService("RunService")
			local hrp, ch, vel, movel = nil, nil, nil, 0.1
			while S.walkFling do
				RS.Heartbeat:Wait()
				if not S.walkFling then break end
				pcall(function()
					while S.walkFling and not (ch and ch.Parent and hrp and hrp.Parent) do
						RS.Heartbeat:Wait()
						ch = localplr.Character
						hrp = ch and (ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso"))
					end
					if not S.walkFling or not hrp then return end
					local power = S.wfPower or 10000
					vel = hrp.Velocity
					hrp.Velocity = vel * power + Vector3.new(0, power, 0)
					RS.RenderStepped:Wait()
					if ch and ch.Parent and hrp and hrp.Parent then
						hrp.Velocity = vel
					end
					RS.Stepped:Wait()
					if ch and ch.Parent and hrp and hrp.Parent then
						hrp.Velocity = vel + Vector3.new(0, movel, 0)
						movel = movel * -1
					end
				end)
			end
		end)
	end, false)
	lib.makelabel("--- Shield / radius settings ---", flingtab)
	S.orbitRadius = S.orbitRadius or 18
	S.orbitSpin = S.orbitSpin or 2.4
	S.protectRadius = S.protectRadius or 25
	S.selfFlingRadius = S.selfFlingRadius or 20
	lib.maketextbox("Orbit shield radius (default 18)", flingtab, function(txt)
		local n = tonumber(txt)
		if n and n > 0 then S.orbitRadius = n flingNotify("Orbit radius " .. n) end
	end)
	lib.maketextbox("Orbit spin speed (default 2.4, higher = faster)", flingtab, function(txt)
		local n = tonumber(txt)
		if n and n > 0 then S.orbitSpin = n flingNotify("Spin " .. n) end
	end)
	lib.maketextbox("Protect fling aura radius (default 25)", flingtab, function(txt)
		local n = tonumber(txt)
		if n and n > 0 then S.protectRadius = n flingNotify("Protect radius " .. n) end
	end)
	lib.maketextbox("Fling aura (yourself) radius (default 20)", flingtab, function(txt)
		local n = tonumber(txt)
		if n and n > 0 then S.selfFlingRadius = n flingNotify("Self aura radius " .. n) end
	end)
	lib.makelabel("--- Fling actions ---", flingtab)
	local function flingOnce5s(targetHRP)
		if not targetHRP or typeof(flingWithReturn) ~= "function" then return end
		flingWithReturn(targetHRP, 5, true)
	end
	lib.makebutton("Fling once (selected)", flingtab, function()
		local p = getSel()
		if not p or not p.Character then flingNotify("No target") return end
		local th = p.Character:FindFirstChild("HumanoidRootPart")
		if th then flingOnce5s(th) flingNotify("Fling 5s done") end
	end)
	lib.maketoggle("Loop fling selected", flingtab, function(bool)
		S.flingSel = bool
		local home = hrp() and hrp().CFrame
		if not bool then
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
			return
		end
		task.spawn(function()
			home = hrp() and hrp().CFrame
			while S.flingSel do
				pcall(function()
					local p = getSel()
					local th = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					if th and typeof(flingHold) == "function" then flingHold(th) end
				end)
				task.wait()
			end
			if typeof(tcoSoftReturnHome) == "function" then tcoSoftReturnHome(home)
			else
				pcall(function()
					local my = hrp()
					if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
				end)
			end
		end)
	end, false)
	lib.maketoggle("Loop fling ALL", flingtab, function(bool)
		S.loopFlingAll = bool
		local home = hrp() and hrp().CFrame
		if not bool then
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
			return
		end
		task.spawn(function()
			home = hrp() and hrp().CFrame
			while S.loopFlingAll do
				for _, p in ipairs(game.Players:GetPlayers()) do
					if not S.loopFlingAll then break end
					if p ~= localplr and p.Character then
						local th = p.Character:FindFirstChild("HumanoidRootPart")
						if th and typeof(flingHold) == "function" then
							pcall(function() flingHold(th, 0.35) end)
						end
					end
				end
				task.wait(0.05)
			end
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
		end)
	end, false)
	lib.makebutton("Fling all once", flingtab, function()
		local home = hrp() and hrp().CFrame
		for _, p in ipairs(game.Players:GetPlayers()) do
			if p ~= localplr and p.Character then
				local th = p.Character:FindFirstChild("HumanoidRootPart")
				if th then pcall(function() flingOnce5s(th) end) end
			end
		end
		pcall(function()
			local my = hrp()
			if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
		end)
		flingNotify("Fling all once done")
	end)
	lib.maketoggle("Kill fling (selected)", flingtab, function(bool)
		S.killFling = bool
		local home = hrp() and hrp().CFrame
		if not bool then
			if typeof(tcoSoftReturnHome) == "function" then tcoSoftReturnHome(home) end
			return
		end
		task.spawn(function()
			home = hrp() and hrp().CFrame
			local t0 = tick()
			while S.killFling and (tick() - t0) < 8 do
				pcall(function()
					local p = getSel()
					local th = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					if th and typeof(killFlingHold) == "function" then killFlingHold(th) end
				end)
				task.wait()
			end
			S.killFling = false
			if typeof(tcoSoftReturnHome) == "function" then tcoSoftReturnHome(home) end
		end)
	end, false)
	lib.makebutton("Kill fling once (selected, 5s)", flingtab, function()
		local p = getSel()
		if not p or not p.Character then flingNotify("No target") return end
		local th = p.Character:FindFirstChild("HumanoidRootPart")
		if th and typeof(killFlingHold) == "function" then
			local home = hrp() and hrp().CFrame
			local t0 = tick()
			while tick() - t0 < 5 do
				pcall(function() killFlingHold(th) end)
				task.wait()
			end
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
			flingNotify("Kill fling done")
		end
	end)
	lib.maketoggle("Orbit shield fling (selected)", flingtab, function(bool)
		S.orbitFling = bool
		local home = hrp() and hrp().CFrame
		if not bool then
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
			return
		end
		task.spawn(function()
			home = hrp() and hrp().CFrame
			local ang = 0
			while S.orbitFling do
				pcall(function()
					local sel = getSel()
					local center = sel and sel.Character and sel.Character:FindFirstChild("HumanoidRootPart")
					local my = hrp()
					if not my or not center then return end
					local rad = S.orbitRadius or 12
					local spin = S.orbitSpin or 0.85
					ang = ang + spin
					my.CFrame = center.CFrame * CFrame.Angles(0, ang, 0) * CFrame.new(0, 0, -math.max(3, rad * 0.35))
					for _, other in pairs(game.Players:GetPlayers()) do
						if other ~= localplr and other ~= sel and other.Character then
							local oh = other.Character:FindFirstChild("HumanoidRootPart")
							if oh and (oh.Position - center.Position).Magnitude <= rad then
								if typeof(flingHold) == "function" then flingHold(oh, 0.25) end
							end
						end
					end
				end)
				task.wait()
			end
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
		end)
	end, false)
	lib.maketoggle("Protect fling aura (selected)", flingtab, function(bool)
		S.protectFling = bool
		local home = hrp() and hrp().CFrame
		if not bool then
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
			return
		end
		task.spawn(function()
			home = hrp() and hrp().CFrame
			while S.protectFling do
				pcall(function()
					local p = getSel()
					local th = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					if not th then return end
					local rad = S.protectRadius or 25
					local best, bd = nil, rad
					for _, other in pairs(game.Players:GetPlayers()) do
						if other ~= localplr and other ~= p and other.Character then
							local oh = other.Character:FindFirstChild("HumanoidRootPart")
							if oh then
								local d = (oh.Position - th.Position).Magnitude
								if d < bd then best, bd = oh, d end
							end
						end
					end
					if best and typeof(flingHold) == "function" then flingHold(best, 0.4) end
				end)
				task.wait(0.08)
			end
			pcall(function()
				local my = hrp()
				if my and home then my.CFrame = home my.AssemblyLinearVelocity = Vector3.zero end
			end)
		end)
	end, false)
	lib.maketoggle("Fling aura (for yourself)", flingtab, function(bool)
		S.selfFlingAura = bool
		local home = hrp() and hrp().CFrame
		if not bool then
			if typeof(tcoSoftReturnHome) == "function" then tcoSoftReturnHome(home) end
			return
		end
		task.spawn(function()
			home = hrp() and hrp().CFrame
			while S.selfFlingAura do
				pcall(function()
					local my = hrp()
					if not my then return end
					local rad = S.selfFlingRadius or 20
					for _, other in pairs(game.Players:GetPlayers()) do
						if other ~= localplr and other.Character then
							local oh = other.Character:FindFirstChild("HumanoidRootPart")
							if oh and (oh.Position - my.Position).Magnitude <= rad then
								local v = Vector3.new((math.random()-0.5)*3e4, 3e4, (math.random()-0.5)*3e4)
								oh.AssemblyLinearVelocity = v
								pcall(function() oh.Velocity = v end)
							end
						end
					end
				end)
				task.wait(0.08)
			end
			if typeof(tcoSoftReturnHome) == "function" then tcoSoftReturnHome(home) end
		end)
	end, false)
	lib.maketoggle("Fling on touch (collision)", flingtab, function(bool)
		S.touchFling = bool
		if not bool then return end
		task.spawn(function()
			while S.touchFling do
				pcall(function()
					local my = hrp()
					if not my then return end
					for _, p in pairs(game.Players:GetPlayers()) do
						if p ~= localplr and p.Character then
							local th = p.Character:FindFirstChild("HumanoidRootPart")
							if th and (th.Position - my.Position).Magnitude < 4.5 then
								th.AssemblyLinearVelocity = Vector3.new((math.random()-0.5)*3.5e4, 3.5e4, (math.random()-0.5)*3.5e4)
								pcall(function() th.Velocity = th.AssemblyLinearVelocity end)
							end
						end
					end
				end)
				task.wait(0.05)
			end
		end)
	end, false)
	lib.maketextbox("Sky lift speed (default 120)", flingtab, function(txt)
		local n = tonumber(txt)
		if n and n > 0 then S.skyLiftSpeed = n end
	end)
	lib.maketoggle("Sky lift (selected)", flingtab, function(bool)
		S.skyLift = bool
		local home = hrp() and hrp().CFrame
		if not bool then
			pcall(function()
				local my = hrp()
				if my then
					for _, p in pairs(localplr.Character and localplr.Character:GetDescendants() or {}) do
						if p:IsA("BasePart") then p.CanCollide = true end
					end
				end
			end)
			if typeof(tcoSoftReturnHome) == "function" then tcoSoftReturnHome(home) end
			return
		end
		task.spawn(function()
			home = hrp() and hrp().CFrame
			local bv = nil
			while S.skyLift do
				pcall(function()
					local p = getSel()
					local th = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					local my = hrp()
					local char = localplr.Character
					if not my or not th or not char then return end
					for _, part in pairs(char:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = false end
					end
					local under = th.Position + Vector3.new(0, -3.2, 0)
					my.CFrame = CFrame.new(under) * CFrame.Angles(-math.pi/2, 0, 0)
					if not bv or not bv.Parent then
						bv = Instance.new("BodyVelocity")
						bv.Name = "TCOSkyLift"
						bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						bv.Parent = my
					end
					local spd = S.skyLiftSpeed or 120
					bv.Velocity = Vector3.new(0, spd, 0)
					th.AssemblyLinearVelocity = Vector3.new(th.AssemblyLinearVelocity.X * 0.2, math.max(th.AssemblyLinearVelocity.Y, spd * 0.85), th.AssemblyLinearVelocity.Z * 0.2)
				end)
				task.wait()
			end
			pcall(function() if bv then bv:Destroy() end end)
			if typeof(tcoSoftReturnHome) == "function" then tcoSoftReturnHome(home) end
		end)
	end, false)
	do
		local RS = game:GetService("RunService")
		local UIS = game:GetService("UserInputService")
		local TweenService = game:GetService("TweenService")
		local sonicOn = false
		local sonicSpeed = 16
		local sonicMax = 90
		local sonicBuild = 0
		local baseFov = 70
		local runTrack, abilityTrack, idleTrack = nil, nil, nil
		local abilityBusy = false
		local abilityGui = nil
		local slowAnimId = 132168791204839
		local fastAnimId = 82650166267713
		local spinAnimId = 110172609245744
		local idleAnimId = 134034549718293
		local exeIdleId = 107014191831064
		local tpAnimId = 128011595312625
		local flingAnimId = 87206842180130
		local tornadoAnimId = 76065312795694
		local dashAnimId = 128779579295748
		local superSonicId = 132602449607962
		local logos = {
			spin = "rbxthumb://type=Asset&id=12052385551&w=150&h=150",
			sprint = "rbxthumb://type=Asset&id=10491133376&w=150&h=150",
			tp = "rbxthumb://type=Asset&id=6034287594&w=150&h=150",
			tornado = "rbxthumb://type=Asset&id=136807074551057&w=150&h=150",
			dash = "rbxthumb://type=Asset&id=6034754445&w=150&h=150",
		}
		local cds = {spin=0, sprint=0, tp=0, tornado=0, dash=0}
		local cdMax = {spin=6, sprint=10, tp=8, tornado=10, dash=3}
		local function stopTracks()
			pcall(function() if runTrack then runTrack:Stop(0.15) end end)
			pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
			pcall(function() if idleTrack then idleTrack:Stop(0.15) end end)
			runTrack, abilityTrack, idleTrack = nil, nil, nil
		end
		local function loadAnim(id, priority)
			local char = localplr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hum then return nil end
			local animator = hum:FindFirstChildOfClass("Animator")
			if not animator then
				animator = Instance.new("Animator")
				animator.Parent = hum
			end
			local anim = nil
			pcall(function()
				local objects = game:GetObjects("rbxassetid://" .. tostring(id))
				if objects and #objects > 0 then
					local item = objects[1]
					if item:IsA("Animation") then
						anim = item
					else
						anim = item:FindFirstChildWhichIsA("Animation", true)
					end
				end
			end)
			if not anim then
				anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://" .. tostring(id)
			end
			local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
			if ok and track then
				track.Priority = priority or Enum.AnimationPriority.Action4
				return track
			end
			return nil
		end
		local function playRun(fast)
			pcall(function() if idleTrack then idleTrack:Stop(0.1) end end)
			pcall(function() if runTrack then runTrack:Stop(0.1) end end)
			runTrack = loadAnim(fast and fastAnimId or slowAnimId, Enum.AnimationPriority.Movement)
			if runTrack then
				runTrack.Looped = true
				runTrack:Play(0.15)
				runTrack:AdjustSpeed(fast and 1.15 or 0.85)
			end
		end
		local function playIdle()
			pcall(function() if runTrack then runTrack:Stop(0.15) end end)
			runTrack = nil
			if idleTrack and idleTrack.IsPlaying then return end
			pcall(function() if idleTrack then idleTrack:Stop(0.1) end end)
			idleTrack = loadAnim(exeIdleId or idleAnimId, Enum.AnimationPriority.Idle)
			if idleTrack then
				idleTrack.Looped = true
				idleTrack:Play(0.2)
			end
		end
		local function playAbility(id, looped)
			pcall(function() if abilityTrack then abilityTrack:Stop(0.05) end end)
			abilityTrack = loadAnim(id, Enum.AnimationPriority.Action4)
			if abilityTrack then
				abilityTrack.Looped = looped and true or false
				abilityTrack:Play(0.1)
			end
			return abilityTrack
		end
		local function setFov(fov)
			pcall(function()
				local cam = workspace.CurrentCamera
				if cam then
					TweenService:Create(cam, TweenInfo.new(0.25), {FieldOfView = fov}):Play()
				end
			end)
		end
		local function enableWalkFlingTemp(sec)
			task.spawn(function()
				local was = S.walkFling
				S.walkFling = true
				getgenv()._tcoHiddenFling = true
				local t0 = tick()
				local ch, hrp, vel, movel = nil, nil, nil, 0.1
				local power = S.wfPower or 10000
				while tick() - t0 < sec do
					RS.Heartbeat:Wait()
					pcall(function()
						ch = localplr.Character
						hrp = ch and ch:FindFirstChild("HumanoidRootPart")
						if not hrp then return end
						vel = hrp.Velocity
						hrp.Velocity = vel * power + Vector3.new(0, power, 0)
						RS.RenderStepped:Wait()
						if hrp and hrp.Parent then hrp.Velocity = vel end
						RS.Stepped:Wait()
						if hrp and hrp.Parent then
							hrp.Velocity = vel + Vector3.new(0, movel, 0)
							movel = movel * -1
						end
					end)
				end
				if not was then
					S.walkFling = false
					getgenv()._tcoHiddenFling = false
				end
			end)
		end
		local function resumeRunIfOn()
			if sonicOn then
				local moving = false
				pcall(function()
					local h = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
					moving = h and h.MoveDirection.Magnitude > 0.05
				end)
				if moving then
					playRun(sonicBuild >= 0.85)
				end
			end
		end
		local function destroyAbilityGui()
			if abilityGui then pcall(function() abilityGui:Destroy() end) abilityGui = nil end
		end
		local function makeAbilityGui()
			destroyAbilityGui()
			local isMobile = UIS.TouchEnabled == true
			local hasKeyboard = UIS.KeyboardEnabled == true
			local btnSize = (isMobile and not hasKeyboard) and 42 or 58
			local sg = Instance.new("ScreenGui")
			sg.Name = "TCOSonicAbilities"
			sg.ResetOnSpawn = false
			sg.DisplayOrder = 80
			sg.IgnoreGuiInset = true
			pcall(function() sg.Parent = game.CoreGui end)
			if not sg.Parent then sg.Parent = localplr:WaitForChild("PlayerGui") end
			abilityGui = sg
			local order = {"spin", "sprint", "tp", "tornado", "dash"}
			local names = {spin="Spin Dash", sprint="temu override", tp="surprise attack", tornado="Tornado", dash="Dash"}
			local keys = {spin="1", sprint="2", tp="3", tornado="4", dash="5"}
			local center = Instance.new("Frame")
			center.Name = "AbilityRing"
			center.BackgroundTransparency = 1
			center.Parent = sg
			if isMobile and not hasKeyboard then
				center.AnchorPoint = Vector2.new(1, 1)
				center.Position = UDim2.new(1, -8, 1, -145)
				center.Size = UDim2.new(0, (btnSize + 6) * 5 + 8, 0, btnSize + 28)
				local lay = Instance.new("UIListLayout")
				lay.FillDirection = Enum.FillDirection.Horizontal
				lay.HorizontalAlignment = Enum.HorizontalAlignment.Left
				lay.VerticalAlignment = Enum.VerticalAlignment.Bottom
				lay.SortOrder = Enum.SortOrder.LayoutOrder
				lay.Padding = UDim.new(0, 6)
				lay.Parent = center
				for i, key in ipairs(order) do
					local slot = Instance.new("Frame")
					slot.Name = key .. "Slot"
					slot.LayoutOrder = i
					slot.Size = UDim2.new(0, btnSize + 4, 0, btnSize + 24)
					slot.BackgroundTransparency = 1
					slot.Parent = center
					local nameL = Instance.new("TextLabel")
					nameL.Name = "AbilityName"
					nameL.Size = UDim2.new(1, 4, 0, 12)
					nameL.Position = UDim2.new(0.5, 0, 0, 0)
					nameL.AnchorPoint = Vector2.new(0.5, 0)
					nameL.BackgroundTransparency = 1
					nameL.Text = names[key]
					nameL.TextColor3 = Color3.fromRGB(230, 240, 255)
					nameL.TextSize = 8
					nameL.Font = Enum.Font.GothamBold
					nameL.TextTruncate = Enum.TextTruncate.AtEnd
					nameL.Parent = slot
					local btn = Instance.new("ImageButton")
					btn.Name = key
					btn.Size = UDim2.new(0, btnSize, 0, btnSize)
					btn.Position = UDim2.new(0.5, 0, 0, 13)
					btn.AnchorPoint = Vector2.new(0.5, 0)
					btn.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
					btn.Image = logos[key]
					btn.ScaleType = Enum.ScaleType.Fit
					btn.Parent = slot
					Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
					local stroke = Instance.new("UIStroke")
					stroke.Color = Color3.fromRGB(80, 180, 255)
					stroke.Thickness = 1.5
					stroke.Parent = btn
					local cd = Instance.new("Frame")
					cd.Name = "CD"
					cd.Size = UDim2.new(1, 0, 0, 0)
					cd.Position = UDim2.new(0, 0, 1, 0)
					cd.AnchorPoint = Vector2.new(0, 1)
					cd.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					cd.BackgroundTransparency = 0.45
					cd.BorderSizePixel = 0
					cd.Parent = btn
					local keyL = Instance.new("TextLabel")
					keyL.Size = UDim2.new(1, 0, 0, 11)
					keyL.Position = UDim2.new(0, 0, 1, -11)
					keyL.BackgroundTransparency = 1
					keyL.Text = keys[key]
					keyL.TextColor3 = Color3.new(1,1,1)
					keyL.TextSize = 10
					keyL.Font = Enum.Font.GothamBold
					keyL.Parent = btn
					btn.MouseButton1Click:Connect(function()
						if typeof(getgenv()._tcoSonicUse) == "function" then
							getgenv()._tcoSonicUse(key)
						end
					end)
				end
			else
				center.AnchorPoint = Vector2.new(1, 1)
				center.Position = UDim2.new(1, -8, 1, -145)
				center.Size = UDim2.new(0, (btnSize + 6) * 5 + 8, 0, btnSize + 28)
				local lay = Instance.new("UIListLayout")
				lay.FillDirection = Enum.FillDirection.Horizontal
				lay.HorizontalAlignment = Enum.HorizontalAlignment.Left
				lay.VerticalAlignment = Enum.VerticalAlignment.Bottom
				lay.SortOrder = Enum.SortOrder.LayoutOrder
				lay.Padding = UDim.new(0, 6)
				lay.Parent = center
				for i, key in ipairs(order) do
					local slot = Instance.new("Frame")
					slot.Name = key .. "Slot"
					slot.LayoutOrder = i
					slot.Size = UDim2.new(0, btnSize + 4, 0, btnSize + 24)
					slot.BackgroundTransparency = 1
					slot.Parent = center
					local nameL = Instance.new("TextLabel")
					nameL.Name = "AbilityName"
					nameL.Size = UDim2.new(1, 4, 0, 12)
					nameL.Position = UDim2.new(0.5, 0, 0, 0)
					nameL.AnchorPoint = Vector2.new(0.5, 0)
					nameL.BackgroundTransparency = 1
					nameL.Text = names[key]
					nameL.TextColor3 = Color3.fromRGB(230, 240, 255)
					nameL.TextSize = 9
					nameL.Font = Enum.Font.GothamBold
					nameL.TextTruncate = Enum.TextTruncate.AtEnd
					nameL.Parent = slot
					local btn = Instance.new("ImageButton")
					btn.Name = key
					btn.Size = UDim2.new(0, btnSize, 0, btnSize)
					btn.Position = UDim2.new(0.5, 0, 0, 13)
					btn.AnchorPoint = Vector2.new(0.5, 0)
					btn.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
					btn.Image = logos[key]
					btn.ScaleType = Enum.ScaleType.Fit
					btn.Parent = slot
					Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
					local stroke = Instance.new("UIStroke")
					stroke.Color = Color3.fromRGB(80, 160, 255)
					stroke.Thickness = 2
					stroke.Parent = btn
					local keyL = Instance.new("TextLabel")
					keyL.Size = UDim2.new(1, 0, 0, 12)
					keyL.Position = UDim2.new(0, 0, 1, -12)
					keyL.BackgroundTransparency = 1
					keyL.Text = keys[key]
					keyL.TextColor3 = Color3.new(1,1,1)
					keyL.TextSize = 11
					keyL.Font = Enum.Font.GothamBold
					keyL.Parent = btn
					btn.MouseButton1Click:Connect(function()
						if typeof(getgenv()._tcoSonicUse) == "function" then
							getgenv()._tcoSonicUse(key)
						end
					end)
				end
			end
			task.spawn(function()
				while abilityGui and abilityGui.Parent do
					for _, key in ipairs(order) do
						local slot = center:FindFirstChild(key .. "Slot")
						local btn = slot and slot:FindFirstChild(key)
						if btn and btn:FindFirstChild("CD") then
							local left = math.max(0, (cds[key] or 0) - tick())
							local max = cdMax[key] or 5
							local a = left > 0 and (left / max) or 0
							btn.CD.Size = UDim2.new(1, 0, a, 0)
						end
					end
					task.wait(0.1)
				end
			end)
		end
		local function nearestPlayerHRP()
			local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
			if not my then return nil end
			local best, bd = nil, 1e9
			for _, p in pairs(game.Players:GetPlayers()) do
				if p ~= localplr and p.Character then
					local h = p.Character:FindFirstChild("HumanoidRootPart")
					if h then
						local d = (h.Position - my.Position).Magnitude
						if d < bd then best, bd = h, d end
					end
				end
			end
			return best
		end
		getgenv()._tcoSonicUse = function(key)
			if not sonicOn or abilityBusy then return end
			if (cds[key] or 0) > tick() then return end
			abilityBusy = true
			cds[key] = tick() + (cdMax[key] or 5)
			task.spawn(function()
				local ok, err = pcall(function()
					local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
					local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
					if not my or not hum then return end
					if key == "spin" then
						pcall(function() if runTrack then runTrack:Stop(0.1) end end)
						pcall(function() if idleTrack then idleTrack:Stop(0.1) end end)
						pcall(function()
							hum.JumpPower = math.max(hum.JumpPower, 95)
							hum.JumpHeight = math.max(hum.JumpHeight or 7.2, 20)
							hum:ChangeState(Enum.HumanoidStateType.Jumping)
							my.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
						end)
						playAbility(spinAnimId, true)
						local hoverBV = Instance.new("BodyVelocity")
						hoverBV.Name = "TCOSpinHover"
						hoverBV.MaxForce = Vector3.new(5e4, 5e4, 5e4)
						hoverBV.Velocity = Vector3.new(0, 2, 0)
						hoverBV.Parent = my
						local hoverBG = Instance.new("BodyGyro")
						hoverBG.Name = "TCOSpinGyro"
						hoverBG.MaxTorque = Vector3.new(5e4, 5e4, 5e4)
						hoverBG.P = 6e3
						hoverBG.CFrame = my.CFrame
						hoverBG.Parent = my
						pcall(function() hum.PlatformStand = true end)
						local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
						local aimbotOn = false
						local aimTarget = nil
						local aimHighlight = nil
						local fired = false
						local cam = workspace.CurrentCamera
						local aimGui = Instance.new("ScreenGui")
						aimGui.Name = "TCOSonicAim"
						aimGui.IgnoreGuiInset = true
						aimGui.DisplayOrder = 120
						pcall(function() aimGui.Parent = game.CoreGui end)
						if not aimGui.Parent then aimGui.Parent = localplr.PlayerGui end
						local edge = Instance.new("Frame")
						edge.Name = "GreenEdge"
						edge.Size = UDim2.new(1, 0, 1, 0)
						edge.BackgroundTransparency = 1
						edge.BorderSizePixel = 0
						edge.Visible = false
						edge.Parent = aimGui
						local edgeStroke = Instance.new("UIStroke")
						edgeStroke.Color = Color3.fromRGB(40, 255, 90)
						edgeStroke.Thickness = 6
						edgeStroke.Transparency = 0.15
						edgeStroke.Parent = edge
						local tint = Instance.new("Frame")
						tint.Name = "GreenTint"
						tint.Size = UDim2.new(1, 0, 1, 0)
						tint.BackgroundColor3 = Color3.fromRGB(20, 180, 60)
						tint.BackgroundTransparency = 0.82
						tint.BorderSizePixel = 0
						tint.Visible = false
						tint.Parent = aimGui
						local cross = Instance.new("TextLabel")
						cross.Size = UDim2.new(0, 52, 0, 52)
						cross.AnchorPoint = Vector2.new(0.5, 0.5)
						cross.Position = UDim2.new(0.5, 0, 0.5, 0)
						cross.BackgroundTransparency = 1
						cross.Text = "+"
						cross.TextColor3 = Color3.fromRGB(80, 220, 255)
						cross.TextSize = 42
						cross.Font = Enum.Font.GothamBold
						cross.Parent = aimGui
						local hint = Instance.new("TextLabel")
						hint.Size = UDim2.new(0, 320, 0, 40)
						hint.AnchorPoint = Vector2.new(0.5, 0)
						hint.Position = UDim2.new(0.5, 0, 0.5, 32)
						hint.BackgroundTransparency = 1
						hint.Text = isMobile and "Move camera to aim — press GO to dash" or "Look to aim — LEFT CLICK dash · RIGHT CLICK aimbot"
						hint.TextColor3 = Color3.fromRGB(200, 230, 255)
						hint.TextSize = 14
						hint.Font = Enum.Font.GothamBold
						hint.TextWrapped = true
						hint.Parent = aimGui
						local abBtn = Instance.new("TextButton")
						abBtn.Name = "AimbotToggle"
						abBtn.AnchorPoint = Vector2.new(1, 0)
						abBtn.Position = UDim2.new(1, -12, 0, 12)
						abBtn.Size = UDim2.new(0, 110, 0, 36)
						abBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
						abBtn.Text = "Aimbot: OFF"
						abBtn.TextColor3 = Color3.fromRGB(180, 255, 180)
						abBtn.TextSize = 14
						abBtn.Font = Enum.Font.GothamBold
						abBtn.Parent = aimGui
						Instance.new("UICorner", abBtn).CornerRadius = UDim.new(0, 8)
						local abStroke = Instance.new("UIStroke")
						abStroke.Color = Color3.fromRGB(40, 255, 90)
						abStroke.Thickness = 1.5
						abStroke.Parent = abBtn
						local function setAimbot(on)
							aimbotOn = on
							abBtn.Text = on and "Aimbot: ON" or "Aimbot: OFF"
							abBtn.BackgroundColor3 = on and Color3.fromRGB(20, 80, 40) or Color3.fromRGB(30, 40, 35)
							edge.Visible = on
							tint.Visible = on
							cross.TextColor3 = on and Color3.fromRGB(40, 255, 90) or Color3.fromRGB(80, 220, 255)
							if not on then
								aimTarget = nil
								if aimHighlight then pcall(function() aimHighlight:Destroy() end) aimHighlight = nil end
							end
						end
						abBtn.MouseButton1Click:Connect(function()
							setAimbot(not aimbotOn)
						end)
						local goBtn = nil
						if isMobile then
							goBtn = Instance.new("TextButton")
							goBtn.Name = "GoDash"
							goBtn.AnchorPoint = Vector2.new(0.5, 1)
							goBtn.Position = UDim2.new(0.5, 0, 1, -24)
							goBtn.Size = UDim2.new(0, 160, 0, 52)
							goBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 90)
							goBtn.Text = "GO"
							goBtn.TextColor3 = Color3.new(1,1,1)
							goBtn.TextSize = 28
							goBtn.Font = Enum.Font.GothamBold
							goBtn.Parent = aimGui
							Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0, 12)
							goBtn.MouseButton1Click:Connect(function()
								fired = true
							end)
						end
						local function clearAimbotVisual()
							if aimHighlight then pcall(function() aimHighlight:Destroy() end) aimHighlight = nil end
						end
						local function updateAimbotTarget()
							if not aimbotOn then clearAimbotVisual() return end
							cam = workspace.CurrentCamera
							if not cam then return end
							local origin = cam.CFrame.Position
							local look = cam.CFrame.LookVector
							local best, bestDot, bestDist = nil, 0.55, 400
							for _, p in pairs(game.Players:GetPlayers()) do
								if p ~= localplr and p.Character then
									local hrp = p.Character:FindFirstChild("HumanoidRootPart")
									if hrp then
										local to = (hrp.Position - origin)
										local dist = to.Magnitude
										if dist > 3 and dist < bestDist then
											local dot = look:Dot(to.Unit)
											if dot > bestDot then
												bestDot = dot
												best = hrp
											end
										end
									end
								end
							end
							if best ~= aimTarget then
								aimTarget = best
								clearAimbotVisual()
								if best then
									local hl = Instance.new("Highlight")
									hl.Name = "TCOSpinAimHL"
									hl.FillColor = Color3.fromRGB(255, 40, 40)
									hl.OutlineColor = Color3.fromRGB(255, 80, 80)
									hl.FillTransparency = 0.55
									hl.OutlineTransparency = 0
									hl.Adornee = best.Parent
									hl.Parent = game.CoreGui
									aimHighlight = hl
								end
							end
						end
						task.wait(0.4)
						local conn
						if not isMobile then
							conn = UIS.InputBegan:Connect(function(inp, gp)
								if fired then return end
								if inp.UserInputType == Enum.UserInputType.MouseButton1 then
									fired = true
								elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
									setAimbot(not aimbotOn)
								end
							end)
						end
						local tAim = tick()
						while not fired and tick() - tAim < 10 do
							pcall(function()
								my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
								cam = workspace.CurrentCamera
								if my and hoverBV and hoverBV.Parent then
									hoverBV.Velocity = Vector3.new(0, 1.5, 0)
									if hoverBG and cam then
										hoverBG.CFrame = CFrame.new(my.Position, my.Position + cam.CFrame.LookVector)
									end
								end
								updateAimbotTarget()
							end)
							task.wait()
						end
						pcall(function() if conn then conn:Disconnect() end end)
						clearAimbotVisual()
						pcall(function() aimGui:Destroy() end)
						pcall(function() if hoverBV then hoverBV:Destroy() end end)
						pcall(function() if hoverBG then hoverBG:Destroy() end end)
						pcall(function()
							hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
							if hum then hum.PlatformStand = false end
						end)
						if not fired then
							pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
						else
							my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
							local homeCF = my and my.CFrame or CFrame.new()
							local start = my and my.Position or Vector3.zero
							cam = workspace.CurrentCamera
							local followTarget = aimTarget
							local dest
							if followTarget and followTarget.Parent then
								dest = followTarget.Position
							elseif cam then
								dest = start + cam.CFrame.LookVector * 280
							else
								dest = start + Vector3.new(0, 0, -280)
							end
							local wasWF = S.walkFling
							S.walkFling = true
							getgenv()._tcoHiddenFling = true
							local wfToken = {}
							getgenv()._tcoSpinWFToken = wfToken
							task.spawn(function()
								local RS = game:GetService("RunService")
								local ch, hrp, vel, movel = nil, nil, nil, 0.1
								local power = S.wfPower or 10000
								while getgenv()._tcoSpinWFToken == wfToken do
									RS.Heartbeat:Wait()
									pcall(function()
										ch = localplr.Character
										hrp = ch and ch:FindFirstChild("HumanoidRootPart")
										if not hrp then return end
										vel = hrp.Velocity
										hrp.Velocity = vel * power + Vector3.new(0, power, 0)
										RS.RenderStepped:Wait()
										if hrp and hrp.Parent then hrp.Velocity = vel end
										RS.Stepped:Wait()
										if hrp and hrp.Parent then
											hrp.Velocity = vel + Vector3.new(0, movel, 0)
											movel = movel * -1
										end
									end)
								end
							end)
							local function keepAboveGround(pos)
								local origin = pos + Vector3.new(0, 10, 0)
								local params = RaycastParams.new()
								params.FilterDescendantsInstances = {localplr.Character}
								params.FilterType = Enum.RaycastFilterType.Exclude
								local hit = workspace:Raycast(origin, Vector3.new(0, -90, 0), params)
								if hit then
									local minY = hit.Position.Y + 3.2
									if pos.Y < minY then
										pos = Vector3.new(pos.X, minY, pos.Z)
									end
								elseif pos.Y < start.Y - 1 then
									pos = Vector3.new(pos.X, start.Y, pos.Z)
								end
								return pos
							end
							local t0 = tick()
							local chaseTime = 1.2
							local speed = 95
							while tick() - t0 < chaseTime do
								pcall(function()
									my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
									if not my then return end
									if followTarget and followTarget.Parent then
										dest = followTarget.Position
										local to = dest - my.Position
										if to.Magnitude < 10 then
											my.CFrame = followTarget.CFrame
										else
											local step = math.min(to.Magnitude, 14)
											local pos = keepAboveGround(my.Position + to.Unit * step)
											my.CFrame = CFrame.new(pos, dest)
										end
										my.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
									else
										local a = math.clamp((tick() - t0) / chaseTime, 0, 1)
										local pos = keepAboveGround(start:Lerp(dest, a))
										my.CFrame = CFrame.new(pos, dest)
									end
								end)
								task.wait()
							end
							local flingT0 = tick()
							while tick() - flingT0 < 1.8 do
								pcall(function()
									my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
									if not my then return end
									if followTarget and followTarget.Parent then
										my.CFrame = followTarget.CFrame
										local v = Vector3.new((math.random() - 0.5) * 4e4, 4e4, (math.random() - 0.5) * 4e4)
										followTarget.AssemblyLinearVelocity = v
										pcall(function() followTarget.Velocity = v end)
									else
										local best, bd = nil, 12
										for _, p in pairs(game.Players:GetPlayers()) do
											if p ~= localplr and p.Character then
												local oh = p.Character:FindFirstChild("HumanoidRootPart")
												if oh then
													local d = (oh.Position - my.Position).Magnitude
													if d < bd then best, bd = oh, d end
												end
											end
										end
										if best then
											my.CFrame = best.CFrame
											local v = Vector3.new((math.random() - 0.5) * 4e4, 4e4, (math.random() - 0.5) * 4e4)
											best.AssemblyLinearVelocity = v
											pcall(function() best.Velocity = v end)
										end
									end
								end)
								task.wait()
							end
							getgenv()._tcoSpinWFToken = nil
							S.walkFling = wasWF and true or false
							getgenv()._tcoHiddenFling = S.walkFling and true or false
							pcall(function()
								my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
								if my then
									my.CFrame = homeCF
									my.AssemblyLinearVelocity = Vector3.zero
									my.AssemblyAngularVelocity = Vector3.zero
								end
							end)
							pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
						end
					elseif key == "sprint" then
						pcall(function() if runTrack then runTrack:Stop(0.1) end end)
						playAbility(superSonicId or fastAnimId, true)
						enableWalkFlingTemp(5)
						local t0 = tick()
						while tick() - t0 < 5 do
							pcall(function()
								my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
								local cam = workspace.CurrentCamera
								if my and cam then
									local dir = cam.CFrame.LookVector
									dir = Vector3.new(dir.X, 0, dir.Z)
									if dir.Magnitude > 0.05 then dir = dir.Unit end
									my.AssemblyLinearVelocity = dir * 85 + Vector3.new(0, my.AssemblyLinearVelocity.Y, 0)
									my.CFrame = CFrame.new(my.Position, my.Position + dir)
								end
							end)
							task.wait()
						end
						pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
					elseif key == "tp" then
						local home = my.CFrame
						pcall(function() if runTrack then runTrack:Stop(0.1) end end)
						playAbility(tpAnimId, false)
						task.wait(0.25)
						local locked = nearestPlayerHRP()
						if locked then
							for i = 1, 10 do
								pcall(function()
									my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
									if my and locked and locked.Parent then
										my.CFrame = locked.CFrame * CFrame.new(0, 0, 2)
									end
								end)
								task.wait(0.04)
							end
							playAbility(flingAnimId, true)
							local tF = tick()
							while tick() - tF < 2 do
								pcall(function()
									my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
									if my and locked and locked.Parent then
										my.CFrame = locked.CFrame
										local v = Vector3.new((math.random() - 0.5) * 3.5e4, 3.5e4, (math.random() - 0.5) * 3.5e4)
										locked.AssemblyLinearVelocity = v
										pcall(function() locked.Velocity = v end)
									end
								end)
								task.wait()
							end
							pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
						end
						pcall(function()
							my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
							if my then
								my.CFrame = home
								my.AssemblyLinearVelocity = Vector3.zero
								my.AssemblyAngularVelocity = Vector3.zero
							end
						end)
					elseif key == "tornado" then
						pcall(function() if runTrack then runTrack:Stop(0.1) end end)
						playAbility(tornadoAnimId, true)
						enableWalkFlingTemp(5)
						local t0 = tick()
						while tick() - t0 < 5 do
							pcall(function()
								hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
								if hum then hum.WalkSpeed = math.max(hum.WalkSpeed, 42) end
							end)
							task.wait(0.1)
						end
						pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
					elseif key == "dash" then
						pcall(function() if runTrack then runTrack:Stop(0.05) end end)
						playAbility(dashAnimId, false)
						local look = my.CFrame.LookVector
						local flat = Vector3.new(look.X, 0, look.Z)
						if flat.Magnitude < 0.05 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
						local start = my.Position
						local dest = start + flat * 55 + Vector3.new(0, 2, 0)
						local t0 = tick()
						local dur = 0.45
						while tick() - t0 < dur do
							local a = (tick() - t0) / dur
							local e = 1 - (1 - a) * (1 - a)
							pcall(function()
								my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
								if my then
									local pos = start:Lerp(dest, e)
									local params = RaycastParams.new()
									params.FilterDescendantsInstances = {localplr.Character}
									params.FilterType = Enum.RaycastFilterType.Exclude
									local hit = workspace:Raycast(pos + Vector3.new(0, 6, 0), Vector3.new(0, -40, 0), params)
									if hit and pos.Y < hit.Position.Y + 3 then
										pos = Vector3.new(pos.X, hit.Position.Y + 3, pos.Z)
									end
									my.CFrame = CFrame.new(pos, pos + flat)
									my.AssemblyLinearVelocity = flat * 95
								end
							end)
							task.wait()
						end
						pcall(function()
							my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
							if my then my.AssemblyLinearVelocity = Vector3.new(flat.X * 20, 0, flat.Z * 20) end
						end)
						pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
					end
				end)
				abilityBusy = false
				resumeRunIfOn()
			end)
		end
		lib.makelabel("--- Griefer moveset ---", animtab)
		lib.makelabel("REQUIRES BKIT. Keys: 1 Runner 2 Scream 3 Punch 4 Final", animtab)
		lib.maketoggle("Griefer moveset", animtab, function(bool)
			if typeof(getgenv().tcoGrieferSetEnabled) == "function" then
				getgenv().tcoGrieferSetEnabled(bool)
			else
				getgenv()._tcoGrieferPending = bool
			end
		end, false)
		lib.makelabel("--- Void Phantom ---", animtab)
		lib.makelabel("Fling moveset + Vexro emotes. Keys 1-4", animtab)
		lib.maketoggle("Void Phantom", animtab, function(bool)
			if typeof(tcoPhantomSetEnabled) == "function" then
				tcoPhantomSetEnabled(bool)
			elseif typeof(getgenv().tcoPhantomSetEnabled) == "function" then
				getgenv().tcoPhantomSetEnabled(bool)
			else
				getgenv()._tcoPhantomPending = bool
			end
		end, false)
		lib.makelabel("--- temu sonic.exe ---", animtab)
		lib.makelabel("Toggle on, walk to build speed. Idle = sonic.exe. Keys 1-5.", animtab)
		getgenv()._tcoSonicSetEnabled = function(want)
			want = want and true or false
			if sonicOn == want then getgenv()._tcoSonicOn = want return end
			sonicOn = want
			getgenv()._tcoSonicOn = want
			if not want then
				pcall(function() stopTracks() end)
				pcall(function() destroyAbilityGui() end)
				pcall(function() setFov(baseFov) end)
				pcall(function()
					local h = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
					if h then h.WalkSpeed = 16 end
				end)
				sonicBuild = 0
				return
			end
			pcall(function()
				local cam = workspace.CurrentCamera
				if cam then baseFov = cam.FieldOfView end
			end)
			pcall(function() makeAbilityGui() end)
			task.spawn(function()
				local wasMoving, usingFast = false, false
				while sonicOn do
					pcall(function()
						local char = localplr.Character
						local hum = char and char:FindFirstChildOfClass("Humanoid")
						local moving = hum and hum.MoveDirection.Magnitude > 0.08
						if abilityBusy then
						elseif moving then
							sonicBuild = math.clamp(sonicBuild + 0.012, 0, 1)
							local spd = 16 + (sonicMax - 16) * sonicBuild
							hum.WalkSpeed = spd
							setFov(baseFov + 25 * sonicBuild)
							local wantFast = sonicBuild >= 0.85
							if not wasMoving or wantFast ~= usingFast or not runTrack then
								playRun(wantFast)
								usingFast = wantFast
							end
							wasMoving = true
						else
							sonicBuild = math.clamp(sonicBuild - 0.02, 0, 1)
							if hum then hum.WalkSpeed = 16 + (sonicMax - 16) * sonicBuild * 0.3 end
							setFov(baseFov + 10 * sonicBuild)
							if wasMoving or not idleTrack or not idleTrack.IsPlaying then playIdle() end
							wasMoving = false
						end
					end)
					task.wait(0.03)
				end
			end)
			local keyConn2
			keyConn2 = UIS.InputBegan:Connect(function(inp, gp)
				if gp or not sonicOn then return end
				local map = {
					[Enum.KeyCode.One] = "spin",
					[Enum.KeyCode.Two] = "sprint",
					[Enum.KeyCode.Three] = "tp",
					[Enum.KeyCode.Four] = "tornado",
					[Enum.KeyCode.Five] = "dash",
				}
				local k = map[inp.KeyCode]
				if k then getgenv()._tcoSonicUse(k) end
			end)
			task.spawn(function()
				while sonicOn do task.wait(0.5) end
				pcall(function() keyConn2:Disconnect() end)
			end)
		end
		lib.maketoggle("temu sonic.exe", animtab, function(bool)
			sonicOn = bool
			getgenv()._tcoSonicOn = bool
			if not bool then
				stopTracks()
				destroyAbilityGui()
				setFov(baseFov)
				pcall(function()
					local h = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
					if h then h.WalkSpeed = 16 end
				end)
				sonicBuild = 0
				return
			end
			pcall(function()
				local cam = workspace.CurrentCamera
				if cam then baseFov = cam.FieldOfView end
			end)
			makeAbilityGui()
			task.spawn(function()
				local wasMoving = false
				local usingFast = false
				while sonicOn do
					pcall(function()
						local char = localplr.Character
						local hum = char and char:FindFirstChildOfClass("Humanoid")
						local moving = hum and hum.MoveDirection.Magnitude > 0.08
						if abilityBusy then
						elseif moving then
							sonicBuild = math.clamp(sonicBuild + 0.012, 0, 1)
							local spd = 16 + (sonicMax - 16) * sonicBuild
							hum.WalkSpeed = spd
							setFov(baseFov + 25 * sonicBuild)
							local wantFast = sonicBuild >= 0.85
							if not wasMoving or wantFast ~= usingFast or not runTrack then
								playRun(wantFast)
								usingFast = wantFast
							end
							wasMoving = true
						else
							sonicBuild = math.clamp(sonicBuild - 0.02, 0, 1)
							if hum then hum.WalkSpeed = 16 + (sonicMax - 16) * sonicBuild * 0.3 end
							setFov(baseFov + 10 * sonicBuild)
							if wasMoving or not idleTrack or not idleTrack.IsPlaying then
								playIdle()
							end
							wasMoving = false
						end
					end)
					task.wait(0.03)
				end
			end)
			local keyConn
			keyConn = UIS.InputBegan:Connect(function(inp, gp)
				if gp or not sonicOn then return end
				local map = {
					[Enum.KeyCode.One] = "spin",
					[Enum.KeyCode.Two] = "sprint",
					[Enum.KeyCode.Three] = "tp",
					[Enum.KeyCode.Four] = "tornado",
					[Enum.KeyCode.Five] = "dash",
				}
				local k = map[inp.KeyCode]
				if k then getgenv()._tcoSonicUse(k) end
			end)
			task.spawn(function()
				while sonicOn do task.wait(0.5) end
				pcall(function() keyConn:Disconnect() end)
			end)
		end, false)
	end
lib.makelabel("--- Fly (stays in player stuff) ---", ptab)
	lib.maketoggle("Chosen Fly", ptab, function(bool)
		S.chosenFly = bool
		if S.flyBV then pcall(function() S.flyBV:Destroy() end) S.flyBV = nil end
		if S.flyBG then pcall(function() S.flyBG:Destroy() end) S.flyBG = nil end
		if S.flyJumpConn then pcall(function() S.flyJumpConn:Disconnect() end) S.flyJumpConn = nil end
		if S.flyRender then pcall(function() S.flyRender:Disconnect() end) S.flyRender = nil end
		S.flyOn = false
		pcall(function()
			local h = hum()
			if h then h.PlatformStand = false end
		end)
		if not bool then return end
		S.flySpeed = S.flySpeed or 50
		S.flyLastToggle = 0
		local function setFly(on)
			local h = hum()
			local r = hrp()
			if not h or not r then return end
			S.flyOn = on
			if on then
				h.PlatformStand = true
				if S.flyBV then pcall(function() S.flyBV:Destroy() end) end
				if S.flyBG then pcall(function() S.flyBG:Destroy() end) end
				local bv = Instance.new("BodyVelocity")
				bv.Name = "FlyBV"
				bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				bv.P = 9e4
				bv.Velocity = Vector3.new(0, 0, 0)
				bv.Parent = r
				S.flyBV = bv
				local bg = Instance.new("BodyGyro")
				bg.Name = "FlyBG"
				bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
				bg.P = 9e4
				bg.CFrame = r.CFrame
				bg.Parent = r
				S.flyBG = bg
				notifyP("Fly ON - move where you look")
			else
				h.PlatformStand = false
				if S.flyBV then pcall(function() S.flyBV:Destroy() end) S.flyBV = nil end
				if S.flyBG then pcall(function() S.flyBG:Destroy() end) S.flyBG = nil end
				notifyP("Fly OFF")
			end
		end
		S.flyJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
			if not S.chosenFly then return end
			if tick() - (S.flyLastToggle or 0) < 0.45 then return end
			S.flyLastToggle = tick()
			setFly(not S.flyOn)
		end)
		S.flyRender = game:GetService("RunService").RenderStepped:Connect(function()
			if not S.chosenFly or not S.flyOn then return end
			pcall(function()
				local r = hrp()
				local h = hum()
				local cam = workspace.CurrentCamera
				if not r or not h or not cam then return end
				if not S.flyBV or not S.flyBV.Parent then
					setFly(true)
					if not S.flyBV then return end
				end
				local UIS = game:GetService("UserInputService")
				local speed = S.flySpeed or 50
				local cf = cam.CFrame
				local look = cf.LookVector
				local right = cf.RightVector
				local upv = cf.UpVector
				local dir = Vector3.new(0, 0, 0)
				local md = h.MoveDirection
				if md.Magnitude > 0.05 then
					local flatLook = Vector3.new(look.X, 0, look.Z)
					local flatRight = Vector3.new(right.X, 0, right.Z)
					if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit else flatLook = Vector3.new(0, 0, -1) end
					if flatRight.Magnitude > 0.01 then flatRight = flatRight.Unit else flatRight = Vector3.new(1, 0, 0) end
					local forwardAmt = md:Dot(flatLook)
					local rightAmt = md:Dot(flatRight)
					dir = look * forwardAmt + right * rightAmt
				end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then
					dir = dir + Vector3.new(0, 1, 0)
				end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.C) then
					dir = dir - Vector3.new(0, 1, 0)
				end
				if dir.Magnitude > 0 then
					dir = dir.Unit
					S.flyBV.Velocity = dir * speed
				else
					S.flyBV.Velocity = Vector3.new(0, 0, 0)
				end
				if S.flyBG and S.flyBG.Parent then
					S.flyBG.CFrame = CFrame.new(r.Position, r.Position + look)
				end
				h.PlatformStand = true
				pcall(function()
					r.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end)
			end)
		end)
	end, false)
	lib.maketextbox("Fly speed (default 50)", ptab, function(txt)
		local n = tonumber(txt)
		if n and n > 0 then S.flySpeed = n notifyP("Fly speed " .. n) end
	end)
	lib.makelabel("--- Target player ---", ptab)
	lib.maketoggle("Use Display Names (player list)", ptab, function(bool)
		getgenv()._tcoUseDisplayName = bool
		pcall(function() lib.updatedropdown(drop, playerNames()) end)
	end, getgenv()._tcoUseDisplayName and true or false)
	local drop = lib.makedropdown("Select player", ptab, playerNames(), function(sel)
		if sel and sel ~= "(none)" then
			local pl = resolvePlayerFromOpt(sel)
			S.selName = pl and pl.Name or sel
			notifyP("Selected " .. tostring(S.selName))
		end
	end)
	lib.makebutton("Refresh player list", ptab, function()
		pcall(function()
			lib.updatedropdown(drop, playerNames())
		end)
		notifyP("List refreshed")
	end)
	lib.makebutton("TP to player", ptab, function()
		local p = getSel()
		if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
			notifyP("No target")
			return
		end
		pcall(function()
			hrp().CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		end)
	end)
	lib.makebutton("View player", ptab, function()
		local p = getSel()
		if not p or not p.Character then notifyP("No target") return end
		local h = p.Character:FindFirstChildOfClass("Humanoid")
		if h then
			workspace.CurrentCamera.CameraSubject = h
			notifyP("Viewing " .. p.Name)
		end
	end)
	lib.makebutton("Unview (me)", ptab, function()
		local h = hum()
		if h then workspace.CurrentCamera.CameraSubject = h end
		notifyP("Camera back to you")
	end)
	lib.makelabel("--- Annoy ---", ptab)
	lib.maketoggle("Spam TP behind", ptab, function(bool)
		S.spamTP = bool
		if not bool then return end
		task.spawn(function()
			while S.spamTP do
				pcall(function()
					local p = getSel()
					if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and hrp() then
						hrp().CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
					end
				end)
				task.wait(0.15)
			end
		end)
	end, false)
	lib.maketoggle("Orbit target", ptab, function(bool)
		S.orbit = bool
		if not bool then return end
		task.spawn(function()
			local ang = 0
			while S.orbit do
				pcall(function()
					local p = getSel()
					local my = hrp()
					if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and my then
						ang = ang + 0.25
						local t = p.Character.HumanoidRootPart.Position
						my.CFrame = CFrame.new(t + Vector3.new(math.cos(ang) * 6, 3, math.sin(ang) * 6), t)
					end
				end)
				task.wait()
			end
		end)
	end, false)
	lib.maketoggle("Bubble chat (need invis)", ptab, function(bool)
		S.bubbleChat = bool
		if not bool then return end
		notifyP("Stay invisible - your chat bubbles on them")
		task.spawn(function()
			while S.bubbleChat do
				pcall(function()
					local p = getSel()
					local my = hrp()
					if not p or not p.Character or not my then return end
					local th = p.Character:FindFirstChild("HumanoidRootPart")
					if not th then return end
					my.CFrame = th.CFrame
					my.AssemblyLinearVelocity = th.AssemblyLinearVelocity
					my.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					pcall(function()
						my.Velocity = th.Velocity
					end)
				end)
				task.wait()
			end
		end)
	end, false)
	lib.makebutton("Chat: freeze them", ptab, function()
		local p = getSel()
		if not p then notifyP("No target") return end
		pcall(function()
			local msg = "freeze " .. p.Name
			local tcs = game:GetService("TextChatService")
			if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
				local ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
				if ch then ch:SendAsync(msg) return end
			end
		end)
	end)
	lib.makebutton("Chat: reset them", ptab, function()
		local p = getSel()
		if not p then notifyP("No target") return end
		pcall(function()
			local msg = "reset " .. p.Name
			local tcs = game:GetService("TextChatService")
			local ch = tcs.TextChannels and tcs.TextChannels:FindFirstChild("RBXGeneral")
			if ch then ch:SendAsync(msg) end
		end)
	end)
	lib.makebutton("Chat: glitch them", ptab, function()
		local p = getSel()
		if not p then notifyP("No target") return end
		pcall(function()
			local msg = "glitch " .. p.Name
			local tcs = game:GetService("TextChatService")
			local ch = tcs.TextChannels and tcs.TextChannels:FindFirstChild("RBXGeneral")
			if ch then ch:SendAsync(msg) end
		end)
	end)
end
do
	local bbtab = lib.maketab("boombox ids")
	lib.makelabel("Copy ID then play on boombox", bbtab)
	local function addIds(cat, list)
		lib.makelabel("--- " .. cat .. " ---", bbtab)
		for _, item in ipairs(list) do
			local name, id = item[1], item[2]
			lib.makebutton(name .. "  [" .. tostring(id) .. "]", bbtab, function()
				pcall(function() setclipboard(tostring(id)) end)
				pcall(function()
					game:GetService("StarterGui"):SetCore("SendNotification", {
						Title = "Boombox",
						Text = "Copied " .. name,
						Duration = 2
					})
				end)
			end)
		end
	end
	addIds("Elevator / Lounge", {
		{"Elevator Music", 9119119619},
		{"Claire De Lune", 1838457617},
		{"Smooth Jazz", 1845341094},
		{"Wooden Bear", 1844397736},
		{"Happy Song", 1843403987},
		{"Solitare Soft", 1846457890},
	})
	addIds("Calm / Chill", {
		{"Lo-Fi Chill A", 9043887091},
		{"Chillin at Home", 9042666762},
		{"Running (Tom Hillock)", 1843436418},
		{"Crystal Clear", 1837848642},
		{"Alan Walker Fade", 292315830},
		{"Spectre", 313726644},
		{"Lost Sky Dreams", 7547342615},
	})
	addIds("Very Loud", {
		{"Get Hyper", 138855854},
		{"Stadium Rave", 1846368080},
		{"Full Force", 1842801942},
		{"Collider", 1841905171},
		{"Bodypartz", 6673004638},
		{"Tokyo Drift", 1837015626},
	})
	addIds("Phonk", {
		{"TOMA FUNK PHONK", 129098116998483},
		{"ROBLOX PHONK", 136932193331774},
		{"FUNK FESTA", 103409297553965},
		{"AURA Brazilian Phonk", 95131770144654},
		{"MONTAGEM BÊNÇÃO", 140245756477343},
		{"DRIFT NIGHT PHONK", 85735197482652},
		{"Lost Phonk", 139266399633943},
	})
	addIds("Classic / Meme", {
		{"Raining Tacos", 142376088},
		{"Rickroll", 7363412529},
		{"Spooky Scary Skeletons", 138081566},
		{"Whatcha Say", 168208965},
		{"Trumpets", 146237847},
		{"Stronger", 136209425},
		{"Intergalactic", 131603357},
		{"Gangstas Paradise", 6070263388},
		{"TF2 Theme", 166378555},
	})
	lib.makelabel("Add your own (name then id)", bbtab)
	local customName = "Custom"
	lib.maketextbox("Custom track name", bbtab, function(txt)
		if txt and txt ~= "" then customName = txt end
	end)
	lib.maketextbox("Custom sound id (enter to copy)", bbtab, function(txt)
		local id = tostring(txt or ""):gsub("%s", "")
		if id ~= "" then
			pcall(function() setclipboard(id) end)
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Boombox",
					Text = "Copied " .. customName .. " [" .. id .. "]",
					Duration = 2
				})
			end)
		end
	end)
end
	lib.makelabel("--- Selected boombox ---", bbtab)
	bboxtxt = lib.makelabel("No Boombox Selected", bbtab)
	bbid = bbid or ""
	lib.makebutton("Copy Boombox Sound ID", bbtab, function()
		pcall(function() setclipboard(tostring(bbid or "")) end)
	end)
	osbb = false
	lib.maketoggle("Outline Selected Boombox", bbtab, function(bool)
		osbb = bool
		if osbb then
			bbsbox.LineThickness = 0.1
		else
			bbsbox.LineThickness = -1
		end
	end)
lib.makelabel("Needs Build kit equipped / in backpack", jailtab)
lib.maketextbox("Jail aura range (default 40)", jailtab, function(txt)
	local n = tonumber(txt)
	if n and n > 0 then
		getgenv()._tcoJailRange = n
	end
end)
lib.maketextbox("Build speed (default 0.02, lower=faster)", jailtab, function(txt)
	local n = tonumber(txt)
	if n and n >= 0 then
		getgenv()._tcoJailRebuild = n
	end
end)
lib.maketextbox("Cube half-size blocks (default 2)", jailtab, function(txt)
	local n = tonumber(txt)
	if n and n >= 1 then
		getgenv()._tcoJailHalf = math.floor(n)
	end
end)
lib.maketoggle("Jail Aura", jailtab, function(bool)
	getgenv()._tcoJailAura = bool
	if not bool then return end
	task.spawn(function()
		while getgenv()._tcoJailAura do
			pcall(function()
				local range = getgenv()._tcoJailRange or 40
				local myChar = localplr.Character
				local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not myHrp then return end
				if not myChar:FindFirstChild("Build") then
					local bp = localplr.Backpack:FindFirstChild("Build")
					if bp then bp.Parent = myChar end
				end
				local tool = myChar:FindFirstChild("Build")
				if not tool then return end
				local sizeMode = "normal"
				pcall(function()
					if localplr.PlayerGui:FindFirstChild("Build") and localplr.PlayerGui.Build:FindFirstChild("Button") then
						sizeMode = localplr.PlayerGui.Build.Button.Text
					end
				end)
				local function fireAt(pos)
					pcall(function()
						if tool:FindFirstChild("origevent") then
							tool.origevent:Invoke(workspace.Terrain, Enum.NormalId.Top, pos, sizeMode)
						elseif tool:FindFirstChild("Script") and tool.Script:FindFirstChild("Event") then
							tool.Script.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, pos, sizeMode)
						end
					end)
				end
				local best, bd = nil, range
				for _, p in pairs(game.Players:GetPlayers()) do
					if p ~= localplr and p.Character then
						local h = p.Character:FindFirstChild("HumanoidRootPart")
						if h then
							local d = (h.Position - myHrp.Position).Magnitude
							if d < bd then best, bd = h, d end
						end
					end
				end
				if not best then return end
				local b = best.Position
				local half = tonumber(getgenv()._tcoJailHalf) or 2
				local spots = {
					Vector3.new(0, -1.5, 0),
					Vector3.new(half, 0, 0), Vector3.new(-half, 0, 0),
					Vector3.new(0, 0, half), Vector3.new(0, 0, -half),
					Vector3.new(half, 0, half), Vector3.new(half, 0, -half),
					Vector3.new(-half, 0, half), Vector3.new(-half, 0, -half),
					Vector3.new(half, 2, 0), Vector3.new(-half, 2, 0),
					Vector3.new(0, 2, half), Vector3.new(0, 2, -half),
					Vector3.new(0, 3.5, 0),
				}
				for _, o in ipairs(spots) do
					if not getgenv()._tcoJailAura then break end
					fireAt(b + o)
				end
			end)
			task.wait(tonumber(getgenv()._tcoJailRebuild) or 0.02)
		end
	end)
end, false)
function notifySpam(text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Commands",
			Text = tostring(text),
			Duration = 2
		})
	end)
end
function saySpamMsg(msg, hide)
	if not msg or msg == "" then return end
	if hide and string.sub(msg, 1, 1) ~= ";" then
		msg = ";" .. msg
	end
	pcall(function()
		local tcs = game:GetService("TextChatService")
		if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
			local ch = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
			if ch then
				ch:SendAsync(msg)
				return
			end
		end
		local rs = game:GetService("ReplicatedStorage")
		local ev = rs:FindFirstChild("DefaultChatSystemChatEvents")
		if ev and ev:FindFirstChild("SayMessageRequest") then
			ev.SayMessageRequest:FireServer(msg, "All")
		end
	end)
end
spamDelay = 1
spamList = {}
selectedSpam = nil
spamRunning = false
hideCmd = false
spamDropdown = nil
lib.makelabel("Spam delay (seconds)", cmdspamtab)
lib.maketextbox("Set spam delay (e.g. 1)", cmdspamtab, function(txt)
	local n = tonumber(txt)
	if n and n > 0 then
		spamDelay = n
		notifySpam("Delay set to " .. tostring(n) .. "s")
	else
		notifySpam("Invalid delay")
	end
end)
lib.makelabel("Type anything to add to list", cmdspamtab)
lib.maketextbox("Type command / text then enter", cmdspamtab, function(txt)
	if not txt or txt == "" then return end
	table.insert(spamList, txt)
	selectedSpam = txt
	pcall(function()
		if spamDropdown then
			lib.updatedropdown(spamDropdown, spamList)
		end
	end)
	notifySpam("Added: " .. txt)
end)
lib.maketoggle("Hide command (; prefix)", cmdspamtab, function(bool)
	hideCmd = bool
	notifySpam(bool and "Hide ON (; added)" or "Hide OFF")
end, false)
lib.makelabel("Select what to spam", cmdspamtab)
spamDropdown = lib.makedropdown("Saved messages", cmdspamtab, {"(empty)"}, function(sel)
	if sel and sel ~= "(empty)" then
		selectedSpam = sel
		notifySpam("Selected: " .. tostring(sel))
	end
end)
lib.makebutton("Clear list", cmdspamtab, function()
	spamList = {}
	selectedSpam = nil
	pcall(function()
		if spamDropdown then
			lib.updatedropdown(spamDropdown, {"(empty)"})
		end
	end)
	notifySpam("List cleared")
end)
lib.maketoggle("Spam selected (toggle)", cmdspamtab, function(bool)
	spamRunning = bool
	if spamRunning then
		notifySpam("Spamming ON")
		task.spawn(function()
			while spamRunning do
				if selectedSpam and selectedSpam ~= "" and selectedSpam ~= "(empty)" then
					saySpamMsg(selectedSpam, hideCmd)
				end
				task.wait(spamDelay)
			end
		end)
	else
		notifySpam("Spamming OFF")
	end
end, false)
lib.makebutton("Load 2 commands spam GUI", cmdspamtab, function()
	loadDualSpamGui()
end)
loadDualSpamGui = function()
	local existing = game.CoreGui:FindFirstChild("TCODualSpamGui")
		or (game.Players.LocalPlayer:FindFirstChild("PlayerGui")
			and game.Players.LocalPlayer.PlayerGui:FindFirstChild("TCODualSpamGui"))
	if existing then existing:Destroy() end
	local miniOld = game.CoreGui:FindFirstChild("TCODualSpamMini")
		or (game.Players.LocalPlayer:FindFirstChild("PlayerGui")
			and game.Players.LocalPlayer.PlayerGui:FindFirstChild("TCODualSpamMini"))
	if miniOld then miniOld:Destroy() end
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local plr = Players.LocalPlayer
	local function notify(text)
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "2 Spam",
				Text = tostring(text),
				Duration = 2
			})
		end)
	end
	local function sayMsg(msg, hide)
		if not msg or msg == "" then return end
		if hide and string.sub(msg, 1, 1) ~= ";" then
			msg = ";" .. msg
		end
		pcall(function()
			local tcs = game:GetService("TextChatService")
			if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
				local ch = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
				if ch then ch:SendAsync(msg) return end
			end
			local rs = game:GetService("ReplicatedStorage")
			local ev = rs:FindFirstChild("DefaultChatSystemChatEvents")
			if ev and ev:FindFirstChild("SayMessageRequest") then
				ev.SayMessageRequest:FireServer(msg, "All")
			end
		end)
	end
	local delay1, delay2 = 1, 1
	local list1, list2 = {}, {}
	local sel1, sel2 = nil, nil
	local run1, run2 = false, false
	local hide1, hide2 = false, false
	local gen1, gen2 = 0, 0
	local sg = Instance.new("ScreenGui")
	sg.Name = "TCODualSpamGui"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() sg.Parent = game.CoreGui end)
	if not sg.Parent then sg.Parent = plr:WaitForChild("PlayerGui") end
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 210, 0, 320)
	frame.Position = UDim2.new(0, 28, 0.5, -160)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.ClipsDescendants = true
	frame.Parent = sg
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 26)
	titleBar.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = frame
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -58, 1, 0)
	title.Position = UDim2.new(0, 8, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "2 spam"
	title.TextColor3 = Color3.fromRGB(190, 190, 195)
	title.Font = Enum.Font.SourceSans
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar
	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 24, 0, 22)
	minBtn.Position = UDim2.new(1, -52, 0, 2)
	minBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 54)
	minBtn.Text = "-"
	minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	minBtn.Font = Enum.Font.SourceSans
	minBtn.TextSize = 16
	minBtn.Parent = titleBar
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 3)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 24, 0, 22)
	closeBtn.Position = UDim2.new(1, -26, 0, 2)
	closeBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
	closeBtn.Text = "x"
	closeBtn.TextColor3 = Color3.fromRGB(220, 180, 180)
	closeBtn.Font = Enum.Font.SourceSans
	closeBtn.TextSize = 14
	closeBtn.Parent = titleBar
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)
	local topResize = Instance.new("TextButton")
	topResize.Size = UDim2.new(1, 0, 0, 5)
	topResize.Position = UDim2.new(0, 0, 0, 0)
	topResize.BackgroundTransparency = 1
	topResize.Text = ""
	topResize.ZIndex = 5
	topResize.Parent = frame
	local botResize = Instance.new("TextButton")
	botResize.Size = UDim2.new(1, 0, 0, 6)
	botResize.Position = UDim2.new(0, 0, 1, -6)
	botResize.BackgroundTransparency = 1
	botResize.Text = ""
	botResize.ZIndex = 5
	botResize.Parent = frame
	local resizing, resizeMode, resizeStart, resizeSize, resizePos
	local function beginResize(mode, input)
		resizing = true
		resizeMode = mode
		resizeStart = input.Position
		resizeSize = frame.AbsoluteSize
		resizePos = frame.AbsolutePosition
	end
	topResize.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			beginResize("top", input)
		end
	end)
	botResize.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			beginResize("bot", input)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not resizing then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local dy = input.Position.Y - resizeStart.Y
		if resizeMode == "bot" then
			local nh = math.clamp(resizeSize.Y + dy, 180, 600)
			frame.Size = UDim2.new(0, frame.AbsoluteSize.X, 0, nh)
		elseif resizeMode == "top" then
			local nh = math.clamp(resizeSize.Y - dy, 180, 600)
			local yOff = resizePos.Y + (resizeSize.Y - nh)
			frame.Size = UDim2.new(0, frame.AbsoluteSize.X, 0, nh)
			frame.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, yOff)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)
	closeBtn.MouseButton1Click:Connect(function()
		run1 = false
		run2 = false
		gen1 = gen1 + 1
		gen2 = gen2 + 1
		sg:Destroy()
		local mini = game.CoreGui:FindFirstChild("TCODualSpamMini")
			or (plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("TCODualSpamMini"))
		if mini then mini:Destroy() end
	end)
	local miniGui = Instance.new("ScreenGui")
	miniGui.Name = "TCODualSpamMini"
	miniGui.ResetOnSpawn = false
	miniGui.Enabled = false
	pcall(function() miniGui.Parent = game.CoreGui end)
	if not miniGui.Parent then miniGui.Parent = plr:WaitForChild("PlayerGui") end
	local miniBtn = Instance.new("TextButton")
	miniBtn.Size = UDim2.new(0, 56, 0, 56)
	miniBtn.Position = UDim2.new(0, 20, 0.55, -28)
	miniBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	miniBtn.Text = "2s"
	miniBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
	miniBtn.Font = Enum.Font.SourceSans
	miniBtn.TextSize = 16
	miniBtn.Parent = miniGui
	Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 6)
	minBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
		miniGui.Enabled = true
	end)
	miniBtn.MouseButton1Click:Connect(function()
		frame.Visible = true
		miniGui.Enabled = false
	end)
	local dragging, dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	local mDragging, mStart, mPos
	miniBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			mDragging = true
			mStart = input.Position
			mPos = miniBtn.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if mDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - mStart
			miniBtn.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + d.X, mPos.Y.Scale, mPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			mDragging = false
		end
	end)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -34)
	scroll.Position = UDim2.new(0, 5, 0, 28)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = frame
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = scroll
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)
	local function addLabel(text)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -4, 0, 20)
		l.BackgroundTransparency = 1
		l.Text = text
		l.TextColor3 = Color3.fromRGB(150, 190, 255)
		l.Font = Enum.Font.GothamBold
		l.TextSize = 12
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Parent = scroll
	end
	local function addBox(placeholder, callback)
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, -4, 0, 28)
		box.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
		box.Text = ""
		box.PlaceholderText = placeholder
		box.TextColor3 = Color3.new(1, 1, 1)
		box.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
		box.Font = Enum.Font.Gotham
		box.TextSize = 12
		box.ClearTextOnFocus = false
		box.Parent = scroll
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
		box.FocusLost:Connect(function(enter)
			if enter and box.Text ~= "" then
				callback(box.Text)
				box.Text = ""
			end
		end)
		return box
	end
	local function addBtn(text, callback)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -4, 0, 28)
		b.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
		b.Text = text
		b.TextColor3 = Color3.fromRGB(220, 220, 230)
		b.Font = Enum.Font.Gotham
		b.TextSize = 12
		b.Parent = scroll
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(callback)
		return b
	end
	local function addToggle(text, onEnable, onDisable)
		local on = false
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -4, 0, 28)
		b.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
		b.Text = text .. "  [OFF]"
		b.TextColor3 = Color3.fromRGB(220, 220, 230)
		b.Font = Enum.Font.Gotham
		b.TextSize = 12
		b.Parent = scroll
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(function()
			on = not on
			if on then
				b.Text = text .. "  [ON]"
				b.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
				if onEnable then onEnable() end
			else
				b.Text = text .. "  [OFF]"
				b.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
				if onDisable then onDisable() end
			end
		end)
		return b
	end
	local function makeSelector(labelText, getList, getSel, setSel)
		addLabel(labelText)
		local btn = addBtn("(empty) - click to cycle", function()
			local list = getList()
			if #list == 0 then
				notify("List empty")
				return
			end
			local idx = 1
			local cur = getSel()
			if cur then
				for i, v in ipairs(list) do
					if v == cur then idx = i + 1 break end
				end
				if idx > #list then idx = 1 end
			end
			setSel(list[idx])
			btn.Text = "[" .. idx .. "/" .. #list .. "] " .. tostring(list[idx])
			notify("Selected: " .. tostring(list[idx]))
		end)
		return btn
	end
	local aName, aPlr, aMsg = nil, nil, ""
	local aDelay = 0.8
	local aReset, aRejoin = false, false
	local aCharConns = {}
	local aLifeConns = {}
	local aSkip = false
	local aTargetLbl = nil
	local function aClearChars()
		for _, c in pairs(aCharConns) do pcall(function() c:Disconnect() end) end
		aCharConns = {}
	end
	local function aFind(txt)
		if not txt or txt == "" then return nil end
		txt = tostring(txt):lower():gsub("^%s+",""):gsub("%s+$","")
		local exact, partial = nil, nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower() == txt or p.DisplayName:lower() == txt then exact = p break end
			if string.find(p.Name:lower(), txt, 1, true) or string.find(p.DisplayName:lower(), txt, 1, true) then
				partial = partial or p
			end
		end
		return exact or partial
	end
	local function aMatchName(plr)
		if not aName or aName == "" or not plr then return false end
		local n = aName:lower()
		return plr.Name:lower() == n
			or plr.DisplayName:lower() == n
			or string.find(plr.Name:lower(), n, 1, true) ~= nil
			or string.find(plr.DisplayName:lower(), n, 1, true) ~= nil
	end
	local aEquipEnlighten = false
	local function aEquipEnlightenInvisible()
		if not aEquipEnlighten then return end
		pcall(function()
			local tool = localplr.Backpack:FindFirstChild("The Arkenstone")
				or localplr.Backpack:FindFirstChild("Arkenstone")
				or localplr.Backpack:FindFirstChild("Enlighten")
				or (localplr.Character and (localplr.Character:FindFirstChild("The Arkenstone")
					or localplr.Character:FindFirstChild("Arkenstone")
					or localplr.Character:FindFirstChild("Enlighten")))
			if not tool then return end
			local char = localplr.Character
			if not char then return end
			local backpack = localplr.Backpack
			local held = nil
			for _, t in pairs(char:GetChildren()) do
				if t:IsA("Tool") and t ~= tool then held = t break end
			end
			if tool.Parent == char then tool.Parent = backpack end
			if tool.Parent == backpack then tool.Parent = char end
			game:GetService("RunService").RenderStepped:Wait()
			if tool.Parent == char then tool.Parent = backpack end
			if held and held.Parent == backpack then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum:EquipTool(held) end
			end
		end)
	end
	local function aSay()
		if not aMsg or aMsg == "" then return end
		local msg = aMsg
		if aName then
			msg = string.gsub(msg, "{name}", aName)
			msg = string.gsub(msg, "{NAME}", aName)
		end
		aEquipEnlightenInvisible()
		task.wait(tonumber(aDelay) or 0.8)
		aEquipEnlightenInvisible()
		sayMsg(msg, false)
		notify("Auto said: " .. msg)
	end
	local function aWaitAliveAndSay(plr)
		task.spawn(function()
			local char = plr.Character
			if not char then
				local ok, res = pcall(function()
					return plr.CharacterAdded:Wait()
				end)
				char = ok and res or plr.Character
			end
			if not char then
				local t0 = tick()
				while tick() - t0 < 15 and not plr.Character do
					task.wait(0.2)
				end
				char = plr.Character
			end
			if not char then return end
			local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 20)
			if not hum then return end
			local t0 = tick()
			while tick() - t0 < 12 do
				if not plr.Parent then return end
				if hum.Parent and hum.Health > 0 then break end
				task.wait(0.15)
			end
			if hum.Parent and hum.Health > 0 and aMsg ~= "" then
				aSay()
			end
		end)
	end
	local function aHook(plr)
		if not plr then return end
		aClearChars()
		aSkip = true
		local function onChar(char)
			if not char then return end
			if aSkip then
				aSkip = false
				return
			end
			if not aReset or aMsg == "" then return end
			task.spawn(function()
				local hum = char:WaitForChild("Humanoid", 15)
				if not hum then return end
				local t0 = tick()
				while tick() - t0 < 6 do
					if hum.Parent and hum.Health > 0 then break end
					task.wait(0.1)
				end
				if hum.Parent and hum.Health > 0 then aSay() end
			end)
		end
		table.insert(aCharConns, plr.CharacterAdded:Connect(onChar))
		if plr.Character then onChar(plr.Character) end
	end
	addLabel("--- Auto say ---")
	aTargetLbl = addBtn("Target: (none)", function() end)
	aTargetLbl.TextColor3 = Color3.fromRGB(180, 200, 220)
	addBox("Player name then enter", function(txt)
		local p = aFind(txt)
		if p then
			aPlr = p
			aName = p.Name
			aHook(p)
			aTargetLbl.Text = "Target: " .. p.DisplayName .. " (@" .. p.Name .. ")"
			notify("Selected " .. p.Name)
		else
			aPlr = nil
			aName = tostring(txt or "")
			aClearChars()
			aTargetLbl.Text = "Target: " .. aName .. " (offline)"
			notify("Not in server - watching join")
		end
	end)
	addBox("Message to say (e.g. freeze Name)", function(txt)
		aMsg = tostring(txt or "")
		notify("Msg: " .. aMsg)
	end)
	addBox("Shared delay (reset + rejoin)", function(txt)
		local n = tonumber(txt)
		if n and n >= 0 then aDelay = n notify("Delay: " .. n .. "s (both)") end
	end)
	addToggle("Say on RESET", function()
		aReset = true
		if aPlr then aHook(aPlr) end
		notify("Reset ON")
	end, function()
		aReset = false
		notify("Reset OFF")
	end)
	addToggle("Say on REJOIN", function()
		aRejoin = true
		notify("Rejoin ON")
	end, function()
		aRejoin = false
		notify("Rejoin OFF")
	end)
	addToggle("Equip Arkenstone when reset/rejoin", function()
		aEquipEnlighten = true
		notify("Arkenstone equip ON (invisible)")
	end, function()
		aEquipEnlighten = false
		notify("Arkenstone equip OFF")
	end)
	table.insert(aLifeConns, Players.PlayerAdded:Connect(function(plr)
		if not aRejoin then return end
		if not aMatchName(plr) then return end
		aPlr = plr
		aName = plr.Name
		pcall(function()
			aTargetLbl.Text = "Target: " .. plr.DisplayName .. " (@" .. plr.Name .. ")"
		end)
		notify("Target rejoined: " .. plr.Name)
		aWaitAliveAndSay(plr)
		aHook(plr)
	end))
	table.insert(aLifeConns, Players.PlayerRemoving:Connect(function(plr)
		if aPlr == plr then
			aPlr = nil
			aClearChars()
			pcall(function()
				if aName then
					aTargetLbl.Text = "Target: " .. aName .. " (left)"
				end
			end)
		end
	end))
	addLabel("--- Slot 1 ---")
	addBox("Slot 1 delay (seconds)", function(txt)
		local n = tonumber(txt)
		if n and n > 0 then delay1 = n notify("Slot 1 delay: " .. n) end
	end)
	addBox("Slot 1 type text then enter", function(txt)
		table.insert(list1, txt)
		sel1 = txt
		notify("Slot 1 added: " .. txt)
	end)
	addToggle("Slot 1 hide (;)", function() hide1 = true end, function() hide1 = false end)
	local selBtn1 = makeSelector("Slot 1 select message", function() return list1 end, function() return sel1 end, function(v) sel1 = v end)
	addBtn("Slot 1 clear", function()
		list1 = {}
		sel1 = nil
		selBtn1.Text = "(empty) - click to cycle"
		notify("Slot 1 cleared")
	end)
	addToggle("Slot 1 spam", function()
		run1 = true
		gen1 = gen1 + 1
		local my = gen1
		notify("Slot 1 ON")
		task.spawn(function()
			while run1 and gen1 == my do
				if sel1 and sel1 ~= "" then sayMsg(sel1, hide1) end
				task.wait(delay1)
			end
		end)
	end, function()
		run1 = false
		gen1 = gen1 + 1
		notify("Slot 1 OFF")
	end)
	addLabel("--- Slot 2 ---")
	addBox("Slot 2 delay (seconds)", function(txt)
		local n = tonumber(txt)
		if n and n > 0 then delay2 = n notify("Slot 2 delay: " .. n) end
	end)
	addBox("Slot 2 type text then enter", function(txt)
		table.insert(list2, txt)
		sel2 = txt
		notify("Slot 2 added: " .. txt)
	end)
	addToggle("Slot 2 hide (;)", function() hide2 = true end, function() hide2 = false end)
	local selBtn2 = makeSelector("Slot 2 select message", function() return list2 end, function() return sel2 end, function(v) sel2 = v end)
	addBtn("Slot 2 clear", function()
		list2 = {}
		sel2 = nil
		selBtn2.Text = "(empty) - click to cycle"
		notify("Slot 2 cleared")
	end)
	addToggle("Slot 2 spam", function()
		run2 = true
		gen2 = gen2 + 1
		local my = gen2
		notify("Slot 2 ON")
		task.spawn(function()
			while run2 and gen2 == my do
				if sel2 and sel2 ~= "" then sayMsg(sel2, hide2) end
				task.wait(delay2)
			end
		end)
	end, function()
		run2 = false
		gen2 = gen2 + 1
		notify("Slot 2 OFF")
	end)
	addLabel("--- Both ---")
	addToggle("Spam BOTH slots", function()
		run1 = true
		run2 = true
		gen1 = gen1 + 1
		gen2 = gen2 + 1
		local my1, my2 = gen1, gen2
		notify("BOTH ON")
		task.spawn(function()
			while run1 and gen1 == my1 do
				if sel1 and sel1 ~= "" then sayMsg(sel1, hide1) end
				task.wait(delay1)
			end
		end)
		task.spawn(function()
			while run2 and gen2 == my2 do
				if sel2 and sel2 ~= "" then sayMsg(sel2, hide2) end
				task.wait(delay2)
			end
		end)
	end, function()
		run1 = false
		run2 = false
		gen1 = gen1 + 1
		gen2 = gen2 + 1
		notify("BOTH OFF")
	end)
	notify("2 Commands Spam GUI loaded")
end
dumfix = true
function listfilesfixed(directory)
	local s, lf = pcall(function()
		return listfiles(directory)
	end)
	if not s or type(lf) ~= "table" then
		if type(directory) == "string" and #directory > 0 and directory:sub(-1) == "/" then
			s, lf = pcall(function() return listfiles(directory:sub(1, -1)) end)
		end
	end
	if not s or type(lf) ~= "table" then
		return {}
	end
	for i, v in pairs(lf) do
		v = tostring(v):gsub("\\", "/")
		if v:sub(1, 2) == "./" then
			v = v:sub(3)
		end
		lf[i] = v
	end
	return lf
end
function getfn(js, first)
	pcall(function()
		if typeof(makefolder) == "function" then
			makefolder("TheChosenOneBuilds")
		end
	end)
	local raw = listfilesfixed("TheChosenOneBuilds/")
	if type(raw) ~= "table" or #raw == 0 then
		raw = listfilesfixed("TheChosenOneBuilds")
	end
	if type(raw) ~= "table" then
		return {}
	end
	local names = {}
	local seen = {}
	for _, v in pairs(raw) do
		local name = tostring(v):gsub("\\", "/")
		name = name:match("([^/]+)$") or name
		if not js then
			name = name:gsub("%.json$", ""):gsub("%.txt$", "")
		end
		if name ~= "" and name ~= "TheChosenOneBuilds" and not seen[name] then
			seen[name] = true
			names[#names + 1] = name
		end
	end
	return names
end
function snap(pos,m)
	if m == nil then
		m = mult
	end
	local x = math.round(pos.X/m)+2
	return pos
end
childcube = nil
childcube2 = nil
oldprt = nil
tp = true
blocks = {}
cubehistory = {}
historynum = 0
historymax = 900
cubechild = nil
toxifybrick = nil
buildingtoxify = false
if workspace.Bricks:FindFirstChild(localplr.Name) then
	cubechild = workspace.Bricks[localplr.Name].ChildAdded:Connect(function(child)
		childcube = child
		historynum = historynum + 1
		if historynum > historymax then
			historynum = 1
		end
		if buildingtoxify then
			toxifybrick = child
		end
		if getgenv()._tcoBuildingYellow then
			getgenv()._tcoYellowBrick = child
		end
		cubehistory[historynum] = child
		built = true
	end)
	for i,child in pairs(workspace.Bricks[localplr.Name]:GetChildren()) do
	end
else
	cubechild = workspace.Bricks.ChildAdded:Connect(function()
	end)
end
function getclosesttopos(pos)
	local closest = nil
	for i,v in pairs(blocks) do
  		if v and v.Parent then
			if closest == nil then
	  			closest = {(i - pos).Magnitude,v,i}
	  		elseif closest and (i - pos).Magnitude < closest[1] then
	  			closest = {(i - pos).Magnitude,v,i}
	  		end
		else
			blocks[i] = nil
		end
  	end
	return closest[2],closest[3]
end
colors = {}
colors["tan"] = Color3.fromRGB(188,155,93)
colors["pink"] = Color3.fromRGB(255,0,255)
colors["dark pink"] = Color3.fromRGB(160,0,160)
defaultcolor = Color3.fromRGB(192,192,192)
buildingexec = nil
novel = false
resizewait = 0.7
buildspeed = 1.0
normalids = {}
normalids[Enum.NormalId.Right] = {Vector3.new(1,0,0),"X"}
normalids[Enum.NormalId.Top] = {Vector3.new(0,1,0),"Y"}
normalids[Enum.NormalId.Back] = {Vector3.new(0,0,1),"Z"}
normalids[Enum.NormalId.Left] = {Vector3.new(-1,0,0),"X"}
normalids[Enum.NormalId.Bottom] = {Vector3.new(0,-1,0),"Y"}
normalids[Enum.NormalId.Front] = {Vector3.new(0,0,-1),"Z"}
function roundnum(num,m)
	return math.round((num - 2) / m) * m + 2
end
function round(pos,m)
	return Vector3.new(roundnum(pos.X,m or mult),roundnum(pos.Y,m or mult),roundnum(pos.Z,m or mult))
end
wbs = false
function buildblock(pos,texture,color,bsize,bsizev3,premadebuild,origmaterial,sprays,anchored,collide)
	if not premadebuild then
		task.wait(0.001)
	end
	if anchored == nil then
		anchored = true
	end
	if collide == nil then
		collide = true
	end
	local needsresize = false
	local spd = math.max(0.25, tonumber(buildspeed) or 1)
	local isSave = premadebuild == true
	local waitBuild = (isSave and 0.035 or 0.05) / spd
	local waitPaint = (isSave and 0.08 or 0.2) / spd
	local waitAnchor = (isSave and 0.35 or 1) / spd
	local waitSpray = (isSave and 0.25 or 0.5) / spd
	local waitResize = isSave and math.max(0.06, resizewait * 0.45) or resizewait
	local maxBuildTries = isSave and 90 or 200
	local maxPaintTries = isSave and 80 or 2000
	local maxAnchorTries = isSave and 12 or 20
	local s,e = pcall(function()
	local s,e = pcall(function()
		localplr.Backpack.Build.Parent = localplr.Character
	end)
	local oo = false
	local c = 0
	childcube = nil
	if #cubehistory > 0 and oldprt then
		local allooslol = {}
		for i,childcube2 in pairs(cubehistory) do
			if childcube2 == nil or childcube2.Parent == nil then
				cubehistory[i] = nil
				continue
			elseif oldprt.Size == childcube2.Size then
				for i,v in pairs(normalids) do
					local fpos = childcube2.Position+(v[1]*childcube2.Size[v[2]])
					if (fpos - oldprt.Position).Magnitude < 0.05 then
						oo = {i,childcube2,childcube2.Position+(v[1]*childcube2.Size[v[2]]/2)}
						table.insert(allooslol,{i,childcube2,childcube2.Position+(v[1]*childcube2.Size[v[2]]/2)})
					end
				end
			end
		end
		if #allooslol > 1 and color and oo[2].Color ~= color then
			for i,v in pairs(allooslol) do
				if v[2].Color == color then
					oo = v
				end
			end
		end
		local origposs = pos
		if oo and oo[2] ~= nil and oo[2].Parent ~= nil then
			local args = {
				[1] = oo[2],
				[2] = oo[1],
				[3] = oo[3] or oldprt.Position,
				[4] = "normal"
			}
			built = false
			childcube = nil
			c = 0
			repeat
				c = c + 1
				if localplr.Character:FindFirstChild("Build") then
					local event = (localplr.Character.Build:FindFirstChild("origevent") and localplr.Character.Build.origevent:Invoke(unpack(args))) or localplr.Character.Build.Script.Event:FireServer(unpack(args))
				else
					local s,e = pcall(function()
						localplr.Backpack.Build.Parent = localplr.Character
					end)
				end
				local s,e = pcall(function()
					novel = true
					pos = oo[3] or pos
					if tp then
						localplr.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
					end
				end)
				task.wait(waitBuild)
			until (built == true and childcube) or oo[2] == nil or oo[2].Parent == nil or stopped == true or skipblock == true or c > maxBuildTries
			novel = false
			if oo[2] == nil or oo[2].Parent == nil or c > maxBuildTries then
				oo = false
			else
				if oldprt then
					oldprt:Destroy()
				end
			end
		end
		pos = origposs
	end
	if oo == false then
	if bsize == nil then
		bsize = "normal"
		if localplr.PlayerGui:FindFirstChild("Build") and localplr.PlayerGui.Build:FindFirstChild("Button") then
			bsize = localplr.PlayerGui.Build.Button.Text
		end
		if bsizev3 ~= nil and (bsizev3.X ~= mult or bsizev3.Y ~= mult or bsizev3.Z ~= mult) then
			bsize = "detailed"
		elseif bsizev3 ~= nil and (bsizev3.X == mult and bsizev3.Y == mult and bsizev3.Z == mult) then
			bsize = "normal"
		end
		if bsizev3 == nil and (bsize ~= "detailed") and oldprt and oldprt.Position ~= round(pos) then
			if (oldprt.Position - round(pos)).Magnitude > 0.5 then
				bsize = "detailed"
				needsresize = true
				bsizev3 = Vector3.new(4,4,4)
				pos = Vector3.new((pos.X - (bsizev3.X/2))+.5,(pos.Y - (bsizev3.Y/2))+.5,(pos.Z - (bsizev3.Z/2))+.5)
				if isSave then
					waitResize = math.max(0.04, resizewait * 0.25)
				end
			end
		end
	end
	local oldpos = pos
	pos = snap(pos)
	local args = {
		[1] = workspace.Terrain,
		[2] = Enum.NormalId.Top,
		[3] = pos,
		[4] = bsize or "normal"
	}
	built = false
	local s,e = pcall(function()
		local event = (localplr.Character.Build:FindFirstChild("origevent") and localplr.Character.Build.origevent:Invoke(unpack(args))) or localplr.Character.Build.Script.Event:FireServer(unpack(args))
	end)
	c = 0
	repeat
		c = c + 1
		if localplr.Character and not localplr.Character:FindFirstChild("Build") and localplr.Backpack:FindFirstChild("Build") then
			localplr.Backpack.Build.Parent = localplr.Character
		end
		if localplr.Character:FindFirstChild("Build") then
			local event = (localplr.Character.Build:FindFirstChild("origevent") and localplr.Character.Build.origevent:Invoke(unpack(args))) or localplr.Character.Build.Script.Event:FireServer(unpack(args))
		end
		local s,e = pcall(function()
			novel = true
			if tp then
				localplr.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
			end
		end)
		task.wait(waitBuild * 1.6)
	until (built == true and childcube) or stopped == true or skipblock == true or c > maxBuildTries
	novel = false
	built = false
	c = 0
	end
	if childcube and typeof(color) == "Color3" and (color ~= defaultcolor or (childcube.Color ~= color or childcube.Material ~= texture)) and (localplr.Backpack:FindFirstChild("Paint") or localplr.Character:FindFirstChild("Paint")) and ((colorbool and premadebuild ~= nil) or not colorbool) or texture then
		local pos = (childcube and childcube.Position + childcube.Size/2) or pos
		local args = {
			[1] = childcube,
			[2] = Enum.NormalId.Top,
			[3] = pos,
			[4] = "color",
			[5] = color or nil,
			[6] = "tiles",
			[7] = ""
		}
		task.wait()
		local success,err = pcall(function()
			localplr.Backpack.Paint.Parent = localplr.Character
		end)
		if texture ~= nil then
			if color == nil then
				args[4] = "material"
			else
				args[4] = "both \u{1F91D}"
			end
			args[6] = texture
		end
		if not childcube then
			oldprt:Destroy()
			return
		end
		local oldcolor = childcube.Color
		highlight.Adornee = childcube
		c = 0
		local s,e = pcall(function()
		repeat
			c = c + 1
			if localplr.Character and not localplr.Character:FindFirstChild("Paint") and localplr.Backpack:FindFirstChild("Paint") then
				localplr.Backpack.Paint.Parent = localplr.Character
			end
			if localplr.Character and localplr.Character:FindFirstChild("Paint") then
				local event = (localplr.Character.Paint:FindFirstChild("origevent") and localplr.Character.Paint.origevent:Invoke(unpack(args))) or localplr.Character.Paint.Script.Event:FireServer(unpack(args))
			end
			local s,e = pcall(function()
				novel = true
				if tp then
					localplr.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
				end
			end)
			task.wait(waitPaint)
		until not childcube or not childcube.Parent or childcube.Color == color or (texture and childcube.Material == Enum.Material[origmaterial]) or stopped == true or skipblock == true or c > maxPaintTries
		novel = false
		end)
	end
	if childcube and localplr.Character and localplr.Character:FindFirstChild("Paint") and childcube.Anchored ~= anchored then
		local pos = (childcube and childcube.Position + childcube.Size/2) or pos
		local args = {
			[1] = childcube,
			[2] = Enum.NormalId.Top,
			[3] = pos or childcube.Position+Vector3.new(1,0,0),
			[4] = "material",
			[5] = nil,
			[6] = "anchor",
			[7] = ""
		}
		c = 0
		repeat
			c = c + 1
			if localplr.Character and not localplr.Character:FindFirstChild("Paint") and localplr.Backpack:FindFirstChild("Paint") then
				localplr.Backpack.Paint.Parent = localplr.Character
			end
			if localplr.Character and localplr.Character:FindFirstChild("Paint") and childcube and childcube.Anchored ~= anchored then
				local event = (localplr.Character.Paint:FindFirstChild("origevent") and localplr.Character.Paint.origevent:Invoke(unpack(args))) or localplr.Character.Paint.Script.Event:FireServer(unpack(args))
			end
			local s,e = pcall(function()
				novel = true
				if tp then
					localplr.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,8,0))
				end
			end)
			task.wait(waitAnchor)
		until not childcube or not childcube.Parent or childcube.Anchored == anchored or not localplr.Character or (not localplr.Character:FindFirstChild("Paint") and not localplr.Backpack:FindFirstChild("Paint")) or stopped == true or skipblock == true or c > maxAnchorTries
		novel = false
	end
	if childcube and localplr.Character and localplr.Character:FindFirstChild("Paint") and childcube.CanCollide ~= collide then
		local pos = (childcube and childcube.Position + childcube.Size/2) or pos
		local args = {
			[1] = childcube,
			[2] = Enum.NormalId.Top,
			[3] = pos or childcube.Position+Vector3.new(1,0,0),
			[4] = "material",
			[5] = nil,
			[6] = "collide",
			[7] = ""
		}
		c = 0
		repeat
			c = c + 1
			if localplr.Character and not localplr.Character:FindFirstChild("Paint") and localplr.Backpack:FindFirstChild("Paint") then
				localplr.Backpack.Paint.Parent = localplr.Character
			end
			if localplr.Character and localplr.Character:FindFirstChild("Paint") and childcube and childcube.CanCollide ~= collide then
				local event = (localplr.Character.Paint:FindFirstChild("origevent") and localplr.Character.Paint.origevent:Invoke(unpack(args))) or localplr.Character.Paint.Script.Event:FireServer(unpack(args))
			end
			local s,e = pcall(function()
				novel = true
				if tp then
					localplr.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,8,0))
				end
			end)
			task.wait(waitAnchor)
		until not childcube or not childcube.Parent or childcube.CanCollide == collide or not localplr.Character or (not localplr.Character:FindFirstChild("Paint") and not localplr.Backpack:FindFirstChild("Paint")) or stopped == true or skipblock == true or c > maxAnchorTries
		novel = false
	end
	highlight.Adornee = nil
	if childcube and (localplr.Backpack:FindFirstChild("Paint") or localplr.Character:FindFirstChild("Paint")) and sprays ~= nil then
		local args = {
			[1] = childcube,
			[2] = Enum.NormalId.Front,
			[3] = childcube.Position+Vector3.new(1,0,0),
			[4] = "material",
			[5] = nil,
			[6] = "spray",
			[7] = "ha"
		}
		for i,v in pairs(sprays) do
			args[2] = Enum.NormalId[v[1]]
			args[7] = v[3]
			if childcube and (localplr.Backpack:FindFirstChild("Paint") or localplr.Character:FindFirstChild("Paint")) and stopped == false and skipblock == false then
				local success,err = pcall(function()
					localplr.Backpack.Paint.Parent = localplr.Character
				end)
				local success,err = pcall(function()
					task.wait(waitSpray)
					local event = (localplr.Character.Paint:FindFirstChild("origevent") and localplr.Character.Paint.origevent:Invoke(unpack(args))) or localplr.Character.Paint.Script.Event:FireServer(unpack(args))
				end)
			end
		end
	end
	if childcube and bsizev3 ~= nil and ((bsizev3.X ~= mult or bsizev3.Y ~= mult or bsizev3.Z ~= mult) or needsresize == true) and (localplr.Character:FindFirstChild("Shape") or localplr.Backpack:FindFirstChild("Shape")) then
		if not localplr.Character:FindFirstChild("Shape") and localplr.Backpack:FindFirstChild("Shape") then
			localplr.Backpack.Shape.Parent = localplr.Character
		end
		local function resizeAxis(normalId, axisName, targetSize)
			if not childcube or not childcube.Parent then return end
			if childcube.Size[axisName] == targetSize then return end
			local args = {[1]=childcube,[2]=normalId,[3]="",[4]=""}
			local maxTries = math.clamp(math.abs(childcube.Size[axisName] - targetSize) * 4 + 6, 8, 40)
			local stall = 0
			local lastSize = childcube.Size[axisName]
			local c = 0
			repeat
				c = c + 1
				if not childcube or not childcube.Parent then break end
				pos = childcube.Position + childcube.Size/2
				args[1] = childcube
				args[3] = pos
				args[4] = nil
				local cur = childcube.Size[axisName]
				if cur > targetSize then
					args[4] = "decrease"
				elseif cur < targetSize then
					args[4] = "increase"
				else
					break
				end
				if not localplr.Character:FindFirstChild("Shape") and localplr.Backpack:FindFirstChild("Shape") then
					localplr.Backpack.Shape.Parent = localplr.Character
				end
				if localplr.Character:FindFirstChild("Shape") then
					local event = (localplr.Character.Shape:FindFirstChild("origevent") and localplr.Character.Shape.origevent:Invoke(unpack(args))) or localplr.Character.Shape.Script.Event:FireServer(unpack(args))
				end
				local s,e = pcall(function()
					novel = true
					if tp then
						localplr.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
					end
				end)
				task.wait(waitResize)
				if childcube and childcube.Parent then
					if childcube.Size[axisName] == lastSize then
						stall = stall + 1
					else
						stall = 0
						lastSize = childcube.Size[axisName]
					end
				end
			until (childcube and childcube.Size[axisName] == targetSize)
				or (args[4] == "decrease" and childcube and childcube.Size[axisName] <= 1 and targetSize <= 1)
				or stopped == true or skipblock == true
				or not childcube or not childcube.Parent
				or c >= maxTries
				or stall >= 6
			novel = false
		end
		resizeAxis(Enum.NormalId.Right, "X", bsizev3.X)
		resizeAxis(Enum.NormalId.Top, "Y", bsizev3.Y)
		resizeAxis(Enum.NormalId.Back, "Z", bsizev3.Z)
	end
	skipblock = false
	end)
	if oldprt then
		oldprt:Destroy()
	end
	novel = false
	childcube = nil
	if not s then print(e) end
end
scrowners = {}
scrowners[8037732501] = true
scrowners[2387624455] = true
scrowners[7712298174] = true
scrowners[8176819177] = true
scrowners[7206552535] = true
scrowners[7692355288] = true
scrowners[7739036304] = true
scrowners[8354921817] = true
scrowners[8433979982] = true
scrowners[8448316736] = true
scrowners[8461858903] = true
scrowners[8457413331] = true
scrowners[8472051580] = true
scrowners[8519042103] = true
scrowners[8923010115] = true
scrowners[9096498334] = true
scrowners[9978235297] = true
scrowners[9337715494] = true
scrowners[10304502709] = true
scrowners[10950244484] = true
enderhubpeople = {}
enderhubpeople[2581030028] = true
enderhubpeople[9129601647] = true
enderhubpeople[10309331614] = true
enderhubpeople[10304652238] = true
enderhubpeople[2051023643] = true
lib.makebutton("Stop Building",buildtab,function()
	stopped = true
end)
lib.makebutton("Skip Block",buildtab,function()
	skipblock = true
end)
lib.maketoggle("Teleport to Block",buildtab,function(bool)
	tp = bool
end,true)
function convrot(int)
	return (int*360)/(math.pi*2)
end
lib.maketoggle("Annoy Aura (Dih)", grieftab, function(bool)
	getgenv()._tcoDihAura = bool
	if not bool then return end
	task.spawn(function()
		while getgenv()._tcoDihAura do
			pcall(function()
				local char = localplr.Character
				if not char then return end
				local my = char:FindFirstChild("HumanoidRootPart")
				if not my then return end
				if not char:FindFirstChild("Build") then
					local bp = localplr.Backpack:FindFirstChild("Build")
					if bp then bp.Parent = char end
				end
				local tool = char:FindFirstChild("Build")
				if not tool then return end
				local sizeMode = "normal"
				pcall(function()
					if localplr.PlayerGui:FindFirstChild("Build") and localplr.PlayerGui.Build:FindFirstChild("Button") then
						sizeMode = localplr.PlayerGui.Build.Button.Text
					end
				end)
				local m = 4
				local target = nil
				local best = 1e9
				for _, p in pairs(game.Players:GetPlayers()) do
					if p ~= localplr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						local d = (p.Character.HumanoidRootPart.Position - my.Position).Magnitude
						if d < best and d < 60 then
							best = d
							target = p.Character.HumanoidRootPart.Position
						end
					end
				end
				if not target then
					target = my.Position + my.CFrame.LookVector * 8
				end
				local cx = math.floor(target.X / m + 0.5) * m
				local cy = math.floor(target.Y / m + 0.5) * m
				local cz = math.floor(target.Z / m + 0.5) * m
				local offs = {
					Vector3.new(-m, 0, 0), Vector3.new(0, 0, 0), Vector3.new(m, 0, 0),
					Vector3.new(0, m, 0), Vector3.new(0, 2 * m, 0),
				}
				for i = 1, #offs do
					if not getgenv()._tcoDihAura then break end
					local pos = Vector3.new(cx, cy, cz) + offs[i]
					pcall(function()
						if tool:FindFirstChild("origevent") then
							tool.origevent:Invoke(workspace.Terrain, Enum.NormalId.Top, pos, sizeMode)
						elseif tool:FindFirstChild("Script") and tool.Script:FindFirstChild("Event") then
							tool.Script.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, pos, sizeMode)
						end
					end)
					task.wait(0.03)
				end
			end)
			task.wait(0.08)
		end
	end)
end, false)
spmbl = false
spmsi = false
tkill = false
lib.maketoggle("Toxify Aura",grieftab,function(bool)
	if not bool then auraStop("_tcoToxifyAura", "_tcoToxifyAura_gen") return end
	getgenv()._tcoToxifyAura = true
	local gen = auraBump("_tcoToxifyAura_gen")
	task.spawn(function()
		while getgenv()._tcoToxifyAura and getgenv()._tcoToxifyAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				if o then paintAround("toxic", Color3.fromRGB(0,255,0), o, getgenv()._tcoAuraRange or 35, "_tcoToxifyAura") end
			end)
			task.wait(0.05)
		end
	end)
end, false)
lib.maketoggle("Toxic Kill Aura",grieftab,function(bool)
	tkill = bool
	buildingtoxify = false
	while tkill do
		task.wait()
		if (not toxifybrick or not toxifybrick:IsDescendantOf(workspace.Bricks)) and ((localplr.Character:FindFirstChild("Build") or localplr.Backpack:FindFirstChild("Build")) or (localplr.Character:FindFirstChild("Paint") or localplr.Backpack:FindFirstChild("Paint"))) then
			buildingtoxify = true
			local opos = localplr.Character.HumanoidRootPart.CFrame
			buildblock(round(Vector3.new(math.random(10000,100000),math.random(1000,5000),math.random(10000,100000))),"toxic",Color3.fromRGB(0,0,0),nil,nil,true,"Neon",nil,nil,nil)
			buildingtoxify = false
			localplr.Character.HumanoidRootPart.CFrame = opos
		end
		if toxifybrick and (localplr.Character:FindFirstChild("Build") or localplr.Backpack:FindFirstChild("Build")) then
			for i,v in pairs(game.Players:GetPlayers()) do
				if v ~= localplr and v.Character and localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position - localplr.Character.HumanoidRootPart.Position).Magnitude < 40 then
		  			if localplr.Backpack:FindFirstChild("Build") and localplr.Character then
						localplr.Backpack.Build.Parent = localplr.Character
					end
					if localplr.Character and localplr.Character:FindFirstChild("Build") then
						local hrp = v.Character.HumanoidRootPart
						local pos = (hrp.CFrame * CFrame.new(0,0,-hrp.Velocity.Magnitude/2.5)).Position
						local event = (localplr.Character.Build:FindFirstChild("origevent") and localplr.Character.Build.origevent:Invoke(toxifybrick,Enum.NormalId.Top,pos,"detailed")) or localplr.Character.Build.Script.Event:FireServer(toxifybrick,Enum.NormalId.Top,pos,"detailed")
						task.wait(0.1)
					end
				end
			end
		end
	end
end)
function hasDeleteTool()
	return localplr.Backpack:FindFirstChild("Delete")
		or (localplr.Character and localplr.Character:FindFirstChild("Delete"))
end
function refreshDeleteTool()
	local deleteTool = hasDeleteTool()
	if not deleteTool then return false end
	local char = localplr.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local backpack = localplr.Backpack
	local heldName = nil
	for _, t in pairs(char:GetChildren()) do
		if t:IsA("Tool") and t.Name ~= "Delete" then
			heldName = t.Name
			break
		end
	end
	pcall(function()
		if deleteTool.Parent == char then
			deleteTool.Parent = backpack
		end
	end)
	pcall(function()
		if deleteTool.Parent == backpack then
			deleteTool.Parent = char
		end
	end)
	pcall(function()
		game:GetService("RunService").Heartbeat:Wait()
	end)
	pcall(function()
		if deleteTool and deleteTool.Parent == char then
			deleteTool.Parent = backpack
		end
	end)
	pcall(function()
		local d = char:FindFirstChild("Delete")
		if d then d.Parent = backpack end
	end)
	if heldName and hum then
		local held = backpack:FindFirstChild(heldName)
		if held then
			pcall(function() hum:EquipTool(held) end)
		end
	end
	return true
end
function refreshDeleteToolEquip()
	return refreshDeleteTool()
end
function fixBkit()
	local char = localplr.Character
	local backpack = localplr.Backpack
	if not char or not backpack then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local rs = game:GetService("RunService")
	local sg = game:GetService("StarterGui")
	pcall(function()
		sg:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
	task.wait(0.05)
	pcall(function()
		sg:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	end)
	pcall(function()
		if hum then hum:UnequipTools() end
	end)
	for _, t in pairs(char:GetChildren()) do
		if t:IsA("Tool") then
			pcall(function() t.Parent = backpack end)
		end
	end
	task.wait(0.05)
	local tools = {}
	for _, t in pairs(backpack:GetChildren()) do
		if t:IsA("Tool") then tools[#tools + 1] = t end
	end
	for _, t in ipairs(tools) do
		pcall(function()
			t.Parent = char
		end)
		rs.Heartbeat:Wait()
		pcall(function()
			t.Parent = backpack
		end)
	end
	pcall(function()
		if hum then hum:UnequipTools() end
	end)
	for _, t in pairs(char:GetChildren()) do
		if t:IsA("Tool") then
			pcall(function() t.Parent = backpack end)
		end
	end
	_cachedDeleteTools = {}
	_cachedDeleteEv = nil
	_cachedDeleteAt = 0
	pcall(function()
		if refreshDeleteCache then refreshDeleteCache() end
	end)
	local build = backpack:FindFirstChild("Build")
	if build and hum then
		pcall(function() hum:EquipTool(build) end)
	end
	return true
end
function findDeleteTools()
	local dtools = {}
	local function scan(container)
		if not container then return end
		for _, v in pairs(container:GetChildren()) do
			if v:IsA("Tool") and v.Name == "Delete" then
				local ev = nil
				if v:FindFirstChild("Script") and v.Script:FindFirstChild("Event") then
					ev = v.Script.Event
				end
				local inv = v:FindFirstChild("origevent")
				if ev or inv then
					table.insert(dtools, {bt = v, e = ev, inv = inv})
				end
			end
		end
	end
	scan(localplr.Backpack)
	scan(localplr.Character)
	return dtools
end
_dti = 0
_cachedDeleteTools = {}
_cachedDeleteEv = nil
_cachedDeleteIsInvoke = false
_cachedDeleteAt = 0
function refreshDeleteCache()
	_cachedDeleteTools = findDeleteTools()
	_cachedDeleteEv = nil
	_cachedDeleteIsInvoke = false
	if #_cachedDeleteTools > 0 then
		local dt = _cachedDeleteTools[1]
		if dt.e then
			_cachedDeleteEv = dt.e
			_cachedDeleteIsInvoke = false
		elseif dt.inv then
			_cachedDeleteEv = dt.inv
			_cachedDeleteIsInvoke = true
		end
	end
	_cachedDeleteAt = tick()
	return _cachedDeleteEv ~= nil
end
local _deleteCursor = 0
local _deleteLastCharacter = nil
function fireDelete(part)
	if not part or not part.Parent then return false end
	local hrp = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
	local hrpPos = hrp and hrp.Position or part.Position
	if tick() - _cachedDeleteAt > 1.5 or not _cachedDeleteEv then refreshDeleteCache() end
	local ev = _cachedDeleteEv
	if not ev then return false end
	local ok
	if _cachedDeleteIsInvoke then ok = pcall(function() ev:Invoke(part, hrpPos) end)
	else ok = pcall(function() ev:FireServer(part, hrpPos) end) end
	if not ok then _cachedDeleteEv = nil end
	return ok
end
function fireDeleteBurst(parts, limit)
	if not parts or #parts == 0 then return 0 end
	if tick() - _cachedDeleteAt > 1.5 or not _cachedDeleteEv then refreshDeleteCache() end
	if not _cachedDeleteEv then return 0 end
	local total = #parts
	local maxCount = math.min(tonumber(limit) or total, total)
	local start = (_deleteCursor % total) + 1
	local count = 0
	for off = 0, total - 1 do
		if count >= maxCount then break end
		local part = parts[((start + off - 1) % total) + 1]
		if part and part.Parent and fireDelete(part) then count = count + 1 end
		if count > 0 and count % 12 == 0 then task.wait() end
	end
	_deleteCursor = start + math.max(count, 1) - 1
	return count
end
_toolRemoteCache = _toolRemoteCache or {}
_toolRemoteAt = _toolRemoteAt or {}
function findToolAny(toolName)
	local bag = localplr.Backpack
	local char = localplr.Character
	if bag then
		local t = bag:FindFirstChild(toolName)
		if t and t:IsA("Tool") then return t end
	end
	if char then
		local t = char:FindFirstChild(toolName)
		if t and t:IsA("Tool") then return t end
	end
	return nil
end
function hasToolInInventory(toolName)
	return findToolAny(toolName) ~= nil
end
function refreshToolBypass(toolName)
	local tool = findToolAny(toolName)
	if not tool then return false end
	local char = localplr.Character
	local backpack = localplr.Backpack
	if not char or not backpack then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local heldName = nil
	for _, t in pairs(char:GetChildren()) do
		if t:IsA("Tool") and t.Name ~= toolName then
			heldName = t.Name
			break
		end
	end
	pcall(function()
		if tool.Parent == char then tool.Parent = backpack end
	end)
	pcall(function()
		if tool.Parent == backpack then tool.Parent = char end
	end)
	pcall(function()
		game:GetService("RunService").Heartbeat:Wait()
	end)
	pcall(function()
		if tool and tool.Parent == char then tool.Parent = backpack end
	end)
	pcall(function()
		local stray = char:FindFirstChild(toolName)
		if stray then stray.Parent = backpack end
	end)
	if heldName and hum then
		local held = backpack:FindFirstChild(heldName)
		if held then
			pcall(function() hum:EquipTool(held) end)
		end
	end
	_toolRemoteCache[toolName] = nil
	_toolRemoteAt[toolName] = 0
	return true
end
function getToolRemote(toolName)
	local now = tick()
	if _toolRemoteCache[toolName] and (now - (_toolRemoteAt[toolName] or 0)) < 3 then
		return _toolRemoteCache[toolName]
	end
	local tool = findToolAny(toolName)
	if not tool then return nil end
	local inv = tool:FindFirstChild("origevent")
	local ev = tool:FindFirstChild("Script") and tool.Script:FindFirstChild("Event")
	local remote = { tool = tool, inv = inv, ev = ev }
	_toolRemoteCache[toolName] = remote
	_toolRemoteAt[toolName] = now
	return remote
end
function fireToolRemote(toolName, ...)
	local char = localplr.Character
	local bag = localplr.Backpack
	if not char or not bag then return false end
	local now = tick()
	local cache = _toolRemoteCache[toolName]
	local at = _toolRemoteAt[toolName] or 0
	local tool = findToolAny(toolName)
	if not tool then return false end
	if (not cache) or (now - at > 3) or (not cache.inv and not cache.ev) then
		pcall(function()
			if tool.Parent == bag then
				tool.Parent = char
				task.wait()
			end
		end)
		tool = findToolAny(toolName) or tool
		cache = {
			tool = tool,
			inv = tool and tool:FindFirstChild("origevent"),
			ev = tool and tool:FindFirstChild("Script") and tool.Script:FindFirstChild("Event"),
		}
		_toolRemoteCache[toolName] = cache
		_toolRemoteAt[toolName] = now
		pcall(function()
			local t = findToolAny(toolName)
			if t and t.Parent == char then t.Parent = bag end
		end)
	end
	local inv, ev = cache.inv, cache.ev
	if not inv and not ev then
		_toolRemoteCache[toolName] = nil
		return false
	end
	local args = {...}
	local ok = pcall(function()
		if inv then inv:Invoke(unpack(args)) else ev:FireServer(unpack(args)) end
	end)
	pcall(function()
		local t = findToolAny(toolName)
		if t and char and t.Parent == char and bag then t.Parent = bag end
	end)
	return ok
end
function withToolSession(toolName, fn)
	local char = localplr.Character
	local bag = localplr.Backpack
	if not char or not bag then return false end
	local tool = findToolAny(toolName)
	if not tool then return false end
	pcall(function()
		if tool.Parent ~= char then tool.Parent = char end
	end)
	tool = char:FindFirstChild(toolName) or tool
	local inv = tool:FindFirstChild("origevent")
	local ev = tool:FindFirstChild("Script") and tool.Script:FindFirstChild("Event")
	local function fire(...)
		if inv then inv:Invoke(...) elseif ev then ev:FireServer(...) end
	end
	local ok = pcall(fn, fire, tool)
	pcall(function()
		local t = char:FindFirstChild(toolName)
		if t then t.Parent = bag end
	end)
	return ok
end
function equipNamedTool(toolName)
	local t = findToolAny(toolName)
	if not t then return nil end
	pcall(function()
		if not t:FindFirstChild("origevent") and not (t:FindFirstChild("Script") and t.Script:FindFirstChild("Event")) then
			refreshToolBypass(toolName)
		end
	end)
	local bag = localplr.Backpack
	local char = localplr.Character
	t = findToolAny(toolName)
	if t and char and bag and t.Parent == char then
		pcall(function() t.Parent = bag end)
	end
	return findToolAny(toolName)
end
function flingWithReturn(targetHRP, durationSec, returnHome)
	durationSec = durationSec or 5
	if returnHome == nil then returnHome = true end
	local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
	if not my or not targetHRP then return end
	local startCF = my.CFrame
	local t0 = tick()
	while tick() - t0 < durationSec do
		pcall(function()
			my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
			if not my or not targetHRP or not targetHRP.Parent then return end
			my.CFrame = targetHRP.CFrame
			local v = Vector3.new((math.random() - 0.5) * 3e4, 3e4, (math.random() - 0.5) * 3e4)
			targetHRP.AssemblyLinearVelocity = v
			pcall(function() targetHRP.Velocity = v end)
		end)
		task.wait()
	end
	if returnHome then
		pcall(function()
			my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
			if my then
				my.CFrame = startCF
				my.AssemblyLinearVelocity = Vector3.zero
				my.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end
end
function flingHold(targetHRP, durationSec)
	durationSec = durationSec or 0
	local t0 = tick()
	repeat
		pcall(function()
			local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
			if not my or not targetHRP or not targetHRP.Parent then return end
			my.CFrame = targetHRP.CFrame
			local v = Vector3.new((math.random() - 0.5) * 3e4, 3e4, (math.random() - 0.5) * 3e4)
			targetHRP.AssemblyLinearVelocity = v
			pcall(function() targetHRP.Velocity = v end)
		end)
		task.wait()
	until durationSec <= 0 or (tick() - t0) >= durationSec
end
function tcoSoftReturnHome(homeCF)
	if not homeCF then return end
	if getgenv()._tcoReturning then return end
	getgenv()._tcoReturning = true
	task.spawn(function()
		pcall(function()
			if typeof(tcoClearUnderHold) == "function" then tcoClearUnderHold() end
			local char = localplr.Character
			local my = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if my then
				my.AssemblyLinearVelocity = Vector3.zero
				my.AssemblyAngularVelocity = Vector3.zero
				my.CFrame = homeCF
			end
			if hum and hum.Health > 0 then
				hum.Sit = true
				hum.PlatformStand = false
				task.wait(0.2)
				hum.Sit = false
			end
		end)
		getgenv()._tcoBlameHomeCF = nil
		getgenv()._tcoReturning = false
	end)
end
function killFlingHold(targetHRP)
	pcall(function()
		local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
		if not my or not targetHRP or not targetHRP.Parent then return end
		local char = localplr.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
		my.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
		local v = Vector3.new((math.random() - 0.5) * 2e3, -8e3 - math.random() * 2e3, (math.random() - 0.5) * 2e3)
		targetHRP.AssemblyLinearVelocity = v
		pcall(function() targetHRP.Velocity = v end)
		my.AssemblyLinearVelocity = v * 0.1
	end)
end
function tcoStartBuildAura()
	getgenv()._tcoBuildAura = true
	local gen = (getgenv()._tcoBuildAura_gen or 0) + 1
	getgenv()._tcoBuildAura_gen = gen
	task.spawn(function()
		while getgenv()._tcoBuildAura and getgenv()._tcoBuildAura_gen == gen do
			pcall(function()
				local origin = getAuraOrigin()
				if not origin then return end
				local sizeMode = "normal"
				pcall(function()
					if localplr.PlayerGui:FindFirstChild("Build") and localplr.PlayerGui.Build:FindFirstChild("Button") then
						sizeMode = localplr.PlayerGui.Build.Button.Text
					end
				end)
				fireBuildAt(origin + Vector3.new(math.random(-10, 10), -1.5, math.random(-10, 10)), sizeMode)
			end)
			task.wait(0.03)
		end
	end)
end
function tcoStopBuildAura()
	getgenv()._tcoBuildAura = false
	getgenv()._tcoBuildAura_gen = (getgenv()._tcoBuildAura_gen or 0) + 1
end
function fireBuildAt(pos, sizeMode)
	sizeMode = sizeMode or "detailed"
	if not findToolAny("Build") then return false end
	return fireToolRemote("Build", workspace.Terrain, Enum.NormalId.Top, pos, sizeMode)
end
function fireSignAt(pos)
	if not findToolAny("Sign") then return false end
	return fireToolRemote("Sign", workspace.Terrain, Enum.NormalId.Top, pos, "normal")
end
function firePaintPart(part, mode, color)
	if not part or not part.Parent then return false end
	local char = localplr.Character
	local bag = localplr.Backpack
	if not char or not bag then return false end
	if not char:FindFirstChild("Paint") then
		local t = bag:FindFirstChild("Paint")
		if not t then return false end
		pcall(function() t.Parent = char end)
	end
	if not char:FindFirstChild("Paint") then return false end
	local pos = part.Position + part.Size / 2
	mode = tostring(mode or "black"):lower()
	local ok = true
	local movedPaint = false
	local paintTool = char:FindFirstChild("Paint")
	if not paintTool then
		paintTool = bag:FindFirstChild("Paint")
		movedPaint = paintTool ~= nil
	end
	local function fireArgs(args)
		local paint = char:FindFirstChild("Paint")
		if not paint then
			local t = bag:FindFirstChild("Paint")
			if t then t.Parent = char paint = t end
		end
		if not paint then return false end
		local inv = paint:FindFirstChild("origevent")
		local ev = paint:FindFirstChild("Script") and paint.Script:FindFirstChild("Event")
		if inv then
			inv:Invoke(unpack(args))
		elseif ev then
			ev:FireServer(unpack(args))
		else
			return false
		end
		return true
	end
	if mode == "black" or mode == "both" or mode == "neon" or mode == "color" then
		local col = color or Color3.fromRGB(0, 0, 0)
		local args = {
			[1] = part,
			[2] = Enum.NormalId.Top,
			[3] = pos,
			[4] = "both \u{1F91D}",
			[5] = col,
			[6] = "Neon",
			[7] = ""
		}
		ok = pcall(function() fireArgs(args) end) and ok
	end
	if mode == "plastic" then
		local col = color or Color3.fromRGB(255, 255, 255)
		local args = {
			[1] = part,
			[2] = Enum.NormalId.Top,
			[3] = pos,
			[4] = "both \u{1F91D}",
			[5] = col,
			[6] = "Plastic",
			[7] = ""
		}
		ok = pcall(function() fireArgs(args) end) and ok
	end
	if mode == "forcefield" then
		local col = color or Color3.fromRGB(0, 255, 255)
		local args = {
			[1] = part,
			[2] = Enum.NormalId.Top,
			[3] = pos,
			[4] = "both \u{1F91D}",
			[5] = col,
			[6] = "ForceField",
			[7] = ""
		}
		ok = pcall(function() fireArgs(args) end) and ok
	end
	if mode == "glass" then
		local col = color or Color3.fromRGB(150, 200, 255)
		local args = {
			[1] = part,
			[2] = Enum.NormalId.Top,
			[3] = pos,
			[4] = "both \u{1F91D}",
			[5] = col,
			[6] = "Glass",
			[7] = ""
		}
		ok = pcall(function() fireArgs(args) end) and ok
	end
	if mode == "unanchor" or mode == "both" then
		local args = {
			[1] = part,
			[2] = Enum.NormalId.Top,
			[3] = pos,
			[4] = "material",
			[5] = nil,
			[6] = "anchor",
			[7] = ""
		}
		ok = pcall(function() fireArgs(args) end) and ok
	end
	if movedPaint and paintTool and paintTool.Parent == char then pcall(function() paintTool.Parent = bag end) end
	return ok
end
function findNearestBrick(pos, maxDist)
	maxDist = maxDist or 8
	local bricks = workspace:FindFirstChild("Bricks")
	if not bricks then return nil end
	local best, bd = nil, maxDist
	local myName = localplr.Name
	for _, p in pairs(bricks:GetDescendants()) do
		if p:IsA("BasePart") then
			local d = (p.Position - pos).Magnitude
			if d < bd then
				best, bd = p, d
			end
		end
	end
	return best
end
function paintUntilBlack(part, unanchorToo, tries)
	tries = tries or 12
	if not part then return false end
	for i = 1, tries do
		if not part or not part.Parent then return false end
		local mode = unanchorToo and "both" or "black"
		firePaintPart(part, mode)
		task.wait(0.02)
		local done = false
		pcall(function()
			done = part.Color == Color3.fromRGB(0,0,0) or (part.Color.R < 0.15 and part.Color.G < 0.15 and part.Color.B < 0.15)
		end)
		if done and (not unanchorToo or part.Anchored == false) then
			return true
		end
		if unanchorToo and done then
			firePaintPart(part, "unanchor")
		end
	end
	return false
end
function getBuildCenter(folder)
	if not folder then return nil end
	local sum = Vector3.new(0, 0, 0)
	local n = 0
	for _, p in pairs(folder:GetDescendants()) do
		if p:IsA("BasePart") then
			sum = sum + p.Position
			n = n + 1
		end
	end
	if n == 0 then
		for _, p in pairs(folder:GetChildren()) do
			if p:IsA("BasePart") then
				sum = sum + p.Position
				n = n + 1
			end
		end
	end
	if n == 0 then return nil end
	return sum / n
end
function findBuildFolder(name)
	if not name or name == "" or name == "(none)" then return nil end
	local bricks = workspace:FindFirstChild("Bricks")
	if not bricks then return nil end
	local folder = bricks:FindFirstChild(name)
	if folder then return folder end
	for _, f in pairs(bricks:GetChildren()) do
		if f.Name:lower() == name:lower() then return f end
	end
	return nil
end
function tpToBuild(folder)
	local center = getBuildCenter(folder)
	if not center then return false end
	local ok = pcall(function()
		local char = localplr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.CFrame = CFrame.new(center + Vector3.new(0, 14, 0))
	end)
	return ok
end
task.spawn(function()
	task.wait(0.5)
	pcall(refreshDeleteTool)
end)
daurarange = 35
daurapart = Instance.new("Part")
daurapart.Shape = Enum.PartType.Ball
daurapart.Anchored = true
daurapart.CanCollide = false
daurapart.CastShadow = false
daurapart.CanQuery = false
daurapart.Color = Color3.fromRGB(255, 0, 0)
daurapart.Transparency = 1
daurapart.Size = Vector3.new(daurarange, daurarange, daurarange)
daurapart.Parent = workspace
lib.maketextbox("Range of delete aura (studs, default is 35)",grieftab,function(txt)
	local n = tonumber(txt)
	if n and n > 0 then
		daurarange = n
		daurapart.Size = Vector3.new(daurarange, daurarange, daurarange)
	end
end)
filter = OverlapParams.new()
filter.FilterType = Enum.RaycastFilterType.Include
filter.MaxParts = 120
pcall(function() if workspace:FindFirstChild("Bricks") then filter:AddToFilter(workspace.Bricks) end end)
daura = false
lib.maketoggle("Delete Aura",grieftab,function(bool)
	daura = bool
	if daura then
		daurapart.Transparency = 0.55
		pcall(refreshDeleteTool)
		task.spawn(function()
			task.wait(0.2)
			pcall(refreshDeleteTool)
		end)
	else
		daurapart.Transparency = 1
		pcall(function()
			local t = hasDeleteTool()
			if t and localplr.Character and t.Parent == localplr.Character then
				t.Parent = localplr.Backpack
			end
		end)
	end
end)
dauras = false
ors = true
coroutine.wrap(function()
	local lastRefresh = 0
	local lastCharacter = nil
	while ors do
		if not (daura or dauras) then
			task.wait(0.05)
		else
			pcall(function()
				local char = localplr.Character
				if not char then return end
				if char ~= lastCharacter then
					lastCharacter = char
					lastRefresh = 0
					_cachedDeleteEv = nil
				end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				if not hasDeleteTool() then return end
				if tick() - lastRefresh > 2 or not _cachedDeleteEv then
					lastRefresh = tick()
					pcall(refreshDeleteTool)
					pcall(refreshDeleteCache)
				end
				local pos = hrp.Position
				local range = daurarange or 35
				daurapart.Position = pos
				daurapart.Size = Vector3.new(range * 2, range * 2, range * 2)
				local targets = {}
				local r2 = range * range
				local bricks = workspace:FindFirstChild("Bricks")
				if bricks then
					for _, v in pairs(bricks:GetDescendants()) do
						if v:IsA("BasePart") then
							local d = v.Position - pos
							if d.X * d.X + d.Y * d.Y + d.Z * d.Z <= r2 then
								targets[#targets + 1] = v
								if #targets >= 240 then break end
							end
						end
					end
				end
				if #targets > 0 then
					local deleted = fireDeleteBurst(targets, 36)
					if deleted == 0 then _cachedDeleteEv = nil; pcall(refreshDeleteCache) end
				end
			end)
			task.wait(0.08)
		end
	end
end)()
griefSelName = nil
griefTargets = {}
griefRunning = false
griefHL = nil
griefTP = true
function clearGHL()
	if griefHL then pcall(function() griefHL:Destroy() end) griefHL = nil end
end
function ownersList()
	local t = {}
	pcall(function()
		local bricks = workspace:FindFirstChild("Bricks")
		if not bricks then return end
		for _, f in pairs(bricks:GetChildren()) do
			if f.Name ~= localplr.Name and #f:GetChildren() > 0 then
				t[#t + 1] = f.Name
			end
		end
	end)
	table.sort(t, function(a, b) return a:lower() < b:lower() end)
	if #t == 0 then t[1] = "(none)" end
	return t
end
lib.makelabel("--- auras ---", grieftab)
getgenv()._tcoAuraRange = getgenv()._tcoAuraRange or 35
lib.maketextbox("Aura range (default 35)", grieftab, function(txt)
	local n = tonumber(txt)
	if n and n > 0 then getgenv()._tcoAuraRange = n end
end)
pcall(function() tcoAddModeToggles(grieftab) end)
lib.maketoggle("Sign Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoSignAura", "_tcoSignAura_gen") return end
	getgenv()._tcoSignAura = true
	local gen = auraBump("_tcoSignAura_gen")
	task.spawn(function()
		while getgenv()._tcoSignAura and getgenv()._tcoSignAura_gen == gen do
			pcall(function()
				local origin = getAuraOrigin()
				if not origin then return end
				fireSignAt(origin + Vector3.new(math.random(-8,8), -1.5, math.random(-8,8)))
			end)
			task.wait(0.05)
		end
	end)
end, false)
lib.maketoggle("Build Aura", grieftab, function(bool)
	if not bool then
		getgenv()._tcoBuildAura = false
		getgenv()._tcoBuildAura_gen = (getgenv()._tcoBuildAura_gen or 0) + 1
		return
	end
	tcoStartBuildAura()
end, false)
function auraBump(genKey)
	getgenv()[genKey] = (getgenv()[genKey] or 0) + 1
	return getgenv()[genKey]
end
function auraStop(flag, genKey)
	getgenv()[flag] = false
	if genKey then auraBump(genKey) end
end
getgenv()._tcoUG = getgenv()._tcoUG or false
getgenv()._tcoSafeMode = getgenv()._tcoSafeMode or false
getgenv()._tcoInvisMode = getgenv()._tcoInvisMode or false
getgenv()._tcoModeHomeCF = nil
function tcoChatCmd(msg)
	pcall(function()
		local tcs = game:GetService("TextChatService")
		if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
			local ch = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
			if ch then ch:SendAsync(msg) return end
		end
		local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
		if ev and ev:FindFirstChild("SayMessageRequest") then
			ev.SayMessageRequest:FireServer(msg, "All")
		end
	end)
end
function tcoBypassArken()
	pcall(function()
		local name = "The Arkenstone"
		local t = findToolAny and findToolAny(name)
		if not t then
			t = localplr.Backpack:FindFirstChild(name) or localplr.Backpack:FindFirstChild("Arkenstone") or localplr.Backpack:FindFirstChild("Enlighten")
		end
		if not t then return end
		local char, bag = localplr.Character, localplr.Backpack
		if not char or not bag then return end
		pcall(function() t.Parent = char end)
		task.defer(function()
			pcall(function()
				local x = char:FindFirstChild(t.Name)
				if x then x.Parent = bag end
			end)
		end)
	end)
end
function tcoIsRiskyTarget(hrp)
	if not hrp then return true end
	local pos = hrp.Position
	local vel = hrp.AssemblyLinearVelocity or Vector3.zero
	if vel.Magnitude > 40 then return true end
	if vel.Y > 12 then return true end
	if pos.Y > (getgenv()._tcoSafeY or 80) then return true end
	local hum = hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
	if hum then
		local st = hum:GetState()
		if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Flying
			or st == Enum.HumanoidStateType.Climbing or st == Enum.HumanoidStateType.Swimming then
			return true
		end
	end
	return false
end
function tcoSaveHome()
	local h = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
	if h and not getgenv()._tcoModeHomeCF then
		getgenv()._tcoModeHomeCF = h.CFrame
	end
end
function tcoRestoreHome()
	local h = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
	local cf = getgenv()._tcoModeHomeCF
	if h and cf then
		pcall(function()
			h.CFrame = cf
			h.AssemblyLinearVelocity = Vector3.zero
		end)
	end
	getgenv()._tcoModeHomeCF = nil
end
function tcoApplyTargetMode(targetHRP)
	if not targetHRP then return false end
	local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
	if not my then return false end
	if getgenv()._tcoSafeMode and tcoIsRiskyTarget(targetHRP) then
		tcoRestoreHome()
		return false
	end
	tcoSaveHome()
	if getgenv()._tcoInvisMode then
		pcall(function()
			for _, p in ipairs(localplr.Character:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
			my.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
		end)
		return true
	end
	if getgenv()._tcoUG then
		pcall(function()
			my.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, -6, 0))
			my.AssemblyLinearVelocity = Vector3.zero
		end)
		return true
	end
	return true
end
function tcoStopTargetMode()
	local wasInvis = getgenv()._tcoInvisMode
	tcoRestoreHome()
	if wasInvis then
		task.spawn(function()
			tcoBypassArken()
			tcoChatCmd(";visible me")
			task.wait(1)
			tcoBypassArken()
		end)
	end
end
function tcoAddModeToggles(tab)
	lib.makelabel("--- aura target modes ---", tab)
	lib.maketoggle("Safe mode (abort if flying/climbing)", tab, function(bool)
		getgenv()._tcoSafeMode = bool
		if not bool then return end
		task.spawn(function()
			while getgenv()._tcoSafeMode do
				pcall(function()
					if not getgenv()._tcoBlameUnder then return end
					local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
					if not my then return end
					local hum = localplr.Character and localplr.Character:FindFirstChildOfClass("Humanoid")
					local st = hum and hum:GetState()
					local vel = my.AssemblyLinearVelocity or Vector3.zero
					local flying = (st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Flying
						or st == Enum.HumanoidStateType.Climbing) or (vel.Y > 18) or (vel.Magnitude > 55)
					local high = my.Position.Y > (getgenv()._tcoSafeY or 80)
					if flying or high then
						getgenv()._tcoBlameUnder = false
						getgenv()._tcoUG = false
						if typeof(tcoClearUnderHold) == "function" then tcoClearUnderHold() end
						local home = getgenv()._tcoBlameHomeCF
						if typeof(tcoSoftReturnHome) == "function" and home then
							tcoSoftReturnHome(home)
						end
					end
				end)
				task.wait(0.05)
			end
		end)
	end, getgenv()._tcoSafeMode and true or false)
	lib.maketoggle("Invisible mode (noclip behind + auras)", tab, function(bool)
		getgenv()._tcoInvisMode = bool
		if bool then
			getgenv()._tcoUG = false
			tcoSaveHome()
		else
			tcoStopTargetMode()
		end
	end, getgenv()._tcoInvisMode and true or false)
end
function getAuraOrigin()
	local ch = localplr.Character
	local h = ch and ch:FindFirstChild("HumanoidRootPart")
	return h and h.Position or nil
end
function tcoInstantNoclipUnder(targetPos)
	if not targetPos then return end
	local char = localplr.Character
	if not char then return end
	pcall(function()
		if not getgenv()._tcoBlameHomeCF then
			local r0 = char:FindFirstChild("HumanoidRootPart")
			if r0 then getgenv()._tcoBlameHomeCF = r0.CFrame end
		end
		for _, p in pairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local r = char:FindFirstChild("HumanoidRootPart")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Physics)
			hum.AutoRotate = false
		end
		if r then
			local holdY = targetPos.Y - 5.5
			r.CFrame = CFrame.new(targetPos.X, holdY, targetPos.Z) * CFrame.Angles(-math.pi/2, 0, 0)
			r.AssemblyLinearVelocity = Vector3.zero
			r.AssemblyAngularVelocity = Vector3.zero
			if not r:FindFirstChild("TCOUnderBV") then
				local bv = Instance.new("BodyVelocity")
				bv.Name = "TCOUnderBV"
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Velocity = Vector3.zero
				bv.Parent = r
			else
				r.TCOUnderBV.Velocity = Vector3.zero
			end
		end
	end)
end
function tcoClearUnderHold()
	pcall(function()
		local char = localplr.Character
		local r = char and char:FindFirstChild("HumanoidRootPart")
		if r and r:FindFirstChild("TCOUnderBV") then r.TCOUnderBV:Destroy() end
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = true end
		if char then
			for _, p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = true end
			end
		end
	end)
end
getgenv()._tcoUGSpeed = getgenv()._tcoUGSpeed or 40
getgenv()._tcoUGMaxY = getgenv()._tcoUGMaxY or 0
getgenv()._tcoStartUGControl = function()
	getgenv()._tcoStopUGControl()
	local char = localplr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	getgenv()._tcoUGHomeCF = hrp.CFrame
	getgenv()._tcoUGControl = true
	local maxY = tonumber(getgenv()._tcoUGMaxY) or 0
	local hoverY = maxY - 0.1
	local startPos = Vector3.new(hrp.Position.X, hoverY, hrp.Position.Z)
	pcall(function()
		hrp.Anchored = true
		hrp.CFrame = CFrame.new(startPos) * CFrame.Angles(-math.pi / 2, 0, 0)
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		hum.PlatformStand = true
		hum.AutoRotate = false
		hum:ChangeState(Enum.HumanoidStateType.Physics)
	end)
	local keys = {W=false,A=false,S=false,D=false}
	local UIS = game:GetService("UserInputService")
	local conns = {}
	local gui = Instance.new("ScreenGui")
	gui.Name = "TCOUGControl"
	gui.ResetOnSpawn = false
	pcall(function() gui.Parent = game.CoreGui end)
	if not gui.Parent then gui.Parent = localplr.PlayerGui end
	getgenv()._tcoUGGui = gui
	local function mbtn(text, pos)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 56, 0, 56)
		b.Position = pos
		b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		b.BackgroundTransparency = 0.3
		b.Text = text
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 16
		b.Parent = gui
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
		return b
	end
	local function hold(btn, key)
		table.insert(conns, btn.MouseButton1Down:Connect(function() keys[key] = true end))
		table.insert(conns, btn.MouseButton1Up:Connect(function() keys[key] = false end))
		table.insert(conns, btn.InputEnded:Connect(function() keys[key] = false end))
	end
	hold(mbtn("W", UDim2.new(1, -140, 1, -180)), "W")
	hold(mbtn("A", UDim2.new(1, -200, 1, -120)), "A")
	hold(mbtn("S", UDim2.new(1, -140, 1, -120)), "S")
	hold(mbtn("D", UDim2.new(1, -80, 1, -120)), "D")
	table.insert(conns, UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		local k = input.KeyCode
		if k == Enum.KeyCode.W then keys.W = true
		elseif k == Enum.KeyCode.A then keys.A = true
		elseif k == Enum.KeyCode.S then keys.S = true
		elseif k == Enum.KeyCode.D then keys.D = true
		end
	end))
	table.insert(conns, UIS.InputEnded:Connect(function(input)
		local k = input.KeyCode
		if k == Enum.KeyCode.W then keys.W = false
		elseif k == Enum.KeyCode.A then keys.A = false
		elseif k == Enum.KeyCode.S then keys.S = false
		elseif k == Enum.KeyCode.D then keys.D = false
		end
	end))
	table.insert(conns, game:GetService("RunService").RenderStepped:Connect(function(dt)
		if not getgenv()._tcoUGControl then return end
		local c = localplr.Character
		local h = c and c:FindFirstChild("HumanoidRootPart")
		local hu = c and c:FindFirstChildOfClass("Humanoid")
		if not h then return end
		if hu then
			hu.PlatformStand = true
			hu.AutoRotate = false
		end
		local cam = workspace.CurrentCamera
		if not cam then return end
		local look = cam.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.05 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
		local right = Vector3.new(flat.Z, 0, -flat.X)
		local move = Vector3.zero
		if keys.W then move = move + flat end
		if keys.S then move = move - flat end
		if keys.A then move = move - right end
		if keys.D then move = move + right end
		local spd = tonumber(getgenv()._tcoUGSpeed) or 40
		local maxY = tonumber(getgenv()._tcoUGMaxY) or 0
		local hoverY = maxY - 0.1
		local pos = h.Position
		if move.Magnitude > 0 then
			local delta = move.Unit * spd * dt
			pos = Vector3.new(pos.X + delta.X, hoverY, pos.Z + delta.Z)
		else
			pos = Vector3.new(pos.X, hoverY, pos.Z)
		end
		local yaw = math.atan2(-flat.X, -flat.Z)
		h.Anchored = true
		h.CFrame = CFrame.new(pos) * CFrame.Angles(-math.pi / 2, yaw, 0)
		h.AssemblyLinearVelocity = Vector3.zero
		h.AssemblyAngularVelocity = Vector3.zero
	end))
	getgenv()._tcoUGConns = conns
end
getgenv()._tcoStopUGControl = function()
	getgenv()._tcoUGControl = false
	local conns = getgenv()._tcoUGConns
	if conns then
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	end
	getgenv()._tcoUGConns = nil
	if getgenv()._tcoUGGui then pcall(function() getgenv()._tcoUGGui:Destroy() end) end
	getgenv()._tcoUGGui = nil
	local home = getgenv()._tcoUGHomeCF
	local char = localplr.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	pcall(function()
		if hrp then
			hrp.Anchored = false
		end
		if hum then
			hum.PlatformStand = false
			hum.AutoRotate = true
		end
		if hrp and home then
			hrp.CFrame = home
			hrp.AssemblyLinearVelocity = Vector3.zero
		end
	end)
	getgenv()._tcoUGHomeCF = nil
end
local _paintCursor = 0
local _paintLastPulse = 0
local _paintLastMode = nil
local _paintScanAt = 0
local _paintScanCenter = nil
local _paintScanRange = 0
local _paintTargetCache = {}
local _paintAuraFlags = {
	"_tcoUnanchorAura", "_tcoBlackAura", "_tcoWhiteAura", "_tcoRainbowAura",
	"_tcoFFAura", "_tcoGlassAura", "_tcoMetalAura", "_tcoIceAura", "_tcoWoodAura",
	"_tcoCmdPaint_unanchor", "_tcoCmdPaint_black", "_tcoCmdPaint_plastic",
	"_tcoCmdPaint_forcefield", "_tcoCmdPaint_glass", "_tcoCmdPaint_metal",
	"_tcoCmdPaint_ice", "_tcoCmdPaint_wood", "_tcoCmdPaint_neon",
	"_tcoCmdPaint_yellow", "_tcoCmdPaint_yellow_unanchor", "_tcoCmdPaint_toxic",
	"_tcoCmdPaint_rainbow",
}
function paintAround(mode, color, centerPos, range, stopFlag, stopGenKey)
	getgenv().paintAround = paintAround
	range = tonumber(range) or getgenv()._tcoAuraRange or 35
	local char = localplr.Character
	if not centerPos then
		centerPos = getAuraOrigin and getAuraOrigin() or nil
		if not centerPos then
			if not char or not char:FindFirstChild("HumanoidRootPart") then return 0 end
			centerPos = char.HumanoidRootPart.Position
		end
	end
	if stopFlag and getgenv()[stopFlag] == false then return 0 end
	if stopGenKey and getgenv()[stopGenKey] and stopFlag then
	end
	if not findToolAny("Paint") then return 0 end
	local now = tick()
	local activeAuras = 0
	local stopFlagListed = false
	for _, flag in ipairs(_paintAuraFlags) do
		if flag == stopFlag then stopFlagListed = true end
		if getgenv()[flag] then activeAuras = activeAuras + 1 end
	end
	if stopFlag and not stopFlagListed and getgenv()[stopFlag] then activeAuras = activeAuras + 1 end
	local pulseGap = activeAuras > 1 and 0.12 or 0.08
	local modeKey = stopFlag or tostring(mode)
	if now - _paintLastPulse < pulseGap then return 0 end
	if activeAuras > 1 and _paintLastMode == modeKey then return 0 end
	_paintLastPulse = now
	_paintLastMode = modeKey
	local bricks = workspace:FindFirstChild("Bricks")
	if not bricks then return 0 end
	local r2 = range * range
	local list
	local cacheFresh = (now - _paintScanAt) < 0.25
	local moved = not _paintScanCenter or (_paintScanCenter - centerPos).Magnitude > 4
	if cacheFresh and not moved and _paintScanRange == range and #_paintTargetCache > 0 then
		list = _paintTargetCache
	else
		list = {}
		for _, folder in pairs(bricks:GetChildren()) do
			for _, part in pairs(folder:GetChildren()) do
				if part:IsA("BasePart") then
					local d = part.Position - centerPos
					if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= r2 then
						list[#list+1] = part
						if #list >= 160 then break end
					end
				end
			end
			if #list >= 160 then break end
		end
		if #list == 0 then
			for _, part in pairs(bricks:GetDescendants()) do
				if part:IsA("BasePart") then
					local d = part.Position - centerPos
					if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= r2 then
						list[#list+1] = part
						if #list >= 160 then break end
					end
				end
			end
		end
		_paintTargetCache = list
		_paintScanAt = now
		_paintScanCenter = centerPos
		_paintScanRange = range
	end
	if #list == 0 then return 0 end
	mode = tostring(mode or "black"):lower()
	local col = color
	if mode == "black" or mode == "neon" or mode == "color" then
		col = col or Color3.fromRGB(0,0,0)
	elseif mode == "yellow" or mode == "yellow_unanchor" then
		col = col or Color3.fromRGB(255,255,0)
	elseif mode == "plastic" then
		col = col or Color3.fromRGB(255,255,255)
	elseif mode == "forcefield" then
		col = col or Color3.fromRGB(0,255,255)
	elseif mode == "glass" then
		col = col or Color3.fromRGB(150,200,255)
	elseif mode == "metal" then
		col = col or Color3.fromRGB(163,162,165)
	elseif mode == "ice" then
		col = col or Color3.fromRGB(128,187,219)
	elseif mode == "wood" then
		col = col or Color3.fromRGB(86,66,54)
	elseif mode == "toxic" then
		col = col or Color3.fromRGB(0,255,0)
	end
	local n = 0
	local maxN = activeAuras > 1 and 2 or 4
	local startIdx = (_paintCursor % #list) + 1
	withToolSession("Paint", function(fire)
		for off = 0, #list - 1 do
			if stopFlag and getgenv()[stopFlag] == false then return end
			if n >= maxN then break end
			local part = list[((startIdx + off - 1) % #list) + 1]
			if part and part.Parent then
				local pos = part.Position + part.Size / 2
				if mode == "unanchor" then
					fire(part, Enum.NormalId.Top, pos, "material", nil, "anchor", "")
				elseif mode == "yellow_unanchor" or mode == "yellow" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col or Color3.fromRGB(255,255,0), "neon", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "neon", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "anchor", "")
				elseif mode == "plastic" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col, "plastic", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "plastic", "")
				elseif mode == "forcefield" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col, "forcefield", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "forcefield", "")
				elseif mode == "glass" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col, "glass", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "glass", "")
				elseif mode == "metal" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col, "metal", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "metal", "")
				elseif mode == "ice" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col, "ice", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "ice", "")
				elseif mode == "wood" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col, "wood", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "wood", "")
				elseif mode == "toxic" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col or Color3.fromRGB(0,255,0), "toxic", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "toxic", "")
				elseif mode == "black" or mode == "neon" or mode == "color" then
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col or Color3.fromRGB(0,0,0), "neon", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "neon", "")
				else
					fire(part, Enum.NormalId.Top, pos, "both \u{1F91D}", col or Color3.fromRGB(0,0,0), "neon", "")
					fire(part, Enum.NormalId.Top, pos, "material", nil, "neon", "")
				end
				n = n + 1
			end
		end
	end)
	_paintCursor = startIdx + n
	return n
end
lib.maketoggle("Unanchor Aura (Paint)", grieftab, function(bool)
	if not bool then auraStop("_tcoUnanchorAura", "_tcoUnanchorAura_gen") return end
	getgenv()._tcoUnanchorAura = true
	local gen = (getgenv()._tcoUnanchorAura_gen or 0) + 1
	getgenv()._tcoUnanchorAura_gen = gen
	task.spawn(function()
		while getgenv()._tcoUnanchorAura and getgenv()._tcoUnanchorAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("unanchor", nil, o, getgenv()._tcoAuraRange or 35, "_tcoUnanchorAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("Black Neon Aura (Paint)", grieftab, function(bool)
	if not bool then auraStop("_tcoBlackAura", "_tcoBlackAura_gen") return end
	getgenv()._tcoBlackAura = true
	local gen = (getgenv()._tcoBlackAura_gen or 0) + 1
	getgenv()._tcoBlackAura_gen = gen
	task.spawn(function()
		while getgenv()._tcoBlackAura and getgenv()._tcoBlackAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("black", nil, o, getgenv()._tcoAuraRange or 35, "_tcoBlackAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("White Plastic Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoWhiteAura", "_tcoWhiteAura_gen") return end
	getgenv()._tcoWhiteAura = true
	local gen = (getgenv()._tcoWhiteAura_gen or 0) + 1
	getgenv()._tcoWhiteAura_gen = gen
	task.spawn(function()
		while getgenv()._tcoWhiteAura and getgenv()._tcoWhiteAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("plastic", Color3.fromRGB(255,255,255), o, getgenv()._tcoAuraRange or 35, "_tcoWhiteAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("Rainbow Neon Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoRainbowAura", "_tcoRainbowAura_gen") return end
	getgenv()._tcoRainbowAura = true
	local gen = (getgenv()._tcoRainbowAura_gen or 0) + 1
	getgenv()._tcoRainbowAura_gen = gen
	task.spawn(function()
		local h = 0
		while getgenv()._tcoRainbowAura and getgenv()._tcoRainbowAura_gen == gen do
			pcall(function()
				h = (h + 0.05) % 1
				local col = Color3.fromHSV(h, 1, 1)
				local o = getAuraOrigin()
				paintAround("black", col, o, getgenv()._tcoAuraRange or 35)
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("ForceField Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoFFAura", "_tcoFFAura_gen") return end
	getgenv()._tcoFFAura = true
	local gen = (getgenv()._tcoFFAura_gen or 0) + 1
	getgenv()._tcoFFAura_gen = gen
	task.spawn(function()
		while getgenv()._tcoFFAura and getgenv()._tcoFFAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("forcefield", Color3.fromRGB(0,255,255), o, getgenv()._tcoAuraRange or 35, "_tcoFFAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("Glass Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoGlassAura", "_tcoGlassAura_gen") return end
	getgenv()._tcoGlassAura = true
	local gen = (getgenv()._tcoGlassAura_gen or 0) + 1
	getgenv()._tcoGlassAura_gen = gen
	task.spawn(function()
		while getgenv()._tcoGlassAura and getgenv()._tcoGlassAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("glass", nil, o, getgenv()._tcoAuraRange or 35, "_tcoGlassAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("Metal Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoMetalAura", "_tcoMetalAura_gen") return end
	getgenv()._tcoMetalAura = true
	local gen = auraBump("_tcoMetalAura_gen")
	task.spawn(function()
		while getgenv()._tcoMetalAura and getgenv()._tcoMetalAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("metal", Color3.fromRGB(163,162,165), o, getgenv()._tcoAuraRange or 35, "_tcoMetalAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("Ice Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoIceAura", "_tcoIceAura_gen") return end
	getgenv()._tcoIceAura = true
	local gen = auraBump("_tcoIceAura_gen")
	task.spawn(function()
		while getgenv()._tcoIceAura and getgenv()._tcoIceAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("ice", Color3.fromRGB(128,187,219), o, getgenv()._tcoAuraRange or 35, "_tcoIceAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("Wood Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoWoodAura", "_tcoWoodAura_gen") return end
	getgenv()._tcoWoodAura = true
	local gen = auraBump("_tcoWoodAura_gen")
	task.spawn(function()
		while getgenv()._tcoWoodAura and getgenv()._tcoWoodAura_gen == gen do
			pcall(function()
				local o = getAuraOrigin()
				paintAround("wood", Color3.fromRGB(86,66,54), o, getgenv()._tcoAuraRange or 35, "_tcoWoodAura")
			end)
			task.wait(0.10)
		end
	end)
end, false)
lib.maketoggle("Tiny Blocks Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoTinyBlocks", "_tcoTinyBlocks_gen") return end
	getgenv()._tcoTinyBlocks = true
	local gen = auraBump("_tcoTinyBlocks_gen")
	task.spawn(function()
		while getgenv()._tcoTinyBlocks and getgenv()._tcoTinyBlocks_gen == gen do
			pcall(function()
				local base = getAuraOrigin()
				if not base then return end
				for i = 1, 6 do
					fireBuildAt(base + Vector3.new((math.random()-0.5)*10, (math.random()-0.5)*3-1, (math.random()-0.5)*10), "detailed")
				end
			end)
			task.wait(0.03)
		end
	end)
end, false)
lib.maketoggle("Tiny Yellow Neon Blocks Aura", grieftab, function(bool)
	if not bool then
		auraStop("_tcoYellowTiny", "_tcoYellowTiny_gen")
		getgenv()._tcoBuildingYellow = false
		return
	end
	getgenv()._tcoYellowTiny = true
	local gen = auraBump("_tcoYellowTiny_gen")
	task.spawn(function()
		while getgenv()._tcoYellowTiny and getgenv()._tcoYellowTiny_gen == gen do
			pcall(function()
				local origin = getAuraOrigin()
				if not origin then return end
				if not getgenv()._tcoYellowBrick or not getgenv()._tcoYellowBrick.Parent then
					getgenv()._tcoBuildingYellow = true
					local opos = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") and localplr.Character.HumanoidRootPart.CFrame
					pcall(function()
						buildblock(Vector3.new(math.random(10000,100000), math.random(1000,5000), math.random(10000,100000)), "neon", Color3.fromRGB(255,255,0), nil, nil, true, "Neon", nil, nil, nil)
					end)
					getgenv()._tcoBuildingYellow = false
					if opos and localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
						localplr.Character.HumanoidRootPart.CFrame = opos
					end
				end
				local yb = getgenv()._tcoYellowBrick
				if yb and yb.Parent and localplr.Character then
					if not localplr.Character:FindFirstChild("Build") then
						local bp = localplr.Backpack:FindFirstChild("Build")
						if bp then bp.Parent = localplr.Character end
					end
					local tool = localplr.Character:FindFirstChild("Build")
					if tool then
						for i = 1, 4 do
							if not getgenv()._tcoYellowTiny then break end
							local pos = origin + Vector3.new((math.random()-0.5)*10, (math.random()-0.5)*3, (math.random()-0.5)*10)
							pcall(function()
								if tool:FindFirstChild("origevent") then
									tool.origevent:Invoke(yb, Enum.NormalId.Top, pos, "detailed")
								elseif tool:FindFirstChild("Script") and tool.Script:FindFirstChild("Event") then
									tool.Script.Event:FireServer(yb, Enum.NormalId.Top, pos, "detailed")
								end
							end)
						end
					end
				end
				paintAround("yellow_unanchor", Color3.fromRGB(255,255,0), origin, getgenv()._tcoAuraRange or 35, "_tcoYellowTiny")
			end)
			task.wait(0.06)
		end
	end)
end, false)
lib.maketoggle("Floor Spam Aura", grieftab, function(bool)
	if not bool then auraStop("_tcoFloorAura", "_tcoFloorAura_gen") return end
	getgenv()._tcoFloorAura = true
	local gen = auraBump("_tcoFloorAura_gen")
	task.spawn(function()
		while getgenv()._tcoFloorAura and getgenv()._tcoFloorAura_gen == gen do
			pcall(function()
				local origin = getAuraOrigin()
				if not origin then return end
				local base = origin + Vector3.new(0, -4, 0)
				for x = -2, 2 do
					for z = -2, 2 do
						fireBuildAt(base + Vector3.new(x * 4, 0, z * 4), "normal")
					end
				end
			end)
			task.wait(0.2)
		end
	end)
end, false)
lib.maketoggle("Build Trail", grieftab, function(bool)
	if not bool then auraStop("_tcoCageAura", "_tcoCageAura_gen") return end
	getgenv()._tcoCageAura = true
	local gen = auraBump("_tcoCageAura_gen")
	task.spawn(function()
		while getgenv()._tcoCageAura and getgenv()._tcoCageAura_gen == gen do
			pcall(function()
				local origin = getAuraOrigin()
				if not origin then return end
				local p = origin
				local m = 4
				local offs = {
					Vector3.new(m,0,0), Vector3.new(-m,0,0), Vector3.new(0,0,m), Vector3.new(0,0,-m),
					Vector3.new(m,m,0), Vector3.new(-m,m,0), Vector3.new(0,m,m), Vector3.new(0,m,-m),
					Vector3.new(0,-m,0), Vector3.new(0,2*m,0)
				}
				for _, o in ipairs(offs) do
					fireBuildAt(p + o, "normal")
				end
			end)
			task.wait(0.15)
		end
	end)
end, false)
lib.makelabel("--- Disable Bkit ---", grieftab)
getgenv()._tcoDisableBkit = getgenv()._tcoDisableBkit or {}
local function bkitPlayerList()
	return playerDropdownList(false)
end
lib.maketoggle("Use Display Names (bkit list)", grieftab, function(bool)
	getgenv()._tcoUseDisplayName = bool
	pcall(function() lib.updatedropdown(bkitDrop, bkitPlayerList()) end)
end, getgenv()._tcoUseDisplayName and true or false)
local bkitDrop = lib.makedropdown("Disable bkit target", grieftab, bkitPlayerList(), function(sel)
	local pl = resolvePlayerFromOpt(sel)
	local name = pl and pl.Name or sel
	getgenv()._tcoDisableBkitSel = name
	getgenv()._tcoBkitSelected = name
end)
lib.makebutton("Refresh disable-bkit list", grieftab, function()
	local list = bkitPlayerList()
	pcall(function() lib.updatedropdown(bkitDrop, list) end)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification",{Title="Bkit",Text=#list-1 .." players",Duration=2})
	end)
end)
getgenv()._tcoStartDisableBkit = function(targetName)
	if not targetName or targetName == "" or targetName == "(none)" then
		return false
	end
	getgenv()._tcoDisableBkitSel = targetName
	getgenv()._tcoDisableBkitOn = true
	getgenv()._tcoDisableBkitGen = (getgenv()._tcoDisableBkitGen or 0) + 1
	local gen = getgenv()._tcoDisableBkitGen
	local known = {}
	local deleteReadyAt = 0
	local function ensureDeleteReady(force)
		if not hasDeleteTool or not hasDeleteTool() then return false end
		if force or tick() - deleteReadyAt > 1 or not _cachedDeleteEv then
			pcall(function()
				if typeof(refreshDeleteTool) == "function" then refreshDeleteTool() end
				if typeof(refreshToolBypass) == "function" then refreshToolBypass("Delete") end
				if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
			end)
			deleteReadyAt = tick()
		end
		return _cachedDeleteEv ~= nil or typeof(fireToolRemote) == "function"
	end
	local function deleteOne(part)
		if not part or not part.Parent then return false end
		if typeof(fireToolRemote) == "function" then
			local hrp = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
			local pos = hrp and hrp.Position or part.Position
			local ok = fireToolRemote("Delete", part, pos)
			if ok then return true end
			if ensureDeleteReady(true) then
				ok = fireToolRemote("Delete", part, pos)
				if ok then return true end
			end
			return false
		end
		if not ensureDeleteReady(false) or typeof(fireDelete) ~= "function" then return false end
		return fireDelete(part) == true
	end
	local function ownerKey(part)
		local folder = part.Parent
		local bricks = workspace:FindFirstChild("Bricks")
		while folder and folder ~= workspace do
			if folder.Parent == bricks or (folder.Parent and folder.Parent.Name == "Bricks") then
				return folder.Name
			end
			folder = folder.Parent
		end
		return part.Parent and part.Parent.Name
	end
	local function matchesTarget(own, target)
		if not own then return false end
		local multi = getgenv()._tcoBkitTargets
		if multi and next(multi) then
			for name, on in pairs(multi) do
				if on and (own == name or own:lower() == tostring(name):lower()) then
					return true
				end
			end
		end
		if not target then return false end
		return own == target or own:lower() == target:lower()
	end
	local function findFolder(target)
		local bricks = workspace:FindFirstChild("Bricks")
		if not bricks then return nil end
		local folder = bricks:FindFirstChild(target)
		if folder then return folder end
		for _, f in pairs(bricks:GetChildren()) do
			if f.Name:lower() == target:lower() then return f end
		end
		return nil
	end
	pcall(function()
		local bricks = workspace:FindFirstChild("Bricks")
		if bricks then
			for _, p in pairs(bricks:GetDescendants()) do
				if p:IsA("BasePart") and matchesTarget(ownerKey(p), targetName) then
					known[p] = true
				end
			end
		end
	end)
	local conns = {}
	pcall(function()
		local bricks = workspace:FindFirstChild("Bricks")
		if not bricks then return end
		local function onNew(obj)
			if not getgenv()._tcoDisableBkitOn or getgenv()._tcoDisableBkitGen ~= gen then return end
			if obj:IsA("BasePart") and not known[obj] then
				if deleteOne(obj) then
					known[obj] = true
				end
			end
		end
		local function attachFolder(folder)
			if not folder then return end
			conns[#conns+1] = folder.ChildAdded:Connect(onNew)
			conns[#conns+1] = folder.DescendantAdded:Connect(onNew)
		end
		for _, folder in pairs(bricks:GetChildren()) do
			if matchesTarget(folder.Name, targetName) then
				attachFolder(folder)
			end
		end
		conns[#conns+1] = bricks.ChildAdded:Connect(function(ch)
			if not getgenv()._tcoDisableBkitOn or getgenv()._tcoDisableBkitGen ~= gen then return end
			if matchesTarget(ch.Name, targetName) then
				attachFolder(ch)
			end
		end)
	end)
	getgenv()._tcoDisableBkitConns = conns
	task.spawn(function()
		pcall(function()
			if typeof(refreshDeleteTool) == "function" then refreshDeleteTool() end
			if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
		end)
		while getgenv()._tcoDisableBkitOn and getgenv()._tcoDisableBkitGen == gen do
			pcall(function()
				local target = getgenv()._tcoDisableBkitSel
				if not target or target == "(none)" then return end
				local bricks = workspace:FindFirstChild("Bricks")
				if not bricks then return end
				if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
				local folder = findFolder(target)
				local iter = folder and folder:GetDescendants() or bricks:GetDescendants()
				local attempted = 0
				for _, p in pairs(iter) do
					if p:IsA("BasePart") and not known[p] then
						if folder or matchesTarget(ownerKey(p), target) then
							attempted = attempted + 1
							if deleteOne(p) then known[p] = true end
							if attempted >= 50 then break end
						end
					end
				end
			end)
			task.wait(0.08)
		end
		for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
	end)
	return true
end
getgenv()._tcoStopDisableBkit = function()
	getgenv()._tcoDisableBkitOn = false
	getgenv()._tcoDisableBkitGen = (getgenv()._tcoDisableBkitGen or 0) + 1
	local conns = getgenv()._tcoDisableBkitConns
	if conns then
		for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
	end
	getgenv()._tcoDisableBkitConns = nil
end
lib.makebutton("Select ALL for disable bkit", grieftab, function()
	getgenv()._tcoBkitTargets = {}
	for _, p in pairs(game.Players:GetPlayers()) do
		if p ~= localplr then
			getgenv()._tcoBkitTargets[p.Name] = true
		end
	end
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {Title="Bkit", Text="Selected everyone", Duration=2})
	end)
end)
lib.makebutton("Add selected to disable-bkit multi", grieftab, function()
	getgenv()._tcoBkitTargets = getgenv()._tcoBkitTargets or {}
	local n = getgenv()._tcoBkitSelected
	if n and n ~= "" and n ~= "(none)" then
		getgenv()._tcoBkitTargets[n] = true
	end
end)
lib.makebutton("Clear disable-bkit multi", grieftab, function()
	getgenv()._tcoBkitTargets = {}
end)
lib.maketoggle("Disable Bkit (delete NEW blocks only)", grieftab, function(bool)
	if not bool then
		if getgenv()._tcoStopDisableBkit then getgenv()._tcoStopDisableBkit() end
		return
	end
	local multi = getgenv()._tcoBkitTargets
	local sel = getgenv()._tcoDisableBkitSel
	if (not multi or not next(multi)) and (not sel or sel == "(none)") then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Bkit",Text="Select a target or everyone first",Duration=2})
		end)
		return
	end
	getgenv()._tcoStartDisableBkit(sel or next(multi))
	local msg = (multi and next(multi)) and "multi targets" or tostring(sel)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification",{Title="Bkit",Text="Blocking new blocks: "..msg,Duration=2})
	end)
end, false)
lib.makelabel("--- targeted grief ---", grieftab)
gdrop = lib.makedropdown("Select builder", grieftab, ownersList(), function(sel)
	if sel and sel ~= "(none)" then
		griefSelName = sel
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Selected "..sel,Duration=2})
		end)
	end
end)
lib.makebutton("Refresh builders", grieftab, function()
	local list = ownersList()
	pcall(function() lib.updatedropdown(gdrop, list) end)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text=#list.." builders",Duration=2})
	end)
end)
lib.makebutton("Highlight selected build", grieftab, function()
	if griefHL then
		clearGHL()
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Highlight OFF",Duration=1})
		end)
		return
	end
	if not griefSelName then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Select a builder first",Duration=2})
		end)
		return
	end
	local folder = findBuildFolder(griefSelName)
	if not folder then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Build not found",Duration=2})
		end)
		return
	end
	clearGHL()
	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(255, 0, 0)
	h.OutlineColor = Color3.fromRGB(255, 80, 80)
	h.FillTransparency = 0.6
	h.OutlineTransparency = 0
	h.Adornee = folder
	h.Parent = folder
	griefHL = h
end)
lib.makebutton("Add selected to targets", grieftab, function()
	if griefSelName and griefSelName ~= "(none)" then
		griefTargets[griefSelName] = true
		getgenv()._tcoBkitTargets = getgenv()._tcoBkitTargets or {}
		getgenv()._tcoBkitTargets[griefSelName] = true
		local c = 0
		for _ in pairs(griefTargets) do c = c + 1 end
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Targets: "..c.." (added "..griefSelName..")",Duration=2})
		end)
	end
end)
lib.makebutton("Select all builders", grieftab, function()
	local list = ownersList()
	local n = 0
	getgenv()._tcoBkitTargets = {}
	getgenv()._tcoDisableBkitSel = nil
	for _, name in ipairs(list) do
		if name and name ~= "(none)" then
			griefTargets[name] = true
			getgenv()._tcoBkitTargets[name] = true
			n = n + 1
		end
	end
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Selected all: "..n.." builders (including Disable Bkit)",Duration=2})
	end)
end)
lib.makebutton("Clear targets", grieftab, function()
	griefTargets = {}
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Targets cleared",Duration=2})
	end)
end)
lib.makebutton("Show target count", grieftab, function()
	local c = 0
	local names = {}
	for k, v in pairs(griefTargets) do
		if v then c = c + 1 names[#names+1] = k end
	end
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification",{
			Title="Targets ("..c..")",
			Text=(#names > 0 and table.concat(names, ", ") or "none"),
			Duration=4
		})
	end)
end)
function wipeBuildFolder(folder)
	if not folder then return 0 end
	local parts = {}
	for _, part in pairs(folder:GetChildren()) do
		if part:IsA("BasePart") then
			parts[#parts + 1] = part
		end
	end
	if #parts == 0 then return 0 end
	fireDeleteBurst(parts)
	return #parts
end
lib.makebutton("Wipe selected once", grieftab, function()
	if not griefSelName or griefSelName == "(none)" then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Select a builder first",Duration=2})
		end)
		return
	end
	task.spawn(function()
		_griefOnce = true
		pcall(function()
			if not hasDeleteTool() then
				game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Need Delete in inventory",Duration=2})
				return
			end
			refreshDeleteTool()
			refreshDeleteCache()
			local folder = findBuildFolder(griefSelName)
			if not folder then
				game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Build not found",Duration=2})
				return
			end
			local n = wipeBuildFolder(folder)
			task.wait()
			n = n + wipeBuildFolder(folder)
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Wiped ~"..tostring(n).." parts of "..griefSelName,Duration=2})
		end)
		_griefOnce = false
	end)
end)
lib.makebutton("Select nearest build", grieftab, function()
	pcall(function()
		local hrp = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local bricks = workspace:FindFirstChild("Bricks")
		if not bricks then return end
		local best, bestDist = nil, math.huge
		for _, f in pairs(bricks:GetChildren()) do
			if f.Name ~= localplr.Name and #f:GetChildren() > 0 then
				local center = getBuildCenter(f)
				if center then
					local d = (center - hrp.Position).Magnitude
					if d < bestDist then bestDist = d best = f end
				end
			end
		end
		if best then
			griefSelName = best.Name
			pcall(function() lib.updatedropdown(gdrop, ownersList()) end)
			game:GetService("StarterGui"):SetCore("SendNotification",{
				Title="Grief",
				Text="Selected nearest: "..best.Name.." ("..math.floor(bestDist).." studs)",
				Duration=2
			})
		else
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="No builds nearby",Duration=2})
		end
	end)
end)
lib.maketoggle("Start griefing targets", grieftab, function(bool)
	griefRunning = bool
	if not bool then return end
	local names = {}
	if griefSelName and griefSelName ~= "(none)" then
		names[griefSelName] = true
	end
	for n, on in pairs(griefTargets) do
		if on and n ~= "(none)" then names[n] = true end
	end
	local any = false
	for _ in pairs(names) do any = true break end
	if not any then
		griefRunning = false
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification",{Title="Grief",Text="Select a builder or add targets",Duration=2})
		end)
		return
	end
	pcall(refreshDeleteTool)
	pcall(refreshDeleteCache)
	task.spawn(function()
		local lastRefresh = tick()
		local nameList = {}
		for n, _ in pairs(names) do
			nameList[#nameList + 1] = n
		end
		table.sort(nameList)
		local idx = 1
		while griefRunning do
			pcall(function()
				if not hasDeleteTool() then return end
				if tick() - lastRefresh > 10 then
					lastRefresh = tick()
					refreshDeleteTool()
					refreshDeleteCache()
				end
				if #nameList == 0 then return end
				local name = nameList[((idx - 1) % #nameList) + 1]
				idx = idx + 1
				local folder = findBuildFolder(name)
				if folder then
					wipeBuildFolder(folder)
				end
			end)
			task.wait()
		end
	end)
end, false)
lib.makebutton("Refresh Delete bypass now", grieftab, function()
	local ok = refreshDeleteTool() or refreshDeleteToolEquip()
	pcall(refreshDeleteCache)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Delete Bypass",
			Text = ok and "Refreshed" or "Delete tool not found",
			Duration = 2
		})
	end)
end)
lib.makebutton("Fix Bkit (tools)", grieftab, function()
	local ok = pcall(fixBkit)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Bkit",
			Text = ok and "Tools reset - equip Build again" or "Fix failed",
			Duration = 3
		})
	end)
end)
sblock = nil
spmsb = false
side = Enum.NormalId.Top
sides = {"Right","Top","Back","Left","Bottom","Front"}
blocktxt2 = lib.makelabel("No Block Selected",buildtab)
ssbox = Instance.new("SurfaceGui")
ssbox.Parent = game.CoreGui
ssbox.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
ssboxframe = Instance.new("Frame")
ssboxframe.BackgroundTransparency = 1
ssboxframe.Size = UDim2.new(1,0,1,0)
ssboxframe.Parent = ssbox
uistroke = Instance.new("UIStroke")
uistroke.LineJoinMode = Enum.LineJoinMode.Miter
uistroke.Color = Color3.fromRGB(13,105,172)
uistroke.Thickness = -1
uistroke.Parent = ssboxframe
oss = false
ss = true
lib.makebutton("Stop Building",bsaltab,function()
	stopped = true
end)
lib.makebutton("Skip Block",bsaltab,function()
	skipblock = true
end)
lib.makelabel("saving builds",bsaltab)
starterui = game:GetService("StarterGui")
savebuildname = "Untitled"
savebuildnames = {}
textbox = nil
textbox = lib.maketextbox("Set Build Name",bsaltab,function(txt)
	txt = validate(txt)
	savebuildname = txt
	textbox.Text = ""
	textbox.PlaceholderText = "Successfully Named Build"
	wait(1)
	textbox.PlaceholderText = "Set Build Name"
end)
selectedbuild = nil
builds = {}
builddropdown = nil
function updatedropdown()
	local names = getfn()
	if type(names) ~= "table" then names = {} end
	table.sort(names, function(a, b)
		return tostring(a):lower() < tostring(b):lower()
	end)
	if #names == 0 then
		names = {"(no saves yet)"}
	end
	pcall(function()
		lib.updatedropdown(builddropdown, names)
	end)
	pcall(function()
		if typeof(writefile) == "function" and http then
			writefile("thechosenonenames.txt", http:JSONEncode(savebuildnames or {}))
		end
	end)
end
files = listfilesfixed("")
s,e = pcall(function()
	if (not table.find(files,"TheChosenOneBuilds/") and not table.find(files,"TheChosenOneBuilds")) then
		if table.find(files,"thechosenonebuilds.txt") then
			starterui:SetCore("SendNotification",{Title="Transferring Builds",Text="Currently transferring all your builds to a new folder...",Duration=5})
			task.wait(1)
			builds = http:JSONDecode(readfile("thechosenonebuilds.txt"))
			makefolder("TheChosenOneBuilds")
			local i2 = 0
			for i,v in pairs(builds) do
				i = validate(i)
				local s,e = pcall(function()
					writefile("TheChosenOneBuilds/"..i..".json",http:JSONEncode(v))
				end)
				if not s then
					i2 += 1
					writefile("TheChosenOneBuilds/CheckFile_Named_'TCO"..tostring(i2).."'.json",http:JSONEncode(v))
					writefile("'TCO"..tostring(i2).."'.txt","If you came here from the CheckFile file, your build name had an error ("..i..") DO NOT change the file name to that name, it's best just to rename the file to something else.")
				end
				task.wait()
			end
			starterui:SetCore("SendNotification",{Title="Done",Text="Builds are done transferring! If names are changed, we can't name files with a specific symbol in the name (ex: question mark (?))",Duration=20})
		else
			makefolder("TheChosenOneBuilds")
		end
	end
end)
if not s then print(e) end
s,e = pcall(function()
	savebuildnames = http:JSONDecode(readfile("thechosenonenames.txt"))
end)
if savebuildnames == nil then
	savebuildnames = {}
end
function createpartpos(pos,col)
	if typeof(pos) == "CFrame" then
		pos = pos.Position
	end
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	p.CanQuery = false
	p.Color = col
	p.Transparency = .5
	p.Size = Vector3.new(3,3,3)
	p.CFrame = CFrame.new(pos)
	p.Parent = workspace
end
function createpartrepl(pos,bsize,col,mat,transp,anch,collide,sprays)
	if typeof(pos) == "Vector3" then
		pos = CFrame.new(pos)
	end
	local p = Instance.new("Part")
	oldprt = p
	p.Anchored = (anch ~= nil) and anch or true
	p.CanCollide = (collide ~= nil) and collide or false
	p.CastShadow = false
	p.CanQuery = false
	p.Color = col
	p.Transparency = transp or .5
	p.Material = mat
	if bsize ~= nil then
		pos = CFrame.new((pos.X + (bsize.X/2))-.5,(pos.Y + (bsize.Y/2))-.5,(pos.Z + (bsize.Z/2))-.5) * pos.Rotation
	end
	p.Size = bsize or Vector3.new(mult,mult,mult)
	p.CFrame = pos
	if sprays then
		for i,v in pairs(sprays) do
			local face = Enum.NormalId[v[1]]
			local image = v[2]
			local txt = v[3]
			local surfaceui = Instance.new("SurfaceGui")
			surfaceui.Face = face
			surfaceui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			surfaceui.PixelsPerStud = 50
			local out,count = string.gsub(txt,"#","l")
			if count == string.len(txt) then
				local img = Instance.new("ImageLabel")
				img.Image = image
				img.BackgroundTransparency = 1
				img.Size = UDim2.new(1,0,1,0)
				img.Parent = surfaceui
			else
				local textlabel = Instance.new("TextLabel")
				textlabel.Text = txt
				textlabel.BackgroundTransparency = 1
				textlabel.TextScaled = true
				textlabel.TextColor3 = Color3.fromRGB(255,255,255)
				textlabel.Font = Enum.Font.FredokaOne
				textlabel.Size = UDim2.new(1,0,1,0)
				textlabel.Parent = surfaceui
			end
			surfaceui.Parent = p
		end
	end
	p.Parent = workspace
	return p
end
materials = {}
materials[Enum.Material.SmoothPlastic] = "smooth"
materials[Enum.Material.Plastic] = "plastic"
materials[Enum.Material.CeramicTiles] = "tiles"
materials[Enum.Material.Brick] = "bricks"
materials[Enum.Material.WoodPlanks] = "planks"
materials[Enum.Material.Ice] = "ice"
materials[Enum.Material.Grass] = "grass"
materials[Enum.Material.Sand] = "sand"
materials[Enum.Material.Snow] = "snow"
materials[Enum.Material.Glass] = "glass"
materials[Enum.Material.Wood] = "wood"
materials[Enum.Material.Slate] = "stone"
materials[Enum.Material.Pebble] = "pebble"
materials[Enum.Material.Marble] = "marble"
materials[Enum.Material.Granite] = "granite"
materials[Enum.Material.DiamondPlate] = "steel"
materials[Enum.Material.Metal] = "metal"
materials[Enum.Material.Asphalt] = "asphalt"
materials[Enum.Material.Concrete] = "concrete"
materials[Enum.Material.Pavement] = "pavement"
materials[Enum.Material.Neon] = "neon"
swappedmaterials = {}
for i,v in pairs(materials) do
	swappedmaterials[v] = i
end
function tcoEnsureBuildFolder()
	pcall(function()
		if typeof(makefolder) == "function" then
			makefolder("TheChosenOneBuilds")
		end
	end)
end
function tcoCollectParts(root)
	local parts = {}
	if not root then return parts end
	for _, v in pairs(root:GetDescendants()) do
		if v:IsA("BasePart") then
			parts[#parts + 1] = v
		end
	end
	if #parts == 0 then
		for _, v in pairs(root:GetChildren()) do
			if v:IsA("BasePart") then
				parts[#parts + 1] = v
			end
		end
	end
	return parts
end
function tcoWriteBuildSave(builddata, label)
	tcoEnsureBuildFolder()
	if type(http) ~= "table" and typeof(http) ~= "Instance" then
		http = game:GetService("HttpService")
	end
	local savebuildname2 = tostring(savebuildname or "Untitled")
	savebuildname2 = savebuildname2:gsub("^%s+", ""):gsub("%s+$", "")
	savebuildname2 = savebuildname2:gsub("%.json$", "")
	if savebuildname2 == "" or savebuildname2 == "." then savebuildname2 = "Untitled" end
	local names = getfn()
	local used = {}
	if type(names) == "table" then for _, n in ipairs(names) do used[tostring(n)] = true end end
	if savebuildname2 == "Untitled" or used[savebuildname2] then
		savebuildnames = savebuildnames or {}
		local suffix = tonumber(savebuildnames[savebuildname2]) or 0
		local candidate
		repeat
			suffix = suffix + 1
			candidate = savebuildname2 .. tostring(suffix)
		until not used[candidate] and (typeof(isfile) ~= "function" or not isfile("TheChosenOneBuilds/"..candidate..".json"))
		savebuildnames[savebuildname2] = suffix
		savebuildname2 = candidate
	end
	local path = "TheChosenOneBuilds/" .. savebuildname2 .. ".json"
	local encoded
	local okEnc, encErr = pcall(function()
		encoded = http:JSONEncode(builddata)
	end)
	if not okEnc then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "JSON encode error: " .. tostring(encErr),
				Duration = 4
			})
		end)
		return false
	end
	if typeof(writefile) ~= "function" then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "Your executor has no writefile",
				Duration = 4
			})
		end)
		return false
	end
	local okW, wErr = pcall(function()
		writefile(path, encoded)
	end)
	if not okW then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = tostring(wErr),
				Duration = 4
			})
		end)
		return false
	end
	pcall(updatedropdown)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = label or "Build saved",
			Text = savebuildname2 .. " (" .. tostring(#builddata) .. " blocks)",
			Duration = 3
		})
	end)
	return true
end
function saveblock(bl)
	local blockdata = {}
	if bl:IsA("BasePart") then
		local pt = {bl.Position.X,bl.Position.Y,bl.Position.Z}
		local comps = {bl.CFrame:GetComponents()}
		if (bl.CFrame - bl.Position) ~= CFrame.new() then
			blockdata.p = {comps[1], comps[2], comps[3]}
			blockdata.r = {comps[4], comps[5], comps[6], comps[7], comps[8], comps[9], comps[10], comps[11], comps[12]}
		else
			blockdata.p = pt
		end
		blockdata.c = {math.round(bl.Color.R*255),math.round(bl.Color.G*255),math.round(bl.Color.B*255)}
		blockdata.a = bl.Anchored
		blockdata.cc = bl.CanCollide
		if bl.Size.X ~= mult or bl.Size.Y ~= mult or bl.Size.Z ~= mult then
			blockdata.p[1] = (blockdata.p[1] - (bl.Size.X/2))+.5
			blockdata.p[2] = (blockdata.p[2] - (bl.Size.Y/2))+.5
			blockdata.p[3] = (blockdata.p[3] - (bl.Size.Z/2))+.5
			blockdata.s = {bl.Size.X,bl.Size.Y,bl.Size.Z}
		else
		end
		blockdata.m = materials[bl.Material]
		blockdata.o = bl.Material.Name
		local isToxic = false
		pcall(function()
			if bl:GetAttribute("Toxic") or bl:GetAttribute("Toxify") then isToxic = true end
			if bl.Name and (string.find(string.lower(bl.Name), "toxic") or string.find(string.lower(bl.Name), "toxify")) then isToxic = true end
			if bl.Material == Enum.Material.Neon then
				local r,g,b = bl.Color.R, bl.Color.G, bl.Color.B
				if r < 0.08 and g < 0.08 and b < 0.08 then
					isToxic = true
				end
			end
			if toxifybrick and bl == toxifybrick then isToxic = true end
		end)
		blockdata.tx = isToxic and true or nil
		if isToxic then
			blockdata.m = "toxic"
		end
		blockdata.sp = {}
		blockdata.sign = nil
		blockdata.isSign = nil
		for i,v in pairs(bl:GetDescendants()) do
			if v.Name == "Spray" and (v:IsA("SurfaceGui") or v.ClassName == "SurfaceGui") then
				local img, txt = "", ""
				pcall(function()
					local imageNode = v:FindFirstChild("Image") or v:FindFirstChildWhichIsA("ImageLabel", true)
					local textNode = v:FindFirstChild("Label") or v:FindFirstChildWhichIsA("TextLabel", true) or v:FindFirstChildWhichIsA("TextBox", true)
					if imageNode and imageNode:IsA("ImageLabel") then img = imageNode.Image end
					if textNode then txt = textNode.Text end
				end)
				local face = "Front"
				pcall(function() face = v.Face.Name end)
				table.insert(blockdata.sp, {face, img, string.gsub(tostring(txt), '"', "'")})
			end
		end
		for _, v in pairs(bl:GetChildren()) do
			if v:IsA("SurfaceGui") and v.Name ~= "Spray" then
				local lbl = v:FindFirstChildWhichIsA("TextLabel", true) or v:FindFirstChildWhichIsA("TextBox", true)
				if lbl and tostring(lbl.Text) ~= "" then
					blockdata.sign = { face = v.Face.Name, text = tostring(lbl.Text) }
					blockdata.isSign = true
					blockdata.m = "sign"
					break
				end
			end
		end
		if not blockdata.sign then
			local nameL = string.lower(tostring(bl.Name or ""))
			if string.find(nameL, "sign", 1, true) then
				local t, face = "", "Front"
				for _, d in pairs(bl:GetDescendants()) do
					if d:IsA("TextLabel") or d:IsA("TextBox") then
						if tostring(d.Text) ~= "" then t = tostring(d.Text) end
					end
					if d:IsA("SurfaceGui") then
						pcall(function() face = d.Face.Name end)
					end
				end
				blockdata.sign = { face = face, text = t }
				blockdata.isSign = true
				blockdata.m = "sign"
			end
		end
		pcall(function()
			if bl:GetAttribute("IsSign") or bl:GetAttribute("Sign") then
				blockdata.isSign = true
				blockdata.m = "sign"
				if not blockdata.sign then
					blockdata.sign = { face = "Front", text = tostring(bl:GetAttribute("Text") or "") }
				end
			end
		end)
	end
	return blockdata
end
lib.makebutton("Save Build",bsaltab,function()
	local folder = workspace:FindFirstChild("Bricks") and workspace.Bricks:FindFirstChild(localplr.Name)
	if not folder then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "No builds folder for you in workspace.Bricks",
				Duration = 3
			})
		end)
		return
	end
	local builddata = {}
	for _, v in pairs(tcoCollectParts(folder)) do
		table.insert(builddata, saveblock(v))
	end
	if #builddata == 0 then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "No blocks found to save",
				Duration = 3
			})
		end)
		return
	end
	tcoWriteBuildSave(builddata, "Build saved")
end)
movetool = nil
rotatetool = nil
movepreview = {}
moveorigin = Vector3.new(0,0,0)
movepos = Vector3.new(0,0,0)
moverotY = 0
uselastmoveonload = false
function clearmovepreview()
	for i,v in pairs(movepreview) do
		if v and v.Parent then v:Destroy() end
	end
	movepreview = {}
end
function getbuildorigin(build)
	local minx,miny,minz = math.huge,math.huge,math.huge
	local found = false
	for _,v in pairs(build) do
		if not (v.s or v.size) then
			local posses = v.p or v.pos
			if posses then
				found = true
				if posses[1] < minx then minx = posses[1] end
				if posses[2] < miny then miny = posses[2] end
				if posses[3] < minz then minz = posses[3] end
			end
		end
	end
	if not found then
		minx,miny,minz = math.huge,math.huge,math.huge
		for _,v in pairs(build) do
			local posses = v.p or v.pos
			if posses then
				if posses[1] < minx then minx = posses[1] end
				if posses[2] < miny then miny = posses[2] end
				if posses[3] < minz then minz = posses[3] end
			end
		end
	end
	if minx == math.huge then return Vector3.new(0,0,0) end
	return Vector3.new(minx,miny,minz)
end
function rotatevecY(vec, deg)
	local r = math.rad(deg)
	local c,s = math.cos(r), math.sin(r)
	return Vector3.new(vec.X * c - vec.Z * s, vec.Y, vec.X * s + vec.Z * c)
end
function rotatesizeY(sz, deg)
	if not sz then return nil end
	if (deg % 180) == 90 then
		return Vector3.new(sz.Z, sz.Y, sz.X)
	end
	return sz
end
function tcoValidBuildRecord(v)
	if type(v) ~= "table" then return false end
	local p = v.p or v.pos
	if type(p) ~= "table" or tonumber(p[1]) == nil or tonumber(p[2]) == nil or tonumber(p[3]) == nil then return false end
	local c = v.c or v.color
	if type(c) ~= "table" or tonumber(c[1]) == nil or tonumber(c[2]) == nil or tonumber(c[3]) == nil then return false end
	return true
end
function tcoValidBuildData(data)
	if type(data) ~= "table" then return false end
	for _, v in pairs(data) do if not tcoValidBuildRecord(v) then return false end end
	return #data > 0
end
function tcoSavedPosition(v)
	local p = v.p or v.pos
	return Vector3.new(tonumber(p[1]) or 0, tonumber(p[2]) or 0, tonumber(p[3]) or 0)
end
function placeoneblock(v, pos, rotY)
	rotY = rotY or 0
	if v.sign or v.isSign or v.m == "sign" or v.mat == "sign" then
		pcall(function()
			local txt = ""
			if type(v.sign) == "table" then
				txt = tostring(v.sign.text or "")
			elseif v.sign then
				txt = tostring(v.sign)
			end
			pcall(function()
				local pg = localplr:FindFirstChild("PlayerGui")
				if pg and pg:FindFirstChild("Sign") then
					local box = pg.Sign:FindFirstChildWhichIsA("TextBox", true)
					if box then box.Text = txt end
				end
			end)
			if typeof(fireSignAt) == "function" then
				fireSignAt(typeof(pos) == "Vector3" and pos or pos.Position)
			elseif findToolAny and findToolAny("Sign") then
				fireToolRemote("Sign", workspace.Terrain, Enum.NormalId.Top, typeof(pos) == "Vector3" and pos or pos.Position, "normal")
			end
		end)
		return
	end
	local matName = v.m or v.mat
	if v.tx or matName == "toxic" then
		matName = "toxic"
	end
	local args = {}
	args[1] = pos
	args[2] = matName
	local rawColor = v.c or v.color or {0,0,0}
	args[3] = Color3.fromRGB(math.clamp(tonumber(rawColor[1]) or 0,0,255), math.clamp(tonumber(rawColor[2]) or 0,0,255), math.clamp(tonumber(rawColor[3]) or 0,0,255))
	if v.s or v.size then
		args[5] = Vector3.new(table.unpack(v.s or v.size))
	end
	if args[5] and (rotY % 180) == 90 then
		args[5] = rotatesizeY(args[5], rotY)
	end
	local matEnum = swappedmaterials[matName] or Enum.Material.Plastic
	if matName == "toxic" then
		matEnum = Enum.Material.Neon
	end
	createpartrepl(args[1], args[5], args[3], matEnum)
	args[7] = v.o or v.origmat or (matName == "toxic" and "Neon") or nil
	args[8] = v.sp or v.sprayed
	args[9] = v.a or v.anchored
	args[10] = v.cc or v.collide
	if matName == "toxic" then
		buildingtoxify = true
		buildblock(args[1], "toxic", args[3], nil, args[5], true, "Neon", args[8], args[9], args[10])
		buildingtoxify = false
	else
		buildblock(args[1], args[2], args[3], nil, args[5], true, args[7], args[8], args[9], args[10])
	end
end
function getblockpos(v, origin, target, rotY)
	local posses = v.p or v.pos
	local base = CFrame.new(posses[1],posses[2],posses[3]).Position
	local pos
	if rotY == 0 then
		pos = base + (target - origin)
	else
		pos = target + rotatevecY(base - origin, rotY)
	end
	if not (v.s or v.size) then
		pos = round(pos)
	end
	return pos
end
function refreshmovepreview()
	clearmovepreview()
	if not selectedbuild or not selectedbuild[2] then return end
	local build = selectedbuild[2]
	moveorigin = getbuildorigin(build)
	for _,v in pairs(build) do
		local posses = v.p or v.pos
		if not posses then continue end
		local pos = getblockpos(v, moveorigin, movepos, moverotY)
		local bsize = nil
		if v.s or v.size then
			bsize = rotatesizeY(Vector3.new(table.unpack(v.s or v.size)), moverotY)
		end
		local col = Color3.fromRGB(table.unpack(v.c or v.color or {192,192,192}))
		local mat = swappedmaterials[v.m or v.mat] or Enum.Material.Plastic
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CastShadow = false
		p.CanQuery = false
		p.Color = col
		p.Transparency = 0.5
		p.Material = mat
		p.Size = bsize or Vector3.new(mult,mult,mult)
		if bsize then
			p.CFrame = CFrame.new((pos.X + (bsize.X/2))-0.5,(pos.Y + (bsize.Y/2))-0.5,(pos.Z + (bsize.Z/2))-0.5)
		else
			p.CFrame = CFrame.new(pos)
		end
		p.Parent = workspace
		table.insert(movepreview, p)
	end
	local marker = Instance.new("Part")
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(1.5,1.5,1.5)
	marker.Color = Color3.fromRGB(0,255,100)
	marker.Material = Enum.Material.Neon
	marker.Anchored = true
	marker.CanCollide = false
	marker.CastShadow = false
	marker.CanQuery = false
	marker.Transparency = 0.2
	marker.CFrame = CFrame.new(movepos)
	marker.Parent = workspace
	table.insert(movepreview, marker)
end
function confirmplacebuild()
	if not selectedbuild or not selectedbuild[2] then
		starterui:SetCore("SendNotification",{Title="Move Build",Text="Select a saved build first!",Duration=3})
		return
	end
	if #movepreview == 0 then
		starterui:SetCore("SendNotification",{Title="Move Build",Text="Use Move tool and click to set a position first!",Duration=4})
		return
	end
	local build = selectedbuild[2]
	local origin = getbuildorigin(build)
	stopped = false
	if oldprt then oldprt:Destroy() oldprt = nil end
	clearmovepreview()
	local raw = movepos - origin
	local delta = Vector3.new(
		math.round(raw.X / mult) * mult,
		math.round(raw.Y / mult) * mult,
		math.round(raw.Z / mult) * mult
	)
	for i,v in pairs(build) do
		if stopped == true then break end
		local posses = (v.p or v.pos)
		local base = CFrame.new(posses[1],posses[2],posses[3]).Position
		local pos
		if moverotY == 0 then
			pos = base + delta
		else
			pos = movepos + rotatevecY(base - origin, moverotY)
		end
		local bsize = nil
		if v.s or v.size then
			bsize = Vector3.new(table.unpack(v.s or v.size))
			if (moverotY % 180) == 90 then
				bsize = rotatesizeY(bsize, moverotY)
			end
		else
			pos = round(pos)
		end
		if oldprt then oldprt:Destroy() oldprt = nil end
		buildblock(pos, v.m or v.mat, Color3.fromRGB(table.unpack(v.c or v.color)), nil, bsize, true, v.o or v.origmat, v.sp or v.sprayed, v.a or v.anchored, v.cc or v.collide)
	end
	stopped = false
	starterui:SetCore("SendNotification",{Title="Move Build",Text="Finished placing build!",Duration=3})
end
function permanentsavebuild()
	if not selectedbuild or not selectedbuild[2] then
		starterui:SetCore("SendNotification",{Title="Permanent Save",Text="Select a saved build first!",Duration=3})
		return
	end
	if #movepreview == 0 and movepos == Vector3.new(0,0,0) then
		starterui:SetCore("SendNotification",{Title="Permanent Save",Text="Move the preview first!",Duration=4})
		return
	end
	local build = selectedbuild[2]
	local origin = getbuildorigin(build)
	local newbuild = {}
	for i,v in pairs(build) do
		local nv = {}
		for k,val in pairs(v) do nv[k] = val end
		local posses = v.p or v.pos
		if posses then
			local pos = getblockpos(v, origin, movepos, moverotY)
			nv.p = {pos.X, pos.Y, pos.Z}
			nv.pos = nil
			if v.s or v.size then
				local sz = rotatesizeY(Vector3.new(table.unpack(v.s or v.size)), moverotY)
				nv.s = {sz.X, sz.Y, sz.Z}
				nv.size = nil
			end
		end
		table.insert(newbuild, nv)
	end
	local fname = selectedbuild[1]
	local path = "TheChosenOneBuilds/"..fname
	if not string.find(fname, "%.json") then
		path = "TheChosenOneBuilds/"..fname..".json"
	end
	local ok, err = pcall(function()
		if typeof(writefile) ~= "function" then error("writefile unavailable") end
		writefile(path, http:JSONEncode(newbuild))
	end)
	if not ok then
		pcall(function() starterui:SetCore("SendNotification",{Title="Permanent Save failed",Text=tostring(err),Duration=4}) end)
		return
	end
	selectedbuild[2] = newbuild
	moverotY = 0
	moveorigin = getbuildorigin(newbuild)
	movepos = moveorigin
	refreshmovepreview()
	updatedropdown()
	starterui:SetCore("SendNotification",{Title="Permanent Save",Text="Save overwritten at new position/rotation!",Duration=5})
end
function maketool(name)
	local t = Instance.new("Tool")
	t.Name = name
	t.RequiresHandle = true
	t.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1,1,1)
	handle.Transparency = 1
	handle.CanCollide = false
	handle.Parent = t
	t.Parent = localplr.Backpack
	if localplr.Character then t.Parent = localplr.Character end
	return t
end
function ensurepreview()
	if not selectedbuild then return false end
	if #movepreview == 0 then
		if movepos == Vector3.new(0,0,0) and localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
			movepos = round(localplr.Character.HumanoidRootPart.Position)
		end
		refreshmovepreview()
	end
	return true
end
lib.makebutton("Move Selected Build (gives tool)",bsaltab,function()
	if not selectedbuild then
		starterui:SetCore("SendNotification",{Title="Move Build",Text="Select a saved build first!",Duration=4})
		return
	end
	if movetool and movetool.Parent then movetool:Destroy() end
	ensurepreview()
	movetool = maketool("Move Selected Build")
	movetool.Activated:Connect(function()
		local hit = mouse.Hit
		if hit then
			local p = hit.Position
			movepos = round(Vector3.new(p.X, (movepos.Y ~= 0 and movepos.Y) or p.Y, p.Z))
			if movepos.Y == 0 then movepos = round(p) end
			refreshmovepreview()
		end
	end)
	starterui:SetCore("SendNotification",{Title="Move Build",Text="Click = move preview. Does NOT build until Confirm.",Duration=5})
end)
lib.makebutton("↑ Height Up (+1 block)",bsaltab,function()
	if not ensurepreview() then return end
	movepos = movepos + Vector3.new(0, mult, 0)
	refreshmovepreview()
end)
lib.makebutton("↓ Height Down (-1 block)",bsaltab,function()
	if not ensurepreview() then return end
	movepos = movepos - Vector3.new(0, mult, 0)
	refreshmovepreview()
end)
lib.makebutton("Rotate Selected Build (gives tool)",bsaltab,function()
	if not selectedbuild then
		starterui:SetCore("SendNotification",{Title="Rotate",Text="Select a saved build first!",Duration=4})
		return
	end
	if rotatetool and rotatetool.Parent then rotatetool:Destroy() end
	ensurepreview()
	rotatetool = maketool("Rotate Selected Build")
	rotatetool.Activated:Connect(function()
		moverotY = (moverotY + 90) % 360
		refreshmovepreview()
		starterui:SetCore("SendNotification",{Title="Rotate",Text="Rotated to "..tostring(moverotY).."°",Duration=1})
	end)
	starterui:SetCore("SendNotification",{Title="Rotate",Text="Click to rotate 90° in place.",Duration=4})
end)
lib.makebutton("Confirm Place Build (builds preview)",bsaltab,function()
	confirmplacebuild()
end)
lib.makebutton("Permanent Save Here (overwrite file)",bsaltab,function()
	permanentsavebuild()
end)
lib.makebutton("Reset Rotation (0°)",bsaltab,function()
	moverotY = 0
	if selectedbuild then refreshmovepreview() end
end)
lib.makebutton("Clear Move Preview",bsaltab,function()
	clearmovepreview()
	moverotY = 0
end)
lib.makebutton("Move Preview To Me",bsaltab,function()
	if not selectedbuild then return end
	if localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
		movepos = round(localplr.Character.HumanoidRootPart.Position)
		refreshmovepreview()
	end
end)
lib.maketoggle("Use last move pos when Load Save",bsaltab,function(bool)
	uselastmoveonload = bool
end,false)
lib.makebutton("Save Server Builds",bsaltab,function()
	local bricks = workspace:FindFirstChild("Bricks")
	if not bricks then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "workspace.Bricks missing",
				Duration = 3
			})
		end)
		return
	end
	local builddata = {}
	for _, v in pairs(tcoCollectParts(bricks)) do
		table.insert(builddata, saveblock(v))
	end
	if #builddata == 0 then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "No blocks on server to save",
				Duration = 3
			})
		end)
		return
	end
	tcoWriteBuildSave(builddata, "Server builds saved")
end)
plrbuild = nil
plrbuilds = {ServerBuilds = workspace.Bricks}
plrnames = {"ServerBuilds"}
hpb = true
buildhighlight = Instance.new("Highlight")
buildhighlight.Parent = game.CoreGui
buildhighlight.FillColor = Color3.fromRGB(0,255,0)
buildhighlight.FillTransparency = .9
plrdropdown = lib.makedropdown("Select Player Builds",bsaltab,{},function(sel)
	plrbuild = plrbuilds[sel]
	buildhighlight.Adornee = plrbuild
end)
function upddd()
	table.sort(plrnames,function(a,b)
		return a:lower() < b:lower()
	end)
	lib.updatedropdown(plrdropdown,plrnames)
end
function dobricks(f,nud)
	plrbuilds[f.Name] = f
	if f:FindFirstChild("Brick") then
		table.insert(plrnames,f.Name)
	end
	table.insert(conn,f.ChildAdded:Connect(function(b)
		if not table.find(plrnames,f.Name) then
			table.insert(plrnames,f.Name)
			upddd()
		end
	end))
	table.insert(conn,f.ChildRemoved:Connect(function(b)
		if #f:GetChildren() <= 0 and table.find(plrnames,f.Name) then
			table.remove(plrnames,table.find(plrnames,f.Name))
			upddd()
		end
	end))
	if nud == nil then
		upddd()
	end
end
for i,v in pairs(workspace.Bricks:GetChildren()) do
	if v:IsA("Model") then
		dobricks(v,true)
	end
end
upddd()
onbrick = workspace.Bricks.ChildAdded:Connect(function(child)
	dobricks(child)
end)
lib.maketoggle("Highlight Player Build",bsaltab,function(bool)
	hpb = bool
	if not hpb then
		buildhighlight.FillTransparency = 1
		buildhighlight.OutlineTransparency = 1
	else
		buildhighlight.FillTransparency = .9
		buildhighlight.OutlineTransparency = 0
	end
end,true)
lib.makebutton("Save Player Build",bsaltab,function()
	if not plrbuild then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "Select a player build first",
				Duration = 3
			})
		end)
		return
	end
	local builddata = {}
	for _, v in pairs(tcoCollectParts(plrbuild)) do
		table.insert(builddata, saveblock(v))
	end
	if #builddata == 0 then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Save failed",
				Text = "That player has no blocks",
				Duration = 3
			})
		end)
		return
	end
	tcoWriteBuildSave(builddata, "Player build saved")
end)
lib.makelabel("loading/deleting builds",bsaltab)
builddropdown = lib.makedropdown("Saved Builds",bsaltab,{"(loading...)"},function(sel)
	if not sel or sel == "" or sel == "(no saves yet)" or sel == "(loading...)" then
		selectedbuild = nil
		return
	end
	local path = "TheChosenOneBuilds/" .. sel .. ".json"
	local ok, data = pcall(function()
		return http:JSONDecode(readfile(path))
	end)
	if ok and tcoValidBuildData(data) then
		selectedbuild = {sel, data}
	else
		selectedbuild = nil
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Saved Builds",
				Text = "Could not load: " .. tostring(sel),
				Duration = 3
			})
		end)
	end
end)
pcall(updatedropdown)
bindfunc = Instance.new("BindableFunction")
bindfunc.OnInvoke = function(prompt)
	if prompt == "Yes" and selectedbuild ~= nil then
		local path = "TheChosenOneBuilds/"..selectedbuild[1]..".json"
		local ok = typeof(delfile) == "function" and pcall(function() delfile(path) end)
		if ok then
			selectedbuild = nil
			updatedropdown()
		else
			pcall(function() starterui:SetCore("SendNotification",{Title="Delete failed",Text="The save file could not be deleted",Duration=3}) end)
		end
	end
end
lib.makebutton("Delete Save",bsaltab,function()
	starterui:SetCore("SendNotification",{Title="Delete Save?",Text="Are you sure you want to delete the save?",Duration=5,Callback=bindfunc,Button1="Yes",Button2="No"})
end)
function getbuild()
	if selectedbuild then
		return selectedbuild[2]
	end
	return nil
end
offset = Vector3.new(0,0,0)
lib.makebutton("Load Save",bsaltab,function()
	if selectedbuild ~= nil then
		pcall(function() if getgenv()._tcoOpenMiniGames then getgenv()._tcoOpenMiniGames() end end)
		local build = getbuild()
		if build then
			if oldprt then
				oldprt:Destroy()
			end
			local origin = getbuildorigin(build)
			local skipped = 0
			for i,v in pairs(selectedbuild[2]) do
				if stopped == true then
					break
				end
				if not tcoValidBuildRecord(v) then
					skipped = skipped + 1
					continue
				end
				local posses = (v.p or v.pos)
				local pos
				if uselastmoveonload and movepos ~= Vector3.new(0,0,0) then
					pos = getblockpos(v, origin, movepos, moverotY)
				else
					pos = CFrame.new(posses[1],posses[2],posses[3]).Position + offset
				end
				placeoneblock(v, pos, (uselastmoveonload and moverotY) or 0)
			end
			stopped = false
			if skipped > 0 then
				pcall(function() starterui:SetCore("SendNotification",{Title="Load Save",Text="Skipped "..tostring(skipped).." invalid block records",Duration=4}) end)
			end
		end
		pcall(function()
			if getgenv()._tcoCloseMiniGames then getgenv()._tcoCloseMiniGames() end
			local g = game.CoreGui:FindFirstChild("TCOMiniGames")
			if g then g:Destroy() end
			local g2 = localplr:FindFirstChild("PlayerGui") and localplr.PlayerGui:FindFirstChild("TCOMiniGames")
			if g2 then g2:Destroy() end
		end)
	end
end)
function optimizebuilds()
	if selectedbuild ~= nil and type(selectedbuild[2]) == "table" then
		for _,v in pairs(selectedbuild[2]) do
			local pos = v.p or v.pos
			if type(pos) == "table" and pos[1] and pos[2] and pos[3] then
				v.p = {tonumber(pos[1]),tonumber(pos[2]),tonumber(pos[3])}
				v.pos = nil
				v.m = v.m or v.mat or "plastic"; v.mat = nil
				v.s = v.s or v.size; v.size = nil
				v.c = v.c or v.color or {192,192,192}; v.color = nil
				v.o = v.o or v.origmat; v.origmat = nil
				v.sp = v.sp or v.sprayed; v.sprayed = nil
				v.a = v.a; if v.a == nil then v.a = v.anchored end; v.anchored = nil
				v.cc = v.cc; if v.cc == nil then v.cc = v.collide end; v.collide = nil
			end
		end
		local ok = pcall(function() writefile("TheChosenOneBuilds/"..selectedbuild[1]..".json",http:JSONEncode(selectedbuild[2])) end)
		if ok then updatedropdown() end
	end
end
lib.makelabel("extra settings/display build",bsaltab)
offsetpart = Instance.new("Part")
offsetpart.Shape = Enum.PartType.Ball
offsetpart.Anchored = true
offsetpart.CanCollide = false
offsetpart.CastShadow = false
offsetpart.CanQuery = false
offsetpart.Color = Color3.new(0,1,0)
offsetpart.Transparency = 1
offsetpart.Size = Vector3.new(3,3,3)
offsetpart.CFrame = CFrame.new(0,0,0)
offsetpart.Parent = workspace
lib.makebutton("Offset Build",bsaltab,function()
	offset = round(workspace.Spawn.Position + game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
	offsetpart.Position = offset
	offsetpart.Transparency = 0.5
end)
lib.makebutton("Reset Offset",bsaltab,function()
	offset = Vector3.new(0,0,0)
	offsetpart.Transparency = 1
end)
prttable = nil
lib.makebutton("Display whole build",bsaltab,function()
	if selectedbuild ~= nil then
		local build = getbuild()
		if build then
			if prttable then
				for i,v in pairs(prttable) do
					v:Destroy()
				end
			end
			local laggyparttable = {}
			for i,v in pairs(selectedbuild[2]) do
				local blocktype = nil
				local args = {}
				local posses = (v.pos or v.p)
				args[1] = CFrame.new(table.unpack(posses)) + offset
				args[2] = v.mat or v.m
				args[3] = Color3.fromRGB(table.unpack(v.color or v.c))
				if v.size or v.s then
					args[5] = Vector3.new(table.unpack(v.size or v.s))
				end
				local prt = createpartrepl(args[1],args[5],args[3],swappedmaterials[v.mat or v.m],0,v.anchored or v.a,v.collide or v.cc,v.sprayed or v.sp)
				table.insert(laggyparttable,prt)
			end
			prttable = laggyparttable
		end
	end
end)
lib.makebutton("Delete display build",bsaltab,function()
	if prttable then
		for i,v in pairs(prttable) do
			v:Destroy()
		end
	end
end)
resizewaitlabel = nil
lib.maketextbox("Wait before resizing",buildtab,function(txt)
	if tonumber(txt) then
		resizewait = tonumber(txt)
		lib.updatelabel("Resize Wait: "..tostring(resizewait),resizewaitlabel)
	end
end)
buildspeedlabel = nil
lib.makelabel("Build Speed (1.0 = current optimized, higher = faster, lower = safer)",buildtab)
lib.maketextbox("Build Speed (e.g. 1.0 / 1.5 / 2.0)",buildtab,function(txt)
	local n = tonumber(txt)
	if n and n > 0 then
		buildspeed = math.clamp(n, 0.25, 25)
		if buildspeedlabel then
			lib.updatelabel("Build Speed: "..tostring(buildspeed),buildspeedlabel)
		end
	end
end)
buildspeedlabel = lib.makelabel("Build Speed: 1.0",buildtab)
resizewaitlabel = lib.makelabel("Resize Wait: 0.7",buildtab)
updatedropdown()
lib.makebutton("Copy random gear",geartab,function()
	local ids = {"77443491","99119158","16688968","125013769","104699113","212641536","77443391","77443438","230212810"}
	local id = ids[math.random(1, #ids)]
	pcall(function() setclipboard(tostring(id)) end)
end)
lib.makelabel("Pressing 'say' will not make you say to everyone, you say it privately",geartab)
lib.makelabel("Doing the say/copy will say/copy the gear id, not the gear name",geartab)
currgears = {}
chatgear = false
gearcopybefore = "gear me "
lib.makebutton("Put gear id with 'gear me'",geartab,function()
	gearcopybefore = "gear me "
end)
lib.makebutton("Put gear id with 'gear all'",geartab,function()
	gearcopybefore = "gear all "
end)
lib.maketextbox("Put gear id with what you enter",geartab,function(txt)
	txt = string.gsub(txt,'"','\"')
	local len = string.len(txt)
	if len > 0 then
		if string.sub(txt,len,len) == " " then
			txt = string.sub(txt,1,len-1)
		end
		txt = txt.." "
	end
	gearcopybefore = txt
end)
chat = nil
s,e = pcall(function()
	chat = nil
end)
function say(text,channel)
	local msg = tostring(text or "")
	if msg == "" then return false end
	if string.sub(msg,1,1) ~= ";" then msg = ";"..msg end
	local sent = false
	pcall(function()
		local tcs = game:GetService("TextChatService")
		local channels = tcs:FindFirstChild("TextChannels")
		local ch = channels and (channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("RBXSystem"))
		if ch then ch:SendAsync(msg); sent = true end
	end)
	if not sent then pcall(function() game.Players:Chat(msg); sent = true end) end
	return sent
end
gsavenames = "tcogearsavenames.txt"
function savegears()
	local s,e = pcall(function()
		local tjson = game:GetService("HttpService"):JSONEncode(currgears)
		writefile(gsavenames,tjson)
	end)
end
function makegear(gearname,gearid,save,changename)
	deletegear(gearid)
	if changename == nil then
		changename = true
	end
	if changename then
	local foundcopy = false
	for i,v in pairs(currgears) do
		if v[3] == gearname then
			foundcopy = true
		end
	end
	if foundcopy then
		local n = 1
		local gearname2 = gearname
		repeat
			local foundcopy2 = false
			gearname2 = gearname.." "..tostring(n)
			for i,v in pairs(currgears) do
				if v[3] == gearname2 then
					foundcopy2 = true
				end
			end
			n = n + 1
			if not foundcopy2 then
				foundcopy = false
			end
			task.wait()
		until foundcopy == false
		gearname = gearname2
	end
	end
	local gbutton = lib.makebutton("Copy "..gearname,geartab,function()
		setclipboard(gearcopybefore..tostring(gearid))
	end)
	local gbutton2 = lib.makebutton("Say "..gearname,geartab,function()
		say(gearcopybefore..tostring(gearid),"system")
	end)
	if save then
		currgears[gearid] = {gbutton,gbutton2,gearname,gearid}
		savegears()
	end
end
function deletegear(gearid)
	if currgears[gearid] then
		local v = currgears[gearid]
		local s,e = pcall(function()
			v[1]:Destroy()
			v[2]:Destroy()
			currgears[gearid] = nil
			savegears()
		end)
	end
end
lib.makelabel("Preset Gears",geartab)
makegear("Pot Of Gold",24015579,false)
makegear("Merely's Web Slinger",169602010,false)
makegear("Dagger of Shattered Dimensions",71037101,false)
makegear("Portable Justice (Blacklisted)",82357101,false)
makegear("BB-8",1183007014,false)
makegear("BB-9E",1183007628,false)
makegear("Advanced Paint Bucket",18474459,false)
makegear("Rainbow Periastron",159229806,false)
makegear("Chartreuse Periastron",80661504,false)
makegear("Crimson Periastron",99119240,false)
makegear("Azure Periastron",69499437,false)
makegear("Noir Periastron",120307951,false)
makegear("Ivory Periastron",108158379,false)
makegear("Grimgold Periastron",73829193,false)
makegear("Amethyst Periastron",93136802,false)
makegear("Festive Periastron",139577901,false)
makegear("Joyful Periastron",233520257,false)
makegear("Fall Periastron",2544549379,false)
makegear("Fake Chartreuse Periastron",80597060,false)
makegear("Blizzard Wand",68354832,false)
makegear("Poseidon's Quake Trident",54130559,false)
makegear("Classic Bucket",25162389,false)
makegear("Vampire Vanquisher",94794847,false)
makegear("Exploding Heart",178076989,false)
makegear("Portable Beach (R6)",162857357,false)
makegear("Scroll of Sevenless",125013830,false)
makegear("Positronic Platform Producer",34898883,false)
makegear("Azure Dragon's Magic Slayer",268586231,false)
makegear("Azure Mines Pickaxe",583030187,false)
makegear("Body Swap Potion",78730532,false)
makegear("Crossbow of the Sea",236438668,false)
makegear("Gravity Coil",16688968,false)
makegear("Speed Coil",99119158,false)
makegear("Fusion Coil",77443491,false)
makegear("Bloxy Cola",104699113,false)
makegear("Linked Sword",125013769,false)
makegear("Darkheart",77443391,false)
makegear("Illumina",77443438,false)
makegear("Rocket Launcher",15806820,false)
makegear("Hyperlaser Gun",130113146,false)
makegear("Grapple Hook",73089285,false)
makegear("Subspace Tripmine",11999247,false)
makegear("Superball",16688961,false)
makegear("Slingshot",16630147,false)
makegear("Rainbow Carpet",225945419,false)
makegear("Regen Coil",16688975,false)
makegear("Timebomb",11999235,false)
makegear("Flashlight",1157524,false)
makegear("Ninja Star",77443450,false)
makegear("Healing Potion",78730244,false)
makegear("Speed Potion",78730268,false)
makegear("Jump Potion",78730280,false)
lib.makelabel("Custom Gears (creation)",geartab)
gnamesel = "Untitled"
lib.maketextbox("Enter gear name",geartab,function(txt)
	txt = string.gsub(txt,'"','\"')
	gnamesel = txt
end)
gidsel = "0"
lib.maketextbox("Enter gear id",geartab,function(txt)
	txt = string.gsub(txt,'"','\"')
	gidsel = txt
end)
lib.makebutton("Create Gear Buttons",geartab,function()
	if currgears[gidsel] then
		deletegear(gidsel)
	end
	makegear(gnamesel,gidsel,true)
end)
lib.maketextbox("Delete Gear Buttons (enter in id)",geartab,function(txt)
	deletegear(txt)
end)
lib.makelabel("Custom Gears",geartab)
s,e = pcall(function()
	currgears = game:GetService("HttpService"):JSONDecode(readfile(gsavenames))
	if currgears == nil then
		currgears = {}
	end
	for i,v in pairs(currgears) do
		makegear(v[3],i,true,false)
	end
	savegears()
end)
spamming = nil
lib.maketoggle("Spam Equipped Tools",tooltab,function(bool)
	if bool then
		spamming = true
	else
		spamming = nil
	end
end)
dee = false
lib.maketoggle("Don't equip enlighten when dropping/equipping tools",tooltab,function(bool)
	dee = bool
end)
lib.makebutton("Equip All Tools",tooltab,function()
	for i,v in pairs(localplr.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			if (dee and v.Name ~= "The Arkenstone") or not dee then
				v.Parent = localplr.Character
			end
		end
	end
end)
lib.makebutton("Drop All Tools",tooltab,function()
	for i,v in pairs(localplr.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			if (dee and v.Name ~= "The Arkenstone") or not dee then
				v.Parent = localplr.Character
			end
		end
	end
	task.wait()
	for i,v in pairs(localplr.Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = workspace
		end
	end
end)
suaeq = false
lib.maketoggle("Spam Equip and Unequip all tools",tooltab,function(bool)
	if bool then
		suaeq = true
	else
		suaeq = nil
	end
end)
dee2 = true
lib.maketoggle("Don't equip enlighten when dropping tools (For auto drop)",tooltab,function(bool)
	dee2 = bool
end,true)
pickuptools = true
autodroptools = true
currhum = nil
function dc(c)
	local f = c.ChildAdded:Connect(function(child)
		if not child then
			return
		end
		if child:IsA("Humanoid") then
			currhum = child
		elseif child:IsA("Tool") and not child:HasTag("DroppedByScript") then
			child:AddTag("DroppedByScript")
		end
	end)
	if c:FindFirstChild("Humanoid") then
		currhum = c.Humanoid
	end
	coroutine.wrap(function()
		repeat task.wait(10) until c == nil or c.Parent == nil
		f:Disconnect()
	end)()
end
if localplr.Character then
	dc(localplr.Character)
end
onchradded = localplr.CharacterAdded:Connect(function(c)
	dc(c)
end)
ot = false
autoperm = false
alwaysreset = false
alwaysresetall = false
coroutine.wrap(function()
	repeat
		task.wait(.1)
		if currhum ~= nil and currhum.Parent ~= nil then
			if pickuptools and currhum.Health > 0 and currhum:GetState() ~= Enum.HumanoidStateType.Dead then
				for i,v in pairs(workspace:GetChildren()) do
					if v:IsA("Tool") and v.Name ~= "Paint" and v:FindFirstChild("Handle") and v:HasTag("DroppedByScript") then
						currhum:EquipTool(v)
						if v.Name == "The Arkenstone" and autoperm then
							task.wait(.1)
						end
					end
				end
			end
			if autodroptools and currhum.Health <= 0 then
				for i,v in pairs(localplr.Backpack:GetChildren()) do
					if ((dee2 and v.Name ~= "The Arkenstone") or not dee2) then
						v.Parent = localplr.Character
					end
				end
				for i,v in pairs(localplr.Character:GetChildren()) do
					if v:IsA("Tool") and ((dee2 and v.Name ~= "The Arkenstone") or not dee2) then
						v.Parent = workspace
					end
				end
			end
		end
	until not on
end)()
lib.maketoggle("Auto Pickup Your Dropped Tools",tooltab,function(bool)
	pickuptools = bool
end,true)
lib.maketoggle("Auto Drop Tools On Death",tooltab,function(bool)
	autodroptools = bool
end,true)
commands = {}
heldtools = {}
hb = 0
onrender = game:GetService("RunService").Heartbeat:Connect(function()
	if spamming and on then
		for i,v in pairs(localplr.Character:GetChildren()) do
			if v:IsA("Tool") then
				v:Activate()
			end
		end
	end
	if suaeq and on then
		local tools = {}
		hb += 1
		for i,v in pairs(localplr.Backpack:GetChildren()) do
			if v:IsA("Tool") then
				table.insert(tools,v)
			end
		end
		for i,v in pairs(localplr.Character:GetChildren()) do
			if v:IsA("Tool") then
				table.insert(tools,v)
			end
		end
		for i,v in pairs(tools) do
			if hb%2 == 0 then
				v.Parent = localplr.Character
			else
				v.Parent = localplr.Backpack
			end
		end
	end
	if localplr.Character then
		for i,v in pairs(localplr.Character:GetChildren()) do
			if v:IsA("Tool") then
				if not heldtools[v.Name] then
					heldtools[v.Name] = 3
				end
				heldtools[v.Name] = heldtools[v.Name]-1
			end
		end
	end
	for i,v in pairs(heldtools) do
		if not localplr.Character or not localplr.Character:FindFirstChild(i) then
			heldtools[i] = nil
		end
	end
	local attemptreset = false
	if autoperm and localplr.Character and localplr.Character:FindFirstChild("The Arkenstone") then
		attemptreset = true
		if heldtools["The Arkenstone"] > 0 then
			say("reset me","system")
		end
	elseif autoperm and localplr.Backpack:FindFirstChild("The Arkenstone") and localplr:GetAttribute("Arken") ~= true and localplr.Character then
		localplr.Backpack["The Arkenstone"].Parent = localplr.Character
		attemptreset = true
		if heldtools["The Arkenstone"] > 0 then
			say("reset me","system")
		end
	end
	if alwaysreset then
		attemptreset = true
	   	say("reset me","system")
	end
	if alwaysresetall then
		say("reset all","system")
	end
	if not attemptreset then
		for i,v in pairs(commands) do
			if v == true then
				say(i,"system")
			end
		end
	end
	if novel == true and localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
		localplr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
	end
end)
griefWhitelist = {}
detectDelete = false
detectPaint = false
detectSpam = false
detectExploit = false
deleteMinBlocks = 5
deleteTimeWindow = 3
paintMinBlocks = 5
paintTimeWindow = 3
spamMinBlocks = 50
deleteTrack = {}
paintTrack = {}
griefViewing = nil
griefGui = nil
griefConns = {}
placeCounts = {}
deleteCounts = {}
paintCounts = {}
lastPaintCheck = {}
function isGriefWhitelisted(plr)
	if not plr then return false end
	return griefWhitelist[plr.UserId] == true
end
function stopGriefView()
	if griefGui then
		griefGui:Destroy()
		griefGui = nil
	end
	griefViewing = nil
	pcall(function()
		if localplr.Character and localplr.Character:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraSubject = localplr.Character.Humanoid
		end
	end)
end
function startGriefView(plr, reason)
	if not plr or isGriefWhitelisted(plr) then return end
	if griefViewing == plr and griefGui then return end
	stopGriefView()
	griefViewing = plr
	pcall(function()
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
		end
	end)
	local sg = Instance.new("ScreenGui")
	sg.Name = "GriefActionGui"
	sg.ResetOnSpawn = false
	pcall(function() sg.Parent = game.CoreGui end)
	if not sg.Parent then sg.Parent = localplr:WaitForChild("PlayerGui") end
	griefGui = sg
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 340)
	frame.Position = UDim2.new(1, -280, 0.5, -170)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	frame.BorderSizePixel = 0
	frame.Parent = sg
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -10, 0, 50)
	title.Position = UDim2.new(0, 5, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "GRIEF DETECTED\n"..(plr.DisplayName or plr.Name).."\n"..(reason or "")
	title.TextColor3 = Color3.fromRGB(255, 80, 80)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame
	local function makeBtn(text, y, color, cb)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -20, 0, 32)
		b.Position = UDim2.new(0, 10, 0, y)
		b.BackgroundColor3 = color
		b.Text = text
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.GothamBold
		b.TextScaled = true
		b.Parent = frame
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = b
		b.MouseButton1Click:Connect(cb)
		return b
	end
	makeBtn("FLING (5s)", 60, Color3.fromRGB(180, 40, 40), function()
		coroutine.wrap(function()
			local myChar = localplr.Character
			if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
			local hrp = myChar.HumanoidRootPart
			local hum = myChar:FindFirstChildOfClass("Humanoid")
			local oldCF = hrp.CFrame
			local bav = Instance.new("BodyAngularVelocity")
			bav.Name = "GriefFlingSpin"
			bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			bav.P = math.huge
			bav.AngularVelocity = Vector3.new(0, 9e4, 0)
			bav.Parent = hrp
			local bv = Instance.new("BodyVelocity")
			bv.Name = "GriefFlingVel"
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp
			if hum then hum.PlatformStand = true end
			local start = tick()
			while tick() - start < 5 do
				if not plr or not plr.Parent then break end
				local tchar = plr.Character
				local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
				if thrp then
					hrp.CFrame = thrp.CFrame
					bv.Velocity = Vector3.new(math.random(-12000,12000), 12000, math.random(-12000,12000))
					pcall(function()
						thrp.AssemblyLinearVelocity = Vector3.new(math.random(-15000,15000), 15000, math.random(-15000,15000))
						thrp.Velocity = thrp.AssemblyLinearVelocity
					end)
				end
				task.wait()
			end
			pcall(function() bav:Destroy() end)
			pcall(function() bv:Destroy() end)
			if hum then hum.PlatformStand = false end
			pcall(function()
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.Velocity = Vector3.zero
				hrp.CFrame = oldCF
			end)
		end)()
	end)
	makeBtn("ALARM (chat)", 98, Color3.fromRGB(180, 120, 30), function()
		local msg = (plr.DisplayName or plr.Name).." is griefing! ("..(reason or "grief")..")"
		coroutine.wrap(function()
			pcall(function()
				game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
			end)
		end)()
	end)
	makeBtn("freeze", 136, Color3.fromRGB(50, 90, 160), function()
		say("freeze "..plr.Name, "system")
	end)
	makeBtn("reset", 174, Color3.fromRGB(50, 90, 160), function()
		say("reset "..plr.Name, "system")
	end)
	makeBtn("clearinv", 212, Color3.fromRGB(50, 90, 160), function()
		say("clearinv "..plr.Name, "system")
	end)
	makeBtn("glitch", 250, Color3.fromRGB(50, 90, 160), function()
		say("glitch "..plr.Name, "system")
	end)
	makeBtn("STOP VIEWING", 292, Color3.fromRGB(60, 60, 70), function()
		stopGriefView()
	end)
	pcall(function()
		starterui:SetCore("SendNotification",{
			Title = "Grief Detected",
			Text = (plr.DisplayName or plr.Name).." - "..(reason or "grief"),
			Duration = 6
		})
	end)
end
function flagGriefer(plr, reason)
	if not plr or plr == localplr then return end
	if isGriefWhitelisted(plr) then return end
	startGriefView(plr, reason)
end
function onBrickAdded(folder, child)
	if not child:IsA("BasePart") then return end
	local owner = game.Players:FindFirstChild(folder.Name)
	if not owner or isGriefWhitelisted(owner) then return end
	local now = tick()
	placeCounts[owner.UserId] = placeCounts[owner.UserId] or {}
	table.insert(placeCounts[owner.UserId], now)
	local t = placeCounts[owner.UserId]
	local kept = {}
	for _,tm in ipairs(t) do
		if now - tm <= 5 then table.insert(kept, tm) end
	end
	placeCounts[owner.UserId] = kept
	if detectSpam and #kept >= spamMinBlocks then
		flagGriefer(owner, "block spam ("..#kept.." in 5s)")
		placeCounts[owner.UserId] = {}
	end
end
function onBrickRemoved(folder, child)
	if not child:IsA("BasePart") then return end
	if not (detectDelete or detectExploit) then return end
	local victimName = folder.Name
	local victimPlr = game.Players:FindFirstChild(victimName)
	if not victimPlr then return end
	local now = tick()
	local blockPos = nil
	pcall(function() blockPos = child.Position end)
	local best, bestScore = nil, -1
	for _, plr in ipairs(game.Players:GetPlayers()) do
		if plr ~= victimPlr and not isGriefWhitelisted(plr) then
			local score = 0
			local char = plr.Character
			local hasDelChar = char and char:FindFirstChild("Delete")
			local hasDelBag = plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Delete")
			if hasDelChar then
				score = score + 50
			elseif hasDelBag then
				score = score + 10
			else
				score = -1
			end
			if score >= 0 and char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp and blockPos then
					local dist = (hrp.Position - blockPos).Magnitude
					if dist < 25 then
						score = score + 40
					elseif dist < 60 then
						score = score + 15
					elseif dist > 120 and not hasDelChar then
						score = score - 20
					end
				end
			end
			if score > bestScore then
				bestScore = score
				best = plr
			end
		end
	end
	if not best or bestScore < 25 then return end
	if best.Name == victimName then return end
	deleteCounts[best.UserId] = deleteCounts[best.UserId] or {}
	table.insert(deleteCounts[best.UserId], now)
	local window = deleteTimeWindow or 3
	local kept = {}
	for _, tm in ipairs(deleteCounts[best.UserId]) do
		if now - tm <= window then table.insert(kept, tm) end
	end
	deleteCounts[best.UserId] = kept
	if detectDelete and #kept >= (deleteMinBlocks or 5) then
		flagGriefer(best, "deleted "..#kept.." of "..victimName.."'s blocks in "..tostring(window).."s")
		deleteCounts[best.UserId] = {}
	end
	if detectExploit and #kept >= math.max(15, (deleteMinBlocks or 5) * 3) then
		flagGriefer(best, "delete aura on "..victimName.." ("..#kept.."/"..tostring(window).."s)")
		deleteCounts[best.UserId] = {}
	end
end
function hookBrickFolder(folder)
	if not folder or griefConns[folder] then return end
	griefConns[folder] = {
		folder.ChildAdded:Connect(function(c) onBrickAdded(folder, c) end),
		folder.ChildRemoved:Connect(function(c) onBrickRemoved(folder, c) end),
	}
end
function hookAllBricks()
	for _,folder in ipairs(workspace.Bricks:GetChildren()) do
		if folder:IsA("Model") or folder:IsA("Folder") then
			hookBrickFolder(folder)
		end
	end
	if not griefConns["_bricks_added"] then
		griefConns["_bricks_added"] = workspace.Bricks.ChildAdded:Connect(function(folder)
			task.wait(0.1)
			hookBrickFolder(folder)
		end)
	end
end
function startPaintWatch()
	if griefConns["_paint"] then return end
	griefConns["_paint"] = true
	coroutine.wrap(function()
		while detectPaint do
			task.wait(0.35)
			pcall(function()
				local bricks = workspace:FindFirstChild("Bricks")
				if not bricks then return end
				for _, folder in ipairs(bricks:GetChildren()) do
					local owner = game.Players:FindFirstChild(folder.Name)
					if not owner then
					else
						for _, part in ipairs(folder:GetChildren()) do
							if part:IsA("BasePart") then
								local key = tostring(part)
								local prev = lastPaintCheck[key]
								local cur = {part.Color, part.Material}
								if prev and (prev[1] ~= cur[1] or prev[2] ~= cur[2]) then
									local best, bestScore = nil, -1
									local pos = part.Position
									for _, plr in ipairs(game.Players:GetPlayers()) do
										if plr ~= owner and not isGriefWhitelisted(plr) then
											local char = plr.Character
											local hasPaintChar = char and char:FindFirstChild("Paint")
											local hasPaintBag = plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Paint")
											local score = -1
											if hasPaintChar then score = 50
											elseif hasPaintBag then score = 10 end
											if score >= 0 and char then
												local hrp = char:FindFirstChild("HumanoidRootPart")
												if hrp then
													local dist = (hrp.Position - pos).Magnitude
													if dist < 25 then score = score + 40
													elseif dist < 60 then score = score + 15 end
												end
												if score > bestScore then
													bestScore = score
													best = plr
												end
											end
										end
									end
									if best and bestScore >= 25 then
										local now = tick()
										paintCounts[best.UserId] = paintCounts[best.UserId] or {}
										table.insert(paintCounts[best.UserId], now)
										local window = paintTimeWindow or 3
										local kept = {}
										for _, tm in ipairs(paintCounts[best.UserId]) do
											if now - tm <= window then table.insert(kept, tm) end
										end
										paintCounts[best.UserId] = kept
										if #kept >= (paintMinBlocks or 5) then
											flagGriefer(best, "painted "..#kept.." of "..owner.Name.."'s blocks in "..tostring(window).."s")
											paintCounts[best.UserId] = {}
										end
									end
								end
								lastPaintCheck[key] = cur
							end
						end
					end
				end
			end)
		end
		griefConns["_paint"] = nil
	end)()
end
function refreshDetections()
	if detectDelete or detectSpam or detectExploit or detectPaint then
		hookAllBricks()
	end
	if detectPaint then
		startPaintWatch()
	end
end
lib.makelabel("--- Join alerts ---", scripttab)
getgenv()._tcoCfg = getgenv()._tcoCfg or {}
lib.maketoggle("Say hi when someone joins", scripttab, function(bool)
	getgenv()._tcoCfg.joinHi = bool
	if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
end, getgenv()._tcoCfg.joinHi and true or false)
lib.maketextbox("Hi message ({name} = player)", scripttab, function(txt)
	if txt and txt ~= "" then
		getgenv()._tcoCfg.joinHiMsg = txt
		if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
	end
end)
lib.maketoggle("Fling new joiner (5 sec)", scripttab, function(bool)
	getgenv()._tcoCfg.joinFling = bool
	if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
end, getgenv()._tcoCfg.joinFling and true or false)
lib.maketoggle("Say command when someone joins", scripttab, function(bool)
	getgenv()._tcoCfg.joinCmd = bool
	if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
end, getgenv()._tcoCfg.joinCmd and true or false)
lib.maketextbox("Join command ({name})", scripttab, function(txt)
	if txt and txt ~= "" then
		getgenv()._tcoCfg.joinCmdMsg = txt
		if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
	end
end)
task.spawn(function()
	local function chatMsg(msg)
		msg = tostring(msg or "")
		pcall(function()
			local tcs = game:GetService("TextChatService")
			if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
				local ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
				if ch then ch:SendAsync(msg) return end
			end
		end)
		pcall(function()
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
		end)
	end
	local function onJoin(plr)
		if plr == localplr then return end
		task.wait(0.8)
		local cfg = getgenv()._tcoCfg or {}
		local name = plr.DisplayName or plr.Name
		if cfg.joinHi then
			local m = (cfg.joinHiMsg or "hi {name}"):gsub("{name}", name):gsub("{user}", plr.Name)
			chatMsg(m)
		end
		if cfg.joinCmd then
			local m = (cfg.joinCmdMsg or "freeze {name}"):gsub("{name}", name):gsub("{user}", plr.Name)
			chatMsg(m)
		end
		if cfg.joinFling then
			task.spawn(function()
				local my0 = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
				local startCF = my0 and my0.CFrame
				local t0 = tick()
				while tick() - t0 < 5 do
					pcall(function()
						local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
						local th = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
						if my and th then
							my.CFrame = th.CFrame
							th.AssemblyLinearVelocity = Vector3.new((math.random()-0.5)*3e4, 3e4, (math.random()-0.5)*3e4)
							th.Velocity = th.AssemblyLinearVelocity
						end
					end)
					task.wait()
				end
				pcall(function()
					local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
					if my and startCF then
						my.CFrame = startCF
						my.AssemblyLinearVelocity = Vector3.zero
					end
				end)
			end)
		end
	end
	for _, p in pairs(game.Players:GetPlayers()) do end
	game.Players.PlayerAdded:Connect(onJoin)
end)
lib.makelabel("Grief Detection - whitelist players so they are ignored",scripttab)
lib.makebutton("Detect delete blocks grief",scripttab,function()
	detectDelete = not detectDelete
	refreshDetections()
	starterui:SetCore("SendNotification",{Title="Delete Detection",Text=detectDelete and "ON" or "OFF",Duration=3})
end)
lib.maketextbox("Delete min blocks (default 5)",scripttab,function(txt)
	local n = tonumber(txt)
	if n and n >= 1 then
		deleteMinBlocks = math.floor(n)
		starterui:SetCore("SendNotification",{Title="Delete Min",Text=tostring(deleteMinBlocks).." blocks",Duration=2})
	end
end)
lib.maketextbox("Delete time window sec (default 3)",scripttab,function(txt)
	local n = tonumber(txt)
	if n and n > 0 then
		deleteTimeWindow = n
		starterui:SetCore("SendNotification",{Title="Delete Window",Text=tostring(deleteTimeWindow).."s",Duration=2})
	end
end)
lib.makebutton("Detect paint block grief",scripttab,function()
	detectPaint = not detectPaint
	refreshDetections()
	starterui:SetCore("SendNotification",{Title="Paint Detection",Text=detectPaint and "ON" or "OFF",Duration=3})
end)
lib.maketextbox("Paint min blocks (default 5)",scripttab,function(txt)
	local n = tonumber(txt)
	if n and n >= 1 then
		paintMinBlocks = math.floor(n)
		starterui:SetCore("SendNotification",{Title="Paint Min",Text=tostring(paintMinBlocks).." blocks",Duration=2})
	end
end)
lib.maketextbox("Paint time window sec (default 3)",scripttab,function(txt)
	local n = tonumber(txt)
	if n and n > 0 then
		paintTimeWindow = n
		starterui:SetCore("SendNotification",{Title="Paint Window",Text=tostring(paintTimeWindow).."s",Duration=2})
	end
end)
lib.makebutton("Detect block spam",scripttab,function()
	detectSpam = not detectSpam
	refreshDetections()
	starterui:SetCore("SendNotification",{Title="Spam Detection",Text=detectSpam and "ON" or "OFF",Duration=3})
end)
lib.maketextbox("Spam min blocks in 5s (default 50)",scripttab,function(txt)
	local n = tonumber(txt)
	if n and n >= 1 then
		spamMinBlocks = math.floor(n)
		starterui:SetCore("SendNotification",{Title="Spam Min",Text="Set to "..tostring(spamMinBlocks),Duration=3})
	end
end)
lib.makebutton("Detect exploit (delete aura)",scripttab,function()
	detectExploit = not detectExploit
	refreshDetections()
	starterui:SetCore("SendNotification",{Title="Exploit Detection",Text=detectExploit and "ON" or "OFF",Duration=3})
end)
lib.makebutton("Detect all",scripttab,function()
	detectDelete = true
	detectPaint = true
	detectSpam = true
	detectExploit = true
	refreshDetections()
	starterui:SetCore("SendNotification",{Title="Grief Detection",Text="ALL ON",Duration=3})
end)
lib.makebutton("Turn all detections OFF",scripttab,function()
	detectDelete = false
	detectPaint = false
	detectSpam = false
	detectExploit = false
	stopGriefView()
	starterui:SetCore("SendNotification",{Title="Grief Detection",Text="ALL OFF",Duration=3})
end)
lib.makelabel("Whitelist (name or display name)",scripttab)
lib.maketextbox("Whitelist player",scripttab,function(txt)
	if not txt or txt == "" then return end
	local found = nil
	for _,plr in ipairs(game.Players:GetPlayers()) do
		if plr.Name:lower() == txt:lower() or plr.DisplayName:lower() == txt:lower() then
			found = plr
			break
		end
	end
	if found then
		griefWhitelist[found.UserId] = true
		starterui:SetCore("SendNotification",{Title="Whitelist",Text="Whitelisted "..found.Name,Duration=3})
	else
		starterui:SetCore("SendNotification",{Title="Whitelist",Text="Player not found",Duration=3})
	end
end)
lib.maketextbox("Unwhitelist player",scripttab,function(txt)
	if not txt or txt == "" then return end
	local found = nil
	for _,plr in ipairs(game.Players:GetPlayers()) do
		if plr.Name:lower() == txt:lower() or plr.DisplayName:lower() == txt:lower() then
			found = plr
			break
		end
	end
	if found then
		griefWhitelist[found.UserId] = nil
		starterui:SetCore("SendNotification",{Title="Whitelist",Text="Removed "..found.Name,Duration=3})
	else
		starterui:SetCore("SendNotification",{Title="Whitelist",Text="Player not found in server",Duration=3})
	end
end)
lib.makebutton("Whitelist myself",scripttab,function()
	griefWhitelist[localplr.UserId] = true
	starterui:SetCore("SendNotification",{Title="Whitelist",Text="You are whitelisted",Duration=3})
end)
lib.makebutton("Unwhitelist myself",scripttab,function()
	griefWhitelist[localplr.UserId] = nil
	starterui:SetCore("SendNotification",{Title="Whitelist",Text="You are no longer whitelisted",Duration=3})
end)
lib.makebutton("Stop viewing (manual)",scripttab,function()
	stopGriefView()
end)
function clearclogs(amt)
	for i=1,amt do
		coroutine.wrap(function()
			say(";","system")
		end)()
	end
end
ccol = false
commands = {}
function loadAntiGui()
	local existing = game.CoreGui:FindFirstChild("TCOAntiGui")
		or (game.Players.LocalPlayer:FindFirstChild("PlayerGui")
			and game.Players.LocalPlayer.PlayerGui:FindFirstChild("TCOAntiGui"))
	if existing then existing:Destroy() end
	local miniOld = game.CoreGui:FindFirstChild("TCOAntiMini")
		or (game.Players.LocalPlayer:FindFirstChild("PlayerGui")
			and game.Players.LocalPlayer.PlayerGui:FindFirstChild("TCOAntiMini"))
	if miniOld then miniOld:Destroy() end
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local plr = Players.LocalPlayer
	local function notify(text)
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Anti",
				Text = tostring(text),
				Duration = 2
			})
		end)
	end
	local function sayCmd(msg)
		pcall(function()
			local tcs = game:GetService("TextChatService")
			if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
				local ch = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
				if ch then
					ch:SendAsync(msg)
					return
				end
			end
			local rs = game:GetService("ReplicatedStorage")
			local ev = rs:FindFirstChild("DefaultChatSystemChatEvents")
			if ev and ev:FindFirstChild("SayMessageRequest") then
				ev.SayMessageRequest:FireServer(msg, "All")
			end
		end)
		pcall(function()
			game:GetService("Players"):Chat(msg)
		end)
	end
	local function getChar()
		return plr.Character
	end
	local function getHRP()
		local c = getChar()
		return c and c:FindFirstChild("HumanoidRootPart")
	end
	local function getHum()
		local c = getChar()
		return c and c:FindFirstChildOfClass("Humanoid")
	end
	local gen = {}
	local function startLoop(key, interval, fn)
		gen[key] = (gen[key] or 0) + 1
		local myGen = gen[key]
		task.spawn(function()
			while gen[key] == myGen do
				pcall(fn)
				task.wait(interval)
			end
		end)
	end
	local function stopLoop(key)
		gen[key] = (gen[key] or 0) + 1
	end
	local states = {}
	local autoEnlightenConn = nil
	local enlightenLoopGen = 0
	local sg = Instance.new("ScreenGui")
	sg.Name = "TCOAntiGui"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() sg.Parent = game.CoreGui end)
	if not sg.Parent then sg.Parent = plr:WaitForChild("PlayerGui") end
	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = UDim2.new(0, 200, 0, 300)
	frame.Position = UDim2.new(0, 18, 0.5, -150)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.ClipsDescendants = true
	frame.Parent = sg
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 26)
	titleBar.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = frame
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -58, 1, 0)
	title.Position = UDim2.new(0, 8, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "anti"
	title.TextColor3 = Color3.fromRGB(190, 190, 195)
	title.Font = Enum.Font.SourceSans
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar
	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 24, 0, 22)
	minBtn.Position = UDim2.new(1, -52, 0, 2)
	minBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 54)
	minBtn.Text = "-"
	minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	minBtn.Font = Enum.Font.SourceSans
	minBtn.TextSize = 16
	minBtn.Parent = titleBar
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 3)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 24, 0, 22)
	closeBtn.Position = UDim2.new(1, -26, 0, 2)
	closeBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
	closeBtn.Text = "x"
	closeBtn.TextColor3 = Color3.fromRGB(220, 180, 180)
	closeBtn.Font = Enum.Font.SourceSans
	closeBtn.TextSize = 14
	closeBtn.Parent = titleBar
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)
	local topResize = Instance.new("TextButton")
	topResize.Size = UDim2.new(1, 0, 0, 5)
	topResize.Position = UDim2.new(0, 0, 0, 0)
	topResize.BackgroundTransparency = 1
	topResize.Text = ""
	topResize.ZIndex = 5
	topResize.Parent = frame
	local botResize = Instance.new("TextButton")
	botResize.Size = UDim2.new(1, 0, 0, 6)
	botResize.Position = UDim2.new(0, 0, 1, -6)
	botResize.BackgroundTransparency = 1
	botResize.Text = ""
	botResize.ZIndex = 5
	botResize.Parent = frame
	local resizing, resizeMode, resizeStart, resizeSize, resizePos
	local function beginResize(mode, input)
		resizing = true
		resizeMode = mode
		resizeStart = input.Position
		resizeSize = frame.AbsoluteSize
		resizePos = frame.AbsolutePosition
	end
	topResize.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			beginResize("top", input)
		end
	end)
	botResize.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			beginResize("bot", input)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not resizing then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local dy = input.Position.Y - resizeStart.Y
		if resizeMode == "bot" then
			local nh = math.clamp(resizeSize.Y + dy, 160, 560)
			frame.Size = UDim2.new(0, frame.AbsoluteSize.X, 0, nh)
		elseif resizeMode == "top" then
			local nh = math.clamp(resizeSize.Y - dy, 160, 560)
			local yOff = resizePos.Y + (resizeSize.Y - nh)
			frame.Size = UDim2.new(0, frame.AbsoluteSize.X, 0, nh)
			frame.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, yOff)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)
	closeBtn.MouseButton1Click:Connect(function()
		for k in pairs(gen) do stopLoop(k) end
		enlightenLoopGen = enlightenLoopGen + 1
		if autoEnlightenConn then pcall(function() autoEnlightenConn:Disconnect() end) end
		sg:Destroy()
		local mini = game.CoreGui:FindFirstChild("TCOAntiMini") or (plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("TCOAntiMini"))
		if mini then mini:Destroy() end
	end)
	local miniGui = Instance.new("ScreenGui")
	miniGui.Name = "TCOAntiMini"
	miniGui.ResetOnSpawn = false
	miniGui.Enabled = false
	pcall(function() miniGui.Parent = game.CoreGui end)
	if not miniGui.Parent then miniGui.Parent = plr:WaitForChild("PlayerGui") end
	local miniBtn = Instance.new("TextButton")
	miniBtn.Size = UDim2.new(0, 56, 0, 56)
	miniBtn.Position = UDim2.new(0, 20, 0.5, -28)
	miniBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	miniBtn.Text = "a"
	miniBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
	miniBtn.Font = Enum.Font.SourceSans
	miniBtn.TextSize = 18
	miniBtn.Parent = miniGui
	Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 6)
	minBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
		miniGui.Enabled = true
	end)
	miniBtn.MouseButton1Click:Connect(function()
		frame.Visible = true
		miniGui.Enabled = false
	end)
	local dragging, dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	local mDragging, mStart, mPos
	miniBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			mDragging = true
			mStart = input.Position
			mPos = miniBtn.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if mDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - mStart
			miniBtn.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + d.X, mPos.Y.Scale, mPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			mDragging = false
		end
	end)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -8, 1, -34)
	scroll.Position = UDim2.new(0, 4, 0, 28)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = frame
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 3)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll
	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
	end)
	local function addLabel(text)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -4, 0, 22)
		l.BackgroundTransparency = 1
		l.Text = text
		l.TextColor3 = Color3.fromRGB(150, 190, 255)
		l.Font = Enum.Font.GothamBold
		l.TextSize = 13
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Parent = scroll
	end
	local function addToggle(text, key, onEnable, onDisable)
		states[key] = false
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -4, 0, 28)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
		btn.Text = text .. "  [OFF]"
		btn.TextColor3 = Color3.fromRGB(220, 220, 230)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.Parent = scroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.MouseButton1Click:Connect(function()
			states[key] = not states[key]
			if states[key] then
				btn.Text = text .. "  [ON]"
				btn.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
				if onEnable then onEnable() end
			else
				btn.Text = text .. "  [OFF]"
				btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
				stopLoop(key)
				if onDisable then onDisable() end
			end
			notify(text .. (states[key] and " ON" or " OFF"))
		end)
		return btn
	end
	addLabel("── Protections ──")
	addToggle("Anti Toxify", "antiToxify", function()
		startLoop("antiToxify", 0.3, function()
			local char = getChar()
			if char then
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
						if v.Color == Color3.fromRGB(0, 0, 0) or v.Name:lower():find("toxic") then
							v:Destroy()
						end
					end
					local nl = v.Name:lower()
					if nl:find("toxic") or nl:find("toxify") then v:Destroy() end
				end
			end
			local hrp = getHRP()
			if hrp and workspace:FindFirstChild("Bricks") then
				for _, b in ipairs(workspace.Bricks:GetDescendants()) do
					if b:IsA("BasePart") and b.Material == Enum.Material.Neon and b.Color == Color3.fromRGB(0, 0, 0) then
						if (b.Position - hrp.Position).Magnitude < 18 then
							b:Destroy()
						end
					end
				end
			end
		end)
	end)
	addToggle("Anti Blind", "antiBlind", function()
		startLoop("antiBlind", 0.25, function()
			local lighting = game:GetService("Lighting")
			for _, v in ipairs(lighting:GetChildren()) do
				if v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") then
					local nl = v.Name:lower()
					if nl:find("blind") or nl:find("dark") or (v:IsA("ColorCorrectionEffect") and v.Brightness < -0.25) then
						v:Destroy()
					end
				end
			end
			local pg = plr:FindFirstChild("PlayerGui")
			if pg then
				for _, g in ipairs(pg:GetChildren()) do
					local nl = g.Name:lower()
					if nl:find("blind") or nl:find("blackout") or nl:find("darkness") then
						g:Destroy()
					end
				end
			end
		end)
	end)
	addToggle("Anti Myopic", "antiMyopic", function()
		startLoop("antiMyopic", 0.25, function()
			local lighting = game:GetService("Lighting")
			for _, v in ipairs(lighting:GetChildren()) do
				local nl = v.Name:lower()
				if nl:find("myopic") or nl:find("nearsight") or nl:find("blur") then
					v:Destroy()
				end
				if v:IsA("BlurEffect") then v:Destroy() end
				if v:IsA("DepthOfFieldEffect") then v:Destroy() end
			end
			local cam = workspace.CurrentCamera
			if cam then
				for _, v in ipairs(cam:GetChildren()) do
					if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") then
						v:Destroy()
					end
				end
			end
			local pg = plr:FindFirstChild("PlayerGui")
			if pg then
				for _, g in ipairs(pg:GetChildren()) do
					if g.Name:lower():find("myopic") then g:Destroy() end
				end
			end
		end)
	end)
	addToggle("Anti Glitch / Fling", "antiGlitch", function()
		local lastSafe = nil
		local lastY = nil
		startLoop("antiGlitch", 0.1, function()
			local hrp = getHRP()
			if not hrp then return end
			if hrp.Position.Y < -20 then
				return
			end
			local spd = hrp.AssemblyLinearVelocity.Magnitude
			local flingVel = spd > 250
			for _, v in ipairs(hrp:GetChildren()) do
				if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("LinearVelocity") or v:IsA("AngularVelocity") then
					if v.Name ~= "FlyBV" and v.Name ~= "FlyBG" and v.Name ~= "WF_AV" and v.Name ~= "WF_BV" then
						local kill = false
						pcall(function()
							if v:IsA("BodyAngularVelocity") and v.MaxTorque.Magnitude > 1e5 then kill = true end
							if v:IsA("BodyVelocity") and v.MaxForce.Magnitude > 1e5 and v.Name ~= "FlyBV" then kill = true end
							if v:IsA("BodyForce") then kill = true end
						end)
						if kill then pcall(function() v:Destroy() end) end
					end
				end
			end
			if flingVel then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
				if lastSafe then
					hrp.CFrame = lastSafe
				end
			else
				if spd < 120 then
					lastSafe = hrp.CFrame
				end
			end
		end)
	end)
	addToggle("Anti Freeze", "antiFreeze", function()
		local lastReset = 0
		startLoop("antiFreeze", 0.15, function()
			local hum = getHum()
			local hrp = getHRP()
			local char = getChar()
			if not hum or not hrp or not char then return end
			local isFlying = false
			if hrp:FindFirstChild("FlyBV") or hrp:FindFirstChild("FlyBG") then
				isFlying = true
			end
			if hrp:FindFirstChild("BodyVelocity") and hrp:FindFirstChild("BodyGyro") then
				local bv = hrp:FindFirstChild("BodyVelocity")
				if bv and bv.MaxForce.Magnitude > 10000 then
					isFlying = true
				end
			end
			if isFlying then return end
			local frozen = false
			if hum.WalkSpeed == 0 or hum.JumpPower == 0 then
				frozen = true
			end
			if hrp.Anchored then
				frozen = true
				pcall(function() hrp.Anchored = false end)
			end
			for _, v in ipairs(hrp:GetChildren()) do
				if v:IsA("BodyPosition") and v.Name ~= "FlyBV" and v.Name ~= "FlyBG" then
					frozen = true
					pcall(function() v:Destroy() end)
				end
			end
			if hum.PlatformStand and hum.WalkSpeed == 0 then
				frozen = true
			end
			if frozen and (tick() - lastReset) > 1.5 then
				lastReset = tick()
				pcall(function()
					hum.Health = 0
				end)
			end
		end)
	end)
	addToggle("Anti Jail", "antiJail", function()
		local noclipUntil = 0
		local lastTrigger = 0
		startLoop("antiJail", 0.1, function()
			local hrp = getHRP()
			local char = getChar()
			if not hrp or not char then return end
			local jailed = false
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide then
					local n = v.Name:lower()
					if n:find("jail") or n:find("cage") or n:find("prison") or n:find("cell") then
						if (v.Position - hrp.Position).Magnitude < 25 then
							jailed = true
							break
						end
					end
				end
			end
			if not jailed then
				local nearbyWalls = 0
				for _, v in ipairs(workspace:GetDescendants()) do
					if v:IsA("BasePart") and v.Anchored and v.CanCollide then
						if (v.Position - hrp.Position).Magnitude < 10 and v.Size.Magnitude > 4 then
							nearbyWalls = nearbyWalls + 1
						end
					end
				end
				if nearbyWalls >= 4 then
					jailed = true
				end
			end
			if jailed and (tick() - lastTrigger) > 4 then
				lastTrigger = tick()
				noclipUntil = tick() + 3
				notify("Jail detected - noclip 3s")
			end
			if tick() < noclipUntil then
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanCollide = false
					end
				end
			end
		end)
	end)
	addToggle("Anti Stun", "antiStun", function()
		startLoop("antiStun", 0.2, function()
			local hum = getHum()
			local hrp = getHRP()
			if not hum or not hrp then return end
			if hrp:FindFirstChild("FlyBV") or hrp:FindFirstChild("FlyBG") then return end
			if hrp:FindFirstChild("BodyVelocity") and hrp:FindFirstChild("BodyGyro") then
				local bv = hrp:FindFirstChild("BodyVelocity")
				if bv and bv.MaxForce.Magnitude > 10000 then return end
			end
			local state = hum:GetState()
			if state == Enum.HumanoidStateType.Physics
				or state == Enum.HumanoidStateType.Ragdoll
				or state == Enum.HumanoidStateType.FallingDown
				or state == Enum.HumanoidStateType.PlatformStanding then
				pcall(function()
					hum.PlatformStand = false
					hum:ChangeState(Enum.HumanoidStateType.GettingUp)
					task.wait()
					hum:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end
		end)
	end)
	addToggle("Anti Invis", "antiInvis", function()
		local lastReset = 0
		startLoop("antiInvis", 0.25, function()
			local char = getChar()
			local hum = getHum()
			if not char or not hum then return end
			local invis = false
			for _, v in ipairs(char:GetDescendants()) do
				if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
					if v.Transparency > 0.6 then invis = true break end
					local ok, ltm = pcall(function() return v.LocalTransparencyModifier end)
					if ok and ltm and ltm > 0.6 then invis = true break end
				end
			end
			if invis and (tick() - lastReset) > 3 then
				lastReset = tick()
				pcall(function() hum.Health = 0 end)
				notify("Invis detected - reset")
			end
		end)
	end)
	addToggle("Anti Glow", "antiGlow", function()
		startLoop("antiGlow", 0.4, function()
			local char = getChar()
			if not char then return end
			for _, v in ipairs(char:GetDescendants()) do
				if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
					v:Destroy()
				end
			end
		end)
	end)
	addToggle("Anti Void", "antiVoid", function()
		startLoop("antiVoid", 0.15, function()
			local hrp = getHRP()
			if hrp and hrp.Position.Y < -30 then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.CFrame = CFrame.new(0, 80, 0)
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
		end)
	end)
	addToggle("Anti Sit", "antiSit", function()
		startLoop("antiSit", 0.15, function()
			local hum = getHum()
			if hum and hum.Sit then
				hum.Sit = false
				hum.Jump = true
			end
		end)
	end)
	addToggle("Anti AFK", "antiAFK", function()
		startLoop("antiAFK", 30, function()
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end)
	end)
	addToggle("Anti Fog", "antiFog", function()
		startLoop("antiFog", 0.5, function()
			local lighting = game:GetService("Lighting")
			lighting.FogEnd = 100000
			lighting.FogStart = 0
			if lighting:FindFirstChild("Fog") then
				pcall(function() lighting.Fog:Destroy() end)
			end
		end)
	end)
	addToggle("Anti Smoke / Fire", "antiSmoke", function()
		startLoop("antiSmoke", 0.5, function()
			local char = getChar()
			if char then
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
						v.Enabled = false
					end
				end
			end
		end)
	end)
	addLabel("── Special ──")
	addToggle("Spam r6 when die", "spamR6", function()
		local function startR6Loop()
			enlightenLoopGen = enlightenLoopGen + 1
			local myGen = enlightenLoopGen
			task.spawn(function()
				local safety = 0
				while enlightenLoopGen == myGen and states.spamR6 and safety < 60 do
					safety = safety + 1
					sayCmd("r6")
					task.wait(1)
					local char = plr.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					if char and hum and hum.Health > 0 and hum.Parent then
						break
					end
				end
			end)
		end
		local function onCharacter(char)
			local hum = char:WaitForChild("Humanoid", 15)
			if not hum then return end
			hum.HealthChanged:Connect(function(hp)
				if not states.spamR6 then return end
				if hp <= 0 then
					task.wait(0.1)
					startR6Loop()
				end
			end)
			hum.Died:Connect(function()
				if not states.spamR6 then return end
				task.wait(0.1)
				startR6Loop()
			end)
		end
		if plr.Character then
			onCharacter(plr.Character)
		end
		if autoEnlightenConn then
			pcall(function() autoEnlightenConn:Disconnect() end)
		end
		autoEnlightenConn = plr.CharacterAdded:Connect(onCharacter)
	end, function()
		enlightenLoopGen = enlightenLoopGen + 1
		if autoEnlightenConn then
			pcall(function() autoEnlightenConn:Disconnect() end)
		end
		autoEnlightenConn = nil
	end)
	notify("Anti GUI loaded")
end
lib.makelabel("Opens the Anti and Extras GUI", antitab)
lib.makebutton("Load Anti and Extras GUI", antitab, function()
	loadAntiGui()
end)
getgenv()._tcoOpenLagGui = function()
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification",{Title="Lag Machine",Text="Removed from commands GUI",Duration=2})
	end)
end
do
	local btab = lib.maketab("blame people lol")
	lib.makelabel("Build auras at selected player (or you)", btab)
	local function blameList()
		return playerDropdownList(true)
	end
	getgenv()._tcoBlameTarget = "me"
	lib.maketoggle("Use Display Names (blame list)", btab, function(bool)
		getgenv()._tcoUseDisplayName = bool
		pcall(function() lib.updatedropdown(blameDrop, blameList()) end)
	end, getgenv()._tcoUseDisplayName and true or false)
	local blameDrop = lib.makedropdown("Blame target", btab, blameList(), function(sel)
		getgenv()._tcoBlameTarget = sel
	end)
	lib.makebutton("Refresh blame targets", btab, function()
		pcall(function() lib.updatedropdown(blameDrop, blameList()) end)
	end)
	local function blameFindPlayer(n)
		if not n or n == "" or n == "(none)" then return nil end
		if n == "me" then return localplr end
		local pl = game.Players:FindFirstChild(n)
		if pl then return pl end
		local low = n:lower()
		for _, p in pairs(game.Players:GetPlayers()) do
			if p.Name:lower() == low or p.DisplayName:lower() == low then return p end
		end
		for _, p in pairs(game.Players:GetPlayers()) do
			if p.Name:lower():find(low, 1, true) or p.DisplayName:lower():find(low, 1, true) then return p end
		end
		return nil
	end
	local function blameHRP()
		local n = getgenv()._tcoBlameTarget or "me"
		if not n or n == "me" or n == "(me)" then
			local ch = localplr.Character
			return ch and ch:FindFirstChild("HumanoidRootPart")
		end
		local p = blameFindPlayer(n)
		local h = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if h and getgenv()._tcoBlameUnder then
			pcall(function() tcoInstantNoclipUnder(h.Position) end)
		end
		return h
	end
	local function equipTool(name)
				if typeof(refreshToolBypass) == "function" then
			pcall(refreshToolBypass, name)
		end
		return findToolAny and findToolAny(name) or localplr.Backpack:FindFirstChild(name)
	end
	getgenv()._tcoBlameRange = getgenv()._tcoBlameRange or 35
	getgenv()._tcoBlameUnder = false
	lib.maketoggle("Tween under target while blaming", btab, function(bool)
		getgenv()._tcoBlameUnder = bool
		if bool then
			pcall(function()
				local my = localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart")
				if my then getgenv()._tcoBlameHomeCF = my.CFrame end
			end)
		else
			if typeof(tcoClearUnderHold) == "function" then tcoClearUnderHold() end
			if typeof(tcoSoftReturnHome) == "function" and getgenv()._tcoBlameHomeCF then
				tcoSoftReturnHome(getgenv()._tcoBlameHomeCF)
			end
		end
	end, false)
	lib.maketextbox("Blame aura range (default 35)", btab, function(txt)
		local n = tonumber(txt)
		if n and n > 0 then getgenv()._tcoBlameRange = n end
	end)
	pcall(function() tcoAddModeToggles(btab) end)
		lib.maketoggle("Blame Build Aura", btab, function(bool)
		getgenv()._tcoBlameBuild = bool
		if not bool then
			getgenv()._tcoBlameBuild_gen = (getgenv()._tcoBlameBuild_gen or 0) + 1
			if typeof(tcoClearUnderHold) == "function" then tcoClearUnderHold() end
			if typeof(tcoSoftReturnHome) == "function" and getgenv()._tcoBlameHomeCF then tcoSoftReturnHome(getgenv()._tcoBlameHomeCF) end
			return
		end
		local gen = (getgenv()._tcoBlameBuild_gen or 0) + 1
		getgenv()._tcoBlameBuild_gen = gen
		task.spawn(function()
			while getgenv()._tcoBlameBuild and getgenv()._tcoBlameBuild_gen == gen do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					if getgenv()._tcoBlameUnder then tcoInstantNoclipUnder(hrp.Position) end
					local sizeMode = "normal"
					pcall(function()
						if localplr.PlayerGui:FindFirstChild("Build") and localplr.PlayerGui.Build:FindFirstChild("Button") then
							sizeMode = localplr.PlayerGui.Build.Button.Text
						end
					end)
					local b = hrp.Position
					fireBuildAt(b + Vector3.new(math.random(-10, 10), -1.5, math.random(-10, 10)), sizeMode)
				end)
				task.wait(0.03)
			end
		end)
	end, false)
	lib.maketoggle("Blame Sign Aura", btab, function(bool)
		getgenv()._tcoBlameSign = bool
		if not bool then
			if typeof(tcoClearUnderHold) == "function" then tcoClearUnderHold() end
			if typeof(tcoSoftReturnHome) == "function" and getgenv()._tcoBlameHomeCF then tcoSoftReturnHome(getgenv()._tcoBlameHomeCF) end
			return
		end
		task.spawn(function()
			while getgenv()._tcoBlameSign do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					fireSignAt(hrp.Position + Vector3.new(math.random(-5,5), -1.5, math.random(-5,5)))
				end)
				task.wait(0.05)
			end
		end)
	end, false)
	lib.maketoggle("Blame Unanchor Aura", btab, function(bool)
		getgenv()._tcoBlameUnanchor = bool
		if not bool then
			getgenv()._tcoBlameUnanchor_gen = (getgenv()._tcoBlameUnanchor_gen or 0) + 1
			if typeof(tcoClearUnderHold) == "function" then tcoClearUnderHold() end
			if typeof(tcoSoftReturnHome) == "function" and getgenv()._tcoBlameHomeCF then tcoSoftReturnHome(getgenv()._tcoBlameHomeCF) end
			return
		end
		local gen = (getgenv()._tcoBlameUnanchor_gen or 0) + 1
		getgenv()._tcoBlameUnanchor_gen = gen
		task.spawn(function()
			while getgenv()._tcoBlameUnanchor and getgenv()._tcoBlameUnanchor_gen == gen do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					paintAround("unanchor", nil, hrp.Position, getgenv()._tcoBlameRange or 35, "_tcoBlameUnanchor")
				end)
				task.wait(0.05)
			end
		end)
	end, false)
	lib.maketoggle("Blame Black Neon Aura", btab, function(bool)
		getgenv()._tcoBlameBlack = bool
		if not bool then
			getgenv()._tcoBlameBlack_gen = (getgenv()._tcoBlameBlack_gen or 0) + 1
			if typeof(tcoClearUnderHold) == "function" then tcoClearUnderHold() end
			if typeof(tcoSoftReturnHome) == "function" and getgenv()._tcoBlameHomeCF then tcoSoftReturnHome(getgenv()._tcoBlameHomeCF) end
			return
		end
		local gen = (getgenv()._tcoBlameBlack_gen or 0) + 1
		getgenv()._tcoBlameBlack_gen = gen
		task.spawn(function()
			while getgenv()._tcoBlameBlack and getgenv()._tcoBlameBlack_gen == gen do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					paintAround("black", nil, hrp.Position, getgenv()._tcoBlameRange or 35, "_tcoBlameBlack")
				end)
				task.wait(0.05)
			end
		end)
	end, false)
	lib.maketoggle("Blame White Plastic Aura", btab, function(bool)
		getgenv()._tcoBlameWhite = bool
		if not bool then return end
		local gen = (getgenv()._tcoBlameWhite_gen or 0) + 1
		getgenv()._tcoBlameWhite_gen = gen
		task.spawn(function()
			while getgenv()._tcoBlameWhite and getgenv()._tcoBlameWhite_gen == gen do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					paintAround("plastic", Color3.fromRGB(255,255,255), hrp.Position, getgenv()._tcoBlameRange or 35)
				end)
				task.wait(0.05)
			end
		end)
	end, false)
	lib.maketoggle("Blame Rainbow Neon Aura", btab, function(bool)
		getgenv()._tcoBlameRainbow = bool
		if not bool then return end
		task.spawn(function()
			while getgenv()._tcoBlameRainbow do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					local c = Color3.fromHSV((tick()*0.25)%1, 1, 1)
					paintAround("black", c, hrp.Position, getgenv()._tcoBlameRange or 35)
				end)
				task.wait(0.04)
			end
		end)
	end, false)
	lib.maketoggle("Blame ForceField Aura", btab, function(bool)
		getgenv()._tcoBlameFF = bool
		if not bool then return end
		local gen = (getgenv()._tcoBlameFF_gen or 0) + 1
		getgenv()._tcoBlameFF_gen = gen
		task.spawn(function()
			while getgenv()._tcoBlameFF and getgenv()._tcoBlameFF_gen == gen do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					paintAround("forcefield", Color3.fromRGB(0,255,255), hrp.Position, getgenv()._tcoBlameRange or 35)
				end)
				task.wait(0.05)
			end
		end)
	end, false)
	lib.maketoggle("Blame Glass Aura", btab, function(bool)
		getgenv()._tcoBlameGlass = bool
		if not bool then return end
		local gen = (getgenv()._tcoBlameGlass_gen or 0) + 1
		getgenv()._tcoBlameGlass_gen = gen
		task.spawn(function()
			while getgenv()._tcoBlameGlass and getgenv()._tcoBlameGlass_gen == gen do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					paintAround("glass", nil, hrp.Position, getgenv()._tcoBlameRange or 35)
				end)
				task.wait(0.05)
			end
		end)
	end, false)
	lib.maketoggle("Tiny Blocks Aura (blame)", btab, function(bool)
		getgenv()._tcoBlameTiny = bool
		if not bool then return end
		task.spawn(function()
			while getgenv()._tcoBlameTiny do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					local base = hrp.Position
					for i = 1, 6 do
						fireBuildAt(base + Vector3.new((math.random()-0.5)*10, (math.random()-0.5)*3-1, (math.random()-0.5)*10), "detailed")
					end
				end)
				task.wait(0.03)
			end
		end)
	end, false)
	lib.maketoggle("Blame Floor Spam", btab, function(bool)
		getgenv()._tcoBlameFloor = bool
		if not bool then return end
		local gen = (getgenv()._tcoBlameFloor_gen or 0) + 1
		getgenv()._tcoBlameFloor_gen = gen
		task.spawn(function()
			while getgenv()._tcoBlameFloor and getgenv()._tcoBlameFloor_gen == gen do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					local char = localplr.Character
					local bag = localplr.Backpack
					if char and bag and not char:FindFirstChild("Build") and bag:FindFirstChild("Build") then
						bag.Build.Parent = char
					end
					local base = hrp.Position + Vector3.new(0, -4, 0)
					for x = -2, 2 do
						for z = -2, 2 do
							fireBuildAt(base + Vector3.new(x * 4, 0, z * 4), "normal")
						end
					end
				end)
				task.wait(0.08)
			end
		end)
	end, false)
	lib.maketoggle("Blame Build Trail", btab, function(bool)
		getgenv()._tcoBlameCage = bool
		if not bool then return end
		task.spawn(function()
			while getgenv()._tcoBlameCage do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					local p = hrp.Position
					local m = 4
					for _, o in ipairs({
						Vector3.new(m,0,0), Vector3.new(-m,0,0), Vector3.new(0,0,m), Vector3.new(0,0,-m),
						Vector3.new(m,m,0), Vector3.new(-m,m,0), Vector3.new(0,m,m), Vector3.new(0,m,-m),
						Vector3.new(0,-m,0), Vector3.new(0,2*m,0)
					}) do
						fireBuildAt(p + o, "normal")
					end
				end)
				task.wait(0.15)
			end
		end)
	end, false)
	lib.maketoggle("Blame Platform Under", btab, function(bool)
		getgenv()._tcoBlamePlat = bool
		if not bool then return end
		task.spawn(function()
			while getgenv()._tcoBlamePlat do
				pcall(function()
					local hrp = blameHRP()
					if not hrp then return end
					fireBuildAt(hrp.Position + Vector3.new(0, -5, 0), "normal")
					fireBuildAt(hrp.Position + Vector3.new(4, -5, 0), "normal")
					fireBuildAt(hrp.Position + Vector3.new(-4, -5, 0), "normal")
					fireBuildAt(hrp.Position + Vector3.new(0, -5, 4), "normal")
					fireBuildAt(hrp.Position + Vector3.new(0, -5, -4), "normal")
				end)
				task.wait(0.1)
			end
		end)
	end, false)
end
do
	local stab = lib.maketab("settings")
	local cfg = getgenv()._tcoCfg or {}
	local function save()
		if getgenv()._tcoSaveCfg then getgenv()._tcoSaveCfg() end
	end
	local function configNames()
		local t = {}
		cfg.configs = cfg.configs or { default = {} }
		for n in pairs(cfg.configs) do table.insert(t, n) end
		table.sort(t)
		if #t == 0 then t = {"default"} end
		return t
	end
	lib.makelabel("--- Configs (saved on disk) ---", stab)
	local cfgNameBox = "default"
	lib.maketextbox("Config name to save", stab, function(txt)
		if txt and txt ~= "" then cfgNameBox = txt end
	end)
	lib.makebutton("Save config (current settings)", stab, function()
		cfg.configs = cfg.configs or {}
		cfg.configs[cfgNameBox] = {
			skipIntro = cfg.skipIntro,
			loadMain = cfg.loadMain,
			loadCmds = cfg.loadCmds,
			theme = cfg.theme or getgenv()._guyHubThemeName or "Dark",
			joinHi = cfg.joinHi,
			joinHiMsg = cfg.joinHiMsg,
			joinFling = cfg.joinFling,
			joinCmd = cfg.joinCmd,
			joinCmdMsg = cfg.joinCmdMsg,
		}
		cfg.activeConfig = cfgNameBox
		save()
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {Title="Config", Text="Saved "..cfgNameBox, Duration=2})
		end)
	end)
	local cfgDrop = lib.makedropdown("Select config", stab, configNames(), function(sel)
		cfg.activeConfig = sel
		save()
	end)
	lib.makebutton("Load selected config", stab, function()
		local name = cfg.activeConfig or "default"
		local ac = cfg.configs and cfg.configs[name]
		if not ac then
			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {Title="Config", Text="Missing "..tostring(name), Duration=2})
			end)
			return
		end
		for k, v in pairs(ac) do cfg[k] = v end
		getgenv()._tcoSkipIntro = cfg.skipIntro and true or false
		getgenv()._tcoLoadMain = cfg.loadMain ~= false
		getgenv()._tcoLoadCmds = cfg.loadCmds and true or false
		save()
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {Title="Config", Text="Loaded "..name.." (re-execute for full effect)", Duration=3})
		end)
	end)
	lib.maketoggle("Reload config on execute", stab, function(bool)
		cfg.reloadOnExecute = bool
		save()
	end, cfg.reloadOnExecute and true or false)
	lib.makelabel("--- Intro & load ---", stab)
	lib.maketoggle("Skip intro", stab, function(bool)
		cfg.skipIntro = bool
		getgenv()._tcoSkipIntro = bool
		save()
	end, cfg.skipIntro and true or false)
	lib.maketoggle("Load Main GUI", stab, function(bool)
		cfg.loadMain = bool
		getgenv()._tcoLoadMain = bool
		save()
	end, cfg.loadMain ~= false)
	lib.maketoggle("Load Commands GUI", stab, function(bool)
		cfg.loadCmds = bool
		getgenv()._tcoLoadCmds = bool
		save()
	end, cfg.loadCmds and true or false)
	lib.makelabel("Saved to guyhub_tco_config.json (executor FS)", stab)
end
namecolors = {
	peasant={150,103,102},
	arken={4,175,236},
	admin={245,205,48},
	hidden={255,0,0},
	iqgenius={255,179,179},
	iqdumb={200,0,0}
}
if isog then
	namecolors.peasant = {128,128,128}
end
namecolorshex = {}
for i,v in pairs(namecolors) do
	namecolorshex[i] = "#"..Color3.fromRGB(table.unpack(v)):ToHex()
end
joincmds = {
	joinxl="JoinXL",
	joinvc="JoinVC",
	joinog="JoinOG"
}
function oimremake(mdata)
	if not spychat then
		return
	end
	local ok, err = pcall(function()
		if not mdata then return end
		local text = tostring(mdata.Text or "")
		local src = mdata.TextSource
		local uid = src and src.UserId
		local plr = uid and game.Players:GetPlayerByUserId(uid)
		if not plr then return end
		local cn = "peasant"
		local hidden = false
		local muted = false
		pcall(function()
			if plr.Neutral == true then
				cn = (plr:GetAttribute("Arken") == true) and "arken" or "peasant"
			else
				cn = "admin"
			end
		end)
		pcall(function() muted = plr:HasTag("Muted") == true end)
		if muted then
			cn = "hidden"
			if not spychat then
				mdata.Text = ""
				text = ""
			end
		end
		local spacePos = string.find(text, " ", 1, true)
		local cmd = text
		if spacePos then cmd = string.sub(text, 1, spacePos - 1) end
		if string.sub(text, 1, 1) == ";" then
			if spacePos then
				cmd = string.sub(text, 2, spacePos - 1)
			else
				cmd = string.sub(text, 2)
			end
			if spychat then
				cn = "hidden"
				hidden = true
			else
				mdata.Text = ""
			end
		end
		pcall(function()
			if plr == localplr and cmd and joincmds[string.lower(cmd)] then
				for i, v in pairs(joincmds) do
					local gui = localplr.PlayerGui:FindFirstChild(v)
					if gui then gui.Enabled = (i == string.lower(cmd)) end
				end
			end
		end)
		local iq = nil
		if spychat then
			local iqVal = plr:GetAttribute("IQ")
			if typeof(iqVal) == "number" then
				if iqVal >= 200 then iq = "genius"; cn = "iqgenius"
				elseif iqVal <= 50 then iq = "dumb"; cn = "iqdumb" end
			end
		end
		local isSemicolon = string.sub(text, 1, 1) == ";"
		local isPrivate = hidden or muted or cn == "hidden"
		local forceRed = isSemicolon or isPrivate
		local col = namecolors[cn] or namecolors.peasant
		local hex = namecolorshex[cn] or namecolorshex.peasant
		local extra = ""
		if hidden then extra = extra .. " (HIDDEN CHAT)" end
		if iq then extra = extra .. " (" .. iq .. ")" end
		if muted then extra = extra .. " (MUTED)" end
		if isSemicolon then extra = extra .. " (;)" end
		local rgb = tostring(col[1]) .. "," .. tostring(col[2]) .. "," .. tostring(col[3])
		if forceRed then
			hex = "#ff3030"
			rgb = "255,48,48"
		end
		if isog then
			mdata.PrefixText = "<font color=\"" .. hex .. "\"><b><font color='rgb(" .. rgb .. ")'>[" .. plr.DisplayName .. extra .. "]: </font></b></font>"
		else
			mdata.PrefixText = "<font color=\"" .. hex .. "\"><i><font color='rgb(" .. rgb .. ")'>(" .. plr.DisplayName .. extra .. ") </font></i></font>"
		end
		if forceRed and text ~= "" then
			mdata.Text = "<font color='rgb(255,48,48)'>" .. text .. "</font>"
		end
	end)
	if not ok then warn("[TCO] spy chat oim error:", err) end
end
local _tcoSpyChatInstalled = false
local _tcoSpyChatPreviousHandler = nil
function setSpyChatHook(enabled)
	spychat = enabled and true or false
	getgenv()._tcoSpyChat = spychat
	local tcs = game:GetService("TextChatService")
	if spychat then
		pcall(function()
			if not _tcoSpyChatInstalled then
				_tcoSpyChatPreviousHandler = tcs.OnIncomingMessage
				_tcoSpyChatInstalled = true
			end
			tcs.OnIncomingMessage = oimremake
		end)
	else
		pcall(function()
			if _tcoSpyChatInstalled and tcs.OnIncomingMessage == oimremake then
				tcs.OnIncomingMessage = _tcoSpyChatPreviousHandler
			end
			_tcoSpyChatInstalled = false
			_tcoSpyChatPreviousHandler = nil
		end)
	end
	getgenv()._tcoSetSpyChat = setSpyChatHook
end
lib.maketoggle("SPY CHAT", modtab, function(bool)
	setSpyChatHook(bool)
end, false)
lib.makelabel("OFF by default. Toggle ON to see ; hidden / muted chats.", modtab)
bbid = bbid or ""
boomboxnames = {}
boomboxnames["SuperFlyGoldBoombox"] = true
boomboxnames["BoomboxGearThree"] = true
boomboxnames["DualGoldenSuperFlyBoombox"] = true
boomboxnames["DubstepBoombox"] = true
boomboxnames["BeatUpBoombox"] = true
inputbegan = game:GetService("UserInputService").InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		local mousepart = mouse.Target
		if mousepart then
			if mousepart:IsDescendantOf(workspace.Bricks) then
				local plr = game.Players:FindFirstChild(mousepart.Parent.Name)
				local plrtxt = ""
				if plr then
					if plr.DisplayName == plr.Name then
						plrtxt = plr.Name
					else
						plrtxt = plr.DisplayName.."/"..plr.Name
					end
				else
					plrtxt = mousepart.Parent.Name.." (NOT INGAME)"
				end
				if mousepart.Parent.Parent == workspace then
					plrtxt = "Server Build (Not from anyone)"
				end
				lib.updatelabel("Block is from: "..plrtxt,blocktxt)
				if oss then
					lib.updatelabel("Block is from: "..plrtxt,blocktxt2)
					ssbox.Adornee = mousepart
					ssbox.Face = side
					sblock = mousepart
				end
				if ss then
					local ctm = nil
					for i,v in pairs(normalids) do
						local pos = mousepart.Position + (v[1]*mousepart.Size[v[2]]/2)
						if ctm == nil then
							ctm = {i,(mouse.Hit.Position - pos).Magnitude}
						elseif (mouse.Hit.Position - pos).Magnitude < ctm[2] then
							ctm = {i,(mouse.Hit.Position - pos).Magnitude}
						end
					end
					side = ctm[1]
					ssbox.Face = side
				end
			else
				lib.updatelabel("No Block Selected",blocktxt)
				sbox.Adornee = nil
			end
			if boomboxnames[mousepart.Parent.Name] == true then
				local sound = mousepart.Parent:FindFirstChild("Sound",true)
				if sound.SoundId == nil or sound.SoundId == "" then
					lib.updatelabel("No sound is playing on the boombox!",bboxtxt)
					bbid = ""
				else
					bbid = string.sub(sound.SoundId,string.find(sound.SoundId,"id=")+3)
					lib.updatelabel("Boombox ID: "..bbid,bboxtxt)
				end
				bbsbox.Adornee = mousepart.Parent.Handle
			else
				lib.updatelabel("No Boombox Selected",bboxtxt)
				bbsbox.Adornee = nil
			end
		else
			lib.updatelabel("No Block Selected",blocktxt)
			sbox.Adornee = nil
			lib.updatelabel("No Boombox Selected",bboxtxt)
			bbsbox.Adornee = nil
		end
	end
end)
groups = {}
dheads = {}
function plradded(plr)
	local owner = scrowners[plr.UserId]
	local enderhubperson = enderhubpeople[plr.UserId]
	local nahhh = plr.Name == "Visible_Threat"
	local beggar = plr.Name == "Skibisaacjacob" or plr.Name == "spiralrblxofficial"
	local group = false
	for i,v in pairs(groups) do
		if plr:IsInGroup(i) then
			local nv = v
			table.insert(v,i)
			group = nv
		end
	end
	if owner or group or nahhh or beggar or enderhubperson then
		function onchar(c)
			coroutine.wrap(function()
				c:WaitForChild("Head",math.huge)
				local bbgui = Instance.new("BillboardGui")
				dheads[c.Head] = bbgui
				bbgui.Size = UDim2.new(10,0,1.5,0)
				bbgui.StudsOffset = Vector3.new(0,3.5,0)
				bbgui.Parent = c.Head
				local txt = Instance.new("TextLabel")
				txt.TextScaled = true
				txt.BackgroundTransparency = 1
				txt.Size = UDim2.new(1,0,1,0)
				txt.Position = UDim2.new(0,0,-0.5,0)
				txt.TextStrokeTransparency = 0
				local infotxt = Instance.new("TextLabel")
				infotxt.TextScaled = true
				infotxt.BackgroundTransparency = 1
				infotxt.Size = UDim2.new(1,0,0.5,0)
				infotxt.Position = UDim2.new(0,0,0.5,0)
				infotxt.TextStrokeTransparency = 0
				if owner then
					txt.Text = "Script Owner (Extra Stuff)"
					infotxt.Text = "Don't ask me for the 'tag' script, you only see this when you execute the script."
					txt.TextColor3 = Color3.fromRGB(200,90,0)
				elseif enderhubperson then
					txt.Text = "Ender Hub"
					infotxt.Text = "these people are tuff"
					txt.TextColor3 = Color3.fromRGB(18,94,84)
				elseif beggar then
					txt.Text = "Beggar"
					infotxt.Text = "laugh at this person please"
					txt.TextColor3 = Color3.fromRGB(0,100,0)
				elseif nahhh then
					txt.Text = "I'm Not Tuff"
					infotxt.Text = "stop using my script, you are not tuff!"
					txt.TextColor3 = Color3.fromRGB(255,0,0)
				elseif group then
					txt.Text = group[1]
					txt.TextColor3 = group[2]
					infotxt.Text = plr:GetRoleInGroup(group[3])
				end
				txt.Parent = bbgui
				infotxt.TextColor3 = txt.TextColor3
				infotxt.Parent = bbgui
			end)()
		end
		if plr.Character then
			onchar(plr.Character)
		end
		table.insert(conn,plr.CharacterAdded:Connect(onchar))
	end
end
for i,v in pairs(game.Players:GetPlayers()) do
	plradded(v)
end
onplr = game.Players.PlayerAdded:Connect(plradded)
lib.ondestroyedfunc = function()
	on = false
	ot = false
	ccol = false
	stopped = true
	skipblock = true
	autoperm = false
	alwaysreset = false
	alwaysresetall = false
	built = true
	spychat = false
	cubechild:Disconnect()
	onrender:Disconnect()
	inputbegan:Disconnect()
	highlight:Destroy()
	onplr:Disconnect()
	daura = false
	dauras = false
	ors = false
	daurapart:Destroy()
	for i,v in pairs(commands) do
		v = false
	end
	pickuptools = false
	autodroptools = false
	onchradded:Disconnect()
	dee2 = false
	dee = false
	spmbl = false
	spmsi = false
	if prttable then
		for i,v in pairs(prttable) do
			v:Destroy()
		end
	end
	wbs = false
	if oldprt then
		oldprt:Destroy()
	end
	sbox.Adornee = nil
	sbox:Destroy()
	bbsbox.Adornee = nil
	bbsbox:Destroy()
	for i,v in pairs(conn) do
		v:Disconnect()
	end
	for i,v in pairs(dheads) do
		if v then
			v:Destroy()
		end
	end
	ssbox.Adornee = nil
	ssbox:Destroy()
	spmsb = false
	ss = false
	tp = false
	onbrick:Disconnect()
	buildhighlight:Destroy()
	offsetpart:Destroy()
end
end)
do
	local RS = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")
	local lp = game.Players.LocalPlayer
	local IDLE_ID = 70911307307774
	local WALK_ID = 91882704243098
	local RUN_ID = 76925904315215
	local SLASH_ID = 128779579295748
	local SNATCH_ID = 126234379064550
	local BARRAGE_ID = 120668080412453
	local DROP_ID = 127764273000599
	local DOMAIN_ID = 107014191831064
	local LOGOS = {
		slash = "rbxthumb://type=Asset&id=128779579295748&w=150&h=150",
		snatch = "rbxthumb://type=Asset&id=126234379064550&w=150&h=150",
		barrage = "rbxthumb://type=Asset&id=120668080412453&w=150&h=150",
		domain = "rbxthumb://type=Asset&id=107014191831064&w=150&h=150",
	}
	local on, busy = false, false
	local idleTrack, moveTrack, abilityTrack = nil, nil, nil
	local abilityGui, inputConn, movementThread = nil, nil, nil
	local speedValue, movementState = 16, "idle"
	local baseFov, targetFov, savedWalkSpeed = 70, 70, 16
	local function stopTrack(track, fade)
		pcall(function()
			if track then
				track:Stop(fade or 0.1)
			end
		end)
	end
	local function stopAllTracks()
		stopTrack(abilityTrack, 0.05)
		stopTrack(moveTrack, 0.05)
		stopTrack(idleTrack, 0.05)
		abilityTrack, moveTrack, idleTrack = nil, nil, nil
		pcall(function()
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			local animator = hum and hum:FindFirstChildOfClass("Animator")
			if animator then
				for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
					pcall(function() t:Stop(0.05) end)
				end
			end
		end)
	end
	local function resolveAnimation(id)
		id = tostring(id):gsub("rbxassetid://", "")
		local anim = nil
		pcall(function()
			if typeof(game.GetObjects) == "function" then
				local objects = game:GetObjects("rbxassetid://" .. id)
				if objects and objects[1] then
					local item = objects[1]
					if item:IsA("Animation") then
						anim = item
					else
						anim = item:FindFirstChildWhichIsA("Animation", true)
					end
				end
			end
		end)
		if not anim then
			anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://" .. id
		end
		return anim
	end
	local function loadAnim(id, looped, priority)
		local char = lp.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return nil end
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = hum
		end
		local anim = resolveAnimation(id)
		local track = nil
		pcall(function()
			track = animator:LoadAnimation(anim)
		end)
		if not track then
			pcall(function()
				track = hum:LoadAnimation(anim)
			end)
		end
		if not track then return nil end
		track.Priority = priority or Enum.AnimationPriority.Action4
		track.Looped = looped and true or false
		pcall(function()
			track:Play(0.1, 1, 1)
			track:AdjustWeight(1)
		end)
		return track
	end
	local function playAbilityEmote(id, looped)
		stopTrack(abilityTrack, 0.05)
		stopTrack(moveTrack, 0.05)
		stopTrack(idleTrack, 0.05)
		moveTrack, idleTrack = nil, nil
		pcall(function()
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			local animator = hum and hum:FindFirstChildOfClass("Animator")
			if animator then
				for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
					if t.Priority == Enum.AnimationPriority.Core or t.Priority == Enum.AnimationPriority.Idle or t.Priority == Enum.AnimationPriority.Movement then
						pcall(function() t:Stop(0.05) end)
					end
				end
			end
			local animate = lp.Character and lp.Character:FindFirstChild("Animate")
			if animate and animate:IsA("LocalScript") then
				animate.Disabled = true
			end
		end)
		abilityTrack = loadAnim(id, looped == true, Enum.AnimationPriority.Action4)
		return abilityTrack
	end
	local function resumeIdle()
		stopTrack(abilityTrack, 0.12)
		abilityTrack = nil
		pcall(function()
			local animate = lp.Character and lp.Character:FindFirstChild("Animate")
			if animate and animate:IsA("LocalScript") then
				animate.Disabled = false
			end
		end)
		if on and not busy then
			idleTrack = loadAnim(IDLE_ID, true, Enum.AnimationPriority.Idle)
			movementState = "idle"
		end
	end
	local function nearestHRP(maxDist)
		maxDist = maxDist or 120
		local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if not my then return nil end
		local best, bd = nil, maxDist
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= lp and p.Character then
				local h = p.Character:FindFirstChild("HumanoidRootPart")
				local hum = p.Character:FindFirstChildOfClass("Humanoid")
				if h and hum and hum.Health > 0 then
					local d = (h.Position - my.Position).Magnitude
					if d < bd then best, bd = h, d end
				end
			end
		end
		return best
	end
	local function softReturn(cf)
		pcall(function()
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if my and cf then
				my.CFrame = cf
				my.AssemblyLinearVelocity = Vector3.zero
				my.AssemblyAngularVelocity = Vector3.zero
			end
			if hum then
				hum.Sit = true
				task.wait(0.12)
				hum.Sit = false
			end
		end)
	end
	local function flingLikeRiftSlash(target, duration)
		if not target or not target.Parent then return end
		if typeof(flingHold) == "function" then
			flingHold(target, duration)
		elseif typeof(flingWithReturn) == "function" then
			flingWithReturn(target, duration, false)
		else
			local t0 = tick()
			while tick() - t0 < duration and target and target.Parent do
				pcall(function()
					local v = Vector3.new((math.random() - 0.5) * 3e4, 3e4, (math.random() - 0.5) * 3e4)
					target.AssemblyLinearVelocity = v
					pcall(function() target.Velocity = v end)
				end)
				task.wait(0.05)
			end
		end
	end
	local function castSlash()
		if busy then return end
		busy = true
		task.spawn(function()
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not my then busy = false return end
			local home = my.CFrame
			playAbilityEmote(SLASH_ID, true)
			local look = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector or my.CFrame.LookVector
			for i = 1, 8 do
				pcall(function()
					my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
					if my then
						my.CFrame = my.CFrame + look * 4
						my.AssemblyLinearVelocity = look * 60
					end
				end)
				task.wait(0.03)
			end
			local th = nearestHRP(40)
			if th then flingLikeRiftSlash(th, 1.2) end
			softReturn(home)
			resumeIdle()
			busy = false
		end)
	end
	local function castSnatch()
		if busy then return end
		busy = true
		task.spawn(function()
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not my then busy = false return end
			local home = my.CFrame
			local th = nearestHRP(150)
			if not th then resumeIdle() busy = false return end
			playAbilityEmote(SNATCH_ID, true)
			for i = 1, 6 do
				pcall(function()
					if th and th.Parent then
						my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
						if my then my.CFrame = th.CFrame * CFrame.new(0, 0, 3) end
					end
				end)
				task.wait(0.05)
			end
			if typeof(flingWithReturn) == "function" then
				flingWithReturn(th, 2.5, false)
			elseif typeof(flingHold) == "function" then
				flingHold(th, 2.5)
			end
			softReturn(home)
			resumeIdle()
			busy = false
		end)
	end
	local function castBarrage()
		if busy then return end
		busy = true
		task.spawn(function()
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if not my or not hum then busy = false return end
			local oldSpeed = hum.WalkSpeed
			local oldAutoRotate = hum.AutoRotate
			local hitTarget, hitPosition = nil, nil
			local start = tick()
			playAbilityEmote(BARRAGE_ID, true)
			while tick() - start < 10 and on and not hitTarget do
				pcall(function()
					my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
					hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
					local cam = workspace.CurrentCamera
					if not my or not hum then return end
					hum.WalkSpeed = 0
					hum.AutoRotate = false
					local look = cam and cam.CFrame.LookVector or my.CFrame.LookVector
					local flat = Vector3.new(look.X, 0, look.Z)
					if flat.Magnitude > 0.001 then
						flat = flat.Unit
						my.CFrame = CFrame.lookAt(my.Position + flat * 7, my.Position + flat * 14)
						my.AssemblyLinearVelocity = flat * 70
					end
					local camFlat = flat
					local closest, closestDist = nil, 5.5
					for _, p in pairs(Players:GetPlayers()) do
						if p ~= lp and p.Character then
							local h = p.Character:FindFirstChild("HumanoidRootPart")
							local th = p.Character:FindFirstChildOfClass("Humanoid")
							if h and th and th.Health > 0 then
								local offset = h.Position - my.Position
								local d = offset.Magnitude
								if d < closestDist and (d < 2 or offset.Unit:Dot(camFlat) > 0.55) then
									closest, closestDist = h, d
								end
							end
						end
					end
					if closest then
						hitTarget = closest
						hitPosition = my.CFrame
					end
				end)
				task.wait(0.03)
			end
			stopTrack(abilityTrack, 0.05)
			abilityTrack = nil
			if hitTarget and hitTarget.Parent then
				playAbilityEmote(DROP_ID, false)
				flingLikeRiftSlash(hitTarget, 1.2)
				task.wait(1.2)
				stopTrack(abilityTrack, 0.1)
				abilityTrack = nil
				if hitPosition then softReturn(hitPosition) end
			end
			pcall(function()
				hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.WalkSpeed = oldSpeed
					hum.AutoRotate = oldAutoRotate
				end
			end)
			resumeIdle()
			busy = false
		end)
	end
	local function castDomain()
		if busy then return end
		busy = true
		task.spawn(function()
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if not my or not hum then busy = false return end
			local home = my.CFrame
			local oldSpeed, oldAutoRotate = hum.WalkSpeed, hum.AutoRotate
			local targets = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= lp and p.Character then
					local th = p.Character:FindFirstChild("HumanoidRootPart")
					local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
					if th and targetHum and targetHum.Health > 0 and (th.Position - home.Position).Magnitude <= 35 then
						table.insert(targets, th)
					end
				end
			end
			playAbilityEmote(DOMAIN_ID, true)
			task.wait(0.15)
			for _, th in ipairs(targets) do
				task.spawn(function()
					if th and th.Parent then flingLikeRiftSlash(th, 2) end
				end)
			end
			task.wait(2.1)
			stopTrack(abilityTrack, 0.1)
			abilityTrack = nil
			pcall(function()
				hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.WalkSpeed = oldSpeed
					hum.AutoRotate = oldAutoRotate
				end
			end)
			softReturn(home)
			resumeIdle()
			busy = false
		end)
	end
	function tcoPhantomCast(which)
		which = tostring(which or ""):lower()
		if which == "slash" or which == "riftslash" or which == "1" then castSlash()
		elseif which == "snatch" or which == "soulsnatch" or which == "2" then castSnatch()
		elseif which == "barrage" or which == "3" then castBarrage()
		elseif which == "domain" or which == "voiddomain" or which == "4" then castDomain()
		end
	end
	getgenv().tcoPhantomCast = tcoPhantomCast
	local function destroyGui()
		if abilityGui then pcall(function() abilityGui:Destroy() end) end
		abilityGui = nil
		local old = game.CoreGui:FindFirstChild("TCOPhantomAbilities")
		if old then old:Destroy() end
	end
	local function makeGui()
		destroyGui()
		local isMobile = UIS.TouchEnabled == true
		local hasKeyboard = UIS.KeyboardEnabled == true
		local btnSize = (isMobile and not hasKeyboard) and 48 or 58
		local sg = Instance.new("ScreenGui")
		sg.Name = "TCOPhantomAbilities"
		sg.ResetOnSpawn = false
		sg.DisplayOrder = 81
		sg.IgnoreGuiInset = true
		pcall(function() sg.Parent = game.CoreGui end)
		if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end
		abilityGui = sg
		local center = Instance.new("Frame")
		center.Name = "AbilityRing"
		center.BackgroundTransparency = 1
		center.AnchorPoint = Vector2.new(1, 1)
		center.Position = UDim2.new(1, -8, 1, -145)
		center.Size = UDim2.new(0, (btnSize + 8) * 4 + 8, 0, btnSize + 28)
		center.Parent = sg
		local lay = Instance.new("UIListLayout")
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.Padding = UDim.new(0, 8)
		lay.Parent = center
		local names = {"Rift Slash", "Soul Snatch", "Barrage", "Domain"}
		local keys = {"slash", "snatch", "barrage", "domain"}
		for i = 1, 4 do
			local slot = Instance.new("Frame")
			slot.Size = UDim2.new(0, btnSize + 4, 0, btnSize + 24)
			slot.BackgroundTransparency = 1
			slot.LayoutOrder = i
			slot.Parent = center
			local nameL = Instance.new("TextLabel")
			nameL.Size = UDim2.new(1, 0, 0, 12)
			nameL.BackgroundTransparency = 1
			nameL.Text = names[i]
			nameL.TextColor3 = Color3.fromRGB(220, 230, 255)
			nameL.TextSize = 9
			nameL.Font = Enum.Font.GothamBold
			nameL.TextTruncate = Enum.TextTruncate.AtEnd
			nameL.Parent = slot
			local btn = Instance.new("ImageButton")
			btn.Name = keys[i]
			btn.Size = UDim2.new(0, btnSize, 0, btnSize)
			btn.Position = UDim2.new(0.5, 0, 0, 13)
			btn.AnchorPoint = Vector2.new(0.5, 0)
			btn.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
			btn.Image = LOGOS[keys[i]]
			btn.ScaleType = Enum.ScaleType.Fit
			btn.Parent = slot
			Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(140, 100, 255)
			stroke.Thickness = 2.5
			stroke.Parent = btn
			local keyL = Instance.new("TextLabel")
			keyL.Size = UDim2.new(1, 0, 0, 14)
			keyL.Position = UDim2.new(0, 0, 1, -14)
			keyL.BackgroundTransparency = 1
			keyL.Text = tostring(i)
			keyL.TextColor3 = Color3.new(1, 1, 1)
			keyL.TextSize = 12
			keyL.Font = Enum.Font.GothamBold
			keyL.Parent = btn
			btn.MouseButton1Click:Connect(function()
				tcoPhantomCast(keys[i])
			end)
		end
	end
	local function movementLoop()
		if movementThread then return end
		movementThread = task.spawn(function()
			while on do
				pcall(function()
					if busy then return end
					local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
					local cam = workspace.CurrentCamera
					if not hum then return end
					if hum.MoveDirection.Magnitude > 0.08 then
						speedValue = math.min(54, speedValue + 0.22)
						hum.WalkSpeed = speedValue
						targetFov = baseFov + ((speedValue - 16) / 38) * 38
						if speedValue < 28 then
							if movementState ~= "walk" or not (moveTrack and moveTrack.IsPlaying) then
								stopTrack(idleTrack, 0.1)
								idleTrack = nil
								stopTrack(moveTrack, 0.1)
								moveTrack = loadAnim(WALK_ID, true, Enum.AnimationPriority.Movement)
								movementState = "walk"
							end
							if moveTrack then pcall(function() moveTrack:AdjustSpeed(0.55 + ((speedValue - 16) / 12) * 0.65) end) end
						else
							if movementState ~= "run" or not (moveTrack and moveTrack.IsPlaying) then
								stopTrack(idleTrack, 0.1)
								idleTrack = nil
								stopTrack(moveTrack, 0.1)
								moveTrack = loadAnim(RUN_ID, true, Enum.AnimationPriority.Movement)
								movementState = "run"
							end
							if moveTrack then pcall(function() moveTrack:AdjustSpeed(0.9 + ((speedValue - 28) / 26) * 0.7) end) end
						end
					else
						speedValue = 16
						hum.WalkSpeed = 16
						targetFov = baseFov
						if movementState ~= "idle" then
							stopTrack(moveTrack, 0.15)
							moveTrack = nil
							idleTrack = loadAnim(IDLE_ID, true, Enum.AnimationPriority.Idle)
							movementState = "idle"
						end
					end
					if cam then
						cam.FieldOfView = cam.FieldOfView + (math.clamp(targetFov, baseFov, baseFov + 38) - cam.FieldOfView) * 0.08
					end
				end)
				task.wait(0.03)
			end
			movementThread = nil
		end)
	end
	function tcoPhantomSetEnabled(enabled)
		on = enabled and true or false
		getgenv()._tcoPhantomOn = on
		if not on then
			busy = false
			movementThread = nil
			pcall(function()
				local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = savedWalkSpeed or 16 end
				local animate = lp.Character and lp.Character:FindFirstChild("Animate")
				if animate and animate:IsA("LocalScript") then animate.Disabled = false end
			end)
			stopAllTracks()
			destroyGui()
			if inputConn then pcall(function() inputConn:Disconnect() end) inputConn = nil end
			pcall(function()
				local cam = workspace.CurrentCamera
				if cam then cam.FieldOfView = baseFov end
			end)
			speedValue = 16
			movementState = "idle"
			return
		end
		pcall(function()
			local cam = workspace.CurrentCamera
			if cam then baseFov = cam.FieldOfView targetFov = baseFov end
		end)
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			savedWalkSpeed = hum.WalkSpeed
			speedValue = 16
			hum.WalkSpeed = 16
		end
		makeGui()
		movementState = "idle"
		idleTrack = loadAnim(IDLE_ID, true, Enum.AnimationPriority.Idle)
		movementLoop()
		if inputConn then pcall(function() inputConn:Disconnect() end) end
		inputConn = UIS.InputBegan:Connect(function(inp, gp)
			if gp or not on then return end
			local map = {
				[Enum.KeyCode.One] = "slash",
				[Enum.KeyCode.Two] = "snatch",
				[Enum.KeyCode.Three] = "barrage",
				[Enum.KeyCode.Four] = "domain",
			}
			local w = map[inp.KeyCode]
			if w then tcoPhantomCast(w) end
		end)
	end
	getgenv().tcoPhantomSetEnabled = tcoPhantomSetEnabled
	if getgenv()._tcoPhantomPending then
		getgenv()._tcoPhantomPending = nil
		tcoPhantomSetEnabled(true)
	end
end
do
	local RS = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local Players = game:GetService("Players")
	local lp = game.Players.LocalPlayer
	local IDLE_ID = 76361248833307
	local WALK_ID = 103108206614856
	local RUN_ID = 138431313591911
	local MADNESS_ID = 115344615095212
	local SCREAM_ID = 106126238069740
	local PUNCH_ID = 132934182261872
	local RISE_ID = 110047392616015
	local FINAL_ID = 110914756664020
	local LOGOS = {
		madness = "rbxthumb://type=Asset&id=6034754445&w=150&h=150",
		scream = "rbxthumb://type=Asset&id=6031094678&w=150&h=150",
		punch = "rbxthumb://type=Asset&id=6034287594&w=150&h=150",
		final = "rbxthumb://type=Asset&id=6031229350&w=150&h=150",
	}
	local on, busy = false, false
	local idleTrack, walkTrack, runTrack, abilityTrack = nil, nil, nil, nil
	local abilityGui, inputConn = nil, nil
	local buildUp, baseFov, maxSpeed = 0, 70, 40
	local function stopTracks()
		for _, t in pairs({idleTrack, walkTrack, runTrack, abilityTrack}) do
			pcall(function() if t then t:Stop(0.1) end end)
		end
		idleTrack, walkTrack, runTrack, abilityTrack = nil, nil, nil, nil
	end
	local function loadAnim(id, looped, priority)
		local char = lp.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return nil end
		local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(id)
		pcall(function()
			if typeof(game.GetObjects) == "function" then
				local objects = game:GetObjects("rbxassetid://" .. tostring(id))
				if objects and objects[1] then
					local item = objects[1]
					if item:IsA("Animation") then anim = item
					else
						local found = item:FindFirstChildWhichIsA("Animation", true)
						if found then anim = found end
					end
				end
			end
		end)
		local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
		if not ok or not track then return nil end
		track.Priority = priority or Enum.AnimationPriority.Action4
		track.Looped = looped and true or false
		pcall(function() track:Play(0.12) end)
		return track
	end
	local function setFov(v)
		pcall(function()
			local cam = workspace.CurrentCamera
			if cam then cam.FieldOfView = v end
		end)
	end
	local function warnBkit()
		task.spawn(function()
			local sg = Instance.new("ScreenGui")
			sg.Name = "TCOGrieferWarn"
			sg.IgnoreGuiInset = true
			sg.DisplayOrder = 200
			pcall(function() sg.Parent = game.CoreGui end)
			if not sg.Parent then sg.Parent = lp.PlayerGui end
			local t = Instance.new("TextLabel")
			t.Size = UDim2.new(0.7, 0, 0, 36)
			t.Position = UDim2.new(0.15, 0, 0.12, 0)
			t.BackgroundTransparency = 0.35
			t.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
			t.TextColor3 = Color3.fromRGB(255, 60, 60)
			t.Font = Enum.Font.GothamBold
			t.TextSize = 16
			t.Text = "You must have BKIT for Griefer moveset"
			t.Parent = sg
			Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
			for i = 1, 20 do
				t.TextTransparency = i / 20
				t.BackgroundTransparency = 0.35 + i * 0.03
				task.wait(0.08)
			end
			sg:Destroy()
		end)
	end
	local function hasBkit()
		return (typeof(hasToolInInventory) == "function" and (hasToolInInventory("Build") or hasToolInInventory("Delete") or hasToolInInventory("Paint")))
			or (lp.Backpack and (lp.Backpack:FindFirstChild("Build") or lp.Backpack:FindFirstChild("Delete")))
			or (lp.Character and (lp.Character:FindFirstChild("Build") or lp.Character:FindFirstChild("Delete")))
	end
	local function ensureDeleteReady()
		pcall(function()
			local tool = nil
			if typeof(findToolAny) == "function" then
				tool = findToolAny("Delete")
			end
			if not tool then
				local bag = lp.Backpack
				local char = lp.Character
				tool = (bag and bag:FindFirstChild("Delete")) or (char and char:FindFirstChild("Delete"))
			end
			if tool and tool:IsA("Tool") then
				local char = lp.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if char and tool.Parent ~= char then
					pcall(function() tool.Parent = char end)
				end
				pcall(function() if hum then hum:EquipTool(tool) end end)
			end
			if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
			if typeof(refreshToolBypass) == "function" then refreshToolBypass("Delete") end
			pcall(function()
				local bag = lp.Backpack
				local char = lp.Character
				local t = (char and char:FindFirstChild("Delete")) or (bag and bag:FindFirstChild("Delete"))
				if t and char and t.Parent ~= char then t.Parent = char end
			end)
			if typeof(refreshDeleteCache) == "function" then refreshDeleteCache() end
		end)
	end
	local function deleteAhead(dist)
		ensureDeleteReady()
		pcall(function()
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not my then return end
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {lp.Character}
			params.FilterType = Enum.RaycastFilterType.Exclude
			local look = my.CFrame.LookVector
			local hit = workspace:Raycast(my.Position, look * (dist or 8), params)
			if hit and hit.Instance and hit.Instance:IsA("BasePart") then
				local part = hit.Instance
				if part.Parent and workspace:FindFirstChild("Bricks") and part:IsDescendantOf(workspace.Bricks) then
					if typeof(fireDelete) == "function" then fireDelete(part) end
				end
			end
			local bricks = workspace:FindFirstChild("Bricks")
			if bricks and typeof(fireDeleteBurst) == "function" then
				local bag = {}
				for _, v in pairs(bricks:GetChildren()) do
					if v:IsA("BasePart") then
						local to = v.Position - my.Position
						if to.Magnitude < 10 and to.Unit:Dot(look) > 0.35 then
							bag[#bag + 1] = v
							if #bag >= 12 then break end
						end
					end
				end
				if #bag > 0 then fireDeleteBurst(bag) end
			end
		end)
	end
	local function deleteAuraPulse(range)
		ensureDeleteReady()
		pcall(function()
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not my then return end
			local bricks = workspace:FindFirstChild("Bricks")
			if not bricks then return end
			local bag = {}
			for _, v in pairs(bricks:GetDescendants()) do
				if v:IsA("BasePart") and (v.Position - my.Position).Magnitude <= (range or 30) then
					bag[#bag + 1] = v
					if #bag >= 40 then break end
				end
			end
			if #bag > 0 then
				if typeof(fireDeleteBurst) == "function" then fireDeleteBurst(bag)
				elseif typeof(fireDelete) == "function" then
					for i = 1, #bag do fireDelete(bag[i]) end
				end
			end
		end)
	end
	local function softAntiToxify(seconds)
		getgenv()._tcoCmdStates = getgenv()._tcoCmdStates or {}
		getgenv()._tcoCmdStates.antiToxify = true
		task.delay(seconds or 5, function()
			if getgenv()._tcoCmdStates then getgenv()._tcoCmdStates.antiToxify = false end
		end)
	end
	local function castMadness()
		if busy then return end
		busy = true
		task.spawn(function()
			if not hasBkit() then busy = false return end
			ensureDeleteReady()
			abilityTrack = loadAnim(MADNESS_ID, true, Enum.AnimationPriority.Action4)
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			local t0 = tick()
			while tick() - t0 < 5 and on do
				pcall(function()
					hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
					local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
					if hum then hum.WalkSpeed = 50 end
					if my then
						local look = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector or my.CFrame.LookVector
						local flat = Vector3.new(look.X, 0, look.Z)
						if flat.Magnitude > 0.05 then
							flat = flat.Unit
							my.AssemblyLinearVelocity = flat * 50 + Vector3.new(0, my.AssemblyLinearVelocity.Y, 0)
						end
					end
					deleteAhead(10)
				end)
				task.wait(0.05)
			end
			pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
			pcall(function() if hum then hum.WalkSpeed = 16 end end)
			busy = false
		end)
	end
	local function castScream()
		if busy then return end
		busy = true
		task.spawn(function()
			if not hasBkit() then busy = false return end
			ensureDeleteReady()
			abilityTrack = loadAnim(SCREAM_ID, true, Enum.AnimationPriority.Action4)
			local t0 = tick()
			while tick() - t0 < 3 and on do
				deleteAuraPulse(32)
				task.wait(0.12)
			end
			pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
			busy = false
		end)
	end
	local function castPunch()
		if busy then return end
		busy = true
		task.spawn(function()
			if not hasBkit() then busy = false return end
			pcall(function()
				if typeof(refreshToolBypass) == "function" then
					refreshToolBypass("Build"); refreshToolBypass("Paint"); refreshToolBypass("Delete")
				end
			end)
			softAntiToxify(6)
			abilityTrack = loadAnim(PUNCH_ID, false, Enum.AnimationPriority.Action4)
			local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not my then busy = false return end
			local look = my.CFrame.LookVector
			local base = my.Position + look * 4 + Vector3.new(0, 1, 0)
			local placed = {}
			for i = 1, 5 do
				local pos = base + look * ((i - 1) * 1.1)
				pcall(function() if typeof(fireBuildAt) == "function" then fireBuildAt(pos, "tiny") end end)
				task.wait(0.08)
			end
			task.wait(0.25)
			pcall(function()
				local bricks = workspace:FindFirstChild("Bricks")
				if not bricks then return end
				for _, v in pairs(bricks:GetDescendants()) do
					if v:IsA("BasePart") and (v.Position - base).Magnitude < 8 then
						if typeof(firePaintPart) == "function" then firePaintPart(v, "toxic", Color3.fromRGB(0, 255, 0)) end
						placed[#placed + 1] = v
					end
				end
			end)
			task.wait(2)
			if #placed > 0 then
				if typeof(fireDeleteBurst) == "function" then fireDeleteBurst(placed)
				elseif typeof(fireDelete) == "function" then
					for _, p in ipairs(placed) do fireDelete(p) end
				end
			end
			pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
			busy = false
		end)
	end
	local function castFinal()
		if busy then return end
		busy = true
		task.spawn(function()
			if not hasBkit() then busy = false return end
			pcall(function() if typeof(refreshToolBypass) == "function" then refreshToolBypass("Delete") end end)
			abilityTrack = loadAnim(RISE_ID, true, Enum.AnimationPriority.Action4)
			local tRise = tick()
			while tick() - tRise < 1.2 do
				pcall(function()
					local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
					if my then
						my.CFrame = my.CFrame + Vector3.new(0, 1.2, 0)
						my.AssemblyLinearVelocity = Vector3.new(0, 12, 0)
					end
				end)
				task.wait()
			end
			pcall(function() if abilityTrack then abilityTrack:Stop(0.05) end end)
			abilityTrack = loadAnim(FINAL_ID, true, Enum.AnimationPriority.Action4)
			ensureDeleteReady()
			local t0 = tick()
			while tick() - t0 < 10 and on do
				deleteAuraPulse(80)
				pcall(function()
					local my = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
					if my then my.AssemblyLinearVelocity = Vector3.new(0, 2, 0) end
				end)
				task.wait(0.1)
			end
			pcall(function() if abilityTrack then abilityTrack:Stop(0.1) end end)
			busy = false
		end)
	end
	function tcoGrieferCast(which)
		which = tostring(which or ""):lower()
		if which == "madness" or which == "1" then castMadness()
		elseif which == "scream" or which == "2" then castScream()
		elseif which == "punch" or which == "3" then castPunch()
		elseif which == "final" or which == "finalgrief" or which == "4" then castFinal()
		end
	end
	getgenv().tcoGrieferCast = tcoGrieferCast
	local function destroyGui()
		if abilityGui then pcall(function() abilityGui:Destroy() end) end
		abilityGui = nil
		local old = game.CoreGui:FindFirstChild("TCOGrieferAbilities")
		if old then old:Destroy() end
	end
	local function makeGui()
		destroyGui()
		local isMobile = UIS.TouchEnabled == true
		local hasKeyboard = UIS.KeyboardEnabled == true
		local btnSize = (isMobile and not hasKeyboard) and 42 or 58
		local sg = Instance.new("ScreenGui")
		sg.Name = "TCOGrieferAbilities"
		sg.ResetOnSpawn = false
		sg.DisplayOrder = 82
		sg.IgnoreGuiInset = true
		pcall(function() sg.Parent = game.CoreGui end)
		if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end
		abilityGui = sg
		local center = Instance.new("Frame")
		center.BackgroundTransparency = 1
		center.AnchorPoint = Vector2.new(1, 1)
		center.Position = UDim2.new(1, -8, 1, -145)
		center.Size = UDim2.new(0, (btnSize + 6) * 4 + 8, 0, btnSize + 28)
		center.Parent = sg
		local lay = Instance.new("UIListLayout")
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.Padding = UDim.new(0, 6)
		lay.Parent = center
		local names = {"Griefing Runner", "Griefer Scream", "Block Punch", "Final Grief"}
		local keys = {"madness", "scream", "punch", "final"}
		for i = 1, 4 do
			local slot = Instance.new("Frame")
			slot.Size = UDim2.new(0, btnSize + 4, 0, btnSize + 24)
			slot.BackgroundTransparency = 1
			slot.LayoutOrder = i
			slot.Parent = center
			local nameL = Instance.new("TextLabel")
			nameL.Size = UDim2.new(1, 4, 0, 12)
			nameL.BackgroundTransparency = 1
			nameL.Text = names[i]
			nameL.TextColor3 = Color3.fromRGB(255, 180, 180)
			nameL.TextSize = 8
			nameL.Font = Enum.Font.GothamBold
			nameL.Parent = slot
			local btn = Instance.new("ImageButton")
			btn.Size = UDim2.new(0, btnSize, 0, btnSize)
			btn.Position = UDim2.new(0.5, 0, 0, 13)
			btn.AnchorPoint = Vector2.new(0.5, 0)
			btn.BackgroundColor3 = Color3.fromRGB(28, 12, 12)
			btn.Image = LOGOS[keys[i]]
			btn.ScaleType = Enum.ScaleType.Fit
			btn.Parent = slot
			Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(220, 60, 60)
			stroke.Thickness = 2
			stroke.Parent = btn
			local keyL = Instance.new("TextLabel")
			keyL.Size = UDim2.new(1, 0, 0, 12)
			keyL.Position = UDim2.new(0, 0, 1, -12)
			keyL.BackgroundTransparency = 1
			keyL.Text = tostring(i)
			keyL.TextColor3 = Color3.new(1, 1, 1)
			keyL.TextSize = 11
			keyL.Font = Enum.Font.GothamBold
			keyL.Parent = btn
			btn.MouseButton1Click:Connect(function() tcoGrieferCast(keys[i]) end)
		end
	end
	function tcoGrieferSetEnabled(enabled)
		on = enabled and true or false
		getgenv()._tcoGrieferOn = on
		if not on then
			busy = false
			stopTracks()
			destroyGui()
			setFov(baseFov)
			if inputConn then pcall(function() inputConn:Disconnect() end) inputConn = nil end
			pcall(function()
				local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = 16 end
			end)
			return
		end
		warnBkit()
		makeGui()
		pcall(function()
			local cam = workspace.CurrentCamera
			if cam then baseFov = cam.FieldOfView end
		end)
		idleTrack = loadAnim(IDLE_ID, true, Enum.AnimationPriority.Idle)
		buildUp = 0
		task.spawn(function()
			local wasMoving = false
			while on do
				pcall(function()
					if busy then return end
					local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
					local moving = hum and hum.MoveDirection.Magnitude > 0.08
					if moving then
						buildUp = math.clamp(buildUp + 0.015, 0, 1)
						local spd = 16 + (maxSpeed - 16) * buildUp
						hum.WalkSpeed = spd
						setFov(baseFov + 22 * buildUp)
						if buildUp > 0.55 then
							if not runTrack then
								pcall(function() if walkTrack then walkTrack:Stop(0.1) end end)
								pcall(function() if idleTrack then idleTrack:Stop(0.1) end end)
								runTrack = loadAnim(RUN_ID, true, Enum.AnimationPriority.Movement)
								walkTrack = nil
							end
						else
							if not walkTrack then
								pcall(function() if runTrack then runTrack:Stop(0.1) end end)
								pcall(function() if idleTrack then idleTrack:Stop(0.1) end end)
								walkTrack = loadAnim(WALK_ID, true, Enum.AnimationPriority.Movement)
								runTrack = nil
							end
						end
						wasMoving = true
					else
						buildUp = math.clamp(buildUp - 0.025, 0, 1)
						if hum then hum.WalkSpeed = 16 end
						setFov(baseFov + 8 * buildUp)
						if wasMoving or not idleTrack then
							pcall(function() if walkTrack then walkTrack:Stop(0.1) end end)
							pcall(function() if runTrack then runTrack:Stop(0.1) end end)
							walkTrack, runTrack = nil, nil
							idleTrack = loadAnim(IDLE_ID, true, Enum.AnimationPriority.Idle)
						end
						wasMoving = false
					end
				end)
				task.wait(0.04)
			end
		end)
		if inputConn then pcall(function() inputConn:Disconnect() end) end
		inputConn = UIS.InputBegan:Connect(function(inp, gp)
			if gp or not on then return end
			local map = {
				[Enum.KeyCode.One] = "madness",
				[Enum.KeyCode.Two] = "scream",
				[Enum.KeyCode.Three] = "punch",
				[Enum.KeyCode.Four] = "final",
			}
			local w = map[inp.KeyCode]
			if w then tcoGrieferCast(w) end
		end)
	end
	getgenv().tcoGrieferSetEnabled = tcoGrieferSetEnabled
	if getgenv()._tcoGrieferPending then
		getgenv()._tcoGrieferPending = nil
		tcoGrieferSetEnabled(true)
	end
end
if not success then warn("[TCO]", err) print(err,"TCOExtrasError") end
