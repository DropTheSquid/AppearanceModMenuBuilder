class AMM_Utilities extends Object;

struct PawnAppearanceIds 
{
	// the id of the spec to use
    var int bodyAppearanceId;
    var int helmetAppearanceId;
    var int breatherAppearanceId;
	var appearanceSettings m_appearanceSettings;
    // various bools which can be encoded in an int for most characters
    struct appearanceSettings
    {
        //TODO override helmet preference, etc
    };
};
enum eGender
{
    Either,
    Male,
    Female,
};
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
        target.m_oHairMesh.SetHidden(appearance.hideHair);
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

	if (target.m_oVisorMesh == None)
    {
        target.m_oVisorMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oVisorMesh.SetParentAnimComponent(target.Mesh);
        target.m_oVisorMesh.SetShadowParent(target.Mesh);
        target.m_oVisorMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oVisorMesh);
    }
    // LogInfo("Setting visor mesh to" @ appearance.VisorMesh.Mesh);
    replaceMesh(target, target.m_oVisorMesh, appearance.VisorMesh);
    target.m_oVisorMesh.SetHidden(appearance.VisorMesh.Mesh == None);

	if (target.m_oFacePlateMesh == None)
    {
        target.m_oFacePlateMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oFacePlateMesh.SetParentAnimComponent(target.Mesh);
        target.m_oFacePlateMesh.SetShadowParent(target.Mesh);
        target.m_oFacePlateMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oFacePlateMesh);
    }
    // LogInfo("Setting faceplate mesh to" @ appearance.FaceplateMesh.Mesh);
    replaceMesh(target, target.m_oFacePlateMesh, appearance.BreatherMesh);
    target.m_oFacePlateMesh.SetHidden(appearance.BreatherMesh.Mesh == None);


	// This call is very important to prevent all kinds of weirdness
	// for example bone melting and materials misbehaving, and possibly even crashing
	target.ForceUpdateComponents(FALSE, FALSE);
}

public static function replaceMesh(BioPawn targetPawn, SkeletalMeshComponent smc, AppearanceMesh AppearanceMesh)
{
    local int i;
    local MaterialInstanceConstant MIC;

	// LogInternal("running ReplaceMesh on pawn"@targetPawn@targetPawn.tag);
	// LogInternal("current mesh"@PathName(smc.SkeletalMesh));
	// LogInternal("Current materials"@smc.GetNumElements()@smc.Materials.Length);
	// for (i = 0; i < smc.GetNumElements(); i++)
	// {
	// 	LogInternal("current material"@i@smc.GetMaterial(i).class@Pathname(smc.GetMaterial(i)));
	// 	LogInternal("by direct access method"@smc.Materials[i]);
	// 	LogInternal("base material?"@smc.GetBaseMaterial(i));
	// 	MIC = MaterialInstanceConstant(smc.GetMaterial(i));
	// 	if (MIC != None)
	// 	{
	// 		LogInternal("MIC parent material"@MIC.Parent.class@Pathname(MIC.Parent));
	// 	}
	// }
	// LogInternal("before:");
	// ProfileSMC(smc);
    
    // LogInternal("replacing mesh on SMC" @ smc @ PathName(smc.SkeletalMesh) @ "With new mesh" @ PathName(AppearanceMesh.Mesh));
	if (smc == None)
	{
		return;
	}
    smc.SetSkeletalMesh(AppearanceMesh.Mesh);

	// LogInternal("intermediate materials"@smc.GetNumElements()@smc.Materials.Length);
	// for (i = 0; i < smc.GetNumElements(); i++)
	// {
	// 	LogInternal("intermediate material"@i@smc.GetMaterial(i).class@Pathname(smc.GetMaterial(i)));
	// 	LogInternal("by direct access method"@smc.Materials[i]);
	// 	LogInternal("base material?"@smc.GetBaseMaterial(i));
	// 	MIC = MaterialInstanceConstant(smc.GetMaterial(i));
	// 	if (MIC != None)
	// 	{
	// 		LogInternal("MIC parent material"@MIC.Parent.class@Pathname(MIC.Parent));
	// 	}
	// }
	// LogInternal("intermediate:");
	// ProfileSMC(smc);

	// smc.Materials.Length = AppearanceMesh.Materials.Length;
    for (i = 0; i < AppearanceMesh.Materials.Length; i++)
    {
		// LogInternal("Setting material"@i@AppearanceMesh.Materials[i]);
		// reuse existing MICs when possible; it makes the game much more stable. I am not sure why

		// I need to do this entirely based around the methods I think. idk why, but that's the next thing to try
        MIC = MaterialInstanceConstant(smc.Materials[i]);
        if (MIC != None && MIC.outer == targetPawn)
        {
			// LogInternal("reusing MIC");
			MIC.ClearParameterValues();
            MIC.SetParent(AppearanceMesh.Materials[i]);
			// trying to do this even though it should already be there
			smc.SetMaterial(i, MIC);
        }
		else
		{
			// LogInternal("creating new MIC");
			// if they do not have a suitable MIC, make one and point it at the right parent.
			MIC = new (targetPawn) Class'BioMaterialInstanceConstant';
			MIC.SetParent(AppearanceMesh.Materials[i]);
			smc.SetMaterial(i, MIC);
		}

		// old code that caused crashes:
		// MIC = new (targetPawn) Class'BioMaterialInstanceConstant';
        // MIC.SetParent(AppearanceMesh.Materials[i]);
        // smc.SetMaterial(i, MIC);
        // if (smc.m_aEffectsMaterialMICs[i] != None)
        // {
        //     smc.m_aEffectsMaterialMICs[i].SetParent(MIC);
        // }
        // if (markAsAMM)
        // {
        //     MIC.SetScalarParameterValue('AppliedByAMM', 1.0);
        // }
    }

	// LogInternal("after:");
	// ProfileSMC(smc);
	// LogInternal("running forceUpdateComponents");
}

public static function bool IsFrameworkInstalled()
{
	return DynamicLoadObject("DLC_MOD_Framework_GlobalTlk.GlobalTlk_tlk", Class'Object') != None;
}

public static function bool DoesLevelExist(coerce string levelName)
{
	return DynamicLoadObject(string(levelName)$".TheWorld", class'World') != None;
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

// private static function ProfileSMC(SkeletalMeshComponent smc)
// {
// 	local int i;

// 	LogInternal("profiling SMC"@pathName(smc));
// 	LogInternal("mesh"@PathName(smc.SkeletalMesh));
// 	LogInternal("materials"@smc.GetNumElements()@smc.Materials.Length);
// 	for (i = 0; i < smc.GetNumElements(); i++)
// 	{
// 		LogInternal("current material"@i@smc.GetMaterial(i).class@Pathname(smc.GetMaterial(i)));
// 		LogInternal("by direct access method"@smc.Materials[i]);
// 		LogInternal("base material?"@smc.GetBaseMaterial(i));
// 		ProfileMaterialInterface(smc.GetMaterial(i));
// 	}
// }

// private static function ProfileMaterialInterface(MaterialInterface mat)
// {
// 	local MaterialInstance MI;

// 	LogInternal("profiling material"@mat.class@pathname(mat));
// 	LogInternal("GetMaterial"@mat.GetMaterial().class@PathName(mat.GetMaterial()));
// 	MI = MaterialInstance(mat);
// 	if (MI != None)
// 	{
// 		LogInternal("profiling parent");
// 		ProfileMaterialInterface(MI.parent);
// 	}
// }