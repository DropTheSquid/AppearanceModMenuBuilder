class AppearanceUpdater extends Object; // <= harmless, but it makes the code analysis in VS Code happy

// can be called in the DLC mod to make sure the mod is actually installed
static function bool IsMergeModInstalled(out AppearanceUpdater basegamgeInstance)
{
	basegamgeInstance = AppearanceUpdater(FindObject("SFXGame.AppearanceUpdaterInstance", Class'Object'));
	// this lives in SFXGame, so if it is not found, the user has reverted the basegame changes or they were not applied
	// and the mod will not work
    return basegamgeInstance != None;
}

static function bool IsDlcModInstalled(out AppearanceUpdater dlcInstance)
{
	dlcInstance = AppearanceUpdater(FindObject("Startup_MOD_AMM.AMM_AppearanceUpdaterInstance", Class'Object'));
	// this lives in the startup file, so if it if not found, the DLC mod is not installed
	// or hasn't loaded yet, and we should do nothing. 
	return dlcInstance != None;
}

protected final static function bool GetInstance(out AppearanceUpdater instance)
{
	// Return the appropriate instance depending on the state of things
	if (IsDlcModInstalled(instance))
	{
		return true;
	}
	if (IsMergeModInstalled(instance))
	{
		return true;
	}
	// I don't even know how this would happen
	return false;
}

public function UpdatePawnAppearance(BioPawn target, string source)
{
	LogInternal("basegame appearance update for target"@target@"from source"@source);
}

public static function UpdatePawnAppearanceStatic(BioPawn target, string source)
{
	local AppearanceUpdater instance;

	if (GetInstance(instance))
	{
		instance.UpdatePawnAppearance(target, source);
	}
}