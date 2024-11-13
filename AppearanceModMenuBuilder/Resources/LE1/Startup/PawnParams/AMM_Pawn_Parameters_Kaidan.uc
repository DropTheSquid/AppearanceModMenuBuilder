Class AMM_Pawn_Parameters_Kaidan extends AMM_Pawn_Parameters_Romanceable
    config(Game);

var transient array<string> pawnsToFix;

public function Object GetOverrideDefaultOutfitSpec(BioPawn targetPawn)
{
	local SimpleOutfitSpec delegateSpec;
	local bool AucInstalled;
	local object baseResult;

	baseResult = super.GetOverrideDefaultOutfitSpec(targetPawn);

	if (baseResult != None)
	{
		return baseResult;
	}

	if (GetAppearanceType(targetPawn) ~= "casual")
	{
		// HACK AUC compat, same as Ashley's
		// check if AUC is installed
		AucInstalled = DynamicLoadObject("DLC_MOD_AllianceUniformConsistency_GlobalTlk.GlobalTlk_tlk", class'Object') != None;
		if (AucInstalled)
		{
			delegateSpec = new class'SimpleOutfitSpec';
			delegateSpec.bodyMesh.MaterialPaths.AddItem("BIOG_HMM_ARM_CTH_AUC_R.CTHb.HMM_ARM_CTHb_AUC_MAT_1a");
			delegateSpec.helmetTypeOverride = -2;
			delegateSpec.bodyMesh.MeshPath = "BIOG_HMM_ARM_CTH_AUC_R.CTHb.HMM_ARM_CTHb_AUC_MDL";
		}
	}

	return None;
}

private function initHack(BioPawn targetPawn)
{
	local int i;
	local BioPawn partyPawn;

	// HACK KAO compatibility
	// if we force his body mesh to LOD 0 (continuously) then his face doesn't melt, regardless of what outfit he has on.

	// if this is a preview pawn. don't bother
	if (string(targetPawn.GetPackageName()) ~= "BIOG_UIWORLD")
	{
		return;
	}

	// if this pawn is in the party, don't bother
	if (GetPawnFromParty("hench_humanMale", partyPawn) && partypawn == targetPawn)
	{
		return;
	}

	
	// if KAO is not installed, don't bother
	if (DynamicLoadObject("DLC_MOD_KaidanOverhaul2_GlobalTlk.GlobalTlk_tlk", class'Object') == None)
	{
		return;
	}

	if (!targetPawn.IsTimerActive('AMM_KAO_HACK'))
	{
		i = pawnsToFix.Find(PathName(targetPawn));
		if (i == -1)
		{
			pawnsToFix.AddItem(PathName(targetPawn));
		}
		targetPawn.SetTimer(0.01, TRUE, 'AMM_KAO_HACK', Self);
	}
}

private function AMM_KAO_HACK()
{
	local string currentPawnString;
	local BioPawn currentPawn;
	local array<string> pawnsToRemove;

	// LogInternal("function has been called");
	foreach pawnsToFix(currentPawnString)
	{
		currentPawn = BioPawn(FindObject(currentPawnString, class'BioPawn'));
		if (currentPawn != None)
		{
			currentPawn.Mesh.ForcedLodModel = 1;
		}
		else
		{
			pawnsToRemove.AddItem(currentPawnString);
		}
	}
	foreach pawnsToRemove(currentPawnString)
	{
		pawnsToFix.RemoveItem(currentPawnString);
	}
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
	initHack(targetPawn);
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