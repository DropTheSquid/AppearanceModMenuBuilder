class AMM_Utilities extends Object;

enum eGender
{
    Either,
    Male,
    Female,
};
struct AppearanceMesh 
{
    var SkeletalMesh Mesh;
    var array<MaterialInterface> Materials;
    
    structdefaultproperties
    {
        Materials = ()
    }
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
    // If either is set to true, consider it casual
    return pawnType.m_bIsArmorOverridden || targetPawn.m_oBehavior.m_bArmorOverridden;
}

public static function bool LoadSkeletalMesh(string skeletalMeshPath, out SkeletalMesh Mesh)
{
    Mesh = SkeletalMesh(DynamicLoadObject(skeletalMeshPath, Class'SkeletalMesh'));
    if (Mesh == None)
    {
        LogInternal("WARNING failed to load mesh" @ skeletalMeshPath, );
        return FALSE;
    }
    LogInternal("Loaded mesh" @ Mesh, );
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
        LogInternal("Loaded material" @ material, );
        Materials.AddItem(material);
    }
    return TRUE;
}

public static function replaceMesh(BioPawn targetPawn, SkeletalMeshComponent smc, AppearanceMesh AppearanceMesh, optional bool markAsAMM = TRUE)
{
    local int i;
    local MaterialInstanceConstant MIC;
    
    LogInternal("replacing mesh on SMC" @ smc @ PathName(smc.SkeletalMesh) @ "With new mesh" @ PathName(AppearanceMesh.Mesh));
	if (smc == None)
	{
		LogInternal("why is the smc None?"@targetPawn);
		return;
	}
    smc.SetSkeletalMesh(AppearanceMesh.Mesh);
	smc.Materials.Length = AppearanceMesh.Materials.Length;
    for (i = 0; i < AppearanceMesh.Materials.Length; i++)
    {
		// by reusing the smc, I avoid creating a new one or needing to call SetMaterial, which seems to be the really problematic part
		// however, this does mean the params stay, so if they had a skintone, it carries over. This will cause problems. 
		// I could clear all params I suppose. 
		// also I should make sure this is behaving how I think it is; for example, is Kirahhe green because MIC is none? I don't think so, but gotta make sure
		// For characters that actually have any params on their MICs, I need to cache that stuff somehow so I can restore it later. 
		// maybe I do that at the same time I pull stuff off?
		// could save a list of params by pawn path, and periodically purge the cache if they are no longer in memory
		// and this gets used to restore if we turn them back to vanilla later. 
		// this could work
        MIC = MaterialInstanceConstant(smc.Materials[i]);
        if (MIC != None)
        {
			MIC.ClearParameterValues();
            MIC.SetParent(AppearanceMesh.Materials[i]);
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
}