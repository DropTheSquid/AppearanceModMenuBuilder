Class ModHandler_Inventory_AMM extends BioSFHandler_PCInventory
    config(UI);

// Variables
var stringref srCustomizeAppearance;

public function OnPanelAdded()
{
    Super.OnPanelAdded();
	LogInternal("New handler added");
}

// Functions
public function HandleEvent(byte nCommand, const out array<string> Parameters)
{
	// TODO comment what command this is. needs to be looked up in scaleform
    if (int(nCommand) == 1)
    {
        ASSetAMMButtonText(string(srCustomizeAppearance));
    }
    Super.HandleEvent(nCommand, Parameters);
}
public function HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
	// this handles the xbox back/select button
    if (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_BACK && ASIsAMMButtonVisible())
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
    // local Class<CustomUIHandlerInterface> AMMClass;
    // local CustomUIHandlerInterface AMM;
    // local BioWorldInfo oBWI;
    
    // oBWI = BioWorldInfo(oWorldInfo);
    // if (m_oLastSpawnedPawn != None)
    // {
    //     LogInternal("Destroying UI World Pawn from inventory before launching AMM" @ m_oLastSpawnedPawn, );
    //     oBWI.m_UIWorld.DestroyPawn(m_oLastSpawnedPawn);
    //     LogInternal("pawn destroyed maybe", );
    // }
    // AMMClass = Class<CustomUIHandlerInterface>(DynamicLoadObject("AMM.Handler.ModHandler_AMM", Class'Class'));
    // LogInternal("AMMClass" @ AMMClass, );
    // AMM = AMMClass.static.LaunchMenu(string(m_oLastSpawnedPawn.Tag));
    // LogInternal("AMM instance" @ AMM, );
    // AMM.SetOnCloseCallback(OnAMMClose);
    // oPanel.SetMovieVisibility(FALSE);
	LogInternal("You have pushed the AMM button");
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
    LogInternal("re-spawning UIWorld Pawn after AMM closed" @ m_oLastSpawnedPawn @ oOverrideDisplayCharacter, );
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
}