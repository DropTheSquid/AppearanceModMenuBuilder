class SimpleOutfitSpec extends OutfitSpecBase;

var AppearanceMeshPaths BodyMesh;
// whether this spec shoudl suppress the helmet; still allows breather if not suppressed
var bool bSuppressHelmet;
// suppress the breather in addition to the helmet; no effect if helmet not suppressed
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;
var int helmetTypeOverride;
var int HelmetOnBodySpec;
var int HelmetFullBodySpec;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eHelmetDisplayState helmetDisplayState;

	// get whether we should display the helmet based on a variety of factors
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	// if we should show a helmet but this spec redirects to another in that case, delegate to that one
	if (helmetDisplayState  == eHelmetDisplayState.on && HelmetOnBodySpec != 0)
	{
		appearanceIds.bodyAppearanceId = HelmetOnBodySpec;
		return specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, appearance);
	}
	// same if it redirects to another spec based on it being full helmet
	else if (helmetDisplayState  == eHelmetDisplayState.full && HelmetFullBodySpec != 0)
	{
		appearanceIds.bodyAppearanceId = HelmetFullBodySpec;
		return specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, appearance);
	}

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(BodyMesh, appearance.bodyMesh))
	{
		return false;
	}

	appearance.hideHair = bHideHair;
	appearance.hideHead = bHideHead;

	// if we should display some kind of helmet, check if we should use the default one for this outfit
	// if the helmet id is 0 or -1 and the outfit default is not 0, use it
	if ((appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
		&& helmetTypeOverride != 0)
	{
		appearanceIds.helmetAppearanceId = helmetTypeOverride;
	}

	// if a helmet is requested and it is not suppressed
	if (helmetDisplayState != eHelmetDisplayState.off && !bSuppressHelmet)
	{
		specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);
	}
	// if a breather is requested and the helmet is suppressed but the breather is not
	else if (helmetDisplayState == eHelmetDisplayState.full && bSuppressHelmet && !bSuppressBreather)
	{
		specLists.breatherSpecs.DelegateToBreatherSpec(target, specLists, appearanceIds, appearance);
	}

	return true;
}
