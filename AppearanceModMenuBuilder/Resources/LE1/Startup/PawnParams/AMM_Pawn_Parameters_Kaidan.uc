Class AMM_Pawn_Parameters_Kaidan extends AMM_Pawn_Parameters_Romanceable
    config(Game);

public function Object GetOverrideDefaultSpec(BioPawn targetPawn)
{
	local SimpleOutfitSpec delegateSpec;

	if (GetAppearanceType(targetPawn) ~= "casual")
	{
		// HACK AUC compat, same as Ashley's
		// check if AUC is installed
		if (DynamicLoadObject("DLC_MOD_AllianceUniformConsistency_GlobalTlk.GlobalTlk_tlk", class'Object') != None)
		{
			delegateSpec = new class'SimpleOutfitSpec';
			delegateSpec.bodyMesh.MaterialPaths.AddItem("BIOG_HMM_ARM_CTH_AUC_R.CTHb.HMM_ARM_CTHb_AUC_MAT_1a");
			delegateSpec.helmetTypeOverride = -2;

			// then also check if Kaidan Overhaul is installed
			if (DynamicLoadObject("DLC_MOD_KaidanOverhaul2_GlobalTlk.GlobalTlk_tlk", class'Object') != None)
			{
				delegateSpec.bodyMesh.MeshPath = "kaidan_overhaul.kaidan_clth";
			}
			else
			{
				delegateSpec.bodyMesh.MeshPath = "BIOG_HMM_ARM_CTH_AUC_R.CTHb.HMM_ARM_CTHb_AUC_MDL";
			}
			return DelegateSpec;
		}
	}

	// otherwise, let it behave as normal

	return None;
}

public function SpecialHandling(BioPawn targetPawn)
{
    local BioPawnType pawnType;

	// this is a non-framework specific issue (EG there is no issue when framework is installed):
	// if we are in the menu trying to customize Kaidan's casual appearance
	// we are relying on the spawned in combat pawn
	// who has the wrong settings on his pawn. He is configured for LGTa 5
	// while his Normandy appearance is CTHb 1
	// if the framework is not installed
	// note that casual hubs also addresses this issue
	// HACK vanilla issue, will be addressed by framework
	if (!Class'AMM_Common'.static.IsFrameworkInstalled())
	{
		// and this is a UI world pawn with armor overridden (casual preview)
		if (string(targetPawn.GetPackageName()) ~= "BIOG_UIWORLD" && Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(targetPawn))
		{
			pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
			// and it has his default combat appearance set
			if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_LIGHT && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 0 && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 4)
			{
				// then overwrite it with his default Normandy appearance
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
	if (targetPawn.Tag == 'hench_humanmale')
	{
		// if this is streamed in with the framework or it's in the Salarian Camp on Virmire, count it as combat
		if (targetPawn.GetPackageName() == 'BIONPC_Kaidan' || targetPawn.GetPackageName() == 'BIOA_JUG20_08_DSG')
		{
			return "combat";
		}
	}
	// otherwise, go with the normal system of relying on the armor override to account for in party with/without casual hubs
    return Super.GetAppearanceType(targetPawn);
}