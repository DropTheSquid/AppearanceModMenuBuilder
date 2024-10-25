public final function UpdateUIState(int NewState)
{
    local Name ClassName;
    local BioPawn TargetBP;
    local bool bUpdate;
    
    ClassName = 'Soldier';
    TargetBP = lstTemplates[int(m_nCurrentTemplate)];
    switch (NewState)
    {
        case 1:
        case 11:
            bUpdate = TRUE;
            break;
        case 12:
        case 13:
            bUpdate = TRUE;
            ClassName = 'None';
            break;
        case 7:
        case 14:
            bUpdate = TRUE;
            ClassName = lstCurrentClass[int(m_nCurrentTemplate)];
            break;
        default:
    }
    LastUIState = UIState;
    UIState = byte(NewState);
    if (LastUIState == NewCharacterUIState.NCMS_Class)
    {
        bUpdate = TRUE;
    }
    if (bUpdate)
    {
        Update3DModelByClass(ClassName, TargetBP, m_nCurrentTemplate, TRUE, FALSE, TRUE);
        // I need to run this again to ensure that the armor stays after we select a class other than soldier when it removes the pose and VFX from class selection
        BioWorldInfo(oWorldInfo).m_UIWorld.TriggerEvent('re_amm_update_cc', oWorldInfo);
    }
}