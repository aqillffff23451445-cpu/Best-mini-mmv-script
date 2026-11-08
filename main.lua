--приветик бро! Этот код без вирусов и полностью бесплатный! Пользуйся на здоровье<3
-- ==============================================================================
-- MMV Admin Panel | Gemini Ai & ChatGPT Integration
-- Version 5.20.0 (Fixed Audio, ToggleNoclip, Improved Fly & Stable Fling)
-- ==============================================================================

local getgenv = getgenv or function() return _G end
local currentSession = tick()
getgenv().MMV_AdminPanel_Session = currentSession

if getgenv().MMV_AdminPanel_Running then
	getgenv().MMV_AdminPanel_Running = false
	task.wait(0.1)
end
getgenv().MMV_AdminPanel_Running = true

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ====================== КОНФИГ И СОХРАНЕНИЕ ======================
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
	Audio = {
		OffAllRadio = false,
		SelectedSongId = "82746224492420",
	},
	AntiCauldron = {
		Enabled = false,
	},
	Player = {
		Enabled = false,
		WalkSpeed = 16,
		JumpPower = 50,
		Noclip = false,
		Fly = false,
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
		Aimbot = false,
		BombSpamActive = false,
	},
	Fling = {
		Active = false,
	},
	Exploits = {
		StealthActive = false,
		LastTrapPlaced = 0,
		LastMorph = 0,
		LastShot = 0,
		LastKnifeThrow = 0,
		LastAudioPlay = 0,
		LastBombSpam = 0,
	},
}

local CONFIG_FILE = "MMV_AdminConfig_" .. tostring(LocalPlayer.UserId) .. ".json"

local function SaveConfig()
	pcall(function()
		if writefile and HttpService then
			local saveData = {
				ESP = Config.ESP,
				Audio = Config.Audio,
				Combat = Config.Combat,
				AntiCauldron = Config.AntiCauldron,
				Player = Config.Player,
				Colors = {}
			}
			for k, v in pairs(Config.Colors) do
				saveData.Colors[k] = {r = v.color.R, g = v.color.G, b = v.color.B, rainbow = v.rainbow}
			end
			writefile(CONFIG_FILE, HttpService:JSONEncode(saveData))
		end
	end)
end

local function LoadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) and HttpService then
			local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
			if decoded then
				if decoded.ESP then for k, v in pairs(decoded.ESP) do Config.ESP[k] = v end end
				if decoded.Audio then for k, v in pairs(decoded.Audio) do Config.Audio[k] = v end end
				if decoded.Combat then for k, v in pairs(decoded.Combat) do Config.Combat[k] = v end end
				if decoded.AntiCauldron then for k, v in pairs(decoded.AntiCauldron) do Config.AntiCauldron[k] = v end end
				if decoded.Player then for k, v in pairs(decoded.Player) do Config.Player[k] = v end end
				if decoded.Colors then
					for k, v in pairs(decoded.Colors) do
						if Config.Colors[k] then
							Config.Colors[k].color = Color3.new(v.r, v.g, v.b)
							Config.Colors[k].rainbow = v.rainbow
						end
					end
				end
			end
		end
	end)
end

LoadConfig()

local DrawingLib = nil
local HasDrawing = false
pcall(function()
	DrawingLib = Drawing or (getgenv and getgenv().Drawing)
	if DrawingLib and type(DrawingLib.new) == "function" then HasDrawing = true end
end)

-- ====================== GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MMV_AdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiSuccess = pcall(function() ScreenGui.Parent = CoreGui end)
if not guiSuccess or not ScreenGui.Parent then
	pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
end

local function MakeDraggable(guiObject)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	pcall(function()
		guiObject.Active = true
		guiObject.InputBegan:Connect(function(input)
			local isTouch = input.UserInputType == Enum.UserInputType.Touch
			local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
			if dragging or not (isTouch or isMouse) then return end
			dragging = true
			dragInput = isTouch and input or nil
			dragStart = input.Position
			startPos = guiObject.Position
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			local isOurTouch = dragInput ~= nil and input == dragInput
			local isMouseMove = dragInput == nil and input.UserInputType == Enum.UserInputType.MouseMovement
			if not isOurTouch and not isMouseMove then return end
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)

		UserInputService.InputEnded:Connect(function(input)
			local isOurTouch = dragInput ~= nil and input == dragInput
			local isOurMouse = dragInput == nil and input.UserInputType == Enum.UserInputType.MouseButton1
			if dragging and (isOurTouch or isOurMouse) then
				dragging = false
				dragInput = nil
				dragStart = nil
				startPos = nil
			end
		end)
	end)
end

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
	pcall(function() ContentProvider:PreloadAsync({ToggleIcon, BgImage}) end)
end)

local menuVisible = true
ToggleIcon.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	MainFrame.Visible = menuVisible
end)

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
local TabNames = {"Player", "Fling", "Visual", "Combat", "Info"}
local CurrentTab = "Player"

for _, name in ipairs(TabNames) do
	local frame = Instance.new("ScrollingFrame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ScrollBarThickness = 4
	frame.CanvasSize = UDim2.new(0, 0, 0, 600)
	frame.Visible = (name == "Player")
	frame.ZIndex = 3
	frame.Parent = Content
	Tabs[name] = frame
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = SearchBox.Text:lower()
	local activeTab = Tabs[CurrentTab]
	if activeTab then
		for _, child in ipairs(activeTab:GetChildren()) do
			if child:IsA("GuiObject") then
				local searchableText = (child.Name .. " " .. (child:IsA("TextButton") and child.Text or "")):lower()
				if query == "" or searchableText:find(query) then child.Visible = true else child.Visible = false end
			end
		end
	end
end)

local NavButtons = {}
for i, name in ipairs(TabNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -14, 0, 40)
	btn.Position = UDim2.new(0, 7, 0, 10 + (i-1)*46)
	btn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	btn.Text = name
	btn.TextColor3 = (name == "Player") and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(210, 210, 210)
	btn.TextSize = 15
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

local function GetColorFromConfig(key)
	local conf = Config.Colors[key]
	if not conf then return Color3.new(1, 1, 1) end
	if conf.rainbow then return Color3.fromHSV(tick() % 5 / 5, 1, 1) end
	return conf.color
end

local function GetRoleColor(player)
	local roleName = "Innocent"
	pcall(function()
		if tick() - LastRoleCheck > 1.5 then
			LastRoleCheck = tick()
			pcall(function()
				local ok, data = pcall(function() return ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer() end)
				if ok and type(data) == "table" then RoleCache = data end
			end)
		end

		if RoleCache[player.Name] then
			local role = tostring(RoleCache[player.Name].Role or RoleCache[player.Name].Team or ""):lower()
			if role:find("murder") or role:find("killer") then roleName = "Murder"
			elseif role:find("sheriff") then roleName = "Sheriff"
			else roleName = "Innocent" end
		else
			local char, backpack = player.Character, player:FindFirstChild("Backpack")
			local hasKnife, hasGun = false, false
			for _, cont in ipairs({char, backpack}) do
				if cont then
					for _, item in ipairs(cont:GetChildren()) do
						pcall(function()
							if item:FindFirstChild("IsKnife") or item.Name:lower():find("knife") then hasKnife = true end
							if item:FindFirstChild("IsGun") or item.Name:lower():find("gun") then hasGun = true end
						end)
					end
				end
			end
			if hasKnife then roleName = "Murder"
			elseif hasGun then roleName = "Sheriff"
			else roleName = "Innocent" end
		end
	end)

	return roleName, GetColorFromConfig(roleName)
end

local function HasGun()
	local char = LocalPlayer.Character
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	for _, cont in ipairs({char, backpack}) do
		if cont then
			for _, item in ipairs(cont:GetChildren()) do
				local nameL = item.Name:lower()
				if item:FindFirstChild("IsGun") or nameL:find("gun") or nameL:find("revolver") or nameL:find("sheriff") then
					return true, item
				end
			end
		end
	end
	return false, nil
end

_G.GetPlayerRole = GetRoleColor

-- ====================== AUDIO / RADIO (ИСПРАВЛЕНО) ======================
local function PlaySelectedSong(songId)
	if tick() - Config.Exploits.LastAudioPlay < 1.0 then return end
	Config.Exploits.LastAudioPlay = tick()

	task.spawn(function()
		pcall(function()
			local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Inventory")
			local equipRemote = remotes:WaitForChild("Equip")
			local playSongRemote = remotes:WaitForChild("PlaySong")

			equipRemote:FireServer("Gold", "Radios")
			task.wait(0.25)

			local targetId = tostring(songId or Config.Audio.SelectedSongId or "82746224492420")
			local songUrl = "https://www.roblox.com/asset/?id=" .. targetId

			playSongRemote:FireServer(songUrl)
		end)
	end)
end

local function ProcessAudio()
	pcall(function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local radio = player.Character:FindFirstChild("Radio") or player.Character:FindFirstChild("radio")
				if radio then
					local sound = radio:FindFirstChild("Sound") or radio:FindFirstChildOfClass("Sound")
					if sound and Config.Audio.OffAllRadio then sound.Volume = 0 sound.Playing = false end
				end
			end
		end
	end)
end

-- ====================== ANTI-CAULDRON BYPASS ======================
local function ProcessCauldrons()
	if not Config.AntiCauldron.Enabled then return end
	pcall(function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			pcall(function()
				if obj.Name == "Handle" and obj:IsA("BasePart") then
					local hasGlow = obj:FindFirstChild("glow")
					local hasFx = obj:FindFirstChild("FxPart")
					local hasSpin = obj:FindFirstChild("spin")
					
					if hasGlow or hasFx or hasSpin then
						obj.CanCollide = false
						obj.Transparency = 1
						for _, child in ipairs(obj:GetDescendants()) do
							if child:IsA("BasePart") or child:IsA("Decal") or child:IsA("Texture") then
								pcall(function()
									child.Transparency = 1
									if child:IsA("BasePart") then child.CanCollide = false end
								end)
							end
						end
					end
				end
			end)
		end
	end)
end

-- ====================== PLAYER MODS (NOCLIP & FLY ИСПРАВЛЕНЫ) ======================
local flyConnection = nil
local noclipConnection = nil
local flyBodyVelocity = nil

local function ToggleNoclip(state)
	Config.Player.Noclip = state

	if state then
		if not noclipConnection then
			noclipConnection = RunService.Stepped:Connect(function()
				pcall(function()
					if not Config.Player.Noclip then return end
					local char = LocalPlayer.Character
					if not char then return end
					for _, part in pairs(char:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end)
			end)
		end
	else
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end

		pcall(function()
			local char = LocalPlayer.Character
			if char then
				for _, part in pairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end)
	end
end

local function ToggleFly(state)
	Config.Player.Fly = state

	if state then
		if flyConnection then return end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		hum.PlatformStand = true

		flyBodyVelocity = Instance.new("BodyVelocity")
		flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		flyBodyVelocity.Velocity = Vector3.zero
		flyBodyVelocity.Parent = hrp

		flyConnection = RunService.RenderStepped:Connect(function()
			pcall(function()
				if not Config.Player.Fly or not flyBodyVelocity or not flyBodyVelocity.Parent then return end

				local camCF = Camera.CFrame
				local move = Vector3.zero
				local speed = 55

				if UserInputService:IsKeyDown(Enum.KeyCode.W) then
					move = move + camCF.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then
					move = move - camCF.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then
					move = move - camCF.RightVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then
					move = move + camCF.RightVector
				end

				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					move = move + Vector3.new(0, 1, 0)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
					move = move - Vector3.new(0, 1, 0)
				end

				if move.Magnitude > 0 then
					flyBodyVelocity.Velocity = move.Unit * speed
				else
					flyBodyVelocity.Velocity = Vector3.zero
				end

				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end)
	else
		if flyConnection then
			flyConnection:Disconnect()
			flyConnection = nil
		end

		if flyBodyVelocity then
			flyBodyVelocity:Destroy()
			flyBodyVelocity = nil
		end

		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hum then hum.PlatformStand = false end
			if hrp then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end
end

-- ====================== MORPH ======================
local morphIndex = 1
local function MorphAvatar()
	if tick() - Config.Exploits.LastMorph < 1.2 then return end
	Config.Exploits.LastMorph = tick()

	pcall(function()
		local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
		if not mainGui then return end
		local lobby = mainGui:FindFirstChild("Lobby")
		local screens = lobby and lobby:FindFirstChild("Screens")
		local inventory = screens and screens:FindFirstChild("Inventory")
		local main = inventory and inventory:FindFirstChild("Main")
		local outfits = main and main:FindFirstChild("Outfits")
		local items = outfits and outfits:FindFirstChild("Items")
		local container = items and items:FindFirstChild("Container")
		local current = container and container:FindFirstChild("Current")
		local actualContainer = current and current:FindFirstChild("Container")

		if not actualContainer then return end
		local outfitsList = {}
		for _, item in ipairs(actualContainer:GetChildren()) do
			if item.Name == "NewItem" then
				local label = item:FindFirstChild("ItemName") and item.ItemName:FindFirstChild("Label")
				if label and label:IsA("TextLabel") and label.Text ~= "" then table.insert(outfitsList, label.Text) end
			end
		end

		if #outfitsList == 0 then return end
		if morphIndex > #outfitsList then morphIndex = 1 end
		local chosenOutfit = outfitsList[morphIndex]
		morphIndex = morphIndex + 1

		local outfitEvents = ReplicatedStorage:FindFirstChild("OutfitEvents")
		local setAvatarRemote = outfitEvents and outfitEvents:FindFirstChild("SetAvatarClient")
		if setAvatarRemote then setAvatarRemote:FireServer(chosenOutfit) end
	end)
end

-- ====================== AIMBOT ======================
local function RunAimbot()
	pcall(function()
		if not Config.Combat.Aimbot then return end
		local targetHRP = nil
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local playerRole, _ = GetRoleColor(player)
				if playerRole == "Murder" then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					local hum = player.Character:FindFirstChild("Humanoid")
					if hrp and hum and hum.Health > 0 then targetHRP = hrp break end
				end
			end
		end
		if targetHRP then Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position) end
	end)
end

-- ====================== BOMB SPAM ======================
local function TriggerBombSpam()
	if tick() - Config.Exploits.LastBombSpam < 0.12 then return end
	Config.Exploits.LastBombSpam = tick()

	pcall(function()
		local equipArgs = { "FakeBomb" }
		ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("ReplicateToy"):InvokeServer(unpack(equipArgs))
		
		local targetPos = nil
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local roleName, _ = GetRoleColor(player)
				if roleName == "Murder" then
					local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
					local hum = player.Character:FindFirstChild("Humanoid")
					if tHRP and hum and hum.Health > 0 then
						targetPos = tHRP.Position
						break
					end
				end
			end
		end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local fakeBomb = char and char:FindFirstChild("FakeBomb")

		if hrp then
			local throwCFrame
			if targetPos then
				throwCFrame = CFrame.new(hrp.Position, targetPos + Vector3.new(0, 2, 0))
			else
				throwCFrame = hrp.CFrame + (hrp.CFrame.LookVector * 10)
			end

			if fakeBomb then
				local remoteEvent = fakeBomb:FindFirstChild("RemoteEvent")
				if remoteEvent then
					local args = { throwCFrame, true }
					remoteEvent:FireServer(unpack(args))
				end
			end
		end
	end)
end

-- ====================== ESP ======================
local Highlights = {}
local Billboards = {}
local Lines = {}
local Boxes = {}

local ItemHighlights = {}
local ItemBillboards = {}
local ItemLines = {}
local ItemBoxes = {}

local function RemovePlayerESP(player)
	pcall(function()
		if Highlights[player] then Highlights[player]:Destroy() Highlights[player] = nil end
		if Billboards[player] then Billboards[player]:Destroy() Billboards[player] = nil end
		if Lines[player] then pcall(function() Lines[player]:Remove() end) Lines[player] = nil end
		if Boxes[player] then pcall(function() Boxes[player]:Remove() end) Boxes[player] = nil end
	end)
end

local function ClearAllItemESP()
	pcall(function()
		for obj, hl in pairs(ItemHighlights) do hl:Destroy() end
		for obj, bb in pairs(ItemBillboards) do bb:Destroy() end
		for obj, l in pairs(ItemLines) do pcall(function() l:Remove() end) end
		for obj, b in pairs(ItemBoxes) do pcall(function() b:Remove() end) end
		ItemHighlights, ItemBillboards, ItemLines, ItemBoxes = {}, {}, {}, {}
	end)
end

local function ClearAllESP()
	pcall(function()
		for player, _ in pairs(Highlights) do RemovePlayerESP(player) end
		for player, _ in pairs(Lines) do if Lines[player] then pcall(function() Lines[player]:Remove() end) Lines[player] = nil end end
		for player, _ in pairs(Boxes) do if Boxes[player] then pcall(function() Boxes[player]:Remove() end) Boxes[player] = nil end end
		ClearAllItemESP()
	end)
end

local function IsRealTrap(obj)
	return obj and obj.Name == "Trap" and obj:IsA("Model") 
		and obj:FindFirstChild("TrapVisual") 
		and obj:FindFirstChild("PlacedPlayer")
end

local function UpdateESP()
	if not Config.ESP.Enabled then ClearAllESP() return end

	for _, player in ipairs(Players:GetPlayers()) do
		pcall(function()
			if player ~= LocalPlayer and player.Character then
				local char = player.Character
				local root = char:FindFirstChild("HumanoidRootPart")
				local head = char:FindFirstChild("Head")
				local hum = char:FindFirstChildOfClass("Humanoid")

				if root and head and hum and hum.Health > 0 then
					local roleName, color = GetRoleColor(player)
					if Config.ESP.Chams then
						local hl = Highlights[player]
						if not hl or not hl.Parent or hl.Parent ~= char then
							if hl then pcall(function() hl:Destroy() end) end
							hl = Instance.new("Highlight")
							hl.FillTransparency = 0.55
							hl.OutlineTransparency = 1
							hl.Parent = char
							Highlights[player] = hl
						end
						hl.Adornee = char hl.FillColor = color hl.Enabled = true
					elseif Highlights[player] then Highlights[player].Enabled = false end

					if Config.ESP.Name or Config.ESP.Role then
						local bb = Billboards[player]
						if not bb or not bb.Parent or bb.Parent ~= char then
							if bb then pcall(function() bb:Destroy() end) end
							bb = Instance.new("BillboardGui")
							bb.Name = "MMV_ESP_Billboard"
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
						local text = (Config.ESP.Name and Config.ESP.Role) and (player.Name .. "\n" .. roleName) or (Config.ESP.Name and player.Name or roleName)
						bb.Enabled = true
						local lbl = bb:FindFirstChild("Label")
						if lbl then lbl.Text = text lbl.TextColor3 = color end
					elseif Billboards[player] then Billboards[player].Enabled = false end
				else RemovePlayerESP(player) end
			else RemovePlayerESP(player) end
		end)
	end

	local validObjects = {}
	if Config.ESP.Gun or Config.ESP.Trap then
		pcall(function()
			for _, obj in ipairs(workspace:GetChildren()) do
				pcall(function()
					local nameLower = obj.Name:lower()
					if Config.ESP.Gun and (nameLower == "gundrop" or nameLower == "gun") then
						validObjects[obj] = {text = "GUN DROP", color = GetColorFromConfig("Gun")}
					elseif Config.ESP.Trap and IsRealTrap(obj) then
						local visualPart = obj:FindFirstChild("TrapVisual")
						if visualPart then
							validObjects[obj] = {text = "TRAP", color = GetColorFromConfig("Trap"), adornee = visualPart}
							if visualPart:IsA("BasePart") then visualPart.Transparency = 0 end
							local billboard = visualPart:FindFirstChild("TrapBillboard") or obj:FindFirstChild("TrapBillboard")
							if billboard and billboard:IsA("BillboardGui") then billboard.Enabled = true end
						end
					end
				end)
			end
		end)
	end

	for obj, info in pairs(validObjects) do
		pcall(function()
			local hl = ItemHighlights[obj]
			if not hl or not hl.Parent then
				hl = Instance.new("Highlight") hl.FillTransparency = 0.3 hl.OutlineTransparency = 1 hl.Parent = obj ItemHighlights[obj] = hl
			end
			hl.FillColor = info.color hl.Enabled = true

			local bb = ItemBillboards[obj]
			if not bb or not bb.Parent then
				bb = Instance.new("BillboardGui")
				bb.Size = UDim2.new(0, 100, 0, 30)
				bb.StudsOffset = Vector3.new(0, 1.8, 0)
				bb.AlwaysOnTop = true
				local lbl = Instance.new("TextLabel")
				lbl.Name = "Label" lbl.Size = UDim2.new(1, 0, 1, 0) lbl.BackgroundTransparency = 1
				lbl.Text = info.text lbl.TextSize = 13 lbl.Font = Enum.Font.GothamBold
				lbl.TextStrokeTransparency = 0.2 lbl.TextColor3 = info.color lbl.Parent = bb
				bb.Parent = obj ItemBillboards[obj] = bb
			end
			bb.Adornee = info.adornee or obj bb.Enabled = true
		end)
	end

	for obj, hl in pairs(ItemHighlights) do
		if not validObjects[obj] or not obj.Parent then 
			pcall(function() 
				hl:Destroy() 
				if ItemBillboards[obj] then ItemBillboards[obj]:Destroy() ItemBillboards[obj] = nil end 
				if ItemLines[obj] then ItemLines[obj]:Remove() ItemLines[obj] = nil end
				if ItemBoxes[obj] then ItemBoxes[obj]:Remove() ItemBoxes[obj] = nil end
			end) 
			ItemHighlights[obj] = nil 
		end
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() RemovePlayerESP(p) end)
	p.CharacterRemoving:Connect(function() RemovePlayerESP(p) end)
end)
Players.PlayerRemoving:Connect(RemovePlayerESP)

if HasDrawing then
	pcall(function()
		RunService.RenderStepped:Connect(function()
			if not Config.ESP.Enabled or (not Config.ESP.Line and not Config.ESP.Box) then
				for _, l in pairs(Lines) do if l then l.Visible = false end end
				for _, b in pairs(Boxes) do if b then b.Visible = false end end
				for _, l in pairs(ItemLines) do if l then l.Visible = false end end
				for _, b in pairs(ItemBoxes) do if b then b.Visible = false end end
				return
			end
			
			local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			
			for _, player in ipairs(Players:GetPlayers()) do
				pcall(function()
					local showLine = Config.ESP.Line
					local showBox = Config.ESP.Box
					
					if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local char = player.Character 
						local root = char.HumanoidRootPart 
						local head = char:FindFirstChild("Head") or root
						local hum = char:FindFirstChildOfClass("Humanoid")
						
						if hum and hum.Health > 0 then
							local _, color = GetRoleColor(player)
							local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
							
							if onScreen and rootPos.Z > 0 then
								if showLine then
									local line = Lines[player]
									if not line then line = DrawingLib.new("Line") line.Thickness = 2 Lines[player] = line end
									line.From = screenBottom line.To = Vector2.new(rootPos.X, rootPos.Y) line.Color = color line.Visible = true
								elseif Lines[player] then Lines[player].Visible = false end

								if showBox then
									local box = Boxes[player]
									if not box then box = DrawingLib.new("Square") box.Thickness = 2 box.Filled = false Boxes[player] = box end
									local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
									local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
									local height = math.abs(headPos.Y - legPos.Y)
									local width = height * 0.55
									box.Size = Vector2.new(width, height)
									box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
									box.Color = color box.Visible = true
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
				end)
			end

			for obj, _ in pairs(ItemHighlights) do
				pcall(function()
					if not obj or not obj.Parent then return end
					local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
					if not part then return end

					local isGun = (obj.Name:lower() == "gundrop" or obj.Name:lower() == "gun")
					local color = isGun and GetColorFromConfig("Gun") or GetColorFromConfig("Trap")
					local pos, onScreen = Camera:WorldToViewportPoint(part.Position)

					if onScreen and pos.Z > 0 then
						if Config.ESP.Line then
							local line = ItemLines[obj]
							if not line then line = DrawingLib.new("Line") line.Thickness = 2 ItemLines[obj] = line end
							line.From = screenBottom line.To = Vector2.new(pos.X, pos.Y) line.Color = color line.Visible = true
						elseif ItemLines[obj] then ItemLines[obj].Visible = false end

						if Config.ESP.Box then
							local box = ItemBoxes[obj]
							if not box then box = DrawingLib.new("Square") box.Thickness = 2 box.Filled = false ItemBoxes[obj] = box end
							local boxSize = Vector2.new(35, 35)
							box.Size = boxSize
							box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
							box.Color = color box.Visible = true
						elseif ItemBoxes[obj] then ItemBoxes[obj].Visible = false end
					else
						if ItemLines[obj] then ItemLines[obj].Visible = false end
						if ItemBoxes[obj] then ItemBoxes[obj].Visible = false end
					end
				end)
			end
		end)
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
sat_grad.Size = UDim2.new(1, 0, 1, 0) sat_grad.ZIndex = 21
local sg = Instance.new("UIGradient", sat_grad) sg.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}

local val_grad = Instance.new("Frame", SV_Canvas)
val_grad.Size = UDim2.new(1, 0, 1, 0) val_grad.ZIndex = 21
local vg = Instance.new("UIGradient", val_grad) vg.Rotation = 90 vg.Color = ColorSequence.new(Color3.new(0, 0, 0)) vg.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}

local Pointer = Instance.new("Frame", SV_Canvas)
Pointer.Size = UDim2.new(0, 10, 0, 10) Pointer.AnchorPoint = Vector2.new(0.5, 0.5) Pointer.BackgroundColor3 = Color3.new(1, 1, 1) Pointer.ZIndex = 25
Instance.new("UICorner", Pointer).CornerRadius = UDim.new(1, 0) Instance.new("UIStroke", Pointer)

local Hue_Rail = Instance.new("Frame", ColorPane)
Hue_Rail.Size = UDim2.new(0, 18, 0, 150) Hue_Rail.Position = UDim2.new(0, 172, 0, 12) Hue_Rail.ZIndex = 21
Instance.new("UICorner", Hue_Rail).CornerRadius = UDim.new(0, 4)
local hg = Instance.new("UIGradient", Hue_Rail) hg.Rotation = 90
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
		update_pkr() SaveConfig()
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
				callback(relX, relY) update_pkr() SaveConfig()
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
	pcall(function()
		local gunDrop = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun")
		if not gunDrop then return end
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local target = gunDrop:IsA("Model") and (gunDrop.PrimaryPart or gunDrop:FindFirstChildWhichIsA("BasePart")) or gunDrop
		if target and target:IsA("BasePart") then
			firetouchinterest(hrp, target, 0) task.wait() firetouchinterest(hrp, target, 1)
		end
	end)
end

local function ShotMurder()
	if isFiring or (tick() - Config.Exploits.LastShot < 0.4) then return end
	pcall(function()
		local has, tool = HasGun()
		if not has or not tool then return end
		local remote = tool:FindFirstChild("KnifeServer") and tool.KnifeServer:FindFirstChild("SlashStart")
		if not remote then
			for _, child in ipairs(tool:GetDescendants()) do
				if child:IsA("RemoteEvent") and (child.Name:lower():find("slash") or child.Name:lower():find("shoot") or child.Name:lower():find("gun")) then
					remote = child break
				end
			end
		end
		if not remote then return end
		
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local roleName, _ = GetRoleColor(player)
				if roleName == "Murder" then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					local head = player.Character:FindFirstChild("Head")
					if hrp then
						isFiring = true Config.Exploits.LastShot = tick()
						local targetPos = head and head.Position or hrp.Position
						remote:FireServer(1, targetPos) task.wait(0.2) isFiring = false break
					end
				end
			end
		end
	end)
end

local function KillMurder()
	if isFiring or (tick() - Config.Exploits.LastShot < 0.4) then return end
	pcall(function()
		local has, tool = HasGun()
		if not has or not tool then return end
		local remote = tool:FindFirstChild("KnifeServer") and tool.KnifeServer:FindFirstChild("SlashStart")
		if not remote then return end
		local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not myHRP then return end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local roleName, _ = GetRoleColor(player)
				if roleName == "Murder" then
					local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
					local head = player.Character:FindFirstChild("Head")
					if targetHRP then
						isFiring = true Config.Exploits.LastShot = tick()
						myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 4.2)
						task.wait(0.04)
						local targetPos = head and head.Position or targetHRP.Position
						remote:FireServer(1, targetPos) task.wait(0.2) isFiring = false break
					end
				end
			end
		end
	end)
end

local function ThrowKnifeAtNearest()
	if tick() - Config.Exploits.LastKnifeThrow < 1.8 then return end
	Config.Exploits.LastKnifeThrow = tick()

	pcall(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local knife = char and char:FindFirstChild("Knife")
		if not hrp or not knife then return end

		local remote = knife:FindFirstChild("KnifeServer") and knife.KnifeServer:FindFirstChild("FlingKnifeEvent")
		local handle = knife:FindFirstChild("Handle")
		if not remote or not handle then return end

		local nearestDist = math.huge
		local targetHRP = nil
		local targetHead = nil

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
				local hum = player.Character:FindFirstChild("Humanoid")
				local head = player.Character:FindFirstChild("Head")
				if tHRP and hum and hum.Health > 0 then
					local dist = (tHRP.Position - hrp.Position).Magnitude
					if dist < nearestDist then nearestDist = dist targetHRP = tHRP targetHead = head end
				end
			end
		end

		if targetHRP then
			local targetPos = targetHead and targetHead.Position or targetHRP.Position
			remote:FireServer(CFrame.new(targetPos), handle.Position)
			pcall(function() handle.Transparency = 1 end)

			task.spawn(function()
				local fakeKnife = nil
				local weaponDisplays = workspace:FindFirstChild("WeaponDisplays")
				if weaponDisplays then
					for _, disp in ipairs(weaponDisplays:GetChildren()) do
						pcall(function()
							if disp.Name:lower() == LocalPlayer.Name:lower() or disp.Name:lower() == "knifedisplay" then
								local creatorObj = disp:FindFirstChild("creator")
								if creatorObj and (creatorObj.Value == LocalPlayer or creatorObj.Value == LocalPlayer.Name) then
									fakeKnife = disp:Clone()
								elseif not fakeKnife and disp.Name:lower() == "knifedisplay" then
									fakeKnife = disp:Clone()
								end
							end
						end)
						if fakeKnife then break end
					end
				end

				if not fakeKnife then fakeKnife = handle:Clone() end
				local primaryPart = fakeKnife:IsA("Model") and (fakeKnife.PrimaryPart or fakeKnife:FindFirstChildWhichIsA("BasePart")) or fakeKnife
				if primaryPart and primaryPart:IsA("BasePart") then
					if fakeKnife:IsA("Model") then fakeKnife:SetPrimaryPartCFrame(handle.CFrame) else fakeKnife.CFrame = handle.CFrame end
					for _, p in ipairs(fakeKnife:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false p.Transparency = 0 end end
					fakeKnife.Parent = workspace

					local startPos = handle.Position
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = {char, fakeKnife}
					
					local rayResult = workspace:Raycast(startPos, (targetPos - startPos), raycastParams)
					local endPos = rayResult and rayResult.Position or targetPos

					local speed = 80
					local distance = (endPos - startPos).Magnitude
					local duration = distance / speed
					local elapsed = 0

					while elapsed < duration do
						local dt = RunService.RenderStepped:Wait()
						elapsed = elapsed + dt
						local alpha = math.clamp(elapsed / duration, 0, 1)
						local currentPos = startPos:Lerp(endPos, alpha)
						local rotCF = CFrame.new(currentPos) * CFrame.Angles(math.rad(elapsed * 600), 0, 0)
						if fakeKnife:IsA("Model") and fakeKnife.PrimaryPart then fakeKnife:SetPrimaryPartCFrame(rotCF) elseif fakeKnife:IsA("BasePart") then fakeKnife.CFrame = rotCF end
					end
					pcall(function() fakeKnife:Destroy() end)
				end
				pcall(function() handle.Transparency = 0 end)
			end)
		end
	end)
end

local function SpamPlaceTrap()
	if tick() - Config.Exploits.LastTrapPlaced < 0.8 then return end
	Config.Exploits.LastTrapPlaced = tick()
	pcall(function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local trapRemote = ReplicatedStorage:FindFirstChild("TrapSystem") and ReplicatedStorage.TrapSystem:FindFirstChild("PlaceTrap")
		if trapRemote then trapRemote:FireServer(hrp.CFrame) end
	end)
end

-- ====================== КНОПКИ ДЕЙСТВИЙ НА ЭКРАНЕ ======================
local ActionButtons = {}
local function CreateActionScreenButton(name, text, defaultPos, actionFunc)
	local btn = Instance.new("TextButton")
	btn.Name = name btn.Size = UDim2.new(0, 155, 0, 40) btn.Position = defaultPos
	btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) btn.Text = text
	btn.TextColor3 = Color3.fromRGB(210, 210, 210) btn.TextSize = 14 btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 12 btn.Visible = false btn.Parent = ScreenGui
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(180, 180, 180) s.Thickness = 2 s.Parent = btn
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
CreateActionScreenButton("MorphBtn", "MORPH OUTFIT", UDim2.new(1, -175, 0, 240), MorphAvatar)
CreateActionScreenButton("AimbotBtn", "AIMBOT MURDER", UDim2.new(1, -175, 0, 286), function()
	Config.Combat.Aimbot = not Config.Combat.Aimbot SaveConfig()
end)

CreateActionScreenButton("BombSpamBtn", "BOMB SPAM", UDim2.new(1, -175, 0, 332), function()
	Config.Combat.BombSpamActive = not Config.Combat.BombSpamActive
	SaveConfig()
end)

-- ====================== УЛЬТРА-СТАБИЛЬНЫЙ FLING (ИСПРАВЛЕНО) ======================
local SelectedTargets = {}
local function StartFling()
	if Config.Fling.Active then return end

	local targetPlayer = nil
	for _, plr in pairs(SelectedTargets) do
		if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			targetPlayer = plr
			break
		end
	end
	if not targetPlayer then return end

	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	Config.Fling.Active = true
	local originalCFrame = root.CFrame
	local oldGravity = workspace.Gravity
	workspace.Gravity = 0

	local noclipConn = RunService.Stepped:Connect(function()
		pcall(function()
			if not Config.Fling.Active then return end
			local c = LocalPlayer.Character
			if not c then return end
			for _, part in pairs(c:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end)

	task.spawn(function()
		local startTime = tick()

		while Config.Fling.Active and (tick() - startTime) < 1.25 do
			RunService.Heartbeat:Wait()

			local tRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not tRoot or not myRoot then break end

			local angle = tick() * 40
			local offset = Vector3.new(math.sin(angle) * 1.6, 0.6, math.cos(angle) * 1.6)
			myRoot.CFrame = CFrame.new(tRoot.Position + offset)

			myRoot.AssemblyLinearVelocity = Vector3.new(9999, 9999, 9999)
			myRoot.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
		end

		Config.Fling.Active = false
		if noclipConn then noclipConn:Disconnect() end

		pcall(function()
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myRoot then
				myRoot.AssemblyLinearVelocity = Vector3.zero
				myRoot.AssemblyAngularVelocity = Vector3.zero
				myRoot.Anchored = true

				task.wait(0.15)
				myRoot.CFrame = originalCFrame + Vector3.new(0, 5, 0)

				for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end

				task.wait(0.8)
				myRoot.Anchored = false
				myRoot.AssemblyLinearVelocity = Vector3.zero
			end
		end)

		workspace.Gravity = oldGravity
	end)
end

-- ====================== ПОСТРОЕНИЕ ВКЛАДОК ======================
local function BuildPlayerTab()
	local tab = Tabs.Player
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local y = 12

	local function section(t)
		local s = Instance.new("TextLabel")
		s.Size = UDim2.new(1, -20, 0, 22) s.Position = UDim2.new(0, 10, 0, y) s.BackgroundTransparency = 1
		s.Text = t s.TextColor3 = Color3.fromRGB(160, 160, 160) s.Font = Enum.Font.GothamBold s.TextSize = 13 s.TextXAlignment = Enum.TextXAlignment.Left s.ZIndex = 4 s.Parent = tab
		y = y + 26
	end

	local enableBtn = Instance.new("TextButton")
	enableBtn.Size = UDim2.new(1, -20, 0, 36) enableBtn.Position = UDim2.new(0, 10, 0, y)
	enableBtn.BackgroundColor3 = Config.Player.Enabled and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
	enableBtn.Text = "  enable" enableBtn.TextColor3 = Color3.new(1, 1, 1) enableBtn.TextSize = 15 enableBtn.Font = Enum.Font.GothamBold enableBtn.TextXAlignment = Enum.TextXAlignment.Left enableBtn.ZIndex = 4 enableBtn.Parent = tab
	Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 6)

	local enableSel = Instance.new("TextLabel")
	enableSel.Size = UDim2.new(0, 90, 1, 0) enableSel.Position = UDim2.new(1, -95, 0, 0) enableSel.BackgroundTransparency = 1
	enableSel.Text = Config.Player.Enabled and "●" or "○" enableSel.TextColor3 = Config.Player.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(180, 180, 180)
	enableSel.TextSize = 18 enableSel.Font = Enum.Font.GothamBold enableSel.TextXAlignment = Enum.TextXAlignment.Right enableSel.ZIndex = 5 enableSel.Parent = enableBtn

	enableBtn.MouseButton1Click:Connect(function()
		Config.Player.Enabled = not Config.Player.Enabled
		enableSel.Text = Config.Player.Enabled and "●" or "○"
		enableSel.TextColor3 = Config.Player.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(180, 180, 180)
		enableBtn.BackgroundColor3 = Config.Player.Enabled and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		SaveConfig()
	end)
	y = y + 44

	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(0, 150, 0, 34) speedLabel.Position = UDim2.new(0, 10, 0, y) speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "  Walk Speed" speedLabel.TextColor3 = Color3.new(1, 1, 1) speedLabel.TextSize = 14 speedLabel.Font = Enum.Font.GothamBold speedLabel.TextXAlignment = Enum.TextXAlignment.Left speedLabel.ZIndex = 4 speedLabel.Parent = tab
	Instance.new("UICorner", speedLabel).CornerRadius = UDim.new(0, 6)
	speedLabel.BackgroundColor3 = Color3.fromRGB(52, 52, 52)

	local speedBox = Instance.new("TextBox")
	speedBox.Size = UDim2.new(0, 130, 0, 34) speedBox.Position = UDim2.new(1, -140, 0, y)
	speedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	speedBox.Text = tostring(Config.Player.WalkSpeed)
	speedBox.PlaceholderText = "speed value..."
	speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBox.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
	speedBox.TextSize = 13 speedBox.Font = Enum.Font.GothamBold speedBox.ZIndex = 4 speedBox.Parent = tab
	Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

	speedBox.FocusLost:Connect(function()
		local val = tonumber(speedBox.Text)
		if val then
			Config.Player.WalkSpeed = math.clamp(val, 0, 300)
			speedBox.Text = tostring(Config.Player.WalkSpeed)
			SaveConfig()
		else
			speedBox.Text = tostring(Config.Player.WalkSpeed)
		end
	end)
	y = y + 42

	local jumpLabel = Instance.new("TextLabel")
	jumpLabel.Size = UDim2.new(0, 150, 0, 34) jumpLabel.Position = UDim2.new(0, 10, 0, y) jumpLabel.BackgroundTransparency = 1
	jumpLabel.Text = "  Jump Power" jumpLabel.TextColor3 = Color3.new(1, 1, 1) jumpLabel.TextSize = 14 jumpLabel.Font = Enum.Font.GothamBold jumpLabel.TextXAlignment = Enum.TextXAlignment.Left jumpLabel.ZIndex = 4 jumpLabel.Parent = tab
	Instance.new("UICorner", jumpLabel).CornerRadius = UDim.new(0, 6)
	jumpLabel.BackgroundColor3 = Color3.fromRGB(52, 52, 52)

	local jumpBox = Instance.new("TextBox")
	jumpBox.Size = UDim2.new(0, 130, 0, 34) jumpBox.Position = UDim2.new(1, -140, 0, y)
	jumpBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	jumpBox.Text = tostring(Config.Player.JumpPower)
	jumpBox.PlaceholderText = "jump value..."
	jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	jumpBox.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
	jumpBox.TextSize = 13 jumpBox.Font = Enum.Font.GothamBold jumpBox.ZIndex = 4 jumpBox.Parent = tab
	Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 6)

	jumpBox.FocusLost:Connect(function()
		local val = tonumber(jumpBox.Text)
		if val then
			Config.Player.JumpPower = math.clamp(val, 0, 400)
			jumpBox.Text = tostring(Config.Player.JumpPower)
			SaveConfig()
		else
			jumpBox.Text = tostring(Config.Player.JumpPower)
		end
	end)
	y = y + 48

	section("---Toggles (Independent)")

	local noclipBtn = Instance.new("TextButton")
	noclipBtn.Size = UDim2.new(1, -20, 0, 36) noclipBtn.Position = UDim2.new(0, 10, 0, y)
	noclipBtn.BackgroundColor3 = Config.Player.Noclip and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
	noclipBtn.Text = "  Noclip" noclipBtn.TextColor3 = Color3.new(1, 1, 1) noclipBtn.TextSize = 15 noclipBtn.Font = Enum.Font.GothamBold noclipBtn.TextXAlignment = Enum.TextXAlignment.Left noclipBtn.ZIndex = 4 noclipBtn.Parent = tab
	Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 6)

	local noclipSel = Instance.new("TextLabel")
	noclipSel.Size = UDim2.new(0, 90, 1, 0) noclipSel.Position = UDim2.new(1, -95, 0, 0) noclipSel.BackgroundTransparency = 1
	noclipSel.Text = Config.Player.Noclip and "SELECT" or "" noclipSel.TextColor3 = Color3.fromRGB(0, 255, 120) noclipSel.TextSize = 14 noclipSel.Font = Enum.Font.GothamBold noclipSel.TextXAlignment = Enum.TextXAlignment.Right noclipSel.ZIndex = 5 noclipSel.Parent = noclipBtn

	noclipBtn.MouseButton1Click:Connect(function()
		local newState = not Config.Player.Noclip
		ToggleNoclip(newState)
		noclipSel.Text = newState and "SELECT" or ""
		noclipBtn.BackgroundColor3 = newState and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		SaveConfig()
	end)
	y = y + 42

	local flyBtn = Instance.new("TextButton")
	flyBtn.Size = UDim2.new(1, -20, 0, 36) flyBtn.Position = UDim2.new(0, 10, 0, y)
	flyBtn.BackgroundColor3 = Config.Player.Fly and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
	flyBtn.Text = "  Fly" flyBtn.TextColor3 = Color3.new(1, 1, 1) flyBtn.TextSize = 15 flyBtn.Font = Enum.Font.GothamBold flyBtn.TextXAlignment = Enum.TextXAlignment.Left flyBtn.ZIndex = 4 flyBtn.Parent = tab
	Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 6)

	local flySel = Instance.new("TextLabel")
	flySel.Size = UDim2.new(0, 90, 1, 0) flySel.Position = UDim2.new(1, -95, 0, 0) flySel.BackgroundTransparency = 1
	flySel.Text = Config.Player.Fly and "SELECT" or "" flySel.TextColor3 = Color3.fromRGB(0, 255, 120) flySel.TextSize = 14 flySel.Font = Enum.Font.GothamBold flySel.TextXAlignment = Enum.TextXAlignment.Right flySel.ZIndex = 5 flySel.Parent = flyBtn

	flyBtn.MouseButton1Click:Connect(function()
		local newState = not Config.Player.Fly
		ToggleFly(newState)
		flySel.Text = newState and "SELECT" or ""
		flyBtn.BackgroundColor3 = newState and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		SaveConfig()
	end)
	y = y + 44

	tab.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

local function BuildFlingTab()
	local tab = Tabs.Fling
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local y = 12

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Name = player.Name btn.Size = UDim2.new(1, -20, 0, 34) btn.Position = UDim2.new(0, 10, 0, y)
			btn.BackgroundColor3 = SelectedTargets[player] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
			btn.Text = "  " .. player.Name btn.TextColor3 = Color3.new(1, 1, 1) btn.TextSize = 15
			btn.Font = Enum.Font.GothamBold btn.TextXAlignment = Enum.TextXAlignment.Left btn.ZIndex = 4 btn.Parent = tab
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

			local sel = Instance.new("TextLabel")
			sel.Size = UDim2.new(0, 90, 1, 0) sel.Position = UDim2.new(1, -95, 0, 0) sel.BackgroundTransparency = 1
			sel.Text = SelectedTargets[player] and "SELECT" or "" sel.TextColor3 = Color3.fromRGB(0, 255, 120)
			sel.TextSize = 14 sel.Font = Enum.Font.GothamBold sel.TextXAlignment = Enum.TextXAlignment.Right sel.ZIndex = 5 sel.Parent = btn

			btn.MouseButton1Click:Connect(function()
				if SelectedTargets[player] then SelectedTargets = {} else SelectedTargets = {[player] = player} end
				BuildFlingTab()
			end)
			y = y + 40
		end
	end

	local startBtn = Instance.new("TextButton")
	startBtn.Size = UDim2.new(0.46, 0, 0, 40) startBtn.Position = UDim2.new(0, 10, 0, y + 10)
	startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0) startBtn.Text = "START FLING"
	startBtn.TextColor3 = Color3.new(1, 1, 1) startBtn.Font = Enum.Font.GothamBold startBtn.TextSize = 15 startBtn.ZIndex = 4 startBtn.Parent = tab
	Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)
	startBtn.MouseButton1Click:Connect(StartFling)

	local stopBtn = Instance.new("TextButton")
	stopBtn.Size = UDim2.new(0.46, 0, 0, 40) stopBtn.Position = UDim2.new(0.52, 0, 0, y + 10)
	stopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0) stopBtn.Text = "STOP FLING"
	stopBtn.TextColor3 = Color3.new(1, 1, 1) stopBtn.Font = Enum.Font.GothamBold stopBtn.TextSize = 15 stopBtn.Parent = tab
	Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)
	stopBtn.MouseButton1Click:Connect(function()
		Config.Fling.Active = false
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then root.Velocity = Vector3.new(0, 0, 0) root.Anchored = false end
		workspace.Gravity = 196.2
	end)

	tab.CanvasSize = UDim2.new(0, 0, 0, y + 70)
end

local function BuildVisualTab()
	local tab = Tabs.Visual
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local y = 12

	local function section(t)
		local s = Instance.new("TextLabel")
		s.Size = UDim2.new(1, -20, 0, 22) s.Position = UDim2.new(0, 10, 0, y) s.BackgroundTransparency = 1
		s.Text = t s.TextColor3 = Color3.fromRGB(160, 160, 160) s.Font = Enum.Font.GothamBold s.TextSize = 13 s.TextXAlignment = Enum.TextXAlignment.Left s.ZIndex = 4 s.Parent = tab
		y = y + 26
	end

	section("---Anti Cauldron (Анти-Котлы)")
	local cauldronBtn = Instance.new("TextButton")
	cauldronBtn.Size = UDim2.new(1, -20, 0, 34) cauldronBtn.Position = UDim2.new(0, 10, 0, y)
	cauldronBtn.BackgroundColor3 = Config.AntiCauldron.Enabled and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
	cauldronBtn.Text = "  Anti Cauldron Spam" cauldronBtn.TextColor3 = Color3.new(1, 1, 1) cauldronBtn.TextSize = 15 cauldronBtn.Font = Enum.Font.GothamBold cauldronBtn.TextXAlignment = Enum.TextXAlignment.Left cauldronBtn.ZIndex = 4 cauldronBtn.Parent = tab
	Instance.new("UICorner", cauldronBtn).CornerRadius = UDim.new(0, 6)

	local cauldronSel = Instance.new("TextLabel")
	cauldronSel.Size = UDim2.new(0, 90, 1, 0) cauldronSel.Position = UDim2.new(1, -95, 0, 0) cauldronSel.BackgroundTransparency = 1
	cauldronSel.Text = Config.AntiCauldron.Enabled and "SELECT" or "" cauldronSel.TextColor3 = Color3.fromRGB(0, 255, 120) cauldronSel.TextSize = 14 cauldronSel.Font = Enum.Font.GothamBold cauldronSel.TextXAlignment = Enum.TextXAlignment.Right cauldronSel.ZIndex = 5 cauldronSel.Parent = cauldronBtn

	cauldronBtn.MouseButton1Click:Connect(function()
		Config.AntiCauldron.Enabled = not Config.AntiCauldron.Enabled
		cauldronSel.Text = Config.AntiCauldron.Enabled and "SELECT" or ""
		cauldronBtn.BackgroundColor3 = Config.AntiCauldron.Enabled and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		SaveConfig()
	end)
	y = y + 44

	section("---Esp")
	local opts = {{n = "Chams esp", k = "Chams"}, {n = "Name esp", k = "Name"}, {n = "Role esp", k = "Role"}, {n = "Line esp", k = "Line"}, {n = "Box esp", k = "Box"}, {n = "Gun esp", k = "Gun"}, {n = "Trap esp", k = "Trap"}}
	for _, o in ipairs(opts) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 34) btn.Position = UDim2.new(0, 10, 0, y)
		btn.BackgroundColor3 = Config.ESP[o.k] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		btn.Text = "  " .. o.n btn.TextColor3 = Color3.new(1, 1, 1) btn.TextSize = 15 btn.Font = Enum.Font.GothamBold btn.TextXAlignment = Enum.TextXAlignment.Left btn.ZIndex = 4 btn.Parent = tab
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local sel = Instance.new("TextLabel")
		sel.Size = UDim2.new(0, 90, 1, 0) sel.Position = UDim2.new(1, -95, 0, 0) sel.BackgroundTransparency = 1
		sel.Text = Config.ESP[o.k] and "SELECT" or "" sel.TextColor3 = Color3.fromRGB(0, 255, 120) sel.TextSize = 14 sel.Font = Enum.Font.GothamBold sel.TextXAlignment = Enum.TextXAlignment.Right sel.ZIndex = 5 sel.Parent = btn

		btn.MouseButton1Click:Connect(function()
			Config.ESP[o.k] = not Config.ESP[o.k]
			sel.Text = Config.ESP[o.k] and "SELECT" or ""
			btn.BackgroundColor3 = Config.ESP[o.k] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
			Config.ESP.Enabled = Config.ESP.Chams or Config.ESP.Name or Config.ESP.Role or Config.ESP.Line or Config.ESP.Box or Config.ESP.Gun or Config.ESP.Trap
			SaveConfig()
		end)
		y = y + 40
	end

	y = y + 10
	section("---Audio & Radio")
	
	local radioBtn = Instance.new("TextButton")
	radioBtn.Size = UDim2.new(1, -20, 0, 34) radioBtn.Position = UDim2.new(0, 10, 0, y)
	radioBtn.BackgroundColor3 = Config.Audio.OffAllRadio and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
	radioBtn.Text = "  Off all radio" radioBtn.TextColor3 = Color3.new(1, 1, 1) radioBtn.TextSize = 15 radioBtn.Font = Enum.Font.GothamBold radioBtn.TextXAlignment = Enum.TextXAlignment.Left radioBtn.ZIndex = 4 radioBtn.Parent = tab
	Instance.new("UICorner", radioBtn).CornerRadius = UDim.new(0, 6)

	local radioSel = Instance.new("TextLabel")
	radioSel.Size = UDim2.new(0, 90, 1, 0) radioSel.Position = UDim2.new(1, -95, 0, 0) radioSel.BackgroundTransparency = 1
	radioSel.Text = Config.Audio.OffAllRadio and "SELECT" or "" radioSel.TextColor3 = Color3.fromRGB(0, 255, 120) radioSel.TextSize = 14 radioSel.Font = Enum.Font.GothamBold radioSel.TextXAlignment = Enum.TextXAlignment.Right radioSel.ZIndex = 5 radioSel.Parent = radioBtn

	radioBtn.MouseButton1Click:Connect(function()
		Config.Audio.OffAllRadio = not Config.Audio.OffAllRadio
		radioSel.Text = Config.Audio.OffAllRadio and "SELECT" or ""
		radioBtn.BackgroundColor3 = Config.Audio.OffAllRadio and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		SaveConfig()
	end)
	y = y + 42

	local songs = {
		{name = "Good luck (Verity)", id = "82057571662059"},
		{name = "Smooth Hill", id = "110398343528156"},
		{name = "The Dream Tree", id = "102616343336371"},
		{name = "TerraAway (Teranowa)", id = "82746224492420"}
	}

	for _, song in ipairs(songs) do
		local songBtn = Instance.new("TextButton")
		songBtn.Size = UDim2.new(1, -20, 0, 32) songBtn.Position = UDim2.new(0, 10, 0, y)
		songBtn.BackgroundColor3 = (Config.Audio.SelectedSongId == song.id) and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		songBtn.Text = "  Play: " .. song.name
		songBtn.TextColor3 = Color3.new(1, 1, 1) songBtn.TextSize = 14 songBtn.Font = Enum.Font.GothamBold songBtn.TextXAlignment = Enum.TextXAlignment.Left songBtn.ZIndex = 4 songBtn.Parent = tab
		Instance.new("UICorner", songBtn).CornerRadius = UDim.new(0, 6)

		songBtn.MouseButton1Click:Connect(function()
			Config.Audio.SelectedSongId = song.id
			SaveConfig()
			PlaySelectedSong(song.id)
			BuildVisualTab()
		end)
		y = y + 38
	end

	y = y + 10
	section("---Colors")
	local roles = {"Murder", "Sheriff", "Innocent", "Gun", "Trap"}
	for _, r in ipairs(roles) do
		local lbl = Instance.new("TextLabel")
		lbl.Name = r lbl.Size = UDim2.new(0, 120, 0, 28) lbl.Position = UDim2.new(0, 14, 0, y) lbl.BackgroundTransparency = 1 lbl.Text = r lbl.TextColor3 = Color3.new(1, 1, 1) lbl.TextSize = 15 lbl.Font = Enum.Font.GothamBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 4 lbl.Parent = tab

		local circle = Instance.new("TextButton")
		circle.Name = r .. "Circle" circle.Size = UDim2.new(0, 26, 0, 26) circle.Position = UDim2.new(1, -50, 0, y + 1)
		circle.BackgroundColor3 = Config.Colors[r].color circle.Text = "" circle.ZIndex = 5 circle.Parent = tab
		Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

		circle.MouseButton1Click:Connect(function()
			if current_key == r then ColorPane.Visible = false current_key = nil else current_key = r ColorPane.Visible = true update_pkr() end
		end)

		task.spawn(function()
			while getgenv().MMV_AdminPanel_Session == currentSession and circle.Parent do
				pcall(function()
					if Config.Colors[r].rainbow then circle.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) else circle.BackgroundColor3 = Config.Colors[r].color end
				end)
				task.wait(0.25)
			end
		end)
		y = y + 36
	end
	tab.CanvasSize = UDim2.new(0, 0, 0, y + 30)
end

local function BuildCombatTab()
	local tab = Tabs.Combat
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local y = 12

	local function section(t)
		local s = Instance.new("TextLabel")
		s.Size = UDim2.new(1, -20, 0, 22) s.Position = UDim2.new(0, 10, 0, y) s.BackgroundTransparency = 1
		s.Text = t s.TextColor3 = Color3.fromRGB(160, 160, 160) s.Font = Enum.Font.GothamBold s.TextSize = 13 s.TextXAlignment = Enum.TextXAlignment.Left s.ZIndex = 4 s.Parent = tab
		y = y + 26
	end

	local function toggle(text, key)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 34) btn.Position = UDim2.new(0, 10, 0, y)
		btn.BackgroundColor3 = Config.Combat[key] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		btn.Text = "  " .. text btn.TextColor3 = Color3.new(1, 1, 1) btn.TextSize = 14 btn.Font = Enum.Font.GothamBold btn.TextXAlignment = Enum.TextXAlignment.Left btn.ZIndex = 4 btn.Parent = tab
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local sel = Instance.new("TextLabel")
		sel.Size = UDim2.new(0, 90, 1, 0) sel.Position = UDim2.new(1, -95, 0, 0) sel.BackgroundTransparency = 1
		sel.Text = Config.Combat[key] and "SELECT" or "" sel.TextColor3 = Color3.fromRGB(0, 255, 120) sel.TextSize = 13 sel.Font = Enum.Font.GothamBold sel.TextXAlignment = Enum.TextXAlignment.Right sel.ZIndex = 5 sel.Parent = btn

		btn.MouseButton1Click:Connect(function()
			Config.Combat[key] = not Config.Combat[key]
			sel.Text = Config.Combat[key] and "SELECT" or ""
			btn.BackgroundColor3 = Config.Combat[key] and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
			SaveConfig()
		end)
		y = y + 40
	end

	section("---Automatic Combat")
	toggle("Auto pick up gun", "AutoGun")
	toggle("Auto shot murder", "AutoShot")
	toggle("Auto kill murder", "AutoKill")
	toggle("Auto throw knife", "AutoThrow")
	toggle("Auto aimbot murder", "Aimbot")

	y = y + 8
	section("---Ui Action Buttons")
	local function uiButtonToggle(text, btnKey)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -20, 0, 34) btn.Position = UDim2.new(0, 10, 0, y)
		local targetScreenBtn = ActionButtons[btnKey]
		btn.BackgroundColor3 = (targetScreenBtn and targetScreenBtn.Visible) and Color3.fromRGB(30, 70, 45) or Color3.fromRGB(52, 52, 52)
		btn.Text = "  " .. text btn.TextColor3 = Color3.new(1, 1, 1) btn.TextSize = 14 btn.Font = Enum.Font.GothamBold btn.TextXAlignment = Enum.TextXAlignment.Left btn.ZIndex = 4 btn.Parent = tab
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local sel = Instance.new("TextLabel")
		sel.Size = UDim2.new(0, 90, 1, 0) sel.Position = UDim2.new(1, -95, 0, 0) sel.BackgroundTransparency = 1
		sel.Text = (targetScreenBtn and targetScreenBtn.Visible) and "SELECT" or "" sel.TextColor3 = Color3.fromRGB(0, 255, 120) sel.TextSize = 13 sel.Font = Enum.Font.GothamBold sel.TextXAlignment = Enum.TextXAlignment.Right sel.ZIndex = 5 sel.Parent = btn

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
	uiButtonToggle("Morph outfit", "MorphBtn")
	uiButtonToggle("Aimbot button", "AimbotBtn")
	uiButtonToggle("Bomb spam button", "BombSpamBtn")

	tab.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

local function BuildInfoTab()
	local tab = Tabs.Info
	for _, c in ipairs(tab:GetChildren()) do c:Destroy() end
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -30, 1, -30) lbl.Position = UDim2.new(0, 15, 0, 15) lbl.BackgroundTransparency = 1
	lbl.Text = "Mmv Script Hub\nPowered by Gemini Ai & ChatGPT\n\nVersion: 5.20.0\n\n- Fixed Audio PlaySong & Noclip toggle\n- Improved Fly with BodyVelocity (WASD + Space/Ctrl)\n- Fixed Fling self-throw glitch\n- Fixed Gun/Trap ESP colors & Item Box/Line ESP"
	lbl.TextColor3 = Color3.fromRGB(190, 190, 190) lbl.TextSize = 15 lbl.Font = Enum.Font.GothamBold lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.TextYAlignment = Enum.TextYAlignment.Top lbl.ZIndex = 4 lbl.Parent = tab
end

BuildPlayerTab()
BuildFlingTab()
BuildVisualTab()
BuildCombatTab()
BuildInfoTab()

Players.PlayerAdded:Connect(BuildFlingTab)
Players.PlayerRemoving:Connect(BuildFlingTab)

-- ====================== УМНЫЙ ГЛАВНЫЙ ЦИКЛ ======================
task.spawn(function()
	while getgenv().MMV_AdminPanel_Session == currentSession and getgenv().MMV_AdminPanel_Running do
		local anyActive = Config.ESP.Enabled or Config.Audio.OffAllRadio or Config.Combat.Aimbot or Config.Combat.AutoGun or Config.Combat.AutoShot or Config.Combat.AutoKill or Config.Combat.AutoThrow or Config.Combat.BombSpamActive or Config.AntiCauldron.Enabled or Config.Player.Enabled or Config.Player.Noclip or Config.Player.Fly

		if anyActive then
			if Config.ESP.Enabled then pcall(UpdateESP) end
			if Config.Audio.OffAllRadio then pcall(ProcessAudio) end
			if Config.Combat.Aimbot then pcall(RunAimbot) end
			if Config.Combat.AutoGun and not HasGun() then pcall(PickUpGun) end
			if Config.Combat.AutoShot then pcall(ShotMurder) end
			if Config.Combat.AutoKill then pcall(KillMurder) end
			if Config.Combat.AutoThrow then pcall(ThrowKnifeAtNearest) end
			if Config.Combat.BombSpamActive then pcall(TriggerBombSpam) end
			if Config.AntiCauldron.Enabled then pcall(ProcessCauldrons) end
			
			pcall(function()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					if Config.Player.Enabled then
						hum.WalkSpeed = Config.Player.WalkSpeed
						hum.JumpPower = Config.Player.JumpPower
					else
						hum.WalkSpeed = 16
						hum.JumpPower = 50
					end
				end
			end)

			task.wait(0.08)
		else
			ClearAllESP()
			task.wait(0.4)
		end
	end
	ClearAllESP()
end)

print("[MMV Admin Panel] v5.20.0 успешно загружена!")
