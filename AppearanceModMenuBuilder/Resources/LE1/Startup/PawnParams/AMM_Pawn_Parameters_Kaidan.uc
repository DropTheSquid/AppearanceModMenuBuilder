Class AMM_Pawn_Parameters_Kaidan extends AMM_Pawn_Parameters_Romanceable
    config(Game);

public function SpecialHandling(BioPawn targetPawn)
{
    local BioPawnType pawnType;

	// this is a non framework specific issue:
	// if we are in the menu trying to customize Kaidan's casual appearance
	// we are relying on the spawned in combat pawn
	// who has the wrong settings on his pawn. He is configured for LGTa 5
	// while his Normandy appearance is CTHb 1
	// if the framework is not installed
	if (!Class'AMM_Utilities'.static.IsFrameworkInstalled())
	{
		// and this is a UI world pawn with armor overridden (casual preview)
		if (string(targetPawn.GetPackageName()) ~= "BIOG_UIWORLD" && Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(targetPawn))
		{
			pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
			// and it has his default combat appearance set
			if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_LIGHT && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 0 && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 4)
			{
				// the overwrite it with his default Normandy appearance
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType = EBioArmorType.ARMOR_TYPE_CLOTHING;
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant = 1;
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig = 0;
				// this will not match his overridden appearance if a mod has changed that only in the Normandy files
				// I accept this limitation. The Framework addresses this issue.
				// targetpawn.m_oBehavior.ForceAppearanceUpdate();
			}
		}
	}
}