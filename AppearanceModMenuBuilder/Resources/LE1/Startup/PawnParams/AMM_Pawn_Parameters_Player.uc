Class AMM_Pawn_Parameters_Player extends AMM_Pawn_Parameters_Romanceable
    config(Game);

// Variables
var config int CharacterCreatorBodyAppearanceId;

// Functions
public function bool matchesPawn(BioPawn targetPawn)
{
    local bool bIsFemale;
    
    bIsFemale = gender == eGender.Female;
    if (SFXPawn_Player(targetPawn) != None || targetPawn.Tag == 'Player')
    {
        return bIsFemale == targetPawn.bIsFemale;
    }
    return Super.matchesPawn(targetPawn);
}

// public function string GetAppearanceType(BioPawn targetPawn)
// {
//     local BioWorldInfo BWI;
//     local string path;
    
//     path = AMM_AppearanceUpdater(Class'AMM_AppearanceUpdater'.static.GetInstance()).outerWorldInfoPath;
//     BWI = BioWorldInfo(FindObject(path, Class'BioWorldInfo'));
//     if (BWI != None && BWI.m_UIWorld.m_oNCHandler != None)
//     {
//         return "CharacterCreator";
//     }
//     return Super.GetAppearanceType(targetPawn);
// }
// public function bool GetAppearanceIds(string appearanceType, out PawnAppearanceIds PawnAppearanceIds)
// {
//     if (appearanceType ~= "CharacterCreator")
//     {
//         PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId;
//         return TRUE;
//     }
//     return Super(AMM_Pawn_Parameters).GetAppearanceIds(appearanceType, PawnAppearanceIds);
// }
