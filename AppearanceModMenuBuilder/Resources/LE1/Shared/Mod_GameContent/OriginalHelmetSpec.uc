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
			LogInternal("acould not get breather spec");
		}
	}
	return true;
}
