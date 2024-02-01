public function Pawn SpawnPlayerSquadMembers(BioPlayerController PlayerController, NavigationPoint SpawnPoint)
{
    local BioPawn Player;
    local BioPawn henchman;
    local BioWorldInfo BioWorldInfo;
    local int I;
    local int numHench;
    local BioGlobalVariableTable oGV;
    local PartySelectMemberInfo partyInfo;
    
    BioWorldInfo = BioWorldInfo(WorldInfo);
    oGV = BioWorldInfo.GetGlobalVariables();
    Player = SpawnPlayer(PlayerController, SpawnPoint);
	// could do this inside SpawnPlayer. not sure if there is any benefit to doing so. 
	Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(Player, "BioSPGame.SpawnPlayerSquadMembers - Player");
    if (Player == None)
    {
        WarnInternal(GetFuncName() @ "Failed to spawn player!");
    }
    else
    {
        numHench = 0;
        for (I = 0; I < Class'BioSFHandler_PartySelection'.default.lstMemberInfo.Length && numHench < 2; I++)
        {
            partyInfo = Class'BioSFHandler_PartySelection'.default.lstMemberInfo[I];
            if (oGV.GetBoolByName(partyInfo.InPartyLabel) == TRUE)
            {
                henchman = SpawnHenchman(partyInfo.Tag, Player, -60.0, -60.0, numHench < 1);
                if (henchman != None)
                {
					// I could also technically do this inside of SpawnHenchman, but I don't currently see any beneft to this
					// maybe if it is used elsewhere like the lockers it could be worth it
					Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(henchman, "BioSPGame.SpawnPlayerSquadMembers - henchman");
                    ++numHench;
                }
            }
        }
    }
    return PlayerController.Pawn;
}