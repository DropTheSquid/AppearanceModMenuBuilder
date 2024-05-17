class AMM_Utilities extends Object;

struct AppearanceMeshPaths
{
	var string MeshPath;
	var Array<string> MaterialPaths;
};
struct AppearanceMesh
{
    var SkeletalMesh Mesh;
    var array<MaterialInterface> Materials;
};
struct pawnAppearance
{
    var AppearanceMesh bodyMesh;
    var AppearanceMesh HelmetMesh;
    var AppearanceMesh VisorMesh;
    var AppearanceMesh BreatherMesh;
	var bool hideHair;
    var bool hideHead;
};

struct SpecLists
{
	var OutfitSpecListBase outfitSpecs;
	var HelmetSpecListBase helmetSpecs;
	var BreatherSpecListBase breatherSpecs;
};

public static function SpecLists GetSpecLists(BioPawn target, AMM_Pawn_Parameters params)
{
	local SpecLists lists;

	lists.outfitSpecs = OutfitSpecListBase(params.GetOutfitSpecList(target));
	lists.helmetSpecs = HelmetSpecListBase(params.GetHelmetSpecList(target));
	lists.breatherSpecs = BreatherSpecListBase(params.GetBreatherSpecList(target));

	return lists;
}

public static function BioPawnType GetPawnType(BioPawn targetPawn)
{
    local BioPawnType pawnType;
    
    pawnType = BioPawnType(targetPawn.ActorType);
    if (pawnType == None)
    {
        pawnType = BioPawnType(targetPawn.m_oBehavior.m_oActorType);
    }
    return pawnType;
}

public static function bool IsPawnArmorAppearanceOverridden(BioPawn targetPawn)
{
    local BioPawnType pawnType;
    
    pawnType = GetPawnType(targetPawn);
    if (pawnType == None)
    {
        LogInternal("Why does this pawn not have a pawnType???" @ PathName(targetPawn), );
        return FALSE;
    }
    // this is nasty, but basically, the first is the 'default' behavior of this pawn, such as true for most NPCs on the Normandy (except the ones that are inexplicably broken)
    // The second is overridden occasionally to put Shepard in casual clothes on the Normandy, as well as squadmates and Shep in Casual Hubs
    // If either is set to true, consider it overridden
    return pawnType.m_bIsArmorOverridden || targetPawn.m_oBehavior.m_bArmorOverridden;
}

public static function UpdatePawnMaterialParameters(BioPawn targetPawn)
{
    local MaterialInterface Mat;
    local MaterialInstanceConstant MIC;
    local VectorParameterValue vectorParam;
    local ScalarParameterValue scalParam;
    local TextureParameterValue texParam;
    local int i;
    local ColorParameter colorParam;
    local ScalarParameter scalParam2;
    local TextureParameter texParam2;
    local BioMorphFace morphFace;
    
    EnsureMICs(targetPawn);
    morphFace = GetMorphHead(targetPawn);
    if (morphFace != None)
    {
        foreach morphFace.m_oMaterialOverrides.m_aColorOverrides(colorParam, )
        {
            vectorParam.ParameterName = colorParam.nName;
            vectorParam.ParameterValue = colorParam.cValue;
            ApplyVectorParameterToAllMICs(vectorParam, targetPawn);
        }
        foreach morphFace.m_oMaterialOverrides.m_aScalarOverrides(scalParam2, )
        {
            scalParam.ParameterName = scalParam2.nName;
            scalParam.ParameterValue = scalParam2.sValue;
            ApplyScalarParameterToAllMICs(scalParam, targetPawn);
        }
        foreach morphFace.m_oMaterialOverrides.m_aTextureOverrides(texParam2, )
        {
            texParam.ParameterName = texParam2.nName;
            texParam.ParameterValue = texParam2.m_pTexture;
            ApplyTextureParameterToAllMICs(texParam, targetPawn);
        }
    }
    else
    {
        ApplyHeadMaterialsToBody(targetPawn);
    }
}

public static function BioMorphFace GetMorphHead(BioPawn targetPawn)
{
    local BioMorphFace morphFace;
    local BioPawnType pawnType;
    
    morphFace = targetPawn.m_oBehavior.m_oAppearanceType.m_oMorphFace;
    if (morphFace == None)
    {
        pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
        if (pawnType != None)
        {
            morphFace = pawnType.m_oMorphFace;
        }
    }
    return morphFace;
}

private static final function EnsureMICs(BioPawn targetPawn)
{
    local SkeletalMeshComponent MeshCmpt;
    local int MaterialIndex;
    local MaterialInterface CurrentMaterial;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', MeshCmpt)
    {
        if (MeshCmpt != None)
        {
            for (MaterialIndex = 0; MaterialIndex < MeshCmpt.GetNumElements(); MaterialIndex++)
            {
                // GetBaseMaterial returns from SMC Materials array or falls back to SM material
                CurrentMaterial = MeshCmpt.GetBaseMaterial(MaterialIndex);
                if (CurrentMaterial != None)
                {
                    if (CurrentMaterial.Outer == targetPawn)
                    {
                        MIC = MaterialInstanceConstant(CurrentMaterial);
                    }
                    else
                    {
                        MIC = None;
                    }
                    if (MIC == None)
                    {
                        MIC = new (targetPawn) Class'MaterialInstanceConstant';
                        if (MIC != None)
                        {
                            MIC.SetParent(CurrentMaterial);
                            MeshCmpt.SetMaterial(MaterialIndex, MIC);
                        }
                    }
                }
            }
        }
    }
}
private static final function ApplyHeadMaterialsToBody(BioPawn targetPawn)
{
    local int i;
    local LinearColor skinTone;
    local bool skinToneSet;
    local LinearColor SkinLightScattering;
    local bool skinLightScatteringSet;
    local MaterialInstanceConstant MIC;
    local VectorParameterValue vect;
    
    if (targetPawn.m_oHeadMesh == None)
    {
        return;
    }
    for (i = 0; i < targetPawn.m_oHeadMesh.GetNumElements(); i++)
    {
        MIC = MaterialInstanceConstant(targetPawn.m_oHeadMesh.GetBaseMaterial(i));
        if (MIC != None)
        {
            if (!skinToneSet && MIC.GetVectorParameterValue('skinTone', skinTone))
            {
                skinToneSet = TRUE;
            }
            if (!skinLightScatteringSet && MIC.GetVectorParameterValue('SkinLightScattering', SkinLightScattering))
            {
                skinLightScatteringSet = TRUE;
            }
        }
    }
    if (skinToneSet)
    {
        vect.ParameterName = 'skinTone';
        vect.ParameterValue = skinTone;
        ApplyVectorParameterToAllMICs(vect, targetPawn);
    }
    if (skinLightScatteringSet)
    {
        vect.ParameterName = 'SkinLightScattering';
        vect.ParameterValue = SkinLightScattering;
        ApplyVectorParameterToAllMICs(vect, targetPawn);
    }
}
private static final function ApplyVectorParameterToAllMICs(VectorParameterValue vect, BioPawn targetPawn)
{
    local SkeletalMeshComponent smc;
    local int i;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', smc)
    {
        if (smc != targetPawn.Mesh && FALSE)
        {
            continue;
        }
        if (smc != None)
        {
            for (i = 0; i < smc.GetNumElements(); i++)
            {
                MIC = MaterialInstanceConstant(smc.GetBaseMaterial(i));
                if (MIC != None)
                {
                    MIC.SetVectorParameterValue(vect.ParameterName, vect.ParameterValue);
                }
            }
        }
    }
}
private static final function ApplyScalarParameterToAllMICs(ScalarParameterValue scal, BioPawn targetPawn)
{
    local SkeletalMeshComponent smc;
    local int i;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', smc)
    {
        if (smc != targetPawn.Mesh && FALSE)
        {
            continue;
        }
        if (smc != None)
        {
            for (i = 0; i < smc.GetNumElements(); i++)
            {
                MIC = MaterialInstanceConstant(smc.GetBaseMaterial(i));
                if (MIC != None)
                {
                    MIC.SetScalarParameterValue(scal.ParameterName, scal.ParameterValue);
                }
            }
        }
    }
}
private static final function ApplyTextureParameterToAllMICs(TextureParameterValue tex, BioPawn targetPawn)
{
    local SkeletalMeshComponent smc;
    local int i;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', smc)
    {
        if (smc != targetPawn.Mesh && FALSE)
        {
            continue;
        }
        if (smc != None)
        {
            for (i = 0; i < smc.GetNumElements(); i++)
            {
                MIC = MaterialInstanceConstant(smc.GetBaseMaterial(i));
                if (MIC != None)
                {
                    MIC.SetTextureParameterValue(tex.ParameterName, tex.ParameterValue);
                }
            }
        }
    }
}

public static function bool LoadAppearanceMesh(AppearanceMeshPaths meshPaths, out AppearanceMesh AppearanceMesh, optional bool allowNone = false)
{
	if (class'AMM_Utilities'.static.LoadSkeletalMesh(meshPaths.meshPath, AppearanceMesh.Mesh, allowNone)
		&& class'AMM_Utilities'.static.LoadMaterials(meshPaths.MaterialPaths, AppearanceMesh.Materials))
	{
		return true;
	}
	return false;
}

public static function bool LoadSkeletalMesh(string skeletalMeshPath, out SkeletalMesh Mesh, optional bool allowNone = false)
{
	if (allowNone && (skeletalMeshPath == "" || skeletalMeshPath ~= "None"))
	{
		return true;
	}
    Mesh = SkeletalMesh(DynamicLoadObject(skeletalMeshPath, Class'SkeletalMesh'));
    if (Mesh == None)
    {
        LogInternal("WARNING: failed to load mesh" @ skeletalMeshPath, );
        return FALSE;
    }
    return TRUE;
}

public static function bool LoadMaterials(array<string> materialPaths, out array<MaterialInterface> Materials)
{
    local string materialString;
    local MaterialInterface material;
    
    Materials.Length = 0;
    foreach materialPaths(materialString, )
    {
        material = MaterialInterface(DynamicLoadObject(materialString, Class'MaterialInterface'));
        if (material == None)
        {
            LogInternal("WARNING failed to Load material" @ materialString, );
            return FALSE;
        }
        Materials.AddItem(material);
    }
    return TRUE;
}

public static function ApplyPawnAppearance(BioPawn target, pawnAppearance appearance)
{
	replaceMesh(target, target.Mesh, appearance.bodyMesh);
	if (target.m_oHairMesh != None)
    {
		// hide head also implies hiding the hair
        target.m_oHairMesh.SetHidden(appearance.hideHair || appearance.hideHead);
    }
    if (target.m_oHeadMesh != None)
    {
        target.m_oHeadMesh.SetHidden(appearance.hideHead);
    }

	if (target.m_oHeadGearMesh == None)
    {
        target.m_oHeadGearMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oHeadGearMesh.SetParentAnimComponent(target.Mesh);
        target.m_oHeadGearMesh.SetShadowParent(target.Mesh);
        target.m_oHeadGearMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oHeadGearMesh);
    }
	replaceMesh(target, target.m_oHeadGearMesh, appearance.HelmetMesh);
	target.m_oHeadGearMesh.SetHidden(appearance.HelmetMesh.Mesh == None);
	target.m_oHeadGearMesh.CastShadow = appearance.HelmetMesh.Mesh != None;

	if (target.m_oVisorMesh == None)
    {
        target.m_oVisorMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oVisorMesh.SetParentAnimComponent(target.Mesh);
        target.m_oVisorMesh.SetShadowParent(target.Mesh);
        target.m_oVisorMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oVisorMesh);
    }
    replaceMesh(target, target.m_oVisorMesh, appearance.VisorMesh);
    target.m_oVisorMesh.SetHidden(appearance.VisorMesh.Mesh == None);
	target.m_oVisorMesh.CastShadow = appearance.VisorMesh.Mesh != None;

	if (target.m_oFacePlateMesh == None)
    {
        target.m_oFacePlateMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oFacePlateMesh.SetParentAnimComponent(target.Mesh);
        target.m_oFacePlateMesh.SetShadowParent(target.Mesh);
        target.m_oFacePlateMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oFacePlateMesh);
    }
    replaceMesh(target, target.m_oFacePlateMesh, appearance.BreatherMesh);
    target.m_oFacePlateMesh.SetHidden(appearance.BreatherMesh.Mesh == None);
	target.m_oFacePlateMesh.CastShadow = appearance.BreatherMesh.Mesh != None;

	// make sure that skintone matches and headmorph material overrides are applied to all materials
	UpdatePawnMaterialParameters(target);

	// This call is very important to prevent all kinds of weirdness
	// for example bone melting and materials misbehaving, and possibly even crashing
	target.ForceUpdateComponents(FALSE, FALSE);
}

public static function replaceMesh(BioPawn targetPawn, SkeletalMeshComponent smc, AppearanceMesh AppearanceMesh)
{
    local int i;
    local MaterialInstanceConstant MIC;

	if (smc == None)
	{
		return;
	}
    smc.SetSkeletalMesh(AppearanceMesh.Mesh);

	// smc.Materials.Length = AppearanceMesh.Materials.Length;
    for (i = 0; i < AppearanceMesh.Materials.Length; i++)
    {
		// reuse existing MICs when possible; it makes the game much more stable. I am not sure why

		// I need to do this entirely based around the methods I think. idk why, but that's the next thing to try
        MIC = MaterialInstanceConstant(smc.Materials[i]);
        if (MIC != None && MIC.outer == targetPawn)
        {
			MIC.ClearParameterValues();
            MIC.SetParent(AppearanceMesh.Materials[i]);
			// trying to do this even though it should already be there
			smc.SetMaterial(i, MIC);
        }
		else
		{
			// if they do not have a suitable MIC, make one and point it at the right parent.
			MIC = new (targetPawn) Class'BioMaterialInstanceConstant';
			MIC.SetParent(AppearanceMesh.Materials[i]);
			smc.SetMaterial(i, MIC);
		}
	}
}

public static function string GetArmorCode(EBioArmorType armorType)
{
    switch (armorType)
    {
        case EBioArmorType.ARMOR_TYPE_NONE:
            return "NKD";
        case EBioArmorType.ARMOR_TYPE_CLOTHING:
            return "CTH";
        case EBioArmorType.ARMOR_TYPE_LIGHT:
            return "LGT";
        case EBioArmorType.ARMOR_TYPE_MEDIUM:
            return "MED";
        case EBioArmorType.ARMOR_TYPE_HEAVY:
            return "HVY";
        default:
    }
    return "";
}

public static function string GetLetter(int num)
{
    switch (num + 1)
    {
        case 1:
            return "a";
        case 2:
            return "b";
        case 3:
            return "c";
        case 4:
            return "d";
        case 5:
            return "e";
        case 6:
            return "f";
        case 7:
            return "g";
        case 8:
            return "h";
        case 9:
            return "i";
        case 10:
            return "j";
        case 11:
            return "k";
        case 12:
            return "l";
        case 13:
            return "m";
        case 14:
            return "n";
        case 15:
            return "o";
        case 16:
            return "p";
        case 17:
            return "q";
        case 18:
            return "r";
        case 19:
            return "s";
        case 20:
            return "t";
        case 21:
            return "u";
        case 22:
            return "v";
        case 23:
            return "w";
        case 24:
            return "x";
        case 25:
            return "y";
        case 26:
            return "z";
        default:
    }
    return "";
}

public static function GetVanillaVisorMesh(BioPawnType pawnType, out AppearanceMesh visorMesh)
{
	local Array<SkeletalMesh> visorMeshSpecs;
	local Array<MaterialInterface> visorMaterialSpecs;

	visorMeshSpecs = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMesh;
	visorMaterialSpecs = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMaterial;

	if (visorMeshSpecs.Length == 0 || visorMaterialSpecs.Length == 0)
	{
		// this will be the case for Wrex, and is fine and expected
		visorMesh.Mesh = None;
        visorMesh.Materials.Length = 0;
		return;
	}

	// TODO this is an array, I think there can theoretically be more than one visor spec, indexed by a property on the appearance settings
	// but I have never seen it actually used, so I think I am going to ignore it.
	visorMesh.Mesh = visorMeshSpecs[0];
	// similarly, this is an array, but I am not sure if it is for a visor with multiple materials or to index into different visor specs, as above
	// I am going to pretend it only ever deals with a single spec with one material.
	visorMesh.Materials[0] = visorMaterialSpecs[0];
}

public static function eHelmetDisplayState GetHelmetDisplayState(PawnAppearanceIds appearanceIds, BioPawn target)
{
	local BioPawnType pawnType;
	local eHelmetDisplayState forceHelmetState;

	// if the game has an override to breather and we are not ignoring it, use a full breather
	if (ShouldUseForcedBreather(target))
	{
		return eHelmetDisplayState.full;
	}

	if (GetMenuHelmetOverride(target, appearanceIds.m_appearanceSettings.helmetDisplayState, forceHelmetState))
	{
		return forceHelmetState;
	}

	// else use what the player has requested
	return appearanceIds.m_appearanceSettings.helmetDisplayState;
}

private static function bool GetMenuHelmetOverride(BioPawn target, eHelmetDisplayState desiredState, out eHelmetDisplayState result)
{
	local BioSFPanel panel;
	local AMM_AppearanceUpdater updaterInstance;
	local AMM_Pawn_Parameters params;
	local eMenuHelmetOverride menuOverride;

	// if we are not in AMM and working with a UI world pawn, move on
	if (target.GetPackageName() != 'BIOG_UIWORLD' || !class'AMM_AppearanceUpdater'.static.IsInAMM(panel))
	{
		return false;
	}

	updaterInstance = class'AMM_AppearanceUpdater'.static.GetDlcInstance();
	if (updaterInstance == None)
	{
		return false;
	}

	menuOverride = eMenuHelmetOverride(updaterInstance.menuHelmetOverride);

	switch (menuOverride)
	{
		// it is forced to a specific state
		case eMenuHelmetOverride.off:
			result = eHelmetDisplayState.off;
			return true;
		case eMenuHelmetOverride.on:
			result = eHelmetDisplayState.on;
			return true;
		case eMenuHelmetOverride.full:
			result = eHelmetDisplayState.full;
			return true;
		case eMenuHelmetOverride.offOrOn:
			if (desiredState == eHelmetDisplayState.Full)
			{
				result = eHelmetDisplayState.on;
			}
			else
			{
				result = desiredState;
			}
			return true;
		case eMenuHelmetOverride.onOrFull:
			if (desiredState == eHelmetDisplayState.off)
			{
				result = eHelmetDisplayState.on;
			}
			else
			{
				result = desiredState;
			}
			return true;
		case eMenuHelmetOverride.offOrFull:
			if (desiredState == eHelmetDisplayState.on)
			{
				result = eHelmetDisplayState.off;
			}
			else
			{
				result = desiredState;
			}
			return true;
		case eMenuHelmetOverride.unchanged:
		default:
			return false;
	}
}

private static function bool ShouldUseForcedBreather(BioPawn target)
{
	local BioPawnType pawnType;
	local BioInterface_Appearance_Pawn appearance;
	local bool isHeadgearPreferenceOverridden;
	local bool helmetVisible;
	local bool faceplateVisible;
	local BioGlobalVariableTable globalVars;
	local AMM_Pawn_Parameters params;
	local BioSFPanel panel;

	// if this is a preview pawn in AMM, return false; we should ignore forced state there
	if (target.GetPackageName() == 'BIOG_UIWORLD' && class'AMM_AppearanceUpdater'.static.IsInAMM(panel))
	{
		return false;
	}

	if (class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params) && params.bIgnoreForcedHelmet)
	{
		return false;
	}

	// first check if the mod setting lets us override things
	globalVars = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo()).GetGlobalVariables();
	if (globalVars.GetInt(1593) == 1)
	{
		return false;
	}

	pawnType = GetPawnType(target);
	appearance = BioInterface_Appearance_Pawn(target.m_oBehavior.m_oAppearanceType);
	isHeadgearPreferenceOverridden = !target.IsHeadGearVisiblePreferenceRelevant();
	if (!isHeadgearPreferenceOverridden)
	{
		// meaning, in this case, respect the preference set by the player in the Squad record menu
		return false;
	}
	helmetVisible = appearance.m_headGearVisibilityRunTimeOverride.m_a[2].m_bIsVisible;
	faceplateVisible = appearance.m_headGearVisibilityRunTimeOverride.m_a[1].m_bIsVisible;
	// force the breather only if the helmet and faceplate have been forced into visibility
	return helmetVisible && faceplateVisible;
}
