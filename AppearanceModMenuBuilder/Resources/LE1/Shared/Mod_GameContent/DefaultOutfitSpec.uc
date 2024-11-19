Class DefaultOutfitSpec extends OutfitSpecBase;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local OutfitSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    if (delegateSpec == None)
    {
        return false;
    }

    return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
}

private function OutfitSpecBase GetDelegateSpec(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local OutfitSpecBase delegateSpec;
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local AMM_Pawn_Parameters params;

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
		return None;
	}

    BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    globalVars = BWI.GetGlobalVariables();

    // if the equipped armor mod setting is on and this is a squadmate (but not the player) in a combat appearance
    if (globalVars.GetInt(1601) == 1
        && AMM_Pawn_Parameters_Squad(params) != None
        && AMM_Pawn_Parameters_Player(params) == None
        && params.GetAppearanceType(target) ~= "combat")
    {
        // then use the Equipped armor spec
        return new Class'EquippedArmorOutfitSpec';
    }
    else
    {
        // check if they have an override spec set
        delegateSpec = OutfitSpecBase(params.GetOverrideDefaultOutfitSpec(target));

        if (delegateSpec == None)
        {
            // otherwise, defer to vanilla behavior
            delegateSpec = new Class'VanillaOutfitSpec';
        }

        return delegateSpec;
    }
}

public function HelmetSpecBase GetHelmetSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds)
{
    local OutfitSpecBase outfitDelegate;

    outfitDelegate = GetDelegateSpec(target, specLists, appearanceIds);
    if (outfitDelegate == None)
    {
        return None;
    }
    return outfitDelegate.GetHelmetSpec(target, SpecLists, appearanceIds);
}

public function bool LocksHelmetSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local OutfitSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    if (delegateSpec == None)
    {
        return false;
    }
    return delegateSpec.LocksHelmetSelection(target, specLists, appearanceIds);
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local OutfitSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    if (delegateSpec == None)
    {
        return false;
    }
    return delegateSpec.LocksBreatherSelection(target, specLists, appearanceIds);
}
