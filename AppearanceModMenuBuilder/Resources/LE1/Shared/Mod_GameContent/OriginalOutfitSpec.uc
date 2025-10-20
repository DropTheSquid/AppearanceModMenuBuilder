Class OriginalOutfitSpec extends OutfitSpecBase;

public function bool LoadOutfit(BioPawn target, specLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
    local eHelmetDisplayState helmetDisplayState;
    local OutfitSpecBase outfitDelegateSpec;
    local HelmetSpecBase helmetDelegateSpec;
    local AMM_OriginalOutfit originalOutfit;

    if (Class'AMM_OriginalOutfit'.static.GetOutfit(target, originalOutfit))
    {
        appearance.bodyMesh = originalOutfit.originalBody;
    }
    else
    {
        outfitDelegateSpec = new Class'VanillaOutfitSpec';
        return outfitDelegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
    }

    // get whether we should display the helmet based on a variety of factors
    helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
    // if a helmet is requested and it is not suppressed
    if (helmetDisplayState != eHelmetDisplayState.off)
    {
        helmetDelegateSpec = GetHelmetSpec(target, specLists, appearanceIds);
        if (helmetDelegateSpec != None)
        {
            if (!helmetDelegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance))
            {
                LogInternal("failed to load helmet spec"@helmetDelegateSpec);
            }
        }
        else
        {
            LogInternal("failed to get helmet spec");
        }
    }
    return TRUE;
}
