Class ArmorOverrideVanillaHelmetSpec extends VanillaHelmetSpecBase;

// This class will apply whatever the default meshes of the PawnType are. This is often the casual clothes of a squadmate pawn

protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
    local BioPawnType pawnType;
    
    pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
    if (pawnType == None)
    {
        LogInternal("Warning: Pawn" @ PathName(targetPawn) @ targetPawn.Tag @ "does not have a pawnType, so I cannot get the default outfit.");
        return FALSE;
    }
	// pulls the data off of the pawnType, which is the default used if the armor appearance is overridden
    armorType = int(pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType);
    meshVariant = pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant;
    materialVariant = pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig;
    return TRUE;
}