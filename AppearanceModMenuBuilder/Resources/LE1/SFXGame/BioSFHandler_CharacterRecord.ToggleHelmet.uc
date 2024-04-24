public function ToggleHelmet()
{
    local BioPlayerSquad oSquad;
    local BioPawn oSquadMember;
	local string HelmetButtonText;
    
	// it is possible to invoke this with the controller even when the button is not visible; ignore it
    HelmetButtonText = oPanel.GetVariableString("amm_currentHelmetText");
    if (HelmetButtonText == "")
    {
        return;
    }
    
    oSquad = BioWorldInfo(oWorldInfo).m_playerSquad;
    if (oSquad != None)
    {
        oSquadMember = BioPawn(oSquad.GetMember(m_CurrentPawnIndex));
    }
    if (oSquadMember != None)
    {
		// delegate to the appearance updater to cycle to the next helmet state
        Class'AMM_AppearanceUpdater_Base'.static.HelmetButtonPressedStatic(oSquadMember);
		// trigger a new update of the character record pawn
		BioWorldInfo(oWorldInfo).m_UIWorld.TriggerEvent('re_AMM_update_CharRec_Appearance', oWorldInfo);
		// and the real world pawn
		Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(oSquadMember, "BioSFHandler_CharacterRecord.ToggleHelmet");
    }
}