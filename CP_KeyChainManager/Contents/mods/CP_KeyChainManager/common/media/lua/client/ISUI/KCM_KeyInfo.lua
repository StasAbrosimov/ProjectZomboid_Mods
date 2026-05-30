require "ISUI/ISToolTipInv"

local KCMLib = require("KCMLib")
local KCMConfing = require("KCM_Options");
local KCMDataManager = require("KCM_ModDataManager");

keyInfo = keyInfo or {}

-- Helper: Rounds a number to the specified number of decimal places
function keyInfo:_round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

diff = {} -- Table to hold vector differences (distance and direction)
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
    local compassNeeded = KCMConfing.SandboxVars.CompassNeeded
    local showDirectionInfo = KCMConfing.ShowDirectionForItem
    local showKeyId = KCMConfing.ShowKeyId

    if showDirectionInfo or showKeyId then
        self.Text = {}
        self.TextVal = {}
        -- Store the item for use in the vector drawing
    end

    KCMDataManager:AddNewItemToDraw(item, playerObj, md);

    -- If a compass is needed and the player doesn't have one, do nothing
    local isHaveTextToShow = false;

    if showDirectionInfo then
        local canShowInfo = KCMDataManager:CanShowKeyInformationFor(playerObj);

        local isHasCompas = KCMLib.hasCompass(playerObj)

        local canShowPlaceInfo = canShowInfo.DirectionVector or canShowInfo.Distance or canShowInfo.Coordinates

        -- print("Key Info:")

        -- print("compassNeeded: " .. tostring(compassNeeded))
        -- print("isHasCompas: " .. tostring(isHasCompas))
        -- print("canShowPlaceInfo:" .. tostring(canShowPlaceInfo))

        if compassNeeded and not isHasCompas then
            -- print("Compass needed and no compass")
            if canShowPlaceInfo then
                -- print("No compass message")
                if self.lastItem ~= item then
                    self.lastItem = item
                    self.CompassMessageTextKey = KCMDataManager:GetCompassMessageLocalizationKey(true);
                end

                self.Text = { (" " .. getText(self.CompassMessageTextKey)) }
                self.TextVal = { " " }
                isHaveTextToShow = true;
            end
        elseif canShowPlaceInfo then
            -- print("Can show some info")

            -- Calculate the difference in coordinates between the player and the key's origin
            diff.X = item:getOriginX() - playerObj:getX()
            diff.Y = item:getOriginY() - playerObj:getY()
            diff.Z = item:getOriginZ() - playerObj:getZ()
            diff.mod = math.sqrt(diff.X * diff.X + diff.Y * diff.Y)

            --Safety guard: avoid division by zero if origin equals player position
            if diff.mod == 0 then
                diff.mod = 0.0001
            end

            -- Use atan2 so axis-aligned keys don't produce invalid divisions.
            diff.argRad = math.atan2(diff.X, -diff.Y)
            diff.arg = diff.argRad * 57.2958 -- Convert radians to degrees

            -- Determine the cardinal direction of the key's origin
            if diff.arg < -157.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_South") or "S" --"S"
            elseif diff.arg < -112.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_SouthWest") or "SW"
            elseif diff.arg < -67.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_West") or "W"
            elseif diff.arg < -22.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_NorthWest") or "NW"
            elseif diff.arg < 22.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_North") or "N"
            elseif diff.arg < 67.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_NorthEast") or "NE"
            elseif diff.arg < 112.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_East") or "E"
            elseif diff.arg < 157.5 then
                diff.dir = getTextOrNull("IGUI_KCM_Direction_SouthEast") or "SE"
            else
                diff.dir = getTextOrNull("IGUI_KCM_Direction_South") or "S"
            end

            -- Prepare the text to display in the tooltip

            if canShowInfo.Coordinates then
                table.insert(self.Text,
                    " " .. getText("IGUI_KCM_XYZ") .. ":")
                table.insert(self.TextVal,
                    string.format("%d, %d, %d", self:_round(diff.X, 0), self:_round(diff.Y, 0), self:_round(diff.Z, 0)) ..
                    " ")
            end

            if canShowInfo.Distance then
                table.insert(self.Text,
                    " " .. getText("IGUI_KCM_Distance") .. ":")
                table.insert(self.TextVal,
                    tostring(self:_round(diff.mod, 0)) .. " ")
            end

            if canShowInfo.DirectionVector then
                table.insert(self.Text,
                    " " .. getText("IGUI_KCM_Direction") .. ":")
                table.insert(self.TextVal,
                    string.format("%d (%s)", self:_round(diff.arg, 0), diff.dir) .. " ")
            end

            -- self.Text = {
            --     getText("IGUI_KCM_XYZ") .. ":",
            --     getText("IGUI_KCM_Distance") .. ":",
            --     getText("IGUI_KCM_Direction") .. ":",
            -- }

            -- -- Prepare the values that will accompany each label in the tooltip
            -- self.TextVal = {
            --     string.format("%d, %d, %d", self:_round(diff.X, 0), self:_round(diff.Y, 0), self:_round(diff.Z, 0)),
            --     tostring(self:_round(diff.mod, 0)),
            --     string.format("%d (%s)", self:_round(diff.arg, 0), diff.dir)
            -- }
            isHaveTextToShow = true;
        end
    end

    if showKeyId then
        local keyId = tostring(item:getKeyId())
        if self.Text ~= nil and #self.Text > 0 then
            table.insert(self.Text, " " .. getText("IGUI_KCM_Key_Fingerprint") .. ":")
        else
            self.Text = { " " .. getText("IGUI_KCM_Key_Fingerprint") .. ":", }
        end

        if self.TextVal ~= nil and #self.TextVal > 0 then
            table.insert(self.TextVal, keyId .. " ")
        else
            self.TextVal = { keyId .. " ", }
        end

        isHaveTextToShow = true;
    end

    return isHaveTextToShow
end

-- Store the previous version of the render function (vanilla or from another mod)
if KCM_prev_render == nil then
    KCM_prev_render = ISToolTipInv.render
end

function ISToolTipInv:render(...)
    -- If the item has no origin info, just call the previous render function
    if not self.item or not keyInfo:initStats(self.item) then
        return KCM_prev_render(self, ...)
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
    KCM_prev_render(self, ...)

    -- Restore original methods to avoid affecting other tooltips
    self.setHeight = orig_setHeight
    self.setWidth = orig_setWidth
    self.drawRectBorder = orig_drawRectBorder
end
