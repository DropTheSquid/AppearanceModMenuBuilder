Class AMM_Pawn_Parameters_Garrus extends AMM_Pawn_Parameters_Squad
    config(Game);

public function SpecialHandling(BioPawn targetPawn)
{
	local BioPawnType pawnType;
	local name packageName;
	local BioWorldInfo BWI;
	local BioGlobalVariableTable globalVars;

	BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
	globalVars = BWI.GetGlobalVariables();


	packageName = targetPawn.GetPackageName();

	if (IsCasualHubsGarrusWrexOptionInstalled(pawnType))
	{
		if ( // Normandy garage
			packageName == 'BIOA_NOR10_11_DSG'
			// speech when first leaving the citadel
			|| packageName == 'BIOA_NOR10_01patton_DSG'
			// post mission debriefs
			|| packageName == 'BIOA_NOR10_04A_DSG'
			// CSec - !Garrus waiting to congratulate you && Garrus previously refused && you have left the citadel already
			|| (packageName == 'BIOA_STA30_01_DSG' && !BWI.CheckConditional(790) && BWI.CheckConditional(1368) && globalVars.GetBool(4117)))
		{
			// replace the pawnType on the actor with the one from their hench file so their casual outfits work correctly
			// and set it to be armor override
			targetPawn.m_oBehavior.m_oActorType = pawnType;
			targetPawn.m_oBehavior.m_bArmorOverridden = true;
		}
	}
}

private function bool IsCasualHubsGarrusWrexOptionInstalled(out BioPawnType pawnType)
{
	return DynamicLoadObject("DLC_MOD_CasualHubs_GlobalTlk.GlobalTlk_tlk", class'Object', true) != None
		// and we can get the actorType for Garrus
        && class'AMM_Utilities'.static.GetActorType("Hench_Turian", pawnType)
		// and it is in Clothing (casual hubs Garrus/Wrex option)
		&& pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_CLOTHING;
}

public function string GetAppearanceType(BioPawn targetPawn)
{
	// all Garrus appearances:
	// pre recruitment in Med Clinic (sta60_Garrus)
	// late pre recruitment in CSec
	// in party w/ or w/o casual hubs
	// Virmire
	// Normandy
	// normandy debrief?
	local name packageName;
	local BioPawnType _;
	local BioWorldInfo BWI;
	local BioGlobalVariableTable globalVars;

	BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
	globalVars = BWI.GetGlobalVariables();

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
		packageName = targetPawn.GetPackageName();
		// if this is streamed in with the framework or it's in the Salarian Camp on Virmire, or the late recruitment pickup in csec count it as combat
		if (packageName == 'BIONPC_Garrus' || packageName == 'BIOA_JUG20_08_DSG')
		{
			return "combat";
		}
		else if (packageName == 'BIOA_STA30_01_DSG')
		{
			// is Casual Hubs installed and is this a late recruit after having left the citadel once?
			if (IsCasualHubsGarrusWrexOptionInstalled(_) && !BWI.CheckConditional(790) && BWI.CheckConditional(1368) && globalVars.GetBool(4117))
			{
				return "casual";
			}
			return "combat";
		}
	}
	// otherwise, go with the normal system of relying on the armor override to account for in party with/without casual hubs
    return Super.GetAppearanceType(targetPawn);
}
