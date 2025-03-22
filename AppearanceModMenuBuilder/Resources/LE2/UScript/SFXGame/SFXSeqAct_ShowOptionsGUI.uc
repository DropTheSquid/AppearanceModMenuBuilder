Class SFXSeqAct_ShowOptionsGUI extends BioSequenceLatentAction;

// these modifications work, except you see a flash of something or other because the panel is removed too early. need to investigate when it actually gets removed. 

var bool m_bIsFinished;
var(SFXSeqAct_ShowOptionsGUI) EOptionsGuiMode OptionsGUIMode;
// added to hold onto the handler for the mod settings menu
var BioSFHandler MSMHandler;

public event function Deactivated()
{
    local BioWorldInfo oWorldInfo;
    local BioPlayerController oController;
    local MassEffectGuiManager oMgr;
    local BioSFPanel oPanel;
    
    oWorldInfo = BioWorldInfo(GetWorldInfo());
    oController = oWorldInfo.GetLocalPlayerController();
    if (oController != None)
    {
        oMgr = MassEffectGuiManager(oController.GetScaleFormManager());
        if (oMgr != None)
        {
            oPanel = oMgr.GetPanelByTag('Options');
            if (oPanel != None)
            {
                oMgr.RemovePanel(oPanel);
            }
        }
    }
}
public function onScreenClosed()
{
    local BioSFPanel panel;
    local MassEffectGuiManager oMgr;

    // added; if this was launched as part of the new game sequence
    if (OptionsGUIMode == EOptionsGuiMode.GuiMode_NewGame)
    {
        oMgr = MassEffectGuiManager(BioWorldInfo(GetWorldInfo()).GetLocalPlayerController().GetScaleFormManager());
        panel = oMgr.CreatePanel('MSM', TRUE);
        oMgr.CreatePanel('Options', TRUE);
        if (panel != None)
        {
            panel.bFullScreen = TRUE;
            MSMHandler = panel.GetDefaultHandler();
            // testing this; when does it get rid of it?
            panel.m_bSelfPanelClose = false;
        }
    }
    else
    {
        // this is the entirety of the vanilla function
        m_bIsFinished = TRUE;
    }
}
public function bool UpdateOp(float fDeltaT)
{
    if (MSMHandler != None && MSMHandler.oPanel == None)
    {
        m_bIsFinished = true;
    }
    if (m_bIsFinished)
    {
        if (!bAborted)
        {
            OutputLinks[0].bHasImpulse = TRUE;
            OutputLinks[1].bHasImpulse = FALSE;
            OutputLinks[2].bHasImpulse = FALSE;
        }
        else
        {
            OutputLinks[0].bHasImpulse = FALSE;
            OutputLinks[1].bHasImpulse = TRUE;
            OutputLinks[2].bHasImpulse = TRUE;
        }
    }
    return m_bIsFinished;
}
public event function Activated()
{
    local BioWorldInfo oWorldInfo;
    local BioPlayerController oController;
    local MassEffectGuiManager oMgr;
    local BioSFPanel oNewPanel;
    local BioSFHandler_Options oOptions;
    
    bAborted = FALSE;
    m_bIsFinished = FALSE;
    oWorldInfo = BioWorldInfo(GetWorldInfo());
    oController = oWorldInfo.GetLocalPlayerController();
    if (oController != None)
    {
        oMgr = MassEffectGuiManager(oController.GetScaleFormManager());
        oNewPanel = oMgr.CreatePanel('Options', TRUE);
        if (oNewPanel != None)
        {
            oNewPanel.bFullScreen = TRUE;
            oOptions = BioSFHandler_Options(oNewPanel.GetDefaultHandler());
            oOptions.GuiMode = OptionsGUIMode;
            // changed this as an experiment, because it stuck around even though my thing was launched. 
            // should I just add the base handler and hide the options screen?
            oOptions.m_bSelfPanelClose = FALSE;
            oOptions.SetOnCloseCallback(onScreenClosed);
        }
        else
        {
            bAborted = TRUE;
            m_bIsFinished = TRUE;
        }
    }
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    OptionsGUIMode = EOptionsGuiMode.GuiMode_NewGame
    bHasTargets = FALSE
    VariableLinks = ()
    bManualHandleOutputs = TRUE
}