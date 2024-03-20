Class VanillaOutfitSpec extends VanillaOutfitSpecBase;

public function bool ApplyOutfit(BioPawn target)
{
	local OutfitSpecBase delegateSpec;

	if (Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(target))
    {
        delegateSpec = new Class'ArmorOverrideVanillaoutfitSpec';
    }
    else
    {
        delegateSpec = new Class'EquippedArmorOutfitSpec';
    }
    return delegateSpec.ApplyOutfit(target);
}
