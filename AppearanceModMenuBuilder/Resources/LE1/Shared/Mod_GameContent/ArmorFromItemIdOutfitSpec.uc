Class ArmorFromItemIdOutfitSpec extends VanillaOutfitSpecBase;

// the itemId, manufacturerId and sophistication (level 1-10) for the item whose appearance we are loading
var int itemId;
var int manufacturerId;
var byte sophistication;

// this should take in the equipment ids that point to a specific armor, and then load the appearance for that armor taking into account both changes to the hench file which can, for example, redirect certain armors to a different file
// as well as changes to the items 2da that can change what appearance is used, such as Iconic Fashion Party. 
// this is better for compatibility in some cases, especially for Tali's armors, where every mod altering Tali's appearance changes her armors
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
    if (!class'AMM_Utilities'.static.LoadEquipmentAndGetAttributes(Name(params.Tag), itemId, ManufacturerID, sophistication, armorType, meshVariant, materialVariant))
    {
        return false;
    }

    return true;
}

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

protected function bool GetDefaultOverrideHelmetSpec(BioPawn target, out HelmetSpecBase helmetSpec)
{
    local ArmorFromItemIdHelmetSpec delegateSpec;

	delegateSpec = new class'ArmorFromItemIdHelmetSpec';
    delegateSpec.ItemId = ItemId;
    delegateSpec.ManufacturerID = ManufacturerID;
    delegateSpec.sophistication = sophistication;
    helmetSpec = delegateSpec;
    return true;
}
