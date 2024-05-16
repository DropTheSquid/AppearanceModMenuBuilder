Class AMM_Pawn_Parameters_Liara extends AMM_Pawn_Parameters_Romanceable
	config(Game);

public function SpecialHandling(BioPawn targetPawn)
{
	local BioPawnType pawnType;

	// if we have configured Liara to wear armor on Therum and Virmire, update her pawn settings to reflect this
	if (LiaraWearsArmor())
	{
		if (targetPawn.GetPackageName() == 'BIOA_LAV70_07_DSG'
			|| targetPawn.GetPackageName() == 'BIOA_JUG20_08_DSG'
			|| targetPawn.GetPackageName() == 'BIONPC_Liara')
		{
			pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);

			if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_CLOTHING
				&& pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 7
				&& pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 4)
			{
				BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_eArmorType = EBioArmorType.ARMOR_TYPE_LIGHT;
				BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nModelVariant = 0;
				BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nMaterialConfig = 6;
			}
		}
	}
}

public function string GetAppearanceType(BioPawn targetPawn)
{
	// by default, Liara is considered to be in casual appearance on Therum and Virmire comap, despite not having armor overridden. 
	// this is true with the framework also
	if (targetPawn.GetPackageName() == 'BIOA_LAV70_07_DSG'
		|| targetPawn.GetPackageName() == 'BIOA_JUG20_08_DSG'
		|| targetPawn.GetPackageName() == 'BIONPC_Liara')
	{
		return LiaraWearsArmor() ? "combat" : "casual";
	}

	return Super(AMM_Pawn_Parameters_Romanceable).GetAppearanceType(targetPawn);
}

private function bool LiaraWearsArmor()
{
	local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;

    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    globalVars = BWI.GetGlobalVariables();
    return globalVars.GetInt(1599) != 0;
}
