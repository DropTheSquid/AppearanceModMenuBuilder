Class AMM_Pawn_Parameters_Player extends AMM_Pawn_Parameters_Romanceable
    config(Game);

// Variables
// pre selection/default if not overridden per class
var config int CharacterCreatorBodyAppearanceId;
// class specific body appearance
var config int CharacterCreatorBodyAppearanceId_Soldier;
var config int CharacterCreatorBodyAppearanceId_Engineer;
var config int CharacterCreatorBodyAppearanceId_Adept;
var config int CharacterCreatorBodyAppearanceId_Vanguard;
var config int CharacterCreatorBodyAppearanceId_Sentinel;
var config int CharacterCreatorBodyAppearanceId_Infiltrator;


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

public function string GetAppearanceType(BioPawn targetPawn)
{
	local BioSFHandler_NewCharacter ncHandler;
	local string currentClass;
    
	if (class'AMM_AppearanceUpdater'.static.IsInCharacterCreator(ncHandler))
	{
		if (ncHandler.UIState < NewCharacterUIState.NCMS_Class)
		{
			// pre class selection
			// LogInternal("pre selection CC class"@ncHandler.lstCurrentClass[0]);
			return "CharacterCreator";
		}
		// during/post class selection
		currentClass = string(ncHandler.lstCurrentClass[0]);
		if (currentClass ~= "Soldier")
		{
			return "CharacterCreator_Soldier";
		}
		else if (currentClass ~= "Adept")
		{
			return "CharacterCreator_Adept";
		}
		else if (currentClass ~= "Engineer")
		{
			return "CharacterCreator_Engineer";
		}
		else if (currentClass ~= "Vanguard")
		{
			return "CharacterCreator_Vanguard";
		}
		else if (currentClass ~= "Sentinel")
		{
			return "CharacterCreator_Sentinel";
		}
		else if (currentClass ~= "Infiltrator")
		{
			return "CharacterCreator_Infiltrator";
		}
		else
		{
			LogInternal("unknown CC class \""$currentClass$"\"");
			return "CharacterCreator";
		}
	}
    return Super.GetAppearanceType(targetPawn);
}
public function bool GetAppearanceIds(string appearanceType, out PawnAppearanceIds PawnAppearanceIds)
{
	switch (appearanceType)
	{
		// character creation pre class selection
		case "CharacterCreator":
			PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId;
			return true;
		// character creation during/post class selection
		case "CharacterCreator_Soldier":
			PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId_Soldier;
			return true;
		case "CharacterCreator_Adept":
			PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId_Adept;
			return true;
		case "CharacterCreator_Engineer":
			PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId_Engineer;
			return true;
		case "CharacterCreator_Vanguard":
			PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId_Vanguard;
			return true;
		case "CharacterCreator_Sentinel":
			PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId_Sentinel;
			return true;
		case "CharacterCreator_Infiltrator":
			PawnAppearanceIds.bodyAppearanceId = CharacterCreatorBodyAppearanceId_Infiltrator;
			return true;
		// every other circumstance
		default:
			return Super(AMM_Pawn_Parameters).GetAppearanceIds(appearanceType, PawnAppearanceIds);
	}
}
