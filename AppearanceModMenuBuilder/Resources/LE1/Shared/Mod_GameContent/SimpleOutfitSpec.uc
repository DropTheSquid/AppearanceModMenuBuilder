class SimpleOutfitSpec extends OutfitSpecBase;

var AppearanceMeshPaths BodyMesh;
var bool bSuppressHelmet;
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;
var int helmetTypeOverride;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	if (class'AMM_Utilities'.static.LoadAppearanceMesh(BodyMesh, appearance.bodyMesh))
	{
		if ((appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
			&& helmetTypeOverride != 0)
		{
			appearanceIds.helmetAppearanceId = helmetTypeOverride;
		}
		// TODO I need to check to make sure helmet specs is not none here
		return specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);
	}

	appearance.hideHair = bHideHair;
	appearance.hideHead = bHideHead;

	return false;
}
