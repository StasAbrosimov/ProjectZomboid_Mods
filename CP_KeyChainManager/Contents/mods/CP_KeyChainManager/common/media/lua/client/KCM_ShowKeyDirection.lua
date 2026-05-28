-- KSM_ShowKeyDirection.lua

require 'luautils'

local KCMLib = require("KCMLib")
local KCMConfing = require("KCM_Options");

--- UI element that renders a directional line toward the key origin
ShowKeyDirection = ISUIElement:derive("ShowKeyDirection")

-- Initializes base UI element
function ShowKeyDirection:initialize()
    ISUIElement.initialise(self)
end

local pos = {}
local diff = {}
--local r, g, b, alpha = 1, 1, 0, 1 -- Vector color (yellow)
local thickness = 2 -- Vector line thickness
local lineColor = { r = 1, g = 1, b = 0, a = 1 }

-- Renders the direction vector on screen
function ShowKeyDirection:render()
    local md = self.playerObj:getModData()
    if not md then return end

    local sandBoxV = SandboxVars.KeyChainManager or {}
    local compassNeeded = sandBoxV.CompassNeeded

    if not (md.KSMItem and md.ShowKeyVector) then return end
    if compassNeeded and not KCMLib.hasCompass(self.playerObj) then
        if md.ShowKeyVector then
            self.playerObj:Say("I need a compass...")
        end

        md.KSMItem = nil;
        md.ShowKeyVector = false;

        return
    end

    local item = md.KSMItem
    if not item or type(item.hasOrigin) ~= "function" or not item:hasOrigin() then return end
    if type(item.getOriginX) ~= "function" or type(item.getOriginY) ~= "function" or type(item.getOriginZ) ~= "function" then return end

    -- Player and key origin positions
    pos.X = self.playerObj:getX()
    pos.Y = self.playerObj:getY()
    pos.Z = self.playerObj:getZ()

    diff.X = item:getOriginX() - pos.X
    diff.Y = item:getOriginY() - pos.Y
    diff.Z = item:getOriginZ() - pos.Z

    -- Calculate vector direction angle
    diff.mod = math.sqrt(diff.X * diff.X + diff.Y * diff.Y)
    if diff.mod == 0 then return end
    local arg = math.atan2(diff.Y, diff.X) -- Angle in radians

    -- Line boundaries
    local radMin = 0
    local radTop = math.min(40, diff.mod)

    -- World coordinates
    local xStart = pos.X + radMin * math.cos(arg)
    local yStart = pos.Y + radMin * math.sin(arg)
    local xEnd = pos.X + radTop * math.cos(arg)
    local yEnd = pos.Y + radTop * math.sin(arg)

    -- Screen coordinates
    local xScreen1 = isoToScreenX(self.playerNum, xStart, yStart, pos.Z)
    local yScreen1 = isoToScreenY(self.playerNum, xStart, yStart, pos.Z)
    local xScreen2 = isoToScreenX(self.playerNum, xEnd, yEnd, pos.Z)
    local yScreen2 = isoToScreenY(self.playerNum, xEnd, yEnd, pos.Z)

    -- Draw line (use Tchernolib if available for advanced styling)
    lineColor = KCMConfing.LineColor;
    thickness = KCMConfing.LineThickness

    local isOk, dr = pcall(function()
        return self:safeDraw(xScreen1, yScreen1, xScreen2, yScreen2, lineColor, arg, thickness)
    end);

    if not isOk then
        KCMConfing.Errors.IsDrowningErrorOccurred = true;

        if KCMConfing.Errors.IsLuautilsDrowningErrorTest then
            KCMConfing.Errors.IsLuautilsDrowningError = true
            KCMConfing.Errors.IsLuautilsDrowningErrorTest = false
        end

        if KCMConfing.Errors.IsInternalDrowningErrorTest then
            KCMConfing.Errors.IsInternalDrowningError = true
            KCMConfing.Errors.IsInternalDrowningErrorTest = false
        end

        if KCMConfing.Errors.IsVanillaDrowningErrorTest then
            KCMConfing.Errors.IsVanillaDrowningError = true
            KCMConfing.Errors.IsVanillaDrowningErrorTest = false
        end
    end
end

function ShowKeyDirection:safeDraw(xScreen1, yScreen1, xScreen2, yScreen2, color, arg, t)
    if luautils.drawLine2 and not KCMConfing.Errors.IsLuautilsDrowningError then
        if KCMConfing.Errors.IsDrowningErrorOccurred then
            KCMConfing.Errors.IsLuautilsDrowningErrorTest = true;
        end

        luautils.drawLine2(xScreen1, yScreen1, xScreen2, yScreen2, color.a, color.r, color.g, color.b, arg, t)

        if KCMConfing.Errors.IsDrowningErrorOccurred then
            KCMConfing.Errors.IsLuautilsDrowningErrorTest = false;
        end
    elseif not KCMConfing.Errors.IsInternalDrowningError then
        if KCMConfing.Errors.IsDrowningErrorOccurred then
            KCMConfing.Errors.IsInternalDrowningErrorTest = true;
        end

        self:drawLine2Int(xScreen1, yScreen1, xScreen2, yScreen2, color.a, color.r, color.g, color.b, arg, t)

        if KCMConfing.Errors.IsDrowningErrorOccurred then
            KCMConfing.Errors.IsInternalDrowningErrorTest = false;
        end
    elseif not KCMConfing.Errors.IsInternalDrowningError then
        if KCMConfing.Errors.IsDrowningErrorOccurred then
            KCMConfing.Errors.IsVanillaDrowningErrorTest = true;
        end

        self:drawLine2(xScreen1, yScreen1, xScreen2, yScreen2, color.a, color.r, color.g, color.b)

        if KCMConfing.Errors.IsDrowningErrorOccurred then
            KCMConfing.Errors.IsVanillaDrowningErrorTest = false;
        end
    else
        KCMConfing.Errors.IsAllDrowningTypesFailed = true;
    end
end

function ShowKeyDirection:drawLine2Int(x, y, x2, y2, a, r, g, b, angle, thick)
    if thick == nil then thick = 2 end
    if thick < 0 then thick = 0 end
    local thickX = thick
    local thickY = thick
    if angle and thick > 0 then
        thickX = thick * Math.cos(angle)
        thickY = thick * Math.sin(angle)
    end
    getRenderer():render(nil, x - thickX, y - thickY, x + thickX, y + thickY, x2 + thickX, y2 + thickY, x2 - thickX,
        y2 - thickY, r, g, b, a, r, g, b, a, r, g, b, a, r, g, b, a, nil);
end

-- Constructor for creating a ShowKeyDirection element
function ShowKeyDirection:new(playerNum, playerObj)
    local posX = getPlayerScreenLeft(playerNum)
    local posY = getPlayerScreenTop(playerNum)
    local o = ISUIElement:new(posX, posY, 1, 1)
    setmetatable(o, self)
    self.__index = self

    o.playerNum = playerNum
    o.playerObj = playerObj

    return o
end

-- Adds the ShowKeyDirection UI to the player when created
function ShowKeyDirection.onCreatePlayer(playerNum, playerObj)
    if not playerObj or (playerObj.getIsNPC and playerObj:getIsNPC()) then return end

    ShowKeyDirection.cache = ShowKeyDirection.cache or {}

    if ShowKeyDirection.cache[playerNum] then
        ShowKeyDirection.cache[playerNum]:removeFromUIManager()
    end

    local web = ShowKeyDirection:new(playerNum, playerObj)
    web:initialize()
    web:instantiate()
    web:addToUIManager()
    ShowKeyDirection.cache[playerNum] = web
end

-- Removes the UI element when player dies
function ShowKeyDirection.onCharacterDeath(characterObj)
    if characterObj and characterObj.getPlayerNum then
        local playerNum = characterObj:getPlayerNum()
        if ShowKeyDirection.cache and ShowKeyDirection.cache[playerNum] then
            ShowKeyDirection.cache[playerNum]:removeFromUIManager()
            ShowKeyDirection.cache[playerNum] = nil
        end
    end
end

-- Register event hooks
Events.OnCreatePlayer.Add(ShowKeyDirection.onCreatePlayer)
Events.OnCharacterDeath.Add(ShowKeyDirection.onCharacterDeath)
