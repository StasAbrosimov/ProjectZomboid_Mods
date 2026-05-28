require 'luautils'

local KCMConfing = {
    --- Show Direction In Item tooltip
    --- @type boolean
    ShowDirectionInItem = false,

    --- Show key id In Item tooltip
    --- @type boolean
    ShowKeyId = false,

    --- Direction line color
    --- @type color
    LineColor = { a = 1.0, r = 1.0, g = 1.0, b = 0.0 },

    --- Direction thicnes
    --- @type number
    LineThickness = 2.0,

    --- Is compass needed to calculate direction
    --- @type boolean
    CompassNeeded = true,

    --- Is exclude cars from direction calculation
    --- @type boolean
    ExcludeCarsKeys = true,

    Errors = {
        IsDrowningErrorOccurred = false,
        IsInternalDrowningError = false,
        IsLuautilsDrowningError = false,
        IsVanillaDrowningError = false,
        IsAllDrowningTypesFailed = false
    },

    Debug = {
        --- Is exclude cars from direction calculation
        --- @type boolean
        isDebugSendBox = false
    }
}

function KCMConfing.Errors:isAnyError()
    return KCMConfing.Errors.IsAllDrowningTypesFailed or
        KCMConfing.Errors.IsDrowningErrorOccurred or
        KCMConfing.Errors.IsInternalDrowningError or
        KCMConfing.Errors.IsLuautilsDrowningError or
        KCMConfing.Errors.IsVanillaDrowningError;
end

KCMConfing.Errors.ResetErrorFlags = function()
    KCMConfing.Errors.IsAllDrowningTypesFailed = false
    KCMConfing.Errors.IsDrowningErrorOccurred = false
    KCMConfing.Errors.IsInternalDrowningError = false
    KCMConfing.Errors.IsLuautilsDrowningError = false
    KCMConfing.Errors.IsVanillaDrowningError = false
    KCMConfing.Errors:UpdateErrorFlags(true)
end

KCMConfing.Errors.ApplyErrorFlags = function()
    KCMConfing.Errors.IsAllDrowningTypesFailed = KCMConfing.modOptions.IsAllDrowningTypesFailed:getValue();
    KCMConfing.Errors.IsDrowningErrorOccurred = KCMConfing.modOptions.IsDrowningErrorOccurred:getValue();
    KCMConfing.Errors.IsInternalDrowningError = KCMConfing.modOptions.IsInternalDrowningError:getValue();
    KCMConfing.Errors.IsLuautilsDrowningError = KCMConfing.modOptions.IsLuautilsDrowningError:getValue();
    KCMConfing.Errors.IsVanillaDrowningError = KCMConfing.modOptions.IsVanillaDrowningError:getValue();
    KCMConfing.Errors:UpdateErrorFlags(true)
end

function KCMConfing.Debug:IsDebugEnabled()
    return self.isDebugSendBox or isDebugEnabled()
end

KCMConfing.Errors.ShowErrorFlags = function()
    KCMConfing.Errors:UpdateErrorFlags(true)
end

function KCMConfing.Errors:UpdateErrorFlags(resetLua)
    local function isIdInOptions(Id)
        for index, value in ipairs(KCMConfing.Options.data) do
            if value.id == Id then
                return true;
            end
        end

        return false;
    end

    local function deleteOptionById(Id)
        for index, value in ipairs(KCMConfing.Options.data) do
            if value.id == Id then
                table.remove(KCMConfing.Options.data, index)
                KCMConfing.Options.dict[Id] = nil;
                return true;
            end
        end

        return false;
    end

    deleteOptionById("CP_KCM_ResetErrors_Button")

    local firstSeparatorIndex = -1
    local separatorCount = 0
    for index, value in ipairs(KCMConfing.Options.data) do
        if value.type == "separator" then
            if firstSeparatorIndex < 0 then
                firstSeparatorIndex = index
            end
            separatorCount = separatorCount + 1
        else
            firstSeparatorIndex = -1
            separatorCount = 0
        end

        if separatorCount >= 2 then
            break
        end
    end

    if firstSeparatorIndex > 0 then
        local newDat = {}
        local newDic = {}

        for index, value in ipairs(KCMConfing.Options.data) do
            if firstSeparatorIndex > index then
                table.insert(newDat, value);
                if value.id ~= nil then
                    newDic[value.id] = value;
                end
            else
                break
            end
        end
    end


    -- ERRORS region
    if KCMConfing.Errors:isAnyError() then
        KCMConfing.Options:addSeparator()
        KCMConfing.Options:addSeparator()
        KCMConfing.Options:addDescription(
            "If you're reading this, there's been an error. Below are the descriptions.")

        if KCMConfing.Errors.IsDrowningErrorOccurred then
            KCMConfing.Options:addDescription(" ");
            KCMConfing.Options:addDescription("One or more line drawing methods do not work.")
        end

        if KCMConfing.Errors.IsInternalDrowningError then
            KCMConfing.Options:addDescription(" ");
            KCMConfing.Options:addDescription("Internal rendering method does not work, try using TchernoLib mode.")
        end

        if KCMConfing.Errors.IsLuautilsDrowningError then
            KCMConfing.Options:addDescription(" ");
            KCMConfing.Options:addDescription(
                "TchernoLib rendering method does not work, trying to use Vanila line render");
        end

        if KCMConfing.Errors.IsVanillaDrowningError then
            KCMConfing.Options:addDescription(" ");
            KCMConfing.Options:addDescription(
                "Vanila rendering method does not work. Oops... sorry... Waiting for mode updates");
        end


        KCMConfing.Options:addDescription(" ");
        KCMConfing.modOptions.resetErrors = KCMConfing.Options:addButton("CP_KCM_ResetErrors_Button", "Reset Errors",
            "Reset all errors flags", KCMConfing.Errors.ResetErrorFlags)
    else
        KCMConfing.Options:addSeparator()
        KCMConfing.Options:addSeparator()
        KCMConfing.Options:addDescription(
            "There are NO errors")
    end

    if resetLua then
        MainOptions.instance.resetLua = true;
    end
end

KCMConfing.initOptions = function()
    local Options = PZAPI.ModOptions:create("CP_KCM_Options", getText("IGUI_CP_KCM_Options_Title"))
    KCMConfing.Options = Options;

    KCMConfing.modOptions = {}

    KCMConfing.modOptions.ShowDirectionInItem = Options:addTickBox("CP_KCM_ShowDirectionInItem",
        getText("IGUI_CP_KCM_Options_ShowDirectionInItem"),
        true,
        getText("IGUI_CP_KCM_Options_ShowDirectionInItem_tooltip"));

    KCMConfing.modOptions.ShowKeyId = Options:addTickBox("CP_KCM_ShowKeyID",
        getText("IGUI_CP_KCM_Options_ShowKeyID"),
        true,
        getText("IGUI_CP_KCM_Options_ShowKeyID_tooltip"));

    Options:addSeparator()
    Options:addDescription(
        "IGUI_CP_KCM_Options_DrawingOptionsTitle")


    KCMConfing.modOptions.LineColorPiker = Options:addColorPicker("CP_KCM_Drawing_LineColor",
        getText("IGUI_CP_KCM_Options_Drawing_LineColor"), 1.0, 1.0, 0, 1.0,
        getText("IGUI_CP_KCM_Options_Drawing_LineColor"))

    KCMConfing.modOptions.LineThicknessSlider = Options:addSlider("CP_KCM_Drawing_Line_Thickness",
        getText("IGUI_CP_KCM_Options_Drawing_Line_Thickness"),
        1.0, 32.0, 1.0, 2.0,
        getText("IGUI_CP_KCM_Options_Drawing_Line_Thickness_tooltip"));

    KCMConfing.modOptions.LineThicknessSliderTooltip = Options:addDescription(getText(
        "IGUI_CP_KCM_Options_Drawing_Line_Thickness_tooltip"));

    KCMConfing.Debug.isDebugSendBox = isDebugEnabled();



    Options.apply = function()
        KCMConfing.ShowDirectionInItem = KCMConfing.modOptions.ShowDirectionInItem:getValue();
        KCMConfing.ShowKeyId = KCMConfing.modOptions.ShowKeyId:getValue();
        KCMConfing.LineColor = KCMConfing.modOptions.LineColorPiker:getValue();
        KCMConfing.LineThickness = KCMConfing.modOptions.LineThicknessSlider:getValue();

        local sandBoxV = SandboxVars.KeyChainManager or {}
        KCMConfing.CompassNeeded = sandBoxV.CompassNeeded or false;

        if isDebugSendBox() then
            print("KCM in debug mode, ignore sendbox settings")

            print("KCM sendbox debug settings: " .. tostring(sandBoxV.IsDebugSendBox or false));
        else
            KCMConfing.Debug.isDebugSendBox = sandBoxV.IsDebugSendBox or false;
        end
    end

    Events.OnGameStart.Add(Options.apply)
end


KCMConfing.initOptions()


return KCMConfing
