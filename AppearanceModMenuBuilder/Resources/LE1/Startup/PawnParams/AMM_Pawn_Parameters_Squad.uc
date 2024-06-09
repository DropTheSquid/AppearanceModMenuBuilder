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
	// If appearanceType is combat, always pull from party.
	// if appearance type is casual and framework is installed, return false (make them stream it in)
	// if appearance type is romance, return false? or we could do a kind of force stream it in
	if (appearanceType ~= "combat" 
		|| (appearanceType ~= "casual" && !GetFrameworkFileForAppearanceType(appearanceType, tempString)))
	{
		// get pawn from party
		return GetPawnFromParty(Tag, existingPawn);
	}
	return false;
}

private final function bool GetPawnFromParty(string LookupTag, out BioPawn squadmate)
{
    local BioWorldInfo BWI;
    local MemberData tempsquadMember;
    local BioPawn Pawn;
    
    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
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

	// same as above:
	// If appearanceType is combat, always pull from party.
	// if appearance type is casual and framework is installed, return false (make them stream it in)
	// if appearance type is romance, return false? or we could do a kind of force stream it in
	if (appearanceType ~= "combat" 
		|| (appearanceType ~= "casual" && !GetFrameworkFileForAppearanceType(appearanceType, tempString)))
	{
		// get pawn from party
		return spawnPawnIntoParty(Tag, spawnedPawn);
	}
	
	return false;
}
public function bool spawnPawnIntoParty(string appearanceType, out BioPawn spawnedPawn)
{
    local BioPawn BioPawn;
    local BioWorldInfo BioWorldInfo;
    local int characterID;
    local string TheActorType;
    local BioAiController henchAI;
    local BioPlayerSquad henchSquad;
    local Vector SpawnPoint;
    local Rotator SpawnRotation;
    local int nIsHeadGearVisible;
    local BioSPGame gameInfo;
    
    BioWorldInfo = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    gameInfo = BioSPGame(BioWorldInfo.Game);
    spawnedPawn = gameInfo.SpawnHenchman(Name(Tag), BioWorldInfo.m_playerSquad.m_playerPawn, -60.0, -60.0, FALSE);
    return spawnedPawn != None;
}