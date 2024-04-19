class SimpleOutfitSpec extends OutfitSpecBase;

var AppearanceMeshPaths BodyMesh;
var bool bSuppressHelmet;
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;
var int helmetTypeOverride;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eHelmetDisplayState helmetDisplayState;

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(BodyMesh, appearance.bodyMesh))
	{
		return false;
	}

	appearance.hideHair = bHideHair;
	appearance.hideHead = bHideHead;

	// get whether we should display the helmet based on a variety of factors
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	if (helmetDisplayState == eHelmetDisplayState.off)
	{
		// NoHelmetSpec
		appearanceIds.helmetAppearanceId = -2;
	}
	// if we should display some kind of helmet, check if we should use the default one for this outfit
	// if the helmet id is 0 or -1 and the outfit default is not 0, use it
	else if ((appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
		&& helmetTypeOverride != 0)
	{
		appearanceIds.helmetAppearanceId = helmetTypeOverride;
	}

	// apply the helmet
	return specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);
}
