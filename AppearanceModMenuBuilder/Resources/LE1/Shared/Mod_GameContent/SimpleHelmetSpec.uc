class SimpleHelmetSpec extends HelmetSpecBase;

var AppearanceMeshPaths HelmetMesh;
var AppearanceMeshPaths VisorMesh;
var bool bSuppressVisor;
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;
// if the helmet is in the full state, it will show this helmet spec instead of this one. This allows you to redirect from a visor type helmet (think Kuwashi visor) to a full breather helmet
var int helmetFullHelmetSpec;
// alternatively, you can force a specific breather spec to match your helmet
var int breatherSpecOverride;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eHelmetDisplayState helmetDisplayState;

	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);

	LogInternal("doing the helmet spec"@helmetDisplayState@helmetFullHelmetSpec@breatherSpecOverride);
	// if they should have a full helmet and this is set to redirect to another helmet in that case, do that. 
	if (helmetDisplayState == eHelmetDisplayState.full && helmetFullHelmetSpec != 0)
	{
		LogInternal("delegating to helmet spec"@helmetFullHelmetSpec);
		appearanceIds.helmetAppearanceId = helmetFullHelmetSpec;
		return specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);
	}


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
	if (!bSuppressBreather && helmetDisplayState == eHelmetDisplayState.full)
	{
		// if the breather spec is overridden, use that
		if (breatherSpecOverride != 0)
		{
			LogInternal("forcing breather spec"@breatherSpecOverride);
			appearanceIds.breatherAppearanceId = breatherSpecOverride;
		}
		specLists.breatherSpecs.DelegateToBreatherSpec(target, specLists, appearanceIds, appearance);
	}
	return true;
}