-- SKO_ContextMenu.lua

-- Table to hold all SKO context menu functions
SKO_ContextMenu = SKO_ContextMenu or {}

-- Toggles the visibility of the direction vector for the selected key
function SKO_ContextMenu.changeShowKeyVector(item, player)
    local playerObj = getSpecificPlayer(player)
    if not playerObj then return end
    local md = playerObj:getModData()
    if not md then return end

    md.ShowKeyVector = not md.ShowKeyVector
end

-- Returns whether the vector display is currently enabled for the player
function SKO_ContextMenu.isShowKeyVector(playerObj)
    if not playerObj then return false end
    local md = playerObj:getModData()
    return md and md.ShowKeyVector == true
end

-- Adds the context menu option to show/hide the direction vector
local function SKO_ContextMenu_toggleShowKeyVector(player, context, items)
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
        local show = SKO_ContextMenu.isShowKeyVector(playerObj)
        local optionText = show and getText("ContextMenu_SKO_Hide") or getText("ContextMenu_SKO_Show")
        local option = context:addOption(optionText, validKeys[1], SKO_ContextMenu.changeShowKeyVector, player)

        local tooltip = ISInventoryPaneContextMenu.addToolTip()
        tooltip.description = getText("Tooltip_SKO_Toggle")
        option.toolTip = tooltip

        context:setOptionChecked(option, show)
    end
end

-- Register the context menu event
Events.OnFillInventoryObjectContextMenu.Add(SKO_ContextMenu_toggleShowKeyVector)