local RunService = game:GetService("RunService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Pet Simulator! Script",
   LoadingTitle = "Auto Hatch",
   LoadingSubtitle = "by Dark",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = nil
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Zakładka Auto Egg
local EggTab = Window:CreateTab("Auto Egg", 4483362458)

-- Zakładka Auto Combine
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Ustawienia
local Settings = {
    ["Auto Egg"] = {
        ["Christmas Tier 4"] = false,
        ["Christmas Tier 3"] = false,
        ["Tier 18"] = false,
        ["Tier 17"] = false,
        ["Triple Egg Open"] = true
    },
    ["Auto Combine"] = {
        ["Enabled"] = false,
        ["Threads"] = 1,
        ["Gold"] = true,
        ["Rainbow"] = true,
        ["Dark Matter"] = true
    },
    ["Auto Deleters"] = {
        ["Enabled"] = false
    }
}

local Deleters = {
    "Dominus Pumpkin", "Dominus Cherry", "Dominus Noob", "Dominus Wavy", 
    "Dominus Damnee", "Dominus HeadStack", "Spike", "Aesthetic Cat", "Magic Fox", 
    "Chimera", "Gingerbread", "Festive Ame Damnee", "Reindeer", "Festive Dominus"
}

local Directory = require(game:GetService("ReplicatedStorage")["1 | Directory"])

-- Flagi kontrolne
local AutoCombineRunning = false
local AutoDeletersRunning = false

-- Funkcja sprawdzająca, czy zwierzak znajduje się na liście do usunięcia
local function CheckDeleters(Info)
    for _, Deleter in pairs(Deleters) do
        if string.lower(tostring(Deleter)) == string.lower(Directory.Pets[Info].DisplayName) or 
           string.lower(tostring(Deleter)) == string.lower(Directory.Pets[Info].ReferenceName) then
            return true
        end
    end
    return false
end

-- Funkcja usuwająca niechciane zwierzaki
local function DeleteOtherUnwantedPets()
    local Stats = workspace["__REMOTES"]["Core"]["Get Stats"]:InvokeServer()
    for _, Pet in ipairs(Stats.Save.Pets) do
        if CheckDeleters(Pet.n) then
            workspace["__REMOTES"]["Game"]["Inventory"]:InvokeServer("Delete", Pet.id)
        end
    end
end

-- Funkcja zakupu jajek
local function BuyEgg(tier)
    print("Próbuję kupić jajko z tierem: " .. tier)

    local success, result = workspace["__REMOTES"]["Game"]["Shop"]:InvokeServer("Buy", "Eggs", tier, Settings["Auto Egg"]["Triple Egg Open"])
    if success then
        print("Pomyślnie zakupiono jajko.")
    else
        warn("Nie udało się kupić jajka: " .. tostring(result))
    end
    return success
end

-- Główna funkcja Auto Egg
local function AutoEggMain()
    while Settings["Auto Egg"]["Christmas Tier 4"] or Settings["Auto Egg"]["Tier 17"] or Settings["Auto Egg"]["Tier 18"] or Settings["Auto Egg"]["Christmas Tier 3"] do
        local tier = nil
        if Settings["Auto Egg"]["Christmas Tier 4"] then
            tier = "Christmas Tier 4"
        elseif Settings["Auto Egg"]["Tier 18"] then
            tier = "Tier 18"
        elseif Settings["Auto Egg"]["Christmas Tier 3"] then
            tier = "Christmas Tier 3"
        elseif Settings["Auto Egg"]["Tier 17"] then
            tier = "Tier 17"
        end
        
        local stats = workspace["__REMOTES"]["Core"]["Get Stats"]:InvokeServer()
        local currentPets = #stats.Save.Pets
        local maxPets = stats.Save.PetSlots
        local requiredFreeSlots = Settings["Auto Egg"]["Triple Egg Open"] and 3 or 1

        if maxPets - currentPets < requiredFreeSlots then
            warn("Ekwipunek pełny, czekam na zwolnienie miejsca...")
            repeat
                RunService.Heartbeat:Wait()
                stats = workspace["__REMOTES"]["Core"]["Get Stats"]:InvokeServer()
                currentPets = #stats.Save.Pets
            until maxPets - currentPets >= requiredFreeSlots
            warn("Miejsce w ekwipunku dostępne, wznawiam Auto Hatch.")
        end

        local success = BuyEgg(tier)
        if not success then
            warn("Kupowanie jajek zostało przerwane.")
            break
        end
        local start = tick()
        repeat RunService.Heartbeat:Wait() until tick() - start >= 0.5
    end
end

-- Funkcja automatycznego łączenia zwierzaków
local function AutoCombineCheck()
    local Stats = workspace["__REMOTES"]["Core"]["Get Stats"]:InvokeServer()
    local GoldTable, RainbowTable, DarkMatterTable = {}, {}, {}

    for _, Pet in ipairs(Stats.Save.Pets) do
        if Settings["Auto Combine"]["Gold"] and not Pet.g and not Pet.r and not Pet.dm then
            GoldTable[tostring(Pet.n)] = (GoldTable[tostring(Pet.n)] or 0) + 1
        elseif Settings["Auto Combine"]["Rainbow"] and Pet.g and not Pet.r and not Pet.dm then
            RainbowTable[tostring(Pet.n)] = (RainbowTable[tostring(Pet.n)] or 0) + 1
        elseif Settings["Auto Combine"]["Dark Matter"] and not Pet.g and Pet.r and not Pet.dm then
            DarkMatterTable[tostring(Pet.n)] = (DarkMatterTable[tostring(Pet.n)] or 0) + 1
        end
    end

    -- Łączenie w Gold
    for PetN, Amount in pairs(GoldTable) do
        if Amount >= 10 then
            for _, Pet in ipairs(Stats.Save.Pets) do
                if tostring(Pet.n) == tostring(PetN) and not Pet.g and not Pet.r and not Pet.dm then
                    workspace["__REMOTES"]["Game"]["Golden Pets"]:InvokeServer(Pet.id)
                end
            end
        end
    end

    -- Łączenie w Rainbow
    for PetN, Amount in pairs(RainbowTable) do
        if Amount >= 7 then
            for _, Pet in ipairs(Stats.Save.Pets) do
                if tostring(Pet.n) == tostring(PetN) and Pet.g and not Pet.r and not Pet.dm then
                    workspace["__REMOTES"]["Game"]["Rainbow Pets"]:InvokeServer(Pet.id)
                end
            end
        end
    end

    -- Łączenie w Dark Matter
    for PetN, Amount in pairs(DarkMatterTable) do
        if Amount >= 5 then
            for _, Pet in ipairs(Stats.Save.Pets) do
                if tostring(Pet.n) == tostring(PetN) and not Pet.g and Pet.r and not Pet.dm then
                    workspace["__REMOTES"]["Game"]["Dark Matter Pets"]:InvokeServer(Pet.id)
                end
            end
        end
    end
end

-- Przełączniki w GUI
EggTab:CreateToggle({
    Name = "Enable Christmas Tier 4 Auto Egg",
    CurrentValue = Settings["Auto Egg"]["Christmas Tier 4"],
    Flag = "ChristmasTier4Toggle",
    Callback = function(Value)
        Settings["Auto Egg"]["Christmas Tier 4"] = Value
        if Value then
            Settings["Auto Egg"]["Tier 17"] = false
            Settings["Auto Egg"]["Tier 18"] = false
            Settings["Auto Egg"]["Christmas Tier 3"] = false
            spawn(AutoEggMain)
        end
    end
})

EggTab:CreateToggle({
    Name = "Enable Christmas Tier 3 Auto Egg",
    CurrentValue = Settings["Auto Egg"]["Christmas Tier 3"],
    Flag = "ChristmasTier3Toggle",
    Callback = function(Value)
        Settings["Auto Egg"]["Christmas Tier 3"] = Value
        if Value then
            Settings["Auto Egg"]["Tier 17"] = false
            Settings["Auto Egg"]["Tier 18"] = false
            Settings["Auto Egg"]["Christmas Tier 4"] = false
            spawn(AutoEggMain)
        end
    end
})

EggTab:CreateToggle({
    Name = "Enable Tier 18 Auto Egg",
    CurrentValue = Settings["Auto Egg"]["Tier 18"],
    Flag = "Tier18Toggle",
    Callback = function(Value)
        Settings["Auto Egg"]["Tier 18"] = Value
        if Value then
            Settings["Auto Egg"]["Christmas Tier 4"] = false
            Settings["Auto Egg"]["Tier 17"] = false
            Settings["Auto Egg"]["Christmas Tier 3"] = false
            spawn(AutoEggMain)
        end
    end
})

EggTab:CreateToggle({
    Name = "Enable Tier 17 Auto Egg",
    CurrentValue = Settings["Auto Egg"]["Tier 17"],
    Flag = "Tier17Toggle",
    Callback = function(Value)
        Settings["Auto Egg"]["Tier 17"] = Value
        if Value then
            Settings["Auto Egg"]["Christmas Tier 4"] = false
            Settings["Auto Egg"]["Tier 18"] = false
            Settings["Auto Egg"]["Christmas Tier 3"] = false
            spawn(AutoEggMain)
        end
    end
})

SettingsTab:CreateToggle({
    Name = "Triple Egg Open",
    CurrentValue = Settings["Auto Egg"]["Triple Egg Open"],
    Flag = "TripleEggToggle",
    Callback = function(Value)
        Settings["Auto Egg"]["Triple Egg Open"] = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Auto Combine",
    CurrentValue = Settings["Auto Combine"]["Enabled"],
    Flag = "AutoCombineToggle",
    Callback = function(Value)
        Settings["Auto Combine"]["Enabled"] = Value
        AutoCombineRunning = Value
        if Value then
            for i = 1, Settings["Auto Combine"]["Threads"] do
                spawn(function()
                    while AutoCombineRunning do
                        AutoCombineCheck()
                        local start = tick()
                        repeat RunService.Heartbeat:Wait() until tick() - start >= 0.2
                    end
                end)
            end
        end
    end
})

SettingsTab:CreateToggle({
    Name = "Auto Deleters",
    CurrentValue = Settings["Auto Deleters"]["Enabled"],
    Flag = "AutoDeleterToggle",
    Callback = function(Value)
        Settings["Auto Deleters"]["Enabled"] = Value
        AutoDeletersRunning = Value
        if Value then
            spawn(function()
                while AutoDeletersRunning do
                    DeleteOtherUnwantedPets()
                    local start = tick()
                    repeat RunService.Heartbeat:Wait() until tick() - start >= 0.2
                end
            end)
        end
    end
})

-- Anti-AFK Script
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    local VirtualUser = game:service('VirtualUser')
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
    print("Anti-AFK: Zapobieganie rozłączeniu.")
	end)