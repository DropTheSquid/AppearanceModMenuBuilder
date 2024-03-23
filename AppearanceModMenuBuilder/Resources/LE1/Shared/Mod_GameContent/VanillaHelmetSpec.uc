Class VanillaHelmetSpec extends VanillaHelmetSpecBase;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local HelmetSpecBase delegateSpec;

	if (Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(target))
    {
        delegateSpec = new Class'ArmorOverrideVanillaHelmetSpec';
    }
    else
    {
        delegateSpec = new Class'EquippedArmorHelmetSpec';
    }
    return delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance);
}

