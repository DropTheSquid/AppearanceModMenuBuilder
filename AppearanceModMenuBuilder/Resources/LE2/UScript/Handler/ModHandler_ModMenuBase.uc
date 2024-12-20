class ModHandler_ModMenuBase extends ModHandler_base
    abstract
    config(UI);

var transient bool m_bStopScroll;
var config float controllerDeadzone;

public function ExASLoaded()
{
    // called when the actionscript is loaded and ready to work with
    HandleButtonRefresh(oPanel.bUsingGamepad);
}

public function ExLog(string message)
{
    LogInternal("AS LOG:"@message);
}

public function ASSetTitle(string title)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = title;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setTitle", Parameters);
}

public function ASSetSubtitle(string subtitle)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = subtitle;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setSubtitle", Parameters);
}

// must be called before you add or update any items
// setting the scroll and initial selection here avoid seeing a single frame of the top of the list
public function ASInitializeList(int size, optional int initialScrollPosition = -1, optional int initialSelection = -1)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = size;
    Parameters.AddItem(Param);
    Param.nVar = initialScrollPosition;
    Parameters.AddItem(Param);
    Param.nVar = initialSelection;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.initializeList", Parameters);
}

public function ASUpdateMenuEntry(int index, string leftText, string centerText, string rightText, string secondaryText, bool disabled, bool showPlus)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = index;
    Parameters.AddItem(Param);
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = leftText;
    Parameters.AddItem(Param);
    Param.sVar = centerText;
    Parameters.AddItem(Param);
    Param.sVar = rightText;
    Parameters.AddItem(Param);
    Param.sVar = secondaryText;
    Parameters.AddItem(Param);
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = disabled;
    Parameters.AddItem(Param);
	Param.bVar = showPlus;
	Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.updateMenuEntry", Parameters);
}

// TODO need to hook this up, return a bool to handle it?
public function ExOnItemHover(int index)
{
    // item hovered with a mouse
    // LogInternal("item"@index@"hovered");
}

public function ExOnItemUnHover(int index)
{
    // mouse leaves an item it was hovering
    // LogInternal("item"@index@"un hovered");
}

public function ExOnItemSelected(int index)
{
    // item single clicked with a mouse, or reached by navigating with controller/up down buttons/scrolling
    // LogInternal("item"@index@"selected");
}

public function ExOnItemDoubleClicked(int index)
{
    // double clicked; by default will go to PC action
    // LogInternal("item"@index@"double clicked");
    ExActionPressed(index);
}

public function ExActionPressed(int index)
{
    // PC action button or controller A pressed while this item is selected
    // LogInternal("item"@index@"action");
}

public function ExAuxPressed(int index)
{
    // PC button 2/controller X
    // LogInternal("item"@index@"aux");
}

public function ExAux2Pressed(int index)
{
    // PC button 3/controller Y
    // LogInternal("item"@index@"aux2");
}

public function ExBackPressed()
{
    // when the back/controller B button is pressed
    // be default, close the UI
    MassEffectGuiManager(oPanel.oParentManager).RemovePanel(oPanel);
}

public function ASSetActionButtonText(string actionText)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = actionText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setAText", Parameters);
}

public function ASSetActionButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setAActive", Parameters);
}

public function ASSetAuxButtonText(string auxText)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = auxText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setXText", Parameters);
}

public function ASSetAuxButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setXActive", Parameters);
}

public function ASSetAux2ButtonText(string aux2Text)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = aux2Text;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setYText", Parameters);
}

public function ASSetAux2ButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setYActive", Parameters);
}

public function ASSetBackButtonText(string backText)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = backText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setBText", Parameters);
}

public function ASSetBackButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setBActive", Parameters);
}

public function ASSetDescription(string description)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = description;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.SetDescription", Parameters);
}

public function ASSetRightTitle(string rightTitle)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = rightTitle;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.SetRightTitle", Parameters);
}

public event function HandleButtonRefresh(bool usingGamepad)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = usingGamepad;
    Parameters.AddItem(Param);
    SetMouseShown(!usingGamepad);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.RefreshButtonHelp", Parameters);
}

public function OnPanelAdded()
{
    oPanel.SetExternalInterface(Self);
    SetMouseShown(!oPanel.bUsingGamepad);
    Super.OnPanelAdded();
}

public function ASSetSelectedIndex(int selectedIndex, bool skipAnimation)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = selectedIndex;
    Parameters.AddItem(Param);
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = skipAnimation;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setSelectedIndex", Parameters);
}

public function ASSetScrollPosition(int scrollPosition, bool skipAnimate)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = scrollPosition;
    Parameters.AddItem(Param);
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = skipAnimate;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setScrollPosition", Parameters);
}

// down is > 0, up is < 0
public function ASScrollList(int dir)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = dir;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.scrollList", Parameters);
}

// public function ASPageList(int dir)
// {
//     local ASParams Param;
//     local array<ASParams> Parameters;

//     Param.Type = ASParamTypes.ASParam_Integer;
//     Param.nVar = dir;
//     Parameters.AddItem(Param);
//     oPanel.InvokeMethodArgs("ChoiceGuiInstance.pageList", Parameters);
// }


public function ASScrollInfoTextDiscrete(int steps)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    // number of lines to scroll
    Param.nVar = steps * -1;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.ScrollInfoTextDiscrete", Parameters);
}

public function ASScrollDetailText(float scroll)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Float;
    Param.fVar = scroll;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.ScrollInfoText", Parameters);
}

public function ASStopScrollDetailText()
{
    oPanel.InvokeMethod("ChoiceGuiInstance.StopInfoScroll");
}

public function int ASGetScrollPosition()
{
    return int(oPanel.InvokeMethodReturn("ChoiceGuiInstance.getScrollPosition"));
}

public function int ASGetSelectedIndex()
{
    return int(oPanel.InvokeMethodReturn("ChoiceGuiInstance.getSelectedIndex"));
}

public function ScrollText(float fValue)
{
    if (Abs(fValue) <= controllerDeadzone)
    {
        if (m_bStopScroll)
        {
            ASStopScrollDetailText();
            m_bStopScroll = FALSE;
        }
        return;
    }
    ASScrollDetailText(fValue * float(2));
    m_bStopScroll = TRUE;
}

public function HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    switch (Event)
    {
        case BioGuiEvents.BIOGUI_EVENT_AXIS_RSTICK_Y:
            // the game imposes a truly ridiculous deadzone on the input; this bit of code gets around it for much more sensitivity
            fValue = BioPlayerInput(BioWorldInfo(oWorldInfo).GetLocalPlayerController().PlayerInput).AxisBuffer[3];
            if (Abs(fValue) < controllerDeadzone)
            {
                fValue = 0;
            }
            OnRStickY(fValue);
            break;
        case BioGuiEvents.BIOGUI_EVENT_AXIS_RSTICK_X:
            // the game imposes a truly ridiculous deadzone on the input; this bit of code gets around it for much more sensitivity
            fValue = BioPlayerInput(BioWorldInfo(oWorldInfo).GetLocalPlayerController().PlayerInput).AxisBuffer[2];
            if (Abs(fValue) < controllerDeadzone)
            {
                fValue = 0;
            }
            OnRStickX(fValue);
            break;
        default:
            Super.HandleInputEvent(Event, fValue);
            return;
    }
}

public function OnRStickY(float val)
{
    ScrollText(-val);
}

public function OnRStickX(float val)
{
}

public function ExOnScrollWheel(int dir, bool overRightPane, bool overList)
{
    if (overList)
    {
        ASScrollList(dir);
    }
    else if (overRightPane)
    {
        ASScrollInfoTextDiscrete(dir);
    }
}

public function ASSetImage(string imagePath)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = imagePath;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.DisplayImageForChoice", Parameters);
    
}




// what uses will I have for this?
// AMM
// BBP
// Mod Settings Menu
// better stores?

// is it worth totally reworking it for those? I can make choiceGUI work with minor adjustments
// honestly, yeah. I will need to tweak more things for AMM. I will do it. 

defaultproperties
{
    controllerDeadzone = 0.1
}