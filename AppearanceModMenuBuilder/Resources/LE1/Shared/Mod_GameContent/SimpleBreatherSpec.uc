class SimpleBreatherSpec extends BreatherSpecBase;

// the main breather mesh
var AppearanceMeshPaths BreatherMesh;
// you can apply a different visor mesh or provide it even if the helmet spec didn't provide one/suppressed it
var AppearanceMeshPaths OverrideVisorMesh;
// you can suppress the visor as part of applying the breather
var bool bSuppressVisor;
// it can hide the head or hair
var bool bHideHair;
var bool bHideHead;

public function bool LoadBreather(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(BreatherMesh, appearance.breatherMesh))
	{
		return false;
	}
	if (OverrideVisorMesh.meshPath != "" && !bSuppressVisor)
	{
		if (!class'AMM_Utilities'.static.LoadAppearanceMesh(OverrideVisorMesh, appearance.visorMesh))
		{
			return false;
		}
	}
	else if (bSuppressVisor)
	{
		appearance.VisorMesh.Mesh = None;
		appearance.VisorMesh.Materials.Length = 0;
	}
	appearance.hideHair = appearance.hideHair || bHideHair;
	appearance.hideHead = appearance.hideHead || bHideHead;
	return true;
}