Class AMM_Pawn_Parameters_Jenkins extends AMM_Pawn_Parameters_Squad
    config(Game);

public function SpecialHandling(BioPawn targetPawn)
{
    local BioPawnType pawnType;

	// Jenkins has a slew of issues if the framework is not installed
	if (!Class'AMM_Utilities'.static.IsFrameworkInstalled())
	{
		pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
		// if we are in the menu trying to customize Jenkins' casual appearance
		// we are relying on the spawned in combat pawn
		// who has the wrong settings on his pawn.
		if (targetPawn.GetPackageName() == 'BIOG_UIWORLD')
		{
			if (targetPawn.m_oBehavior.m_bArmorOverridden)
			{
				if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_MEDIUM && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 0 && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 4)
				{
					// If this is Jenkins and he has his default appearance of stock Medium armor, change it to match his normandy look;
					pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType = EBioArmorType.ARMOR_TYPE_CLOTHING;
					pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant = 1;
					pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig = 0;
					// this will not match his overridden appearance if a mod has changed that only in the Normandy files
					// also, he is missing his iconic hat.
					// I accept this limitation. The Framework addresses this issue.
				}
			}
			else
			{
				if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_CLOTHING && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 1 && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 0)
				{
					// Undo the above if we need him to appear in his default armor
					pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType = EBioArmorType.ARMOR_TYPE_MEDIUM;
					pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant = 0;
					pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig = 4;
				}
			}
		}
	}
}

public function string GetAppearanceType(BioPawn targetPawn)
{
	// if this is his pawn on the Normandy, it is always casual
	if (targetPawn.Tag == 'nor10_jenkins')
	{
		return "Casual";
	}

	// if this is one of his appearances on Eden Prime, treat him as being in combat mode even though his appearance may be overridden
	if (targetPawn.Tag == 'cutscene_jenkins' || targetPawn.Tag == 'cutscene_jenkins2')
    {
        return "combat";
    }

	// if he is hench_Jenkins, then it depends on whether he is in the party (root will be )
	if (targetPawn.Tag == 'hench_jenkins')
	{
		return targetPawn.m_oBehavior.m_bArmorOverridden ? "casual" : "combat";
	}
    return Super.GetAppearanceType(targetPawn);
}