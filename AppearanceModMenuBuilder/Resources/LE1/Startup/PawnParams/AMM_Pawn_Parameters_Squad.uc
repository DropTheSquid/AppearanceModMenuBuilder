Class AMM_Pawn_Parameters_Squad extends AMM_Pawn_Parameters
    abstract
    config(Game);

var config int defaultCasualBodyAppearanceId;
var config int defaultCasualHelmetAppearanceId;
var config int defaultCasualBreatherAppearanceId;

var config int defaultCombatBodyAppearanceId;
var config int defaultCombatHelmetAppearanceId;
var config int defaultCombatBreatherAppearanceId;

// Functions
public function string GetAppearanceType(BioPawn targetPawn)
{
	// return casual or cambat based on whether the armor appearance is overriden
    return Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(targetPawn) ? "casual" : "combat";
}
public function bool GetExistingPawn(string appearanceType, out BioPawn existingPawn)
{
	local string tempString;
    local string tempString2;
    local string tempString3;

    // if it is possible to stream in according to the config, do so
    // LogInternal("GetExistingPawn"@self@appearanceType);
    if (GetFrameworkFileForAppearanceType(appearanceType, tempString, tempString2, tempString3))
    {
        return false;
    }
    // else, grab them from the party
    return GetPawnFromParty(Tag, existingPawn);
}

public function Object GetOverrideDefaultOutfitSpec(BioPawn targetPawn)
{
	local OutfitSpecBase delegateSpec;
    local SpecLists specLists;

    specLists = class'AMM_Utilities'.static.GetSpecLists(targetPawn, self);
    if (specLists.outfitSpecs == None)
    {
        return super.GetOverrideDefaultOutfitSpec(targetPawn);
    }

	if (GetAppearanceType(targetPawn) ~= "casual")
	{
        if (defaultCasualBodyAppearanceId != 0 && specLists.outfitSpecs.GetOutfitSpecById(defaultCasualBodyAppearanceId, delegateSpec))
        {
            return delegateSpec;
        }
	}
    else if (GetAppearanceType(targetPawn) ~= "Combat")
	{
        if (defaultCombatBodyAppearanceId != 0 && specLists.outfitSpecs.GetOutfitSpecById(defaultCombatBodyAppearanceId, delegateSpec))
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

    specLists = class'AMM_Utilities'.static.GetSpecLists(targetPawn, self);
    if (specLists.HelmetSpecs == None)
    {
        return super.GetOverrideDefaultHelmetSpec(targetPawn);
    }

	if (GetAppearanceType(targetPawn) ~= "casual")
	{
        if (defaultCasualHelmetAppearanceId != 0 && specLists.helmetSpecs.GetHelmetSpecById(defaultCasualHelmetAppearanceId, delegateSpec))
        {
            return delegateSpec;
        }
	}
    else if (GetAppearanceType(targetPawn) ~= "Combat")
	{
        if (defaultCombatHelmetAppearanceId != 0 && specLists.helmetSpecs.GetHelmetSpecById(defaultCombatHelmetAppearanceId, delegateSpec))
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

    specLists = class'AMM_Utilities'.static.GetSpecLists(targetPawn, self);
    if (specLists.BreatherSpecs == None)
    {
        return super.GetOverrideDefaultBreatherSpec(targetPawn);
    }

	if (GetAppearanceType(targetPawn) ~= "casual")
	{
        if (defaultCasualBreatherAppearanceId != 0 && specLists.BreatherSpecs.GetBreatherSpecById(defaultCasualBreatherAppearanceId, delegateSpec))
        {
            return delegateSpec;
        }
	}
    else if (GetAppearanceType(targetPawn) ~= "Combat")
	{
        if (defaultCombatBreatherAppearanceId != 0 && specLists.BreatherSpecs.GetBreatherSpecById(defaultCombatBreatherAppearanceId, delegateSpec))
        {
            return delegateSpec;
        }
	}

	return super.GetOverrideDefaultBreatherSpec(targetPawn);
}

protected final function bool GetPawnFromParty(string LookupTag, out BioPawn squadmate)
{
    local BioWorldInfo BWI;
    local MemberData tempsquadMember;
    local BioPawn Pawn;
    
    // LogInternal("getting from party");
    BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    if (LookupTag ~= "Player" || LookupTag ~= "Human_Male" || LookupTag ~= "Human_Female")
    {
        squadmate = BWI.m_playerSquad.m_playerPawn;
        return TRUE;
    }
    else
    {
        foreach BWI.m_playerSquad.Members(tempsquadMember, )
        {
            if (string(BioPawn(tempsquadMember.SquadMember).Tag) ~= LookupTag)
            {
                squadmate = BioPawn(tempsquadMember.SquadMember);
                return TRUE;
            }
        }
    }
    return FALSE;
}

// if there is not an existing pawn, but we can/should synchronously spawn one, do so
public function bool SpawnPawn(string appearanceType, out BioPawn spawnedPawn)
{
	local string tempString;
    local string tempString2;
    local string tempString3;

    // if it is possible to stream in according to the config, do so
    if (GetFrameworkFileForAppearanceType(appearanceType, tempString, tempString2, tempString3))
    {
        return false;
    }
    // else, add them to the party
    return spawnPawnIntoParty(Tag, spawnedPawn);
}
public function bool spawnPawnIntoParty(string appearanceType, out BioPawn spawnedPawn)
{
    local BioWorldInfo BioWorldInfo;
    local BioSPGame gameInfo;
    
    BioWorldInfo = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    gameInfo = BioSPGame(BioWorldInfo.Game);
    spawnedPawn = gameInfo.SpawnHenchman(Name(Tag), BioWorldInfo.m_playerSquad.m_playerPawn, -60.0, -60.0, FALSE);
    return spawnedPawn != None;
}

defaultproperties
{
	// false for squadmates, in general
	requiresFramework=false
    // squadmates can hide their helmets in conversations
    hideHelmetsInConversations=true
}