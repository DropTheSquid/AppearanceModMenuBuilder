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
struct SpecLists
{
	var OutfitSpecListBase outfitSpecs;
	var HelmetSpecListBase helmetSpecs;
	var BreatherSpecListBase breatherSpecs;
};

// Variables
var transient SpecLists __SpecLists;
var transient bool __specListsInitialized;
var config string outfitSpecListPath;
var config string helmetSpecListPath;
var config string breatherSpecListPath;
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
	PawnAppearanceIds.m_appearanceSettings = class'AMM_Utilities'.static.DecodeAppearanceSettings(GetAppearanceIdValue(lookups.appearanceFlagsLookup, globalVars));
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

public function SpecLists GetSpecLists(BioPawn target)
{
	local Class<OutfitSpecListBase> outfitSpecListClass;
	local Class<HelmetSpecListBase> helmetSpecListClass;
	local Class<BreatherSpecListBase> breatherSpecListClass;
    
    if (!__specListsInitialized)
    {
        outfitSpecListClass = Class<OutfitSpecListBase>(DynamicLoadObject(outfitSpecListPath, Class'Class'));
        if (outfitSpecListClass != None)
        {
            __SpecLists.outfitSpecs = new outfitSpecListClass;
        }
		else
		{
			LogInternal("Warning: could not load outfit spec list"@outfitSpecListPath);
		}
		helmetSpecListClass = Class<HelmetSpecListBase>(DynamicLoadObject(helmetSpecListPath, Class'Class'));
        if (helmetSpecListClass != None)
        {
            __SpecLists.helmetSpecs = new helmetSpecListClass;
        }
		else
		{
			LogInternal("Warning: could not load helmet spec list"@helmetSpecListPath);
		}
		breatherSpecListClass = Class<BreatherSpecListBase>(DynamicLoadObject(breatherSpecListPath, Class'Class'));
        if (breatherSpecListClass != None)
        {
            __SpecLists.breatherSpecs = new breatherSpecListClass;
        }
		else
		{
			LogInternal("Warning: could not load breather spec list"@breatherSpecListPath);
		}
		__specListsInitialized = true;
    }
    return __SpecLists;
}

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