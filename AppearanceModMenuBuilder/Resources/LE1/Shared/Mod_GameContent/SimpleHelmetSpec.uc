class SimpleHelmetSpec extends HelmetSpecBase;

var AppearanceMeshPaths HelmetMesh;
var AppearanceMeshPaths VisorMesh;
var bool bSuppressVisor;
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(HelmetMesh, appearance.helmetMesh))
	{
		LogInternal("failed to load helmet mesh"@HelmetMesh.MeshPath);
		return false;
	}
	if (VisorMesh.meshPath != "" && !bSuppressVisor)
	{
		if (!class'AMM_Utilities'.static.LoadAppearanceMesh(VisorMesh, appearance.visorMesh))
		{
			LogInternal("failed to load visor mesh"@VisorMesh.MeshPath);
			return false;
		}
	}
	appearance.hideHair = bHideHair;
	appearance.hideHead = bHideHead;
	// TODO load in a breather if it is not suppressed here
	return true;
}