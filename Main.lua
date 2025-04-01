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
local FindingOre = "Sapphire" -- Дефолтное значение, изменится через UI
local path = nil
local oresByType = {} -- Изменено: Теперь храним руды по типам
local ChoosedOre = nil
local Connection = nil
local IsToggled = false -- Состояние телепортации: false - выключена, true - включена

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
    oresByType = {} -- Очищаем старые данные
    if FindBlockWorldsPath() then
        for _, oreType in ipairs(Ores) do
            oresByType[oreType] = {} -- Инициализируем пустой список для каждого типа руды
        end
        for _, block in FindBlockWorldsPath():GetChildren() do
            local oreId = block:GetAttribute("id")
            if oresByType[oreId] then -- Проверяем, есть ли такой тип руды в списке Ores
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
    if not IsToggled then return end -- Выходим, если AutoFarm выключен

    local selectedOreType = FindingOre
    local availableOre = nil

    -- Пытаемся найти выбранную руду
    if oresByType[selectedOreType] and #oresByType[selectedOreType] > 0 then
        availableOre = oresByType[selectedOreType][math.random(1, #oresByType[selectedOreType])]
        print(string.format("  -> randomOre(): Выбрана руда %s (выбранная игроком)", selectedOreType))
    else
        -- Если выбранной руды нет, ищем любую другую по приоритету из списка Ores
        for _, oreType in ipairs(Ores) do
            if oreType ~= selectedOreType and oresByType[oreType] and #oresByType[oreType] > 0 then
                availableOre = oresByType[oreType][math.random(1, #oresByType[oreType])]
                print(string.format("  -> randomOre(): Выбрана руда %s (альтернативная)", oreType))
                break -- Нашли первую попавшуюся и выходим
            end
        end
    end

    -- if not availableOre then
    --     print("  -> randomOre(): Нет доступной руды ни одного типа!")
    --     ChoosedOre = nil -- Сбрасываем ChoosedOre, чтобы остановить телепортацию
    --     stopAutoFarm() -- Останавливаем AutoFarm, если нет руды
    --     return
    -- end

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

    local RunService = game:GetService("RunService")
    Connection = RunService.RenderStepped:Connect(function()
        if ChoosedOre and ChoosedOre.Parent then -- Проверяем, что ChoosedOre существует и не удален
            if HumanoidRootPart then
                HumanoidRootPart.CFrame = ChoosedOre.CFrame
            else
                print("  -> RenderStepped: HumanoidRootPart стал nil!")
            end
        else
            print("  -> RenderStepped: ChoosedOre стал nil или удален, поиск новой руды...")
            Connection:Disconnect() -- Отключаем текущее соединение, чтобы не было ошибок
            Connection = nil
            ChoosedOre = nil
			refreshOres()
            randomOre() -- Ищем новую руду
        end
    end)
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
        refreshOres() -- Обновляем список руды при смене типа руды
        if IsToggled then -- Если AutoFarm уже включен, перезапускаем с новой рудой
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
                    randomOre() -- Попытка найти новую руду, если AutoFarm включен
                end
            end
        end
    end)
else
    print("Путь к BlockWorlds не найден! Скрипт AutoFarm не будет работать.")
end