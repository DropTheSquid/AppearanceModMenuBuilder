Class AMM_AppearanceUpdater_Base;

public static function bool IsMergeModInstalled(out AMM_AppearanceUpdater_Base basegamgeInstance)
{
	basegamgeInstance = AMM_AppearanceUpdater_Base(FindObject("SFXGame.AMM_AppearanceUpdater_Base_0", Class'Object'));
	// this lives in SFXGame, so if it is not found, the user has reverted the basegame changes or they were not applied
	// and the mod will not work
	LogInternal("IsMergeModInstalled?"@basegamgeInstance != None);
	return basegamgeInstance != None;
}

public static function bool IsDlcModInstalled(out AMM_AppearanceUpdater_Base dlcInstance)
{
	dlcInstance = AMM_AppearanceUpdater_Base(FindObject("Startup_MOD_AMM.AMM_AppearanceUpdater_0", Class'Object'));
	// this lives in the startup file, so if it if not found, the DLC mod is not installed
	// or hasn't loaded yet, and we should do nothing.
	LogInternal("IsDlcModInstalled?"@dlcInstance != None);
	return dlcInstance != None;
}

protected final static function bool GetInstance(out AMM_AppearanceUpdater_Base instance)
{
	// Return the appropriate instance depending on the state of things
	if (IsDlcModInstalled(instance))
	{
		LogInternal("GetInstance DLC"@PathName(instance));
		return true;
	}
	if (IsMergeModInstalled(instance))
	{
		LogInternal("GetInstance Basegame"@PathName(instance));
		return true;
	}
	// I don't even know how this would happen
	return false;
}
public static function bool LoadMorphHeadStatic(out PlayerSaveRecord ThePlayerRecord, out BioMorphFace morphHead)
{
    local AMM_AppearanceUpdater_Base instance;

	if (GetInstance(instance))
	{
		return instance.LoadMorphHead(ThePlayerRecord, morphHead);
	}
    return false;
}
public function bool LoadMorphHead(out PlayerSaveRecord ThePlayerRecord, out BioMorphFace morphHead)
{
    return false;
}
public static function bool SaveMorphHeadStatic(BioMorphFace Morph, out MorphHeadSaveRecord Record, out bool result)
{
    local AMM_AppearanceUpdater_Base instance;

	if (GetInstance(instance))
	{
		return instance.SaveMorphHead(Morph, Record, result);
	}
    return false;
}
public function bool SaveMorphHead(BioMorphFace Morph, out MorphHeadSaveRecord Record, out bool result)
{
    return false;
}
public static function bool UpdatePlayerAppearanceStatic(SFXPawn_Player target, bool part2, out bool callSuper)
{
    local AMM_AppearanceUpdater_Base instance;

	if (GetInstance(instance))
	{
		return instance.UpdatePlayerAppearance(target, part2, callsuper);
	}
    return false;
}

public function bool UpdatePlayerAppearance(SFXPawn_Player target, bool part2, out bool callSuper)
{
    return false;
}
