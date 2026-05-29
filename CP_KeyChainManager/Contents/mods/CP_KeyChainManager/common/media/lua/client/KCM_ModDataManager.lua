local KCMConfing = require("KCM_Options");

KCMDataManager = KCMDataManager or
    {
        playersToWatch = {}
    }


KCMDataManager.UpdateDuringTime = function()
    local activePlayers = 0;

    for player, playerMD in pairs(KCMDataManager.playersToWatch) do
        if playerMD ~= nil and playerMD.ShowKeyVector then
            activePlayers = activePlayers + 1
            print("OnStart ");
            print("playerMD.ticksToFinishDraw: " .. tostring(playerMD.ticksToFinishDraw))
            playerMD.ticksToFinishDraw = playerMD.ticksToFinishDraw - 1.0

            if playerMD.ticksToFinishDraw < 0.0 then
                print("Stop Showing ");
                playerMD.KCMItem = nil
                KCMDataManager.playersToWatch[player] = nil
            end
            print("OnFinish ");
            print("playerMD.ticksToFinishDraw: " .. tostring(playerMD.ticksToFinishDraw))
        end
    end

    if activePlayers == 0 then
        -- print("Unsubscribe from event ");
        KCMDataManager.playersToWatch = {}
        Events.EveryOneMinute.Remove(KCMDataManager.UpdateDuringTime)
    end
end

function KCMDataManager:AddNewItemToDraw(item, player, playerMD)
    if KCMDataManager:CanShowDirectionVectorFor(player) then
        playerMD.KCMItem = item;

        if playerMD.ShowKeyVector then
            playerMD.ticksToFinishDraw = KCMConfing.SandboxVars.BaseTimeDirectionVisible;

            Events.EveryOneMinute.Remove(self.UpdateDuringTime)

            if playerMD.ticksToFinishDraw > 0.0 and playerMD.ShowKeyVector then
                Events.EveryOneMinute.Add(self.UpdateDuringTime)
                local foragingLevel = player:getPerkLevel(Perks.PlantScavenging)
                local additionalTime = (playerMD.ticksToFinishDraw * KCMConfing.SandboxVars.ByForagingLevelTimeDirectionVisibleModificator * foragingLevel) /
                    100.0;
                playerMD.ticksToFinishDraw = playerMD.ticksToFinishDraw + additionalTime;
                self.playersToWatch[player] = playerMD;
            end
        end
    end
end

---@class WhatCanSow
---@field DirectionVector boolean
---@field Distance boolean
---@field Coordinates boolean
local whatCanSow = {}

---@return WhatCanSow
function KCMDataManager:CanShowKeyInformationFor(player)
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging)
    return {
        DirectionVector = KCMConfing.SandboxVars.ForagingLevelForDirection <= foragingLevel,
        Distance = KCMConfing.SandboxVars.ForagingLevelForDistance <= foragingLevel,
        Coordinates = KCMConfing.SandboxVars.ForagingLevelForCoordinates <= foragingLevel,
    };
end

function KCMDataManager:CanShowDirectionVectorFor(player)
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging) -- PlantScavenging is foraging
    return KCMConfing.SandboxVars.ForagingLevelForDirection <= foragingLevel;
end

function KCMDataManager:GetCompassMessageLocalizationKey(isForTooltip)
    local localizationIndexMax = 4
    if not isForTooltip then
        localizationIndexMax = 8
    end

    local index = ZombRand(localizationIndexMax);

    return "IGUI_KCM_Need_A_Compass_" .. tostring(index)
end

KCMDataManager.PrintVariablesToConsoleContextMenu = function(item, player)
    local playerObj = getSpecificPlayer(player)
    KCMDataManager:PrintVariablesToConsole(playerObj);
end

function KCMDataManager:PrintVariablesToConsole(playerObj)
    print(tostring(playerObj))
    local localPlayer = playerObj
    if localPlayer == nil then
        localPlayer = getPlayer()
    end

    local canShow = KCMDataManager:CanShowKeyInformationFor(localPlayer)
    local foragingLevel = localPlayer:getPerkLevel(Perks.PlantScavenging)

    print("KCMDataManager.WhatCanSow: ")
    print("foraging: " .. tostring(foragingLevel))
    print("ForagingLevelForCoordinates: " .. tostring(KCMConfing.SandboxVars.ForagingLevelForCoordinates))
    print("canShow.Coordinates: " .. tostring(canShow.Coordinates))
    print("ForagingLevelForDirection: " .. tostring(KCMConfing.SandboxVars.ForagingLevelForDirection))
    print("canShow.DirectionVector: " .. tostring(canShow.DirectionVector))
    print("ForagingLevelForDistance: " .. tostring(KCMConfing.SandboxVars.ForagingLevelForDistance))
    print("canShow.Distance: " .. tostring(canShow.Distance))

    print("KCM SendboxOptions: ")
    print("CompassNeeded: " .. tostring(KCMConfing.SandboxVars.CompassNeeded))
    print("BaseTimeDirectionVisible: " .. tostring(KCMConfing.SandboxVars.BaseTimeDirectionVisible))
    print("ByForagingLevelTimeDirectionVisibleModificator: " ..
        tostring(KCMConfing.SandboxVars.ByForagingLevelTimeDirectionVisibleModificator))

    local additionalTime = (KCMConfing.SandboxVars.BaseTimeDirectionVisible * KCMConfing.SandboxVars.ByForagingLevelTimeDirectionVisibleModificator * foragingLevel) /
        100.0;
    print("fullCurrentTime: " .. tostring(KCMConfing.SandboxVars.BaseTimeDirectionVisible + additionalTime))
end

return KCMDataManager
