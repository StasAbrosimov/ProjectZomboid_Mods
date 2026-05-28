local KCMConfing = require("KCM_Options");

KCMDataManager =
{
    playersToWatch = {}
}


KCMDataManager.UpdateDuringTime = function()
    local activePlayers = 0;

    for player, playerMD in pairs(KCMDataManager.playersToWatch) do
        if playerMD ~= nil and playerMD.ShowKeyVector then
            activePlayers = activePlayers + 1
            if playerMD.ticksToFinishDraw > 0.0 then
                playerMD.ticksToFinishDraw = playerMD.ticksToFinishDraw - 1.0
            else
                playerMD.KCMItem = nil
                KCMDataManager.playersToWatch[player] = nil
            end
        elseif playerMD ~= nil then
            activePlayers = activePlayers + 1
        end
    end

    if activePlayers == 0 then
        KCMDataManager.playersToWatch = {}
    end
end

function KCMDataManager:AddNewItemToDraw(item, player, playerMD)
    if KCMDataManager:CanShowDirectionVectorTo(player) then
        playerMD.KCMItem = item;

        if playerMD.ShowKeyVector then
            playerMD.ticksToFinishDraw = KCMConfing.SandboxVars.BaseTimeDirectionVisible;

            Events.EveryOneMinute.Remove(self.UpdateDuringTime)

            if playerMD.ticksToFinishDraw > 0.0 and playerMD.ShowKeyVector then
                Events.EveryOneMinute.Add(self.UpdateDuringTime)
                local additionalTime = (playerMD.ticksToFinishDraw * KCMConfing.SandboxVars.ByForagingLevelTimeDirectionVisibleModificator * foragingLevel) /
                    100.0;
                playerMD.ticksToFinishDraw = playerMD.ticksToFinishDraw + additionalTime;
                playersToWatch[player] = playerMD;
            end
        end
    end
end

function KCMDataManager:CanShowDirectionVectorTo(player)
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging) -- PlantScavenging is foraging
    return KCMConfing.SandboxVars.ForagingLevelForDirection >= foragingLevel;
end

function KCMDataManager:CanShowDistanceTo(player)
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging) -- PlantScavenging is foraging
    return KCMConfing.SandboxVars.ForagingLevelForDistance >= foragingLevel;
end

function KCMDataManager:CanShowCoordinatesTo(player)
    local foragingLevel = player:getPerkLevel(Perks.PlantScavenging) -- PlantScavenging is foraging
    return KCMConfing.SandboxVars.ForagingLevelForCoordinates >= foragingLevel;
end

return KCMDataManager
