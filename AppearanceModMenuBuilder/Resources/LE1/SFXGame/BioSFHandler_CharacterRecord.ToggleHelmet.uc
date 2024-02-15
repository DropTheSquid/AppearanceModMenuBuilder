public function ToggleHelmet()
{
    local BioPlayerSquad oSquad;
    local BioPawn oSquadMember;
    local AppearanceUpdater updater;
    
    oSquad = BioWorldInfo(oWorldInfo).m_playerSquad;
    if (oSquad != None)
    {
        oSquadMember = BioPawn(oSquad.GetMember(m_CurrentPawnIndex));
    }
    if (oSquadMember != None)
    {
        oSquadMember.SetHeadGearVisiblePreference(!oSquadMember.GetHeadGearVisiblePreference());
        BioWorldInfo(oWorldInfo).m_UIWorld.UpdateHeadGearVisibility(oSquadMember);
        BioWorldInfo(oWorldInfo).m_UIWorld.TriggerEvent('AMM_UpdateCharRecAppearance', oWorldInfo);
        updater = Class'AppearanceUpdater'.static.GetInstance();
        updater.UpdatePawnAppearance(oSquadMember, "BioSFHandler_CharacterRecord.ToggleHelmet");
    }
}