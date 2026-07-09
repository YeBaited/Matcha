loadstring(game:HttpGet("https://scripts.wabisabi.mom/wabi-sabi-ui-lib.lua"))()
local Library = WabiSabi

local players = game:GetService("Players")

local ghostModel = workspace.Ghost
local map = workspace.Map
local handPrints = workspace.Handprints
local items = workspace.Items
local scratchText = workspace.ScratchText
local ghostHumanoid = ghostModel.Humanoid
local rooms = map.Rooms

local ghostRoom = "N/A"
local ghostcurrentLocation = "N/A"
local ghostAverageSpeed = 0
local ghostCurrentSpeed = 0
local ghostGender = "N/A"
local ghostAverageBlink = 0
local ghostHunting = false

local ghostSpeedRecords = {}
local ghostBlinkRecords = {}
local evidencesRecords = { -- -1 No | 0 Maybe | 1 Yes
    ["Emf 5"] = 0,
    ["Prints"] = 0,
    ["Spirit Box"] = 0,
    ["Ghost Orb"] = 0,
    ["Freezing Temperature"] = 0,
    ["Inscription"] = 0,
    ["Laser Projector"] = 0,
    ["Wither"] = 0,
}

local otherEvidenceRecords = {
    ["requiredFemale"] = 0,
}

local ghostEvidence = {
    Aswang = {"Emf 5", "Inscription", "Wither"},
    Banshee = {"Freezing Temperature", "Ghost Orb", "Prints"},
    Demon = {"Emf 5", "Freezing Temperature", "Prints"},
    Dullahan = {"Freezing Temperature", "Laser Projector", "Wither"},
    Dybbuk = {"Freezing Temperature", "Prints", "Wither"},
    Entity = {"Prints", "Laser Projector", "Spirit Box"},
    Ghoul = {"Freezing Temperature", "Ghost Orb", "Spirit Box"},
    Keres = {"Prints", "Spirit Box", "Wither"},
    Leviathan = {"Inscription", "Prints", "Ghost Orb"},
    Nightmare = {"Emf 5", "Ghost Orb", "Spirit Box"},
    Oni = {"Freezing Temperature", "Laser Projector", "Spirit Box"},
    Phantom = {"Emf 5", "Prints", "Ghost Orb"},
    Ravager = {"Emf 5", "Inscription", "Spirit Box"},
    Revenant = {"Emf 5", "Freezing Temperature", "Inscription"},
    Shadow = {"Emf 5", "Inscription", "Laser Projector"},
    Siren = {"Emf 5", "Spirit Box", "Wither"},
    Skinwalker = {"Ghost Orb", "Freezing Temperature", "Inscription", "Spirit Box"},
    Specter = {"Emf 5", "Freezing Temperature", "Laser Projector"},
    Spirit = {"Inscription", "Prints", "Spirit Box"},
    Umbra = {"Prints", "Ghost Orb", "Laser Projector"},
    Vesper = {"Inscription", "Prints", "Wither"},
    Vex = {"Freezing Temperature", "Ghost Orb", "Wither"},
    Wendigo = {"Inscription", "Ghost Orb", "Laser Projector"},
    ["The Wisp"] = {"Laser Projector", "Ghost Orb", "Wither"},
    Wraith = {"Emf 5", "Laser Projector", "Spirit Box"}
}

local ghostTraits = {
    Aswang = {},
    Banshee = {},
    Demon = {},
    Dullahan = {},
    Dybbuk = {},
    Entity = {},
    Ghoul = {},
    Keres = {},
    Leviathan = {},
    Nightmare = {},
    Oni = {},
    Phantom = {},
    Ravager = {},
    Revenant = {},
    Shadow = {},
    Siren = {},
    Skinwalker = {},
    Specter = {},
    Spirit = {},
    Umbra = {},
    Vesper = {},
    Vex = {},
    Wendigo = {},
    ["The Wisp"] = {},
    Wraith = {}
}

local config = {
    itemESPEnabled = true,
}

local espLogged = {}

local ghostInformationText = "No information about the ghost! (If you're seeing this, it's broken...)"
local evidenceInformationText = "No information about the ghost! (If you're seeing this, it's broken...)"
local guessInformationText = "No information about the ghost! (If you're seeing this, it's broken...)"

local function updateGhostSpeedRecords()
    if not ghostHunting then return end

    table.insert(ghostSpeedRecords, ghostCurrentSpeed or 0)
    
    local totalSpeed = 0
    local temporaryAverageSpeed = 0

    for _,ghostSpeed in pairs(ghostSpeedRecords) do
        totalSpeed += ghostSpeed
    end

    temporaryAverageSpeed = math.floor((totalSpeed / #ghostSpeedRecords) * 100) / 100

    ghostAverageSpeed = temporaryAverageSpeed
end

local function updateGhostBlinkRecords()
    if not ghostHunting then return end
    local blinkStatus = ghostModel:GetAttribute("Transparency")
    
    table.insert(ghostBlinkRecords, blinkStatus)
    
    local totalBlink = 0
    local temporaryAverageBlink = 0

    for _,ghostBlinked in pairs(ghostBlinkRecords) do
        totalBlink += ghostBlinked
    end

    temporaryAverageBlink = math.floor((totalBlink / #ghostBlinkRecords) * 100) / 100

    ghostAverageBlink = temporaryAverageBlink

end

local function checkPrintsEvidence()
    if evidencesRecords["Prints"] ~= 0 then return end

    if (handPrints:FindFirstChildWhichIsA("Part")) then
        evidencesRecords["Prints"] = 1
        Library:Notify({Title = "Evidence Alert!", Content = "Prints.", Duration = 4 })
    end
end

local function checkTemperatureEvidence()
    if evidencesRecords["Freezing Temperature"] ~= 0 then return end

    for _,room in pairs(rooms:GetChildren()) do
        if (room:GetAttribute("Temperature") < 0) then
            evidencesRecords["Freezing Temperature"] = 1;
            Library:Notify({Title = "Evidence Alert!", Content = "Freezing Temperature.", Duration = 4 })
            return;
        end
    end
end

local function checkGhostOrbEvidence()
    if evidencesRecords["Ghost Orb"] ~= 0 then return end
    if (workspace:FindFirstChild("GhostOrb")) then
        print("Ghost orb found!")
        evidencesRecords["Ghost Orb"] = 1;
        Library:Notify({Title = "Evidence Alert!", Content = "Ghost Orb.", Duration = 4})
    else
        print("No ghost orb!")
        evidencesRecords["Ghost Orb"] = -1;
    end
end

local function checkLaserProjectEvidence()
    if evidencesRecords["Laser Projector"] ~= 0 then return end

    if (ghostModel:GetAttribute("LaserVisible")) then
        evidencesRecords["Laser Projector"] = 1;
        Library:Notify({Title = "Evidence Alert!", Content = "Laser Projector.", Duration = 4})
    end
end

local function checkSpiritBoxEvidence()
    if evidencesRecords["Spirit Box"] ~= 0 then return end


    local function check(model)
        if not (model:GetAttribute("ItemName") == "Spirit Box") then return end

        local spiritBoxHandle = model.Handle

        for _,sound in pairs(spiritBoxHandle:GetChildren()) do
            if sound.Name == "Tone" then continue end

            if sound:GetAttribute("Subtitle") then 
                evidencesRecords["Spirit Box"] = 1
                Library:Notify({Title = "Evidence Alert!", Content = "Spirit Box", Duration = 4})
                return;
            end
        end
    end

    for _,gameItem in pairs(items:GetChildren()) do
        check(gameItem)
    end

    for _,gamePlayer in pairs(players:GetChildren()) do
        for _,playerItem in pairs(gamePlayer.Character:GetChildren()) do
            check(playerItem)
        end
    end
end

local function checkEmfEvidence()
    if evidencesRecords["Emf 5"] ~= 0 then return end

    local function check(model)
        if not (model:GetAttribute("ItemName") == "EMF Reader") then return end

        if (model:GetAttribute("ReadingLevel") == 5) then
            evidencesRecords["Emf 5"] = 1
            Library:Notify({Title = "Evidence Alert!", Content = "EMF 5", Duration = 4})
            return;
        end
        
    end

    for _,gameItem in pairs(items:GetChildren()) do
        check(gameItem)
    end

    for _,gamePlayer in pairs(players:GetChildren()) do
        for _,playerItem in pairs(gamePlayer.Character:GetChildren()) do
            check(playerItem)
        end
    end

end

local function checkWitherEvidence()
    if evidencesRecords["Wither"] ~= 0 then return end

    local function check(model)
        if not (model:GetAttribute("ItemName") == "Flower Pot") then return end
        
        if (model:GetAttribute("PhotoRewardType") == "WitheredFlowers") then
            evidencesRecords["Wither"] = 1
            Library:Notify({Title = "Evidence Alert!", Content = "Withered.", Duration = 4})
            return;
        end
    end

    for _,gameItem in pairs(items:GetChildren()) do
        check(gameItem)
    end

    for _,gamePlayer in pairs(players:GetChildren()) do
        for _,playerItem in pairs(gamePlayer.Character:GetChildren()) do
            check(playerItem)
        end
    end

end

local function checkInscriptionEvidence()
    if evidencesRecords["Inscription"] ~= 0 then return end

    local function check(model)
        if not (model:GetAttribute("ItemName") == "Spirit Book") then return end
        
        if (model:GetAttribute("PhotoRewardType") == "Inscription") then
            evidencesRecords["Inscription"] = 1
            Library:Notify({Title = "Evidence Alert!", Content = "Inscription.", Duration = 4})
            return;
        end
    end

    for _,gameItem in pairs(items:GetChildren()) do
        check(gameItem)
    end

    for _,gamePlayer in pairs(players:GetChildren()) do
        for _,playerItem in pairs(gamePlayer.Character:GetChildren()) do
            check(playerItem)
        end
    end

    if (scratchText:FindFirstChildWhichIsA("Model")) then
        evidencesRecords["Inscription"] = 1
        Library:Notify({Title = "Evidence Alert!", Content = "Inscription.", Duration = 4})
    end

end


local function updateGhostInformation()
    ghostRoom = ghostModel:GetAttribute("FavoriteRoom")
    ghostcurrentLocation = ghostModel:GetAttribute("CurrentRoom")
    --ghostAverageSpeed = ghostAverageSpeed
    ghostCurrentSpeed = math.floor(memory_read("float", ghostHumanoid.Address+464) * 100) / 100
    
    ghostGender = ghostModel:GetAttribute("Gender")
    --ghostAverageBlink = ghostAverageBlink
    ghostHunting = ghostModel:GetAttribute("Hunting") or false


    ghostInformationText = "Ghost Room: " .. ghostRoom .. " \nCurren Location: " .. ghostcurrentLocation .. " \nAverage Speed: " .. ghostAverageSpeed.. " \nCurrent Speed: " .. ghostCurrentSpeed .. " \nGender: " .. ghostGender .. " \n Average Blink: " .. ghostAverageBlink .. "\n Ghost Hunting : " .. tostring(ghostHunting)
end

local function updateEvidenceInformation()
    evidenceInformationText = ""
    for evidenceName, v in pairs(evidencesRecords) do
        if v == -1 then
            v = "Nope"
        elseif v == 1 then
            v = "Yes"
        else
            v = "Maybe"
        end 
        evidenceInformationText = evidenceInformationText .. evidenceName .. ": " .. v .. "\n"
    end
end

local function updateGuessInformation()
    TemporaryGuessInformationText = ""

    local highestPassedChecks = 0;
    local ghostChecks = {};

    local function validateEvidence(evidences)
        local passedChecks = 0;
        for _,evidence in pairs(evidences) do
           
            if (evidencesRecords[evidence] == 1) then
                passedChecks += 1
            end
        end
        return passedChecks
    end

    for ghostName,ghostEvidences in pairs(ghostEvidence) do
        local checksPassed = validateEvidence(ghostEvidences)

        if (checksPassed > highestPassedChecks) then
            highestPassedChecks = checksPassed
        end

        ghostChecks[ghostName] = checksPassed
    end

    for ghostName,_ in pairs(ghostEvidence) do
        if (ghostChecks[ghostName] == highestPassedChecks) then
            TemporaryGuessInformationText = TemporaryGuessInformationText .. ghostName .. " | Checks Completed: " .. ghostChecks[ghostName] .. "\n"
        end
    end

    guessInformationText = TemporaryGuessInformationText
end

local function scanItemsForESP()
    for _,item in pairs(items:GetChildren()) do
        if (espLogged[tostring(item.Address)]) then continue end

        espLogged[tostring(item.Address)] = {
            itemText = item:GetAttribute("ItemName"),
            mainPart = item.Handle,
            category = "itemESP",
            drawing = nil
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = espLogged[tostring(item.Address)].itemText

        espLogged[tostring(item.Address)].drawing = MatchaDrawing
    end
end

local function renderESP()

    for _, espTable in pairs(espLogged) do
        local success,failed 
        local worldPos, isVisible = WorldToScreen(espTable.mainPart.Position)

        if espTable.category == "itemESP" and config.itemESPEnabled then
            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos
        else
            espTable.drawing.Visible = false
        end

    end

end

local window = Library:CreateWindow({
    Title = "Daddy's Demons",
    SubTitle = "v0.0.1",
    Resize = true,
    Size = Vector2.new(580, 600)
})

local information = window:AddTab({
    Title = "Info",
    Icon = "info",
})

local logs = window:AddTab({
    Title = "Logs",
    Icon = "info",
})

local ghostStatus = information:AddParagraph({
    Title = "Ghost Information",
    Content = ghostInformationText
})

local evidenceStatus = information:AddParagraph({
    Title = "Evidences Information",
    Content = evidenceInformationText,
})

local guessesStatus = information:AddParagraph({
    Title = "Guess Information",
    Content = guessInformationText,
})


task.spawn(function()

    while Library.Unloaded == false do -- Main Loop
        updateGhostSpeedRecords()
        updateGhostBlinkRecords()
        
        checkPrintsEvidence()
        checkTemperatureEvidence()
        checkGhostOrbEvidence()
        checkLaserProjectEvidence()
        checkSpiritBoxEvidence()
        checkEmfEvidence()
        checkWitherEvidence()
        checkInscriptionEvidence()
        
        updateGhostInformation()
        updateEvidenceInformation()
        updateGuessInformation()

        scanItemsForESP()
        -- updates Uilibrary information
        ghostStatus:SetContent(ghostInformationText)
        evidenceStatus:SetContent(evidenceInformationText)
        guessesStatus:SetContent(guessInformationText)
        
        task.wait(0.5)
    end
end)

task.spawn(function()
    while Library.Unloaded == false do
        renderESP()
        task.wait(0.001)
    end
end)
