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

protected function bool GetDefaultOverrideHelmetSpec(BioPawn target, out HelmetSpecBase helmetSpec)
{
    local VanillaHelmetByIdSpec delegateSpec;

	delegateSpec = new class'VanillaHelmetByIdSpec';
    delegateSpec.armorType = armorType;
    delegateSpec.meshVariant = meshVariant;
    delegateSpec.materialVariant = materialVariant;
    helmetSpec = delegateSpec;
    return true;
}
