Class EquippedArmorOutfitSpec extends NonOverriddenVanillaOutfitSpec;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
    local AMM_Pawn_Parameters params;
    local BioWorldInfo BWI;
    local AMM_AppearanceUpdater updater;
    local BioPawn partyMember;
    local bool destroyAfter;
    local OutfitSpecBase delegateSpec;
    local int armorType;
    local int meshVariant;
    local int materialVariant;
	local AppearanceMeshPaths meshPaths;
	local array<string> meshMaterialPaths;
	local eHelmetDisplayState helmetDisplayState;

	updater = class'AMM_AppearanceUpdater'.static.GetDlcInstance();

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
        LogInternal("EquippedArmorOutfitSpec could not get params");
		return false;
	}

    // if this is the player or not a squadmate or the target is currently in the party, defer to NonOverriddenVanillaOutfitSpec
    if (AMM_Pawn_Parameters_Player(params) != None 
        || AMM_Pawn_Parameters_Squad(params) == None 
        || AMM_Pawn_Parameters_Squad(params).GetPawnFromParty(params.Tag, partyMember) && partyMember == target)
    {
        LogInternal("EquippedArmorOutfitSpec delegating to NonOverriddenVanillaOutfitSpec");
        delegateSpec = new Class'NonOverriddenVanillaOutfitSpec';
        return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
    }

    // TODO grab this info from the save file squad record instead, look it up in the 2DA?
    // might perform better tbh

    // get a squad copy of this pawn either from the party or create them temporarily
    if (AMM_Pawn_Parameters_Squad(params).GetPawnFromParty(params.Tag, partyMember))
    {
        LogInternal("ArmorOverrideVanillaoutfitSpec got pawn from party"@PathName(partyMember));
        destroyAfter = false;
    }
    else
    {
        LogInternal("ArmorOverrideVanillaoutfitSpec trying to spawn a copy of them");
        BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
        // spawn a copy of this pawn, grab their outfit info
        partyMember = BioSPGame(BWI.Game).SpawnHenchman(Name(params.Tag), BWI.m_playerSquad.m_playerPawn, 100, 100, true);
        LogInternal("ArmorOverrideVanillaoutfitSpec spawned"@PathName(partyMember));
        destroyAfter = true;
    }

    // do the expected GetVariant stuff, but on the partyMember rather than the target
    if (!GetVariant(partyMember, armorType, meshVariant, materialVariant))
    {
        if (destroyAfter)
        {
            partyMember.Destroy();
        }
        return FALSE;
    }
	
	if (!GetOutfitStrings(
		class'AMM_Utilities'.static.GetPawnType(partyMember),
		armorType, meshVariant, materialVariant,
		meshPaths))
	{
        if (destroyAfter)
        {
            partyMember.Destroy();
        }
		return false;
	}

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(meshPaths, appearance.bodyMesh))
	{
        if (destroyAfter)
        {
            partyMember.Destroy();
        }
		return false;
	}
	
	// get whether we should display the helmet based on a variety of factors
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	if (helmetDisplayState != eHelmetDisplayState.off)
	{
		specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);
	}
    if (destroyAfter)
    {
        partyMember.Destroy();
    }
	return true;
}

// protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
// {
//     local AMM_Pawn_Parameters params;

//     if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(targetPawn, params))
// 	{
// 		return false;
// 	}

// 	// Grab the values from the behavior>appearanceType>settings>bodySettings
// 	// this should be updated at runtime to match the armor they have equipped, and is what determines their appearance if their armor appearance is not overridden
//     armorType = int(BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_eArmorType);
//     meshVariant = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nModelVariant;
//     materialVariant = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_oSettings.m_oBodySettings.m_nMaterialConfig;
//     return TRUE;
// }
