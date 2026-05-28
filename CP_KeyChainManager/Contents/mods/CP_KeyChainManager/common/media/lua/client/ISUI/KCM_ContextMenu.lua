require "TimedActions/ISInventoryTransferUtil"
-- KCM_ContextMenu.lua

local KCMDataManager = require("KCM_ModDataManager");

-- Table to hold all KCM context menu functions
KCM_ContextMenu = KCM_ContextMenu or {}

-- Toggles the visibility of the direction vector for the selected key
function KCM_ContextMenu.changeShowKeyVector(item, player)
    local playerObj = getSpecificPlayer(player)
    if not playerObj then return end
    local md = playerObj:getModData()
    if not md then return end

    md.ShowKeyVector = not md.ShowKeyVector
end

function KCM_ContextMenu.putDuplicatesIntoContainer(item, player)
    local playerObj = getSpecificPlayer(player);
    local playerInventory = playerObj:getInventory();
    print(item:getType());

    local allTypeRec = playerInventory:getAllTypeRecurse(item:getType());
    if allTypeRec ~= nil and allTypeRec:size() > 1 then
        local keysArray = allTypeRec:toArray();
        print(item);
        local itemKeyId = item:getKeyId();
        for index, itemToTransfer in ipairs(keysArray) do
            print(index .. " - " .. tostring(itemToTransfer))
            print("Is same object:" .. tostring(itemToTransfer == item))
            if itemToTransfer ~= item and itemToTransfer:getKeyId() == itemKeyId then
                print("transfer " .. tostring(itemToTransfer))
                ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, itemToTransfer,
                    itemToTransfer:getContainer(), playerInventory))
            end
        end
    end
end

-- Returns whether the vector display is currently enabled for the player
function KCM_ContextMenu.isShowKeyVector(playerObj)
    if not playerObj then return false end
    local md = playerObj:getModData()
    return md and md.ShowKeyVector == true
end

-- Adds the context menu option to show/hide the direction vector
local function KCM_ContextMenu_toggleShowKeyVector(player, context, items)
    local playerObj = getSpecificPlayer(player)
    if not playerObj then return end

    local keyItems = ISInventoryPane.getActualItems(items)
    local validKeys = {}

    -- Collect keys that have origin data
    for _, item in ipairs(keyItems) do
        if item:hasOrigin() then
            table.insert(validKeys, item)
        end
    end

    -- Only proceed if there's exactly one key with origin
    if #validKeys == 1 then
        if KCMDataManager:CanShowDirectionVectorTo(playerObj) then
            local show = KCM_ContextMenu.isShowKeyVector(playerObj)
            local optionText = show and getText("ContextMenu_KCM_Origin_Hide") or getText("ContextMenu_KCM_Origin_Show")
            local showOriginOption = context:addOption(optionText, validKeys[1], KCM_ContextMenu.changeShowKeyVector,
                player)

            local tooltip = ISInventoryPaneContextMenu.addToolTip()
            tooltip.description = getText("Tooltip_KCM_CM_Origin_Toggle");
            showOriginOption.toolTip = tooltip

            context:setOptionChecked(showOriginOption, show)
        end
        local unpackOption = context:addOption("Unpack all duplicates into user inventory", validKeys[1],
            KCM_ContextMenu.putDuplicatesIntoContainer, player);

        local unpackTooltip = ISInventoryPaneContextMenu.addToolTip();
        unpackTooltip.description = getText("Tooltip_KCM_CM_Unpack_Duplicates");
        unpackOption.toolTip = unpackTooltip
    end
end

-- Register the context menu event
Events.OnFillInventoryObjectContextMenu.Add(KCM_ContextMenu_toggleShowKeyVector)
