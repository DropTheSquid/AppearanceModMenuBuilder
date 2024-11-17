Class AMM_Pawn_Parameters_Romanceable extends AMM_Pawn_Parameters_Squad
    abstract
    config(Game);

var config string romancePawnTag;

var config int defaultRomanceBodyAppearanceId;
var config int defaultRomanceHelmetAppearanceId;
var config int defaultRomanceBreatherAppearanceId;

public function bool matchesPawn(BioPawn targetPawn)
{
    if (string(targetPawn.Tag) ~= romancePawnTag)
    {
        return ShouldAffectRomanceAppearance();
    }
    return Super.matchesPawn(targetPawn);
}
private function bool ShouldAffectRomanceAppearance()
{
    local BioWorldInfo BWI;
    local BioGlobalVariableTable gv;

    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    gv = BWI.GetGlobalVariables();
    // only affect romance appearances if the framework is installed and romance customization is enabled
    if (class'AMM_Common'.static.IsFrameworkInstalled() && gv.GetInt(1596) == 1)
    {
        return true;
    }
    return false;
}
public function string GetAppearanceType(BioPawn targetPawn)
{
    if (string(targetPawn.Tag) ~= romancePawnTag)
    {
        return "romance";
    }
    return Super.GetAppearanceType(targetPawn);
}

public function Object GetOverrideDefaultOutfitSpec(BioPawn targetPawn)
{
	local OutfitSpecBase delegateSpec;
    local SpecLists specLists;

	if (GetAppearanceType(targetPawn) ~= "romance" && defaultRomanceBodyAppearanceId != 0)
	{
        specLists = class'AMM_Utilities'.static.GetSpecLists(targetPawn, self);
        if (specLists.outfitSpecs == None)
        {
            return super.GetOverrideDefaultOutfitSpec(targetPawn);
        }

        if (specLists.outfitSpecs.GetOutfitSpecById(defaultRomanceBodyAppearanceId, delegateSpec))
        {
            return delegateSpec;
        }
	}

	return super.GetOverrideDefaultOutfitSpec(targetPawn);
}

public function Object GetOverrideDefaultHelmetSpec(BioPawn targetPawn)
{
	local HelmetSpecBase delegateSpec;
    local SpecLists specLists;

	if (GetAppearanceType(targetPawn) ~= "romance" && defaultRomanceHelmetAppearanceId != 0)
	{
        specLists = class'AMM_Utilities'.static.GetSpecLists(targetPawn, self);
        if (specLists.HelmetSpecs == None)
        {
            return super.GetOverrideDefaultHelmetSpec(targetPawn);
        }

        if (specLists.helmetSpecs.GetHelmetSpecById(defaultRomanceHelmetAppearanceId, delegateSpec))
        {
            return delegateSpec;
        }
	}

	return super.GetOverrideDefaultHelmetSpec(targetPawn);
}

public function Object GetOverrideDefaultBreatherSpec(BioPawn targetPawn)
{
	local BreatherSpecBase delegateSpec;
    local SpecLists specLists;

	if (GetAppearanceType(targetPawn) ~= "romance" && defaultRomanceBreatherAppearanceId != 0)
	{
        specLists = class'AMM_Utilities'.static.GetSpecLists(targetPawn, self);
        if (specLists.BreatherSpecs == None)
        {
            return super.GetOverrideDefaultBreatherSpec(targetPawn);
        }

        if (specLists.BreatherSpecs.GetBreatherSpecById(defaultRomanceBreatherAppearanceId, delegateSpec))
        {
            return delegateSpec;
        }
	}

	return super.GetOverrideDefaultBreatherSpec(targetPawn);
}