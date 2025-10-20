Class OriginalOutfitSpec extends OutfitSpecBase;

public function bool LoadOutfit(BioPawn target, specLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
    local eHelmetDisplayState helmetDisplayState;
    local OutfitSpecBase delegateSpec;
    local Name Package;
    local BioWorldInfo localWI;
    local AMM_OriginalOutfit originalOutfit;
    local int i;
    
    // get whether we should display the helmet based on a variety of factors
    // helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
    // // if we should show a helmet but this spec redirects to another in that case, delegate to that one
    // if (helmetDisplayState  == eHelmetDisplayState.on && HelmetOnBodySpec != 0)
    // {
    //     appearanceIds.bodyAppearanceId = HelmetOnBodySpec;
    //     return specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, appearance);
    // }
    // // same if it redirects to another spec based on it being full helmet
    // else if (helmetDisplayState  == eHelmetDisplayState.full && HelmetFullBodySpec != 0)
    // {
    //     appearanceIds.bodyAppearanceId = HelmetFullBodySpec;
    //     return specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, appearance);
    // }
    if (Class'AMM_OriginalOutfit'.static.GetOutfit(target, originalOutfit))
    {
        LogInternal("Loading original outfit for target" @ target.Tag @ PathName(target), );
        LogInternal("outfit" @ originalOutfit.originalSkeletalMesh, );
        appearance.bodyMesh.Mesh = originalOutfit.originalSkeletalMesh;
        for (i = 0; i < originalOutfit.originalMaterials.Length; i++)
        {
            LogInternal("material" @ i @ PathName(originalOutfit.originalMaterials[i]), );
        }
        appearance.bodyMesh.Materials = originalOutfit.originalMaterials;
    }
    else
    {
        LogInternal("delegating to vanilla outfit spec", );
        delegateSpec = new Class'VanillaOutfitSpec';
        return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
    }
    // if (!class'AMM_Utilities'.static.LoadAppearanceMesh(BodyMesh, appearance.bodyMesh))
    // {
    //     return false;
    // }
    // appearance.hideHair = bHideHair;
    // appearance.hideHead = bHideHead;
    // // if a helmet is requested and it is not suppressed
    // if (helmetDisplayState != eHelmetDisplayState.off && !bSuppressHelmet)
    // {
    //     delegateSpec = GetHelmetSpec(target, specLists, appearanceIds);
    //     if (delegateSpec != None)
    //     {
    //         if (!delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance))
    //         {
    //             LogInternal("failed to load helmet spec"@delegateSpec);
    //         }
    //     }
    //     else
    //     {
    //         LogInternal("failed to get helmet spec");
    //     }
    // }
    // // if a breather is requested and the helmet is suppressed but the breather is not
    // else if (helmetDisplayState == eHelmetDisplayState.full && bSuppressHelmet && !bSuppressBreather)
    // {
    //     // TODO I need to check for breather overrides here?
    //     if (breatherSpecOverride != 0)
    //     {
    //         appearanceIds.breatherAppearanceId = breatherSpecOverride;
    //     }
    //     specLists.breatherSpecs.DelegateToBreatherSpec(target, specLists, appearanceIds, appearance);
    // }
    return TRUE;
}
