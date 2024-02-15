Class AMM_DialogBox_Handler extends AMM_Handler_Helper;

var stringref srConfirmationText;
var stringref srConfirmationConfirm;
var stringref srConfirmationStay;
var transient BioSFHandler_MessageBox oMsgBox;
var transient float msgBoxFadeInElapsedTime;
var float msgBoxFadeInTime;
var int maxOpacity;

public function ConfirmExitDialog()
{
    local BioMessageBoxOptionalParams stParams;
    
    oMsgBox = MassEffectGuiManager(_outerMenu.oPanel.oParentManager).CreateMessageBox();
    oMsgBox.SetInputDelegate(ConfirmationInputPressed);
    msgBoxFadeInElapsedTime = 0.0;
    oMsgBox.SetUpdateDelegate(MessageBoxUpdate);
    stParams.srAText = srConfirmationConfirm;
    stParams.srBText = srConfirmationStay;
    oMsgBox.DisplayMessageBox(srConfirmationText, stParams);
}
private function ConfirmationInputPressed(bool bAPressed, int nContext, bool bYPressed)
{
	_outerMenu.ConfirmExitDialogInputPressed(bAPressed);
    oMsgBox = None;
}

private function MessageBoxUpdate(float fDeltaT, BioSFHandler_MessageBox oMsgBoxParam)
{
    local string sPendingEvent;
    local int currentFrame;
    
    sPendingEvent = oMsgBoxParam.oPanel.GetVariableString("_root.sPendingEvent");
    if (sPendingEvent == "")
    {
        if (msgBoxFadeInElapsedTime < msgBoxFadeInTime)
        {
            msgBoxFadeInElapsedTime += fDeltaT;
            SetMessageBoxBGOpacity(int(msgBoxFadeInElapsedTime / msgBoxFadeInTime * float(maxOpacity)));
        }
    }
    else if (msgBoxFadeInElapsedTime > 0.0)
    {
        msgBoxFadeInElapsedTime -= fDeltaT;
        SetMessageBoxBGOpacity(int(msgBoxFadeInElapsedTime / msgBoxFadeInTime * float(maxOpacity)));
    }
}
private final function int GetMessageBoxBGOpacity()
{
    return oMsgBox.oPanel.GetVariableInt("windowMC.bgMC._alpha");
}
private final function SetMessageBoxBGOpacity(int opacity)
{
    oMsgBox.oPanel.SetVariableInt("windowMC.bgMC._alpha", opacity);
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
	// "Confirm"
    srConfirmationConfirm = $168235
	// added by this mod. Asks you to confirm leaving the menu (only during prologue) and tells you how to edit your looks later
    srConfirmationText = $210210212
	// "Stay"
    srConfirmationStay = $173053
    msgBoxFadeInTime = 0.25
    maxOpacity = 120
}