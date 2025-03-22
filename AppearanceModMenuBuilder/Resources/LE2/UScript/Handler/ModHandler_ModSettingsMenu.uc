Class ModHandler_ModSettingsMenu extends ModHandler_ModMenuBase
    config(UI);

var transient GFxMovieInfo movieInfo;
var transient bool launchedFromPauseScreen;
var stringref srBack;
var stringref srClose;
var stringref srApply;
var stringref srOpenSubmenu;
var stringref srCycleImages;
var transient array<ModSettingItemData> currentDisplayItems;
var transient array<ModSettingsSubmenu> submenuStack;
var string rootSubmenuPath;
var transient int imageIndex;

public function OnPanelAdded()
{
    // set up the moving background? does this do anything?
    MassEffectGuiManager(oPanel.oParentManager).SetupBackground();
    SetRootSubmenu(RootSubmenuPath);
    Super.OnPanelAdded();
    // just hold onto this for as long as the handler is alive, it prevents textures from being garbage collected
    movieInfo = GFXMovieInfo(FindObject("ModMenu.ModMenu", class'GFxMovieInfo'));
}

public function PauseMenuAdditionalProcessing()
{
    launchedFromPauseScreen = true;
}

public static function bool AreAnyModsUsingTheMenu()
{
    // TODO check if anything has added menu items to the root menu, to be used to show some kind of message if not
    return true;
}

public function SetRootSubmenu(string submenuPath)
{
    submenuStack.Length = 0;
    submenuStack.AddItem(LoadSubmenu(RootSubmenuPath));
}

public static function ModSettingsSubmenu LoadSubmenu(string submenuPath, optional ModHandler_ModSettingsMenu outer)
{
    local Class<ModSettingsSubmenu> SubmenuClass;
    
    // TODO do I need to seekfree load?
    // it seems to be working fine this way, actually
    SubmenuClass = Class<ModSettingsSubmenu>(DynamicLoadObject(submenuPath, Class'Class'));
    if (SubmenuClass != None)
    {
        return new (outer) SubmenuClass;
    }
    return None;
}
public function PushSubmenu(string submenuPath)
{
    PushSubmenuInstance(LoadSubmenu(submenuPath));
}
public function PushSubmenuInstance(ModSettingsSubmenu instance)
{
    local ModSettingsSubmenu currentSubmenu;
    
    currentSubmenu = GetCurrentSubmenu();
    if (currentSubmenu != None)
    {
        currentSubmenu.scrollIndex = ASGetScrollPosition();
    }
    submenuStack.AddItem(instance);
    RefreshMenu();
}
public function PopSubmenu()
{
    if (submenuStack.Length > 0)
    {
        submenuStack.Length = submenuStack.Length - 1;
    }
    RefreshMenu();
}
public function ModSettingsSubmenu GetCurrentSubmenu()
{
    if (submenuStack.Length > 0)
    {
        return submenuStack[submenuStack.Length - 1];
    }
    return None;
}

public function ExASLoaded()
{
    ASSetBackButtonActive(true);
    // TODO use a stringref here
    ASSetBackButtonText("back");
    RefreshMenu();
    Super.ExASLoaded();
}

public function ExBackPressed()
{
    // local ModSettingsSubmenu currentSubmenu;
    
    // currentSubmenu = GetCurrentSubmenu();
    // if (!currentSubmenu.OnBackButtonPressed(Self))
    // {
        if (submenuStack.Length > 1)
        {
            PopSubmenu();
        }
        else
        {
            if (launchedFromPauseScreen)
            {
                PlayGuiSound('ReturnToBrowser');
                MassEffectGuiManager(oPanel.oParentManager).ReturnToBrowserWheel(oPanel);
            }
            else
            {
                Super.ExBackPressed();
            }
        }
        
    // }
}

public function RefreshMenu()
{
    local ModSettingsSubmenu currentMenu;
    
    currentMenu = GetCurrentSubmenu();
    // if (!currentMenu.OnRefreshMenu(Self))
    // {
        currentDisplayItems.Length = 0;
        // currentMenu.inlineStack.AddItem(PathName(currentMenu.Class));
        PopulateFromSubmenu(currentMenu);
        RenderMenu();
    // }
}

public function PopulateFromSubmenu(ModSettingsSubmenu currentSubmenu)
{
    local ModSettingItemData currentItem;
    
    if (currentSubmenu == None)
    {
        return;
    }
    foreach currentSubmenu.menuItems(currentItem)
    {
        AddItemForDisplay(currentItem, currentSubmenu);
    }
}

public function AddItemForDisplay(ModSettingItemData item, ModSettingsSubmenu currentSubmenu)
{
    if (!ShouldItemBeDisplayed(item))
    {
        return;
    }
    item.disabled = !ShouldItemBeEnabled(item);
    item.submenuInstance = GetSubmenuFromItem(item);
    // if (item.submenuInstance != None && item.inlineSubmenu)
    // {
    //     // if (!CheckForCycle(currentSubmenu, item.submenuInstance))
    //     // {
    //         PopulateFromSubmenu(item.submenuInstance);
    //     // }
    // }
    // else
    // {
        currentDisplayItems.AddItem(item);
    // }
}

public function bool ShouldItemBeDisplayed(ModSettingItemData item)
{
    if (item.hidden)
    {
        return false;
    }
    // TODO check other stuff
    return true;
}

public function bool ShouldItemBeEnabled(ModSettingItemData item)
{
    if (item.disabled)
    {
        return false;
    }
    // TODO check other stuff
    return true;
}

public function string GetString(string s, stringref sr)
{
    return s != "" ? s : string(sr);
}

public function RenderMenu()
{
    local int i;
    local ModSettingItemData item;
    local ModSettingsSubmenu currentSubmenu;
    
    currentSubmenu = GetCurrentSubmenu();
    ASSetTitle(GetString(currentSubmenu.sTitle, currentSubmenu.srTitle));
    ASSetSubTitle(GetString(currentSubmenu.sSubtitle, currentSubmenu.srSubtitle));
    ASInitializeList(currentDisplayItems.Length, currentSubmenu.scrollIndex, currentSubmenu.selectedIndex);
    // sortDisplayItems();
    for (i = 0; i < currentDisplayItems.Length; i++)
    {
        item = currentDisplayItems[i];
        // SetCustomTokens(item);
        ASUpdateMenuEntry(
            i,
            GetString(item.sLeftText, item.srLeftText),
            GetString(item.sCenterText, item.srCenterText),
            GetString(item.sRightText, item.srRightText),
            GetString(item.sSecondaryText, item.srSecondaryText),
            item.disabled, GetSubmenuFromItem(item) != None);
    }
    // ASSetSelectedIndex(currentSubmenu.selectedIndex, true);
    // ASSetScrollPosition(currentSubmenu.scrollIndex, TRUE);
    ASSetBackButtonText(string(submenuStack.Length > 1 ? srBack : srClose));
}

public function ModSettingsSubmenu GetSubmenuFromItem(ModSettingItemData item)
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

public function ExActionPressed(int selectedIndex)
{
    local ModSettingItemData selectedItem;
    local ModSettingsSubmenu submenu;
    local ModSettingsSubmenu currentSubmenu;
    
    currentSubmenu = GetCurrentSubmenu();
    // if (!currentSubmenu.OnActionButtonPressed(Self, selectedIndex))
    // {
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
            currentSubmenu.scrollIndex = ASGetScrollPosition();
            ApplyItem(selectedItem);
            RefreshMenu();
        }
    // }
}

public function ExOnItemSelected(int selectedIndex)
{
    local ModSettingsSubmenu currentSubmenu;
    local ModSettingItemData selectedItem;
    local string actionText;

    currentSubmenu = GetCurrentSubmenu();
    currentSubMenu.selectedIndex = selectedIndex;
    selectedItem = currentDisplayItems[selectedIndex];
    ASSetDescription(GetString(selectedItem.sDescriptionText, selectedItem.srDescriptionText));
    ASSetRightTitle(GetString(selectedItem.sDescriptionTitleText, selectedItem.srDescriptionTitleText));
    // TODO set image and set cycle image button if applicable
    imageIndex = 0;
    if (selectedItem.Images.length > 0)
    {
        ASSetImage(selectedItem.Images[imageIndex]);
    }
    else
    {
        // TODO some default image or else get rid of the image box in this case???
        ASSetImage("");
    }
    if (!selectedItem.disabled)
    {
        if (GetSubmenuFromItem(selectedItem) != None)
        {
            actionText = string(srOpenSubmenu);
        }
        else
        {
            // default action text for anything in the menu
            actionText = string(srApply);
            // default action text from the submenu
            if (currentSubMenu.srDefaultActionText != 0 || currentSubMenu.sDefaultActionText != "")
            {
                actionText = GetString(currentSubMenu.sDefaultActionText, currentSubMenu.srDefaultActionText);
            }
            // override from the item
            if (selectedItem.srActionText != 0 || selectedItem.sActionText != "")
            {
                actionText = GetString(selectedItem.sActionText, selectedItem.srActionText);
            }
        }
        
        ASSetActionButtonText(actionText);
        ASSetActionButtonActive(true);
    }
    else
    {
        ASSetActionButtonActive(false);
    }
}

public function ApplyItem(ModSettingItemData item)
{
    // TODO
    LogInternal("this is where I would apply an item");
}

// public function ExAuxPressed(int index)
// {
//     LogInternal("Aux pressed");
//     // ASSetAuxButtonActive(false);
//     ASSetDescription(generateLines(1000));
//     ASSetRightTitle("1000");
// }

// public function ExAux2Pressed(int index)
// {
//     LogInternal("Aux 2 pressed");
//     // ASSetAux2ButtonActive(false);
//     ASSetDescription(generateLines(50));
//     ASSetRightTitle("50");
// }

defaultproperties
{
    RootSubmenuPath = "ModSettings_Submenus_MSM.ModSettingsSubmenu_Root"
    // srBack = $174627
    // srClose = $161206
    // srDefaultActionText = $177145
    // srOpenSubmenu = $177824
    // srCycleImages = $200007
    // srScroll = $200012
}