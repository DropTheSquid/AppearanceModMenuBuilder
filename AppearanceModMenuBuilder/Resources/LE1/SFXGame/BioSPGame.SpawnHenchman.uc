public event function BioPawn SpawnHenchman(Name pawnTag, Actor Player, float backOffset, float sideOffset, bool spawnLeft)
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
    
    BioWorldInfo = BioWorldInfo(WorldInfo);
    if (BioWorldInfo == None)
    {
        WarnInternal(GetFuncName() @ "- BioWorldInfo is None!" @ "Cannot spawn henchman (" $ pawnTag $ ")!");
        return None;
    }
    nIsHeadGearVisible = 0;
    if (!BioWorldInfo.GetCharacterImporter().FindCharacterInfoByName(pawnTag, characterID, TheActorType, nIsHeadGearVisible))
    {
        WarnInternal("Cannot determine character info! CANNOT SPAWN HENCHMAN!");
        return None;
    }
    PreloadPackage(TheActorType);
    CalculateHenchmanSpawn(Player, backOffset, sideOffset, spawnLeft, SpawnPoint, SpawnRotation);
    BioPawn = SpawnPawn(TheActorType, SpawnPoint, SpawnRotation, FALSE);
    if (BioPawn == None)
    {
        return None;
    }
    SetupPartyMemberAttributes(BioPawn.m_oBehavior, Class'BioAttributesPawnParty');
    if (BioWorldInfo.CurrentGame.GetME2SaveGame().LoadHenchman(pawnTag, BioPawn.m_oBehavior) == FALSE)
    {
		// this code path only runs if this is initializing the character for the first time
        if (!BioWorldInfo.GetCharacterImporter().LoadCharacterDefinitionByIndex(BioPawn.m_oBehavior, characterID))
        {
            WarnInternal("Warning! Failed to load default character definition for pawn " $ BioPawn);
        }
		// this sets the initial helmet preference, which is true for Jenkins, Kaidan, and Ashley per Engine.BIOG_2DA_Characters_X.Characters_Character
        BioPawn.SetHeadGearVisiblePreference(bool(nIsHeadGearVisible));
		// I want to also set this in AMM's settings so they use the right helmet setting initially
		Class'AMM_AppearanceUpdater_Base'.static.UpdateHelmetPreferenceStatic(BioPawn, bool(nIsHeadGearVisible), false);
    }
    BioPawn.m_oBehavior.m_oSquadInterface.ChangeSquads(BioWorldInfo.m_playerSquad);
    if (BioPawn != None)
    {
        henchAI = BioAiController(BioPawn.Controller);
        if (henchAI != None)
        {
            henchAI.PushFollowSquadLeader();
        }
        else
        {
            WarnInternal(GetFuncName() @ "- Could not issue follow command for" @ "henchman with tag (" $ pawnTag $ ")!");
        }
        henchSquad = BioPlayerSquad(BioPawn.m_oBehavior.Squad);
        if (henchSquad != None)
        {
            Class'BioLevelUpSystem'.static.LevelUpPawn(BioPawn, henchSquad.m_nSquadLevel);
            henchSquad.SetMemberFormation(henchSquad.GetMemberIndex(BioPawn), 1);
        }
        else
        {
            WarnInternal(GetFuncName() @ "- Could not level up henchman with tag (" $ pawnTag $ ")!");
        }
    }
    else
    {
        WarnInternal(GetFuncName() @ "- Could not spawn henchman with tag (" $ pawnTag $ ")!");
    }
    Class'UnVince'.static.VinceLogTalentInfoPlayerAndSquad(BioPawn, FALSE);
	// added this to ensure the hench gets updated after their tag and whatnot is actually set up
	Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(BioPawn, "BioSPGame.SpawnHenchman");
    return BioPawn;
}