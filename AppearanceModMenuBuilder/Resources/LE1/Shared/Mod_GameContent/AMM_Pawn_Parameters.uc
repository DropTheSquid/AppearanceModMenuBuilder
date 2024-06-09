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

var config string outfitSpecListPath;
var  Object _outfitSpecList;
var config string helmetSpecListPath;
var  Object _helmetSpecList;
var config string breatherSpecListPath;
var  Object _breatherSpecList;
var config string Tag;
var config array<string> alternateTags;
// only relevant for the player
// TODO get rid of this
var config eGender gender;
// when launching the menu for this pawn, what menu should it start in?
var config string menuRootPath;
// basically, what plot ints should it use to store
var config array<AppearanceIdLookups> AppearanceIdLookupsList;
// whether this pawn should ignore the game forcing a helmet. This mostly applies to Tali, since she always has a breather on anyway, and has no vanilla helmet anyway
var config bool bIgnoreForcedHelmet;
// set the max height of the camera in the menu, as this varies based on the height of the character
var config float PreviewCameraMaxHeight;
// allows you to supress the various menu for this character; this can be overridden by mods if you add helmets
var config bool suppressHelmetMenu;
var config bool suppressHatMenu;
var config bool suppressBreatherMenu;
// tells the game to apply the player headmorph and customizations to this pawn. 
var config bool isPlayer;
var config string BodyMaterialOverrideMIC;
var config bool DoNotApplyGlobalParams;

// Returns true if a given pawn should be controlled by these params
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

// allows you to do some special processing to the pawn before their appearance is updated
public function SpecialHandling(BioPawn targetPawn);

// allows you to have more than one appearance type in an override of this
// for example, squadmates have Casual, Combat, and sometimes Romance appearances
// there are also special appearance types for the character creator
public function string GetAppearanceType(BioPawn targetPawn)
{
    return "";
}

// given an appearance type, return what outfit, helmet, and breather should be used, as well as any settings
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
	PawnAppearanceIds.m_appearanceSettings = class'AMM_Common'.static.DecodeAppearanceSettings(GetAppearanceIdValue(lookups.appearanceFlagsLookup, globalVars));
	return true;
}

// as above, but for the current appearance type
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

// given the appearance type, look up how to get the actual values
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

// if the framework is installed and this pawn in frameworked, we prefer to stream them in if possible. THis returns the file to stream in
public function bool GetFrameworkFileForAppearanceType(string appearanceType, out string frameworkFileName)
{
	local AppearanceIdLookups currentLookups;

	if (class'AMM_Common'.static.IsFrameworkInstalled())
	{
		foreach AppearanceIdLookupsList(currentLookups, )
		{
			if (currentLookups.appearanceType ~= appearanceType)
			{
				frameworkFileName = currentLookups.FrameworkFileName;
				return class'AMM_Common'.static.DoesLevelExist(frameworkFileName);
			}
		}
	}
    return false;
}

// the spec lists are usually species+gender specific. Basically a body type.
// this loads the outfit, helmet, and breathers for this pawn
// returned as objects so that you can use this in a new file to add new pawn params without needing to clone half the code
public function Object GetOutfitSpecList(BioPawn target)
{
	local Class outfitSpecListClass;

	if (_outfitSpecList == none)
	{
		outfitSpecListClass = Class<Object>(DynamicLoadObject(outfitSpecListPath, Class'Class'));
        if (outfitSpecListClass != None)
        {
            _outfitSpecList = new outfitSpecListClass;
        }
	}
	return _outfitSpecList;
}

public function Object GetHelmetSpecList(BioPawn target)
{
	local Class helmetSpecListClass;

	if (_helmetSpecList == none)
	{
		helmetSpecListClass = Class<Object>(DynamicLoadObject(helmetSpecListPath, Class'Class'));
        if (helmetSpecListClass != None)
        {
            _helmetSpecList = new helmetSpecListClass;
        }
	}
	return _helmetSpecList;
}

public function Object GetBreatherSpecList(BioPawn target)
{
	local Class breatherSpecListClass;

	if (_breatherSpecList == none)
	{
		breatherSpecListClass = Class<Object>(DynamicLoadObject(breatherSpecListPath, Class'Class'));
        if (breatherSpecListClass != None)
        {
            _breatherSpecList = new breatherSpecListClass;
        }
	}
	return _breatherSpecList;
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
	// good enough for most characters, but too short for Turian or Krogan
	PreviewCameraMaxHeight = 87
	// hide hats by default
	suppressHatMenu=true
}