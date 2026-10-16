-- привет любитель кражи кода, ну или челика которому страшно за свой аккаунт, добро пожаловать можешь изучить или взять код, мне не жалко<3
-- Защита от повторного запуска
if getgenv().MMVESP_Running then
    getgenv().MMVESP_Running = false
    task.wait(0.5)
end
getgenv().MMVESP_Running = true

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Создание GUI управления (с перетаскиванием)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MMVESPGui"
ScreenGui.ResetOnSpawn = false

local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 180, 0, 170)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MMV ESP & Combat"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

-- Кнопка ESP ON/OFF
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.075, 0, 0.22, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "ESP: ON"
ToggleButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleButton

-- Кнопка Авто-подбора пистолета ON/OFF
local AutoGunButton = Instance.new("TextButton")
AutoGunButton.Size = UDim2.new(0.85, 0, 0, 30)
AutoGunButton.Position = UDim2.new(0.075, 0, 0.49, 0)
AutoGunButton.BackgroundColor3 = Color3.fromRGB(170, 170, 0)
AutoGunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoGunButton.TextSize = 12
AutoGunButton.Font = Enum.Font.SourceSansBold
AutoGunButton.Text = "Auto Gun: ON"
AutoGunButton.Parent = MainFrame

local AutoBtnCorner = Instance.new("UICorner")
AutoBtnCorner.CornerRadius = UDim.new(0, 6)
AutoBtnCorner.Parent = AutoGunButton

-- Кнопка ручного выстрела по убийце (SHOOT)
local ShootButton = Instance.new("TextButton")
ShootButton.Size = UDim2.new(0.85, 0, 0, 30)
ShootButton.Position = UDim2.new(0.075, 0, 0.76, 0)
ShootButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255) -- Синяя кнопка выстрела
ShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootButton.TextSize = 12
ShootButton.Font = Enum.Font.SourceSansBold
ShootButton.Text = "SHOOT KILLER"
ShootButton.Parent = MainFrame

local ShootCorner = Instance.new("UICorner")
ShootCorner.CornerRadius = UDim.new(0, 6)
ShootCorner.Parent = ShootButton

local espEnabled = true
local autoGunEnabled = true

ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.Text = "ESP: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "ESP: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

AutoGunButton.MouseButton1Click:Connect(function()
    autoGunEnabled = not autoGunEnabled
    if autoGunEnabled then
        AutoGunButton.Text = "Auto Gun: ON"
        AutoGunButton.BackgroundColor3 = Color3.fromRGB(170, 170, 0)
    else
        AutoGunButton.Text = "Auto Gun: OFF"
        AutoGunButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)

local highlights = {}
local billboards = {}

local function updateHighlight(obj, color)
    if not obj then return end
    local hl = highlights[obj]
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "MMV_ESP_HL"
        hl.Adornee = obj
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0.2
        hl.FillTransparency = 0.4
        hl.Parent = obj
        highlights[obj] = hl
    end
    hl.FillColor = color
    hl.Enabled = espEnabled
end

local function updateBillboard(obj, text, color)
    if not obj then return end
    local bg = billboards[obj]
    if not bg then
        bg = Instance.new("BillboardGui")
        bg.Name = "MMV_ESP_Tag"
        bg.Size = UDim2.new(0, 120, 0, 40)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.Adornee = obj

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Label"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextSize = 13
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextStrokeTransparency = 0
        textLabel.Parent = bg

        bg.Parent = obj
        billboards[obj] = bg
    end

    bg.Enabled = espEnabled
    local lbl = bg:FindFirstChild("Label")
    if lbl then
        lbl.Text = text
        lbl.TextColor3 = color
    end
end

local function clearAll()
    for _, hl in pairs(highlights) do if hl then hl:Destroy() end end
    for _, bg in pairs(billboards) do if bg then bg:Destroy() end end
    highlights = {}
    billboards = {}
end

-- Кэш ролей
local roleCache = {}
local lastCheck = 0

local function checkPlayerRole(player)
    if tick() - lastCheck > 1 then
        lastCheck = tick()
        local success, data = pcall(function()
            return ReplicatedStorage.Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
        end)
        if success and type(data) == "table" then
            roleCache = data
        end
    end

    if roleCache and roleCache[player.Name] then
        local pData = roleCache[player.Name]
        local role = pData.Role or pData.Team
        if role then
            local lower = string.lower(tostring(role))
            if lower:find("murder") or lower:find("killer") then
                return "Killer", Color3.fromRGB(255, 0, 0)
            elseif lower:find("sheriff") then
                return "Sheriff", Color3.fromRGB(0, 0, 255)
            elseif lower:find("innocent") then
                return "Innocent", Color3.fromRGB(0, 255, 0)
            end
        end
    end

    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local hasKnife, hasGun = false, false

    local containers = {char, backpack}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:FindFirstChild("IsGun") then hasGun = true end
                if item:FindFirstChild("IsKnife") or item.Name == "Knife" then hasKnife = true end
            end
        end
    end

    if hasKnife then
        return "Killer", Color3.fromRGB(255, 0, 0)
    elseif hasGun then
        return "Sheriff", Color3.fromRGB(0, 0, 255)
    else
        return "Innocent", Color3.fromRGB(0, 255, 0)
    end
end

local function localPlayerHasGun()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local containers = {char, backpack}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:FindFirstChild("IsGun") or item.Name:lower():find("gun") then
                    return true
                end
            end
        end
    end
    return false
end

-- Функция выстрела по нажатию на кнопку
ShootButton.MouseButton1Click:Connect(function()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("DefaultGun")
    if not tool then
        -- Пробуем найти пистолет в рюкзаке, если он не экипирован в руках
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            tool = backpack:FindFirstChild("DefaultGun")
        end
    end

    if not tool then return end
    local remote = tool:FindFirstChild("KnifeServer") and tool.KnifeServer:FindFirstChild("SlashStart")
    if not remote then return end

    -- Ищем убийцу на карте и стреляем в него
    local targetFound = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role, _ = checkPlayerRole(player)
            if role == "Killer" then
                local killerHrp = player.Character:FindFirstChild("HumanoidRootPart")
                if killerHrp then
                    targetFound = true
                    pcall(function()
                        remote:FireServer(1, killerHrp.Position)
                    end)
                    break
                end
            end
        end
    end
end)

-- Основной фоновый цикл (ESP + Автоподбор)
task.spawn(function()
    while getgenv().MMVESP_Running do
        if espEnabled then
            -- 1. Игроки
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local role, color = checkPlayerRole(player)
                    local tagText = player.Name .. "_" .. role
                    updateHighlight(player.Character, color)
                    updateBillboard(player.Character, tagText, color)
                end
            end

            -- 2. Упавший пистолет (GunDrop)
            local gunDrop = workspace:FindFirstChild("GunDrop")
            if gunDrop then
                updateBillboard(gunDrop, "Gun", Color3.fromRGB(255, 255, 0))
                updateHighlight(gunDrop, Color3.fromRGB(255, 255, 0))

                if autoGunEnabled and not localPlayerHasGun() then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local targetPart = gunDrop:IsA("Model") and (gunDrop.PrimaryPart or gunDrop:FindFirstChildWhichIsA("BasePart")) or gunDrop
                        if targetPart and targetPart:IsA("BasePart") then
                            pcall(function()
                                firetouchinterest(hrp, targetPart, 0)
                                task.wait()
                                firetouchinterest(hrp, targetPart, 1)
                            end)
                        end
                    end
                end
            else
                for obj, bg in pairs(billboards) do
                    if obj and obj.Name == "GunDrop" then
                        bg:Destroy()
                        billboards[obj] = nil
                        if highlights[obj] then
                            highlights[obj]:Destroy()
                            highlights[obj] = nil
                        end
                    end
                end
            end

            -- 3. Капканы
            for _, obj in ipairs(workspace:GetDescendants()) do
                local nameLower = obj.Name:lower()
                if nameLower:find("trap") and not nameLower:find("strap") then
                    local targetObj = obj
                    if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") and obj.Parent ~= workspace then
                        targetObj = obj.Parent
                    end

                    local isVisible = true
                    if targetObj:IsA("BasePart") and targetObj.Transparency >= 0.99 then
                        isVisible = false
                    end

                    if isVisible then
                        updateBillboard(targetObj, "Trap", Color3.fromRGB(255, 0, 0))
                        updateHighlight(targetObj, Color3.fromRGB(255, 0, 0))
                    end
                end
            end
        else
            for _, hl in pairs(highlights) do if hl then hl.Enabled = false end end
            for _, bg in pairs(billboards) do if bg then bg.Enabled = false end end
        end

        task.wait(0.4)
    end
end)

LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer:IsParentOf(game) then
        getgenv().MMVESP_Running = false
        clearAll()
        ScreenGui:Destroy()
    end
end)
