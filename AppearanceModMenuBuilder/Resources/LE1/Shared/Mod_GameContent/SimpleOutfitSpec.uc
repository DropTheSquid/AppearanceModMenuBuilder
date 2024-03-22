class SimpleOutfitSpec extends OutfitSpecBase;

var AppearanceMeshPaths BodyMesh;
var bool bSuppressHelmet;
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;
var int helmetTypeOverride;

public function bool ApplyOutfit(BioPawn target)
{
	local AppearanceMesh appearanceMesh;

	if (class'AMM_Utilities'.static.LoadSkeletalMesh(BodyMesh.meshPath, AppearanceMesh.Mesh)
		&& class'AMM_Utilities'.static.LoadMaterials(BodyMesh.MaterialPaths, AppearanceMesh.Materials))
	{
		class'AMM_Utilities'.static.ReplaceMesh(target, target.Mesh, AppearanceMesh);
		return true;
	}

	return false;
}