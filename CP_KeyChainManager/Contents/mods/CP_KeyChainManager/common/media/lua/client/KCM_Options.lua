require 'luautils'

---@class RgbColor
---@field a number
---@field r number
---@field g number
---@field b number

KCMConfing = KCMConfing or {
    --- Show Direction In Item tooltip
    --- @type boolean
    ShowDirectionForItem = false,

    --- Show key id In Item tooltip
    --- @type boolean
    ShowKeyId = false,

    --- Show key id In Item tooltip
    --- @type boolean
    DrawTheDirectionLineForKeyItem = true,

    --- Direction line color
    --- @type RgbColor
    LineColor = { a = 1.0, r = 1.0, g = 1.0, b = 0.0 },

    --- Direction thicnes
    --- @type number
    LineThickness = 2.0,

    SandboxVars = {
        --- Is compass needed to calculate direction
        --- @type boolean
        CompassNeeded = true,

        --- What skill level needed for provide additional data, default 1
        --- @type integer
        ForagingLevelForDirection = 1,

        --- What skill level needed for provide additional data, default 2
        --- @type integer
        ForagingLevelForDistance = 2,

        --- What skill level needed for provide additional data, default 3
        --- @type integer
        ForagingLevelForCoordinates = 3,

        --- Base amount of minutes that direction will be visible , default 5 minutes
        --- @type number
        BaseTimeDirectionVisible = 5.0,

        --- Percentage modificator that add value to base time. Based on Foraging skill level, defaults 10
        ByForagingLevelTimeDirectionVisibleModificator = 10.0

    },

    --- Is exclude cars from direction calculation
    --- @type boolean
    ExcludeCarsKeys = true,

    Errors = {
        IsDrowningErrorOccurred = false,
        Is_NO_Luautils_mod_Found = false,
        IsInternalDrowningError = false,
        IsLuautilsDrowningError = false,
        IsVanillaDrowningError = false,
        IsAllDrowningTypesFailed = false
    },

    Debug = {
        --- Is exclude cars from direction calculation
        --- @type boolean
        isDebugSendBox = false,

        isPrintOnDrawDebug = false,

        PrintErrorsOnTick = false,
    }
}


function KCMConfing.Debug:PrintMessageOn(...)
    if KCMConfing.Debug:IsDebugEnabled() then
        local args = { ... }
        local message = ""
        for i = 1, #args do
            message = message .. tostring(args[i]);
        end
        print(message)
    end
end

function KCMConfing.Debug:PrintMessageOnDrawCall(...)
    if KCMConfing.Debug.isPrintOnDrawDebug then
        KCMConfing.Debug:PrintMessageOn(...)
    end
end

function KCMConfing.Debug:isAnyError()
    return KCMConfing.Errors.IsAllDrowningTypesFailed or
        KCMConfing.Errors.IsDrowningErrorOccurred or
        KCMConfing.Errors.IsInternalDrowningError or
        KCMConfing.Errors.IsLuautilsDrowningError or
        KCMConfing.Errors.IsVanillaDrowningError or
        KCMConfing.Errors.Is_NO_Luautils_mod_Found;
end

KCMConfing.Errors.ResetErrorFlags = function()
    KCMConfing.Errors.IsAllDrowningTypesFailed = false
    KCMConfing.Errors.IsDrowningErrorOccurred = false
    KCMConfing.Errors.IsInternalDrowningError = false
    KCMConfing.Errors.IsLuautilsDrowningError = false
    KCMConfing.Errors.IsVanillaDrowningError = false
    KCMConfing.Errors.Is_NO_Luautils_mod_Found = false;
    KCMConfing.Errors:UpdateErrorFlags()
end


KCMConfing.Debug.UpdateErrorDuringTime = function()
    if KCMConfing.Debug:isAnyError() then
        KCMConfing.Errors:UpdateErrorFlags()
    end

    if luautils.drawLine2 then
        KCMConfing.Errors.Is_NO_Luautils_mod_Found = false
    else
        KCMConfing.Errors.Is_NO_Luautils_mod_Found = true
    end

    if KCMConfing.Debug.PrintErrorsOnTick then
        KCMConfing.Errors:PrintAllErrors();
    end
end

function KCMConfing.Errors:PrintAllErrors()
    print("KCMConfing.Errors.IsAllDrowningTypesFailed :" .. tostring(KCMConfing.Errors.IsAllDrowningTypesFailed))
    print("KCMConfing.Errors.IsDrowningErrorOccurred :" .. tostring(KCMConfing.Errors.IsDrowningErrorOccurred))
    print("KCMConfing.Errors.IsInternalDrowningError :" .. tostring(KCMConfing.Errors.IsInternalDrowningError))
    print("KCMConfing.Errors.IsLuautilsDrowningError :" .. tostring(KCMConfing.Errors.IsLuautilsDrowningError))
    print("KCMConfing.Errors.IsVanillaDrowningError :" .. tostring(KCMConfing.Errors.IsVanillaDrowningError))
    print("KCMConfing.Errors.Is_NO_Luautils_mod_Found :" .. tostring(KCMConfing.Errors.Is_NO_Luautils_mod_Found))
end

KCMConfing.Errors.ApplyErrorFlags = function()
    KCMConfing.Errors.IsAllDrowningTypesFailed = KCMConfing.modOptions.IsAllDrowningTypesFailed:getValue();
    KCMConfing.Errors.IsDrowningErrorOccurred = KCMConfing.modOptions.IsDrowningErrorOccurred:getValue();
    KCMConfing.Errors.IsInternalDrowningError = KCMConfing.modOptions.IsInternalDrowningError:getValue();
    KCMConfing.Errors.IsLuautilsDrowningError = KCMConfing.modOptions.IsLuautilsDrowningError:getValue();
    KCMConfing.Errors.IsVanillaDrowningError = KCMConfing.modOptions.IsVanillaDrowningError:getValue();
    KCMConfing.Errors.Is_NO_Luautils_mod_Found = KCMConfing.modOptions.Is_NO_Luautils_mod_Found:getValue();
end

function KCMConfing.Debug:IsDebugEnabled()
    return self.isDebugSendBox or isDebugEnabled()
end

function KCMConfing.Errors:UpdateErrorFlags()
    KCMConfing.modOptions.IsAllDrowningTypesFailed:setValue(self.IsAllDrowningTypesFailed)

    KCMConfing.modOptions.IsDrowningErrorOccurred:setValue(self.IsDrowningErrorOccurred)

    KCMConfing.modOptions.IsInternalDrowningError:setValue(self.IsInternalDrowningError)

    KCMConfing.modOptions.IsLuautilsDrowningError:setValue(self.IsLuautilsDrowningError)

    KCMConfing.modOptions.IsVanillaDrowningError:setValue(self.IsVanillaDrowningError)

    KCMConfing.modOptions.Is_NO_Luautils_mod_Found:setValue(self.Is_NO_Luautils_mod_Found);
end

function KCMConfing.Errors:CreateSettingsDebugRegion()
    -- ERRORS region

    KCMConfing.Options:addSeparator()
    KCMConfing.Options:addSeparator()
    KCMConfing.Options:addDescription(
        "Debug region show only if in debug mode or sandbox flag enabled")

    KCMConfing.Options:addDescription(
        "If error is occurred the checkbox will be enabled")


    KCMConfing.modOptions.IsAllDrowningTypesFailed = KCMConfing.Options:addTickBox(
        "CP_KCM_DEBUG_IsAllDrowningTypesFailed", "IsAllDrowningTypesFailed", false,
        "IsAllDrowningTypesFailed");

    KCMConfing.modOptions.IsDrowningErrorOccurred = KCMConfing.Options:addTickBox(
        "CP_KCM_DEBUG_IsDrowningErrorOccurred",
        "IsDrowningErrorOccurred", false, "IsDrowningErrorOccurred");

    KCMConfing.modOptions.IsInternalDrowningError = KCMConfing.Options:addTickBox(
        "CP_KCM_DEBUG_IsInternalDrowningError",
        "IsInternalDrowningError", false, "IsInternalDrowningError");

    KCMConfing.modOptions.IsLuautilsDrowningError = KCMConfing.Options:addTickBox(
        "CP_KCM_DEBUG_IsLuautilsDrowningError",
        "IsLuautilsDrowningError", false, "IsLuautilsDrowningError");

    KCMConfing.modOptions.IsVanillaDrowningError = KCMConfing.Options:addTickBox(
        "CP_KCM_DEBUG_IsVanillaDrowningError",
        "IsVanillaDrowningError", false, "IsVanillaDrowningError");

    KCMConfing.modOptions.Is_NO_Luautils_mod_Found = KCMConfing.Options:addTickBox(
        "CP_KCM_DEBUG_Is_NO_Luautils_mod_Found",
        "Is_NO_Luautils_from_TchernoLib_mod_Found", false, "Is_NO_Luautils_mod_Found");

    KCMConfing.modOptions.ResetErrorsButton = KCMConfing.Options:addButton("CP_KCM_DEBUG_ResetErrors",
        "Reset errors", "Reset displayed errors for code and this page", KCMConfing.Errors.ResetErrorFlags);
    KCMConfing.modOptions.ResetErrorsButton = KCMConfing.Options:addButton("CP_KCM_DEBUG_SetErrorsForCode",
        "Set Errors for code", "Set errors from combo box to code", KCMConfing.Errors.ApplyErrorFlags);


    KCMConfing.modOptions.IsPrintDebugDrawCalls = KCMConfing.Options:addTickBox(
        "CP_KCM_DEBUG_IsPrintDebugDrawCalls",
        "IsPrintDebugDrawCalls", false, "IsPrintDebugDrawCalls for key origin vector");

    KCMConfing.modOptions.PrintErrorsOnTick = KCMConfing.Options:addTickBox("CP_KCM_DEBUG_PrintErrorsOnTick",
        "PrintErrorsOnTick", false, "PrintErrorsOnTick");
end

KCMConfing.initOptions = function()
    if KCMConfing.Options ~= nil then
        return
    end
    local Options = PZAPI.ModOptions:create("IGUI_CP_KCM_Options", getText("IGUI_CP_KCM_Options_Title"))
    KCMConfing.Options = Options;

    KCMConfing.modOptions = {}

    KCMConfing.modOptions.ShowDirectionForItem = Options:addTickBox("CP_KCM_ShowDirectionForItem",
        getText("IGUI_CP_KCM_Options_ShowDirectionForItem"),
        true,
        getText("IGUI_CP_KCM_Options_ShowDirectionForItem_tooltip"));

    KCMConfing.modOptions.ShowKeyId = Options:addTickBox("CP_KCM_ShowKeyID",
        getText("IGUI_CP_KCM_Options_ShowKeyID"),
        true,
        getText("IGUI_CP_KCM_Options_ShowKeyID_tooltip"));

    Options:addSeparator()
    Options:addDescription(
        "IGUI_CP_KCM_Options_DrawingOptionsTitle")


    KCMConfing.modOptions.DrawTheDirectionLineForTheItem = Options:addTickBox("CP_KCM_DrawTheDirectionLineForTheItem",
        getText("IGUI_CP_KCM_Options_DrawDirectionLineForItem"),
        true,
        getText("IGUI_CP_KCM_Options_DrawDirectionLineForItem_tooltip"));


    KCMConfing.modOptions.LineColorPiker = Options:addColorPicker("CP_KCM_Drawing_LineColor",
        getText("IGUI_CP_KCM_Options_Drawing_LineColor"), 0.4, 1.0, 0, 1.0,
        getText("IGUI_CP_KCM_Options_Drawing_LineColor_tooltip"))

    KCMConfing.modOptions.LineThicknessSlider = Options:addSlider("CP_KCM_Drawing_Line_Thickness",
        getText("IGUI_CP_KCM_Options_Drawing_Line_Thickness"),
        1.0, 20.0, 1.0, 4.0,
        getText("IGUI_CP_KCM_Options_Drawing_Line_Thickness_tooltip"));

    KCMConfing.modOptions.LineThicknessSliderTooltip = Options:addDescription(getText(
        "IGUI_CP_KCM_Options_Drawing_Line_Thickness_tooltip"));

    -- sandbox options init
    local sandBoxV = SandboxVars.CP_KeyChainManager or {}

    KCMConfing.SandboxVars.CompassNeeded = sandBoxV.CompassNeeded or true; -- default true
    KCMConfing.SandboxVars.ForagingLevelForDirection = sandBoxV.ForagingLevelForDirection or
        1                                                                  -- default 1
    KCMConfing.SandboxVars.ForagingLevelForDistance = sandBoxV.ForagingLevelForDistance or
        2                                                                  -- default 2
    KCMConfing.SandboxVars.ForagingLevelForCoordinates = sandBoxV.ForagingLevelForCoordinates or
        3                                                                  -- default 3

    KCMConfing.SandboxVars.BaseTimeDirectionVisible = sandBoxV.BaseTimeDirectionVisible or
        5.0 -- default 5.0
    KCMConfing.SandboxVars.ByForagingLevelTimeDirectionVisibleModificator = sandBoxV
        .ByForagingLevelTimeDirectionVisibleModificator or
        10.0 -- default 10.0

    KCMConfing.Debug.isDebugSendBox = isDebugEnabled() or sandBoxV.IsDebugSendBox;

    if KCMConfing.Debug.isDebugSendBox then
        if not luautils.drawLine2 then
            KCMConfing.Errors.Is_NO_Luautils_mod_Found = true
            KCMConfing.modOptions.LineThicknessSliderTooltip = Options:addDescription(getText(
                "If game do not react on line appearance options then try install TchernoLib mod. \n Place it higher in the mod order."));
        else
            KCMConfing.Errors.Is_NO_Luautils_mod_Found = false
        end

        KCMConfing.Errors:CreateSettingsDebugRegion()
    end

    Options.apply = function()
        KCMConfing.ShowDirectionForItem = KCMConfing.modOptions.ShowDirectionForItem:getValue();
        KCMConfing.ShowKeyId = KCMConfing.modOptions.ShowKeyId:getValue();

        KCMConfing.DrawTheDirectionLineForKeyItem = KCMConfing.modOptions.DrawTheDirectionLineForTheItem:getValue();
        KCMConfing.LineColor = KCMConfing.modOptions.LineColorPiker:getValue();
        KCMConfing.LineThickness = KCMConfing.modOptions.LineThicknessSlider:getValue();

        if not KCMConfing.ShowDirectionForItem or not KCMConfing.DrawTheDirectionLineForKeyItem then
            local playerObj = getPlayer()
            if playerObj then
                local md = playerObj:getModData()
                if md then
                    md.ShowKeyVector = false;
                end
            end
        end


        if KCMConfing.Debug.isDebugSendBox then
            local sandBoxV = SandboxVars.CP_KeyChainManager or {}
            print("KCM in debug mode, ignore sendbox settings")
            print("KCM sendbox debug settings: " .. tostring(sandBoxV.IsDebugSendBox or false));
            print("LineColor: r:" .. tostring(KCMConfing.LineColor.r) ..
                " g:" .. tostring(KCMConfing.LineColor.g) ..
                " b:" .. tostring(KCMConfing.LineColor.b) ..
                " a:" .. tostring(KCMConfing.LineColor.a));
            KCMConfing.Debug.isPrintOnDrawDebug = KCMConfing.modOptions.IsPrintDebugDrawCalls:getValue();
            KCMConfing.Debug.PrintErrorsOnTick = KCMConfing.modOptions.PrintErrorsOnTick:getValue();
        end
    end

    Events.OnGameStart.Remove(Options.apply)
    Events.OnGameStart.Add(Options.apply)
    if KCMConfing.Debug:IsDebugEnabled() then
        Events.EveryOneMinute.Remove(KCMConfing.Debug.UpdateErrorDuringTime)
        Events.EveryOneMinute.Add(KCMConfing.Debug.UpdateErrorDuringTime)
    end
end


KCMConfing.initOptions()


return KCMConfing
