Class DefaultHelmetSpec extends HelmetSpecBase;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local HelmetSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    if (delegateSpec == None)
    {
        return false;
    }

    return delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance);
}

private function HelmetSpecBase GetDelegateSpec(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local HelmetSpecBase delegateSpec;
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local AMM_Pawn_Parameters params;

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
		return None;
	}

    BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    globalVars = BWI.GetGlobalVariables();

    // if the equipped armor mod setting is on and this is a squadmate (but not the player) in a combat appearance
    if (globalVars.GetInt(1601) == 1
        && AMM_Pawn_Parameters_Squad(params) != None
        && AMM_Pawn_Parameters_Player(params) == None
        && params.GetAppearanceType(target) ~= "combat")
    {
        // then use the equipped helmet spec
        return new Class'EquippedArmorHelmetSpec';
    }
    else
    {
        // check if they have an override spec set
        delegateSpec = HelmetSpecBase(params.GetOverrideDefaultHelmetSpec(target));

        // else use vanilla helmet spec
        if (delegateSpec == None)
        {
            delegateSpec = new Class'VanillaHelmetSpec';
        }

        return delegateSpec;
    }
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local HelmetSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    if (delegateSpec == None)
    {
        return false;
    }
    return delegateSpec.LocksBreatherSelection(target, specLists, appearanceIds);
}
