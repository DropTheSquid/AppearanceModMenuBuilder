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

	// this is for equipping their vanilla outfit
	// we will determine what outfit it should be based on the pawn's settings and then apply it
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

	appearance.hideHair = appearance.hideHair || hideHair;
	appearance.hideHead = appearance.hideHead || hideHead;

	// load the helmet mesh
	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(helmetMeshPaths, appearance.HelmetMesh, true))
	{
		return false;
	}

	// if the visor is not suppressed, get the visor mesh
	if (!suppressVisor)
	{
		class'AMM_Utilities'.static.GetVanillaVisorMesh(class'AMM_Utilities'.static.GetPawnType(target), appearance.VisorMesh);
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
		specLists.breatherSpecs.DelegateToBreatherSpec(target, specLists, appearanceIds, appearance);
	}
	
	return true;
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
    suppressVisor = modelSpec.m_bSuppressVisor;
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


// public function bool GetPawnOutfitMeshes(PawnAppearanceIds AppearanceIds, BioPawn targetPawn, AMM_Pawn_Parameters pawnParams, appearanceFlagState helmetOverrideState, out PawnOutfitMeshes PawnOutfitMeshes)
// {
//     local BioInterface_Appearance_Pawn appearance;
//     local BioPawnType pawnType;
//     local bool headgearVisibilityPreference;
//     local bool isHeadgearPreferenceOverridden;
//     local bool ShouldShowHelmet;
//     local bool ShouldShowVisor;
//     local bool ShouldShowFaceplate;
    
//     pawnType = Class'PawnUtilities'.static.GetPawnType(targetPawn);
//     appearance = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType);
//     isHeadgearPreferenceOverridden = !targetPawn.IsHeadGearVisiblePreferenceRelevant();
//     if (helmetOverrideState.state == ehelmetState.off)
//     {
//         ShouldShowHelmet = FALSE;
//         ShouldShowVisor = FALSE;
//         ShouldShowFaceplate = FALSE;
//     }
//     else if (helmetOverrideState.state == ehelmetState.on || AppearanceIds.breatherAppearanceId == -2)
//     {
//         ShouldShowHelmet = TRUE;
//         ShouldShowVisor = !pawnType.m_oAppearanceSettings.m_oBodySettings.m_oHeadGearSettings.m_visor.m_bIsHidden;
//         ShouldShowFaceplate = FALSE;
//     }
//     else
//     {
//         ShouldShowHelmet = TRUE;
//         ShouldShowVisor = !pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_aFacePlateMeshSpec[0].m_bHidesVisor;
//         ShouldShowFaceplate = TRUE;
//     }
//     LogInternal("Getting vanilla headgear", );
//     LogInternal("shouldShowHelmet" @ ShouldShowHelmet, );
//     LogInternal("ShouldShowVisor" @ ShouldShowVisor, );
//     LogInternal("ShouldShowFaceplate" @ ShouldShowFaceplate, );
//     if (!ShouldShowHelmet)
//     {
//         // comment("delegate to the no helmet spec");
//         AppearanceIds.helmetAppearanceId = -2;
//         return Class'HelmetSpecBase'.static.GetMeshesFromHelmetSpec(AppearanceIds, targetPawn, pawnParams, helmetOverrideState, PawnOutfitMeshes);
//     }
//     GetHeadGearMeshes(targetPawn, AppearanceIds, pawnParams, helmetOverrideState, ShouldShowHelmet, ShouldShowVisor, ShouldShowFaceplate, PawnOutfitMeshes);
//     return TRUE;
// }
// public static function bool GetHeadGearMeshes(BioPawn target, PawnAppearanceIds AppearanceIds, AMM_Pawn_Parameters pawnParams, appearanceFlagState helmetOverrideState, bool showHelmet, bool showVisor, bool showFaceplate, out PawnOutfitMeshes PawnOutfitMeshes)
// {
//     local BioPawnType pawnType;
//     local int armorType;
//     local int meshVariant;
//     local int materialVariant;
//     local bool suppressVisor;
//     local bool suppressFacePlate;
    
//     pawnType = Class'PawnUtilities'.static.GetPawnType(target);
//     if (pawnType == None)
//     {
//         Warn("Pawn" @ PathName(target) @ target.Tag @ "does not have a pawnType, so I cannot get the headgear.");
//         return FALSE;
//     }
//     if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_oHeadGearSettings == None)
//     {
//         Warn("Pawn has no Helmet settings");
//         return FALSE;
//     }
//     armorType = int(BioInterface_Appearance_Pawn(target.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_eArmorType);
//     meshVariant = BioInterface_Appearance_Pawn(target.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nModelVariant;
//     materialVariant = BioInterface_Appearance_Pawn(target.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nMaterialConfig;
//     if (!GetHelmetMesh(pawnType, armorType, meshVariant, materialVariant, PawnOutfitMeshes, suppressVisor, suppressFacePlate))
//     {
//         return FALSE;
//     }
//     if (showVisor && !suppressVisor || showFaceplate && !suppressFacePlate)
//     {
//         GetVisorMesh(pawnType, PawnOutfitMeshes.VisorMesh.Mesh, PawnOutfitMeshes.VisorMesh.Materials);
//     }
//     if (showFaceplate && !suppressFacePlate)
//     {
//         return Class'BreatherSpecBase'.static.GetBreatherMeshesFromSpec(AppearanceIds, target, pawnParams, helmetOverrideState, PawnOutfitMeshes);
//     }
//     return TRUE;
// }
// private static final function bool GetHelmetMeshPaths(BioPawnType pawnType, int armorType, int meshVariant, int materialVariant, out PawnOutfitMeshes PawnOutfitMeshes, out bool suppressVisor, out bool suppressFacePlate)
// {
//     local BioHeadGearAppearanceArmorSpec armorTypeSpec;
//     local BioHeadGearAppearanceModelSpec modelSpec;
//     local string headGearPackageName;
//     local string modelCode;
//     local string prefix;
//     local string tempMaterial;
//     local int i;
//     local int numMaterials;
//     local string meshPath;
//     local array<string> materialPaths;
    
//     if (pawnType.m_oAppearance.Body.m_oHeadGearAppearance == None)
//     {
//         return FALSE;
//     }
//     armorTypeSpec = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_aArmorSpec[armorType];
//     headGearPackageName = string(armorTypeSpec.m_nmPackage);
//     if (headGearPackageName == "None")
//     {
//         // comment("this is completely expected for nkd and clothes armor levels, where there is no package of headgear.");
//         suppressVisor = TRUE;
//         suppressFacePlate = TRUE;
//         return TRUE;
//     }
//     modelSpec = armorTypeSpec.m_aModelSpec[meshVariant];
//     PawnOutfitMeshes.hideHair = modelSpec.m_bIsHairHidden;
//     PawnOutfitMeshes.hideHead = modelSpec.m_bIsHeadHidden;
//     suppressVisor = modelSpec.m_bSuppressVisor;
//     suppressFacePlate = modelSpec.m_bSuppressFacePlate;
//     modelCode = class'Amm_Utilities'.static.GetArmorCode(byte(armorType)) $ class'Amm_Utilities'.static.GetLetter(meshVariant);
//     prefix = string(pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_nmPrefix);
//     meshPath = headGearPackageName $ "." $ modelCode $ "." $ prefix $ "_" $ modelCode $ "_MDL";
//     numMaterials = modelSpec.m_nMaterialCountPerConfig;
//     for (i = 0; i < numMaterials; i++)
//     {
//         tempMaterial = headGearPackageName $ "." $ modelCode $ "." $ prefix $ "_" $ modelCode $ "_MAT_" $ materialVariant + 1 $ GetLetter(i);
//         materialPaths.AddItem(tempMaterial);
//     }
//     // if (!Class'PawnUtilities'.static.LoadSkeletalMesh(meshPath, PawnOutfitMeshes.HelmetMesh.Mesh))
//     // {
//     //     return FALSE;
//     // }
//     // if (!Class'PawnUtilities'.static.LoadMaterials(materialPaths, PawnOutfitMeshes.HelmetMesh.Materials))
//     // {
//     //     return FALSE;
//     // }
//     return TRUE;
// }
// private static final function bool GetVisorMesh(BioPawnType pawnType, out SkeletalMesh VisorMesh, out array<MaterialInterface> Materials)
// {
//     if (pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMesh.Length == 0 || pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMaterial.Length == 0)
//     {
//         VisorMesh = None;
//         Materials.Length = 0;
//         return TRUE;
//     }
//     VisorMesh = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMesh[0];
//     Materials = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMaterial;
//     return TRUE;
// }
