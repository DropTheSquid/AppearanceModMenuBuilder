class VanillaOutfitSpecBase extends OutfitSpecBase abstract;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local int armorType;
    local int meshVariant;
    local int materialVariant;
	local AppearanceMeshPaths meshPaths;
	local array<string> meshMaterialPaths;
	local eHelmetDisplayState helmetDisplayState;
	local HelmetSpecBase delegateSpec;
	local BioPawnType pawnType;

	// this is for equipping their vanilla outfit
	// we will determine what outfit it should be based on the pawn's settings and then apply it
	if (!GetVariant(target, armorType, meshVariant, materialVariant))
    {
        return FALSE;
    }

	if (!GetPawnType(target, pawnType))
	{
		return false;
	}
	
	if (!GetOutfitStrings(
		pawnType,
		armorType, meshVariant, materialVariant,
		meshPaths))
	{
		return false;
	}

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(meshPaths, appearance.bodyMesh, false, true))
	{
		return false;
	}
	
	// get whether we should display the helmet based on a variety of factors
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	if (helmetDisplayState != eHelmetDisplayState.off)
	{
		delegateSpec = GetHelmetSpec(target, specLists, appearanceIds);
		if (delegateSpec != None)
		{
			if (!delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance))
			{
				LogInternal("failed to load helmet"@delegateSpec);
			}
		}
		else
		{
			LogInternal("failed to get helmet spec");
		}
	}
	return true;
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
	local HelmetSpecBase delegateSpec;

	delegateSpec = GetHelmetSpec(target, specLists, appearanceIds);
	if (delegateSpec == None)
	{
		return false;
	}
	return delegateSpec.LocksBreatherSelection(target, SpecLists, appearanceIds);
}

protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
	// This is in the abstract base class, and needs to be overridden in child classes
    LogInternal("You have made a programming mistake; VanillaOutfitSpecBase.GetVariant should never be called", );
    return FALSE;
}

protected function bool GetPawnType(BioPawn target, out BioPawnTYpe pawnType)
{
	pawnType = class'AMM_Utilities'.static.GetPawnType(target);
	return true;
}

protected static function bool GetOutfitStrings(BioPawnType pawnType, int armorType, int meshVariant, int materialVariant, out AppearanceMeshPaths Mesh)
{
    local ArmorTypes armor;
    local string meshPackageName;
    local string materialPackageName;
    local string prefix;
    local string meshCode;
    local int numMaterials;
    local string tempMaterial;
    local int i;
	local string sharedPrefix;
    
    armor = pawnType.m_oAppearance.Body.armor[armorType];
	// eg BIOG_TUR_ARM_LGT_R, always matches in vanilla
    meshPackageName = string(armor.m_meshPackageName);
    materialPackageName = string(armor.m_materialPackageName);
    if (meshPackageName == "None" || materialPackageName == "None")
    {
        LogInternal("No mesh or material package for armor type" @ armorType, );
        return FALSE;
    }
	// eg TUR_ARM
    prefix = pawnType.m_oAppearance.Body.AppearancePrefix;
    // For example, LGTa
    meshCode = class'Amm_Utilities'.static.GetArmorCode(byte(armorType)) $ class'Amm_Utilities'.static.GetLetter(meshVariant);
    numMaterials = armor.Variations[meshVariant].MaterialsPerVariation;
	// some outfits are set up wrong and say 0, noteably HMF LGTc
	if (numMaterials < 1)
	{
		numMaterials = 1;
	}
	// eg LGTa.TUR_ARM_LGTa
	sharedPrefix = meshCode $ "." $ prefix $ "_" $ meshCode;
	// eg BIOG_TUR_ARM_LGT_R.LGTa.TUR_ARM_LGTa_MDL
    Mesh.meshPath = meshPackageName $ "." $ sharedPrefix $ "_MDL";
    for (i = 0; i < numMaterials; i++)
    {
		// eg BIOG_TUR_ARM_LGT_R.LGTa.TUR_ARM_LGTa_MAT_1a
        tempMaterial = materialPackageName $ "." $ sharedPrefix $ "_MAT_" $ materialVariant + 1 $ class'Amm_Utilities'.static.GetLetter(i);
        Mesh.MaterialPaths.AddItem(tempMaterial);
    }
    return TRUE;
}

