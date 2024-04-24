public final function bool ChangeToCharacter(BioPawn NextCharacter)
{
    local ASParams currentParameter;
    local array<ASParams> Parameters;
    local string HelmetButtonText;
    
    if (m_CurrentPawn != None)
    {
        m_WorldInfo.m_UIWorld.HidePawn(m_CurrentPawn, TRUE);
        m_WorldInfo.m_UIWorld.SetPawnVariable('CharRecPawn', None);
    }
    m_CurrentPawn = NextCharacter;
	// check whether we should be showing a helmet button and what it should say
    HelmetButtonText = Class'AMM_AppearanceUpdater_Base'.static.ShouldShowHelmetButtonStatic(m_CurrentPawn);
	// store this for later
    oPanel.SetVariableString("amm_currentHelmetText", HelmetButtonText);
    m_CurrentPawnIndex = m_WorldInfo.m_playerSquad.GetMemberIndex(m_CurrentPawn);
    m_TalentContainer = m_CurrentPawn.m_oBehavior.m_Talents;
    if (m_TalentContainer == None)
    {
        LogInternal(GetFuncName() @ "- Warning! Talent container associated with pawn" @ NextCharacter @ "is null!", );
        return FALSE;
    }
    if (!m_TalentContainer.InitializeLevelUp())
    {
        LogInternal(GetFuncName() @ "- Warning! Failed to initialize level up for pawn " @ NextCharacter $ ".", );
        return FALSE;
    }
    currentParameter.Type = ASParamTypes.ASParam_Integer;
    currentParameter.nVar = 2;
    Parameters.AddItem(currentParameter);
    currentParameter.Type = ASParamTypes.ASParam_Boolean;
    currentParameter.bVar = TRUE;
    Parameters.AddItem(currentParameter);
    oPanel.InvokeMethodArgs("SuspendWithPeriod", Parameters);
    m_WorldInfo.m_UIWorld.TriggerEvent('SetupCharRec', m_WorldInfo);
    if (m_PawnIsSpawned.Length > m_CurrentPawnIndex && m_PawnIsSpawned[m_CurrentPawnIndex])
    {
        m_WorldInfo.m_UIWorld.HidePawn(m_CurrentPawn, FALSE);
        m_WorldInfo.m_UIWorld.SetPawnVariable('CharRecPawn', m_CurrentPawn);
        m_WorldInfo.m_UIWorld.UpdateAppearance(m_CurrentPawn);
    }
    else
    {
        m_WorldInfo.m_UIWorld.SpawnPawn(m_CurrentPawn, 'CharRecSpawnPoint', 'CharRecPawn');
        if (m_PawnIsSpawned.Length <= m_CurrentPawnIndex)
        {
            m_PawnIsSpawned.Length = m_CurrentPawnIndex + 1;
        }
        m_PawnIsSpawned[m_CurrentPawnIndex] = TRUE;
    }
	// make sure we update the character's appearance to match the appearance type outside the menu
	if (m_CurrentPawn.m_oBehavior.IsArmorOverridden())
	{
		m_WorldInfo.m_UIWorld.TriggerEvent('re_AMM_charRec_Casual', m_WorldInfo);
	}
	else
	{
		m_WorldInfo.m_UIWorld.TriggerEvent('re_AMM_charRec_Combat', m_WorldInfo);
	}
    PlayGuiSound('ChangeCharacter');
    return TRUE;
}