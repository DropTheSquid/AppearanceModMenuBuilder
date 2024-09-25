Class EquippedArmorHelmetSpec extends NonOverriddenVanillaHelmetSpec;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local AMM_Pawn_Parameters params;
    local BioPawn partyMember;
    local BioPawnType pawnType;
    local HelmetSpecBase delegateSpec;
    local int armorType;
    local int meshVariant;
    local int materialVariant;
	local eHelmetDisplayState helmetDisplayState;
    local AppearanceMeshPaths helmetMeshPaths;
	local bool suppressVisor;
	local bool suppressBreather;
	local bool hideHair;
	local bool hideHead;


    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
        LogInternal("EquippedArmorHelmetSpec could not get params");
		return false;
	}

    // if this is the player or not a squadmate or the target is currently in the party, defer to NonOverriddenVanillaHelmetSpec
    if (AMM_Pawn_Parameters_Player(params) != None 
        || AMM_Pawn_Parameters_Squad(params) == None 
        || AMM_Pawn_Parameters_Squad(params).GetPawnFromParty(params.Tag, partyMember) && partyMember == target)
    {
        LogInternal("EquippedArmorHelmetSpec delegating to NonOverriddenVanillaHelmetSpec");
        delegateSpec = new Class'NonOverriddenVanillaHelmetSpec';
        return delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance);
    }

    // TODO grab this info from the save file squad record instead, look it up in the 2DA?
    // might perform better tbh

    // get a squad copy of this pawn either from the party or create them temporarily
    if (AMM_Pawn_Parameters_Squad(params).GetPawnFromParty(params.Tag, partyMember))
    {
        pawnType = class'AMM_Utilities'.static.GetPawnType(partyMember);
        // do the expected GetVariant stuff, but on the partyMember rather than the target
        if (!GetVariant(partyMember, armorType, meshVariant, materialVariant))
        {
            return FALSE;
        }
    }
    else
    {
        // LogInternal("loading equipment for helmet spec"@params.tag);
        if (!class'AMM_Utilities'.static.LoadEquipmentOnly(params.Tag, pawnType, armorType, meshVariant, materialVariant))
        {
            return false;
        }
        // LogInternal("loaded and got"@armorType@meshVariant@materialVariant);
    }

    if (!GetHelmetMeshPaths(
        pawnType,
        armorType,
        meshVariant,
        materialVariant,
        helmetMeshPaths,
        hideHair,
        hideHead,
        suppressVisor,
        suppressBreather
    ))
    {
        return false;
    }

    // load the helmet mesh
    if (!class'AMM_Utilities'.static.LoadAppearanceMesh(helmetMeshPaths, appearance.HelmetMesh, true))
    {
        return false;
    }

	appearance.hideHair = appearance.hideHair || hideHair;
	appearance.hideHead = appearance.hideHead || hideHead;

	// if the visor is not suppressed, get the visor mesh
	if (!suppressVisor)
	{
		class'AMM_Utilities'.static.GetVanillaVisorMesh(class'AMM_Utilities'.static.GetPawnType(partyMember), appearance.VisorMesh);
	}

	// check whether we should display a breather
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	if (helmetDisplayState != eHelmetDisplayState.full)
	{
		suppressBreather = true;
	}

	// if the breather is not suppressed, delegate to the breather spec
	if (!suppressBreather)
	{
		specLists.breatherSpecs.DelegateToBreatherSpec(target, specLists, appearanceIds, appearance);
	}
	
	return true;
}
