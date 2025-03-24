if not game.PlaceId == 8737899170 then return end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

print("Rayfield Loaded") -- Keep this print for initial load confirmation in console

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
local MineSection = MainTab:CreateSection("Mine")
MineSection:Set("Ore and Location Settings") -- English section title

local Ores = {
    "Sapphire",
    "Ruby",
    "Amethyst",
    "Emerald",
}

local Locations = {
    [1] = "Mining Ore",
    [2] = "Ancient Cave",
    [3] = "Frozen Echo",
    [4] = "Deep Abyss",
    [5] = "Abstract Void",
}

local FindingOre = "Sapphire"
local AddedBlocks = {}
local HighlightXrayName = "XrayHighlight"
local CurrentLocation = 1

local XrayToggled = false

local BlockWorlds = workspace:WaitForChild("__THINGS").BlockWorlds

local function update()
    print("Updating block list for", Locations[CurrentLocation], "and ore", FindingOre) -- Removed print

    if CurrentLocation then
        local Path = "Blocks_" .. CurrentLocation
        if BlockWorlds:FindFirstChild(Path) then
            local Blocks = BlockWorlds:FindFirstChild(Path)
            for block, i in Blocks:GetChildren() do
                if block and block:GetAttribute("id") and block:GetAttribute("id") == FindingOre then
                    if block:FindFirstChild(HighlightXrayName) then
                        block:FindFirstChild(HighlightXrayName):Destroy()
                    end
                end
            end
        else
            warn("Location folder not found:", Path) -- Keep warn in English
        end
    else
        warn("CurrentLocation is undefined") -- Keep warn in English
    end
end

local DropdownOre = MainTab:CreateDropdown({
    Name = "Mining Ore", -- English dropdown name
    Options = Ores,
    CurrentOption = "Sapphire",
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        local choosedore = Option
        -- print("Selected Ore:", choosedore) -- Removed print
        FindingOre = choosedore
        if XrayToggled then
            Farm(true)
        end
    end,
})

local Divider1 = MainTab:CreateDivider()

local DropdownLocation = MainTab:CreateDropdown({
    Name = "Location", -- English dropdown name
    Options = Locations,
    CurrentOption = Locations[CurrentLocation],
    MultipleOptions = false,
    Flag = "Dropdown3",
    Callback = function(Option)
        -- Example of print "Option":
        -- 1 Mining Ore
        -- 1 Ancient Cave
        for i, locationName in ipairs(Option) do
            for index,location in Locations do
                if locationName == location then
                    CurrentLocation = index
                    print("Selected Location:", locationName, "Index:", index) -- Removed print
                    if XrayToggled then
                        Farm(true)
                    end
                    break
                end
            end
        end
    end,
})

local Divider3 = MainTab:CreateDivider()

local debounce = false

local Toggle = MainTab:CreateToggle({
    Name = "Xray",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if not debounce then
            debounce = true
            
            XrayToggled = Value

            task.delay(0.2, function()
                debounce = false
            end)
    
            Farm(Value)
        end
    end,
})

function Farm(ToggleValue)
    if CurrentLocation then
        local Path = "Blocks_" .. CurrentLocation
        if BlockWorlds:FindFirstChild(Path) then
            if ToggleValue then
                update()

                Rayfield:Notify({
                    Title = "Xray",
                    Content = "Xray Enabled", -- English notification
                    Duration = 3,
                    Image = 4483362458,
                })

                local Blocks = BlockWorlds:FindFirstChild(Path)

                update()

                for block, i in Blocks:GetChildren() do
                    if block:GetAttribute("id") and block:GetAttribute("id") == FindingOre then
                        if ToggleValue then
                            local Highlight = Instance.new("Highlight", block)
                            Highlight.Name = HighlightXrayName
                            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                    end
                end

                Blocks.ChildAdded:Connect(function(block)
                    if block:GetAttribute("id") and block:GetAttribute("id") == FindingOre then
                        if ToggleValue then
                            local Highlight = Instance.new("Highlight", block)
                            Highlight.Name = HighlightXrayName
                            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                    end
                end)
            else
                Rayfield:Notify({
                    Title = "Xray",
                    Content = "Xray Disabled", -- English notification
                    Duration = 3,
                    Image = 4483362458,
                })
                Toggle:Set(false)
                XrayToggled = false
        
                update()
            end
        else
            Rayfield:Notify({
                Title = "Error", -- English notification
                Content = "Please select a valid location", -- English notification
                Duration = 3,
                Image = 4483362458,
            })

            Toggle:Set(false)
            XrayToggled = false
            return
        end
    else
        Rayfield:Notify({
            Title = "Error", -- English notification
            Content = "Something went wrong", -- English notification
            Duration = 3,
            Image = 4483362458,
        })

        XrayToggled = false
        return
    end
end