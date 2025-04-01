if not game.PlaceId == 8737899170 then return end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

print("Rayfield Loaded")

local player = game.Players.LocalPlayer
local debugLabel

if player.PlayerGui:FindFirstChild("DebugGui") then
    debugLabel = player.PlayerGui:FindFirstChild("DebugGui").DebugLabel
else
    local DebugGui = Instance.new("ScreenGui", player.PlayerGui)
    DebugGui.Name = "DebugGui"

    debugLabel = Instance.new("TextLabel", DebugGui)
    debugLabel.Name = "DebugLabel"
end

local Window = Rayfield:CreateWindow({
    Name = "Auto Mine",
    Icon = 0,
    LoadingTitle = "Mining Hub",
    LoadingSubtitle = "by zxcFedka",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "Big Hub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local MainTab = Window:CreateTab("Home", nil)
local MineSection = MainTab:CreateSection("AutoFarm")
MineSection:Set("Settings")

local BlockWorlds = workspace.__THINGS.BlockWorlds
local Camera = workspace.CurrentCamera
local BlackList = {}
local FindingOre = "Sapphire"
local path = nil
local oresByType = {}
local ChoosedOre = nil
local Connection = nil
local IsToggled = false

local UserInputService = game:GetService("UserInputService")

local Ores = {
    "Sapphire",
    "Ruby",
    "Amethyst",
    "Emerald",
    "Rainbow",
    "Quartz",
    "BasicChest",
    "RareChest",
    "EpicChest",
}

local function FindBlockWorldsPath()
    for _, block in BlockWorlds:GetChildren() do
        if string.find(block.Name, "Blocks_") then
            return block
        end
    end
    return nil
end

local function refreshOres()
    oresByType = {}
    if FindBlockWorldsPath() then
        for _, oreType in ipairs(Ores) do
            oresByType[oreType] = {}
        end
        for _, block in FindBlockWorldsPath():GetChildren() do
            local oreId = block:GetAttribute("id")
            if oresByType[oreId] then
                table.insert(oresByType[oreId], block)
            end
        end
        for oreType, oreList in pairs(oresByType) do
            print(string.format("-> refreshOres(): Найдено %d блоков типа %s", #oreList, oreType))
        end
    else
        print("-> refreshOres(): Путь BlockWorlds не найден!")
    end
end

local function randomOre()
    if not IsToggled then return end

    local selectedOreType = FindingOre
    local availableOre = nil

    -- Фильтрация руд, исключая руды из черного списка
    local filteredOres = {}
    if oresByType[selectedOreType] then
        for _, ore in ipairs(oresByType[selectedOreType]) do
            if not BlackList[selectedOreType] then -- Проверяем, не заблокирован ли тип руды целиком
                filteredOres[#filteredOres + 1] = ore
            end
        end
    end

    -- Пытаемся найти выбранную руду из отфильтрованного списка
    if #filteredOres > 0 then
        availableOre = filteredOres[math.random(1, #filteredOres)]
        print(string.format("  -> randomOre(): Выбрана руда %s (выбранная игроком, не из черного списка)", selectedOreType))
    else
        -- Если выбранной руды нет или все в черном списке, ищем любую другую по приоритету из списка Ores
        for _, oreType in ipairs(Ores) do
            if oreType ~= selectedOreType and not BlackList[oreType] and oresByType[oreType] and #oresByType[oreType] > 0 then -- Проверяем, не заблокирован ли тип руды
                filteredOres = {} -- Очищаем список отфильтрованных руд для нового типа
                for _, ore in ipairs(oresByType[oreType]) do
                    if not BlackList[oreType] then -- Дополнительная проверка на всякий случай
                        filteredOres[#filteredOres + 1] = ore
                    end
                end
                if #filteredOres > 0 then
                    availableOre = filteredOres[math.random(1, #filteredOres)]
                    print(string.format("  -> randomOre(): Выбрана руда %s (альтернативная, не из черного списка)", oreType))
                    break
                end
            end
        end
    end

    local Player = game.Players.LocalPlayer
    local Char = Player.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then
        print("  -> randomOre(): Персонаж или HumanoidRootPart не найдены!")
        return
    end
    local HumanoidRootPart = Char.HumanoidRootPart

    ChoosedOre = availableOre

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    if ChoosedOre then -- Добавлена проверка на nil перед подключением RenderStepped
        local RunService = game:GetService("RunService")
        Connection = RunService.RenderStepped:Connect(function()
            if ChoosedOre and ChoosedOre.Parent then
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = ChoosedOre.CFrame

                    local cameraPosition = Camera.CFrame.Position
                    local direction = (ChoosedOre.Position - cameraPosition).Unit
                    local lookAtCFrame = CFrame.lookAt(cameraPosition, ChoosedOre.Position)
                    Camera.CFrame = lookAtCFrame
                else
                    print("  -> RenderStepped: HumanoidRootPart стал nil!")
                end
            else
                print("  -> RenderStepped: ChoosedOre стал nil или удален, поиск новой руды...")
                Connection:Disconnect()
                Connection = nil
                ChoosedOre = nil
                refreshOres()
                randomOre()
            end
        end)
    else
        print("  -> randomOre(): Не найдено доступных руд, включая не из черного списка. Повторная попытка через некоторое время...")
        task.delay(5, randomOre) -- Повторная попытка через 5 секунд, если руда не найдена
    end
end

function startAutoFarm()
    if not IsToggled then
        IsToggled = true
        print("AutoFarm включен")
        randomOre()

		Rayfield:Notify({
            Title = "Auto Farm",
            Content = "Enabled",
            Duration = 3,
            Image = 4483362458,
        })
    end
end

function stopAutoFarm()
    if IsToggled then
        IsToggled = false
        print("AutoFarm выключен")
        if Connection then
            Connection:Disconnect()
            Connection = nil
            ChoosedOre = nil
        end

		Rayfield:Notify({
            Title = "Auto Farm",
            Content = "Disabled",
            Duration = 3,
            Image = 4483362458,
        })
    end
end

local DropdownBlackList = MainTab:CreateDropdown({
    Name = "Black List",
    Options = Ores,
    CurrentOption = nil,
    MultipleOptions = true,
    Flag = "Dropdown3",
    Callback = function(Option)
        BlackList = {} -- Очищаем BlackList перед обновлением
        for ore, enabled in pairs(Option) do
            if enabled then
                BlackList[ore] = true
            end
        end
        print("BlackList обновлен:", BlackList)
    end,
})

local DropdownOre = MainTab:CreateDropdown({
    Name = "Mining Ore",
    Options = Ores,
    CurrentOption = "Sapphire",
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        local choosedore = Option[1]
        FindingOre = choosedore
        print("Выбрана руда для AutoFarm:", choosedore)
        refreshOres()
        if IsToggled then
            randomOre()
        end
    end,
})

local Divider1 = MainTab:CreateDivider()

local ToggleAutoFarm = MainTab:CreateToggle({
    Name = "AutoFarm",
    CurrentValue = false,
    Flag = "ToggleAutoFarm",
    Callback = function(Value)
        if Value then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end,
})

path = FindBlockWorldsPath()

if path then
    refreshOres()
    print("Первоначальное состояние oresByType после refreshOres:")
    for oreType, oreList in pairs(oresByType) do
        print(string.format("  - %s: %d блоков", oreType, #oreList))
    end

    path.ChildAdded:Connect(function(block)
        local oreId = block:GetAttribute("id")
        if oresByType[oreId] then
            table.insert(oresByType[oreId], block)
            print(string.format("-> ChildAdded: Блок %s (%s) добавлен. Теперь блоков %s: %d", block.Name, oreId, oreId, #oresByType[oreId]))
            if IsToggled then
                randomOre()
            end
        end
    end)

    path.ChildRemoved:Connect(function(block)
        local oreId = block:GetAttribute("id")
        if oresByType[oreId] then
            for i, v in ipairs(oresByType[oreId]) do
                if v == block then
                    table.remove(oresByType[oreId], i)
                    print(string.format("  -> ChildRemoved: Блок %s (%s) удален. Теперь блоков %s: %d", block.Name, oreId, oreId, #oresByType[oreId]))
                    break
                end
            end

            if ChoosedOre == block then
                print("  -> ChildRemoved: Удаленный блок был ChoosedOre.")
                ChoosedOre = nil
                print("  -> ChildRemoved: ChoosedOre сброшен в nil.")

                if IsToggled then
                    randomOre()
                end
            end
        end
    end)
else
    print("Путь к BlockWorlds не найден! Скрипт AutoFarm не будет работать.")
end