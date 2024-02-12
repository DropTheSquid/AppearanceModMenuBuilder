public final function UpdateCharacter()
{
    local Name ClassName;
    local BioPawn TargetBP;
    local bool bUpdateAnimsAndVFX;
    local bool bUpdateAppearance;
    local BioWorldInfo WI;
    
    ClassName = 'Soldier';
    TargetBP = lstTemplates[int(m_nCurrentTemplate)];
    switch (UIState)
    {
        case NewCharacterUIState.NCMS_Iconic:
        case NewCharacterUIState.NCMS_FaceCustom:
        case NewCharacterUIState.NCMS_Sex:
            bUpdateAnimsAndVFX = TRUE;
            break;
        case NewCharacterUIState.NCMS_Class:
            ClassName = lstCurrentClass[int(m_nCurrentTemplate)];
            bUpdateAnimsAndVFX = TRUE;
            break;
        case NewCharacterUIState.NCMS_FaceTitle:
        case NewCharacterUIState.NCMS_FaceDetail:
            ClassName = 'None';
            bUpdateAppearance = TRUE;
            break;
        default:
    }
    if (bUpdateAnimsAndVFX)
    {
        WI = BioWorldInfo(oWorldInfo);
        WI.m_UIWorld.TriggerEvent('SetupCharCreate', WI);
    }
    if (!bUpdateAppearance)
    {
        Update3DModelByClass(ClassName, TargetBP, m_nCurrentTemplate, bUpdateAnimsAndVFX, FALSE, bUpdateAnimsAndVFX);
    }
    else
    {
		// this method overwrites my AMM changes. I need to reapply after this runs
        BioWorldInfo(oWorldInfo).m_UIWorld.UpdateAppearance(lstTemplates[int(m_nCurrentTemplate)], ClassName);
		// this is only set in certain branches, so set it if it is unset
        if (WI == None)
        {
            WI = BioWorldInfo(oWorldInfo);
        }
		// trigger my new Remote Event that will update the appearance
		// this will safely do nothing if the mod is not installed.
        WI.m_UIWorld.TriggerEvent('re_amm_update_cc', WI);
    }
    
}