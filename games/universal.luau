local function get(path)
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/freezy-offical/my-scripts/main/" .. path)
    end)
    if not success then return nil end
    return result
end

local function req(path)
    local source = get(path)
    if not source or source:find("404: Not Found") then 
        error("\n[Loader Error] File not found on GitHub: " .. path .. "\nMake sure you have pushed your files to the 'main' branch!") 
    end
    
    local fn, err = loadstring(source)
    if not fn then error("\n[Loader Error] Syntax error in " .. path .. ": " .. err) end
    
    return fn()
end

local aimbot = req("library/aimbot.luau")
local Library = req("library/UI/Library.luau")
local ThemeManager = req("library/UI/addons/ThemeManager.luau")
local SaveManager = req("library/UI/addons/SaveManager.luau")

local Window = Library:CreateWindow({
    Title = "Universal Aimbot",
    Center = true,
    AutoShow = true,
    TabGuiNavigation = false
})

local Tabs = {
    Aimbot = Window:AddTab("Aimbot"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

local MainGroupBox = Tabs.Aimbot:AddLeftGroupbox("Main")

MainGroupBox:AddToggle("AimbotEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.enabled = Value end
})

MainGroupBox:AddToggle("AimbotToggle", {
    Text = "Toggle",
    Default = false,
    Callback = function(Value) aimbot.toggle = Value end
})

MainGroupBox:AddLabel("Keybind"):AddKeyPicker("AimbotKeybind", {
    Default = "MB2",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Aimbot Keybind",
    NoUI = false,
    ChangedCallback = function(Value) aimbot.keybind = Value end
})

MainGroupBox:AddDropdown("TargetPart", {
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = 1,
    Multi = false,
    Text = "Target Part",
    Callback = function(Value) aimbot.targetPart = Value end
})

local SmoothnessGroupBox = Tabs.Aimbot:AddLeftGroupbox("Smoothness")

SmoothnessGroupBox:AddToggle("SmoothnessEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.smoothness.enabled = Value end
})

SmoothnessGroupBox:AddSlider("SmoothnessX", {
    Text = "Smoothness X",
    Default = 5,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value) aimbot.smoothness.x = Value end
})

SmoothnessGroupBox:AddSlider("SmoothnessY", {
    Text = "Smoothness Y",
    Default = 5,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value) aimbot.smoothness.y = Value end
})

local StickyGroupBox = Tabs.Aimbot:AddLeftGroupbox("Sticky Aim")

StickyGroupBox:AddToggle("StickyEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.stickyAim.enabled = Value end
})

StickyGroupBox:AddSlider("StickyStrength", {
    Text = "Strength",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) aimbot.stickyAim.strength = Value end
})

StickyGroupBox:AddSlider("StickyRadius", {
    Text = "Radius",
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) aimbot.stickyAim.radius = Value end
})

local TriggerGroupBox = Tabs.Aimbot:AddRightGroupbox("Triggerbot")

TriggerGroupBox:AddToggle("TriggerbotEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.triggerbot.enabled = Value end
})

TriggerGroupBox:AddSlider("TriggerbotDelay", {
    Text = "Delay (s)",
    Default = 0.01,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) aimbot.triggerbot.delay = Value end
})

TriggerGroupBox:AddLabel("Keybind"):AddKeyPicker("TriggerbotKeybind", {
    Default = "V",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Triggerbot Keybind",
    NoUI = false,
    ChangedCallback = function(Value) aimbot.triggerbot.keybind = Value end
})

local ChecksGroupBox = Tabs.Aimbot:AddRightGroupbox("Checks")

ChecksGroupBox:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = false,
    Callback = function(Value) aimbot.checks.teamCheck.enabled = Value end
})

ChecksGroupBox:AddDropdown("TeamCheckType", {
    Values = { "TeamColor", "Team" },
    Default = 1,
    Multi = false,
    Text = "Team Check Type",
    Callback = function(Value) aimbot.checks.teamCheck.type = Value end
})

ChecksGroupBox:AddToggle("VisibleCheck", {
    Text = "Visible Check",
    Default = false,
    Callback = function(Value) aimbot.checks.visibleCheck = Value end
})

ChecksGroupBox:AddToggle("InvisibleCheck", {
    Text = "Invisible Check",
    Default = true,
    Callback = function(Value) aimbot.checks.invisibleCheck = Value end
})

ChecksGroupBox:AddToggle("HealthCheck", {
    Text = "Health Check",
    Default = false,
    Callback = function(Value) aimbot.checks.healthCheck = Value end
})

ChecksGroupBox:AddDivider()

ChecksGroupBox:AddToggle("DistanceCheck", {
    Text = "Distance Check",
    Default = false,
    Callback = function(Value) aimbot.checks.distance.enabled = Value end
})

ChecksGroupBox:AddSlider("MaxDistance", {
    Text = "Max Distance",
    Default = 500,
    Min = 10,
    Max = 2000,
    Rounding = 0,
    Callback = function(Value) aimbot.checks.distance.maxDistance = Value end
})

ChecksGroupBox:AddDropdown("DistanceType", {
    Values = { "Character", "Camera" },
    Default = 1,
    Multi = false,
    Text = "Origin Type",
    Callback = function(Value) aimbot.checks.distance.type = Value end
})

local FOVGroupBox = Tabs.Aimbot:AddRightGroupbox("FOV")

FOVGroupBox:AddToggle("ShowFOV", {
    Text = "Show FOV",
    Default = false,
    Callback = function(Value) aimbot.fov.showFov = Value end
})

FOVGroupBox:AddToggle("FOVEnabled", {
    Text = "FOV Scaling",
    Default = false,
    Callback = function(Value) aimbot.fov.enabled = Value end
})

FOVGroupBox:AddToggle("RainbowFOV", {
    Text = "Rainbow",
    Default = false,
    Callback = function(Value) aimbot.fov.rainbow = Value end
})

FOVGroupBox:AddToggle("FilledFOV", {
    Text = "Filled",
    Default = false,
    Callback = function(Value) aimbot.fov.filled = Value end
})

FOVGroupBox:AddSlider("FOVRadius", {
    Text = "Radius",
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) aimbot.fov.radius = Value end
})

FOVGroupBox:AddSlider("FOVTransparency", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) aimbot.fov.transparency = Value end
})

FOVGroupBox:AddSlider("FOVThickness", {
    Text = "Thickness",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value) aimbot.fov.thickness = Value end
})

FOVGroupBox:AddSlider("FOVSides", {
    Text = "Sides",
    Default = 64,
    Min = 3,
    Max = 128,
    Rounding = 0,
    Callback = function(Value) aimbot.fov.numSides = Value end
})

FOVGroupBox:AddToggle("FOVOutline", {
    Text = "Outline",
    Default = true,
    Callback = function(Value) aimbot.fov.outline = Value end
})

FOVGroupBox:AddSlider("FOVFilledTransparency", {
    Text = "Filled Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) aimbot.fov.filledTransparency = Value end
})

FOVGroupBox:AddDropdown("FOVPosition", {
    Values = { "Center", "Mouse" },
    Default = 1,
    Multi = false,
    Text = "Position",
    Callback = function(Value) aimbot.fov.position = Value end
})

FOVGroupBox:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value) aimbot.fov.color = Value end
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "AimbotKeybind", "TriggerbotKeybind" })
ThemeManager:SetFolder("UniversalAimbot")
SaveManager:SetFolder("UniversalAimbot/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

Tabs["UI Settings"]:AddLeftGroupbox("Menu"):AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu bind", ChangedCallback = function(Value) Library.ToggleKeybind = Value end })

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
