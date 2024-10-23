Class VanillaOutfitSpec extends VanillaOutfitSpecBase;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local OutfitSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, speclists, appearanceIds);

    return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
}

private function OutfitSpecBase GetDelegateSpec(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    if (Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(target))
    {
        return new Class'ArmorOverrideVanillaoutfitSpec';
    }
    else
    {
        return new Class'NonOverriddenVanillaOutfitSpec';
    }
}

public function bool LocksHelmetSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local OutfitSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    return delegateSpec.LocksHelmetSelection(target, specLists, appearanceIds);
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local OutfitSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    return delegateSpec.LocksBreatherSelection(target, specLists, appearanceIds);
}
