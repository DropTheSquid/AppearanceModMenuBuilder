Class AMM_Pawn_Parameters_Tali extends AMM_Pawn_Parameters_Squad
    config(Game);

public function string GetAppearanceType(BioPawn targetPawn)
{
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
		// if this is streamed in with the framework or it's in the Salarian Comp of Virmire, count it as combat
		if (targetPawn.GetPackageName() == 'BIONPC_Tali' || targetPawn.GetPackageName() == 'BIOA_JUG20_08_DSG')
		{
			return "combat";
		}
	}
	// otherwise, go with the normal system of relying on the armor override to account for in party with/without casual hubs
    return Super(AMM_Pawn_Parameters_Squad).GetAppearanceType(targetPawn);
}