Class NonOverriddenVanillaHelmetSpec extends VanillaHelmetSpecBase;

protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
    local EBioArmorType visualOverride;

	// Grab the values from the behavior>appearanceType>settings>bodySettings
	// this should be updated at runtime to match the armor they have equipped, and is what determines their appearance if their armor appearance is not overridden
    armorType = int(BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_eArmorType);
    meshVariant = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nModelVariant;
    materialVariant = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nMaterialConfig;
    visualOverride = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_eVisualOverride;
    if (visualOverride != EBioArmorType.ARMOR_TYPE_NONE)
    {
        armorType = int(visualOverride);
    }
    return true;
}