local TheoOffsets = httpget("https://offsets.imtheo.lol/version-90f2fddd3b244ff6/offsets.json")
loadstring(game:HttpGet("https://scripts.wabisabi.mom/wabi-sabi-ui-lib.lua"))()

local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local Library = WabiSabi
TheoOffsets = httpService:JSONDecode(TheoOffsets)

local offsets = TheoOffsets.Offsets

local ghostModel = workspace.Ghost
local map = workspace.Map
local handPrints = workspace.Handprints
local items = workspace.Items
local scratchText = workspace.ScratchText
local saltPile = workspace.SaltPiles
local brokenGlass = workspace.BrokenGlass
local ghostHumanoid = ghostModel.Humanoid
local rooms = map.Rooms

local ghostRoom = "N/A"
local ghostcurrentLocation = "N/A"
local ghostAverageSpeed = 0
local ghostCurrentSpeed = 0
local ghostGender = "N/A"
local ghostAverageBlink = 0
local ghostHunting = false
local preHuntSpeed = 0

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

local ghostTraitsRecords = {
    ["IsFemale"] = 0,
    ["IgnoresSalt"] = 0,
    ["SaltSlowed"] = 0,
    ["CanSlow"] = 0,
    ["Fast"] = 0,
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
    Aswang = {"SaltSlowed"},
    Banshee = {},
    Demon = {},
    Dullahan = {},
    Dybbuk = {},
    Entity = {},
    Ghoul = {},
    Keres = {"IsFemale"},
    Leviathan = {},
    Nightmare = {},
    Oni = {},
    Phantom = {},
    Ravager = {},
    Revenant = {},
    Shadow = {},
    Siren = {"IsFemale", "CanSlow"},
    Skinwalker = {},
    Specter = {},
    Spirit = {},
    Umbra = {},
    Vesper = {},
    Vex = {},
    Wendigo = {},
    ["The Wisp"] = {},
    Wraith = {"IgnoresSalt"}
}

local ignoredGhost = {}

local config = {
    itemESPEnabled = true,
    roomESPEnabled = true,
    shardESPEnabled = true,
    ghostOrbZeroEvidence = false,
    
}

local espLogged = {}

local ghostInformationText = "No information about the ghost! (If you're seeing this, it's broken...)"
local evidenceInformationText = "No information about the ghost! (If you're seeing this, it's broken...)"
local guessInformationText = "No information about the ghost! (If you're seeing this, it's broken...)"
local noteInformationText = "I have no clue..."

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
        return
    end

    if (saltPile:FindFirstChild("DisturbedSaltLine")) then
        if (handPrints:FindFirstChildWhichIsA("Part")) then
            evidencesRecords["Prints"] = 1
            Library:Notify({Title = "Evidence Alert!", Content = "Prints.", Duration = 4 })
            return
        end
        evidencesRecords["Prints"] = -1
        return
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
        evidencesRecords["Ghost Orb"] = (config.ghostOrbZeroEvidence) and 0 or -1;
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
        if check(gameItem) then return end
    end

    for _,gamePlayer in pairs(players:GetChildren()) do
        for _,playerItem in pairs(gamePlayer.Character:GetChildren()) do
            if check(playerItem) then return end
        end
    end

    if (ghostModel:GetAttribute("LastEMFLevel5Time")) then
        evidencesRecords["Emf 5"] = 1
        Library:Notify({Title = "Evidence Alert!", Content = "EMF 5", Duration = 4})
        return
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

local function checkTraitsEvidence()

    local function checkFemale()
        if ghostTraitsRecords["IsFemale"] ~= 0 then return end
        if (ghostGender == "Female") then     
            ghostTraitsRecords["IsFemale"] = 1
            Library:Notify({Title = "Trait found!", Content = "Female...", Duration = 4})
            return
        end

        if (ghostGender == "Male") then
            ghostTraitsRecords["IsFemale"] = -1
            table.insert(ignoredGhost, "Keres")
            table.insert(ignoredGhost, "Siren")
            return
        end
    end

    local function checkCanSlow()
        if ghostTraitsRecords["CanSlow"] ~= 0 then return end
        for _,player in pairs(players:GetChildren()) do
            if player:GetAttribute("Slowed") == true then
                ghostTraitsRecords["CanSlow"] = 1
                Library:Notify({Title = "Trait found!", Content = "It can slow!", Duration = 4})
            end
        end
    end

    local function checkIgnoreSalt()
        if ghostTraitsRecords["IgnoresSalt"] ~= 0 then return end
        if ignoredGhost["Wraith"] then return end
        if #saltPile:GetChildren() == 0 then return end
        
        for _,saltPile in pairs(saltPile:GetChildren()) do
            local saltPileCenter = saltPile:FindFirstChild("Center")
            if not saltPileCenter then continue end

            if (saltPileCenter.Position - ghostModel["Right Leg"].Position).Magnitude < 2 then
                if saltPile.Name ~= "SaltLine" then -- Salt pile changed.
                    ghostTraitsRecords["IgnoresSalt"] = -1
                    table.insert(ignoredGhost, "Wraith")
                    return
                end
                ghostTraitsRecords["IgnoresSalt"] = 1
                Library:Notify({Title = "Trait found!", Content = "Ignores salt", Duration = 4})
                return
            end
        end
    end

    local function checkIfFast()
        if ghostTraitsRecords["Fast"] ~= 0 then return end
        if not ghostHunting then return end
        if ((ghostCurrentSpeed - preHuntSpeed) > 5) then
            ghostTraitsRecords["Fast"] = 1
            Library:Notify({Title = "Trait found!", Content = "Ghost is definitely fast!", Duration = 4})
        end
    end

    local function checkSaltSlowed()
        if ghostTraitsRecords["SaltSlowed"] == 1 then return end
        
        for _,saltPile in pairs(saltPile:GetChildren()) do
            local saltPileCenter = saltPile:FindFirstChild("Center")
            if not saltPileCenter then continue end

            if (saltPileCenter.Position - ghostModel["Right Leg"].Position).Magnitude < 3 then
                if (ghostCurrentSpeed < preHuntSpeed) then
                    ghostTraitsRecords["SaltSlowed"] = 1
                    Library:Notify({Title = "Trait found!", Content = "Ghost got slowed by salt...", Duration = 4})
                end
                return
            end
        end
    end

    checkFemale()
    checkCanSlow()
    checkIgnoreSalt()
    checkIfFast()
    checkSaltSlowed()

end

local function updateGhostInformation()
    ghostRoom = ghostModel:GetAttribute("FavoriteRoom")
    ghostcurrentLocation = ghostModel:GetAttribute("CurrentRoom")
    --ghostAverageSpeed = ghostAverageSpeed
    ghostCurrentSpeed = math.floor(memory_read("float", ghostHumanoid.Address+offsets.Humanoid.Walkspeed) * 100) / 100
    ghostGender = ghostModel:GetAttribute("Gender")
    --ghostAverageBlink = ghostAverageBlink
    ghostHunting = ghostModel:GetAttribute("Hunting") or false

    if (ghostHunting == false and preHuntSpeed == 0) then
        preHuntSpeed = ghostCurrentSpeed
    end

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

local function updateNoteInformation()
    local temporaryNoteInformation = ""
    if ghostTraitsRecords["IgnoresSalt"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Probably a wraith.\n"
    end
    if ghostTraitsRecords["CanSlow"] == 1 and ghostTraitsRecords["IsFemale"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Probably a siren.\n"
    end

    if ghostTraitsRecords["Fast"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Might be a Oni or a Keres, might even be an aswang who knows?\nif speed remains the same might be an Oni.\n"
    end

    if ghostTraitsRecords["SaltSlowed"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "This might actually be a Aswang?!? \n"
    end

    if evidencesRecords["Ghost Orb"] and ghostOrbZeroEvidence then
        temporaryNoteInformation = temporaryNoteInformation .. "If this is zero evidence then probably a skinwalker.\n"
    end


    noteInformationText = temporaryNoteInformation
end

local function updateGuessInformation()
    TemporaryGuessInformationText = ""
    local ghostGuessData = {}
    local highestEvidencePassed = 0

    local function verifyChecksOnGhost(ghostName, evidences, optionalEvidences)
        local evidencePassed = 0
        local traitsPassed = 0
        
        for _,ghostEvidence in pairs(evidences) do

            if (evidencesRecords[ghostEvidence] == 1) then
                evidencePassed += 1
                continue
            end


            if (evidencesRecords[ghostEvidence] == -1) then
                evidencePassed -= 2
                continue
            end
        end

        for _,ghostTrait in pairs(optionalEvidences) do
            if (ghostTraitsRecords[ghostTrait] == 1) then
                traitsPassed += 1
            end
        end

        return evidencePassed, traitsPassed
    end

    for ghostName,ghostEvidences in pairs(ghostEvidence) do
        if ignoredGhost[ghostName] then warn(ghostName .. " <- Ignored. ") continue end 

        local passedChecks, passedTraitsChecks = verifyChecksOnGhost(ghostName, ghostEvidences, ghostTraits[ghostName])
        if (passedChecks > highestEvidencePassed) then
            highestEvidencePassed = passedChecks
        end

        if not ghostGuessData[ghostName] then
            ghostGuessData[ghostName] = {}
        end

        table.insert(ghostGuessData[ghostName], passedChecks)
        table.insert(ghostGuessData[ghostName], passedTraitsChecks)
    end

    for ghostName, ghostChecks in pairs(ghostGuessData) do
        if (ghostChecks[1] == highestEvidencePassed) then
            TemporaryGuessInformationText = TemporaryGuessInformationText .. ghostName .. " <Traits check: " .. ghostChecks[2] .. "> <"

            for _,evidenceRequired in pairs(ghostEvidence[ghostName]) do
                if evidencesRecords[evidenceRequired] == 1 then continue end
                TemporaryGuessInformationText = TemporaryGuessInformationText .. evidenceRequired .. " "
            end

            TemporaryGuessInformationText = TemporaryGuessInformationText .. ">\n"
        end
    end

    guessInformationText = TemporaryGuessInformationText
end

local function scanItemsForESP()
    for _,item in pairs(items:GetChildren()) do
        if (espLogged[tostring(item.Address)]) then continue end
        if (item.Handle == nil) then continue end
        espLogged[tostring(item.Address)] = {
            espText = item:GetAttribute("ItemName"),
            mainPart = item.Handle,
            category = "itemESP",
            drawing = nil
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = item:GetAttribute("ItemName")

        espLogged[tostring(item.Address)].drawing = MatchaDrawing
    end


    for espId,espObject in pairs(espLogged) do -- checks if it's in the inventory, if so then clear it from the stored esp.
        if espObject.category ~= "itemESP" then continue end
        if espObject.mainPart.Parent == nil then continue end
        if espObject.mainPart.Parent.Parent == nil then continue end
        if espObject.mainPart.Parent.Parent.Name == "ToolsHolder" then
            espLogged[espId].drawing:Remove()
            espLogged[espId] = nil
        end
    end
    
end

local function scanRoomsForESP()
    for _,room in pairs(rooms:GetChildren()) do
        if (espLogged[tostring(room.Address)]) then continue end

        local roomBoundingBox = room:FindFirstChild("BoundingBox")

        if (roomBoundingBox.ClassName == "Folder") then
            roomBoundingBox = roomBoundingBox.Part
        end

        if roomBoundingBox == nil then continue end

        espLogged[tostring(room.Address)] = {
            espText = room.Name,
            mainPart = roomBoundingBox,
            category = "roomESP",
            drawing = nil
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = espLogged[tostring(room.Address)].espText
        MatchaDrawing.Color = Color3.fromRGB(44,192,255)

        espLogged[tostring(room.Address)].drawing = MatchaDrawing

    end
end

local function scanBrokenGlassForESP()
    for _, _brokenGlass in pairs(brokenGlass:GetChildren()) do
        if (espLogged[tostring(_brokenGlass.Address)]) then continue end
        local part = _brokenGlass:FindFirstChildWhichIsA("WedgePart")

        if not part then continue end

        espLogged[tostring(_brokenGlass.Address)] = {
            espText = "Broken Glassshards.",
            mainPart = part,
            category = "shardESP",
            drawing = nil
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = espLogged[tostring(_brokenGlass.Address)].espText
        MatchaDrawing.Color = Color3.fromRGB(255, 31, 23)

        espLogged[tostring(_brokenGlass.Address)].drawing = MatchaDrawing
    end
end

local function renderESP()
    for espId, espTable in pairs(espLogged) do
        if (espTable.mainPart == nil) then continue end
            
        local worldPos, isVisible 

        local didWork, errorMessage = xpcall(function()
            worldPos, isVisible = WorldToScreen(espTable.mainPart.Position)
        end, function(erro)
            warn(tostring(erro))
            espLogged["espId"] = nil
            espLogged["espId"].drawing:Remove()
        end)

        if not didWork then
            espLogged["espId"] = nil
            espLogged["espId"].drawing:Remove()
         continue end
        

        if espTable.category == "itemESP" and config.itemESPEnabled then
            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos
            continue
        end
        
        if espTable.category == "roomESP" and config.roomESPEnabled then
            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos
            continue
        end

        if espTable.category == "shardESP" and config.shardESPEnabled then
            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos
            continue
        end

        espTable.drawing.Visible = false

    end
end

local window = Library:CreateWindow({
    Title = "Daddy's Demons",
    SubTitle = "v0.0.1",
    Resize = true,
    Size = Vector2.new(580, 700),
    MinimizeKey = "F1"
})

local information = window:AddTab({
    Title = "Info",
    Icon = "info",
})

local Settings = window:AddTab({
    Title = "Settings",
    Icon = "settings",
})

local ghostStatus = information:AddParagraph({
    Title = "Ghost Information",
    Content = ghostInformationText
})

local evidenceStatus = information:AddParagraph({
    Title = "Evidences Information",
    Content = evidenceInformationText,
})

local notesStatus = information:AddParagraph({
    Title = "Doctor's Note...",
    Content = noteInformationText
})

local guessesStatus = information:AddParagraph({
    Title = "Evidence-Based Guess",
    Content = guessInformationText,
})

local generalSettingsParagraph = Settings:AddParagraph({ 
    Title = "General Settings",
    Content = "Everything related to the ui controls and the scrips configs."
})

local itemESPToggle = Settings:AddToggle({
    Title = "Items ESP",
    Default = true,
})

local roomESPToggle = Settings:AddToggle({
    Title = "Rooms ESP",
    Default = true,
})

local shardESPToggle = Settings:AddToggle({
    Title = "Broken Glass ESP",
    Default = true,
})

itemESPToggle:OnChanged(function()
    config.itemESPEnabled = itemESPToggle.Value
end)

roomESPToggle:OnChanged(function()
    config.roomESPEnabled = roomESPToggle.Value
end)

shardESPToggle:OnChanged(function()
    config.shardESPEnabled = shardESPToggle.Value
end)

task.spawn(function()
    -- Run only once
    scanRoomsForESP() -- Only needs to scan once since c'mon rooms don't fucking change in demonology
    
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

        checkTraitsEvidence()
        
        updateGhostInformation()
        updateEvidenceInformation()
        updateNoteInformation()
        updateGuessInformation()

        scanItemsForESP()
        scanBrokenGlassForESP()
        -- updates Uilibrary information
        ghostStatus:SetContent(ghostInformationText)
        evidenceStatus:SetContent(evidenceInformationText)
        guessesStatus:SetContent(guessInformationText)
        notesStatus:SetContent(noteInformationText)        
        task.wait(0.5)
    end
end)

task.spawn(function()
    while Library.Unloaded == false do
        renderESP()
        task.wait(0.001)
    end
end)
