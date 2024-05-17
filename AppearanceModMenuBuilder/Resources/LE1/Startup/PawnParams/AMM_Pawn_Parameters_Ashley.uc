Class AMM_Pawn_Parameters_Ashley extends AMM_Pawn_Parameters_Romanceable
    config(Game);

public function SpecialHandling(BioPawn targetPawn)
{
    local BioPawnType pawnType;
    local string sComment;

	// this is a non-framework specific issue (EG there is no issue when framework is installed):
	// if we are in the menu trying to customize Ashley's casual appearance
	// we are relying on the spawned in combat pawn
	// who has the wrong settings on her pawn. She is configured for HVYa 10 (Pheonix heavy)
	// while her Normandy appearance is CTHb 1
	// if the framework is not installed
	// note that casual hubs also addresses this issue
	if (!Class'AMM_Common'.static.IsFrameworkInstalled())
	{
		// and this is a UI world pawn with armor overridden (casual preview)
		if (string(targetPawn.GetPackageName()) ~= "BIOG_UIWORLD" && Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(targetPawn))
		{
			pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
			// and it has her default combat appearance set
			if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_HEAVY && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 0 && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 10)
			{
				// the overwrite it with her default Normandy appearance
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType = EBioArmorType.ARMOR_TYPE_CLOTHING;
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant = 1;
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig = 0;
				// this will not match his overridden appearance if a mod has changed that only in the Normandy files
				// I accept this limitation. The Framework addresses this issue.
			}
		}
	}
}
public function string GetAppearanceType(BioPawn targetPawn)
{
	// all Ashley appearances:
	// pre recruitment (pro10_ash) needs to be overridden to combat
	// in party w/ or w/o casual hubs
	// Virmire Camp
	// Nomrandy debrief?
	
	// TODO check how this interacts with framework
	// pro10_ash is immediately pre recruitment. It has the armor override flag set to true, so it would normally be seen as casual
    if (targetPawn.Tag == 'pro10_ash')
    {
        return "combat";
    }
    return Super(AMM_Pawn_Parameters_Romanceable).GetAppearanceType(targetPawn);
}