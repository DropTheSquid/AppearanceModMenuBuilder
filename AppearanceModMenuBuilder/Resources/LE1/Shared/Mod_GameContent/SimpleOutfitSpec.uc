class SimpleOutfitSpec extends OutfitSpecBase;

var AppearanceMeshPaths BodyMesh;

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