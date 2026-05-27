require "ISUI/ISToolTipInv"

keyInfo = keyInfo or {}

-- Helper: Rounds a number to the specified number of decimal places
function keyInfo:_round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Helper: Checks if the player has a compass in their inventory.
-- Uses ItemTag.COMPASS on newer B42 builds and falls back to the item type
-- so the sandbox option stays compatible across older variants.
local function hasCompass(playerObj)
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

diff = {}  -- Table to hold vector differences (distance and direction)

-- Main function: Prepares data to display key origin info in the tooltip
function keyInfo:initStats(item)
    -- Safety guard: item must exist and expose a callable hasOrigin() method
    if not item then
        return false
    end

    -- Safety guard: avoid "Object tried to call nil" if some other mod passes
    -- an object without hasOrigin (or overrides it with a non-function).
    if type(item.hasOrigin) ~= "function" then
        return false
    end

    -- If the item doesn't have an origin, do nothing
    if not item:hasOrigin() then
        return false
    end

    -- Safety guard: make sure origin accessors exist before calling them
    if type(item.getOriginX) ~= "function"
        or type(item.getOriginY) ~= "function"
        or type(item.getOriginZ) ~= "function" then
        return false
    end

    local playerObj = getPlayer()
    if not playerObj then
        return false
    end

    local md = playerObj:getModData()
    if not md then
        return false
    end

    -- Ensure the mod's configuration exists
    SandboxVars.ShowKeyOrigin = SandboxVars.ShowKeyOrigin or {}
    local compassNeeded = SandboxVars.ShowKeyOrigin.CompassNeeded

    -- If a compass is needed and the player doesn't have one, do nothing
    if compassNeeded and not hasCompass(playerObj) then
        return false
    end

    -- Calculate the difference in coordinates between the player and the key's origin
    diff.X = item:getOriginX() - playerObj:getX()
    diff.Y = item:getOriginY() - playerObj:getY()
    diff.Z = item:getOriginZ() - playerObj:getZ()
    diff.mod = math.sqrt(diff.X * diff.X + diff.Y * diff.Y)

    -- Safety guard: avoid division by zero if origin equals player position
    if diff.mod == 0 then
        return false
    end

    -- Use atan2 so axis-aligned keys don't produce invalid divisions.
    diff.argRad = math.atan2(diff.X, -diff.Y)
    diff.arg = diff.argRad * 57.2958  -- Convert radians to degrees

    -- Determine the cardinal direction of the key's origin
    if diff.arg < -157.5 then diff.dir = "S"
    elseif diff.arg < -112.5 then diff.dir = "SW"
    elseif diff.arg < -67.5 then diff.dir = "W"
    elseif diff.arg < -22.5 then diff.dir = "NW"
    elseif diff.arg < 22.5 then diff.dir = "N"
    elseif diff.arg < 67.5 then diff.dir = "NE"
    elseif diff.arg < 112.5 then diff.dir = "E"
    elseif diff.arg < 157.5 then diff.dir = "SE"
    else diff.dir = "S" end

    -- Store the item for use in the vector drawing
    md.SKOItem = item

    -- Prepare the text to display in the tooltip
    self.Text = {
        getText("IGUI_SKO_XYZ") .. ":",
        getText("IGUI_SKO_Distance") .. ":",
        getText("IGUI_SKO_Direction") .. ":"
    }

    -- Prepare the values that will accompany each label in the tooltip
    self.TextVal = {
        string.format("%d, %d, %d", self:_round(diff.X, 0), self:_round(diff.Y, 0), self:_round(diff.Z, 0)),
        tostring(self:_round(diff.mod, 0)),
        string.format("%d (%s)", self:_round(diff.arg, 0), diff.dir)
    }

    return true
end

-- Store the previous version of the render function (vanilla or from another mod)
if SKO_prev_render == nil then
    SKO_prev_render = ISToolTipInv.render
end

function ISToolTipInv:render(...)
    -- If the item has no origin info, just call the previous render function
    if not self.item or not keyInfo:initStats(self.item) then
        return SKO_prev_render(self, ...)
    end

    -- Setup tooltip display parameters
    local font = UIFont[getCore():getOptionTooltipFont()]
    local colors = { r = 0.68, g = 0.64, b = 0.96, a = 1 }
    local lineSpacing = self.tooltip:getLineSpacing()
    local width = self.tooltip:getWidth()
    local height = self.tooltip:getHeight()
    local newHeight = height + #keyInfo.Text * lineSpacing
    local newWidth = width

    -- Calculate new tooltip width based on content
    for i = 1, #keyInfo.Text do
        newWidth = math.max(
            getTextManager():MeasureStringX(font, keyInfo.Text[i]) +
            getTextManager():MeasureStringX(font, keyInfo.TextVal[i]) + 7,
            newWidth
        )
    end

    -- Backup original instance methods
    local orig_setHeight = self.setHeight
    local orig_setWidth = self.setWidth
    local orig_drawRectBorder = self.drawRectBorder

    -- Temporarily override setHeight
    self.setHeight = function(self_, h, ...)
        h = newHeight
        self_.keepOnScreen = false
        return orig_setHeight(self_, h, ...)
    end

    -- Temporarily override setWidth
    self.setWidth = function(self_, w, ...)
        w = newWidth
        self_.keepOnScreen = false
        return orig_setWidth(self_, w, ...)
    end

    -- Temporarily override drawRectBorder to include custom info
    self.drawRectBorder = function(self_, ...)
        for i = 1, #keyInfo.Text do
            self_.tooltip:DrawText(font, keyInfo.Text[i], 7, height - 3, colors.r, colors.g, colors.b, colors.a)
            self_.tooltip:DrawText(
                font,
                keyInfo.TextVal[i],
                newWidth - getTextManager():MeasureStringX(font, keyInfo.TextVal[i]) - 7,
                height - 3,
                colors.r, colors.g, colors.b, colors.a
            )
            height = height + lineSpacing
        end
        orig_drawRectBorder(self_, ...)
    end

    -- Call the previous render function to preserve base or other mod content
    SKO_prev_render(self, ...)

    -- Restore original methods to avoid affecting other tooltips
    self.setHeight = orig_setHeight
    self.setWidth = orig_setWidth
    self.drawRectBorder = orig_drawRectBorder
end
