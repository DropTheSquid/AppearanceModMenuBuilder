class AMM_AppearanceUpdater_Base extends Object; // <= harmless, but it makes the code analysis in VS Code happy

// main entrance point; call this from anywhere and it will handle the rest
public static function UpdatePawnAppearanceStatic(BioPawn target, string source)
{
	local AMM_AppearanceUpdater_Base instance;

	if (GetInstance(instance))
	{
		instance.UpdatePawnAppearance(target, source);
	}
}

// to be overridden by the DLC version of this class
public function UpdatePawnAppearance(BioPawn target, string source);

// can be called in the DLC mod to make sure the mod is actually installed
public static function bool IsMergeModInstalled(out AMM_AppearanceUpdater_Base basegamgeInstance)
{
	basegamgeInstance = AMM_AppearanceUpdater_Base(FindObject("SFXGame.AMM_AppearanceUpdater_Base_0", Class'Object'));
	// this lives in SFXGame, so if it is not found, the user has reverted the basegame changes or they were not applied
	// and the mod will not work
	return basegamgeInstance != None;
}

public static function bool IsDlcModInstalled(out AMM_AppearanceUpdater_Base dlcInstance)
{
	dlcInstance = AMM_AppearanceUpdater_Base(FindObject("Startup_MOD_AMM.AMM_AppearanceUpdater_0", Class'Object'));
	// this lives in the startup file, so if it if not found, the DLC mod is not installed
	// or hasn't loaded yet, and we should do nothing. 
	return dlcInstance != None;
}

protected final static function bool GetInstance(out AMM_AppearanceUpdater_Base instance)
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
