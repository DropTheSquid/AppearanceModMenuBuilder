class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base
    config(Game);

var Pawn_Parameter_Handler paramHandler;
var transient string outerWorldInfoPath;
var transient int menuHelmetOverride;
var transient name menuTagOverride;

var transient delegate<onAppearanceUpdated> __onAppearanceUpdated__Delegate;

public function SetOnAppearanceUpdatedCallback(delegate<onAppearanceUpdated> fn_onAppearanceUpdatedDelegate)
{
    __onAppearanceUpdated__Delegate = fn_onAppearanceUpdatedDelegate;
}

public delegate function onAppearanceUpdated(BioPawn target, string source);

public function UpdatePawnAppearance(BioPawn target, string source)
{
	local AMM_Pawn_Parameters params;
	local PawnAppearanceIds appearanceIds;
	local SpecLists specLists;
	local pawnAppearance pawnAppearance;
	local MaterialInstanceConstant mic;

	UpdateOuterWorldInfo();
	// this pawn is not yet fully initialized; ignore it
	if (target.Tag == 'BioPawn')
    {
        return;
    }
	if (SFXPawn_Player(target) != None && source ~= "BioPawn.PostBeginPlay")
	{
		// skip this; it will sometimes do incorrect things before the pawn is fully initialized, and it will be called again from SpawnPlayer
		return;
	}
	UpdatePreviewTags(target);
	if (paramHandler.GetPawnParams(target, params))
	{
		params.SpecialHandling(target);
		if (params.isPlayer)
		{
			ApplyPlayerAppearance(target);
		}
		RemoveAIControllerFromPreviews(target);
		LogInternal("appearance update for target"@PathName(target)@Target.Tag@Target.UniqueTag@"from source"@source);
		LogInternal("target is in appearance type"@params.GetAppearanceType(target));
		if (params.GetCurrentAppearanceIds(target, appearanceIds))
		{
			specLists = class'AMM_Utilities'.static.GetSpecLists(target, params);
			if (specLists.outfitSpecs == None)
			{
				return;
			}
			if (specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, pawnAppearance))
			{
				// CheckIfAppearanceDiffersFromDefaults(target, appearanceIds, pawnAppearance);
				class'AMM_Utilities'.static.ApplyPawnAppearance(target, pawnAppearance);

				// if there is an override set, apply that
				if (params.BodyMaterialOverrideMIC != "")
				{
					// unless you have opted out default outfits and this is one of those default outfits
					if (!params.DoNotApplyBodyOverrideToDefaultOutfits || (appearanceIds.bodyAppearanceId != 0 && appearanceIds.bodyAppearanceId != -1))
					{
						mic = MaterialInstanceConstant(DynamicLoadObject(params.BodyMaterialOverrideMIC, class'MaterialInstanceConstant'));
						class'AMM_Utilities'.static.ApplyMaterialOverrides(target.Mesh, mic);
					}
				}
				// otherwise, copy stuff from the headmorph or head materials
				else
				{
					class'AMM_Utilities'.static.UpdatePawnMaterialParameters(target);
				}
			}
			if (__onAppearanceUpdated__Delegate != None)
			{
				__onAppearanceUpdated__Delegate(target, source);
			}
		}
		else
		{
			LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		}
	}
	else
	{
		LogInternal("appearance update with no params for target"@PathName(target)@Target.Tag@Target.UniqueTag@"from source"@source);
	}
}

private function CheckIfAppearanceDiffersFromDefaults(BioPawn target, PawnAppearanceIds appearanceIds, pawnAppearance appearance)
{
	local int i;
	local MaterialInterface matInst;
	local MaterialInstanceConstant mic;

	if (appearanceIds.bodyAppearanceId == 0 && appearanceIds.helmetAppearanceId == 0 && appearanceIds.breatherAppearanceId == 0)
	{
		DoesMeshDiffer(target, appearance.bodyMesh, target.Mesh, "body");
	}
}

private function bool DoesMeshDiffer(BioPawn target, AppearanceMesh appMesh, SkeletalMeshComponent smc, string type)
{
	local int i;
	local MaterialInterface matInst;
	local MaterialInstanceConstant mic;
	local bool differs;
	
	if (PathName(appMesh.Mesh) != pathName(smc.SkeletalMesh))
	{
		LogInternal("WARNING:"@type@"Mesh Differs for target"@target.Tag);
		LogInternal("Original"@PathName(smc.SkeletalMesh));
		LogInternal("Expected"@PathName(appMesh.Mesh));
		differs = true;
	}

	if (smc.GetNumElements() != appMesh.Materials.Length)
	{
		LogInternal("WARNING:"@type@"Materials Differ in length"@target.Tag);
		for (i = 0; i < smc.GetNumElements(); i++)
		{
			matInst = smc.GetMaterial(i);
			LogInternal("Original Mat"@i@PathName(matInst));
			mic = MaterialInstanceConstant(matInst);
			if (mic != None)
			{
				LogInternal("Original Mat"@i@"parent"@pathName(mic.Parent));
			}
		}
		for (i = 0; i < appMesh.Materials.Length; i++)
		{
			LogInternal("Expected Mat"@i@PathName(appMesh.Materials[i]));
		}
		differs = true;
	}
	else
	{
		for (i = 0; i < appMesh.Materials.Length; i++)
		{
			matInst = smc.GetMaterial(i);
			if (matInst.outer == smc.outer && MaterialInstanceConstant(matInst) != None)
			{
				matInst = MaterialInstanceConstant(matInst).Parent;
			}
			if (PathName(matInst) != PathName(appMesh.Materials[i]))
			{
				LogInternal("WARNING:"@type@"Material "@i@"Differs for pawn"@target.Tag);
				LogInternal("Original Mat"@i@PathName(matInst));
				LogInternal("Expected Mat"@i@PathName(appMesh.Materials[i]));
				differs = true;
			}
		}
	}
	return differs;
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

private static final function RemoveAIControllerFromPreviews(BioPawn target)
{
	// ocasionally, an NPC has an AI controller that causes it to move, even in the UI world. It does not need that. 
	// this removes it. 
    if (target.GetPackageName() == 'BIOG_UIWorld' && target.Controller != None)
    {
        target.Controller.UnPossess();
    }
}

private function UpdatePreviewTags(BioPawn target)
{
	// UI world preview pawns don't carry over the tag from their original pawn, instead using the ActorType name as the tag
	// this is usually bad and we want to fix it before we update the appearance
	if (target.GetPackageName() == 'BIOG_UIWorld' && menuTagOverride != 'None')
	{
		// do not overwrite these ones; it will destroy our info about the player's gender
		if (target.tag == 'Human_Male' || target.tag == 'Human_Female')
		{
			menuTagOverride = 'None';
			return;
		}
		target.tag = menuTagOverride;
		menuTagOverride = 'None';
	}
}

private static function BioWorldInfo GetOuterWorldInfo()
{
	local AMM_AppearanceUpdater instance;
	local BioWorldInfo bwi;
    local string path;

	bwi = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    if (bwi.GetPackageName() == 'BIOG_UIWorld')
    {
        instance = GetDLCInstance();
		path = AMM_AppearanceUpdater(instance).outerWorldInfoPath;
		bwi = BioWorldInfo(FindObject(path, Class'BioWorldInfo'));
		return bwi;
    }
	return bwi;
}

public static function bool IsInCharacterCreator(out BioSFHandler_NewCharacter ncHandler)
{
	local AMM_AppearanceUpdater_Base instance;
	local BioWorldInfo BWI;

	BWI = GetOuterWorldInfo();
	if (BWI != None)
	{
		ncHandler = BWI.m_UIWorld.m_oNCHandler;
		return ncHandler != None;
	}
	return false;
}

public static function bool IsInAMM(out BioSFPanel panel)
{
	local BioWorldInfo BWI;
	local MassEffectGuiManager guiman;

	BWI = GetOuterWorldInfo();
	guiman = MassEffectGuiManager(BWI.GetLocalPlayerController().GetScaleFormManager());
	panel = guiman.GetPanelByTag('AMM');
	return panel != None;
}

public static function bool GetPawnParams(BioPawn Target, out AMM_Pawn_Parameters params)
{
	local AMM_AppearanceUpdater_Base instance;

	return GetDlcInstance().paramHandler.GetPawnParams(target, params);
}

public static function AMM_AppearanceUpdater GetDlcInstance()
{
	local AMM_AppearanceUpdater_Base baseInstance;

	if (GetInstance(baseInstance) && AMM_AppearanceUpdater(baseInstance) != None)
	{
		return AMM_AppearanceUpdater(baseInstance);
	}
	return None;
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
		specLists = class'AMM_Utilities'.static.GetSpecLists(target, params);
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
			globalVars.SetInt(flagsPlotInt, class'AMM_Common'.static.EncodeAppearanceSettings(currentAppearance.m_appearanceSettings));
		}
	}
}

public function UpdateHelmetPreference(BioPawn target, bool bPreferVisible, bool bForce)
{
	local BioGlobalVariableTable globalVars;
	local AMM_Pawn_Parameters params;
	local PawnAppearanceIds appearanceIds;

	// first check if the mod setting says to ignore forced helmet stuff; if so, do nothing in response to this
	globalVars = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo()).GetGlobalVariables();
	if (globalVars.GetInt(1593) == 1)
	{
		return;
	}

	// I have not found a situation where I actually need this
	// Shep gets their helmet forced on, but they also have the helmet preference covering that
	// Jenkins same, and without this it doesn't get forced back on if you remove it and reload
	if (bForce)
	{
		return;
	}

	// next, identify who this is applying to
	if (!GetPawnParams(target, params))
	{
		// if it is not a pawn whose parameters we control, do nothing
		return;
	}
	params.SpecialHandling(target);

	if (!params.GetCurrentAppearanceIds(target, appearanceIds))
	{
		LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		return;
	}

	// the preference can upgrade from off to on, but will not downgrade from full to on
	if (appearanceIds.m_appearanceSettings.helmetDisplayState == eHelmetDisplayState.off && bPreferVisible)
	{
		// set the helmet preference to on
		appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.on;
		CommitHelmetPreference(target, params, appearanceIds);
	}
	// if the game requests that the helmet be off, do so as long as the preference is just on
	if (appearanceIds.m_appearanceSettings.helmetDisplayState == eHelmetDisplayState.on && !bPreferVisible)
	{
		// set the helmet preference to off
		appearanceIds.m_appearanceSettings.helmetDisplayState = eHelmetDisplayState.off;
		CommitHelmetPreference(target, params, appearanceIds);
	}
}

// this applies the player headmorph to pawns that do not already have it, such as the romance pawn
public function ApplyPlayerAppearance(BioPawn target)
{
	local SFXSaveGame saveGame;

	saveGame = class'SFXEngine'.static.GetEngine().CurrentSaveGame;
	target.m_oBehavior.m_oAppearanceType.m_oMorphFace = saveGame.LoadMorphHead();
}


defaultproperties
{
    Begin Object Class=Pawn_Parameter_Handler Name=paramHandlerInstance
    End Object
    paramHandler = paramHandlerInstance
}
