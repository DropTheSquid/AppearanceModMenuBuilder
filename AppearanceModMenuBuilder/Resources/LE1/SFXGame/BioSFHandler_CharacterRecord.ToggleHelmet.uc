public function ToggleHelmet()
{
    local BioPlayerSquad oSquad;
    local BioPawn oSquadMember;
    
    oSquad = BioWorldInfo(oWorldInfo).m_playerSquad;
    if (oSquad != None)
    {
        oSquadMember = BioPawn(oSquad.GetMember(m_CurrentPawnIndex));
    }
    if (oSquadMember != None)
    {
        oSquadMember.SetHeadGearVisiblePreference(!oSquadMember.GetHeadGearVisiblePreference());
        BioWorldInfo(oWorldInfo).m_UIWorld.UpdateHeadGearVisibility(oSquadMember);
		// trigger a new update of the character record pawn
		BioWorldInfo(oWorldInfo).m_UIWorld.TriggerEvent('re_AMM_update_CharRec_Appearance', oWorldInfo);
		// and the real world pawn
		Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(oSquadMember, "BioSFHandler_CharacterRecord.ToggleHelmet");
    }
}