class SimpleHelmetSpec extends HelmetSpecBase;

var AppearanceMeshPaths HelmetMesh;
var AppearanceMeshPaths VisorMesh;
var bool bSuppressVisor;
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eHelmetDisplayState helmetDisplayState;

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(HelmetMesh, appearance.helmetMesh))
	{
		return false;
	}
	if (VisorMesh.meshPath != "" && !bSuppressVisor)
	{
		if (!class'AMM_Utilities'.static.LoadAppearanceMesh(VisorMesh, appearance.visorMesh))
		{
			return false;
		}
	}
	appearance.hideHair = appearance.hideHair || bHideHair;
	appearance.hideHead = appearance.hideHead || bHideHead;

	// if we should display a breather and it is not suppressed for this helmet, delegate to the breather spec
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	if (!bSuppressBreather && helmetDisplayState == eHelmetDisplayState.full)
	{
		specLists.breatherSpecs.DelegateToBreatherSpec(target, specLists, appearanceIds, appearance);
	}
	return true;
}