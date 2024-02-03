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
    smc.SetSkeletalMesh(AppearanceMesh.Mesh);
    for (i = 0; i < AppearanceMesh.Materials.Length; i++)
    {
        MIC = new (targetPawn) Class'BioMaterialInstanceConstant';
        MIC.SetParent(AppearanceMesh.Materials[i]);
        smc.SetMaterial(i, MIC);
        if (smc.m_aEffectsMaterialMICs[i] != None)
        {
            smc.m_aEffectsMaterialMICs[i].SetParent(MIC);
        }
        if (markAsAMM)
        {
            MIC.SetScalarParameterValue('AppliedByAMM', 1.0);
        }
    }
}