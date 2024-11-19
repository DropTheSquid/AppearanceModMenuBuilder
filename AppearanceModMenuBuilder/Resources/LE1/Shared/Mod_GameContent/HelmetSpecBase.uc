class HelmetSpecBase extends Object
    abstract;

// loads (but does not apply) a helmet, returning true if it was succesful and false otherwise
// the out param holds the loaded outfit meshes and parameters about how to alter the pawn's appearance
public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance);

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    return false;
}

public function BreatherSpecBase GetBreatherSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds)
{
    local BreatherSpecBase delegateBreatherSpec;
    local AMM_Pawn_Parameters params;

    if (appearanceIds.breatherAppearanceId == 0 || appearanceIds.breatherAppearanceId == -1)
    {
        if (class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
        {
            delegateBreatherSpec = BreatherSpecBase(params.GetOverrideDefaultBreatherSpec(target));

            if (delegateBreatherSpec != None)
            {
                return delegateBreatherSpec;
            }
        }
    }

    if (specLists.breatherSpecs != None && SpecLists.breatherSpecs.GetBreatherSpecById(appearanceIds.breatherAppearanceId, delegateBreatherSpec))
    {
        return delegateBreatherSpec;
    }
    return None;
}