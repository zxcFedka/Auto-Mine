if not game.PlaceId == 8737899170 then return end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

print("Loaded")

local Button

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

local DropdownOre = MainTab:CreateDropdown({
    Name = "Mining Ore",
    Options = Ores,
    CurrentOption = "Sapphire",
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        for i,choosedore in Option do
            print(choosedore)
            clearHighlightsForLocation()
            FindingOre = choosedore
            if IsFarming then
                IsFarming = false
                Button:Set("Start Farming")
            end
        end
    end,
})

local Divider1 = MainTab:CreateDivider()

local Types = {
    [1] = "Xray",
    [2] = "Auto Farm"
}

local FarmType = 1

local DropdownType = MainTab:CreateDropdown({
    Name = "Mining Type",
    Options = Types,
    CurrentOption = Types[FarmType],
    MultipleOptions = false,
    Flag = "Dropdown2",
    Callback = function(Option)
        for index, typeName in pairs(Types) do
            if typeName == Option then
                FarmType = index
            end
        end
    end,
})

local Divider2 = MainTab:CreateDivider()

local Locations = {
    [1] = "Mining Ore",
    [2] = "Ancient Cave",
    [3] = "Frozen Echo",
    [4] = "Deep Abyss",
    [5] = "Abstract Void",
}

local CurrentLocation = 1

local DropdownLocation = MainTab:CreateDropdown({
    Name = "Location",
    Options = Locations,
    CurrentOption = Locations[CurrentLocation],
    MultipleOptions = false,
    Flag = "Dropdown3",
    Callback = function(Option)
        for index, locationName in pairs(Locations) do
            if locationName == Option then
                CurrentLocation = index
            end
        end
    end,
})

local Divider3 = MainTab:CreateDivider()

local BlockWorlds = workspace:WaitForChild("__THINGS").BlockWorlds

local HighlightXrayName = "Xrayhighlight"

local debounce = false
local IsFarming = false

Button = MainTab:CreateButton({
    Name = "Start Farming",
    Callback = function()
        farmingToggled(IsFarming)
    end,
})

function clearHighlightsForLocation()
    print("Clear")
    if CurrentLocation then
        if FarmType == 1 then
            local Path = "Blocks_" .. CurrentLocation
            if BlockWorlds:FindFirstChild(Path) then
                local Blocks = BlockWorlds:FindFirstChild(Path)
                for _, block in ipairs(Blocks:GetChildren()) do
                    if block and block:FindFirstChild(HighlightXrayName) then
                        block:FindFirstChild(HighlightXrayName):Destroy()
                    end
                end
            end
        end
    end
end

local AddedBlocks = {}

function farmingToggled(IsToggled)
    if debounce then return end
    debounce = true
    IsFarming = not IsFarming

    task.delay(0.2, function()
        debounce = false
    end)

    if IsFarming then
        Button:Set("Stop Farming")
        if CurrentLocation then
            if FarmType == 1 then
                local Path = "Blocks_" .. CurrentLocation
                if BlockWorlds:FindFirstChild(Path) then
                    local Blocks = BlockWorlds:FindFirstChild(Path)

                    for i,block in AddedBlocks do
                        if block then
                            if block:FindFirstChild(HighlightXrayName) then
                                block:FindFirstChild(HighlightXrayName):Destroy()
                            end

                            local Highlight = Instance.new("Highlight", block)
                            Highlight.Name = HighlightXrayName
                            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                    end

                    Blocks.ChildAdded:Connect(function(block)
                        if block:GetAttribute("id") and block:GetAttribute("id") == FindingOre then
                            AddedBlocks[block]= true
                        end
                    end)
                end
            end
        end
    else
        Button:Set("Start Farming")
        clearHighlightsForLocation()
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

local DropdownTheme = SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = Themes,
    CurrentOption = "Default",
    MultipleOptions = false,
    Flag = "Dropdown4",
    Callback = function(Option)
        Window:ModifyTheme(Option)
    end,
})