Class ModHandler_Inventory_AMM extends BioSFHandler_PCInventory
    config(UI);

// Variables
var stringref srCustomizeAppearance;
// hold onto a reference to this so it always stays in memory; without this, you can run into issues
var GFxMovieInfo movieInfo;


// Functions
public function HandleEvent(byte nCommand, const out array<string> Parameters)
{
	// this is the event InitializeInventory, which is called at various points during the UI's operation
    if (int(nCommand) == 1)
    {
		// just make sure the text on this button is correct
        ASSetAMMButtonText(string(srCustomizeAppearance));
    }
    Super.HandleEvent(nCommand, Parameters);
}
public function bool ShouldShowAmmButtonEx()
{
	// TODO this should return true only if pawnOverride is set or a special setting is done in mod settings
	return oOverrideDisplayCharacter != None;
}
public function HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
	// this handles the xbox back/select button
    if (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_BACK && ASIsAMMButtonVisible() && ShouldShowAmmButtonEx())
    {
		AmmPressEx();
    }
    else
    {
        Super(BioSFHandler_Inventory).HandleInputEvent(Event, fValue);
    }
}
public function AmmPressEx()
{
    local Class<CustomUIHandlerInterface> AMMClass;
    local CustomUIHandlerInterface AMM;
    local BioWorldInfo oBWI;
    
    oBWI = BioWorldInfo(oWorldInfo);
    if (m_oLastSpawnedPawn != None)
    {
        oBWI.m_UIWorld.DestroyPawn(m_oLastSpawnedPawn);
    }
    AMMClass = Class<CustomUIHandlerInterface>(DynamicLoadObject("AMM.Handler.ModHandler_AMM", Class'Class'));
    AMM = AMMClass.static.LaunchMenu(string(m_oLastSpawnedPawn.Tag));
    AMM.SetOnCloseCallback(OnAMMClose);
    oPanel.SetMovieVisibility(FALSE);
}
public function bool ASIsAMMButtonVisible()
{
    local string ASReturnString;
    
    ASReturnString = oPanel.InvokeMethodReturn("IsAMMButtonVisible");
    return ASReturnString ~= "true";
}
public function ASSetAMMButtonText(string text)
{
    local ASParams Param;
    local array<ASParams> Parameters;
    
    Param.Type = ASParamTypes.ASParam_String;
    Param.sVar = text;
    Parameters.AddItem(Param);
    oPanel.InvokeMethodArgs("SetAmmButtonText", Parameters);
}
public function bool OnAMMClose(BioSFHandler self)
{
    oPanel.SetMovieVisibility(TRUE);
	// recreates the preview pawn
    Update3DCharacter();
    return FALSE;
}
public function OnPanelRemoved()
{
    local int I;
    local int squadSize;
    local BioPlayerSquad oSquad;
    local BioPawn squadmate;
    local Actor tempActor;
    
	// trigger an appearance update on all real world pawns that might have been affected by things in this menu
    foreach BioWorldInfo(oWorldInfo).AllActors(Class'Actor', tempActor, )
    {
        if (BioPawn(tempActor) != None)
        {
			Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(BioPawn(tempActor), "Inventory OnPanelRemoved");
        }
    }
    Super(BioSFHandler_Inventory).OnPanelRemoved();
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    srCustomizeAppearance = $210210211
	movieInfo = GFXMovieInfo'GUI.PCInventory'
}