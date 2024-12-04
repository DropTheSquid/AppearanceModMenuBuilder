Class SFXSFHandler_Personalization_AMM extends SFXSFHandler_PCPersonalization
    config(UI);

// called from the ActionScript when you push the new button
public function CustomizeFace()
{
    local BioSFPanel panel;
    
    // ApplyChangesNoSave();
    // SetEnabledAndVisible(FALSE);
    // panel = MassEffectGuiManager(oPanel.oParentManager).CreatePanel('AMM', TRUE);
    // panel.bFullScreen = TRUE;
    // AppearanceModMenu(panel.GetDefaultHandler()).SetExternalCallback_OnComplete(OnAMMExit);
    LogInternal("The new button has been pressed!");
}
// public function OnPanelRemoved()
// {
//     PlayGuiSound('PersonalizeExit');
//     Super(BioSFHandler).OnPanelRemoved();
//     if (m_WorldInfo != None)
//     {
//         if (m_oPlayerPawn != None)
//         {
//             if (m_WorldInfo.m_UIWorld != None)
//             {
//                 m_WorldInfo.m_UIWorld.DestroyPawn(m_oPlayerPawn);
//             }
//         }
//         if (m_WorldInfo.m_UIWorld != None)
//         {
//             m_WorldInfo.m_UIWorld.ResetActors();
//             m_WorldInfo.m_UIWorld.TriggerEvent('LightsOff', m_WorldInfo);
//         }
//     }
//     ClearDelegates();
// }
// public function SetEnabledAndVisible(bool bVal)
// {
//     oPanel.SetInputDisabled(!bVal);
//     oPanel.IsVisible = bVal;
// }
// public function OnAMMExit()
// {
//     LogInternal("The thing was called", );
//     SetEnabledAndVisible(TRUE);
//     InitializeUIWorld();
// }
// public function ApplyChangesNoSave()
// {
//     local SFXPawn_Player oUIPawn;
//     local SFXSaveDescriptor SaveDescriptor;
    
//     oUIPawn = GetUIWorldPlayerPawn();
//     if (oUIPawn == m_oPlayerPawn)
//     {
//         return;
//     }
//     m_oPlayerPawn.CopyPawnAppearance(oUIPawn);
//     if (HelmetID != m_oPlayerPawn.HelmetID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Helmet", m_oPlayerPawn.HelmetID, "outfit");
//     }
//     if (CasualID != m_oPlayerPawn.CasualID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Casual", CasualID, "outfit");
//     }
//     if (FullBodyID != m_oPlayerPawn.FullBodyID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Fullbody", m_oPlayerPawn.FullBodyID, "outfit");
//     }
//     if (TorsoID != m_oPlayerPawn.TorsoID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Torso", m_oPlayerPawn.TorsoID, "outfit");
//     }
//     if (ShoulderID != m_oPlayerPawn.ShoulderID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Shoulder", m_oPlayerPawn.ShoulderID, "outfit");
//     }
//     if (ArmID != m_oPlayerPawn.ArmID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Arm", m_oPlayerPawn.ArmID, "outfit");
//     }
//     if (LegID != m_oPlayerPawn.LegID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Leg", m_oPlayerPawn.LegID, "outfit");
//     }
//     if (Tint1ID != m_oPlayerPawn.Tint1ID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Tint1", m_oPlayerPawn.Tint1ID, "color");
//     }
//     if (Tint2ID != m_oPlayerPawn.Tint2ID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Tint2", m_oPlayerPawn.Tint2ID, "color");
//     }
//     if (PatternID != m_oPlayerPawn.PatternID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Pattern", m_oPlayerPawn.PatternID, "decal");
//     }
//     if (PatternColorID != m_oPlayerPawn.PatternColorID)
//     {
//         Class'SFXTelemetry'.static.SendCustomization("Patterncolor", m_oPlayerPawn.PatternColorID, "color");
//     }
//     CasualID = m_oPlayerPawn.CasualID;
//     FullBodyID = m_oPlayerPawn.FullBodyID;
//     TorsoID = m_oPlayerPawn.TorsoID;
//     ShoulderID = m_oPlayerPawn.ShoulderID;
//     ArmID = m_oPlayerPawn.ArmID;
//     LegID = m_oPlayerPawn.LegID;
//     Tint1ID = m_oPlayerPawn.Tint1ID;
//     Tint2ID = m_oPlayerPawn.Tint2ID;
//     PatternID = m_oPlayerPawn.PatternID;
//     PatternColorID = m_oPlayerPawn.PatternColorID;
//     HelmetID = m_oPlayerPawn.HelmetID;
// }

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}