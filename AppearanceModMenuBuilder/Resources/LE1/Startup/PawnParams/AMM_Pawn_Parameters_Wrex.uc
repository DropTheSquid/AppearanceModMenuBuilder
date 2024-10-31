Class AMM_Pawn_Parameters_Wrex extends AMM_Pawn_Parameters_Squad
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

	// if casual hubs garrus + wrex option is installed
	if (IsCasualHubsGarrusWrexOptionInstalled(pawnType))
	{
		// BIOA_NOR10_11_DSG is the vehicle bay
		// BIOA_NOR10_01patton_DSG is the speech upon leaving the citadel as a spectre for the first time
		// BIOA_NOR10_04A_DSG is the various post mission debriefs
		// BIOA_STA60_05A_DSG is his appearance in Chora's den, which can be armor or casual depending on the situation with the Casual Hubs option installed
		// include BIOA_STA60_05A_DSG with a plot var check
		if ( // Normandy Garage
			packageName == 'BIOA_NOR10_11_DSG'
			// speech upon first leaving the citadel
			|| packageName == 'BIOA_NOR10_01patton_DSG'
			// post mission debriefs
			|| packageName == 'BIOA_NOR10_04A_DSG'
			// in chora's den && conditional 1367 (Wrex Waiting in Chora's Den) && bool 4117 (left citadel to start the story proper)
			|| (packageName == 'BIOA_STA60_05A_DSG' && BWI.CheckConditional(1367) && globalVars.GetBool(4117)))
		{
			// replace the pawnType on the actor with the one from their hench file so their casual outfits work correctly
			// but put it on the pawn behavior, not the pawn type because that will affect other things too
			targetPawn.m_oBehavior.m_oActorType = pawnType;
			targetPawn.m_oBehavior.m_bArmorOverridden = true;
		}
	}
	else if (!Class'AMM_Common'.static.IsFrameworkInstalled() && packageName == 'BIOG_UIWORLD')
	{
		// this is a non-framework specific issue (EG there is no issue when framework is installed):
		// if we are in the menu trying to customize Wrex's casual appearance
		// we are relying on the spawned in combat pawn
		// who has the wrong settings on his pawn. He is configured for HVYa 6
		// while his Normandy appearance is MEDa 7

		// either the framework or the Casual Hubs option will fix this instead

		// if the framework is not installed
		pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
		// and it has his default combat appearance set
		if (pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_HEAVY && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant == 0 && pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig == 6)
		{
			// the overwrite it with his default Normandy appearance
			pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType = EBioArmorType.ARMOR_TYPE_MEDIUM;
			pawnType.m_oAppearanceSettings.m_oBodySettings.m_nModelVariant = 0;
			pawnType.m_oAppearanceSettings.m_oBodySettings.m_nMaterialConfig = 7;
			// this will not match his overridden appearance if a mod has changed that only in the Normandy files
			// I accept this limitation. The Framework addresses this issue.
		}
	}
}

private function bool IsCasualHubsGarrusWrexOptionInstalled(out BioPawnType pawnType)
{
	return DynamicLoadObject("DLC_MOD_CasualHubs_GlobalTlk.GlobalTlk_tlk", class'Object', true) != None
		// and we can get the actorType for Wrex
        && class'AMM_Utilities'.static.GetActorType("Hench_Krogan", pawnType)
		// and it is in Clothing (casual hubs Garrus/Wrex option)
		&& pawnType.m_oAppearanceSettings.m_oBodySettings.m_eArmorType == EBioArmorType.ARMOR_TYPE_CLOTHING;
}

public function string GetAppearanceType(BioPawn targetPawn)
{
	local name packageName;
	local BioWorldInfo BWI;
	local BioGlobalVariableTable globalVars;
	local BioPawnType _;

	BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
	globalVars = BWI.GetGlobalVariables();
	packageName = targetPawn.GetPackageName();

	// Wrex has a few weird appearances. He appears in CSec (BIOA_STA30_01_DSG) to recruit him before taking on Fist or after taking on Fist
	// and in Chora's den before talking to Barla Von/Garrus, and after you refuse him in CSec
	if (targetPawn.Tag == 'hench_krogan')
	{
		// if this is streamed in with the framework or it's in the Salarian Camp on Virmire, or the normal recruitment pickup in csec count it as combat
		if ( // framework streamed in
			packageName == 'BIONPC_Wrex'
			// virmire camp
			|| packageName == 'BIOA_JUG20_08_DSG'
			// csec
			|| packageName == 'BIOA_STA30_01_DSG')
		{
			return "combat";
		}
		// chora's den
		else if (packageName == 'BIOA_STA60_05A_DSG')
		{
			// is this the casual hubs late recruit after you have left the citadel?
			if (IsCasualHubsGarrusWrexOptionInstalled(_) && BWI.CheckConditional(1367) && globalVars.GetBool(4117))
			{
				return "casual";
			}
			return"combat";
		}
	}
	// otherwise, go with the normal system of relying on the armor override to account for in party with/without casual hubs
	return Super(AMM_Pawn_Parameters_Squad).GetAppearanceType(targetPawn);
}
