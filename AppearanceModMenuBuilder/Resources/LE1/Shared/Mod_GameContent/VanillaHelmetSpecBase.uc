Class VanillaHelmetSpecBase extends HelmetSpecBase;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local int armorType;
    local int meshVariant;
    local int materialVariant;
	local AppearanceMeshPaths helmetMeshPaths;
	local array<string> meshMaterialPaths;
	local bool suppressVisor;
	local bool suppressBreather;
	local bool hideHair;
	local bool hideHead;
	local eHelmetDisplayState helmetDisplayState;
	local BioPawnType pawnType;
	local BreatherSpecBase delegateSpec;

	if (!GetPawnType(target, pawnType))
	{
		return false;
	}

	// this is for equipping their vanilla outfit
	// we will determine what outfit it should be based on the pawn's settings and then apply it
	if (!GetVariant(target, armorType, meshVariant, materialVariant))
    {
        return FALSE;
    }

	// get the helmet mesh paths and various parameters around it
	if (!GetHelmetMeshPaths(
		pawnType,
		armorType,
		meshVariant,
		materialVariant,
		helmetMeshPaths,
		hideHair,
		hideHead,
		suppressVisor,
		suppressBreather
	))
	{
		return false;
	}

	// load the helmet mesh
	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(helmetMeshPaths, appearance.HelmetMesh, true, true))
	{
		return false;
	}

	appearance.hideHair = appearance.hideHair || hideHair;
	appearance.hideHead = appearance.hideHead || hideHead;

	// if the visor is not suppressed, get the visor mesh
	if (!suppressVisor)
	{
		class'AMM_Utilities'.static.GetVanillaVisorMesh(pawnType, appearance.VisorMesh);
	}

	// check whether we should display a breather
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	if (helmetDisplayState != eHelmetDisplayState.full)
	{
		suppressBreather = true;
	}

	// if the breather is not suppressed, delegate to the breather spec
	if (!suppressBreather)
	{
		delegateSpec = GetBreatherSpec(target, specLists, appearanceIds);
		if (delegateSpec != None)
		{
			if (!delegateSpec.LoadBreather(target, specLists, appearanceIds, appearance))
			{
				LogInternal("failed to load breather spec"@delegateSpec);
			}
		}
		else
		{
			LogInternal("failed to get breather spec");
		}
	}
	
	return true;
}

protected function bool GetPawnType(BioPawn target, out BioPawnTYpe pawnType)
{
	pawnType = class'AMM_Utilities'.static.GetPawnType(target);
	return true;
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local int armorType;
    local int meshVariant;
    local int materialVariant;
	local AppearanceMeshPaths helmetMeshPaths;
	local bool suppressVisor;
	local bool suppressBreather;
	local bool hideHair;
	local bool hideHead;

	if (!GetVariant(target, armorType, meshVariant, materialVariant))
    {
        return FALSE;
    }

	// get the helmet mesh paths and various parameters around it
	if (!GetHelmetMeshPaths(
		class'AMM_Utilities'.static.GetPawnType(target),
		armorType,
		meshVariant,
		materialVariant,
		helmetMeshPaths,
		hideHair,
		hideHead,
		suppressVisor,
		suppressBreather
	))
	{
		return false;
	}

	// if this vanilla outfit supresses the breather, then count that as locking it
	return suppressBreather;
}


protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
	// This is in the abstract base class, and needs to be overridden in child classes
    LogInternal("You have made a programming mistake; VanillaHelmetSpecBase.GetVariant should never be called", );
    return FALSE;
}

// given the pawnType and armor variant numbers,
// output the helmet/visor meshes
// and whether various things should be shown
// note that we populate the visor mesh even if it is suppressed, as the breather might un-suppress it
private static function bool GetHelmetMeshPaths(
	BioPawnType pawnType,
	int armorType,
	int meshVariant,
	int materialVariant,
	out AppearanceMeshPaths helmetMeshPaths,
	out bool hideHair,
	out bool hideHead,
	out bool suppressVisor,
	out bool suppressBreather)
{
	local BioHeadGearAppearanceArmorSpec armorTypeSpec;
	local BioHeadGearAppearanceModelSpec modelSpec;
	local string modelCode;
    local string prefix;
	local string sharedPrefix;
    local string tempMaterial;
    local int i;
    local int numMaterials;
	local string headGearPackageName;

	if (pawnType.m_oAppearance.Body.m_oHeadGearAppearance == None)
    {
		// this is actually expected for Tali, so we need to allow it
		suppressVisor = true;
		suppressBreather = true;
        return true;
    }
	// contains info on how many mesh variants there are, how many materials per mesh, how many material variants, and what package they all live in
	armorTypeSpec = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_aArmorSpec[armorType];
	// eg BIOG_TUR_HGR_LGT_R
    headGearPackageName = string(armorTypeSpec.m_nmPackage);

	if (headGearPackageName == "None")
    {
        // this is completely expected for nkd and clothes armor levels, where there is no package of headgear.
        suppressVisor = true;
		suppressBreather = true;
        return true;
    }

	// the spec for the specific mesh variant I am interested in
	modelSpec = armorTypeSpec.m_aModelSpec[meshVariant];
	// this tells us whether this model hides hair/head
    hideHair = modelSpec.m_bIsHairHidden;
    hideHead = modelSpec.m_bIsHeadHidden;
	// and whether the visor should be suppressed
	// this is super stupid and mysterious but it is needed for Turian helmets to work right
	suppressVisor = modelSpec.m_bSuppressVisor || pawnType.m_oAppearanceSettings.m_oBodySettings.m_oHeadGearSettings.m_visor.m_bIsHidden;

	// and whether the faceplate/breather should be suppressed
    suppressBreather = modelSpec.m_bSuppressFacePlate;

	// eg LGTa
	modelCode = class'Amm_Utilities'.static.GetArmorCode(byte(armorType)) $ class'Amm_Utilities'.static.GetLetter(meshVariant);
	// eg TUR_HGR
    prefix = string(pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_nmPrefix);
	sharedPrefix = modelCode $ "." $ prefix $ "_" $ modelCode;
	// eg BIOG_TUR_HGR_LGT_R.LGTa.TUR_HGR_LGTa_MDL
    helmetMeshPaths.MeshPath = headGearPackageName $ "." $ sharedPrefix $ "_MDL";
    numMaterials = modelSpec.m_nMaterialCountPerConfig;
    for (i = 0; i < numMaterials; i++)
    {
		// eg BIOG_TUR_HGR_LGT_R.LGTa.TUR_HGR_LGTa_MAT_1a
        tempMaterial = headGearPackageName $ "." $ sharedPrefix $ "_MAT_" $ materialVariant + 1 $ class'Amm_Utilities'.static.GetLetter(i);
        helmetMeshPaths.materialPaths.AddItem(tempMaterial);
    }
	return true;
}
