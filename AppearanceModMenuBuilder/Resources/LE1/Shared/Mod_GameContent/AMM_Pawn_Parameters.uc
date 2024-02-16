Class AMM_Pawn_Parameters
    config(Game);

// Types
struct AppearanceIdLookups 
{
    var string appearanceType;
    var AppearanceIdLookup bodyAppearanceLookup;
    var AppearanceIdLookup helmetAppearanceLookup;
    var AppearanceIdLookup breatherAppearanceLookup;
    var AppearanceIdLookup appearanceFlagsLookup;
    var string FrameworkFileName;
};
struct AppearanceIdLookup 
{
    var int plotIntId;
    var int defaultAppearanceId;
};

// Variables
var transient OutfitSpecListBase __outfitSpecList;
var config string outfitSpecListPath;
// var transient HelmetSpecListBase __helmetSpecList;
// var config string helmetSpecListPath;
// var transient BreatherSpecListBase __breatherSpecList;
// var config string breatherSpecListPath;
// var config int defaultBreatherSpec;
var config string Tag;
var config array<string> alternateTags;
var config eGender gender;
var config string menuRootPath;
var config array<AppearanceIdLookups> AppearanceIdLookupsList;

// Functions
public function bool matchesPawn(BioPawn targetPawn)
{
    local string altTag;
    
    if (string(targetPawn.Tag) ~= Tag)
    {
        return TRUE;
    }
    foreach alternateTags(altTag, )
    {
        if (string(targetPawn.Tag) ~= altTag)
        {
            return TRUE;
        }
    }
    return FALSE;
}

public function SpecialHandling(BioPawn targetPawn);

public function string GetAppearanceType(BioPawn targetPawn)
{
    return "";
}

public function bool GetAppearanceIds(string appearanceType, out PawnAppearanceIds PawnAppearanceIds)
{
	local BioGlobalVariableTable globalVars;
    local AppearanceIdLookups lookups;
    
    globalVars = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo()).GetGlobalVariables();
    if (!GetAppearanceIdLookup(appearanceType, lookups))
    {
        LogInternal("Warning: Could not get appearance ids for appearance type" @ appearanceType, );
        return FALSE;
    }
    PawnAppearanceIds.bodyAppearanceId = GetAppearanceIdValue(lookups.bodyAppearanceLookup, globalVars);
    PawnAppearanceIds.helmetAppearanceId = GetAppearanceIdValue(lookups.helmetAppearanceLookup, globalVars);
    PawnAppearanceIds.breatherAppearanceId = GetAppearanceIdValue(lookups.breatherAppearanceLookup, globalVars);
	return true;
}

public function bool GetCurrentAppearanceIds(BioPawn targetPawn, out PawnAppearanceIds PawnAppearanceIds)
{
	return GetAppearanceIds(GetAppearanceType(targetPawn), PawnAppearanceIds);
}

private final function int GetAppearanceIdValue(AppearanceIdLookup lookup, BioGlobalVariableTable globalVars)
{
    if (lookup.plotIntId != 0)
    {
        return globalVars.GetInt(lookup.plotIntId);
    }
    return lookup.defaultAppearanceId;
}

public function bool GetAppearanceIdLookup(string appearanceType, out AppearanceIdLookups lookups)
{
    local AppearanceIdLookups currentLookups;
    
    foreach AppearanceIdLookupsList(currentLookups, )
    {
        if (currentLookups.appearanceType ~= appearanceType)
        {
            lookups = currentLookups;
            return TRUE;
        }
    }
    return FALSE;
}

public function bool GetFrameworkFileForAppearanceType(string appearanceType, out string frameworkFileName)
{
	local AppearanceIdLookups currentLookups;

	if (class'AMM_Utilities'.static.IsFrameworkInstalled())
	{
		foreach AppearanceIdLookupsList(currentLookups, )
		{
			if (currentLookups.appearanceType ~= appearanceType)
			{
				frameworkFileName = currentLookups.FrameworkFileName;
				return class'AMM_Utilities'.static.DoesLevelExist(frameworkFileName);
			}
		}
	}
    return false;
}

public function OutfitSpecListBase GetOutfitSpecList(BioPawn targetPawn)
{
    local Class<OutfitSpecListBase> specListClass;
    
    if (__outfitSpecList == None)
    {
        specListClass = Class<OutfitSpecListBase>(DynamicLoadObject(outfitSpecListPath, Class'Class'));
        if (specListClass != None)
        {
            __outfitSpecList = new specListClass;
        }
		else
		{
			LogInternal("Warning: could not load spec list"@outfitSpecListPath);
		}
    }
    return __outfitSpecList;
}

// public function HelmetSpecListBase GetHelmetSpecList(BioPawn targetPawn)
// {
//     local Class<HelmetSpecListBase> specListClass;
    
//     if (__helmetSpecList == None)
//     {
//         specListClass = Class<HelmetSpecListBase>(DynamicLoadObject(helmetSpecListPath, Class'Class'));
//         if (specListClass != None)
//         {
//             __helmetSpecList = new specListClass;
//         }
//     }
//     return __helmetSpecList;
// }
// public function BreatherSpecListBase GetBreatherSpecList(BioPawn targetPawn)
// {
//     local Class<BreatherSpecListBase> specListClass;
    
//     if (__breatherSpecList == None)
//     {
//         specListClass = Class<BreatherSpecListBase>(DynamicLoadObject(breatherSpecListPath, Class'Class'));
//         if (specListClass != None)
//         {
//             __breatherSpecList = new specListClass;
//         }
//     }
//     return __breatherSpecList;
// }
// public function string GetRootMenuPath()
// {
//     return menuRootPath;
// }

// find an existing pawn, if possible
public function bool GetExistingPawn(string appearanceType, out BioPawn existingPawn)
{
	return false;
}

// if there is not an existing pawn, but we can synchronously spawn one, do so
public function bool SpawnPawn(string appearanceType, out BioPawn spawnedPawn)
{
	return false;
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}