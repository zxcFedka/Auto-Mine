if not game.PlaceId == 8737899170 then return end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Mine",
    Icon = 0,
    LoadingTitle = "Pidaras Hub", -- Измени на более подходящее название, если хочешь
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
local MineSection = MainTab:CreateSection("Mine")
MineSection:Set("Finding Ore")

local Ores = {
    "Sapphire",
    "Ruby",
    "Amethyst",
    "Emerald",
}

local FindingOre = "Sapphire"

local DropdownOre = MainTab:CreateDropdown({ -- Переименовал переменную, чтобы не было конфликта имен
    Name = "Mining Ore",
    Options = Ores,
    CurrentOption = "Sapphire", -- Исправлено: убраны {}
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option) -- Изменено на Option, так как приходит только 1 значение
        FindingOre = Option -- Исправлено: прямое присвоение
    end,
})

local Divider1 = MainTab:CreateDivider() -- Переименовал переменную, чтобы не было конфликта имен

local Types = {
    [1] = "Xray",
    [2] = "Auto Farm"
}

local FarmType = 1

local DropdownType = MainTab:CreateDropdown({ -- Переименовал переменную, чтобы не было конфликта имен
    Name = "Mining Type",
    Options = Types,
    CurrentOption = Types[FarmType], -- Исправлено: убраны {}
    MultipleOptions = false,
    Flag = "Dropdown2",
    Callback = function(Option) -- Изменено на Option, так как приходит только 1 значение
        for index, typeName in pairs(Types) do -- Лучше использовать pairs для словарей
            if typeName == Option then
                FarmType = index
                break -- Выходим из цикла, когда нашли соответствие
            end
        end
    end,
})

local Divider2 = MainTab:CreateDivider() -- Переименовал переменную, чтобы не было конфликта имен

local Locations = {
    [1] = "Mining Ore",
    [2] = "Ancient Cave",
    [3] = "Frozen Echo",
    [4] = "Deep Abyss",
    [5] = "Abstract Void",
}

local CurrentLocation = 1

local DropdownLocation = MainTab:CreateDropdown({ -- Переименовал переменную, чтобы не было конфликта имен
    Name = "Location",
    Options = Locations,
    CurrentOption = Locations[CurrentLocation], -- Исправлено: убраны {}
    MultipleOptions = false,
    Flag = "Dropdown3",
    Callback = function(Option) -- Изменено на Option, так как приходит только 1 значение
        for index, locationName in pairs(Locations) do -- Лучше использовать pairs для словарей
            if locationName == Option then
                CurrentLocation = index
                break -- Выходим из цикла, когда нашли соответствие
            end
        end
    end,
})

local Divider3 = MainTab:CreateDivider() -- Переименовал переменную, чтобы не было конфликта имен

local BlockWorlds = workspace:WaitForChild("__THINGS").BlockWorlds

local HighlightXrayName = "Xrayhighlight"

local debounce = false
local IsFarming = false

local Button = MainTab:CreateButton({
    Name = "Start Farming",
    Callback = function()
        farmingToggled(IsFarming)
    end,
})

local function clearHighlightsForLocation() -- Функция для очистки хайлайтов, чтобы избежать дублирования кода
    if CurrentLocation then
        if FarmType == 1 then -- Проверка FarmType здесь избыточна, так как функция используется только для Xray
            local Path = "Blocks_" .. CurrentLocation
            if BlockWorlds:FindFirstChild(Path) then
                local Blocks = BlockWorlds:FindFirstChild(Path)
                for _, block in ipairs(Blocks:GetChildren()) do -- ipairs для массивов
                    if block and block:FindFirstChild(HighlightXrayName) then
                        block:FindFirstChild(HighlightXrayName):Destroy()
                    end
                end
            end
        end
    end
end


function farmingToggled(IsToggled)
    if debounce then return end -- Упрощенная проверка debounce
    debounce = true
    IsFarming = not IsFarming

    task.delay(0.2, function() -- Уменьшил задержку debounce
        debounce = false
    end)

    if IsFarming then -- Исправлено: проверка IsFarming, а не IsToggled
        Button:Set("Stop Farming")
        clearHighlightsForLocation() -- Очищаем старые хайлайты перед добавлением новых
        if CurrentLocation then
            if FarmType == 1 then
                local Path = "Blocks_" .. CurrentLocation
                if BlockWorlds:FindFirstChild(Path) then
                    local Blocks = BlockWorlds:FindFirstChild(Path)
                    for _, block in ipairs(Blocks:GetChildren()) do -- ipairs для массивов
                        if block then
                            if block:GetAttribute("id") and block:GetAttribute("id") == FindingOre then
                                local Highlight = Instance.new("Highlight", block)
                                Highlight.Name = HighlightXrayName
                                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            end
                        end
                    end
                end
            end
        end
    else
        Button:Set("Start Farming")
        clearHighlightsForLocation() -- Очищаем хайлайты при остановке фарма
    end
end

local SettingsTab = Window:CreateTab("Settings", nil)
local SettingsSection = SettingsTab:CreateSection("SettingsSection")
SettingsSection:Set("Theme")

local Themes = {
    "Default",
    "Amber Glow",
    "Amethyst",
    "Bloom",
    "Dark Blue",
    "Green",
    "Light",
    "Ocean",
    "Serenity",
}

local DropdownTheme = SettingsTab:CreateDropdown({ -- Переименовал переменную, чтобы не было конфликта имен
    Name = "Theme",
    Options = Themes,
    CurrentOption = "Default",
    MultipleOptions = false,
    Flag = "Dropdown4",
    Callback = function(Option) -- Изменено на Option, так как приходит только 1 значение
        Window:ModifyTheme(Option) -- Исправлено: прямое использование Option
    end,
})