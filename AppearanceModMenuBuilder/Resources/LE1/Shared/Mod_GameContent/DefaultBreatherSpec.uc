Class DefaultBreatherSpec extends BreatherSpecBase;

public function bool LoadBreather(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local BreatherSpecBase delegateSpec;

    delegateSpec = GetDelegateSpec(target, specLists, appearanceIds);
    if (delegateSpec == None)
    {
        return false;
    }

    return delegateSpec.LoadBreather(target, specLists, appearanceIds, appearance);
}

private function BreatherSpecBase GetDelegateSpec(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    local BreatherSpecBase delegateSpec;
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local AMM_Pawn_Parameters params;

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
		return None;
	}

    // check if they have an override spec set
    delegateSpec = BreatherSpecBase(params.GetOverrideDefaultBreatherSpec(target));

    // else use vanilla breather spec
    if (delegateSpec == None)
    {
        delegateSpec = new Class'VanillaBreatherSpec';
    }

    return delegateSpec;
}
