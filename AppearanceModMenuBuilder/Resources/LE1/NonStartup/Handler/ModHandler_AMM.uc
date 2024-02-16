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
    // var bool bOverrideAppearanceType;
    var string appearanceTypeOverride;
    // var eMenuHelmetOverride currentMenuHelmetOverride;
};

// Variables
var name MovieTag;
var transient string launchParam;
var transient AMM_Pawn_Handler pawnHandler;
var stringref srBack;
var stringref srClose;
var stringref srDefaultActionText;
var stringref srOpenSubmenu;
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
        // if (currentSubmenu.menuHelmetOverride != eMenuHelmetOverride.unchanged)
        // {
        //     newState.currentMenuHelmetOverride = currentSubmenu.menuHelmetOverride;
        // }
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
    
    GetManager().SetupBackground();
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
        RootSubmenuPath = params.menuRootPath;
    }
    SetRootSubmenu(RootSubmenuPath);
    Super.OnPanelAdded();
}

public function Close()
{
    pawnHandler.Cleanup();
    cameraHandler.Cleanup();
	if (dialogHandler != None)
	{
		dialogHandler.Cleanup();
	}
    // updater = AMM_AppearanceUpdater(Class'AMM_AppearanceUpdater'.static.GetInstance());
    // updater.appearanceTypeOverride = "";
    // updater.tempHelmetOverride = eMenuHelmetOverride.unchanged;
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
			pawnHandler.DisplayPawn(tag, appearanceType);
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
	pawnHandler.Update(fDeltaT);
}
public function RefreshMenu(optional bool firstEnter = FALSE)
{
    local AppearanceSubmenu currentMenu;
    local bool IsInCharacterSelect;
    local menuState state;
    // local AMM_AppearanceUpdater updater;
    local bool WaitingForPawnToSpawn;
    
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
            IsInCharacterSelect = PathName(currentMenu.Class) ~= Class'ModHandler_AMM'.default.RootSubmenuPath;
            if (IsInCharacterSelect)
            {
                ASSetAux2ButtonActive(FALSE, FALSE);
            }
            else
            {
                ASSetAux2ButtonActive(TRUE, FALSE);
                // TODO use a stringref
				ASSetAux2ButtonText("Select Character");
            }
			if (state.pawnTag ~= "None")
            {
                pawnHandler.DisplayPawn("None", "");
            }
            else if (state.pawnTag != "")
            {
                TryDisplayPawn(state.pawnTag, state.appearanceTypeOverride);
            }
            // updater.appearanceTypeOverride = state.appearanceTypeOverride;
            // // LogInternal("currentMenu.pawnOverride" @ currentMenu.pawnOverride);
            pawnHandler.ForceAppearanceType(state.armorOverrideState);
        }
        // if (TimeToWaitForPawnToSpawn > 0.0 || firstEnter)
        // {
        //     if (state.pawnOverride ~= "None")
        //     {
        //         pawnHandler.SetupUIWorldPawn("None", "");
        //     }
        //     else if (state.pawnOverride != "")
        //     {
        //         Log("Setting up pawn");
        //         pawnHandler.SetupUIWorldPawn(state.pawnOverride, state.appearanceTypeOverride);
        //     }
        // }
        // comment("If the submenu you are in overrides the chosen menu helmet appearance, that takes precedence");
        // if (state.currentMenuHelmetOverride != eMenuHelmetOverride.unchanged)
        // {
        //     if (state.currentMenuHelmetOverride == eMenuHelmetOverride.forcedOn && chosenMenuHelmetVisibilityOverride == eMenuHelmetOverride.forcedFull)
        //     {
        //         LogInternal("Special case: if the menu only requests on but the user has requested full for the preview, use full.", );
        //         updater.tempHelmetOverride = eMenuHelmetOverride.forcedFull;
        //     }
        //     else
        //     {
        //         LogInternal("Using menu helmet override of" @ state.currentMenuHelmetOverride, );
        //         updater.tempHelmetOverride = state.currentMenuHelmetOverride;
        //     }
        // }
        // else
        // {
        //     LogInternal("Using chosen helmet override of" @ chosenMenuHelmetVisibilityOverride, );
        //     updater.tempHelmetOverride = chosenMenuHelmetVisibilityOverride;
        // }
        if (isAppearanceDirty)
        {
            BioWorldInfo(oWorldInfo).m_UIWorld.TriggerEvent('re_AMM_update_Appearance', oWorldInfo);
            isAppearanceDirty = FALSE;
        }
        currentDisplayItems.Length = 0;
        currentMenu.inlineStack.AddItem(PathName(currentMenu.Class));
        PopulateFromSubmenu(currentMenu);
        RenderMenu();
    }
}
private function TryDisplayPawn(string tag, string appearanceType)
{
	local PawnLoadState state;

	state = pawnHandler.LoadPawn(tag, appearanceType);
	// Log("Setting up pawn");
	if (state == PawnLoadState.Loaded)
	{
		pawnHandler.DisplayPawn(tag, appearanceType);
	}
	else if (state == PawnLoadState.Loading)
	{
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
public function RenderMenu()
{
    local int i;
    local AppearanceItemData item;
    local AppearanceSubmenu currentSubmenu;
    
    currentSubmenu = GetCurrentSubmenu();
    ASSetTitle(GetString(currentSubmenu.sTitle, currentSubmenu.srTitle));
    ASSetSubTitle(GetString(currentSubmenu.sSubtitle, currentSubmenu.srSubtitle));
    ASStartSlotList(currentDisplayItems.Length);
    sortDisplayItems();
    for (i = 0; i < currentDisplayItems.Length; i++)
    {
        item = currentDisplayItems[i];
        SetCustomTokens(item);
        ASAddOrUpdateEntry(i, GetString(item.sLeftText, item.srLeftText), GetString(item.sCenterText, item.srCenterText), GetString(item.sRightText, item.srRightText), item.disabled ? 1 : 0);
    }
    ASSetSelectedIndex(currentSubmenu.selectedIndex);
    ASSetListScrollPosition(currentSubmenu.scrollIndex, TRUE);
    ASSetBackButtonText(string(submenuStack.Length > 1 ? srBack : srClose));
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
    if (state.params != None)
    {
        if (state.params.gender == eGender.Either || item.gender == eGender.Either)
        {
            return TRUE;
        }
        else
        {
            return int(item.gender) == int(state.params.gender);
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
public function AddItemForDisplay(AppearanceItemData item, AppearanceSubmenu currentSubmenu, menuState state)
{
    if (!ShouldItemBeDisplayed(item, state))
    {
        return;
    }
    item.disabled = !ShouldItemBeEnabled(item);
    item.submenuInstance = GetSubmenuFromItem(item);
	// preload the pawn for this submenu, if applicable
	if (item.submenuInstance != None && !item.inlineSubmenu && item.submenuInstance.PreloadPawn)
	{
		if (item.submenuInstance.pawnTag != "" && !(item.submenuInstance.pawnTag ~= "None"))
		{
			pawnHandler.LoadPawn(item.submenuInstance.pawnTag, item.submenuInstance.pawnAppearanceType);
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
        return LoadSubmenu(item.SubMenuClassName);
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
    // comment("TODO use a stringref");
    // ASSetAuxButtonText("UNDO");
    // ASSetAuxButtonActive(TRUE);
    RefreshMenu(TRUE);
    // if (CameraDebug)
    // {
    //     cameraDebugAxis = 0;
    //     ASSetActionButtonActive(TRUE);
    //     ASSetActionButtonText("Decrease");
    //     ASSetAuxButtonActive(TRUE);
    //     ASSetAuxButtonText("Increase");
    //     SetAux2CameraDebug();
    // }
    Super.ASLoadedEx();
}
// private final function SetAux2CameraDebug()
// {
//     Self.ASSetAux2ButtonActive(TRUE, FALSE);
//     if (cameraDebugAxis <= 0)
//     {
//         cameraDebugAxis = 0;
//         Self.ASSetAux2ButtonText("X");
//     }
//     else if (cameraDebugAxis == 1)
//     {
//         Self.ASSetAux2ButtonText("Y");
//     }
//     else if (cameraDebugAxis == 2)
//     {
//         Self.ASSetAux2ButtonText("Z");
//     }
//     else
//     {
//         cameraDebugAxis = 0;
//         SetAux2CameraDebug();
//     }
// }
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

    foreach BioWorldInfo(oWorldInfo).AllActors(Class'Actor', tempActor, )
    {
        if (BioPawn(tempActor) != None)
        {
			Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(BioPawn(tempActor), "AMM UpdateAllActorAppearances");
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
        ASSetAuxButtonActive(FALSE);
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
public function AuxButtonPressedEx(int selectedIndex)
{
    local AppearanceItemData selectedItem;
    local AppearanceSubmenu currentSubmenu;
    
    // if (CameraDebug)
    // {
    //     Self.cameraHandler.DebugChangeAxis(TRUE, cameraDebugAxis);
    // }
    // else
    // {
        currentSubmenu = GetCurrentSubmenu();
        if (!currentSubmenu.OnAuxButtonPressed(Self, selectedIndex))
        {
            selectedItem = currentDisplayItems[selectedIndex];
            // comment("TODO undo probably?");
            LogInternal("This should eventually be an undo button", );
        }
    // }
}
public function Aux2ButtonPressedEx(int selectedIndex)
{
    local AppearanceSubmenu currentSubmenu;
    
    // if (CameraDebug)
    // {
    //     Self.cameraDebugAxis++;
    //     Self.SetAux2CameraDebug();
    // }
    // else
    // {
        currentSubmenu = GetCurrentSubmenu();
        if (!currentSubmenu.OnAux2ButtonPressed(Self, selectedIndex))
        {
            SetRootSubmenu(Class'ModHandler_AMM'.default.RootSubmenuPath);
            RefreshMenu(TRUE);
        }
    // }
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
    LogInternal("trying to apply stuff" @ state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId @ state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId @ state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId, );
    if (state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId != 0)
    {
        if (item.applyOutfitId != 0)
        {
            LogInternal("applying outfit" @ item.applyOutfitId @ "to plot int" @ state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId, );
            globalVars.SetInt(state.AppearanceIdLookups.bodyAppearanceLookup.plotIntId, item.applyOutfitId);
            isAppearanceDirty = TRUE;
        }
    }
    if (state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId != 0)
    {
        if (item.applyHelmetId != 0)
        {
            LogInternal("applying helmet" @ item.applyHelmetId @ "to plot int" @ state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId, );
            globalVars.SetInt(state.AppearanceIdLookups.helmetAppearanceLookup.plotIntId, item.applyHelmetId);
            isAppearanceDirty = TRUE;
        }
    }
    if (state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId != 0)
    {
        if (item.applyBreatherId != 0)
        {
            LogInternal("applying breather" @ item.applyBreatherId @ "to plot int" @ state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId, );
            globalVars.SetInt(state.AppearanceIdLookups.breatherAppearanceLookup.plotIntId, item.applyBreatherId);
            isAppearanceDirty = TRUE;
        }
    }
    // ApplyHelmetSetting(item, state, globalVars);
}
// private final function ApplyHelmetSetting(AppearanceItemData item, menuState state, BioGlobalVariableTable globalVars)
// {
//     local int flagsPlotId;
//     local int currentFlagsValue;
//     local int updatedFlags;
    
//     flagsPlotId = state.AppearanceIdLookups.appearanceFlagsLookup.plotIntId;
//     if (flagsPlotId != 0 && item.applyHelmetOverride != eMenuHelmetOverride.unchanged)
//     {
//         LogInternal("Trying to apply helmet visibility override" @ item.applyHelmetOverride @ flagsPlotId, );
//         currentFlagsValue = globalVars.GetInt(flagsPlotId);
//         LogInternal("Current flags" @ currentFlagsValue, );
//         updatedFlags = Class'AppearanceFlagsManager'.static.ApplyForceHelmetState(currentFlagsValue, byte(int(item.applyHelmetOverride) - 1));
//         LogInternal("updated flags" @ updatedFlags, );
//         globalVars.SetInt(flagsPlotId, updatedFlags);
//         if (currentFlagsValue != updatedFlags)
//         {
//             isAppearanceDirty = TRUE;
//         }
//     }
//     if (item.applyHelmetVisibilityPreference != eHelmetVisibilityPreference.unchanged)
//     {
//         LogInternal("trying to apply a helmet visibility preference" @ item.applyHelmetVisibilityPreference, );
//         pawnHandler.ForceHelmetAppearance(item.applyHelmetVisibilityPreference == eHelmetVisibilityPreference.preferOn);
//         isAppearanceDirty = TRUE;
//     }
//     if (item.menuHelmetOverride != eMenuHelmetOverride.unchanged)
//     {
//         LogInternal("Setting chosen menu helmet override to" @ item.menuHelmetOverride, );
//         if (item.menuHelmetOverride == eMenuHelmetOverride.vanilla)
//         {
//             chosenMenuHelmetVisibilityOverride = eMenuHelmetOverride.unchanged;
//         }
//         else
//         {
//             chosenMenuHelmetVisibilityOverride = item.menuHelmetOverride;
//         }
//         isAppearanceDirty = TRUE;
//     }
// }
public function EmitSettingsRemoteEvent()
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
        if (re != None && re.EventName == Name("re_AMM"))
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
	movieInfo = GFXMovieInfo'Gui.ModMenu'
}