Class EquippedArmorOutfitSpec extends NonOverriddenVanillaOutfitSpec;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
    local AMM_Pawn_Parameters params;
    local BioPawn partyMember;
    local OutfitSpecBase delegateSpec;
    local int armorType;
    local int meshVariant;
    local int materialVariant;
	local AppearanceMeshPaths meshPaths;
	local array<string> meshMaterialPaths;
    local BIoPawnType pawnType;

	// updater = class'AMM_AppearanceUpdater'.static.GetDlcInstance();

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
        // LogInternal("EquippedArmorOutfitSpec delegating to NonOverriddenVanillaOutfitSpec");
        delegateSpec = new Class'NonOverriddenVanillaOutfitSpec';
        return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
    }

    // first, try getting a pawn from the party and pulling params off of them
    if (AMM_Pawn_Parameters_Squad(params).GetPawnFromParty(params.Tag, partyMember))
    {
        pawnType = class'AMM_Utilities'.static.GetPawnType(partyMember);
        if (!GetVariant(partyMember, armorType, meshVariant, materialVariant))
        {
            LogInternal("got a pawn but couldn't get params from them???");
            return false;
        }
    }
    else
    {
        // LogInternal("pawn is not in party so we are trying to load the equipment");
        if (!class'AMM_Utilities'.static.LoadEquipmentOnly(params.Tag, pawnType, armorType, meshVariant, materialVariant))
        {
            return false;
        }
    }
	
	if (!GetOutfitStrings(
		pawnType,
		armorType, meshVariant, materialVariant,
		meshPaths))
	{
		return false;
	}

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(meshPaths, appearance.bodyMesh))
	{
		return false;
	}
	
    if (appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
    {
        appearanceIds.helmetAppearanceId = -3;
    }
    specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);

	return true;
}


