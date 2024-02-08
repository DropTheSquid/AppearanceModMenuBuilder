class SimpleOutfitSpec extends OutfitSpecBase;

var string meshPath;
var array<string> meshMaterialPaths;

public function bool ApplyOutfit(BioPawn target)
{
	local AppearanceMesh appearanceMesh;

	class'AMM_Utilities'.static.LoadSkeletalMesh(meshPath, AppearanceMesh.Mesh);
	class'AMM_Utilities'.static.LoadMaterials(meshMaterialPaths, AppearanceMesh.Materials);
	class'AMM_Utilities'.static.ReplaceMesh(target, target.Mesh, AppearanceMesh);

	return true;
}