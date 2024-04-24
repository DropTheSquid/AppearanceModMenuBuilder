public function Update(float fDeltaT)
{
    local BioEventNotifier oNotifier;
    local ASParams stParam;
    local array<ASParams> lstParams;
    local string HelmetButtonText;
    
    stParam.Type = ASParamTypes.ASParam_Float;
    stParam.fVar = m_fScrollValue;
    lstParams.AddItem(stParam);
    oPanel.InvokeMethodArgs("scrollDetailsAnalog", lstParams);
    if (m_CurrentPawn != None)
    {
        oNotifier = BioWorldInfo(oWorldInfo).EventNotifier;
        if (oNotifier.PendingTalentNotify(m_CurrentPawn))
        {
            lstParams[0].Type = ASParamTypes.ASParam_Integer;
            lstParams[0].nVar = 2;
            stParam.Type = ASParamTypes.ASParam_Boolean;
            stParam.bVar = FALSE;
            lstParams.AddItem(stParam);
            oPanel.InvokeMethodArgs("SuspendWithPeriod", lstParams);
            oNotifier.ShowTalentNotify(m_CurrentPawn);
        }
    }
	// make sure the button visibility and text is always correct
    HelmetButtonText = oPanel.GetVariableString("amm_currentHelmetText");
    if (HelmetButtonText == "")
    {
        oPanel.SetClipVisibility("_root.ConsoleToggleHelmMC", FALSE);
        oPanel.SetClipVisibility("_root.PCToggleHelmMC", FALSE);
    }
    else
    {
        oPanel.SetClipVisibility("_root.ConsoleToggleHelmMC", oPanel.bUsingGamepad);
        oPanel.SetClipVisibility("_root.PCToggleHelmMC", !oPanel.bUsingGamepad);
        oPanel.SetTextFieldText("_root.ConsoleToggleHelmMC.BtnText", HelmetButtonText);
        oPanel.SetTextFieldText("_root.PCToggleHelmMC.textMC.textBox", HelmetButtonText);
    }
}