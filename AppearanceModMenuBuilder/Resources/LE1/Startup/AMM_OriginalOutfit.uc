Class AMM_OriginalOutfit;

var string targetPath;
var SkeletalMesh originalSkeletalMesh;
var array<MaterialInterface> originalMaterials;

public static function StoreOutfit(BioPawn target)
{
    local Name Package;
    local BioWorldInfo localWI;
    local AMM_OriginalOutfit outfit;
    local MaterialInterface mat;
    local int i;
    
    if (GetOutfit(target, outfit))
    {
        // TODO store an updated outfit here in some cases?
        return;
    }
    Package = target.GetPackageName();
    localWI = BioWorldInfo(FindObject(Package $ ".TheWorld.PersistentLevel.BioWorldInfo_0", Class'BioWorldInfo'));
    if (localWI != None)
    {
        outfit = new Class'AMM_OriginalOutfit';
        outfit.targetPath = PathName(target);
        outfit.originalSkeletalMesh = target.Mesh.SkeletalMesh;
        i = 0;
        // get materials until we get a None material. this should deal with incorrectly set up SMCs and get the materials from the skeletal mesh itself. 
        //LogInternal("mat" @ i @ target.Mesh.GetMaterial(i) @ target.Mesh.GetBaseMaterial(i) @ target.Mesh.Materials[i], );
        for (; TRUE; i++)
        {
            mat = target.Mesh.GetBaseMaterial(i);
            if (mat == None)
            {
                break;
            }
            outfit.originalMaterials.AddItem(CleanMat(mat, target));
        }
        // LogInternal("saving original mesh for actor" @ PathName(target) @ outfit.originalSkeletalMesh @ outfit.originalMaterials.Length, );
        localWI.ClientDestroyedActorContent.InsertItem(0, outfit);
    }
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
    
    Package = target.GetPackageName();
    localWI = BioWorldInfo(FindObject(Package $ ".TheWorld.PersistentLevel.BioWorldInfo_0", Class'BioWorldInfo'));
    if (localWI != None)
    {
        foreach localWI.ClientDestroyedActorContent(obj, )
        {
            outfit = AMM_OriginalOutfit(obj);
            if (outfit != None && outfit.targetPath == PathName(target))
            {
                return TRUE;
            }
        }
    }
    return FALSE;
}