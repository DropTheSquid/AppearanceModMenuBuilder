Class ModMenuBase extends CustomUIHandlerInterface;

// Types
enum eMenuItemState
{
    normal,
    disabled,
    green,
};
enum eScrollWheelDir
{
    up,
    down,
};

// Variables
var float RStickDeadZone;

// Functions
// protected static function comment(string sComment);

public function OnPanelAdded()
{
    // comment("--------------------------ModMenuBase----------------------------------");
    // comment("-----------------------------------------------------------------------");
    // comment("This class is a low level base with almost no logic in it. It provides all the functions to communicate with the ActionScript and run the UI with sensible defaults, and almost nothing else.");
    // comment("Each method should have comments describing what it is used for and when you should call it or override it.");
    // comment("You should pretty much never need to directly edit this class.");
    // comment("-----------------------------------------------------------------------");
    // comment("Don't mess with this function, everything will break if you do. If you override it, be sure to call it via Super.OnPanelAdded()");
    // comment("This is only for very early initialization; the UI will not be ready for calls yet when this is called");
    // comment("This next call is the secret sauce that lets ActionScript call into UnrealScript easily and be handled by this instance.");
    oPanel.SetExternalInterface(Self);
    Super(BioSFHandler).OnPanelAdded();
    if (!Class'WorldInfo'.static.IsConsoleBuild())
    {
        SetMouseShown(!oPanel.bUsingGamepad);
    }
}
public event function HandleButtonRefresh(bool usingGamepad)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Also don't mess with this, it governs the UI updating between PC and console layouts; if you must override it to do something when the user switches inputs be sure to still call the base version.");
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = usingGamepad;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("RefreshButtonHelp", Parameters);
}
public function Update(float fDeltaT)
{
    // comment("This runs constantly, every tick I think. If you need to update anything over time, override this and call the original.");
	SetMouseShown(!oPanel.bUsingGamepad);
}
public function OnPanelRemoved()
{
    // comment("Called once when the UI is removed. Override and call the original if you need to do additional cleanup work besides calling the on close delegate.");
    Super(BioSFHandler).OnPanelRemoved();
}
public function bool CallOnCloseDelegate()
{
    if (__OnCloseCallback__Delegate != None)
    {
        return __OnCloseCallback__Delegate(Self);
    }
    return FALSE;
}
public function Close()
{
    if (!CallOnCloseDelegate())
    {
        oPanel.oParentManager.RemovePanel(oPanel);
    }
}
public function HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    local BioPlayerController oController;
    local BioPlayerInput bpi;
    
    // comment("Called when there is key input. Override if you need to do things in response to keys that are not already handled by other code. Make sure you call the original if you want handling of the right stick");
    oController = BioWorldInfo(oWorldInfo).GetLocalPlayerController();
    bpi = BioPlayerInput(oController.PlayerInput);
    switch (Event)
    {
        case BioGuiEvents.BIOGUI_EVENT_AXIS_RSTICK_X:
            fValue = bpi.AxisBuffer[2];
            if (Abs(fValue) > RStickDeadZone)
            {
                OnRStickX(fValue);
            }
            else
            {
                OnRStickX(0.0);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_AXIS_RSTICK_Y:
            fValue = bpi.AxisBuffer[3];
            if (Abs(fValue) > RStickDeadZone)
            {
                OnRStickY(fValue);
            }
            else
            {
                OnRStickY(0.0);
            }
            break;
        default:
            Super(BioSFHandler).HandleInputEvent(Event, fValue);
    }
}
public function OnRStickX(float val);

public function OnRStickY(float val);

public function ASLoadedEx()
{
    // comment("This will get called from the GUI when things are loaded and it is ready to add content!");
    // comment("Override this and populate your menu and customize the behavior.");
}
public function LogEX(string funcName, string message)
{
    // comment("This gets called from the GUI to log various things. Can be safely ignored or overriden");
    LogInternal("AS LOG:" @ funcName @ message, );
}
public function BackButtonPressedEx()
{
    // comment("This will get called from the GUI when the back button, escape, or B on the controller are pressed.");
    // comment("The default behavior is to exit the UI. Override it if you need it to do anything else.");
    Close();
}
public function ActionButtonPressedEx(int selectedIndex)
{
    // comment("This will get called from the GUI when a list item is highlighted and you click the bottom left 'action' button, press A on a controller, press enter, or if you double click an item (by default).");
    // comment("Override it to do something useful!");
}
public function AuxButtonPressedEx(int selectedIndex)
{
    // comment("This will get called from the GUI when a list item is highlighted and you click the bottom middle button or X on a controller.");
    // comment("Override it to do something useful!");
}
public function Aux2ButtonPressedEx(int selectedIndex)
{
    // comment("This will get called from the GUI when you click the upper middle button or Y on a controller.");
    // comment("Override it to do something useful!");
}
public function ItemSelectedEx(int selectedIndex)
{
    // comment("This will get called from the GUI when you highlight an item by single clicking on it or navigating to the item using a controller left stick, dpad, or the arrow keys.");
    // comment("You probably don't need to touch this.");
}
public function ItemDoubleClickedEx(int selectedIndex)
{
    // comment("This will get called from the GUI when you double click an item. By default it counts this as invoking the primary action on the item.");
    // comment("You probably don't need to touch this.");
    ActionButtonPressedEx(selectedIndex);
}
public function ItemHoverEx(int hoverIndex)
{
    // comment("This will get called when the mouse rolls over an item in the list");
    // comment("You probably don't need to do anything with this.");
}
public function ItemUnoverEx(int hoverIndex)
{
    // comment("This will get called when the mouse rolls out of an item in the list");
    // comment("You probably don't need to do anything with this.");
}
public function bool ItemActiveEx(int index)
{
    // comment("when an item is selected; return true to cancel animation");
    return FALSE;
}
public function bool ItemInactiveEx(int index)
{
    // comment("when an item is unselected; return true to cancel animation");
    return FALSE;
}
public function bool ItemHoveredEx(int index)
{
    // comment("when an mouse starts to hover over an item; return true to cancel animation");
    return FALSE;
}
public function bool ItemUnhoveredEx(int index)
{
    // comment("when an mouse stops hovering over an item; return true to cancel animation");
    return FALSE;
}
public function OnScrollWheelEX(eScrollWheelDir direction, bool overList, bool overRightPane)
{
    // comment("called when the scroll wheel is moved, with parameters of whether the mouse is over the list in the left pane, or the right pane, or neither.");
    // comment("By default, it will scroll the right pane text if the mouse is over the right pane, and otherwise will scroll the list.");
    if (!overRightPane)
    {
        Self.ASMoveListScrollBar(direction == eScrollWheelDir.down ? 1 : -1);
    }
    else
    {
        Self.ASMoveDetailScrollbar(direction == eScrollWheelDir.down ? 1 : -1);
    }
}
public function IsScrollableEx(bool scrollable)
{
    // comment("Called when it changes whether the right pane can be scrolled");
}
public function ASSetTitle(string title)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the main title text");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = title;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetTitle", Parameters);
}
public function ASSetSubTitle(string title)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the subtitle text");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = title;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetSubtitle", Parameters);
}
public function ASSetActionButtonText(string actionButtonText)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the text on the action/A button");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = actionButtonText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetActionButtonText", Parameters);
}
public function ASSetAuxButtonText(string auxButtonText)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the text on the auxiliary/X button");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = auxButtonText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetAuxButtonText", Parameters);
}
public function ASSetAux2ButtonText(string aux2ButtonText)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the text on the auxiliary/Y button");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = aux2ButtonText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetAux2ButtonText", Parameters);
}
public function ASSetBackButtonText(string backButtonText)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the text on the back/B button (only visible in controller UI)");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = backButtonText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetBackButtonText", Parameters);
}
public function ASSetActionButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets whether the action/A button is visible and active");
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetActionButtonActive", Parameters);
}
public function ASSetAuxButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets whether the auxiliary/X button is visible and active");
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetAuxButtonActive", Parameters);
}
public function ASSetAux2ButtonActive(bool active, bool useAlternatePosition)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets whether the auxiliary/Y button is visible and active");
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    Param.bVar = useAlternatePosition;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetAux2ButtonActive", Parameters);
}
public function ASSetBackButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets whether the back/B button is visible and active");
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetBackButtonActive", Parameters);
}
public function ASSetHeaderVisibility(bool visible)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets whether the header between the subitles is visible");
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = visible;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetHeaderVisibility", Parameters);
}
public function ASSetRightPaneVisibility(bool visible, bool fade)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = visible;
    Parameters.AddItem(Param);
    Param.bVar = fade;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetRightPaneVisibility", Parameters);
}
public function ASSetRightPaneTitleText(string titleText)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = titleText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetRightPaneTitleText", Parameters);
}
public function ASUpdatePicture(string asset)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = asset;
    Parameters.AddItem(Param);
    Param.sVar = "shotOne";
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("updateScreenShot", Parameters);
}
public function ASStartSlotList(int length)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the size of the item list. Must be called before you can add or update an item.");
    // comment("function StartSlotList(nNumSlots)");
    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = length;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("StartSlotList", Parameters);
}
public function ASAddOrUpdateEntry(int index, string leftText, string centerText, string rightText, eMenuItemState state, bool showPlus)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets up a list item; sets text and state (normal, disabled, or green; green not recommended).");
    // comment("function AddOrUpdateMenuItem(nIndex, leftText, centerText, rightText, state)");
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
    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = int(state);
    Parameters.AddItem(Param);
	Param.Type = ASParamTypes.ASParam_Boolean;
	Param.bVar = showPlus;
	Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("AddOrUpdateMenuItem", Parameters);
}
public function ASSetSelectedIndex(int index)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets which index is selected.");
    // comment("function SetListSelectedIndex(nIndex)");
    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = index;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetListSelectedIndex", Parameters);
}
public function ASSetListScrollPosition(int position, bool instant)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets which index is selected.");
    // comment("function SetListScrollPosition(nIndex, bInstant)");
    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = position;
    Parameters.AddItem(Param);
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = instant;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetListScrollPosition", Parameters);
}
public function int ASGetListScrollPosition()
{
    return int(oPanel.InvokeMethodReturn("GetListScrollPosition"));
}
public function ASSetListVisible(bool visible)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets whether the menu list is visible");
    // comment("function SetListVisible(bVisible)");
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = visible;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetListVisible", Parameters);
}
public function ASMoveListScrollBar(int steps)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("moves the scrollbar. positive numbers scroll down. negative scroll up");
    // comment("function MoveListScrollBar(dir)");
    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = steps;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("MoveListScrollBar", Parameters);
}
public function ASSetRightPaneText(string text)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("function SetRightPaneText(sText)");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = text;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetRightPaneText", Parameters);
}
public function ASMoveDetailScrollbar(int steps)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Moves the right pane text scrollbar. Positive scrolls down. Negative scrolls up");
    // comment("function MoveDetailScrollBar(dir)");
    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = steps;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("MoveDetailScrollBar", Parameters);
}
public function ASScrollDetailsAnalog(float val)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Moves the right pane text scrollbar. Positive scrolls down. Negative scrolls up");
    // comment("function scrollDetailsAnalog(val)");
    Param.Type = ASParamTypes.ASParam_Float;
    Param.fVar = val;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("scrollDetailsAnalog", Parameters);
}
public function ASSetControllerButtonText(string buttonName, string buttonText)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the text on a controller prompt");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = buttonName;
    Parameters.AddItem(Param);
    Param.sVar = buttonText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetControllerButtonText", Parameters);
}
public function ASSetControllerButtonActive(string buttonName, bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("sets whether a controller button prompt is shown");
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = buttonName;
    Parameters.AddItem(Param);
    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetControllerButtonActive", Parameters);
}
public function ASSetControllerLayout(int layout)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    // comment("Sets the controller layout. determines if stick press vs scroll is shown, among other things. 0-3 are valid values.");
    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = layout;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetControllerLayout", Parameters);
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}