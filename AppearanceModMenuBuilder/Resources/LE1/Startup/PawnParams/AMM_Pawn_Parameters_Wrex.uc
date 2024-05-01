Class AMM_Pawn_Parameters_Wrex extends AMM_Pawn_Parameters_Squad
    config(Game);

public function SpecialHandling(BioPawn targetPawn)
{
    local BioPawnType pawnType;
	
	// this is a non-framework specific issue (EG there is no issue when framework is installed):
	// if we are in the menu trying to customize Wrex's casual appearance
	// we are relying on the spawned in combat pawn
	// who has the wrong settings on his pawn. He is configured for HVYa 6
	// while his Normandy appearance is MEDa 7
	// if the framework is not installed
	// note that casual hubs also might also addresses this issue if you install the Wrex casual option
	if (!Class'AMM_Utilities'.static.IsFrameworkInstalled())
	{
		// and this is a UI world pawn with armor overridden (casual preview)
		if (string(targetPawn.GetPackageName()) ~= "BIOG_UIWORLD" && Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(targetPawn))
		{
			pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
			// and it has his default combat appearance set
			if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_HEAVY && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 0 && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 6)
			{
				// the overwrite it with his default Normandy appearance
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType = EBioArmorType.ARMOR_TYPE_MEDIUM;
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant = 0;
				pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig = 7;
				// this will not match his overridden appearance if a mod has changed that only in the Normandy files
				// I accept this limitation. The Framework addresses this issue.
			}
		}
	}
}

defaultproperties
{
	// Wrex is too tall for the default camera height
	PreviewCameraMaxHeight = 105
}