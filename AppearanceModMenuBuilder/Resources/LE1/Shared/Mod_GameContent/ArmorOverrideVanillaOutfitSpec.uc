Class ArmorOverrideVanillaOutfitSpec extends VanillaOutfitSpecBase;

// This class will apply whatever the default meshes of the PawnType are. This is often the casual clothes of a squadmate pawn

protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
    local BioPawnType previousPawnType;
    local BioPawnType pawnType;

    // a bit of speical handling for compatibility with Casual Hubs
    // check if Casual Hubs is installed and the frmaeork is not
    // and then try to get the pawnType from the hench file to grab settings from that
    if (DynamicLoadObject("DLC_MOD_CasualHubs_GlobalTlk.GlobalTlk_tlk", class'Object', true) != None
        && !class'AMM_Common'.static.IsFrameworkInstalled()
        && class'AMM_Utilities'.static.GetActorType(string(targetPawn.tag), pawnType))
    {
        // save the previous pawn type for the moment
        previousPawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
        // replace the pawnTYpe on the actor with the one from their hench file so their casual outfits work correctly
        // also take the armor override value from this so that they stay in casual if they were in casual
        targetPawn.m_oBehavior.m_oActorType = pawnType;
        pawnType.m_bIsArmorOverridden = previousPawnType.m_bIsArmorOverridden;
    }
    else
    {
        pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
    }

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