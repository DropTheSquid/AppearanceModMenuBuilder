class OriginalHelmetSpec extends HelmetSpecBase;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eHelmetDisplayState helmetDisplayState;
	local BreatherSpecBase delegateBreatherSpec;
    local HelmetSpecBase helmetDelegateSpec;
    local AMM_OriginalOutfit originalOutfit;

    if (Class'AMM_OriginalOutfit'.static.GetOutfit(target, originalOutfit))
    {
        appearance.HelmetMesh = originalOutfit.originalHeadgear;
		appearance.VisorMesh = originalOutfit.originalVisor;
    }
    else
    {
        helmetDelegateSpec = new Class'VanillaHelmetSpec';
        return helmetDelegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance);
    }

	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);

	// if we should display a breather, delegate to the breather spec
	if (helmetDisplayState == eHelmetDisplayState.full)
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
			LogInternal("could not get breather spec");
		}
	}
	return true;
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
	// TODO can I actually determine this with modded outfits?
    return false;
}

public function BreatherSpecBase GetBreatherSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds)
{
    local BreatherSpecBase delegateBreatherSpec;
    local AMM_Pawn_Parameters params;

    if (appearanceIds.breatherAppearanceId == 0 || appearanceIds.breatherAppearanceId == -1)
    {
        return new class'OriginalBreatherSpec';
    }

    return super.GetBreatherSpec(target, specLists, appearanceIds);
}
