Class VanillaOutfitSpec extends VanillaOutfitSpecBase;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local OutfitSpecBase delegateSpec;

	if (Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(target))
    {
        delegateSpec = new Class'ArmorOverrideVanillaoutfitSpec';
    }
    else
    {
        delegateSpec = new Class'NonOverriddenVanillaOutfitSpec';
    }
    return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
}

