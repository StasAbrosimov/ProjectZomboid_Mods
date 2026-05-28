require 'luautils'

local KCMConfing = {
    --- Whether to hide the dig cursor after selecting a square to dig.
    --- @type boolean
    ShowDirectionInItem = false,

    --- Whether to show debugging menus.
    --- @type boolean
    ShowKeyId = false
}

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

    if not luautils.drawLine2 then
        Options:addDescription(
            "IGUI_CP_KCM_Options_Required_luautils_start")
    end

    KCMConfing.modOptions.LineThicknessSlider = Options:addSlider("CP_KCM_Drawing_Line_Thickness",
        getText("IGUI_CP_KCM_Options_Drawing_Line_Thickness"),
        1.0, 32.0, 1.0, 2.0,
        getText("IGUI_CP_KCM_Options_Drawing_Line_Thickness_tooltip"));

    if not luautils.drawLine2 then
        Options:addDescription(
            "IGUI_CP_KCM_Options_Required_luautils_end")
    end

    Options.apply = function()
        KCMConfing.ShowDirectionInItem = KCMConfing.modOptions.ShowDirectionInItem:getValue();
        KCMConfing.ShowKeyId = KCMConfing.modOptions.ShowKeyId:getValue();
        KCMConfing.LineColor = KCMConfing.modOptions.LineColorPiker:getValue();
        KCMConfing.LineThickness = KCMConfing.modOptions.LineThicknessSlider:getValue();
    end

    Events.OnGameStart.Add(Options.apply)
end


KCMConfing.initOptions()


return KCMConfing
