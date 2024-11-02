Class ArmorFromItemIdHelmetSpec extends VanillaHelmetSpecBase;

// the itemId, manufacturerId and sophistication (level 1-10) for the item whose appearance we are loading
var int itemId;
var int manufacturerId;
var byte sophistication;

protected function bool GetPawnType(BioPawn targetPawn, out BioPawnTYpe pawnType)
{
    local AMM_Pawn_Parameters params;

	if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(targetPawn, params))
	{
		return false;
	}

    // this should work for any squadmate, including the player, but no one else
    // does not matter if they are in the squad or not
    if (AMM_Pawn_Parameters_Squad(params) == None)
    {
        return false;
    }

    // next get their in party pawn type
    if (!class'AMM_Utilities'.static.GetActorType(params.Tag, pawnType))
    {
        LogInternal("could not get actor type for"@params.Tag);
        return false;
    }

    return true;
}


protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
    local AMM_Pawn_Parameters params;

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(targetPawn, params))
	{
		return false;
	}

    // this should work for any squadmate, including the player, but no one else
    // does not matter if they are in the squad or not
    if (AMM_Pawn_Parameters_Squad(params) == None)
    {
        return false;
    }

    // load the equipment and get the stuff from it using the item ids on this spec
    if (!class'AMM_Utilities'.static.LoadEquipmentAndGetAttributes(name(params.Tag), itemId, ManufacturerID, sophistication, armorType, meshVariant, materialVariant))
    {
        return false;
    }

    return true;
}
