class ModHandler_ModMenuBase extends ModHandler_base
    abstract
    config(UI);

public function ExASLoaded()
{
    // called when the actionscript is loaded and ready to work with
    HandleButtonRefresh(oPanel.bUsingGamepad);
}

public function LogFromAS(string message)
{
    LogInternal("AS LOG:"@message);
}

public function SetTitle(string title)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = title;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setTitle", Parameters);
}

public function SetSubtitle(string subtitle)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = subtitle;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setSubtitle", Parameters);
}

// must be called before you add or update any items
public function InitializeList(int size)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = size;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.initializeList", Parameters);
}

public function updateMenuEntry(int index, string leftText, string centerText, string rightText, string secondaryText, bool disabled, bool showPlus)
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
public function OnItemHovered(int index)
{
    // item hovered with a mouse
    LogInternal("item"@index@"hovered");
}

public function OnItemSelected(int index)
{
    // item single clicked with a mouse, or reached by navigating with controller/up down buttons/scrolling
    LogInternal("item"@index@"selected");
}

public function OnItemDoubleClicked(int index)
{
    // double clicked; by default will go to PC action
    LogInternal("item"@index@"double clicked");
    ExActionPressed(index);
}

public function ExActionPressed(int index)
{
    // PC action button or controller A pressed while this item is selected
    LogInternal("item"@index@"action");
}

public function ExAuxPressed(int index)
{
    // PC button 2/controller X
    LogInternal("item"@index@"aux");
}

public function ExAux2Pressed(int index)
{
    // PC button 3/controller Y
    LogInternal("item"@index@"aux2");
}

public function ExBackPressed()
{
    // when the back/controller B button is pressed
    LogInternal("back");
}

public function SetActionButtonText(string actionText)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = actionText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setAText", Parameters);
}

public function SetActionButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setAActive", Parameters);
}

public function SetAuxButtonText(string auxText)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = auxText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setXText", Parameters);
}

public function SetAuxButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setXActive", Parameters);
}

public function SetAux2ButtonText(string aux2Text)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = aux2Text;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setYText", Parameters);
}

public function SetAux2ButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setYActive", Parameters);
}

public function SetBackButtonText(string backText)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = backText;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setBText", Parameters);
}

public function SetBackButtonActive(bool active)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Boolean;
    Param.bVar = active;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setBActive", Parameters);
}

public function SetDescription(string description)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = description;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.SetDescription", Parameters);
}

public function SetRightTitle(string rightTitle)
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
// public function ScrollText(float fValue)
// {
//     if (oPanel.bUsingGamepad)
//     {
//         Super.ScrollText(fValue);
//     }
// }
public function OnPanelAdded()
{
    oPanel.SetExternalInterface(Self);
    SetMouseShown(!oPanel.bUsingGamepad);
    Super.OnPanelAdded();
}

public function SetSelectedIndex(int selectedIndex)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = selectedIndex;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.setSelectedIndex", Parameters);
}

public function SetScrollPosition(int scrollPosition, bool skipAnimate)
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
public function ScrollList(int dir)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = dir;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.scrollList", Parameters);
}

public function PageList(int dir)
{
    local ASParams Param;
    local array<ASParams> Parameters;

    Param.Type = ASParamTypes.ASParam_Integer;
    Param.nVar = dir;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("ChoiceGuiInstance.pageList", Parameters);
}

public function int GetScrollPosition()
{
    return int(oPanel.InvokeMethodReturn("ChoiceGuiInstance.getScrollPosition"));
}

public function int GetSelectedIndex()
{
    return int(oPanel.InvokeMethodReturn("ChoiceGuiInstance.getSelectedIndex"));
}





// what uses will I have for this?
// AMM
// BBP
// Mod Settings Menu
// better stores?

// is it worth totally reworking it for those? I can make choiceGUI work with minor adjustments
// honestly, yeah. I will need to tweak more things for AMM. I will do it. 
