
if game.PlaceId == 18199615050 then warn("You're currently in the room, run this once you get in to a game. or your matcha bugged you might have to eject.") return end

local TheoOffsets = httpget("https://offsets.imtheo.lol/version-90f2fddd3b244ff6/offsets.json")
loadstring(game:HttpGet("https://scripts.wabisabi.mom/wabi-sabi-ui-lib.lua"))()

local players = game:GetService("Players")
local httpService = game:GetService("HttpService")
local lighting = game:GetService("Lighting")

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
local doors = workspace.Doors
local ragdolls = workspace.Ragdolls
local effectHolder = workspace.EffectHolder 
local ghostHumanoid = ghostModel.Humanoid
local invisibleGhostWalls = map.InvisibleGhostWalls
local rooms = map.Rooms

local ghostRoom = "N/A"
local ghostcurrentLocation = "N/A"
local ghostAverageSpeed = 0
local ghostCurrentSpeed = 0
local ghostGender = "N/A"
local ghostHunting = false
local ghostPreHuntSpeed = 11

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
    ["FastWhileInvis"] = 0,
    ["DulluhanSpeed"] = 0,
    ["DulluhanHeadless"] = 0,
    ["OniSpeed"] = 0,
    ["PhantomBlink"] = 0,
    ["GhoulEquipmentEffect"] = 0,
    ["VexLidar"] = 0,
    ["UmbraFootstep"] = 0,
    ["EntityAbility"] = 0,
    ["BansheeWail"] = 0,
    ["GhostBurn"] = 0,
    ["DybbukBodyMover"] = 0,
    ["WendigooSpeed"] = 0,
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
    Oni = {"Freezing Temperature", "Laser Projector", "Spirit Box", "OniSpeed"},
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
    Banshee = {"BansheeWail"},
    Demon = {},
    Dullahan = {"DulluhanSpeed", "DulluhanHeadless"},
    Dybbuk = {"DybbukBodyMover"},
    Entity = {"EntityAbility"},
    Ghoul = {"GhoulEquipmentEffect"},
    Keres = {"IsFemale"},
    Leviathan = {},
    Nightmare = {},
    Oni = {"OniSpeed"},
    Phantom = {"phantomBlink"},
    Ravager = {},
    Revenant = {},
    Shadow = {},
    Siren = {"IsFemale", "CanSlow"},
    Skinwalker = {},
    Specter = {},
    Spirit = {},
    Umbra = {"UmbraFootstep"},
    Vesper = {},
    Vex = {"VexLidar"},
    Wendigo = {"WendigooSpeed"},
    ["The Wisp"] = {"GhostBurn"},
    Wraith = {"IgnoresSalt"}
}

local ignoredGhost = {}
local scriptData = {}
local config = {
    unlimitedStamina = false,
    bright = true,
    itemESPEnabled = true,
    roomESPEnabled = true,
    closetESPEnabled = true,
    shardESPEnabled = true,
    ghostESPEnabled = true,
    ghostTracersESPEnabled = true,
    playerEnergyESPEnabled = true,
    zeroEvidence = false,
}
local currentTraitConfig = {
    fastCheck1 = 2.5,
    fastCheck2 = 3,
    phantomChecksRequired = 8,
    ghoulChecksRequired = 6,
    dullahanCheckRequired = 6,
}

local traitConfig = {
    default = {
        fastCheck1 = 2.5,
        fastCheck2 = 11,
    },

    ["difficulty407"] = {
        fastCheck1 = 5,
        fastCheck2 = 11,
    }
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

local function checkPrintsEvidence()
    if config.zeroEvidence then return end
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
        local roomTemperatureAttribute = room:GetAttribute("Temperature")
        if not roomTemperatureAttribute then continue end
        if (roomTemperatureAttribute < 0) then
            evidencesRecords["Freezing Temperature"] = 1;
            Library:Notify({Title = "Evidence Alert!", Content = "Freezing Temperature.", Duration = 4 })
            return;
        end
    end
end

local function checkGhostOrbEvidence()
    if evidencesRecords["Ghost Orb"] ~= 0 then return end
    if (workspace:FindFirstChild("GhostOrb")) then
        evidencesRecords["Ghost Orb"] = 1;
        Library:Notify({Title = "Evidence Alert!", Content = "Ghost Orb.", Duration = 4})
    else
        evidencesRecords["Ghost Orb"] = (config.zeroEvidence) and 0 or -1;
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
        if gamePlayer.Character == nil then continue end
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
        local character = gamePlayer.Character
        if not character then continue end
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
        if gamePlayer.Character == nil then continue end
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
        if gamePlayer.Character == nil then continue end
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
    local function checkFemale() -- can be 1 or -1
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

    local function checkCanSlow() -- can only be 1 since it might make mistake if it turns -1.
        if ghostTraitsRecords["CanSlow"] ~= 0 then return end
        if not ghostHunting then return end
        for _,player in pairs(players:GetChildren()) do
            if player:GetAttribute("Slowed") == true then
                ghostTraitsRecords["CanSlow"] = 1
                Library:Notify({Title = "Trait found!", Content = "It can slow!", Duration = 4})
            end
        end
    end

    local function checkIgnoreSalt() -- can only be 1 since it might make mistake if it turns -1.
        if ghostTraitsRecords["IgnoresSalt"] ~= 0 then return end
        if ignoredGhost["Wraith"] then return end
        if #saltPile:GetChildren() == 0 then return end

        if not scriptData["SteppedOnSalt"] then 
            scriptData["SteppedOnSalt"] = 0
        end
        
        for _,saltPile in pairs(saltPile:GetChildren()) do
            local saltPileCenter = saltPile:FindFirstChild("Center")
            if not saltPileCenter then continue end

            if saltPile.Name == "SaltLine" then
                if (saltPileCenter.Position - ghostModel["Right Leg"].Position).Magnitude < 3 then
                    scriptData["SteppedOnSalt"] += 1
                    return
                end
            end

            if saltPile.Name == "DisturbedSaltLine" then
                ghostTraitsRecords["Wraith"] = -1
                return
            end
        end
        
        if scriptData["SteppedOnSalt"] >= 2 then
            ghostTraitsRecords["Wraith"] = 1
            Library:Notify({Title = "Trait found!", Content = "Ignores salt???", Duration = 4})
        end
    end

    -- local function checkIfFast() -- can only be 1 since it might make mistake if it turns -1. LEGACY
    --     if ghostTraitsRecords["Fast"] ~= 0 then return end
    --     if not ghostHunting then return end

    --     if ((ghostCurrentSpeed - ghostPreHuntSpeed) >= currentTraitConfig.fastCheck1 and (ghostCurrentSpeed - ghostPreHuntSpeed) <= currentTraitConfig.fastCheck2)  then
    --         if (not scriptData["FastCheckTimestamp"]) or scriptData["FastCheckTimestamp"] == 0 then
    --             scriptData["FastCheckTimestamp"] = os.time()
    --         end
    
    --         if (os.time() - scriptData["FastCheckTimestamp"]) > 5 and scriptData["FastCheckTimestamp"] ~= 0 then  
    --             ghostTraitsRecords["Fast"] = 1
    --             Library:Notify({Title = "Trait found!", Content = "Ghost is definitely fast!", Duration = 4})
    --         end

    --     else
    --         scriptData["FastCheckTimestamp"] = 0
    --     end
    -- end

    local function checkSaltSlowed() -- can only be 1 since it might make mistake if it turns -1.
        if ghostHunting == false then return end
        if ghostTraitsRecords["SaltSlowed"] == 1 then return end
        
        if not scriptData["ghostSlowedSpeed"] then
            scriptData["ghostSlowedSpeed"] = 0
        end

        for _,saltPile in pairs(saltPile:GetChildren()) do
            local saltPileCenter = saltPile:FindFirstChild("Center")
            if not saltPileCenter then continue end

            if (saltPileCenter.Position - ghostModel["Right Leg"].Position).Magnitude < 3 then
                if (ghostCurrentSpeed < ghostPreHuntSpeed) then
                    ghostTraitsRecords["SaltSlowed"] = 1
                    Library:Notify({Title = "Trait found!", Content = "Ghost got slowed by salt.", Duration = 4})
                end
                return
            end
        end
    end
    
    local function checkPhantomBlink()
        if ghostTraitsRecords["PhantomBlink"] ~= 0 then return end
        if not ghostHunting then return end

        if not scriptData["checkFastBlinkLog"] then
            scriptData["checkFastBlinkLog"] = {}
            table.insert(scriptData["checkFastBlinkLog"], ghostCurrentSpeed)
            return
        end

        if ghostCurrentSpeed ~= scriptData["checkFastBlinkLog"][#scriptData["checkFastBlinkLog"]] then
            table.insert(scriptData["checkFastBlinkLog"], ghostCurrentSpeed)
        end
        
        if #scriptData["checkFastBlinkLog"] < 13 then return end
        local checksPassed = 0
        for i = 1,12 do
            if scriptData["checkFastBlinkLog"][i] == scriptData["checkFastBlinkLog"][i+2] then
                if scriptData["checkFastBlinkLog"][i+1] ~= scriptData["checkFastBlinkLog"][i+3] then return end
                checksPassed += 1
            end
        end

        if checksPassed >= currentTraitConfig.phantomChecksRequired then
            ghostTraitsRecords["PhantomBlink"] = 1
            Library:Notify({Title = "Trait found!", Content = "Faster when invisible!", Duration = 4})
        else
            table.insert(ignoredGhost, "Phantom")
            ghostTraitsRecords["PhantomBlink"] = -1
            Library:Notify({Title = "Trait found!", Content = "Not a phantom, surely?", Duration = 4})
        end  
        
    end

    local function checkDulluhanSpeed()
        if ghostTraitsRecords["DulluhanSpeed"] == 1 then return end
        if ghostHunting then 

            if not scriptData["Dullahanspeedometer"] then
                scriptData["Dullahanspeedometer"] = {}
                scriptData["DullahanspeedometerTimestamp"] = {}
                table.insert(scriptData["Dullahanspeedometer"], ghostCurrentSpeed)
                table.insert(scriptData["DullahanspeedometerTimestamp"], os.time())
            end

            if ((os.time() - scriptData["DullahanspeedometerTimestamp"][#scriptData["DullahanspeedometerTimestamp"]]) > 1) then
                table.insert(scriptData["Dullahanspeedometer"], ghostCurrentSpeed)
                table.insert(scriptData["DullahanspeedometerTimestamp"], os.time())
            end

        else
            if not scriptData["Dullahanspeedometer"] then return end
            if #scriptData["Dullahanspeedometer"] == 0 then return end

            local checksCompleted = 0

            for i,dullahanSpeed in pairs(scriptData["Dullahanspeedometer"]) do
                if dullahanSpeed == nil then return end
                if scriptData["Dullahanspeedometer"][i+1] == nil then return end
                if scriptData["Dullahanspeedometer"][i+1] > dullahanSpeed then
                    checksCompleted += 1
                    if checksCompleted >= currentTraitConfig.dullahanCheckRequired then
                        ghostTraitsRecords["DulluhanSpeed"] = 1
                        Library:Notify({Title = "Trait found!", Content = "Speed increasing, dullahan?", Duration = 4})
                        return
                    end
                else
                    checksCompleted = 0
                end
            end

            scriptData["Dullahanspeedometer"] = {}
            scriptData["DullahanspeedometerTimestamp"] = {}
        end
    end

    local function checkDulluhanHeadless()
        if ghostTraitsRecords["DulluhanHeadless"] ~= 0 then return end
        local headlessAttribute = ghostModel:GetAttribute("Headless") 
        if headlessAttribute == nil then return end
        if headlessAttribute then 
            ghostTraitsRecords["DulluhanHeadless"] = 1
            Library:Notify({Title = "Trait found!", Content = "Dulluhan headless!!!", Duration = 4})
        end
    end

    local function checkOniSpeed()
        if ghostTraitsRecords["OniSpeed"] ~= 0 then return end
        if ghostAverageSpeed ~= math.abs(ghostAverageSpeed) then return end

        local function reset()
            scriptData["OniSpeedometer"] = {} 
            scriptData["OniSpeedometerTimestamp"] = {}
        end

        if ghostHunting then
            if not scriptData["OniSpeedometer"] then
                scriptData["OniSpeedometer"] = {} 
                scriptData["OniSpeedometerTimestamp"] = {}
                table.insert(scriptData["OniSpeedometer"], ghostCurrentSpeed)
                table.insert(scriptData["OniSpeedometerTimestamp"], os.time())
                return
            end

            if #scriptData["OniSpeedometer"] == 0 then
                table.insert(scriptData["OniSpeedometer"], ghostCurrentSpeed)
                table.insert(scriptData["OniSpeedometerTimestamp"], os.time())
            end


            if ((os.time() - scriptData["OniSpeedometerTimestamp"][#scriptData["OniSpeedometerTimestamp"]]) > 1) then
                table.insert(scriptData["OniSpeedometer"], ghostCurrentSpeed)
                table.insert(scriptData["OniSpeedometerTimestamp"], os.time())
                return
            end
        else
            if not scriptData["OniSpeedometer"] then
                reset()
                return
            end
            if #scriptData["OniSpeedometer"] == 0 then return end
            if #scriptData["OniSpeedometer"] < 5 then -- not enough data.
                reset()
                return
            end

            local totalSpeed = 0

            for _,speed in pairs(scriptData["OniSpeedometer"]) do
                if speed == ghostPreHuntSpeed then reset() return end
                totalSpeed += speed
            end

            if (totalSpeed / #scriptData["OniSpeedometer"] == scriptData["OniSpeedometer"][1] and ghostAverageSpeed == scriptData["OniSpeedometer"][1]) then
                ghostTraitsRecords["OniSpeed"] = 1
                Library:Notify({Title = "Trait found!", Content = "Always sprinting...", Duration = 4})
                reset()
                return
            end
        end
    end

    local function checkGhoulEquipmentEffect()
        if ghostTraitsRecords["GhoulEquipmentEffect"] ~= 0 then return end

        local ghostModelAttribute = ghostModel:GetAttribute("CantDisableElectronics")
        if ghostModelAttribute then
            if ghostModelAttribute ~= true then return end
            ghostTraitsRecords["GhoulEquipmentEffect"] = 1
            Library:Notify({Title = "Trait found!", Content = "Can't disable electronic!", Duration = 4})
            return
        end

        if ghostHunting == false then return end


        local function verify()
            local checksPassed = 0
            local checkRequired = currentTraitConfig.ghoulChecksRequired 
            
            if not scriptData["spiritBoxEnableRecord"] then 
                scriptData["spiritBoxEnableRecord"] = {}
            end

            for _,v in pairs(scriptData["spiritBoxEnableRecord"]) do
                if v then
                    checksPassed += 1
                else
                    checksPassed = 0
                    checkRequired += .25
                end
            end
            
            if checksPassed >= checkRequired then
                return true
            end
            return false
        end

        if not scriptData["spiritBoxEnableRecord"] then 
            scriptData["spiritBoxEnableRecord"] = {}
        end

        if #scriptData["spiritBoxEnableRecord"] > 6 then
            if verify() then
                ghostTraitsRecords["GhoulEquipmentEffect"] = 1
                Library:Notify({Title = "Trait found!", Content = "Can't disable electronic!", Duration = 4})
                return true
            end
        end

        local function findSpiritBox()
            for _,item in pairs(items:GetChildren()) do
                local itemNameAttribute = item:GetAttribute("ItemName")
                if itemNameAttribute ~= "Spirit Box" then continue end
                return item
            end

            for _, player in pairs(players:GetChildren()) do
                local playerCharacter = player.Character
                if not playerCharacter then continue end
                local equippedItem = playerCharacter:FindFirstChildWhichIsA("Model")
                if not equippedItem then continue end
                local itemNameAttribute = equippedItem:GetAttribute("ItemName")
                if not itemNameAttribute then continue end
                if itemNameAttribute ~= "Spirit Box" then continue end
                return equippedItem
            end

            return nil
        end

        local spiritBox = findSpiritBox()
        local ghostHumanoidRootPart = ghostModel:FindFirstChild("HumanoidRootPart")
        if not spiritBox then return end
        local spiritBoxEnableStatus = spiritBox:GetAttribute("Enabled")
        if not ghostHumanoidRootPart then return end
        if spiritBoxEnableStatus == nil then return end
        local spiritBoxHandle = spiritBox:FindFirstChild("Handle")
        if not spiritBoxHandle then return end
        if (spiritBoxHandle.Position - ghostHumanoidRootPart.Position).Magnitude < 20 then 
            table.insert(scriptData["spiritBoxEnableRecord"], spiritBoxEnableStatus)
        end
    end

    local function checkVexLidar()
        if ghostTraitsRecords["VexLidar"] ~= 0 then return end
        local ghostLidarAttribute = ghostModel:GetAttribute("InvisibleOnLIDAR")
        if ghostLidarAttribute == nil then return end
        if ghostLidarAttribute ~= true then return end

        ghostTraitsRecords["VexLidar"] = 1
        Library:Notify({Title = "Trait found!", Content = "Undetectable thru lidar.", Duration = 4})
    end

    local function checkUmbraFootstep()
        if ghostTraitsRecords["UmbraFootstep"] ~= 0 then return end
        if not ghostModel then return end
        local ghostFootstep = ghostModel:FindFirstChild("GhostFootsteps")
        if not ghostFootstep then
            ghostTraitsRecords["UmbraFootstep"] = 1
            Library:Notify({Title = "Trait found!", Content = "Ghost has no footstep.", Duration = 4})
        else
            ghostTraitsRecords["UmbraFootstep"] = -1
        end
    end

    local function checkEntityAbility()
        if ghostTraitsRecords["EntityAbility"] ~= 0 then return end
        local entitySmoke = effectHolder:FindFirstChild("SmokeHolder")
        if not entitySmoke then return end
        ghostTraitsRecords["EntityAbility"] = 1
        Library:Notify({Title = "Trait found!", Content = "An item has been teleported!", Duration = 4})
    end

    local function checkBansheeWail()
        if ghostTraitsRecords["BansheeWail"] ~= 0 then return end
        if not ghostHunting then return end
        local ghostHumanoidRootPart = ghostModel:FindFirstChild("HumanoidRootPart")
        if not ghostHumanoidRootPart then return end
        local huntSound = ghostHumanoidRootPart:FindFirstChild("Hunt")
        if not huntSound then return end
        local huntPlaybackSpeed = memory_read("float", huntSound.Address+offsets.Sound.PlaybackSpeed)
        if huntPlaybackSpeed > 1 then
            ghostTraitsRecords["BansheeWail"] = 1
            Library:Notify({Title = "Trait found!", Content = "Banshee unique wail!", Duration = 4})
        end
    end

    local function checkGhostBurn()
        if not ghostHunting then return end
        if ghostTraitsRecords["GhostBurn"] ~= 0 then return end
        local ghostBurning = ghostModel:GetAttribute("Burning")
        if ghostBurning then
            ghostTraitsRecords["GhostBurn"] = 1
            return
        end
    end

    local function checkDybbukBodyMover()
        if ghostTraitsRecords["DybbukBodyMover"] ~= 0 then return end
        if not ghostHunting then return end

        if not scriptData["RagdollsLogged"] then
            scriptData["RagdollsLogged"] = {}
        end
        for _,corpse in ipairs(ragdolls:GetChildren()) do
            if not scriptData["RagdollsLogged"][corpse.Name] then
                scriptData["RagdollsLogged"][corpse.Name] = {}
                scriptData["RagdollsLogged"][corpse.Name].loggedTime = os.time()
            end

            if ((os.time() - scriptData["RagdollsLogged"][corpse.Name].loggedTime) < 3 ) then return end -- Fresh corpse, means that the corpse is still actively falling making falsePositives

            local corpseHumanoidRootPart = corpse:FindFirstChild("HumanoidRootPart")
            if not corpseHumanoidRootPart then continue end
            local corpseLinearVelocity = corpseHumanoidRootPart.AssemblyLinearVelocity
            
            local x = math.abs(corpseLinearVelocity.X)
            local y = math.abs(corpseLinearVelocity.Y)
            local z = math.abs(corpseLinearVelocity.z)

            if x > 10 or y > 10 or z > 10 then
                ghostTraitsRecords["DybbukBodyMover"] = 1
                Library:Notify({Title = "Trait found!", Content = "A body has been been thrown!", Duration = 4})
                return
            end
        end
    end

    local function checkWendigoo()  
        if ghostTraitsRecords["WendigooSpeed"] ~= 0 then return end
        if not scriptData["WendigooStatistics"] then
            scriptData["WendigooStatistics"] = {}
            scriptData["WendigooStatistics"].huntLog = {}
            scriptData["WendigooStatistics"].ghostSpeedLog = {}
            scriptData["WendigooStatistics"].teamEnergyLog = {}
            scriptData["WendigooStatistics"].passedChecks = 0
            scriptData["WendigooStatistics"].failedChecks = 0
        end

        local function getTeamAverageEnergy()
            local playersChildren = players:GetChildren()
            local total = 0
            for _,player in pairs(playersChildren) do
                local playerEnergy = player:GetAttribute("Energy")
                if type(playerEnergy) ~= "number" then continue end
                total += math.floor(playerEnergy * 100) / 100
            end

            return total / #playersChildren
        end

        local function printLog()
            print(">Logged<")
            print(scriptData["WendigooStatistics"].huntLog[#scriptData["WendigooStatistics"].huntLog])
            print(scriptData["WendigooStatistics"].ghostSpeedLog[#scriptData["WendigooStatistics"].ghostSpeedLog])
            print(scriptData["WendigooStatistics"].teamEnergyLog[#scriptData["WendigooStatistics"].teamEnergyLog])
        end

        if ghostHunting == scriptData["WendigooStatistics"].huntLog[#scriptData["WendigooStatistics"].huntLog] then return end
        table.insert(scriptData["WendigooStatistics"].huntLog, ghostHunting)
        table.insert(scriptData["WendigooStatistics"].ghostSpeedLog, ghostCurrentSpeed)
        table.insert(scriptData["WendigooStatistics"].teamEnergyLog, getTeamAverageEnergy())

        if #scriptData["WendigooStatistics"].huntLog < 2 then return end

        if (scriptData["WendigooStatistics"].teamEnergyLog[#scriptData["WendigooStatistics"].teamEnergyLog] ~= scriptData["WendigooStatistics"].teamEnergyLog[#scriptData["WendigooStatistics"].teamEnergyLog-1]) then
            if scriptData["WendigooStatistics"].ghostSpeedLog[#scriptData["WendigooStatistics"].ghostSpeedLog] ~= scriptData["WendigooStatistics"].ghostSpeedLog[#scriptData["WendigooStatistics"].ghostSpeedLog-1] then
                -- printLog()
                -- print("Speed is different after energy changed.")
                scriptData["WendigooStatistics"].passedChecks += 1
            else
                -- print("Failed the test!")
                scriptData["WendigooStatistics"].passedChecks = 0
            end

        else
            -- print("No energy change, not checking for speed...")
        end

        if scriptData["WendigooStatistics"].passedChecks >= 4 then
            ghostTraitsRecords["WendigooSpeed"] = 1
            Library:Notify({Title = "Trait found!", Content = "Speed changed on energy level!", Duration = 4})
        end

        if scriptData["WendigooStatistics"].failedChecks >= 6 then
            ghostTraitsRecords["WendigooSpeed"] = -1
        end
    end

    checkFemale()
    checkCanSlow()
    checkIgnoreSalt()
    -- checkIfFast()
    checkSaltSlowed()
    checkPhantomBlink()
    checkDulluhanSpeed()
    checkDulluhanHeadless()
    checkOniSpeed()
    checkGhoulEquipmentEffect()
    checkVexLidar()
    checkUmbraFootstep()
    checkEntityAbility()
    checkBansheeWail()
    checkGhostBurn()
    checkDybbukBodyMover()
    checkWendigoo()
end

local function updateGhostInformation()
    local function ghostPreHuntSpeedCheck()
        if not ghostHunting then 
            ghostPreHuntSpeed = ghostCurrentSpeed
        end
    end

    local function verifyGhostIsHunting()
        local temporaryIsHunting = false

        local ghostModelIsHunting = ghostModel:GetAttribute("Hunting")
        local exitDoor = doors:FindFirstChild("ExitDoor")
        
        if exitDoor ~= nil then
            if exitDoor:GetAttribute("Locked") then
                if exitDoor:GetAttribute("Locked") == true then 
                    temporaryIsHunting = true 
                    return true
                end
            end
        end;
        
        if ghostModelIsHunting == true then
            temporaryIsHunting = true
            return true
        end

        return false
    end

    local temporaryGhostInformationText = ""
    local unknownData = "Not detecting..."

    ghostRoom = ghostModel:GetAttribute("FavoriteRoom")
    ghostcurrentLocation = ghostModel:GetAttribute("CurrentRoom")
    ghostCurrentSpeed = math.floor(memory_read("float", ghostHumanoid.Address+offsets.Humanoid.Walkspeed) * 100) / 100
    ghostGender = ghostModel:GetAttribute("Gender")
    ghostHunting = verifyGhostIsHunting()

    local ghostInformationTemplate = {
        ["Ghost Room"] = ghostRoom or unknownData,
        ["Current Location"] = ghostcurrentLocation or unknownData,
        ["Average Speed"] = ghostAverageSpeed or unknownData,
        ["Current Speed"] = ghostCurrentSpeed or unknownData,
        ["Gender"] = ghostGender or unknownData,
        ["Ghost Hunting"] = ghostHunting or false,
        ["Pre-Hunt Speed"] = ghostPreHuntSpeed or unknownData
    }

    local orderedGhostInformation = {
        "Ghost Room",
        "Current Location",
        "Average Speed",
        "Current Speed",
        "Gender",
        "Pre-Hunt Speed",
        "Ghost Hunting",
    }

    for _, informationTitleOrdered in pairs(orderedGhostInformation) do
        temporaryGhostInformationText = temporaryGhostInformationText .. informationTitleOrdered .. ": " .. tostring(ghostInformationTemplate[informationTitleOrdered])
        temporaryGhostInformationText = temporaryGhostInformationText .. "\n"
    end

    ghostInformationText = temporaryGhostInformationText

    ghostPreHuntSpeedCheck()
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
    local function checkIfNoTraitFound()
        local passedCheck = 0
        for _,traitValue in pairs(ghostTraitsRecords) do
            passedCheck += 1
        end

        if passedCheck == #ghostTraitsRecords then 
            return true
        end
        return false
    end

    local temporaryNoteInformation = ""
    if ghostTraitsRecords["IgnoresSalt"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Probably a wraith.\n"
    end
    if ghostTraitsRecords["CanSlow"] == 1 and ghostTraitsRecords["IsFemale"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Probably a siren.\n"
    end

    if ghostTraitsRecords["PhantomBlink"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Might be a Phantom, due to to it's blinking speed.\n"
    end

    if ghostTraitsRecords["SaltSlowed"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "This might actually be a Aswang?!? \n"
    end

    if evidencesRecords["Ghost Orb"] == 1 and config.zeroEvidence then
        temporaryNoteInformation = temporaryNoteInformation .. "If this is zero evidence then probably a skinwalker.\n"
    end

    if ghostTraitsRecords["FastWhileInvis"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Might be a phantom? If ghost speed keeps alternating it's phantom.\n"
    end

    if ghostTraitsRecords["DulluhanSpeed"] == 1 or ghostTraitsRecords["DulluhanHeadless"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "A Dullhan traits found, Dullahan?\n"
    end

    if ghostTraitsRecords["OniSpeed"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Speed is static, Oni?\n"
    end

    if ghostTraitsRecords["GhoulEquipmentEffect"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Can't disable electronic, Ghoul?\n"
    end

    if ghostTraitsRecords["VexLidar"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Can't be detected through lidar, Vex?\n"
    end

    if ghostTraitsRecords["UmbraFootstep"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Ghost has no footstep, Umbra?\n"
    end

    if ghostTraitsRecords["EntityAbility"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Item teleportation detected, Entity?\n"
    end

    if ghostTraitsRecords["BansheeWail"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Banshee unique wail found, Banshee?\n"
    end

    if ghostTraitsRecords["GhostBurn"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Ghost is burning, Wisp?\n"
    end

    if ghostTraitsRecords["DybbukBodyMover"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Body was thrown! Dybbuk?\n"
    end

    if ghostTraitsRecords["WendigooSpeed"] == 1 then
        temporaryNoteInformation = temporaryNoteInformation .. "Speed changed per energy, Wendigoo?\n"
    end

    if temporaryNoteInformation == "" then
        temporaryNoteInformation = "I'm still thinking sir."
    end

    if checkIfNoTraitFound() then 
        temporaryNoteInformation = "I don't know sir..."
    end
    
    noteInformationText = temporaryNoteInformation
end

local function updateGuessInformation()
    local mainTemporaryString = ""
    local highestVerified = 0
    local totalPassedChecks = 0
    currentGhost = {}

    local function shouldIgnore(ghostName)
        for ghost, _ in pairs(ignoredGhost) do
            if ghost == ghostName then
                return true
            end
        end
        return false
    end

    if not scriptData["ghostGuessCurrentData"] then
        scriptData["ghostGuessCurrentData"] = {}
    end

    for _ghostName,_ghostEvidence in pairs(ghostEvidence) do
        if shouldIgnore(_ghostName) then continue end
        if not scriptData["ghostGuessCurrentData"][_ghostName] then
            scriptData["ghostGuessCurrentData"][_ghostName] = {}
        end
        scriptData["ghostGuessCurrentData"][_ghostName].missingEvidence = {}
        scriptData["ghostGuessCurrentData"][_ghostName].passedChecks = 0
        scriptData["ghostGuessCurrentData"][_ghostName].passedTraits = 0

        for _,evidenceName in ipairs(_ghostEvidence) do
            if evidencesRecords[evidenceName] == 1 then
                scriptData["ghostGuessCurrentData"][_ghostName].passedChecks += 1
            else
                table.insert(scriptData["ghostGuessCurrentData"][_ghostName].missingEvidence, evidenceName) 
            end
        end

        for _,traitName in ipairs(ghostTraits[_ghostName]) do
            if (ghostTraitsRecords[traitName] == 1) then
                scriptData["ghostGuessCurrentData"][_ghostName].passedTraits += 1
            end
        end

        if scriptData["ghostGuessCurrentData"][_ghostName].passedChecks > highestVerified then
            highestVerified = scriptData["ghostGuessCurrentData"][_ghostName].passedChecks
        end
    end

    for ghostName,ghostObj in pairs(scriptData["ghostGuessCurrentData"]) do
        if ghostObj.passedChecks < highestVerified then continue end
        totalPassedChecks += ghostObj.passedChecks
    end

    for ghostName,ghostObj in pairs(scriptData["ghostGuessCurrentData"]) do
        local function missingEvidenceToString()
            if #ghostObj.missingEvidence == 0 then return "" end
            local newString = ""
            for i,v in pairs(ghostObj.missingEvidence) do
                local endString = ", "
                if i == #ghostObj.missingEvidence then
                    endString = ""
                end
                if i == 1 then
                    newString = newString .. " ["
                end
                
                newString = newString ..  v .. endString
            end
            newString = newString .. "]"
            return newString
        end

        local function percentageToString(value)
            return " " .. tostring(math.floor((value / totalPassedChecks) * 100), .5) .. "%"
        end
        if ghostObj.passedChecks < highestVerified then continue end

        local misString = missingEvidenceToString()
        local percentageString = percentageToString(ghostObj.passedChecks)
        mainTemporaryString = mainTemporaryString .. ghostName .. misString .. percentageString .. "\n"
        
    end

    if highestVerified == 0 then
        guessInformationText = "Not enough evidence..."
        return
    end
    guessInformationText = mainTemporaryString
end

local function scanItemsForESP()
    for _,item in pairs(items:GetChildren()) do
        if (espLogged[tostring(item.Address)]) then continue end
        if (item.Handle == nil) then continue end
        if (item:GetAttribute("ItemName") == nil) then continue end

        espLogged[tostring(item.Address)] = {
            espText = item:GetAttribute("ItemName"),
            mainPart = item.Handle,
            category = "itemESP",
            drawing = nil
        }
        
        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = espLogged[tostring(item.Address)].espText

        espLogged[tostring(item.Address)].drawing = MatchaDrawing
    end

    local function scanItemsForESP_Remove(espId)
        espLogged[espId].drawing:Remove()
        espLogged[espId] = nil
    end

    for espId,espObject in pairs(espLogged) do -- checks if it's in the inventory, if so then clear it from the stored esp.
        if espObject.category ~= "itemESP" then continue end
        if espObject.mainPart == nil then scanItemsForESP_Remove(espId) continue end
        if espObject.mainPart.Parent == nil then scanItemsForESP_Remove(espId) continue end
        if espObject.mainPart.Parent.Parent == nil then scanItemsForESP_Remove(espId) continue end
        if espObject.mainPart.Parent.Parent.Name == "ToolsHolder" then scanItemsForESP_Remove(espId) end
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
            drawing = nil,
            unremovable = true
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = espLogged[tostring(room.Address)].espText
        MatchaDrawing.Color = Color3.fromRGB(44,192,255)

        espLogged[tostring(room.Address)].drawing = MatchaDrawing

    end
end

local function scanClosetForESP()
    for _,closet in pairs(invisibleGhostWalls:GetChildren()) do
        if espLogged[tostring(closet.Address)] then continue end
        if closet.Name ~= "GhostCloset" then continue end
        espLogged[tostring(closet.Address)] = {
            espText = "Closet",
            mainPart = closet,
            category = "closetESP",
            drawing = nil,
            unremovable = true
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = espLogged[tostring(closet.Address)].espText
        MatchaDrawing.Color = Color3.fromRGB(255, 145, 0)

        espLogged[tostring(closet.Address)].drawing = MatchaDrawing
    end
end

local function scanBrokenGlassForESP()
    for _, _brokenGlass in pairs(brokenGlass:GetChildren()) do
        if (espLogged[tostring(_brokenGlass.Address)]) then continue end
        
        local part = _brokenGlass:FindFirstChildWhichIsA("WedgePart")

        if not part then continue end
        if not scriptData["storedShardTimestamp"] then
            scriptData["storedShardTimestamp"] = {}
        end

        table.insert(scriptData["storedShardTimestamp"], os.time())
        espLogged[tostring(_brokenGlass.Address)] = {
            espText = "Broken Glassshards.",
            mainPart = part,
            category = "shardESP",
            drawing = nil,
            timestamp = os.time(),
            timestampId = #scriptData["storedShardTimestamp"]
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Outline = true
        MatchaDrawing.Text = espLogged[tostring(_brokenGlass.Address)].espText
        MatchaDrawing.Color = Color3.fromRGB(255, 31, 23)

        espLogged[tostring(_brokenGlass.Address)].drawing = MatchaDrawing
        
    end
end

local function scanGhostForESP()
    local ghostHumanoidRootPart = ghostModel:FindFirstChild("HumanoidRootPart")
    if not ghostHumanoidRootPart then warn("GHOST NOT FOUND!") return end

    espLogged[tostring(ghostModel.Address)] = {
            espText = "Ghost",
            mainPart = ghostHumanoidRootPart,
            category = "ghostESP",
            drawing = nil,
            unremovable = true,
    }

    local MatchaDrawing = Drawing.new("Text")
    MatchaDrawing.Outline = true
    MatchaDrawing.Text = espLogged[tostring(ghostModel.Address)].espText
    MatchaDrawing.Color = Color3.fromRGB(158, 24, 19)

    espLogged[tostring(ghostModel.Address)].drawing = MatchaDrawing
end

local function ghostTracersESP()
    local ghostHead = ghostModel:FindFirstChild("Head")
    if not ghostHead then warn("GHOST NOT FOUND!") return end

    espLogged[tostring(ghostHead.Address)] = {
            espText = "GhostTracers",
            mainPart = ghostHead,
            category = "ghostTracersESP",
            drawing = nil,
            unremovable = true,
    }

    local MatchaDrawing = Drawing.new("Line")
    MatchaDrawing.Color = Color3.fromRGB(158, 24, 19)
    MatchaDrawing.Thickness = 1
    MatchaDrawing.From = Vector2.new(0,0)

    espLogged[tostring(ghostHead.Address)].drawing = MatchaDrawing
end

local function playerEnergyESP()
    for _,player in pairs(players:GetChildren()) do
        if player.Address == players.LocalPlayer.Address then continue end
        if espLogged[tostring(player.Address)] then continue end
        local character = player.Character
        if not character then continue end
        local targetPlayerHumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not targetPlayerHumanoidRootPart then continue end

        espLogged[tostring(player.Address)] = {
            espText = "Energy: ",
            mainPart = targetPlayerHumanoidRootPart,
            category = "playerEnergyESP",
            drawing = nil,
            targetPlayer = player,
            energy = 100,
        }

        local MatchaDrawing = Drawing.new("Text")
        MatchaDrawing.Text =  espLogged[tostring(player.Address)].espText
        MatchaDrawing.Outline = true
        MatchaDrawing.Color = Color3.fromRGB(0, 255, 0)

        espLogged[tostring(player.Address)].drawing = MatchaDrawing
    end
end

local function clearESPLogged()
    warn("==> Clearing ESP-Related data")
    for espId, espObject in pairs(espLogged) do
        if (espObject.unremovable) then continue end
        print("Removing espLogged with the category of: " .. espObject.category)
        espLogged[espId].drawing:Remove()
        espLogged[espId].espText = nil
        espLogged[espId].mainPart = nil
        espLogged[espId].category = nil
        espLogged[espId] = nil
    end

    -- scanRoomsForESP()
    -- scanGhostForESP()
end

local function resetAllSavedInformation()
    warn("Beginning reset.")
    for evidenceName, _ in pairs(evidencesRecords) do
        evidencesRecords[evidenceName] = 0
    end

    for traitName, _ in pairs(ghostTraitsRecords) do
        ghostTraitsRecords[traitName] = 0
    end

    clearESPLogged()

    ignoredGhost = {}
    scriptData = {}
    ghostSpeedRecords = {}
    ghostBlinkRecords = {}

    warn("All data resetted.")
end

local function changeTraitConfigs(choice)
    print("==> Changing settings to " .. choice)

    local function change(configTable)
        for optionName, optionValues in pairs(configTable) do
            currentTraitConfig[optionName] = optionValues
        end
    end

    if choice == "Default" then
        local configForSelected = traitConfig.default
        change(configForSelected)
    end

    if choice == "4.07" then
        local configForSelected = traitConfig.difficulty407
        change(configForSelected)
    end

    resetAllSavedInformation()
end

local function renderESP()
    for espId, espTable in pairs(espLogged) do
        if (espLogged[espId] == nil) then continue end
        if (espTable.mainPart == nil) then continue end
            
        local worldPos, isVisible 

        if espTable.mainPart.Parent == nil and espTable.unremovable == false then
            espLogged[espId].drawing:Remove()
            espLogged[espId] = nil
            return
        end

        local didWork, errorMessage = pcall(function()
            worldPos, isVisible = WorldToScreen(espTable.mainPart.Position)
        end)

        if not didWork then
            warn("===> Rendering ESP failed.")
            warn(errorMessage)
            print("espId of: " .. espId)
            print("mainPart Position: " .. tostring(espTable.mainPart))
            print("parent of mainpart Name: " .. tostring(espTable.mainPart.Parent.Name))
            -- clearESPLogged()
            espLogged[espId].drawing:Remove()
            espLogged[espId] = nil
            return 
        end
        
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

        if espTable.category == "closetESP" and config.closetESPEnabled then
            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos
            continue
        end

        if espTable.category == "shardESP" and config.shardESPEnabled then
            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos

            if not espTable.timestamp then
                espTable.drawing.Text = espTable.espText .. "[UNK]"
                continue
            end

            espTable.drawing.Text = espTable.espText .. "[" .. (espTable.timestamp - scriptData["storedShardTimestamp"][#scriptData["storedShardTimestamp"]]) .. "s]"
        
            continue
        end

        if espTable.category == "ghostESP" and config.ghostESPEnabled then
            local localPlayer = players.LocalPlayer
            if localPlayer == nil then continue end
            local character = localPlayer.Character
            if character == nil then continue end
            local localPlayerHumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not localPlayerHumanoidRootPart then continue end

            espTable.drawing.Text = "Ghost\n[".. math.floor((localPlayerHumanoidRootPart.Position - espTable.mainPart.Position).Magnitude) .. "]"
            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos

            continue
        end

        if espTable.category == "ghostTracersESP" and config.ghostTracersESPEnabled then
            espTable.drawing.Visible = isVisible
            espTable.drawing.To = worldPos
            continue
        end

        if espTable.category == "playerEnergyESP" and config.playerEnergyESPEnabled then
            local playerEnergyLevel = espTable.targetPlayer:GetAttribute("Energy")
            local playerCorpse = ragdolls:FindFirstChild(espTable.targetPlayer.Name)
            if playerEnergyLevel == nil then playerEnergyLevel = -9999 end            
            
            if playerCorpse then
                espTable.drawing.Text = "Energy b/Death: " .. espTable.energy or "UNK"
            else
                espTable.energy = math.floor(playerEnergyLevel)
                espTable.drawing.Text = "Energy: " .. espTable.energy or "UNK"
            end

            espTable.drawing.Visible = isVisible
            espTable.drawing.Position = worldPos
            continue
        end
        
        if espTable.unremovable == false then
            espLogged[espId].drawing:Remove()
            espLogged[espId] = nil
            continue
        end
        
        espTable.drawing.Visible = false
    end
end

local function priorityRunner()
    local function runUnlimitedStamina()
        if not config.unlimitedStamina then return end
        local localPlayer = players.LocalPlayer
        if not localPlayer then return end
        local playerStamina = localPlayer:GetAttribute("Stamina")
        if playerStamina == nil then return end
        local maxStamina = workspace:GetAttribute("MaxStamina") or 100
        if playerStamina < (maxStamina / 2) then
            localPlayer:SetAttribute("Stamina", maxStamina)
        end
    end

    local function runBright()
        if not config.bright then return end
        memory_write("float", lighting.Address+offsets.Lighting.Ambient, 0.4)
        memory_write("float", lighting.Address+offsets.Lighting.Ambient+4, 0.4)
        memory_write("float", lighting.Address+offsets.Lighting.Ambient+8, 0.4)
    end

    runUnlimitedStamina()
    runBright()
end

local window = Library:CreateWindow({
    Title = "Daddy's Demons",
    SubTitle = "Developed by Baited",
    Resize = true,
    Size = Vector2.new(580, 700),
    MinimizeKey = "F1"
})

local information = window:AddTab({
    Title = "Info",
    Icon = "info",
})

local main = window:AddTab({
    Title = "Main",
    Icon = "toolbox",
})

local espSetting = window:AddTab({
    Title = "Esp",
    Icon = "eye",
})


local settings = window:AddTab({
    Title = "Settings",
    Icon = "settings",
})

local unlimitedStaminaToggle = main:AddToggle({
    Title = "Unlimited stamina",
    Default = true
})

main:AddParagraph({
    Title = "Information about Bright.",
    Content = "I'd recommend just using matcha ambient, if you want to use the script bright then use a camera first then unequip it."
})

local brightToggle = main:AddToggle({
    Title = "Bright",
    Default = false
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

espSetting:AddParagraph({ 
    Title = "ESP Settings",
    Content = "Just your ordinary ESP."
})

local itemESPToggle = espSetting:AddToggle({
    Title = "Items ESP",
    Default = true,
})

local roomESPToggle = espSetting:AddToggle({
    Title = "Rooms ESP",
    Default = true,
})

local closetESPToggle = espSetting:AddToggle({
    Title = "Closet ESP",
    Default = true,
})

local shardESPToggle = espSetting:AddToggle({
    Title = "Broken Glass ESP",
    Default = true,
})

local GhostESPToggle = espSetting:AddToggle({
    Title = "Ghost ESP",
    Default = true,
})

local GhostTracersToggle = espSetting:AddToggle({
    Title = "Ghost Tracers ESP",
    Default = true,
})

local playerEnergyESPToggle = espSetting:AddToggle({
    Title = "Player Energy ESP",
    Default = true,
})

settings:AddParagraph({ 
    Title = "Game-Related Settings",
    Content = "Mainly for how you want to go about getting evidence and such"
})

local zeroEvidenceMode = settings:AddToggle({
    Title = "Zero-Evidence Difficulty",
    Default = false,
})

local traitCheckSettings = settings:AddDropdown({
    Title = "Difficulty",
    Values = {"Default", "4.07"},
    Default = "Default"
})

unlimitedStaminaToggle:OnChanged(function()
    config.unlimitedStamina = unlimitedStaminaToggle.Value
end)

brightToggle:OnChanged(function()
    config.bright = brightToggle.Value
end)

itemESPToggle:OnChanged(function()
    config.itemESPEnabled = itemESPToggle.Value
end)

roomESPToggle:OnChanged(function()
    config.roomESPEnabled = roomESPToggle.Value
end)

closetESPToggle:OnChanged(function()
    config.closetESPEnabled = closetESPToggle.Value
end)

shardESPToggle:OnChanged(function()
    config.shardESPEnabled = shardESPToggle.Value
end)

GhostESPToggle:OnChanged(function()
    config.ghostESPEnabled = GhostESPToggle.Value
end)

playerEnergyESPToggle:OnChanged(function()
    config.playerEnergyESPEnabled = playerEnergyESPToggle.Value
end)

GhostTracersToggle:OnChanged(function()
    config.ghostTracersESPEnabled = GhostTracersToggle.Value
end)

zeroEvidenceMode:OnChanged(function()
    config.zeroEvidence = zeroEvidenceMode.Value
    evidencesRecords["Ghost Orb"] = 0
end)

traitCheckSettings:OnChanged(function()
    changeTraitConfigs(traitCheckSettings.Value)
end)

local function loadStartupConfigs()
    local function setupTo407()
        print("Selected the 4.07")
        zeroEvidenceMode:SetValue(true)
        traitCheckSettings:SetValue("4.07")
    end

    if workspace:GetAttribute("Difficulty") == "Custom" then
        Library:Notify({Title = "Difficulty Detected.", Content = "Changed the settings to match the difficulty.", Duration = 6 })
        setupTo407()
    end
end

task.spawn(function()
    -- Run only once
    scanRoomsForESP()
    scanClosetForESP()
    ghostTracersESP()
    scanGhostForESP()
    loadStartupConfigs()
    

    while Library.Unloaded == false do -- Main Loop
     
        updateGhostSpeedRecords()
        
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
        playerEnergyESP()

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
        priorityRunner()
        renderESP()
        task.wait(0.001)
    end
end)
