Class VanillaHelmetSpec extends VanillaHelmetSpecBase;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local HelmetSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, SpecLists, appearanceIds);
    return delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance);
}

private function HelmetSpecBase GetDelegateSpec(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    if (Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(target))
    {
        return new Class'ArmorOverrideVanillaHelmetSpec';
    }
    else
    {
        return new Class'NonOverriddenVanillaHelmetSpec';
    }
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local HelmetSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    return delegateSpec.LocksBreatherSelection(target, specLists, appearanceIds);
}
