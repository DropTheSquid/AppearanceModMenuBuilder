Class AMM_Pawn_Parameters_Tali extends AMM_Pawn_Parameters_Squad
    config(Game);

public function string GetAppearanceType(BioPawn targetPawn)
{
	local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
	local name packageName;

	// check if we have the setting to always show Tali in her combat appearance regardless of the situation
    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    globalVars = BWI.GetGlobalVariables();
    if (globalVars.GetInt(1600) != 0)
	{
		return "combat";
	}

	// Normandy unique tag; make sure she shows up as casual here; it is the only time unless Casual Hubs is installed
	if (targetPawn.UniqueTag == 'hench_quarian_engineering')
    {
        return "casual";
    }

	// pre recruitment tags:
	// Tali on the Citadel pre recruitment is set up a bit wrong, so we need to special case this
	// sta60_quarian and sta60_quarian_combat is the alleyway (cutscene vs actual brief combat) and many frameworked appearances
	// sta20_quarian is the embassy conversation; counting as combat becuase there was not time to change after the alleyway fight
	// this should cover the frameworked version of those scenes as well
    if (targetPawn.Tag == 'sta20_quarian' || targetPawn.Tag == 'sta60_quarian' || targetPawn.Tag == 'sta60_quarian_combat')
    {
        return "combat";
    }

	// Hench_quarian is a weird case though. It can either be in party, in which case it is combat unless casual hubs overrides this and makes it casual. 
	// or it can be Virmire, which I think I will count as combat
	if (targetPawn.Tag == 'hench_quarian')
	{
		packageName = targetPawn.GetPackageName();
		switch (packageName)
		{
			case 'BIONPC_Tali':
			case 'BIOA_JUG20_08_DSG':
				// if this is her Non Nor BioNPC file or in the Virmire camp, return combat
				return "combat";
			case 'BIOA_NOR10_04A_DSG':
			case 'BIOA_NOR10_01_DS2':
				// if this is a post mission debrief or the Pre Ilos cutscene, return casual
				return "casual";
			default:
				break;
		}

		// TODO possible also BIOA_NOR_C.hench_quarian as pawnType to identify casual?
	}
	// otherwise, go with the normal system of relying on the armor override to account for in party with/without casual hubs
    return Super(AMM_Pawn_Parameters_Squad).GetAppearanceType(targetPawn);
}

public function string GetMenuRootPath()
{
	local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;

	// check if we have the setting to always show Tali in her combat appearance regardless of the situation
    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    globalVars = BWI.GetGlobalVariables();
    if (globalVars.GetInt(1600) != 0)
	{
		return "AMM_Submenus.Tali.AppearanceSubmenu_Tali_Combined";
	}

	return Super.GetMenuRootPath();
}

