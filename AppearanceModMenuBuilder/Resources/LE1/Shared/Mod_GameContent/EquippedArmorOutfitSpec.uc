Class EquippedArmorOutfitSpec extends VanillaOutfitSpecBase;

protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
    // TODO see if they have equipped armor, grab the stats from that, use it? Does that get me anything over just grabbing the values that should be populated from there or the defaults?
	// Grab the values from the behavior>appearanceType>settings?bodySettings
	// this should be updated at runtime to match the armor they have equipped, and is what determines their appearance if their armor appearance is not overridden
    armorType = int(BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_eArmorType);
    meshVariant = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nModelVariant;
    materialVariant = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nMaterialConfig;
    return TRUE;
}
