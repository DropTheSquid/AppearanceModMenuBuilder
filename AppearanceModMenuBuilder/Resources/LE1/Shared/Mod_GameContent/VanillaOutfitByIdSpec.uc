Class VanillaOutfitByIdSpec extends VanillaOutfitSpecBase;

var EBioArmorType armorType;
var int meshVariant;
var int materialVariant;

protected function bool GetVariant(BioPawn targetPawn, out int iArmorType, out int iMeshVariant, out int iMaterialVariant)
{
    iArmorType = int(armorType);
    iMeshVariant = meshVariant;
    iMaterialVariant = materialVariant;
    return TRUE;
}

public function HelmetSpecBase GetHelmetSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds)
{
    local VanillaHelmetByIdSpec delegateSpec;

    if (appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
    {
        delegateSpec = new class'VanillaHelmetByIdSpec';
        delegateSpec.armorType = armorType;
        delegateSpec.meshVariant = meshVariant;
        delegateSpec.materialVariant = materialVariant;
        return delegateSpec;
    }

    return super.GetHelmetSpec(target, specLists, appearanceIds);
}
