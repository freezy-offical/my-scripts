local function get(path)
    local success, result = pcall(function()
        -- Adding a random query string to bypass executor caching
        local cacheBuster = "?t=" .. tostring(math.random(1, 100000))
        return game:HttpGet("https://raw.githubusercontent.com/freezy-offical/my-scripts/main/" .. path .. cacheBuster)
    end)
    if not success then return nil end
    return result
end

local function req(path)
    local source = get(path)
    if not source or source:find("404: Not Found") then 
        error("\n[Loader Error] File not found on GitHub: " .. path) 
    end
    local fn, err = loadstring(source)
    if not fn then error("\n[Loader Error] Syntax error in " .. path .. ": " .. err) end
    return fn()
end

local aimbot = req("library/aimbot.luau")
local Library = req("library/UI/Library.luau")
local ThemeManager = req("library/UI/addons/ThemeManager.luau")
local SaveManager = req("library/UI/addons/SaveManager.luau")

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Universal Aimbot",
    Center = true,
    AutoShow = true,
    TabGuiNavigation = false,
    MenuFadeTime = 0.2
})

local Tabs = {
    Aimbot = Window:AddTab("Aimbot"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

--// Aimbot Main
local MainGroup = Tabs.Aimbot:AddLeftGroupbox("Main")

MainGroup:AddToggle("AimbotEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.enabled = Value end
})

MainGroup:AddToggle("AimbotToggle", {
    Text = "Toggle",
    Default = false,
    Callback = function(Value) aimbot.toggle = Value end
})

MainGroup:AddLabel("Keybind"):AddKeyPicker("AimbotKey", {
    Default = "MB2",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Aimbot Keybind",
    NoUI = false,
    ChangedCallback = function(Value) aimbot.keybind = Value end
})

MainGroup:AddDropdown("TargetPart", {
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = 1,
    Multi = false,
    Text = "Target Part",
    Callback = function(Value) aimbot.targetPart = Value end
})

--// Smoothness
local SmoothGroup = Tabs.Aimbot:AddLeftGroupbox("Smoothness")

SmoothGroup:AddToggle("SmoothEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.smoothness.enabled = Value end
})

SmoothGroup:AddSlider("SmoothX", {
    Text = "Smoothness X",
    Default = 5,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value) aimbot.smoothness.x = Value end
})

SmoothGroup:AddSlider("SmoothY", {
    Text = "Smoothness Y",
    Default = 5,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value) aimbot.smoothness.y = Value end
})

--// Sticky Aim
local StickyGroup = Tabs.Aimbot:AddLeftGroupbox("Sticky Aim")

StickyGroup:AddToggle("StickyEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.stickyAim.enabled = Value end
})

StickyGroup:AddSlider("StickyStrength", {
    Text = "Strength",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) aimbot.stickyAim.strength = Value end
})

StickyGroup:AddSlider("StickyRadius", {
    Text = "Radius",
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) aimbot.stickyAim.radius = Value end
})

--// Triggerbot
local TriggerGroup = Tabs.Aimbot:AddRightGroupbox("Triggerbot")

TriggerGroup:AddToggle("TriggerEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value) aimbot.triggerbot.enabled = Value end
})

TriggerGroup:AddSlider("TriggerDelay", {
    Text = "Delay (s)",
    Default = 0.01,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) aimbot.triggerbot.delay = Value end
})

TriggerGroup:AddLabel("Keybind"):AddKeyPicker("TriggerKey", {
    Default = "V",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Triggerbot Keybind",
    NoUI = false,
    ChangedCallback = function(Value) aimbot.triggerbot.keybind = Value end
})

--// Checks
local ChecksGroup = Tabs.Aimbot:AddRightGroupbox("Checks")

ChecksGroup:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = false,
    Callback = function(Value) aimbot.checks.teamCheck.enabled = Value end
})

ChecksGroup:AddDropdown("TeamType", {
    Values = { "TeamColor", "Team" },
    Default = 1,
    Multi = false,
    Text = "Team Check Type",
    Callback = function(Value) aimbot.checks.teamCheck.type = Value end
})

ChecksGroup:AddToggle("VisCheck", {
    Text = "Visible Check",
    Default = false,
    Callback = function(Value) aimbot.checks.visibleCheck = Value end
})

ChecksGroup:AddToggle("InvisCheck", {
    Text = "Invisible Check",
    Default = true,
    Callback = function(Value) aimbot.checks.invisibleCheck = Value end
})

ChecksGroup:AddToggle("HealthCheck", {
    Text = "Health Check",
    Default = false,
    Callback = function(Value) aimbot.checks.healthCheck = Value end
})

ChecksGroup:AddDivider()

ChecksGroup:AddToggle("DistEnabled", {
    Text = "Distance Check",
    Default = false,
    Callback = function(Value) aimbot.checks.distance.enabled = Value end
})

ChecksGroup:AddSlider("MaxDist", {
    Text = "Max Distance",
    Default = 500,
    Min = 10,
    Max = 2000,
    Rounding = 0,
    Callback = function(Value) aimbot.checks.distance.maxDistance = Value end
})

--// FOV
local FOVGroup = Tabs.Aimbot:AddRightGroupbox("FOV")

FOVGroup:AddToggle("ShowFOV", {
    Text = "Show FOV",
    Default = false,
    Callback = function(Value) aimbot.fov.showFov = Value end
})

FOVGroup:AddToggle("FOVScale", {
    Text = "FOV Scaling",
    Default = false,
    Callback = function(Value) aimbot.fov.enabled = Value end
})

FOVGroup:AddToggle("RainbowFOV", {
    Text = "Rainbow",
    Default = false,
    Callback = function(Value) aimbot.fov.rainbow = Value end
})

FOVGroup:AddToggle("FilledFOV", {
    Text = "Filled",
    Default = false,
    Callback = function(Value) aimbot.fov.filled = Value end
})

FOVGroup:AddSlider("FOVRadius", {
    Text = "Radius",
    Default = 150,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) aimbot.fov.radius = Value end
})

FOVGroup:AddSlider("FOVTrans", {
    Text = "Transparency",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) aimbot.fov.transparency = Value end
})

FOVGroup:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "FOV Color",
    Callback = function(Value) aimbot.fov.color = Value end
})

--// UI Settings
local MenuConfigs = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuConfigs:AddButton({
    Text = "Unload",
    Func = function() Library:Unload() end,
    Tooltip = "Unloads the script"
})

MenuConfigs:AddLabel("Menu bind"):AddKeyPicker("MenuKey", { 
    Default = "RightControl", 
    NoUI = true, 
    Text = "Menu bind", 
    ChangedCallback = function(Value) Library.ToggleKeybind = Value end 
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKey", "AimbotKey", "TriggerKey" })

ThemeManager:SetFolder("UniversalAimbot")
SaveManager:SetFolder("UniversalAimbot/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
