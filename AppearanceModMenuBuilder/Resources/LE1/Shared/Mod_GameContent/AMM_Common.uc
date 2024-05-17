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
    };
};

public static function AppearanceSettings DecodeAppearanceSettings(int flags)
{
	local int helmetFlags;
    local string comment;
	local AppearanceSettings settings;
    
    // comment = "zero out all bits except the first two, then compare what is left
    helmetFlags = flags & 3; // AKA 0011 in binary
    switch (helmetFlags)
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
			LogInternal("Invalid helmet flag in appearance settings"@helmetFlags);
			settings.helmetDisplayState = eHelmetDisplayState.off;
			break;
    }

	// TODO decode more flags here later
	return settings;
}

public static function int EncodeAppearanceSettings(AppearanceSettings settings)
{
	local int helmetFlags;
	local string comment;

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

	// TODO encode more flags here later
	return helmetFlags; // | otherFlags once there are others
}

public static function bool IsFrameworkInstalled()
{
	return DynamicLoadObject("DLC_MOD_Framework_GlobalTlk.GlobalTlk_tlk", Class'Object') != None;
}

public static function bool DoesLevelExist(coerce string levelName)
{
	return DynamicLoadObject(string(levelName)$".TheWorld", class'World') != None;
}