Class AMM_Pawn_Parameters_Squad extends AMM_Pawn_Parameters
    abstract
    config(Game);

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

private final function bool GetPawnFromParty(string LookupTag, out BioPawn squadmate)
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
}