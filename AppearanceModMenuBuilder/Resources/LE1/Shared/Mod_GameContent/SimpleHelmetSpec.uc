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
	local BreatherSpecBase delegateBreatherSpec;

	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);

	// LogInternal("doing the helmet spec"@helmetDisplayState@helmetFullHelmetSpec@breatherSpecOverride);
	// if they should have a full helmet and this is set to redirect to another helmet in that case, do that. 
	if (helmetDisplayState == eHelmetDisplayState.full && helmetFullHelmetSpec != 0)
	{
		// LogInternal("delegating to helmet spec"@helmetFullHelmetSpec);
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
		delegateBreatherSpec = GetBreatherSpec(target, specLists, appearanceIds); 

		if (delegateBreatherSpec != None)
		{
			if (!delegateBreatherSpec.LoadBreather(target, specLists, appearanceIds, appearance))
			{
				LogInternal("failed to load breather spec"@delegateBreatherSpec);
			}
		}
		else
		{
			LogInternal("acould not get breather spec");
		}
	}
	return true;
}

public function BreatherSpecBase GetBreatherSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds)
{
    local BreatherSpecBase delegateBreatherSpec;

	if (breatherSpecOverride != 0 && SpecLists.breatherSpecs.GetBreatherSpecById(breatherSpecOverride, delegateBreatherSpec))
	{
		return delegateBreatherSpec;
	}

    return super.GetBreatherSpec(target, specLists, appearanceIds);
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
	local HelmetSpecBase delegateHelmetSpec;

	if (bSuppressBreather)
	{
		return true;
	}
	if (breatherSpecOverride != 0)
	{
		return true;
	}
	if (helmetFullHelmetSpec != 0)
	{
		if (SpecLists.helmetSpecs.GetHelmetSpecById(helmetFullHelmetSpec, delegateHelmetSpec))
		{
			if (helmetFullHelmetSpec != 0 && SimpleHelmetSpec(delegateHelmetSpec) != None && SimpleHelmetSpec(delegateHelmetSpec).helmetFullHelmetSpec != 0)
			{
				SimpleHelmetSpec(delegateHelmetSpec).helmetFullHelmetSpec = helmetFullHelmetSpec;
			}
			return delegateHelmetSpec.LocksBreatherSelection(target, SpecLists, appearanceIds);
		}
	}
    return false;
}