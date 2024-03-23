Class VanillaHelmetByIdSpec extends VanillaHelmetSpecBase;

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