Class ModHandler_Inventory_AMM extends BioSFHandler_PCInventory
    config(UI);

// Variables
var stringref srCustomizeAppearance;
// hold onto a reference to this so it always stays in memory; without this, you can run into issues
var GFxMovieInfo movieInfo;


// Functions
public function OnPanelAdded()
{
    // store this so it definitely stays in memory
    movieInfo = GFxMovieInfo(FindObject("GUI_MOD_Inventory_AMM.PCInventory", class'GFxMovieInfo'));
    Super.OnPanelAdded();
}
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
    local BioGlobalVariableTable globalVars;
	local int settingValue;
    
    globalVars = BioWorldInfo(oWorldInfo).GetGlobalVariables();
	settingValue = globalVars.GetInt(1592);
	switch (settingValue)
	{
		case 1:
			// TODO return whether this is a non combat area
			return true;
		case 2:
			// TODO return whether you are not actively in combat
			return true;
		case 3:
			// it is set to be always accessible
			return true;
		default:
			// return true only if there is a character override, as in this was accessed from a squad locker
			return oOverrideDisplayCharacter != None;
	}
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
	// make sure it doesn't keep firing equip events and putting the AMM model into weapon poses
	m_fNextEquipTime = 0;
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
    local BioPawn squadPawn;

    // if there is an override pawn, only update them
    if (oOverrideDisplayCharacter != None)
    {
        Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(oOverrideDisplayCharacter, "Inventory OnPanelRemoved");
    }
    else
    {
        // otherwise do the whole squad
        for (I = 0; I < 3; I++)
        {
            SquadPawn = BioPawn(BioWorldInfo(oWorldInfo).m_playerSquad.GetMember(I));
            Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(SquadPawn, "Inventory OnPanelRemoved");
        }
    }

    Super(BioSFHandler_Inventory).OnPanelRemoved();
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    srCustomizeAppearance = $210210211
	// movieInfo = GFXMovieInfo'GUI.PCInventory'
}