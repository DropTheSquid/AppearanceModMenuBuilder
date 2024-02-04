public function BioPawn SpawnPlayer(BioPlayerController PlayerController, NavigationPoint playerSpawnPoint)
{
    local BioPawn BioPawn;
    local BioPlayerSquad PlayerSquad;
    local BioWorldInfo BioWorldInfo;
    local int PlayerID;
    local string playerActorType;
    local Vector SpawnLocation;
    local Rotator SpawnRotation;
    local int nIsHeadGearVisible;
    
    if (PlayerController == None || playerSpawnPoint == None)
    {
        WarnInternal(GetFuncName() @ "- Cannot spawn player without a player" @ "controller and a starting navigation point!");
        return None;
    }
    BioWorldInfo = BioWorldInfo(WorldInfo);
    if (BioWorldInfo == None)
    {
        WarnInternal("BioWorldInfo is none! CANNOT SPAWN PLAYER!");
        return None;
    }
    if (!BioWorldInfo.GetCharacterImporter().FindPlayerCharacterInfo(PlayerID, playerActorType, nIsHeadGearVisible))
    {
        WarnInternal("Cannot determine default character info! CANNOT SPAWN PLAYER!");
        return None;
    }
    SpawnLocation = playerSpawnPoint.Location;
    SpawnRotation = playerSpawnPoint.Rotation;
    BioWorldInfo.CurrentGame.GetPlayerSpawn(SpawnLocation, SpawnRotation);
    PreloadPackage(playerActorType);
    BioPawn = SpawnPawn(playerActorType, SpawnLocation, SpawnRotation, TRUE);
    BioPawn.SetPhysics(0);
    if (BioPawn == None)
    {
        LogInternal("-= SpawnPlayer =- bioPawn == none!", );
        return None;
    }
    BioPawn.Tag = 'Player';
    PlayerController.Possess(BioPawn, FALSE);
    AdjustHeightOfPawnSpawnedAtNavigationPoint(BioPawn, playerSpawnPoint);
    BioPawn.m_oBehavior.m_oSquadInterface.ChangeToPlayerSquad(PlayerController.PlayerSquadClass, PlayerController.SquadName);
    PlayerSquad = BioPlayerSquad(BioPawn.m_oBehavior.Squad);
    PlayerSquad.Initialize();
    PlayerSquad.m_playerPawn = BioPawn;
    BioWorldInfo.m_playerSquad = PlayerSquad;
    SetupPartyMemberAttributes(BioPawn.m_oBehavior, Class'BioAttributesPawnPlayer');
    if (BioWorldInfo.CurrentGame.GetME2SaveGame() == None || !BioWorldInfo.CurrentGame.GetME2SaveGame().bIsValid)
    {
        PlayerController.InitializeDefaultMapping();
        if (!BioWorldInfo.GetCharacterImporter().LoadCharacterDefinitionByIndex(BioPawn.m_oBehavior, PlayerID))
        {
            WarnInternal("Warning! Failed to load default character definition for pawn " $ BioPawn);
        }
        BioPawn.SetHeadGearVisiblePreference(bool(nIsHeadGearVisible));
        if (BioWorldInfo.GetBioGamerProfile() != None)
        {
            BioWorldInfo.GetBioGamerProfile().UpdateAllOptions();
        }
    }
    else
    {
        LoadPlayer();
    }
    ChallengeScalePersistentLevelPawns();
    BioPawn.m_oBehavior.ForceAppearanceUpdate();
    Class'UnVince'.static.VinceLogTalentInfoPlayerAndSquad(BioPawn, FALSE);
    BioWorldInfo.SetGlobalTlk(!BioPawn.bIsFemale);
    BioPawn.m_oBehavior.EnableBleedOut(TRUE);
	// added this to ensure the player gets updated after the Force appearance update a few lines up
	Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(BioPawn, "BioSPGame.SpawnPlayer");
    return BioPawn;
}