class AMM_Common;

enum eMenuHelmetOverride
{
    unchanged,
    Off,
    On,
    Full,
	onOrFull,
	offOrOn,
	offOrFull
};

enum eGender
{
    Either,
    Male,
    Female,
};

enum eHelmetDisplayState
{
	off,
	on,
	full
};

struct PawnAppearanceIds
{
	// the id of the spec to use
    var int bodyAppearanceId;
    var int helmetAppearanceId;
    var int breatherAppearanceId;
	var AppearanceSettings m_appearanceSettings;
    // various bools which can be encoded in an int for most characters
    struct AppearanceSettings
    {
        var eHelmetDisplayState helmetDisplayState;
		// for non squad characters, by default their helmet visibility will be locked to default
		// if this is turned on, then it will respect the setting above
		var bool bOverridedefaultHeadgearVisibility;
    };
};

public static function AppearanceSettings DecodeAppearanceSettings(int flags)
{
	local int helmetDisplayState;
	local AppearanceSettings settings;
    
    // zero out all bits except the first two, then compare what is left
    helmetDisplayState = flags & 3; // AKA 0011 in binary
    switch (helmetDisplayState)
    {
		case 0:
			settings.helmetDisplayState = eHelmetDisplayState.off;
			break;
        case 1:
            settings.helmetDisplayState = eHelmetDisplayState.on;
			break;
        case 2:
            settings.helmetDisplayState = eHelmetDisplayState.full;
			break;
		default:
			LogInternal("Invalid helmet display state in appearance settings"@helmetDisplayState);
			settings.helmetDisplayState = eHelmetDisplayState.off;
			break;
    }

	// if the 4 bit AKA 0100 is set, this is true
	settings.bOverridedefaultHeadgearVisibility = (flags & 4) != 0;

	// TODO decode more flags here later
	return settings;
}

public static function int EncodeAppearanceSettings(AppearanceSettings settings)
{
	local int helmetFlags;
	local int overrideHeadgearFlag;

	switch (settings.helmetDisplayState)
	{
		case eHelmetDisplayState.off:
			helmetFlags = 0;
			break;
		case eHelmetDisplayState.on:
			helmetFlags = 1;
			break;
		case eHelmetDisplayState.full:
			helmetFlags = 2;
			break;
	}

	overrideHeadgearFlag = settings.bOverridedefaultHeadgearVisibility ? 4 : 0;

	// TODO encode more flags here later
	return helmetFlags | overrideHeadgearFlag; // | otherFlags once there are others
}

public static function bool IsFrameworkInstalled()
{
	return DynamicLoadObject("DLC_MOD_Framework_GlobalTlk.GlobalTlk_tlk", Class'Object') != None;
}

public static function bool DoesLevelExist(coerce string levelName)
{
	return DynamicLoadObject(string(levelName)$".TheWorld", class'World') != None;
}