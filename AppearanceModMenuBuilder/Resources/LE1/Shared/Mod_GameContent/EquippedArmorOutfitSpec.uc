Class EquippedArmorOutfitSpec extends NonOverriddenVanillaOutfitSpec;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
    local AMM_Pawn_Parameters params;
    local BioPawn partyMember;
    local OutfitSpecBase outfitDelegateSpec;
    local int armorType;
    local int meshVariant;
    local int materialVariant;
	local AppearanceMeshPaths meshPaths;
	local array<string> meshMaterialPaths;
    local BIoPawnType pawnType;
    local eHelmetDisplayState helmetDisplayState;
    local HelmetSpecBase delegateHelmetSpec;

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
        // LogInternal("helmetAppearanceId"@appearanceIds.helmetAppearanceId);
        // this is important to ensure the equipped helmet is used unless overridden even for player and in party squadmates
        if (appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
        {
            // LogInternal("replacing it with -3 (equipped armor helmet)");
            appearanceIds.helmetAppearanceId = -3;
        }
        outfitDelegateSpec = new Class'NonOverriddenVanillaOutfitSpec';
        return outfitDelegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
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

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(meshPaths, appearance.bodyMesh, false, true))
	{
		return false;
	}

    // get whether we should display the helmet based on a variety of factors
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);

    // this is important to ensure we don't add a helmet if the preference is to not have one
    if (helmetDisplayState != eHelmetDisplayState.off)
    {
        delegateHelmetSpec = GetHelmetSpec(target, specLists, appearanceIds);
        if (delegateHelmetSpec != None)
        {
            if (!delegateHelmetSpec.LoadHelmet(target, specLists, appearanceIds, appearance))
            {
                LogInternal("failed to load helmet spec"@delegateHelmetSpec);
            }
        }
        else
        {
            LogInternal("no helmet spec could be found");
        }
    }

	return true;
}

// TODO locks helmet/breather spec here
public function HelmetSpecBase GetHelmetSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds)
{
    local HelmetSpecBase delegateHelmetSpec;

    if (appearanceIds.helmetAppearanceId == 0 || appearanceIds.helmetAppearanceId == -1)
    {
        // by default, try to go to the equipped helmet spec
        if (SpecLists.helmetSpecs.GetHelmetSpecById(-3, delegateHelmetSpec))
        {
            return delegateHelmetSpec;
        }
    }

    return super.GetHelmetSpec(target, specLists, appearanceIds);
}