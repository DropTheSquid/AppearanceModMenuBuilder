class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base
    config(Game);

var Pawn_Parameter_Handler paramHandler;
var transient string outerWorldInfoPath;

public function UpdatePawnAppearance(BioPawn target, string source)
{
	local AMM_Pawn_Parameters params;
	local PawnAppearanceIds appearanceIds;
	local SpecLists specLists;
	local pawnAppearance pawnAppearance;

	UpdateOuterWorldInfo();
	LogInternal("appearance update for target"@PathName(target)@Target.Tag@"from source"@source);
	if (paramHandler.GetPawnParams(target, params))
	{
		params.SpecialHandling(target);
		if (params.GetCurrentAppearanceIds(target, appearanceIds))
		{
			specLists = params.GetSpecLists(target);
			if (specLists.outfitSpecs == None)
			{
				return;
			}
			if (specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, pawnAppearance))
			{
				class'AMM_Utilities'.static.ApplyPawnAppearance(target, pawnAppearance);
			}
		}
		else
		{
			LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		}
	}
}
private function UpdateOuterWorldInfo()
{
	local BioWorldInfo tempWorldInfo;

    tempWorldInfo = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    if (tempWorldInfo.GetPackageName() != 'BIOG_UIWorld')
    {
        outerWorldInfoPath = PathName(tempWorldInfo);
    }
}
public static function bool IsInCharacterCreator(out BioSFHandler_NewCharacter ncHandler)
{
	local AMM_AppearanceUpdater_Base instance;
	local BioWorldInfo BWI;
    local string path;

	if (GetInstance(instance))
	{
		path = AMM_AppearanceUpdater(instance).outerWorldInfoPath;
		BWI = BioWorldInfo(FindObject(path, Class'BioWorldInfo'));
		if (BWI != None)
		{
			ncHandler = BWI.m_UIWorld.m_oNCHandler;
			return ncHandler != None;
		}
		return false;
	}
	return false;
}
public static function bool IsInAMM(out BioSFPanel panel)
{
	local AMM_AppearanceUpdater_Base instance;
	local BioWorldInfo BWI;
    local string path;
	local MassEffectGuiManager guiman;

	if (GetInstance(instance))
	{
		path = AMM_AppearanceUpdater(instance).outerWorldInfoPath;
		BWI = BioWorldInfo(FindObject(path, Class'BioWorldInfo'));
		guiman = MassEffectGuiManager(BWI.GetLocalPlayerController().GetScaleFormManager());
		panel = guiman.GetPanelByTag('AMM');
		return panel != None;
	}
	return false;
}
public static function bool GetPawnParams(BioPawn Target, out AMM_Pawn_Parameters params)
{
	local AMM_AppearanceUpdater_Base instance;

	if (GetInstance(instance) && AMM_AppearanceUpdater(instance) != None)
	{
		return AMM_AppearanceUpdater(instance).paramHandler.GetPawnParams(target, params);
	}
	return false;
}

protected function string ShouldShowHelmetButton(BioPawn Target)
{
	local AMM_Pawn_Parameters params;
	local pawnAppearance noHelmetAppearance;
	local pawnAppearance helmetAppearance;
	local pawnAppearance fullHelmetAppearance;
	local bool hasDistinctHelmetAppearance;
	local bool HasDistinctFullHelmetAppearance;
	local bool HasDistinctBreatherAppearance;

	if (!GetPawnParams(target, params))
	{
		return super.ShouldShowHelmetButton(target);
	}
	params.SpecialHandling(target);
	if (!GetAppearanceForHelmetType(target, params, eHelmetDisplayState.off, noHelmetAppearance)
		|| !GetAppearanceForHelmetType(target, params, eHelmetDisplayState.on, helmetAppearance)
		|| !GetAppearanceForHelmetType(target, params, eHelmetDisplayState.full, fullHelmetAppearance))
	{
		return super.ShouldShowHelmetButton(target);
	}
	// check for differences between all of them
	HasDistinctHelmetAppearance = DoAppearancesDiffer(noHelmetAppearance, helmetAppearance);
	HasDistinctFullHelmetAppearance = DoAppearancesDiffer(helmetAppearance, fullHelmetAppearance);
	HasDistinctBreatherAppearance = DoAppearancesDiffer(noHelmetAppearance, fullHelmetAppearance);
	if (!HasDistinctHelmetAppearance && !HasDistinctFullHelmetAppearance)
	{
		// all are identical; we should not show this button
		return "";
	}
	// if helmet differs from none, but full does not differ from helmet
	// or full differs from none but not from helmet
	if ((HasDistinctHelmetAppearance && !HasDistinctFullHelmetAppearance)
		|| HasDistinctBreatherAppearance && !HasDistinctFullHelmetAppearance)
	{
		// there are two states; have a toggle button
		// "Toggle Helmet"
		return string($174544);
	}
	// the only remaining possibility is that all three are distinct
	// "Cycle Helmet"
	return string($210210248);
}

private function bool GetAppearanceForHelmetType(BioPawn Target, AMM_Pawn_Parameters params, eHelmetDisplayState helmetType, out pawnAppearance appearance)
{
	local PawnAppearanceIds appearanceIds;
	local SpecLists specLists;

	if (params.GetCurrentAppearanceIds(target, appearanceIds))
	{
		specLists = params.GetSpecLists(target);
		if (specLists.outfitSpecs == None)
		{
			return false;
		}
		appearanceIds.m_appearanceSettings.helmetDisplayState = helmetType;
		if (specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, appearance))
		{
			return true;
		}
		return false;
	}
	else
	{
		LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		return false;
	}
}
private function bool DoAppearancesDiffer(pawnAppearance first, pawnAppearance second)
{
	if (first.hideHair != second.HideHair || first.hideHead != second.HideHead)
	{
		return true;
	}
	if (DoAppearanceMeshesDiffer(first.bodyMesh, second.bodyMesh)
		|| DoAppearanceMeshesDiffer(first.HelmetMesh, second.HelmetMesh)
		|| DoAppearanceMeshesDiffer(first.VisorMesh, second.VisorMesh)
		|| DoAppearanceMeshesDiffer(first.BreatherMesh, second.BreatherMesh))
	{
		return true;
	}
	return false;
}

private function bool DoAppearanceMeshesDiffer(AppearanceMesh first, AppearanceMesh second)
{
	local int i;
	if (first.Mesh != second.Mesh)
	{
		return true;
	}
	if (first.Materials.Length != second.Materials.Length)
	{
		return true;
	}
	for (i = 0; i < first.Materials.Length; i++)
	{
		if (first.Materials[i] != second.Materials[i])
		{
			return true;
		}
	}
	return false;
}

public function HelmetButtonPressed(BioPawn Target)
{
	local AMM_Pawn_Parameters params;
	local PawnAppearanceIds appearanceIds;
	local SpecLists specLists;
	local pawnAppearance noHelmetAppearance;
	local pawnAppearance helmetAppearance;
	local pawnAppearance fullHelmetAppearance;
	local bool hasDistinctHelmetAppearance;
	local bool HasDistinctFullHelmetAppearance;
	local bool HasDistinctBreatherAppearance;
	local eHelmetDisplayState currentState;

	if (!GetPawnParams(target, params))
	{
		super.HelmetButtonPressed(target);
		return;
	}
	params.SpecialHandling(target);
	if (!params.GetCurrentAppearanceIds(target, appearanceIds))
	{
		LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		return;
	}
	
	currentState = appearanceIds.m_appearanceSettings.helmetDisplayState;

	if (!GetAppearanceForHelmetType(target, params, eHelmetDisplayState.off, noHelmetAppearance)
		|| !GetAppearanceForHelmetType(target, params, eHelmetDisplayState.on, helmetAppearance)
		|| !GetAppearanceForHelmetType(target, params, eHelmetDisplayState.full, fullHelmetAppearance))
	{
		super.HelmetButtonPressed(target);
		return;
	}
	// check for differences between all of them
	HasDistinctHelmetAppearance = DoAppearancesDiffer(noHelmetAppearance, helmetAppearance);
	HasDistinctFullHelmetAppearance = DoAppearancesDiffer(helmetAppearance, fullHelmetAppearance);
	HasDistinctBreatherAppearance = DoAppearancesDiffer(noHelmetAppearance, fullHelmetAppearance);

	if (currentState == eHelmetDisplayState.off)
	{
		if (HasDistinctHelmetAppearance)
		{
			appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.on;
		}
		else if (HasDistinctBreatherAppearance)
		{
			appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.full;
		}
	}
	else if (currentState == eHelmetDisplayState.on)
	{
		if (HasDistinctFullHelmetAppearance)
		{
			appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.full;
		}
		else if (HasDistinctHelmetAppearance)
		{
			appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.off;
		}
	}
	else if (currentState == eHelmetDisplayState.full)
	{
		if (HasDistinctBreatherAppearance)
		{
			appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.off;
		}
		else if (HasDistinctFullHelmetAppearance)
		{
			appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.on;
		}
	}
	// commit the new helmet preference
	CommitHelmetPreference(target, params, appearanceIds);
}

private function CommitHelmetPreference(BioPawn target, AMM_Pawn_Parameters params, PawnAppearanceIds currentAppearance)
{
	local BioGlobalVariableTable globalVars;
	local AppearanceIdLookups appearanceIdLookups;
	local int flagsPlotInt;
	local int newFlagsValue;
	
	globalVars = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo()).GetGlobalVariables();
	if (params.GetAppearanceIdLookup(params.GetAppearanceType(target), appearanceIdLookups))
	{
		flagsPlotInt = appearanceIdLookups.appearanceFlagsLookup.plotIntId;
		if (flagsPlotInt != 0)
		{
			globalVars.SetInt(flagsPlotInt, class'AMM_Utilities'.static.EncodeAppearanceSettings(currentAppearance.m_appearanceSettings));
		}
	}
}


defaultproperties
{
    Begin Object Class=Pawn_Parameter_Handler Name=paramHandlerInstance
    End Object
    paramHandler = paramHandlerInstance
}
