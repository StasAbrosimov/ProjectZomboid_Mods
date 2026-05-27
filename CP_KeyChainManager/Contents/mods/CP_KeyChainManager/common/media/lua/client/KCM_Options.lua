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

    Options.apply = function()
        KCMConfing.ShowDirectionInItem = KCMConfing.modOptions.ShowDirectionInItem:getValue();
        KCMConfing.ShowKeyId = KCMConfing.modOptions.ShowKeyId:getValue();
    end

    Events.OnGameStart.Add(Options.apply)
end


KCMConfing.initOptions()


return KCMConfing
