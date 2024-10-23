Class ModHandler_AMM extends ModMenuBase;

// this defines the state of what pawn we should be displaying, based on the current stack of menus
// so if we are under a menu for Kaidan, the pawn will be Kaidan, even if the current menu is not specific to him
// this allows you to structure things to reuse generic menus under specific menus
struct menuState 
{
    var string pawnTag;
    var eArmorOverrideState armorOverrideState;
    var AMM_Pawn_Parameters params;
    var AppearanceIdLookups AppearanceIdLookups;
    var string appearanceTypeOverride;
    var eMenuHelmetOverride currentMenuHelmetOverride;
	var string inheritedTitle;
	var string inheritedSubtitle;
    var string cameraPosition;
};

// Variables
var name MovieTag;
var transient string launchParam;
var transient AMM_Pawn_Handler pawnHandler;
var stringref srBack;
var stringref srClose;
var stringref srDefaultActionText;
var stringref srOpenSubmenu;
var stringref srSelectCharacter;
var transient array<AppearanceItemData> currentDisplayItems;
var transient array<AppearanceSubmenu> submenuStack;
var string RootSubmenuPath;
var transient bool launchedInPrologue;
var transient Pawn_Parameter_Handler paramHandler;
var transient AMM_Camera_Handler cameraHandler;
var transient AMM_DialogBox_Handler dialogHandler;
var transient bool isAppearanceDirty;
// var transient eMenuHelmetOverride chosenMenuHelmetVisibilityOverride;
var GFxMovieInfo movieInfo;
var transient bool GameWasPaused;
var transient bool rightClickHeld;
var transient string lastCameraPosition;

// overrides the same function in CustomUIHandlerInterface; this signature must stay the same
public static function CustomUIHandlerInterface LaunchMenu(optional string Param)
{
    local BioSFPanel oNewPanel;
    local ModHandler_AMM Handler;
    local MassEffectGuiManager manager;
    
    // LogInternal("Launching menu with param" @ Param, );
    manager = GetManager();
    oNewPanel = manager.CreatePanel(default.MovieTag, FALSE);
	oNewPanel.AttachDefaultHandler();
	// ensures it isn't transparent during prologue/when launched from sequence
    oNewPanel.bFullScreen = TRUE;
    Handler = ModHandler_AMM(oNewPanel.GetDefaultHandler());
    Handler.launchParam = Param;
	if (Param ~= "prologue")
    {
        Handler.launchedInPrologue = TRUE;
    }
    manager.AddPanel(oNewPanel, FALSE, FALSE);

    return Handler;
}
private final function menuState getMenuState()
{
    local menuState newState;
    local int i;
    local AppearanceSubmenu currentSubmenu;
	local string currentTitle;
	local string currentSubtitle;
    
    for (i = 0; i < submenuStack.Length; i++)
    {
        currentSubmenu = submenuStack[i];
        if (currentSubmenu.pawnTag != "")
        {
            newState.pawnTag = currentSubmenu.pawnTag;
            paramHandler.GetPawnParamsByTag(string(Name(newState.pawnTag)), newState.params);
        }
        if (currentSubmenu.pawnAppearanceType != "")
        {
            newState.appearanceTypeOverride = currentSubmenu.pawnAppearanceType;
            newState.params.GetAppearanceIdLookup(currentSubmenu.pawnAppearanceType, newState.AppearanceIdLookups);
        }
        if (currentSubmenu.armorOverride != eArmorOverrideState.unchanged)
        {
            newState.armorOverrideState = currentSubmenu.armorOverride;
        }
        if (currentSubmenu.menuHelmetOverride != eMenuHelmetOverride.unchanged)
        {
            newState.currentMenuHelmetOverride = currentSubmenu.menuHelmetOverride;
        }
		SetTitleCustomTokens(newState);
		if (currentSubmenu.UseTitleForChildMenus)
		{
			newState.inheritedTitle = GetString(currentSubmenu.sTitle, currentSubmenu.srTitle);
		}
		if (currentSubmenu.UseSubtitleForChildMenus)
		{
			newState.inheritedSubtitle = GetString(currentSubmenu.sSubtitle, currentSubmenu.srSubtitle);
		}
        if (currentSubmenu.cameraPosition != "")
        {
            newState.cameraPosition = currentSubmenu.cameraPosition;
        }
    }
    return newState;
}
private static final function MassEffectGuiManager GetManager()
{
    return MassEffectGuiManager(BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo()).GetLocalPlayerController().GetScaleFormManager());
}
public function OnPanelAdded()
{
    local AMM_Pawn_Parameters params;

    // store this so it definitely stays in memory
    movieInfo = GFxMovieInfo(FindObject("GUI_MOD_AMM.ModMenu", class'GFxMovieInfo'));
	// set up the background so it animates
    GetManager().SetupBackground();
	// save whether it was paused, pause it either way
	GameWasPaused = oWorldInfo.bPlayersOnly;
    oWorldInfo.bPlayersOnly = true;
    // LogInternal("Panel added; launch param:" @ launchParam @ "launched in prologue?"@launchedInPrologue);
    pawnHandler = new (Self) Class'AMM_Pawn_Handler';
	pawnHandler.Init(self);
    paramHandler = new Class'Pawn_Parameter_Handler';
    cameraHandler = new Class'AMM_Camera_Handler';
    cameraHandler.Init(self);
	// if we launched from the prologue, just start at character selection
	if (launchedInPrologue)
	{
		RootSubmenuPath = default.RootSubmenuPath;
	}
	// check next if this is a submenu path
	else if (LoadSubmenu(launchParam) != None)
    {
        RootSubmenuPath = launchParam;
    }
	// finally, check if it is a pawn tag and look up the root menu from there
    else if (paramHandler.GetPawnParamsByTag(launchParam, params))
    {
        RootSubmenuPath = params.GetMenuRootPath();
    }
    SetRootSubmenu(RootSubmenuPath);
	class'AMM_AppearanceUpdater'.static.GetDlcInstance().SetOnAppearanceUpdatedCallback(OnAppearanceUpdated);
    Super.OnPanelAdded();
}

public function OnAppearanceUpdated(BioPawn target, string source)
{
	RefreshHelmetButton();
}

public function OnRemoteEvent(name EventName)
{
    pawnHandler.OnRemoteEvent(EventName);
}

public function Close()
{
	local AMM_AppearanceUpdater updaterInstance;

	updaterInstance = class'AMM_AppearanceUpdater'.static.GetDlcInstance();
	updaterInstance.menuHelmetOverride = int(eMenuHelmetOverride.unchanged);

    pawnHandler.Cleanup();
    cameraHandler.Cleanup();
	if (dialogHandler != None)
	{
		dialogHandler.Cleanup();
	}
    
    // clear this before we update all actor appearances
	updaterInstance.SetOnAppearanceUpdatedCallback(None);

	// make sure we run this. it might be redundant in many cases, but it is better to do it twice than not at all when we should
	UpdateAllActorAppearances();
    // updater = AMM_AppearanceUpdater(Class'AMM_AppearanceUpdater'.static.GetInstance());
    // updater.appearanceTypeOverride = "";
    // updater.tempHelmetOverride = eMenuHelmetOverride.unchanged;
	// restore whether it was paused
	oWorldInfo.bPlayersOnly = GameWasPaused;

    Super.Close();
}

// called by Pawn Handler when an async loaded pawn finishes loading or fails
public function UpdateAsyncPawnLoadingState(string tag, string appearanceType, PawnLoadState state)
{
	local menuState menuState;

	menuState = getMenuState();
	if (menuState.pawnTag == tag && menuState.appearanceTypeOverride == appearanceType)
	{
		if (state == PawnLoadState.Loaded)
		{
			cameraHandler.ResetCameraForCharacter(tag);
			pawnHandler.DisplayPawn(tag, appearanceType);
			RefreshHelmetButton();
		}
		// TODO get rid of the loading spinner here
	}
}

public function SetRootSubmenu(string submenuPath)
{
    submenuStack.Length = 0;
    submenuStack.AddItem(LoadSubmenu(submenuPath));
}
public static function AppearanceSubmenu LoadSubmenu(string submenuPath, optional ModHandler_AMM outerMenu)
{
    local Class<AppearanceSubmenu> SubmenuClass;
    
    SubmenuClass = Class<AppearanceSubmenu>(DynamicLoadObject(submenuPath, Class'Class'));
    if (SubmenuClass != None)
    {
        return new (outerMenu) SubmenuClass;
    }
    return None;
}
public function PushSubmenu(string submenuPath)
{
    PushSubmenuInstance(LoadSubmenu(submenuPath));
}
public function PushSubmenuInstance(AppearanceSubmenu instance)
{
    local AppearanceSubmenu currentSubmenu;
    
    currentSubmenu = GetCurrentSubmenu();
    if (currentSubmenu != None)
    {
        currentSubmenu.scrollIndex = ASGetListScrollPosition();
    }
    submenuStack.AddItem(instance);
    RefreshMenu(TRUE);
}
public function PopSubmenu()
{
    if (submenuStack.Length > 0)
    {
        submenuStack.Length = submenuStack.Length - 1;
    }
    RefreshMenu(TRUE);
}
public event function Update(float fDeltaT)
{
	local vector cameraMove;

	SetMouseShown(!oPanel.bUsingGamepad && !rightClickHeld);
	pawnHandler.Update(fDeltaT);
	cameraHandler.Update(fDeltaT);
}
public function RefreshMenu(optional bool firstEnter = FALSE)
{
    local AppearanceSubmenu currentMenu;
    local bool IsUnderCharacterSelect;
    local menuState state;
    local AMM_AppearanceUpdater updaterInstance;
    
    currentMenu = GetCurrentSubmenu();
    // LogInternal("Refreshing menu" @ currentMenu);
    if (currentMenu == None)
    {
        return;
    }
    if (!currentMenu.OnRefreshMenu(Self))
    {
        // updater = AMM_AppearanceUpdater(Class'AMM_AppearanceUpdater'.static.GetInstance());
        state = getMenuState();
        if (firstEnter)
        {
            // whether the root menu is character select
            IsUnderCharacterSelect = PathName(submenuStack[0].Class) ~= Class'ModHandler_AMM'.default.RootSubmenuPath;
            if (!IsUnderCharacterSelect && ShouldShowSelectCharacter())
            {
                ASSetTopButtonActive(TRUE);
				ASSetTopButtonText(string(srSelectCharacter));
            }
            else
            {
                ASSetTopButtonActive(FALSE);
            }
			if (state.pawnTag ~= "None")
            {
                pawnHandler.DisplayPawn("None", "");
                lastCameraPosition = "";
                // TODO remove helmet button here?
            }
            else if (state.pawnTag != "")
            {
                TryDisplayPawn(state.pawnTag, state.appearanceTypeOverride);
            }
            // updater.appearanceTypeOverride = state.appearanceTypeOverride;
            // LogInternal("currentMenu.pawnOverride" @ currentMenu.pawnOverride);
            pawnHandler.ForceAppearanceType(state.armorOverrideState);

            DoCameraPosition(state);
        }
		// apply (or remove) the menu helmet override
		updaterInstance = class'AMM_AppearanceUpdater'.static.GetDlcInstance();
		updaterInstance.menuHelmetOverride = int(state.currentMenuHelmetOverride);
        if (isAppearanceDirty)
        {
            UIWorldEvent('re_AMM_update_Appearance');
            isAppearanceDirty = FALSE;
        }
        currentDisplayItems.Length = 0;
        currentMenu.inlineStack.AddItem(PathName(currentMenu.Class));
        PopulateFromSubmenu(currentMenu);
        RenderMenu(state);
    }
}
private function DoCameraPosition(menuState state)
{
    local OutfitSpecListBase outfitSpecList;
    local int i;
    local presetCameraPosition cameraPos;

    // LogInternal("doing camera position"@state.CameraPosition@lastCameraPosition);
    // check if we need to transition the camera position
    if (state.cameraPosition != lastCameraPosition)
    {
        lastCameraPosition = state.CameraPosition;
        outfitSpecList = OutfitSpecListBase(state.params.GetOutfitSpecList(pawnHandler.GetUIWorldPawn()));
        i = outfitSpecList.cameraPositions.Find('cameraPositionName', state.CameraPosition);
        // LogInternal("checking"@outfitSpecList@outfitSpecList.cameraPositions.length@i);
        if (i != -1)
        {
            // LogInternal("got"@cameraPos.zoom@cameraPos.height@cameraPos.rotation@cameraPos.transitionTime);
            cameraPos = outfitSpecList.cameraPositions[i];
            cameraHandler.GoToCameraPosition(cameraPos.zoom, cameraPos.height, cameraPos.rotation, cameraPos.transitionTime);
        }
    }
}
protected function UIWorldEvent(name event)
{
    BioWorldInfo(oWorldInfo).m_UIWorld.TriggerEvent(event, oWorldInfo);
}
private function bool ShouldShowSelectCharacter()
{
    local BioGlobalVariableTable globalVars;
    local AMM_AppearanceUpdater updater;

    // if there are extra character menus installed, show the button
    updater = class'AMM_AppearanceUpdater'.static.GetDlcInstance();
    if (updater.ExtraCharacterModulesPresent && class'AMM_Common'.static.IsFrameworkInstalled())
    {
        return true;
    }

    globalVars = BioWorldInfo(oWorldInfo).GetGlobalVariables();

    // get the setting for menu accessibility
    if (globalVars.GetInt(1592) == 3)
    {
        // it is set to be always accessible
        return true;
    }

    // get the setting for pre recruitment
    if (globalVars.GetInt(1597) == 1)
    {
        return true;
    }

    // none of the conditions are met, don't show it
    return false;
}
private function RefreshHelmetButton()
{
	local string helmetButtonText;
	local menuState state;

	state = getMenuState();

	helmetButtonText = pawnHandler.GetHelmetButtonText(state.appearanceTypeOverride);
	if (helmetButtonText == "")
	{
		ASSetAuxButtonText("");
		ASSetAuxButtonActive(false);
	}
	else
	{
		ASSetAuxButtonText(helmetButtonText);
		ASSetAuxButtonActive(true);
	}
}
private function TryDisplayPawn(string tag, string appearanceType)
{
	local PawnLoadState state;

	state = pawnHandler.LoadPawn(tag, appearanceType);
	if (state == PawnLoadState.Loaded)
	{
		// do not reset the camera if the pawn has not changed
		if (!pawnHandler.IsPawnDisplayed(tag))
		{
			cameraHandler.ResetCameraForCharacter(tag);
		}
		pawnHandler.DisplayPawn(tag, appearanceType);
	}
	else if (state == PawnLoadState.Loading)
	{
        // clear current pawn here
        pawnHandler.DisplayPawn("None", "");
        // TODO clear helmet button here?
		// TODO start a loading spinner here
	}
}
public function PopulateFromSubmenu(AppearanceSubmenu currentSubmenu)
{
    local AppearanceItemData currentItem;
    local menuState state;
    
    if (currentSubmenu == None)
    {
        return;
    }
    state = getMenuState();
    foreach currentSubmenu.menuItems(currentItem, )
    {
        AddItemForDisplay(currentItem, currentSubmenu, state);
    }
}
public function RenderMenu(menuState state)
{
    local int i;
    local AppearanceItemData item;
    local AppearanceSubmenu currentSubmenu;
    
    currentSubmenu = GetCurrentSubmenu();
	SetTitleCustomTokens(state);
	// second check prevents it from double substituting
	if (IsStringSet(currentSubmenu.sTitle, currentSubmenu.srTitle) && !currentSubmenu.UseTitleForChildMenus)
	{
		ASSetTitle(GetString(currentSubmenu.sTitle, currentSubmenu.srTitle));
	}
	else
	{
		ASSetTitle(state.inheritedTitle);
	}
	if (IsStringSet(currentSubmenu.sSubtitle, currentSubmenu.srSubtitle) && !currentSubmenu.UseSubtitleForChildMenus)
	{
		ASSetSubTitle(GetString(currentSubmenu.sSubtitle, currentSubmenu.srSubtitle));
	}
	else
	{
		ASSetSubTitle(state.inheritedSubtitle);
	}
    
    ASStartSlotList(currentDisplayItems.Length);
    sortDisplayItems();
    for (i = 0; i < currentDisplayItems.Length; i++)
    {
        item = currentDisplayItems[i];
        SetCustomTokens(item);
        ASAddOrUpdateEntry(
			i,
			GetString(item.sLeftText, item.srLeftText),
			GetString(item.sCenterText, item.srCenterText),
			GetString(item.sRightText, item.srRightText),
            // if currently applied, green. otherwise, blue or grey depending on disabled
			item.currentlyApplied ? 2 : (item.disabled ? 1 : 0),
			GetSubmenuFromItem(item) != None);
    }
    ASSetSelectedIndex(currentSubmenu.selectedIndex);
    ASSetListScrollPosition(currentSubmenu.scrollIndex, TRUE);
    ASSetBackButtonText(string(submenuStack.Length > 1 ? srBack : srClose));
}
private function SetTitleCustomTokens(menuState state)
{
	ClearCustomTokens();
	SetCustomToken(0, state.inheritedTitle);
	SetCustomToken(1, state.inheritedSubtitle);
}
public function SetCustomTokens(AppearanceItemData item)
{
    local string tempString;
    local int tokenIndex;
    
    ClearCustomTokens();
    foreach item.displayVars(tempString, tokenIndex)
    {
        SetCustomToken(tokenIndex, GetDisplayVar(tempString));
    }
    // go through it twice so earlier tokens can reference later ones if needed
    foreach item.displayVars(tempString, tokenIndex)
    {
        SetCustomToken(tokenIndex, GetDisplayVar(tempString));
    }
}
public function sortDisplayItems()
{
    local int i;
    local int j;
    local AppearanceItemData currentItem;
    
    for (i = 1; i < currentDisplayItems.Length; i++)
    {
        currentItem = currentDisplayItems[i];
        for (j = i - 1; j >= 0 && currentDisplayItems[j].sortPriority > currentItem.sortPriority; j--)
        {
            currentDisplayItems[j + 1] = currentDisplayItems[j];
        }
        currentDisplayItems[j + 1] = currentItem;
    }
}
public function string GetDisplayVar(string input)
{
    local string tempString;
    
    if (Left(input, 1) == "$")
    {
        tempString = Right(input, Len(input) - 1);
        if (tempString == string(int(tempString)))
        {
            return string(stringref(int(tempString)));
        }
    }
    return input;
}
public function string GetString(string s, stringref sr)
{
    if (sr == $210210218)
    {
        return Class'SFXEngine'.static.GetEngine().CurrentSaveGame.PlayerRecord.FirstName @ $156667;
    }
    return s != "" ? s : string(sr);
}
public function bool IsStringSet(string s, stringref sr)
{
    return s != "" || sr != 0;
}
public function bool ShouldItemBeDisplayed(AppearanceItemData item, menuState state)
{
    if (!ShouldItemBeDisplayedBasedOnPlot(item))
    {
        return FALSE;
    }
    if (!ShouldItemBeDisplayedBasedOnCharacter(item, state))
    {
        return FALSE;
    }
    return TRUE;
}
private final function bool ShouldItemBeDisplayedBasedOnCharacter(AppearanceItemData item, menuState state)
{
	local string tempString;
	local bool applicableCharacter;
    local bool applicableAppearanceType;

    if (state.params != None)
    {
		// show/hide based on gender (mostly obsolete now)
        if (state.params.gender != eGender.Either && item.gender != eGender.Either && int(item.gender) != int(state.params.gender))
        {
            return false;
        }
		// some characters hide the headgear and breather menus by default becuase there is nothing there
		if (item.hideIfHeadgearSuppressed && state.params.suppressHelmetMenu)
		{
			return false;
		}
		if (item.hideIfHatsSuppressed && state.params.suppressHatMenu)
		{
			return false;
		}
		if (item.hideIfBreatherSuppressed && state.params.suppressBreatherMenu)
		{
			return false;
		}
		if (item.aApplicableCharacters.length > 0)
		{
            // if this tag is any of the applicable characters, show it
			foreach item.aApplicableCharacters(tempString)
			{
				if (tempString ~= state.params.Tag)
				{
					applicableCharacter = true;
					break;
				}
			}
			if (!applicableCharacter)
			{
				return false;
			}
		}
        if (item.aNotApplicableCharacters.length > 0)
		{
            applicableCharacter = true;
            // if this tag is any of the not applicable characters, do not show it
			foreach item.aNotApplicableCharacters(tempString)
			{
				if (tempString ~= state.params.Tag)
				{
					applicableCharacter = false;
					break;
				}
			}
			if (!applicableCharacter)
			{
				return false;
			}
		}
        if (item.aApplicableAppearanceTypes.length > 0)
        {
			foreach item.aApplicableAppearanceTypes(tempString)
			{
				if (tempString ~= state.appearanceTypeOverride)
				{
					applicableAppearanceType = true;
					break;
				}
			}
			if (!applicableAppearanceType)
			{
				return false;
			}
        }
        if (item.aNotApplicableAppearanceTypes.length > 0)
        {
            applicableAppearanceType = true;
			foreach item.aNotApplicableAppearanceTypes(tempString)
			{
				if (tempString ~= state.appearanceTypeOverride)
				{
					applicableAppearanceType = false;
					break;
				}
			}
			if (!applicableAppearanceType)
			{
				return false;
			}
        }
    }
    return TRUE;
}
private final function bool ShouldItemBeDisplayedBasedOnPlot(AppearanceItemData item)
{
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local string requiredPackage;
    
    if (item.hidden)
    {
        return FALSE;
    }
    BWI = BioWorldInfo(oWorldInfo);
    if (item.DisplayConditional > 0 && !BWI.CheckConditional(item.DisplayConditional))
    {
        return FALSE;
    }
    if (item.DisplayConditional < 0 && BWI.CheckConditional(-item.DisplayConditional))
    {
        return FALSE;
    }
    globalVars = BWI.GetGlobalVariables();
    if (item.DisplayBool > 0 && !globalVars.GetBool(item.DisplayBool))
    {
        return FALSE;
    }
    if (item.DisplayBool < 0 && globalVars.GetBool(-item.DisplayBool))
    {
        return FALSE;
    }
    if (item.DisplayInt.Id > 0 && globalVars.GetInt(item.DisplayInt.Id) != item.DisplayInt.Value)
    {
        return FALSE;
    }
    if (item.DisplayInt.Id < 0 && globalVars.GetInt(-item.DisplayInt.Id) == item.DisplayInt.Value)
    {
        return FALSE;
    }
    foreach item.displayRequiredPackageExports(requiredPackage, )
    {
        if (Left(requiredPackage, 1) == "!")
        {
            if (doesPackageExportExist(Right(requiredPackage, Len(requiredPackage) - 1)))
            {
                return FALSE;
            }
        }
        else if (!doesPackageExportExist(requiredPackage))
        {
            return FALSE;
        }
    }
	if (item.requiresFramework && !class'AMM_Common'.static.IsFrameworkInstalled())
	{
		return false;
	}
    return TRUE;
}
public final function bool doesPackageExportExist(string packageName)
{
    return DynamicLoadObject(packageName, Class'Object') != None;
}
public function bool ShouldItemBeEnabled(AppearanceItemData item)
{
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    
    if (item.disabled)
    {
        return FALSE;
    }
    BWI = BioWorldInfo(oWorldInfo);
    if (item.EnableConditional > 0 && !BWI.CheckConditional(item.EnableConditional))
    {
        return FALSE;
    }
    if (item.EnableConditional < 0 && BWI.CheckConditional(-item.EnableConditional))
    {
        return FALSE;
    }
    globalVars = BWI.GetGlobalVariables();
    if (item.EnableBool > 0 && !globalVars.GetBool(item.EnableBool))
    {
        return FALSE;
    }
    if (item.EnableBool < 0 && globalVars.GetBool(-item.EnableBool))
    {
        return FALSE;
    }
    if (item.EnableInt.Id > 0 && globalVars.GetInt(item.EnableInt.Id) != item.EnableInt.Value)
    {
        return FALSE;
    }
    if (item.EnableInt.Id < 0 && globalVars.GetInt(-item.EnableInt.Id) == item.EnableInt.Value)
    {
        return FALSE;
    }
    return TRUE;
}
private function bool IsItemCurrentlyApplied(AppearanceItemData item, menuState state)
{
    local bool plotVarsEffect;
    local bool appearanceIdsEffect;
    local bool plotVars;
    local bool appearanceIds;
    local AppearanceItemData submenuItem;

    // if this is a submenu entry point, don't count it as currently applied
    if (item.submenuInstance != None)
    {
        // if this menu is not marked as a "do not check" (basically, indicating that it tracks a different single applied than the parent is likely to)
        // and this matches the pawn and appearance type of the current menu (or doesn't change it)
        if (!item.submenuInstance.DoNotCheckAppliedInSubmenu 
            && (item.submenuInstance.pawnTag == "" || item.submenuInstance.pawnTag == state.pawnTag)
            && (item.submenuInstance.pawnAppearanceType == "" || item.submenuInstance.pawnAppearanceType == state.appearanceTypeOverride))
        {
            foreach item.submenuInstance.MenuItems(submenuItem)
            {
                submenuItem.submenuInstance = GetSubmenuFromItem(submenuItem);
                if (ShouldItemBeDisplayed(submenuItem, state))
                {
                    if (IsItemCurrentlyApplied(submenuItem, state))
                    {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    plotVars = IsItemCurrentlyAppliedBasedOnPlotVars(item, plotVarsEffect);
    // if there is no plot vars effect or it appears to be applied based on plot vars, check appearance id effects
    if (!plotVarsEffect || plotVars)
    {
        appearanceIds = IsItemCurrentlyAppliedBasedOnAppearanceIds(item, state, appearanceIdsEffect);
    }
    // TODO check on face code stuff when that is a thing
    // it is only currently applied if all relevant stuff matches what is currently applied

    // if this item seems to have no effect, do not count it as currently applied
    if (!plotVarsEffect && !appearanceIdsEffect)
    {
        return false;
    }
    // otherwise, return true only if every factor with an effect matches
    return (!plotVarsEffect || plotVars) && (!appearanceIdsEffect || appearanceIds);
}
private function bool IsItemCurrentlyAppliedBasedOnPlotVars(AppearanceItemData item, out bool hasAnEffect)
{
    local int boolId;
    local bool boolValue;
    local PlotIntSetting plotInt;
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local int plotIntValue;
    
    BWI = BioWorldInfo(oWorldInfo);
    globalVars = BWI.GetGlobalVariables();

    // check that all the bools match what would be applied
    foreach item.ApplySettingBools(boolId)
    {
        if (boolId > 0)
        {
            hasAnEffect = true;
            boolValue = globalVars.GetBool(boolId);
            if (!boolValue)
            {
                return false;
            }
        }
        else if (boolId < 0)
        {
            hasAnEffect = true;
            boolValue = globalVars.GetBool(-boolId);
            if (boolValue)
            {
                return false;
            }
        }
    }

    foreach item.ApplySettingInts(plotInt)
    {
        if (plotInt.Id > 0)
        {
            hasAnEffect = true;
            plotIntValue = globalVars.GetInt(plotInt.Id);
            if (plotIntValue != plotInt.Value)
            {
                return false;
            }
        }
    }
    // either it matches, or it has no effect
    return true;
}
private function bool IsItemCurrentlyAppliedBasedOnAppearanceIds(AppearanceItemData item, menuState state, out bool hasAnEffect)
{
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local int currentPlotIntValue;
    local AppearanceSettings appearanceSettings;

    BWI = BioWorldInfo(oWorldInfo);
    globalVars = BWI.GetGlobalVariables();

    // first, check if this item touches outfit and there is a valid place to check for that
    if (item.applyOutfitId != 0 && state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId != 0)
    {
        hasAnEffect = true;
        currentPlotIntValue = globalVars.GetInt(state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId);
        // account for 0 and -1 meaning the same thing
        if (currentPlotIntValue == 0)
        {
            currentPlotIntValue = -1;
        }
        if (item.applyOutfitId != currentPlotIntValue)
        {
            // if we don't match on anything, short circuit out
            return false;
        }
    }
    if (item.applyHelmetId != 0 && state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId != 0)
    {
        hasAnEffect = true;
        currentPlotIntValue = globalVars.GetInt(state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId);
        // account for 0 and -1 meaning the same thing
        if (currentPlotIntValue == 0)
        {
            currentPlotIntValue = -1;
        }
        if (item.applyHelmetId != currentPlotIntValue)
        {
            // if we don't match on anything, short circuit out
            return false;
        }
    }
    if (item.applyBreatherId != 0 && state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId != 0)
    {
        hasAnEffect = true;
        currentPlotIntValue = globalVars.GetInt(state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId);
        // account for 0 and -1 meaning the same thing
        if (currentPlotIntValue == 0)
        {
            currentPlotIntValue = -1;
        }
        if (item.applyBreatherId != currentPlotIntValue)
        {
            // if we don't match on anything, short circuit out
            return false;
        }
    }
    if (item.applyHelmetPreference != eMenuHelmetOverride.unchanged && state.AppearanceIdLookups.appearanceFlagsLookup.plotIntId != 0)
    {
        hasAnEffect = true;
        appearanceSettings = class'AMM_Common'.static.DecodeAppearanceSettings(globalVars.GetInt(state.AppearanceIdLookups.appearanceFlagsLookup.plotIntId));
        if (appearanceSettings.helmetDisplayState != (item.applyHelmetPreference) - 1)
        {
            return false;
        }
    }
    // everything matches, or it has no effect
    return true;
}
public function AddItemForDisplay(AppearanceItemData item, AppearanceSubmenu currentSubmenu, menuState state)
{
    if (!ShouldItemBeDisplayed(item, state))
    {
        return;
    }
    item.disabled = !ShouldItemBeEnabled(item);
    item.submenuInstance = GetSubmenuFromItem(item);
    item.currentlyApplied = IsItemCurrentlyApplied(item, state);
	// preload the pawn for this submenu, if applicable
	if (item.submenuInstance != None && !item.inlineSubmenu && item.submenuInstance.PreloadPawn)
	{
		if (item.submenuInstance.pawnTag != "" && !(item.submenuInstance.pawnTag ~= "None"))
		{
			pawnHandler.PreloadPawn(item.submenuInstance.pawnTag, item.submenuInstance.pawnAppearanceType);
		}
	}
	// add inline items, if applicable
	if (item.submenuInstance != None && item.inlineSubmenu)
	{
		if (!CheckForCycle(currentSubmenu, item.submenuInstance))
		{
			PopulateFromSubmenu(item.submenuInstance);
		}
	}
	// otherwise, just add the item into the menu
    else
    {
        currentDisplayItems.AddItem(item);
    }
}
public final function bool CheckForCycle(AppearanceSubmenu currentSubmenu, AppearanceSubmenu childSubmenu)
{
    local string menuPath;
    
    if (currentSubmenu.inlineStack.Find(PathName(childSubmenu.Class)) == -1)
    {
        childSubmenu.inlineStack = currentSubmenu.inlineStack;
        childSubmenu.inlineStack.AddItem(PathName(childSubmenu.Class));
        return FALSE;
    }
    LogInternal("WARNING: Menu cycle detected while populating" @ PathName(GetCurrentSubmenu()) $ ". Aborting populating further", );
    LogInternal("cycled menus:", );
    foreach currentSubmenu.inlineStack(menuPath, )
    {
        LogInternal(menuPath, );
    }
    LogInternal(PathName(childSubmenu.Class), );
    return TRUE;
}
public function AppearanceSubmenu GetSubmenuFromItem(AppearanceItemData item)
{
    if (item.submenuInstance != None)
    {
        return item.submenuInstance;
    }
    if (item.SubmenuClass != None)
    {
        return new (Self) item.SubmenuClass;
    }
    if (item.SubMenuClassName != "")
    {
        return LoadSubmenu(item.SubMenuClassName, self);
    }
    return None;
}
public function AppearanceSubmenu GetCurrentSubmenu()
{
    if (submenuStack.Length > 0)
    {
        return submenuStack[submenuStack.Length - 1];
    }
    return None;
}
public function ASLoadedEx()
{
    local AMM_AppearanceUpdater_Base basegameInstance;
    
	if (!class'AMM_AppearanceUpdater_Base'.static.IsMergeModInstalled(basegameInstance))
	{
        LogInternal("Closing menu, as it was installed incorrectly; If you are seeing this, you uninstalled or overwrote the basegame changes of AMM but left the DLC. Remove the DLC to finish uninstalling it, or apply the mod again to make it work.", );
        Super.Close();
        return;
    }
    ASSetBackButtonActive(TRUE);
    ASSetRightPaneVisibility(FALSE, FALSE);
    ASSetHeaderVisibility(true);
    RefreshMenu(TRUE);
    Super.ASLoadedEx();
}
public function OnRStickX(float val)
{
	cameraHandler.rotateController = val;
}
public function OnRStickY(float val)
{
	cameraHandler.moveUpDownController = val;
}
public function HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    local BioPlayerController oController;
    local BioPlayerInput bpi;
    
    oController = BioWorldInfo(oWorldInfo).GetLocalPlayerController();
    bpi = BioPlayerInput(oController.PlayerInput);
    switch (Event)
    {
		// handle controller zoom with triggers
		// TODO take another crack at making this analog
		case BioGuiEvents.BIOGUI_EVENT_BUTTON_LT:
			cameraHandler.zoomOutTriggerPressed = 1.0;
			break;
		case BioGuiEvents.BIOGUI_EVENT_BUTTON_RT:
			cameraHandler.zoomInTriggerPressed = 1.0;
			break;
		case BioGuiEvents.BIOGUI_EVENT_BUTTON_LT_RELEASE:
			cameraHandler.zoomOutTriggerPressed = 0.0;
			break;
		case BioGuiEvents.BIOGUI_EVENT_BUTTON_RT_RELEASE:
			cameraHandler.zoomInTriggerPressed = 0.0;
			break;
		// handle mouse based camera up/down
		case BioGuiEvents.BIOGUI_EVENT_MOUSE_BUTTON_RIGHT:
			rightClickHeld = true;
			break;
		case BioGuiEvents.BIOGUI_EVENT_MOUSE_BUTTON_RIGHT_RELEASE:
			rightClickHeld = false;
			cameraHandler.moveUpDownMouse = 0;
			cameraHandler.rotateMouse = 0;
			break;
		case BioGuiEvents.BIOGUI_EVENT_AXIS_MOUSE_Y:
			if (rightClickHeld)
			{
				cameraHandler.moveUpDownMouse = fValue;
			}
			else
			{
				Super.HandleInputEvent(Event, fValue);
			}
			break;
		case BioGuiEvents.BIOGUI_EVENT_AXIS_MOUSE_X:
			// TODO any deadzone here? any max value we should enforce?
			if (rightClickHeld)
			{
				cameraHandler.rotateMouse = fValue;
			}
			else
			{
				Super.HandleInputEvent(Event, fValue);
			}
			break;
        default:
            Super.HandleInputEvent(Event, fValue);
    }
}
public function OnScrollWheelEX(eScrollWheelDir direction, bool overList, bool overRightPane)
{
    // if the mouse is over the list and right click is not held, scroll the list
    if (overList && !rightClickHeld)
    {
        ASMoveListScrollBar(direction == eScrollWheelDir.down ? 1 : -1);
    }
	// otherwise, zoom in/out from the character
    else
    {
        cameraHandler.MouseWheelZoom(direction == eScrollWheelDir.down);
    }
}
public function BackButtonPressedEx()
{
    local AppearanceSubmenu currentSubmenu;
    
    currentSubmenu = GetCurrentSubmenu();
    if (currentSubmenu == None || !currentSubmenu.OnBackButtonPressed(Self))
    {
        if (submenuStack.Length > 1)
        {
            PopSubmenu();
        }
        else if (launchedInPrologue)
        {
			dialogHandler = new class'AMM_DialogBox_Handler';
			dialogHandler.Init(self);
            dialogHandler.ConfirmExitDialog();
        }
        else
        {
            Super.BackButtonPressedEx();
        }
    }
}
public function ConfirmExitDialogInputPressed(bool bAPressed)
{
    if (bAPressed)
    {
        UpdateAllActorAppearances();
        Super.BackButtonPressedEx();
    }
}
public function UpdateAllActorAppearances()
{
    local Actor tempActor;
    local Array<Object> objectParams;
    local Array<string> stringParams;

    // TODO filter this down to only pawns that could have been affected
    foreach BioWorldInfo(oWorldInfo).AllActors(Class'Actor', tempActor, )
    {
        if (BioPawn(tempActor) != None)
        {
            // send out a remote event to trigger it to update this actor
			objectParams[0] = tempActor;
			stringParams[0] = "AMM UpdateAllActorAppearances";
			class'ModSeqEvent_RemoteEvent_Dynamic'.static.InvokeDynamicEvent('re_AMM_RequestAppearanceUpdate', false, objectParams, stringParams);
        }
    }
}
public function ItemSelectedEx(int selectedIndex)
{
    local AppearanceSubmenu currentSubmenu;
    local AppearanceItemData item;
    local bool itemHasSubmenu;
    local bool actionButtonActive;
    local string actionButtonText;
    
    // if (CameraDebug)
    // {
    //     return;
    // }
    currentSubmenu = GetCurrentSubmenu();
    if (!currentSubmenu.OnItemSelected(Self, selectedIndex))
    {
        if (selectedIndex == -1)
        {
            return;
        }
        currentSubmenu.selectedIndex = selectedIndex;
        item = currentDisplayItems[selectedIndex];
        SetCustomTokens(item);
        itemHasSubmenu = item.SubMenuClassName != "" || item.SubmenuClass != None || item.submenuInstance != None;
        actionButtonActive = !item.disabled;
        ASSetActionButtonActive(actionButtonActive);
        if (actionButtonActive)
        {
            actionButtonText = GetString(item.sActionText, item.srActionText);
            if (actionButtonText == "")
            {
                if (itemHasSubmenu)
                {
                    actionButtonText = string(srOpenSubmenu);
                }
                else
                {
                    actionButtonText = string(srDefaultActionText);
                }
            }
            ASSetActionButtonText(actionButtonText);
        }
    }
}
public function ActionButtonPressedEx(int selectedIndex)
{
	
    local AppearanceItemData selectedItem;
    local AppearanceSubmenu submenu;
    local AppearanceSubmenu currentSubmenu;
    
    // if (CameraDebug)
    // {
    //     Self.cameraHandler.DebugChangeAxis(FALSE, cameraDebugAxis);
    // }
    currentSubmenu = GetCurrentSubmenu();
    if (!currentSubmenu.OnActionButtonPressed(Self, selectedIndex))
    {
        if (selectedIndex == -1 || selectedIndex > currentDisplayItems.Length)
        {
            return;
        }
        selectedItem = currentDisplayItems[selectedIndex];
        if (selectedItem.disabled)
        {
            return;
        }
        submenu = GetSubmenuFromItem(selectedItem);
        if (submenu != None)
        {
            PushSubmenuInstance(submenu);
        }
        else
        {
            currentSubmenu.scrollIndex = ASGetListScrollPosition();
            ApplyItem(selectedItem);
            RefreshMenu();
        }
    }
}
// this is going to be the toggle/cycle helmet button
public function AuxButtonPressedEx(int selectedIndex)
{
	pawnHandler.HelmetButtonPressed();
    BioWorldInfo(oWorldInfo).m_UIWorld.TriggerEvent('re_AMM_update_Appearance', oWorldInfo);
}
public function TopButtonPressedEx(int selectedIndex)
{
    local AppearanceSubmenu currentSubmenu;

	currentSubmenu = GetCurrentSubmenu();
	if (!currentSubmenu.OnTopButtonPressed(Self, selectedIndex))
	{
		SetRootSubmenu(Class'ModHandler_AMM'.default.RootSubmenuPath);
		RefreshMenu(TRUE);
	}
}
public function ApplyItem(AppearanceItemData item)
{
    local int boolId;
    local PlotIntSetting plotInt;
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local menuState state;
    
    BWI = BioWorldInfo(oWorldInfo);
    globalVars = BWI.GetGlobalVariables();
    foreach item.ApplySettingBools(boolId, )
    {
        if (boolId > 0)
        {
            globalVars.SetBool(boolId, TRUE);
        }
        else if (boolId < 0)
        {
            globalVars.SetBool(-boolId, FALSE);
        }
    }
    foreach item.ApplySettingInts(plotInt, )
    {
        if (plotInt.Id > 0)
        {
            globalVars.SetInt(plotInt.Id, plotInt.Value);
        }
    }
    state = getMenuState();
    // LogInternal("trying to apply stuff" @ state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId @ state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId @ state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId, );
    if (state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId != 0)
    {
        if (item.applyOutfitId != 0)
        {
            // LogInternal("applying outfit" @ item.applyOutfitId @ "to plot int" @ state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId, );
            globalVars.SetInt(state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId, item.applyOutfitId);
            isAppearanceDirty = TRUE;
        }
    }
    if (state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId != 0)
    {
        if (item.applyHelmetId != 0)
        {
            // LogInternal("applying helmet" @ item.applyHelmetId @ "to plot int" @ state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId, );
            globalVars.SetInt(state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId, item.applyHelmetId);
            isAppearanceDirty = TRUE;
        }
    }
    if (state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId != 0)
    {
        if (item.applyBreatherId != 0)
        {
            // LogInternal("applying breather" @ item.applyBreatherId @ "to plot int" @ state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId, );
            globalVars.SetInt(state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId, item.applyBreatherId);
            isAppearanceDirty = TRUE;
        }
    }
    ApplyHelmetSetting(item, state, globalVars);
}
private final function ApplyHelmetSetting(AppearanceItemData item, menuState state, BioGlobalVariableTable globalVars)
{
	local AppearanceSettings appearanceSettings;
    local int flagsPlotId;
	local int updatedFlags;

    flagsPlotId = state.AppearanceIdLookups.appearanceFlagsLookup.plotIntId;
    if (flagsPlotId != 0
		&& item.applyHelmetPreference != eMenuHelmetOverride.unchanged
		&& item.applyHelmetPreference != eMenuHelmetOverride.onOrFull
		&& item.applyHelmetPreference != eMenuHelmetOverride.offOrOn
		&& item.applyHelmetPreference != eMenuHelmetOverride.offOrFull)
    {
        // LogInternal("Trying to apply helmet visibility override" @ item.applyHelmetOverride @ flagsPlotId, );
        appearanceSettings = class'AMM_Common'.static.DecodeAppearanceSettings(globalVars.GetInt(flagsPlotId));
        // LogInternal("Current flags" @ currentFlagsValue, );
		// TODO this is a bit brittle; it relies on the values being the same, but offset by 1
		appearanceSettings.helmetDisplayState = (item.applyHelmetPreference) - 1;
        updatedFlags = class'AMM_Common'.static.EncodeAppearanceSettings(appearanceSettings);
        // LogInternal("updated flags" @ updatedFlags, );
        globalVars.SetInt(flagsPlotId, updatedFlags);
		isAppearanceDirty = TRUE;
    }
}
public function EmitSettingsRemoteEvent()
{
    EmitRemoteEvent("re_AMM");
}
private function EmitRemoteEvent(string EventName)
{
	local BioWorldInfo BWI;
    local array<SequenceEvent> remoteEvents;
    local SequenceEvent se;
    local SeqEvent_RemoteEvent re;
    
    BWI = BioWorldInfo(oWorldInfo);
    BWI.GetGlobalEvents(Class'SeqEvent_RemoteEvent', remoteEvents);
    foreach remoteEvents(se, )
    {
        re = SeqEvent_RemoteEvent(se);
        if (re != None && re.EventName == Name(EventName))
        {
            re.CheckActivate(BWI, BWI);
        }
    }
}
public function OnPanelRemoved()
{
    EmitSettingsRemoteEvent();
    Super.OnPanelRemoved();
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
	MovieTag = 'AMM'
    RootSubmenuPath = "AMM_Submenus.AppearanceSubmenu_CharacterSelect"
	// "Back"
    srBack = $174627
	// "Close"
    srClose = $161206
	// "Apply"
    srDefaultActionText = $177145
	// "Open"
    srOpenSubmenu = $177824
	srSelectCharacter = $210210217
	// movieInfo = GFXMovieInfo'Gui.ModMenu'
	RStickDeadZone = 0.1
}