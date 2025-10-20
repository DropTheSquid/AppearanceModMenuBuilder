Class AMM_OriginalOutfit;

var string targetPath;
var Name Tag;
var AppearanceMesh originalBody;
var AppearanceMesh originalHeadgear;
var AppearanceMesh originalVisor;
var AppearanceMesh originalBreather;

public static function StoreOutfit(BioPawn target)
{
    local Name Package;
    local BioWorldInfo localWI;
    local AMM_OriginalOutfit outfit;
    local BioWorldInfo bwi;
    local MemberData tempsquadMember;
    
    // we actually want dynamically spawned pawns like the player and active squadmates to not use this system, as it messes up the whole armor override system
    // and doesn't make sense with dynamically spawned pawns anyway.
    Package = target.GetPackageName();
    if (Package == 'BIOG_UIWorld' || target.Class == Class'SFXPawn_Player')
    {
        return;
    }
    bwi = Class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    foreach bwi.m_playerSquad.Members(tempsquadMember, )
    {
        if (tempsquadMember.SquadMember == target)
        {
            return;
        }
    }
    if (GetOutfit(target, outfit))
    {
        // TODO store an updated outfit here in some cases?
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
        localWI.ClientDestroyedActorContent.InsertItem(0, outfit);
    }
}
private static final function AppearanceMesh SaveMesh(SkeletalMeshComponent smc, BioPawn target)
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
        savedMesh.Materials.AddItem(CleanMat(mat, target));
    }
    return savedMesh;
}
private static final function MaterialInterface CleanMat(MaterialInterface mat, BioPawn target)
{
    local MaterialInstanceConstant mic;
    local MaterialInstanceConstant newMIC;
    
    // if we save a material that has the target as the outer, it'll get cleared and recycled
    // so instead we make a new mat with the same parent and params and save that
    mic = MaterialInstanceConstant(mat);
    if (mic == None || mic.Outer != target)
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

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}