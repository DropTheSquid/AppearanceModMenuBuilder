class SimpleOutfitSpec extends OutfitSpecBase;

var AppearanceMeshPaths BodyMesh;
// whether this spec should suppress the helmet; still allows breather if not suppressed
var bool bSuppressHelmet;
// suppress the breather in addition to the helmet; no effect if helmet not suppressed
var bool bSuppressBreather;
var bool bHideHair;
var bool bHideHead;
var int helmetTypeOverride;
// delegates to a different body spec if the helmet is on, to account for things like hoods
var int HelmetOnBodySpec;
// delegates to a different body spec if the helmet is full to account for things like hoods/faceplates
var int HelmetFullBodySpec;
// a default helmet spec to be used for full helmet situations if one is not set by the user
var int helmetFullHelmetSpec;
// force a specific helmet spec, overriding user choice
var int forceHelmetSpec;
// force a specific breather; only used if the helmet is suppressed, but not the breather
var int breatherSpecOverride;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eHelmetDisplayState helmetDisplayState;
	local HelmetSpecBase delegateSpec;

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

	if (forceHelmetSpec != 0)
	{
		appearanceIds.helmetAppearanceId = forceHelmetSpec;
	}
	// if we should display some kind of helmet, check if we should use the default one for this outfit
	// if the helmet id is 0 or -1 and the outfit default is not 0, use it
	else if ((appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
		&& helmetTypeOverride != 0)
	{
		appearanceIds.helmetAppearanceId = helmetTypeOverride;
	}

	// if a helmet is requested and it is not suppressed
	if (helmetDisplayState != eHelmetDisplayState.off && !bSuppressHelmet)
	{
		if (SpecLists.helmetSpecs.GetHelmetSpecById(appearanceIds.helmetAppearanceId, delegateSpec))
		{
			// the helmetFullHelmet spec set on the outfit takes precedence over the one on the helmet
			if (helmetFullHelmetSpec != 0 && SimpleHelmetSpec(delegateSpec) != None && SimpleHelmetSpec(delegateSpec).helmetFullHelmetSpec != 0)
			{
				SimpleHelmetSpec(delegateSpec).helmetFullHelmetSpec = helmetFullHelmetSpec;
			}
			if (!delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance))
			{
				LogInternal("Warning: failed to apply helmet by id"@appearanceIds.helmetAppearanceId);
			}
		}

		specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);
	}
	// if a breather is requested and the helmet is suppressed but the breather is not
	else if (helmetDisplayState == eHelmetDisplayState.full && bSuppressHelmet && !bSuppressBreather)
	{
		if (breatherSpecOverride != 0)
		{
			appearanceIds.breatherAppearanceId = breatherSpecOverride;
		}
		specLists.breatherSpecs.DelegateToBreatherSpec(target, specLists, appearanceIds, appearance);
	}

	return true;
}

public function bool LocksHelmetSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
	local OutfitSpecBase delegateOutfitSpec;
	local bool helmetOnSpecLocksHelmet;
	local bool helmetFullSpecLocksHelmet;

	// if this outfit spec forces a specific helmet, then indicate it will ignore helmet choice
	if (forceHelmetSpec != 0)
	{
		return true;
	}
	// same if it suppresses the helmet
	if (bSuppressHelmet)
	{
		return true;
	}
	// if this has helmet on/helmet full specs, we gotta ask those as well
	if (HelmetOnBodySpec != 0)
	{
		if (SpecLists.outfitSpecs.GetOutfitSpecById(HelmetOnBodySpec, delegateOutfitSpec))
		{
			helmetOnSpecLocksHelmet = delegateOutfitSpec.LocksHelmetSelection(target, specLists, appearanceIds);
		}
	}
	if (HelmetFullBodySpec != 0)
	{
		if (SpecLists.outfitSpecs.GetOutfitSpecById(HelmetFullBodySpec, delegateOutfitSpec))
		{
			helmetFullSpecLocksHelmet = delegateOutfitSpec.LocksHelmetSelection(target, specLists, appearanceIds);
		}
	}
	// return true if both lock the helmet; if only one does, then you can let them pick a helmet
    return helmetOnSpecLocksHelmet && helmetFullSpecLocksHelmet;
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
	local HelmetSpecBase delegateHelmetSpec;
	local OutfitSpecBase delegateOutfitSpec;
	local bool helmetOnSpecLocksHelmet;
	local bool helmetFullSpecLocksHelmet;
	local bool defaultLocksHelmet;

	if (bSuppressHelmet && !bSuppressBreather && breatherSpecOverride != 0)
	{
		return true;
	}
	if (bSuppressBreather)
	{
		return true;
	}
	// check if a forced helmet locks the breather
	if (forceHelmetSpec != 0)
	{
		appearanceIds.helmetAppearanceId = forceHelmetSpec;
	}
	// otherwise, if it sets a default helmet that is not overridden, check that
	else if ((appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
		&& helmetTypeOverride != 0)
	{
		appearanceIds.helmetAppearanceId = helmetTypeOverride;
	}

	// if this has helmet on/helmet full specs, we gotta ask those as well
	if (HelmetOnBodySpec != 0)
	{
		if (SpecLists.outfitSpecs.GetOutfitSpecById(HelmetOnBodySpec, delegateOutfitSpec))
		{
			helmetOnSpecLocksHelmet = delegateOutfitSpec.LocksBreatherSelection(target, specLists, appearanceIds);
		}
	}
	if (HelmetFullBodySpec != 0)
	{
		if (SpecLists.outfitSpecs.GetOutfitSpecById(HelmetFullBodySpec, delegateOutfitSpec))
		{
			helmetFullSpecLocksHelmet = delegateOutfitSpec.LocksBreatherSelection(target, specLists, appearanceIds);
		}
	}

	// if this has both a helmet on and helmet full body spec, only look at those
	if (HelmetOnBodySpec != 0 && HelmetFullBodySpec != 0)
	{
		// return true if both lock the helmet; if only one does, then you can let them pick a breather
		return helmetOnSpecLocksHelmet && helmetFullSpecLocksHelmet;
	}

	// otherwise also take into account the non body override helmet
	if (SpecLists.helmetSpecs.GetHelmetSpecById(appearanceIds.helmetAppearanceId, delegateHelmetSpec))
	{
		if (helmetFullHelmetSpec != 0 && SimpleHelmetSpec(delegateHelmetSpec) != None && SimpleHelmetSpec(delegateHelmetSpec).helmetFullHelmetSpec != 0)
		{
			SimpleHelmetSpec(delegateHelmetSpec).helmetFullHelmetSpec = helmetFullHelmetSpec;
		}
		defaultLocksHelmet = delegateHelmetSpec.LocksBreatherSelection(target, SpecLists, appearanceIds);
	}

	// lock it only if it is locked in all states
	return defaultLocksHelmet && (HelmetOnBodySpec == 0 || helmetOnSpecLocksHelmet) && (HelmetFullBodySpec == 0 || helmetFullSpecLocksHelmet);
}
