Class AMM_Pawn_Parameters_Ashley extends AMM_Pawn_Parameters_Romanceable
    config(Game);

public function Object GetOverrideDefaultOutfitSpec(BioPawn targetPawn)
{
	local SimpleOutfitSpec delegateSpec;

	if (GetAppearanceType(targetPawn) ~= "casual")
	{
		// HACK AUC compatibility; this ensures Ashley will appear in the correct casual outfit in all circumstances
		// TODO remove this after AUC is rebuilt on framework hopefully
		// check if AUC is installed
		if (DynamicLoadObject("DLC_MOD_AllianceUniformConsistency_GlobalTlk.GlobalTlk_tlk", class'Object') != None)
		{
			delegateSpec = new class'SimpleOutfitSpec';
			delegateSpec.bodyMesh.MaterialPaths.AddItem("BIOG_HMF_ARM_CTH_AUC_R.CTHb.HMF_ARM_CTHb_AUC_MAT_1a");
			delegateSpec.helmetTypeOverride = -2;
			delegateSpec.bodyMesh.MeshPath = "BIOG_HMF_ARM_CTH_AUC_R.CTHb.HMF_ARM_CTHb_AUC_MDL";
			return DelegateSpec;
		}
	}
	// otherwise, let it behave as normal

	return super.GetOverrideDefaultOutfitSpec(targetPawn);
}

public function SpecialHandling(BioPawn targetPawn)
{
    local BioPawnType pawnType;

	// this is a non-framework specific issue (EG there is no issue when framework is installed):
	// if we are in the menu trying to customize Ashley's casual appearance
	// we are relying on the spawned in combat pawn
	// who has the wrong settings on her pawn. She is configured for HVYa 10 (Pheonix heavy)
	// while her Normandy appearance is CTHb 1
	// if the framework is not installed
	// note that casual hubs also addresses this issue
	if (!Class'AMM_Common'.static.IsFrameworkInstalled())
	{
		// HACK vanilla issue. can be removed if we ever start to require the framework
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
	// pre recruitment (Eden Prime, tag is pro10_ash)
	// in party w/ or w/o casual hubs
	// Virmire Camp
	// Normandy

	if (
		// immediately pre recruitment (non framework)
		targetPawn.Tag == 'pro10_ash'
		// Virmire camp (non Framework)
		|| targetPawn.GetPackageName() == 'BIOA_JUG20_08_DSG'
		// pre recruitment/Virmire Camp (framework)
		|| targetPawn.GetPackageName() == 'BIONPC_Ashley')
	{
		return "combat";
	}

	return Super(AMM_Pawn_Parameters_Romanceable).GetAppearanceType(targetPawn);
}