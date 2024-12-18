Class AMM_Pawn_Parameters_Jenkins extends AMM_Pawn_Parameters_Squad
    config(Game);

public function Object GetOverrideDefaultOutfitSpec(BioPawn targetPawn)
{
	local SimpleOutfitSpec delegateSpec;

	if (GetAppearanceType(targetPawn) ~= "casual")
	{
		// HACK AUC compat, same as Kaindan's
		// check if AUC is installed
		if (DynamicLoadObject("DLC_MOD_AllianceUniformConsistency_GlobalTlk.GlobalTlk_tlk", class'Object') != None)
		{
			delegateSpec = new class'SimpleOutfitSpec';
			delegateSpec.bodyMesh.MaterialPaths.AddItem("BIOG_HMM_ARM_CTH_AUC_R.CTHb.HMM_ARM_CTHb_AUC_MAT_1a");
			delegateSpec.helmetTypeOverride = -2;
			delegateSpec.bodyMesh.MeshPath = "BIOG_HMM_ARM_CTH_AUC_R.CTHb.HMM_ARM_CTHb_AUC_MDL";
			return DelegateSpec;
		}
	}

	// otherwise, let it behave as normal

	return super.GetOverrideDefaultOutfitSpec(targetPawn);
}

public function SpecialHandling(BioPawn targetPawn)
{
    local BioPawnType pawnType;

	pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);

	// remove Jenkins' faceplate spec so that you cannot cycle to a full helmet and see the ugly pink default NPC faceplate.
	pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_aFacePlateMeshSpec.Length = 0;
	pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apFacePlateMaterial.Length = 0;

	// if this is cutscene Jenkins (1 or 2) and it is active, remove his visor spec so it will disappear with his vanilla look so Kaidan can close his eyes without clipping through the visor
	if ((targetPawn.Tag == 'cutscene_jenkins' || targetPawn.Tag == 'cutscene_jenkins2') && targetPawn.m_oBehavior.bActive)
	{
		pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMesh.Length = 0;
		pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMaterial.Length = 0;
	}

	// Jenkins has a slew of issues if the framework is not installed
	if (!Class'AMM_Common'.static.IsFrameworkInstalled())
	{
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

	// if he is hench_Jenkins, go with the behavior Armor override, but not the pawnType override, because he is set up super weirdly
	if (targetPawn.Tag == 'hench_jenkins')
	{
		return targetPawn.m_oBehavior.m_bArmorOverridden ? "casual" : "combat";
	}
    return Super.GetAppearanceType(targetPawn);
}

defaultproperties
{
    // don't hide Jenkin's helmet; it is awkward when he dies and his helemt is appearing and disappearing. Also, you're not supposed to see his bare head.
    hideHelmetsInConversations=false
}