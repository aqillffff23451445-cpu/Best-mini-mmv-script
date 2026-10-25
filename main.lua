--приветик бро! Этот код без вирусов и полностью бесплатный! Пользуйся на здоровье<3
--[[
	MMV Admin Panel | Gemini Ai & ChatGPT Integration
	Version 5.19 (Full Script + Multi-Touch Dragging + Fixed ESP Box/Line/Name + Knife Visibility Fix)
]]

if getgenv().MMV_AdminPanel_Running then
	getgenv().MMV_AdminPanel_Running = false
	task.wait(0.4)
end
getgenv().MMV_AdminPanel_Running = true

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ====================== КОНФИГ ======================
local Config = {
	ESP = {
		Enabled = false,
		Chams = false,
		Name = false,
		Role = false,
		Line = false,
		Box = false,
		Gun = false,
		Trap = false,
	},
	Colors = {
		Murder = {color = Color3.fromRGB(255, 40, 40), trans = 0, rainbow = false},
		Sheriff = {color = Color3.fromRGB(40, 100, 255), trans = 0, rainbow = false},
		Innocent = {color = Color3.fromRGB(40, 255, 80), trans = 0, rainbow = false},
		Gun = {color = Color3.fromRGB(255, 255, 0), trans = 0, rainbow = false},
		Trap = {color = Color3.fromRGB(255, 140, 0), trans = 0, rainbow = false},
	},
	Combat = {
		AutoGun = false,
		AutoShot = false,
		AutoKill = false,
		AutoThrow = false,
	},
	Fling = {
		Active = false,
	},
	Exploits = {
		StealthActive = false,
		LastTrapPlaced = 0,
	}
}

local DrawingLib = Drawing or (getgenv and getgenv().Drawing)
local HasDrawing = DrawingLib ~= nil

-- ====================== GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MMV_AdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Умное перетаскивание с поддержкой Multi-Touch (фикс джойстика)
local function MakeDraggable(guiObject)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	guiObject.Active = true

	guiObject.InputBegan:Connect(function(input)
		local isTouch = input.UserInputType == Enum.UserInputType.Touch
		local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1

		if dragging or not (isTouch or isMouse) then
			return
		end

		dragging = true
		dragInput = isTouch and input or nil
		dragStart = input.Position
		startPos = guiObject.Position
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		local isOurTouch = dragInput ~= nil and input == dragInput
		local isMouseMove = dragInput == nil
			and input.UserInputType == Enum.UserInputType.MouseMovement

		if not isOurTouch and not isMouseMove then
			return
		end

		local delta = input.Position - dragStart

		guiObject.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)

	UserInputService.InputEnded:Connect(function(input)
		local isOurTouch = dragInput ~= nil and input == dragInput
		local isOurMouse = dragInput == nil
			and input.UserInputType == Enum.UserInputType.MouseButton1

		if dragging and (isOurTouch or isOurMouse) then
			dragging = false
			dragInput = nil
			dragStart = nil
			startPos = nil
		end
	end)
end

----------------------------------------------------------------
-- 1. Diamond (Радужный ромб - Иконка открытия)
----------------------------------------------------------------
local ToggleIcon = Instance.new("ImageButton")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.new(0, 54, 0, 54)
ToggleIcon.Position = UDim2.new(0.5, -27, 0, 16)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleIcon.BorderSizePixel = 0
ToggleIcon.Image = "rbxassetid://96009357671193"
ToggleIcon.ScaleType = Enum.ScaleType.Fit
ToggleIcon.ZIndex = 10
ToggleIcon.Parent = ScreenGui
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(1, 0)

local ts = Instance.new("UIStroke")
ts.Color = Color3.fromRGB(0, 0, 0)
ts.Thickness = 2
ts.Parent = ToggleIcon
MakeDraggable(ToggleIcon)

----------------------------------------------------------------
-- Главное окно
----------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MakeDraggable(MainFrame)

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(0, 0, 0)
ms.Thickness = 4
ms.Parent = MainFrame

----------------------------------------------------------------
-- 2. Suitman (Фоновое изображение)
----------------------------------------------------------------
local BgImage = Instance.new("ImageLabel")
BgImage.Name = "BgImage"
BgImage.Size = UDim2.new(1, -120, 1, -46)
BgImage.Position = UDim2.new(0, 120, 0, 46)
BgImage.BackgroundTransparency = 1
BgImage.Image = "rbxassetid://89300103502292"
BgImage.ImageTransparency = 0.52
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 1
BgImage.Parent = MainFrame

task.spawn(function()
	pcall(function()
		ContentProvider:PreloadAsync({ToggleIcon, BgImage})
	end)
end)

local menuVisible = true
ToggleIcon.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	MainFrame.Visible = menuVisible
end)

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 260, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Mmv Script | Gemini Ai"
Title.TextColor3 = Color3.fromRGB(235, 235, 235)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = TopBar

-- Search
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 130, 0, 30)
SearchBox.Position = UDim2.new(1, -145, 0.5, -15)
SearchBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search... 🔍"
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
SearchBox.TextSize = 13
SearchBox.Font = Enum.Font.GothamBold
SearchBox.ZIndex = 4
SearchBox.Parent = TopBar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

-- Sidebar + Content
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -120, 1, -46)
Content.Position = UDim2.new(0, 120, 0, 46)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = MainFrame

local Tabs = {}
local TabNames = {"Fling", "Esp", "Combat", "Info"}
local CurrentTab = "Fling"

for _, name in ipairs(TabNames) do
	local frame = Instance.new("ScrollingFrame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ScrollBarThickness = 4
	frame.CanvasSize = UDim2.new(0, 0, 0, 480)
	frame.Visible = (name == "Fling")
	frame.ZIndex = 3
	frame.Parent = Content
	Tabs[name] = frame
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = SearchBox.Text:lower()
	local activeTab = Tabs[CurrentTab]
	for _, child in ipairs(activeTab:GetChildren()) do
		if child:IsA("GuiObject") then
			local searchableText = (child.Name .. " " .. (child:IsA("TextButton") and child.Text or "")):lower()
			if query == "" or searchableText:find(query) then
				child.Visible = true
			else
				child.Visible = false
			end
		end
	end
end)

local NavButtons = {}
for i, name in ipairs(TabNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -14, 0, 40)
	btn.Position = UDim2.new(0, 7, 0, 14 + (i-1)*50)
	btn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	btn.Text = name
	btn.TextColor3 = (name == "Fling") and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(210, 210, 210)
	btn.TextSize = 16
	btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 4
	btn.Parent = Sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	NavButtons[name] = btn

	btn.MouseButton1Click:Connect(function()
		CurrentTab = name
		SearchBox.Text = ""
		for n, f in pairs(Tabs) do f.Visible = (n == name) end
		for n, b in pairs(NavButtons) do
			b.TextColor3 = (n == name) and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(210, 210, 210)
		end
	end)
end

-- ====================== РОЛИ И ЦВЕТА ======================
local RoleCache = {}
local LastRoleCheck = 0

local function GetRoleColor(roleName)
	local conf = Config.Colors[roleName]
	if not conf then return Color3.new(1,1,1) end
	if conf.rainbow then
		return Color3.fromHSV(tick() % 5 / 5, 1, 1)
	end
	return conf.color
end

local function GetPlayerRole(player)
	if tick() - LastRoleCheck > 1.2 then
		LastRoleCheck = tick()
		local ok, data = pcall(function()
			return ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
		end)
		if ok and type(data) == "table" then RoleCache = data end
	end

	if RoleCache[player.Name] then
		local role = tostring(RoleCache[player.Name].Role or RoleCache[player.Name].Team or ""):lower()
		if role:find("murder") or role:find("killer") then return "Murder", GetRoleColor("Murder") end
		if role:find("sheriff") then return "Sheriff", GetRoleColor("Sheriff") end
		if role:find("innocent") then return "Innocent", GetRoleColor("Innocent") end
	end

	local char, backpack = player.Character, player:FindFirstChild("Backpack")
	local hasKnife, hasGun = false, false
	for _, cont in ipairs({char, backpack}) do
		if cont then
			for _, item in ipairs(cont:GetChildren()) do
				if item:FindFirstChild("IsKnife") or item.Name:lower():find("knife") then hasKnife = true end
				if item:FindFirstChild("IsGun") or item.Name:lower():find("gun") then hasGun = true end
			end
		end
	end
	if hasKnife then return "Murder", GetRoleColor("Murder") end
	if hasGun then return "Sheriff", GetRoleColor("Sheriff") end
	return "Innocent", GetRoleColor("Innocent")
end

local function HasGun()
	local char = LocalPlayer.Character
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	for _, cont in ipairs({char, backpack}) do
		if cont then
			for _, item in ipairs(cont:GetChildren()) do
				if item:FindFirstChild("IsGun") or item.Name:lower():find("gun") then
					return true, item
				end
			end
		end
	end
	return false, nil
end

_G.GetPlayerRole = GetPlayerRole

-- ====================== ESP ======================
local Highlights = {}
local Billboards = {}
local Lines = {}
local Boxes = {}
local ItemHighlights = {}
local ItemBillboards = {}

local function RemovePlayerESP(player)
	if Highlights[player] then pcall(function() Highlights[player]:Destroy() end) Highlights[player] = nil end
	if Billboards[player] then pcall(function() Billboards[player]:Destroy() end) Billboards[player] = nil end
	if Lines[player] then pcall(function() Lines[player]:Remove() end) Lines[player] = nil end
	if Boxes[player] then pcall(function() Boxes[player]:Remove() end) Boxes[player] = nil end
end

local function ClearAllItemESP()
	for obj, hl in pairs(ItemHighlights) do pcall(function() hl:Destroy() end) end
	for obj, bb in pairs(ItemBillboards) do pcall(function() bb:Destroy() end) end
	ItemHighlights, ItemBillboards = {}, {}
end

local function ClearAllESP()
	for player, _ in pairs(Highlights) do RemovePlayerESP(player) end
	for player, _ in pairs(Lines) do if Lines[player] then pcall(function() Lines[player]:Remove() end) Lines[player] = nil end end
	for player, _ in pairs(Boxes) do if Boxes[player] then pcall(function() Boxes[player]:Remove() end) Boxes[player] = nil end end
	ClearAllItemESP()
end

local function UpdateESP()
	if not Config.ESP.Enabled then
		ClearAllESP()
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local char = player.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			local head = char:FindFirstChild("Head")
			local hum = char:FindFirstChildOfClass("Humanoid")

			if root and head and hum and hum.Health > 0 then
				local role, color = GetRoleColor(player)

				if Config.ESP.Chams then
					local hl = Highlights[player]
					if not hl or not hl.Parent or hl.Parent ~= char then
						if hl then pcall(function() hl:Destroy() end) end
						hl = Instance.new("Highlight")
						hl.FillTransparency = 0.55
						hl.OutlineTransparency = 0.2
						hl.Parent = char
						Highlights[player] = hl
					end
					hl.Adornee = char
					hl.FillColor = color
					hl.OutlineColor = color
					hl.Enabled = true
				elseif Highlights[player] then
					Highlights[player].Enabled = false
				end

				if Config.ESP.Name or Config.ESP.Role then
					local bb = Billboards[player]
					if not bb or not bb.Parent or bb.Parent ~= char then
						if bb then pcall(function() bb:Destroy() end) end
						bb = Instance.new("BillboardGui")
						bb.Name = "MMV_ESP_Name"
						bb.Size = UDim2.new(0, 150, 0, 42)
						bb.StudsOffset = Vector3.new(0, 2.9, 0)
						bb.AlwaysOnTop = true
						bb.Adornee = head
						local lbl = Instance.new("TextLabel")
						lbl.Name = "Label"
						lbl.Size = UDim2.new(1, 0, 1, 0)
						lbl.BackgroundTransparency = 1
						lbl.TextSize = 14
						lbl.Font = Enum.Font.GothamBold
						lbl.TextStrokeTransparency = 0.25
						lbl.Parent = bb
						bb.Parent = char
						Billboards[player] = bb
					end
					local text = ""
					if Config.ESP.Name then text = player.Name end
					if Config.ESP.Role then text = text .. (text ~= "" and "\n" or "") .. role end
					bb.Enabled = true
					local lbl = bb:FindFirstChild("Label")
					if lbl then
						lbl.Text = text
						lbl.TextColor3 = color
					end
				elseif Billboards[player] then
					Billboards[player].Enabled = false
				end
			else
				RemovePlayerESP(player)
			end
		else
			RemovePlayerESP(player)
		end
	end

	local validObjects = {}
	for _, obj in ipairs(workspace:GetChildren()) do
		pcall(function()
			local nameLower = obj.Name:lower()
			if not nameLower:find("strap") then
				if Config.ESP.Gun and (nameLower == "gundrop" or nameLower == "gun") then
					validObjects[obj] = {text = "GUN DROP", color = GetRoleColor("Gun")}
				elseif Config.ESP.Trap and (nameLower == "trap" or nameLower:find("trap")) then
					validObjects[obj] = {text = "TRAP", color = GetRoleColor("Trap")}
				end
			end
		end)
	end

	for obj, info in pairs(validObjects) do
		pcall(function()
			local hl = ItemHighlights[obj]
			if not hl or not hl.Parent then
				hl = Instance.new("Highlight")
				hl.FillTransparency = 0.3
				hl.OutlineTransparency = 0.1
				hl.Parent = obj
				ItemHighlights[obj] = hl
			end
			hl.FillColor = info.color
			hl.OutlineColor = info.color
			hl.Enabled = true

			local bb = ItemBillboards[obj]
			if not bb or not bb.Parent then
				bb = Instance.new("BillboardGui")
				bb.Size = UDim2.new(0, 100, 0, 30)
				bb.StudsOffset = Vector3.new(0, 1.8, 0)
				bb.AlwaysOnTop = true
				bb.Adornee = obj
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = info.text
				lbl.TextSize = 13
				lbl.Font = Enum.Font.GothamBold
				lbl.TextStrokeTransparency = 0.2
				lbl.Parent = bb
				bb.Parent = obj
				ItemBillboards[obj] = bb
			end
			bb.Enabled = true
		end)
	end

	for obj, hl in pairs(ItemHighlights) do
		if not validObjects[obj] then pcall(function() hl:Destroy() end) ItemHighlights[obj] = nil end
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() RemovePlayerESP(p) end)
end)
Players.PlayerRemoving:Connect(RemovePlayerESP)

if HasDrawing then
	RunService.RenderStepped:Connect(function()
		if not getgenv().MMV_AdminPanel_Running or not Config.ESP.Enabled then
			for player, _ in pairs(Lines) do if Lines[player] then Lines[player].Visible = false end end
			for player, _ in pairs(Boxes) do if Boxes[player] then Boxes[player].Visible = false end end
			return
		end

		local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 8)

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local char = player.Character
				local root = char.HumanoidRootPart
				local hum = char:FindFirstChildOfClass("Humanoid")

				if hum and hum.Health > 0 then
					local role, color = GetRoleColor(player)
					local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

					if onScreen and pos.Z > 0 then
						if Config.ESP.Line then
							local line = Lines[player]
							if not line then
								line = DrawingLib.new("Line")
								line.Thickness = 2
								Lines[player] = line
							end
							line.From = screenBottom
							line.To = Vector2.new(pos.X, pos.Y)
							line.Color = color
							line.Visible = true
						elseif Lines[player] then Lines[player].Visible = false end

						if Config.ESP.Box then
							local box = Boxes[player]
							if not box then
								box = DrawingLib.new("Square")
								box.Thickness = 2
								box.Filled = false
								Boxes[player] = box
							end
							local scale = math.clamp(70 / (pos.Z * 0.09), 28, 95)
							box.Size = Vector2.new(scale * 0.72, scale)
							box.Position = Vector2.new(pos.X - scale * 0.36, pos.Y - scale * 0.5)
							box.Color = color
							box.Visible = true
						elseif Boxes[player] then Boxes[player].Visible = false end
					else
						if Lines[player] then Lines[player].Visible = false end
						if Boxes[player] then Boxes[player].Visible = false end
					end
				else
					if Lines[player] then Lines[player].Visible = false end
					if Boxes[player] then Boxes[player].Visible = false end
				end
			else
				if Lines[player] then Lines[player].Visible = false end
				if Boxes[player] then Boxes[player].Visible = false end
			end
		end
	end)
end

-- ====================== COLOR PICKER ======================
local ColorPane = Instance.new("Frame")
ColorPane.Name = "ColorPane"
ColorPane.Size = UDim2.new(0, 210, 0, 260)
ColorPane.Position = UDim2.new(1, 10, 0, 0)
ColorPane.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
ColorPane.Visible = false
ColorPane.ZIndex = 20
ColorPane.Parent = MainFrame
Instance.new("UICorner", ColorPane).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", ColorPane).Color = Color3.fromRGB(60, 60, 60)

local current_key = nil
local SV_Canvas = Instance.new("Frame", ColorPane)
SV_Canvas.Size = UDim2.new(0, 150, 0, 150)
SV_Canvas.Position = UDim2.new(0, 12, 0, 12)
SV_Canvas.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SV_Canvas.ZIndex = 21
Instance.new("UICorner", SV_Canvas).CornerRadius = UDim.new(0, 4)

local sat_grad = Instance.new("Frame", SV_Canvas)
sat_grad.Size = UDim2.new(1, 0, 1, 0)
sat_grad.ZIndex = 21
local sg = Instance.new("UIGradient", sat_grad)
sg.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}

local val_grad = Instance.new("Frame", SV_Canvas)
val_grad.Size = UDim2.new(1, 0, 1, 0)
val_grad.ZIndex = 21
local vg = Instance.new("UIGradient", val_grad)
vg.Rotation = 90
vg.Color = ColorSequence.new(Color3.new(0, 0, 0))
vg.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}

local Pointer = Instance.new("Frame", SV_Canvas)
Pointer.Size = UDim2.new(0, 10, 0, 10)
Pointer.AnchorPoint = Vector2.new(0.5, 0.5)
Pointer.BackgroundColor3 = Color3.new(1, 1, 1)
Pointer.ZIndex = 25
Instance.new("UICorner", Pointer).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Pointer)

local Hue_Rail = Instance.new("Frame", ColorPane)
Hue_Rail.Size = UDim2.new(0, 18, 0, 150)
Hue_Rail.Position = UDim2.new(0, 172, 0, 12)
Hue_Rail.ZIndex = 21
Instance.new("UICorner", Hue_Rail).CornerRadius = UDim.new(0, 4)
local hg = Instance.new("UIGradient", Hue_Rail)
hg.Rotation = 90
hg.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
})

local RainbowToggle = Instance.new("TextButton", ColorPane)
RainbowToggle.Size = UDim2.new(0, 186, 0, 28)
RainbowToggle.Position = UDim2.new(0, 12, 0, 175)
RainbowToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RainbowToggle.Text = "RAINBOW: OFF"
RainbowToggle.TextColor3 = Color3.new(1, 1, 1)
RainbowToggle.Font = Enum.Font.GothamBold
RainbowToggle.TextSize = 13
RainbowToggle.ZIndex = 22
Instance.new("UICorner", RainbowToggle).CornerRadius = UDim.new(0, 5)

local function update_pkr()
	if not current_key then return end
	local conf = Config.Colors[current_key]
	local h, s, v = conf.color:ToHSV()
	SV_Canvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	Pointer.Position = UDim2.new(s, 0, 1 - v, 0)
	RainbowToggle.Text = "RAINBOW: " .. (conf.rainbow and "ON" or "OFF")
	RainbowToggle.TextColor3 = conf.rainbow and Color3.fromRGB(0, 255, 140) or Color3.new(1, 1, 1)
end

RainbowToggle.MouseButton1Click:Connect(function()
	if current_key then
		Config.Colors[current_key].rainbow = not Config.Colors[current_key].rainbow
		update_pkr()
	end
end)

local function hook_input(frame, callback)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local conn
			conn = RunService.RenderStepped:Connect(function()
				local mouse = UserInputService:GetMouseLocation()
				local inset = GuiService:GetGuiInset()
				local relX = math.clamp((mouse.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
				local relY = math.clamp((mouse.Y - inset.Y - frame.AbsolutePosition.Y) / frame.AbsoluteSize.Y, 0, 1)
				callback(relX, relY)
				update_pkr()
				if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) then
					conn:Disconnect()
				end
			end)
		end
	end)
end

hook_input(SV_Canvas, function(x, y)
	if not current_key then return end
	local h = Config.Colors[current_key].color:ToHSV()
	Config.Colors[current_key].color = Color3.fromHSV(h, x, 1 - y)
end)

hook_input(Hue_Rail, function(x, y)
	if not current_key then return end
	local _, s, v = Config.Colors[current_key].color:ToHSV()
	Config.Colors[current_key].color = Color3.fromHSV(y, s, v)
end)

-- ====================== COMBAT & EXPLOITS ======================
local isFiring = false

local function PickUpGun()
	local gunDrop = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun")
	if not gunDrop then return end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local target = gunDrop:IsA("Model") and (gunDrop.PrimaryPart or gunDrop:FindFirstChildWhichIsA("BasePart")) or gunDrop
	if target and target:IsA("BasePart") then
		pcall(function()
			firetouchinterest(hrp, target, 0)
			task.wait()
			firetouchinterest(hrp, target, 1)
		end)
	end
end

local function ShotMurder()
	if isFiring then return end
	local has, tool = HasGun()
	if not has or not tool then return end
	local remote = tool:FindFirstChild("KnifeServer") and tool.KnifeServer:FindFirstChild("SlashStart")
	if not remote then return end
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if GetPlayerRole(player) == "Murder" then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				local head = player.Character:FindFirstChild("Head")
				if hrp then
					isFiring = true
					local targetPos = head and head.Position or hrp.Position
					pcall(function() remote:FireServer(1, targetPos) end)
					task.wait(0.1)
					isFiring = false
					break
				end
			end
		end
	end
end

local function KillMurder()
	if isFiring then return end
	local has, tool = HasGun()
	if not has or not tool then return end
	local remote = tool:FindFirstChild("KnifeServer") and tool.KnifeServer:FindFirstChild("SlashStart")
	if not remote then return end
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if GetPlayerRole(player) == "Murder" then
				local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
				local head = player.Character:FindFirstChild("Head")
				if targetHRP then
					isFiring = true
					myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 4.2)
					task.wait(0.04)
					local targetPos = head and head.Position or targetHRP.Position
					pcall(function() remote:FireServer(1, targetPos) end)
					task.wait(0.1)
					isFiring = false
					break
				end
			end
		end
	end
end

local function ThrowKnifeAtNearest()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local knife = char and char:FindFirstChild("Knife")
	if not hrp or not knife then return end

	local remote = knife:FindFirstChild("KnifeServer") and knife.KnifeServer:FindFirstChild("FlingKnifeEvent")
	local handle = knife:FindFirstChild("Handle")
	if not remote or not handle then return end

	local nearestDist = math.huge
	local targetHRP = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
			local hum = player.Character:FindFirstChild("Humanoid")
			if tHRP and hum and hum.Health > 0 then
				local dist = (tHRP.Position - hrp.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					targetHRP = tHRP
				end
			end
		end
	end

	if targetHRP then
		pcall(function()
			remote:FireServer(CFrame.new(targetHRP.Position), handle.Position)
		end)
	end
end

local function SpamPlaceTrap()
	if tick() - Config.Exploits.LastTrapPlaced < 2.5 then return end
	Config.Exploits.LastTrapPlaced = tick()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local trapRemote = ReplicatedStorage:FindFirstChild("TrapSystem") and ReplicatedStorage.TrapSystem:FindFirstChild("PlaceTrap")
	if trapRemote then
		pcall(function()
			trapRemote:FireServer(hrp.CFrame)
		end)
	end
end

-- ====================== КНОПКИ ДЕЙСТВИЙ ======================
local ActionButtons = {}
local function CreateActionScreenButton(name, text, defaultPos, actionFunc)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 155, 0, 40)
	btn.Position = defaultPos
	btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(210, 210, 210)
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 12
	btn.Visible = false
	btn.Parent = ScreenGui
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(180, 180, 180)
	s.Thickness = 2
	s.Parent = btn

	MakeDraggable(btn)
	btn.Activated:Connect(actionFunc)
	ActionButtons[name] = btn
	return btn
end

CreateActionScreenButton("PickUpGunBtn", "PICK UP GUN", UDim2.new(1, -175, 0, 10), PickUpGun)
CreateActionScreenButton("ShotMurderBtn", "SHOT MURDER", UDim2.new(1, -175, 0, 56), ShotMurder)
CreateActionScreenButton("KillMurderBtn", "KILL MURDER", UDim2.new(1, -175, 0, 102), KillMurder)
CreateActionScreenButton("ThrowKnifeBtn", "THROW KNIFE", UDim2.new(1, -175, 0, 148), ThrowKnifeAtNearest)
CreateActionScreenButton("PlaceTrapBtn", "SPAM TRAP", UDim2.new(1, -175, 0, 194), SpamPlaceTrap)

-- ====================== FLING ======================
local SelectedTargets = {}

local function SkidFling(target)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = hum and hum.RootPart
	local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not (root and tRoot) then return end

	local old = root.CFrame
	local start = tick()
	local ang = 0
	while Config.Fling.Active and tick() - start < 1.2 do
		if not (root and tRoot) then break end
		ang = ang + 110
		root.CFrame = CFrame.new(tRoot.Position) * CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(ang), 0, 0)
		root.Velocity = Vector3.new(9e9, 9e9, 9e9)
		root.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
		RunService.Heartbeat:Wait()
	end
	if old then root.CFrame = old end
end

local function StartFling()
	if Config.Fling.Active then return end
	Config.Fling.Active = true
	task.spawn(function()
		while Config.Fling.Active do
			for _, plr in pairs(SelectedTargets) do
				if Config.Fling.Active and plr and plr.Character then
					SkidFling(plr)
					task.wait(0.05)
				end
			end
			task.wait(0.2)
		end
	end)
end
local function StopFling() Config.Fling.Active = false end

-- ====================== ВКЛАДКИ МЕНЮ ======================
local function BuildFlingTab()
	local tab = Tabs.Fling
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local y = 12
	SelectedTargets = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Name = player.Name
			btn.Size = UDim2.new(1, -20, 0, 34)
			btn.Position = UDim2.new(0, 10, 0, y)
			btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
			btn.Text = "  " .. player.Name
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.TextSize = 15
			btn.Font = Enum.Font.GothamBold
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.ZIndex = 4
			btn.Parent = tab
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

			local sel = Instance.new("TextLabel")
			sel.Size = UDim2.new(0, 90, 1, 0)
			sel.Position = UDim2.new(1, -95, 0, 0)
			sel.BackgroundTransparency = 1
			sel.Text = ""
			sel.TextColor3 = Color3.fromRGB(0, 255, 120)
			sel.TextSize = 14
			sel.Font = Enum.Font.GothamBold
			sel.TextXAlignment = Enum.TextXAlignment.Right
			sel.ZIndex = 5
			sel.Parent = btn

			btn.MouseButton1Click:Connect(function()
				if SelectedTargets[player] then
					SelectedTargets[player] = nil
					sel.Text = ""
					btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
				else
					SelectedTargets[player] = player
					sel.Text = "SELECT"
					btn.BackgroundColor3 = Color3.fromRGB(30, 70, 45)
				end
			end)
			y = y + 40
		end
	end

	local startBtn = Instance.new("TextButton")
	startBtn.Size = UDim2.new(0.46, 0, 0, 40)
	startBtn.Position = UDim2.new(0, 10, 0, y + 10)
	startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	startBtn.Text = "START FLING"
	startBtn.TextColor3 = Color3.new(1, 1, 1)
	startBtn.Font = Enum.Font.GothamBold
	startBtn.TextSize = 15
	startBtn.ZIndex = 4
	startBtn.Parent = tab
	Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)
	startBtn.MouseButton1Click:Connect(StartFling)

	local stopBtn = Instance.new("TextButton")
	stopBtn.Size = UDim2.new(0.46, 0, 0, 40)
	stopBtn.Position = UDim2.new(0.52, 0, 0, y + 10)
	stopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	stopBtn.Text = "STOP FLING"
	stopBtn.TextColor3 = Color3.new(1, 1, 1)
	stopBtn.Font = Enum.Font.GothamBold
	stopBtn.TextSize = 15
	stopBtn.ZIndex = 4
	stopBtn.Parent = tab
	Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)
	stopBtn.MouseButton1Click:Connect(StopFling)

	tab.CanvasSize = UDim2.new(0, 0, 0, y + 70)
end
BuildFlingTab()
Players.PlayerAdded:Connect(BuildFlingTab)
Players.PlayerRemoving:Connect(BuildFlingTab)

local function BuildEspTab()
	local tab = Tabs.Esp
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local y = 12

	local opts = {
		{n = "Chams esp", k = "Chams"},
		{n = "Name esp", k = "Name"},
		{n = "Role esp", k = "Role"},
		{n = "Line esp", k = "Line"},
		{n = "Box esp", k = "Box"},
		{n = "Gun esp", k = "Gun"},
		{n = "Trap esp", k = "Trap"},
	}

	for _, o in ipairs(opts) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 34)
		btn.Position = UDim2.new(0, 10, 0, y)
		btn.BackgroundColor3 = Config.ESP[o.k] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		btn.Text = "  " .. o.n
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextSize = 15
		btn.Font = Enum.Font.GothamBold
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.ZIndex = 4
		btn.Parent = tab
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local sel = Instance.new("TextLabel")
		sel.Size = UDim2.new(0, 90, 1, 0)
		sel.Position = UDim2.new(1, -95, 0, 0)
		sel.BackgroundTransparency = 1
		sel.Text = Config.ESP[o.k] and "SELECT" or ""
		sel.TextColor3 = Color3.fromRGB(0, 255, 120)
		sel.TextSize = 14
		sel.Font = Enum.Font.GothamBold
		sel.TextXAlignment = Enum.TextXAlignment.Right
		sel.ZIndex = 5
		sel.Parent = btn

		btn.MouseButton1Click:Connect(function()
			Config.ESP[o.k] = not Config.ESP[o.k]
			sel.Text = Config.ESP[o.k] and "SELECT" or ""
			btn.BackgroundColor3 = Config.ESP[o.k] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
			Config.ESP.Enabled = Config.ESP.Chams or Config.ESP.Name or Config.ESP.Role or Config.ESP.Line or Config.ESP.Box or Config.ESP.Gun or Config.ESP.Trap
		end)
		y = y + 40
	end

	y = y + 12
	local roles = {"Murder", "Sheriff", "Innocent", "Gun", "Trap"}
	for _, r in ipairs(roles) do
		local lbl = Instance.new("TextLabel")
		lbl.Name = r
		lbl.Size = UDim2.new(0, 120, 0, 28)
		lbl.Position = UDim2.new(0, 14, 0, y)
		lbl.BackgroundTransparency = 1
		lbl.Text = r
		lbl.TextColor3 = Color3.new(1, 1, 1)
		lbl.TextSize = 15
		lbl.Font = Enum.Font.GothamBold
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 4
		lbl.Parent = tab

		local circle = Instance.new("TextButton")
		circle.Name = r .. "Circle"
		circle.Size = UDim2.new(0, 26, 0, 26)
		circle.Position = UDim2.new(1, -50, 0, y + 1)
		circle.BackgroundColor3 = Config.Colors[r].color
		circle.Text = ""
		circle.ZIndex = 5
		circle.Parent = tab
		Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

		circle.MouseButton1Click:Connect(function()
			if current_key == r then
				ColorPane.Visible = false
				current_key = nil
			else
				current_key = r
				ColorPane.Visible = true
				update_pkr()
			end
		end)

		RunService.RenderStepped:Connect(function()
			if Config.Colors[r].rainbow then
				circle.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
			else
				circle.BackgroundColor3 = Config.Colors[r].color
			end
		end)

		y = y + 36
	end

	tab.CanvasSize = UDim2.new(0, 0, 0, y + 30)
end
BuildEspTab()

local function BuildCombatTab()
	local tab = Tabs.Combat
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local y = 12

	local function section(t)
		local s = Instance.new("TextLabel")
		s.Size = UDim2.new(1, -20, 0, 22)
		s.Position = UDim2.new(0, 10, 0, y)
		s.BackgroundTransparency = 1
		s.Text = t
		s.TextColor3 = Color3.fromRGB(160, 160, 160)
		s.Font = Enum.Font.GothamBold
		s.TextSize = 13
		s.TextXAlignment = Enum.TextXAlignment.Left
		s.ZIndex = 4
		s.Parent = tab
		y = y + 26
	end

	local function toggle(text, key)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 34)
		btn.Position = UDim2.new(0, 10, 0, y)
		btn.BackgroundColor3 = Config.Combat[key] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		btn.Text = "  " .. text
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextSize = 14
		btn.Font = Enum.Font.GothamBold
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.ZIndex = 4
		btn.Parent = tab
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local sel = Instance.new("TextLabel")
		sel.Size = UDim2.new(0, 90, 1, 0)
		sel.Position = UDim2.new(1, -95, 0, 0)
		sel.BackgroundTransparency = 1
		sel.Text = Config.Combat[key] and "SELECT" or ""
		sel.TextColor3 = Color3.fromRGB(0, 255, 120)
		sel.TextSize = 13
		sel.Font = Enum.Font.GothamBold
		sel.TextXAlignment = Enum.TextXAlignment.Right
		sel.ZIndex = 5
		sel.Parent = btn

		btn.MouseButton1Click:Connect(function()
			Config.Combat[key] = not Config.Combat[key]
			sel.Text = Config.Combat[key] and "SELECT" or ""
			btn.BackgroundColor3 = Config.Combat[key] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		end)
		y = y + 40
	end

	section("---Automatic Combat")
	toggle("Auto pick up gun", "AutoGun")
	toggle("Auto shot murder", "AutoShot")
	toggle("Auto kill murder", "AutoKill")
	toggle("Auto throw knife", "AutoThrow")

	y = y + 8
	section("---Ui Action Buttons")

	local function uiButtonToggle(text, btnKey)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 34)
		btn.Position = UDim2.new(0, 10, 0, y)
		local targetScreenBtn = ActionButtons[btnKey]
		btn.BackgroundColor3 = (targetScreenBtn and targetScreenBtn.Visible) and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		btn.Text = "  " .. text
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextSize = 14
		btn.Font = Enum.Font.GothamBold
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.ZIndex = 4
		btn.Parent = tab
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local sel = Instance.new("TextLabel")
		sel.Size = UDim2.new(0, 90, 1, 0)
		sel.Position = UDim2.new(1, -95, 0, 0)
		sel.BackgroundTransparency = 1
		sel.Text = (targetScreenBtn and targetScreenBtn.Visible) and "SELECT" or ""
		sel.TextColor3 = Color3.fromRGB(0, 255, 120)
		sel.TextSize = 13
		sel.Font = Enum.Font.GothamBold
		sel.TextXAlignment = Enum.TextXAlignment.Right
		sel.ZIndex = 5
		sel.Parent = btn

		btn.MouseButton1Click:Connect(function()
			if targetScreenBtn then
				targetScreenBtn.Visible = not targetScreenBtn.Visible
				sel.Text = targetScreenBtn.Visible and "SELECT" or ""
				btn.BackgroundColor3 = targetScreenBtn.Visible and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
			end
		end)
		y = y + 40
	end

	uiButtonToggle("Pick up gun", "PickUpGunBtn")
	uiButtonToggle("Shot murder", "ShotMurderBtn")
	uiButtonToggle("Kill murder", "KillMurderBtn")
	uiButtonToggle("Throw knife", "ThrowKnifeBtn")
	uiButtonToggle("Spam trap", "PlaceTrapBtn")

	tab.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end
BuildCombatTab()

do
	local tab = Tabs.Info
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -30, 1, -30)
	lbl.Position = UDim2.new(0, 15, 0, 15)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Mmv Script Hub\nPowered by Gemini Ai & ChatGPT\n\nVersion: 5.19\n\n- Исправлены ESP Box, Line и стабильность Name\n- Интегрирован мультитач-драггер"
	lbl.TextColor3 = Color3.fromRGB(190, 190, 190)
	lbl.TextSize = 15
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Top
	lbl.ZIndex = 4
	lbl.Parent = tab
end

-- Главный цикл
task.spawn(function()
	while getgenv().MMV_AdminPanel_Running do
		pcall(UpdateESP)

		if Config.Combat.AutoGun and not HasGun() then
			pcall(PickUpGun)
		end
		if Config.Combat.AutoShot then
			pcall(ShotMurder)
		end
		if Config.Combat.AutoKill then
			pcall(KillMurder)
		end
		if Config.Combat.AutoThrow then
			pcall(ThrowKnifeAtNearest)
		end

		task.wait(0.12)
	end
	ClearAllESP()
end)

print("[MMV Admin Panel] v5.19 успешно загружена!")
