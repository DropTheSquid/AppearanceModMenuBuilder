Class AMM_Pawn_Parameters_Squad extends AMM_Pawn_Parameters
    abstract
    config(Game);

// Functions
public function string GetAppearanceType(BioPawn targetPawn)
{
    return Class'AMM_Utilities'.static.IsPawnArmorAppearanceOverridden(targetPawn) ? "casual" : "combat";
}
// public function bool GetExistingPawn(out BioPawn existingPawn, string appearanceType)
// {
//     local BioPawn thePawn;
    
//     return GetPawnFromParty(Tag, existingPawn);
// }
// public function bool spawnPawn(string appearanceType, out BioPawn spawnedPawn)
// {
//     local BioPawn BioPawn;
//     local BioWorldInfo BioWorldInfo;
//     local int characterID;
//     local string TheActorType;
//     local BioAiController henchAI;
//     local BioPlayerSquad henchSquad;
//     local Vector SpawnPoint;
//     local Rotator SpawnRotation;
//     local int nIsHeadGearVisible;
//     local BioSPGame gameInfo;
    
//     BioWorldInfo = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
//     gameInfo = BioSPGame(BioWorldInfo.Game);
//     spawnedPawn = gameInfo.SpawnHenchman(Name(Tag), BioWorldInfo.m_playerSquad.m_playerPawn, -60.0, -60.0, FALSE);
//     return spawnedPawn != None;
// }
// private final function bool GetPawnFromParty(string LookupTag, out BioPawn squadmate)
// {
//     local BioWorldInfo BWI;
//     local MemberData tempsquadMember;
//     local BioPawn Pawn;
    
//     BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
//     if (LookupTag ~= "Player" || LookupTag ~= "Human_Male" || LookupTag ~= "Human_Female")
//     {
//         squadmate = BWI.m_playerSquad.m_playerPawn;
//         return TRUE;
//     }
//     else
//     {
//         foreach BWI.m_playerSquad.Members(tempsquadMember, )
//         {
//             if (string(BioPawn(tempsquadMember.SquadMember).Tag) ~= LookupTag)
//             {
//                 squadmate = BioPawn(tempsquadMember.SquadMember);
//                 return TRUE;
//             }
//         }
//     }
//     return FALSE;
// }
// private final function BioPawn spawnHenchNotInParty(Name pawnTag)
// {
//     local BioPawn BioPawn;
//     local BioWorldInfo BioWorldInfo;
//     local int characterID;
//     local string TheActorType;
//     local BioAiController henchAI;
//     local BioPlayerSquad henchSquad;
//     local Vector SpawnPoint;
//     local Rotator SpawnRotation;
//     local int nIsHeadGearVisible;
//     local BioSPGame gameInfo;
    
//     BioWorldInfo = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
//     gameInfo = BioSPGame(BioWorldInfo.Game);
//     if (!BioWorldInfo.GetCharacterImporter().FindCharacterInfoByName(pawnTag, characterID, TheActorType, nIsHeadGearVisible))
//     {
//         WarnInternal("Cannot determine character info! CANNOT SPAWN HENCHMAN!");
//         return None;
//     }
//     BioPawn = gameInfo.spawnPawn(TheActorType, SpawnPoint, SpawnRotation, FALSE);
//     return BioPawn;
// }

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}