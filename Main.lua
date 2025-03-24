if not game.PlaceId == 8737899170 then return end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
Name = "Auto Mine",
Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
LoadingTitle = "Pidaras Hub",
LoadingSubtitle = "by zxcFedka",
Theme = "Default",

DisableRayfieldPrompts = false,
DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

ConfigurationSaving = {
Enabled = false,
FolderName = nil, -- Create a custom folder for your hub/game
FileName = "Big Hub"
},

Discord = {
Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
RememberJoins = true -- Set this to false to make them join the discord every time they load it up
},

KeySystem = false, -- Set this to true to use our key system
KeySettings = {
Title = "Untitled",
Subtitle = "Key System",
Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
}
})

local MainTab = Window:CreateTab("Home", nil) -- Title, Image
local MineSection = MainTab:CreateSection("Mine")
MineSection:Set("Finding Ore")

local Ores = {
    "Sapphire",
    "Ruby",
    "Amethyst",
    "Emerald",
}

local FindingOre = "Sapphire"

local Dropdown = MainTab:CreateDropdown({
    Name = "Mining Ore",
    Options = Ores,
    CurrentOption = {"Sapphire"},
    MultipleOptions = false,
    Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Options)
        for index, ore in ipairs(Options) do
            FindingOre = ore
        end
    end,
})

local Divider = MainTab:CreateDivider()

local Types = {
    [1] = "Xray",
    [2]= "Auto Farm"
}

local FarmType = 1

local Dropdown = MainTab:CreateDropdown({
    Name = "Mining Type",
    Options = Types,
    CurrentOption = {Types[FarmType]},
    MultipleOptions = false,
    Flag = "Dropdown2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Options)
        for index, farmType in pairs(Options) do
            FarmType = index
        end
    end,
})

local Divider = MainTab:CreateDivider()

local Locations = {
    [1] = "Mining Ore",
    [2] = "Ancient Cave",
    [3] = "Frozen Echo",
    [4] = "Deep Abyss",
    [5] = "Abstract Void",
}

local CurrentLocation = 1

local Dropdown = MainTab:CreateDropdown({
    Name = "Location",
    Options = Locations,
    CurrentOption = {Locations[CurrentLocation]},
    MultipleOptions = false,
    Flag = "Dropdown3", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Options)
        for index, Loc in pairs(Options) do
            CurrentLocation = Loc
        end
    end,
})

local Divider = MainTab:CreateDivider()

local BlockWorlds = workspace:WaitForChild("__THINGS").BlockWorlds

local HighlightXrayName = "Xrayhighlight"

local debounce = false
local IsFarming = false

local function farmingToggled(IsToggled)
    if IsToggled then
        if CurrentLocation then
            if FarmType == 1 then
                print("Success")
                local Path = "Blocks_"..CurrentLocation
                if BlockWorlds:FindFirstChild(Path) then
                    print("Path Finded")
                    local Blocks = BlockWorlds:FindFirstChild(Path)

                    for i, block in Blocks:GetChildren() do
                        if block then
                            if block:FindFirstChild(HighlightXrayName) then
                                block:FindFirstChild(HighlightXrayName):Destroy()
                            end
                        end
                    end

                    for i, block in Blocks:GetChildren() do
                        if block:GetAttribute("id") and block:GetAttribute("id") == FindingOre then
                            print("Finded")
                            local Highlight = Instance.new("Highlight", block)
                            Highlight.Name = Highlight
                            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                    end
                end
            end 
        end
    end
end

local Toggle = MainTab:CreateToggle({
    Name = "Farming",
    CurrentValue = false,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        if not debounce then
            debounce = true
            IsFarming = Value

            farmingToggled(Value)

            task.delay(1, function()
                debounce = false
            end)
        end
    end,
})

local SettingsTab = Window:CreateTab("Settings", nil) -- Title, Image
local SettingsSection = SettingsTab:CreateSection("SettingsSection")
SettingsSection:Set("Theme")

local Themes = {
    "Default";
    "Amber Glow";
    "Amethyst";
    "Bloom";
    "Dark Blue";
    "Green";
    "Light";
    "Ocean";
    "Serenity";
}

local Dropdown = SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = Themes,
    CurrentOption = "Default",
    MultipleOptions = false,
    Flag = "Dropdown4", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Options)
        for index, theme in ipairs(Options) do
            Window.ModifyTheme(tostring(theme))
        end
    end,
})