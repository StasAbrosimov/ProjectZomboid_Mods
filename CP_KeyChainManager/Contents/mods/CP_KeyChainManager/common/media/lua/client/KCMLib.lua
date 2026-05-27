local KCMLib = {}

-- Helper: Checks if the player has a compass in their inventory.
-- Uses ItemTag.COMPASS on newer B42 builds and falls back to the item type
-- so the sandbox option stays compatible across older variants.
function KCMLib.hasCompass(playerObj)
    local inv = playerObj and playerObj:getInventory()
    if not inv then
        return false
    end

    if ItemTag and ItemTag.COMPASS then
        local ok, hasTag = pcall(function()
            return inv:containsTagRecurse(ItemTag.COMPASS)
        end)
        if ok then
            return hasTag
        end
    end

    if inv.containsTypeRecurse then
        local ok, hasType = pcall(function()
            return inv:containsTypeRecurse("Base.CompassDirectional")
        end)
        if ok then
            return hasType
        end
    end

    return false
end

return KCMLib
