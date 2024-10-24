Class AMM_Pawn_Parameters_Garrus extends AMM_Pawn_Parameters_Squad
    config(Game);

public function string GetAppearanceType(BioPawn targetPawn)
{
	// all Garrus appearances:
	// pre recruitment in Med Clinic (sta60_Garrus)
	// late pre recruitment in CSec
	// in party w/ or w/o casual hubs
	// Virmire
	// Normandy
	// normandy debrief?

	// pre recruitment tags:
	// sta60_Garrus is med clinic recruitment (both cutscene and combat I think; need to confirm)
	// he should be in Combat appearance, and he will join the party immediately after this
	// sta70_garrus is Garrus in Citadel tower before you talk to the council the first time
    if (targetPawn.Tag == 'sta60_garrus' || targetPawn.Tag == 'sta70_garrus')
    {
        return "combat";
    }

	// hench_turian is a weird case though. It can either be in party, in which case it is combat unless casual hubs overrides this and makes it casual.
	// or it can be Virmire/CSec for late recruitment, which I think I will count as combat
	if (targetPawn.Tag == 'hench_turian')
	{
		// if this is streamed in with the framework or it's in the Salarian Camp on Virmire, or the late recruitment pickup in csec count it as combat
		if (targetPawn.GetPackageName() == 'BIONPC_Garrus' || targetPawn.GetPackageName() == 'BIOA_JUG20_08_DSG' || targetPawn.GetPackageName() == 'BIOA_STA30_01_DSG')
		{
			return "combat";
		}
	}
	// otherwise, go with the normal system of relying on the armor override to account for in party with/without casual hubs
    return Super.GetAppearanceType(targetPawn);
}
