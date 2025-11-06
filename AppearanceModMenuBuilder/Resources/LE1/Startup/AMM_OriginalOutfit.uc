Class AMM_OriginalOutfit;

var string targetPath;
var Name Tag;
var AppearanceMesh originalBody;
var AppearanceMesh originalHeadgear;
var AppearanceMesh originalVisor;
var AppearanceMesh originalBreather;
var AppearanceMesh lastAppliedBody;
var AppearanceMesh lastAppliedHeadgear;
var AppearanceMesh lastAppliedVisor;
var AppearanceMesh lastAppliedBreather;

public static function StoreOutfit(BioPawn target)
{
    local Name Package;
    local BioWorldInfo localWI;
    local AMM_OriginalOutfit outfit;
    local BioWorldInfo bwi;
    local MemberData tempSquadMember;
    
    // we actually want dynamically spawned pawns like the player and active squadmates to not use this system, as it messes up the whole armor override system
    // and doesn't make sense with dynamically spawned pawns anyway.
    Package = target.GetPackageName();
    if (Package == 'BIOG_UIWorld' || target.Class == Class'SFXPawn_Player')
    {
        return;
    }
    bwi = Class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    foreach bwi.m_playerSquad.Members(tempSquadMember, )
    {
        if (tempSquadMember.SquadMember == target)
        {
            return;
        }
    }
    if (GetOutfit(target, outfit))
    {
        // there is already a record here, but it might need to be updated if something else updated it
        if (!DoesMeshMatch(target.Mesh, outfit.originalBody, outfit.lastAppliedBody))
        {
            outfit.originalBody = SaveMesh(target.Mesh, target);
        }
        if (!DoesMeshMatch(target.m_oHeadGearMesh, outfit.originalHeadgear, outfit.lastAppliedHeadgear))
        {
            outfit.originalHeadgear = SaveMesh(target.m_oHeadGearMesh, target);
        }
        if (!DoesMeshMatch(target.m_oVisorMesh, outfit.originalVisor, outfit.lastAppliedVisor))
        {
            outfit.originalVisor = SaveMesh(target.m_oVisorMesh, target);
        }
        if (!DoesMeshMatch(target.m_oFacePlateMesh, outfit.originalBreather, outfit.lastAppliedBreather))
        {
            outfit.originalBreather = SaveMesh(target.m_oFacePlateMesh, target);
        }
        return;
    }
    localWI = BioWorldInfo(FindObject(Package $ ".TheWorld.PersistentLevel.BioWorldInfo_0", Class'BioWorldInfo'));
    if (localWI != None)
    {
        outfit = new Class'AMM_OriginalOutfit';
        outfit.targetPath = PathName(target);
        outfit.Tag = target.Tag;
        // save all the meshes AMM might overwrite
        outfit.originalBody = SaveMesh(target.Mesh, target);
        outfit.originalHeadgear = SaveMesh(target.m_oHeadGearMesh, target);
        outfit.originalVisor = SaveMesh(target.m_oVisorMesh, target);
        outfit.originalBreather = SaveMesh(target.m_oFacePlateMesh, target);
        // save this in a place where we can find it again but we are not holding a reference that will break things, and it will go out of memory at the same time as the pawn
        localWI.ClientDestroyedActorContent.InsertItem(0, outfit);
    }
}
private static function bool DoesMeshMatch(SkeletalMeshComponent smc, AppearanceMesh originalMesh, AppearanceMesh lastAppliedMesh)
{
    if (smc.SkeletalMesh != originalMesh.Mesh || smc.SkeletalMesh != lastAppliedMesh.Mesh)
    {
        return false;
    }
    // TODO check for materials matching as well
    return true;
}
public static final function AppearanceMesh SaveMesh(SkeletalMeshComponent smc, BioPawn target)
{
    local AppearanceMesh savedMesh;
    local MaterialInterface mat;
    local int i;
    
    savedMesh.Mesh = smc.SkeletalMesh;
    // get materials until we get a None material. this should deal with incorrectly set up SMCs and get the materials from the skeletal mesh itself. 
    for (i = 0; TRUE; i++)
    {
        mat = smc.GetBaseMaterial(i);
        if (mat == None)
        {
            break;
        }
        savedMesh.Materials.AddItem(CleanMat(mat, target, smc));
    }
    return savedMesh;
}
private static final function MaterialInterface CleanMat(MaterialInterface mat, BioPawn target, SkeletalMeshComponent smc)
{
    local MaterialInstanceConstant mic;
    local MaterialInstanceConstant newMIC;
    
    // if we save a material that has the target as the outer, it'll get cleared and recycled
    // so instead we make a new mat with the same parent and params and save that
    mic = MaterialInstanceConstant(mat);
    if (mic == None || (mic.Outer != target && mic.outer != smc))
    {
        return mat;
    }
    newMIC = new Class'MaterialInstanceConstant';
    newMIC.SetParent(mic.parent);
    newMIC.VectorParameterValues = mic.VectorParameterValues;
    newMIC.ScalarParameterValues = mic.ScalarParameterValues;
    newMIC.TextureParameterValues = mic.TextureParameterValues;
    return newMIC;
}
public static function bool GetOutfit(BioPawn target, out AMM_OriginalOutfit outfit)
{
    local Name Package;
    local BioWorldInfo localWI;
    local Object obj;
    local string localTargetPath;
    
    Package = target.GetPackageName();
    localTargetPath = PathName(target);
    if (Package == 'BIOG_UIWorld')
    {
        Package = target.UniqueTag;
        localTargetPath = "";
    }
    localWI = BioWorldInfo(FindObject(Package $ ".TheWorld.PersistentLevel.BioWorldInfo_0", Class'BioWorldInfo'));
    if (localWI != None)
    {
        foreach localWI.ClientDestroyedActorContent(obj, )
        {
            outfit = AMM_OriginalOutfit(obj);
            if (outfit != None)
            {
                if (localTargetPath != "")
                {
                    if (outfit.targetPath == localTargetPath)
                    {
                        return TRUE;
                    }
                    else
                    {
                        continue;
                    }
                }
                else if (outfit.Tag == target.Tag)
                {
                    return TRUE;
                }
                else
                {
                    continue;
                }
            }
        }
    }
    return FALSE;
}