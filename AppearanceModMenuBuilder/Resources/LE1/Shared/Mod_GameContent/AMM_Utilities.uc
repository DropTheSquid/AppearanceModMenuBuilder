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
    var AppearanceMesh FaceplateMesh;
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

public static function bool LoadAppearanceMesh(AppearanceMeshPaths meshPaths, out AppearanceMesh AppearanceMesh)
{
	if (class'AMM_Utilities'.static.LoadSkeletalMesh(meshPaths.meshPath, AppearanceMesh.Mesh)
		&& class'AMM_Utilities'.static.LoadMaterials(meshPaths.MaterialPaths, AppearanceMesh.Materials))
	{
		return true;
	}
	return false;
}

public static function bool LoadSkeletalMesh(string skeletalMeshPath, out SkeletalMesh Mesh)
{
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
	// TODO handle helmet visibility stuff here
	replaceMesh(target, target.m_oHeadGearMesh, appearance.HelmetMesh);
	replaceMesh(target, target.m_oVisorMesh, appearance.VisorMesh);

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