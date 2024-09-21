Class DefaultHelmetSpec extends HelmetSpecBase;

public function bool LoadHelmet(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local HelmetSpecBase delegateSpec;
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local AMM_Pawn_Parameters params;

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
		return false;
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
        delegateSpec = new Class'EquippedArmorHelmetSpec';
    }
    else
    {
        // else use vanilla helmet spec
        delegateSpec = new Class'VanillaHelmetSpec';
    }
    return delegateSpec.LoadHelmet(target, specLists, appearanceIds, appearance);
}
