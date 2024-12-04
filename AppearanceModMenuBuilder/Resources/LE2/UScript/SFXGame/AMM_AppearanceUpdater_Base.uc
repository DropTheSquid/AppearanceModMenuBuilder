Class AMM_AppearanceUpdater_Base;

public static function bool IsMergeModInstalled(out AMM_AppearanceUpdater_Base basegamgeInstance)
{
	basegamgeInstance = AMM_AppearanceUpdater_Base(FindObject("SFXGame.AMM_AppearanceUpdater_Base_0", Class'Object'));
	// this lives in SFXGame, so if it is not found, the user has reverted the basegame changes or they were not applied
	// and the mod will not work
	LogInternal("IsMergeModInstalled?"@basegamgeInstance != None);
	return basegamgeInstance != None;
}

public static function bool IsDlcModInstalled(out AMM_AppearanceUpdater_Base dlcInstance)
{
	dlcInstance = AMM_AppearanceUpdater_Base(FindObject("Startup_MOD_AMM.AMM_AppearanceUpdater_0", Class'Object'));
	// this lives in the startup file, so if it if not found, the DLC mod is not installed
	// or hasn't loaded yet, and we should do nothing.
	LogInternal("IsDlcModInstalled?"@dlcInstance != None);
	return dlcInstance != None;
}

protected final static function bool GetInstance(out AMM_AppearanceUpdater_Base instance)
{
	// Return the appropriate instance depending on the state of things
	if (IsDlcModInstalled(instance))
	{
		LogInternal("GetInstance DLC"@PathName(instance));
		return true;
	}
	if (IsMergeModInstalled(instance))
	{
		LogInternal("GetInstance Basegame"@PathName(instance));
		return true;
	}
	// I don't even know how this would happen
	return false;
}
public static function bool LoadMorphHeadStatic(out PlayerSaveRecord ThePlayerRecord, out BioMorphFace morphHead)
{
    local AMM_AppearanceUpdater_Base instance;

	if (GetInstance(instance))
	{
		return instance.LoadMorphHead(ThePlayerRecord, morphHead);
	}
    return false;
}
public function bool LoadMorphHead(out PlayerSaveRecord ThePlayerRecord, out BioMorphFace morphHead)
{
    return false;
}
public static function bool SaveMorphHeadStatic(BioMorphFace Morph, out MorphHeadSaveRecord Record, out bool result)
{
    local AMM_AppearanceUpdater_Base instance;

	if (GetInstance(instance))
	{
		return instance.SaveMorphHead(Morph, Record, result);
	}
    return false;
}
public function bool SaveMorphHead(BioMorphFace Morph, out MorphHeadSaveRecord Record, out bool result)
{
    return false;
}
// public function UpdateAppearance(SFXPawn_Player Player)
// {
//     ValidateAppearanceIDs(Player);
//     Player.UpdateHairAppearance();
//     Player.UpdateBodyAppearance();
//     Player.ClearMaterialInstances();
//     Player.RefreshMaterialInstances();
//     Player.UpdateParameters();
//     Player.UpdateWeaponVisibility();
//     Player.ForceUpdateComponents(TRUE, FALSE);
//     Player.UpdateGameEffects();
//     Player.BlockForTextureStreaming();
//     Player.SetPlayerLOD();
// }
// public function ValidateAppearanceIDs(SFXPawn_Player Player)
// {
//     if (Player.CasualAppearances.Find('Id', Player.CasualID) == -1)
//     {
//         if (Player.CasualAppearances.Length > 0)
//         {
//             Player.CasualID = Player.CasualAppearances[0].Id;
//         }
//     }
//     if (Player.FullBodyAppearances.Find('Id', Player.FullBodyID) == -1)
//     {
//         if (Player.FullBodyAppearances.Length > 0)
//         {
//             Player.FullBodyID = Player.FullBodyAppearances[0].Id;
//         }
//     }
//     if (Player.TorsoAppearances.Find('Id', Player.TorsoID) == -1)
//     {
//         if (Player.TorsoAppearances.Length > 0)
//         {
//             Player.TorsoID = Player.TorsoAppearances[0].Id;
//         }
//     }
//     if (Player.ShoulderAppearances.Find('Id', Player.ShoulderID) == -1)
//     {
//         if (Player.ShoulderAppearances.Length > 0)
//         {
//             Player.ShoulderID = Player.ShoulderAppearances[0].Id;
//         }
//     }
//     if (Player.ArmAppearances.Find('Id', Player.ArmID) == -1)
//     {
//         if (Player.ArmAppearances.Length > 0)
//         {
//             Player.ArmID = Player.ArmAppearances[0].Id;
//         }
//     }
//     if (Player.LegAppearances.Find('Id', Player.LegID) == -1)
//     {
//         if (Player.LegAppearances.Length > 0)
//         {
//             Player.LegID = Player.LegAppearances[0].Id;
//         }
//     }
//     if (Player.HelmetAppearances.Find('Id', Player.HelmetID) == -1)
//     {
//         if (Player.HelmetAppearances.Length > 0)
//         {
//             Player.HelmetID = Player.HelmetAppearances[0].Id;
//         }
//     }
//     if (Player.SpecAppearances.Find('Id', Player.SpecID) == -1)
//     {
//         if (Player.SpecAppearances.Length > 0)
//         {
//             Player.SpecID = Player.SpecAppearances[0].Id;
//         }
//     }
//     if (Player.Tint1Appearances.Find('Id', Player.Tint1ID) == -1)
//     {
//         if (Player.Tint1Appearances.Length > 0)
//         {
//             Player.Tint1ID = Player.Tint1Appearances[0].Id;
//         }
//     }
//     if (Player.Tint2Appearances.Find('Id', Player.Tint2ID) == -1)
//     {
//         if (Player.Tint2Appearances.Length > 0)
//         {
//             Player.Tint2ID = Player.Tint2Appearances[0].Id;
//         }
//     }
//     if (Player.PatternAppearances.Find('Id', Player.PatternID) == -1)
//     {
//         if (Player.PatternAppearances.Length > 0)
//         {
//             Player.PatternID = Player.PatternAppearances[0].Id;
//         }
//     }
//     if (Player.PatternColorAppearances.Find('Id', Player.PatternColorID) == -1)
//     {
//         if (Player.PatternColorAppearances.Length > 0)
//         {
//             Player.PatternColorID = Player.PatternColorAppearances[0].Id;
//         }
//     }
// }
// public function CopyPawnAppearance(SFXPawn_Player Player, BioPawn SourcePawn)
// {
//     local SFXPawn_Player SourcePlayer;
//     local SFXPower Power;
//     local SFXPower Power2;
    
//     SourcePlayer = SFXPawn_Player(SourcePawn);
//     if (SourcePlayer != None)
//     {
//         Player.CombatAppearance = SourcePlayer.CombatAppearance;
//         Player.CasualID = SourcePlayer.CasualID;
//         Player.FullBodyID = SourcePlayer.FullBodyID;
//         Player.TorsoID = SourcePlayer.TorsoID;
//         Player.ShoulderID = SourcePlayer.ShoulderID;
//         Player.ArmID = SourcePlayer.ArmID;
//         Player.LegID = SourcePlayer.LegID;
//         Player.SpecID = SourcePlayer.SpecID;
//         Player.Tint1ID = SourcePlayer.Tint1ID;
//         Player.Tint2ID = SourcePlayer.Tint2ID;
//         Player.PatternID = SourcePlayer.PatternID;
//         Player.PatternColorID = SourcePlayer.PatternColorID;
//         Player.HelmetID = SourcePlayer.HelmetID;
//         if (SourcePawn.PowerManager != None && Player.PowerManager != None)
//         {
//             foreach SourcePawn.PowerManager.Powers(Power, )
//             {
//                 if (SFXPower_PassivePower(Power) != None)
//                 {
//                     foreach Player.PowerManager.Powers(Power2, )
//                     {
//                         if (Power.Class == Power2.Class)
//                         {
//                             Power2.Rank = Power.Rank;
//                         }
//                     }
//                 }
//             }
//         }
//         Player.UpdateAppearance();
//     }
// }
// public function ForceHelmetVisibility(SFXPawn_Player Player, bool bHelmetVisible)
// {
//     if (bHelmetVisible)
//     {
//         ForceShowHelmet(Player, TRUE);
//     }
//     else
//     {
//         ForceHideHelmet(Player, TRUE);
//     }
// }
// public function ForceHideHelmet(SFXPawn_Player Player, bool bHideHelmet)
// {
//     if (bHideHelmet)
//     {
//         Player.OverrideHelmetID = 0;
//     }
//     else
//     {
//         Player.OverrideHelmetID = -1;
//     }
// }
// public function ForceShowHelmet(SFXPawn_Player Player, bool bShowHelmet)
// {
//     local int Idx;
//     local CustomizableElement Helmet;
//     local string HelmetName;
//     local string ChkName;
    
//     if (bShowHelmet)
//     {
//         Idx = Player.HelmetAppearances.Find('Id', Player.HelmetID);
//         if (Idx != -1)
//         {
//             Helmet = Player.HelmetAppearances[Idx];
//             HelmetName = Player.bIsFemale ? Helmet.Mesh.Female : Helmet.Mesh.Male;
//             if (HelmetName != "")
//             {
//                 if (Helmet.Mesh.bHasBreather)
//                 {
//                     Player.OverrideHelmetID = Player.HelmetID;
//                     return;
//                 }
//                 else
//                 {
//                     for (Idx = 0; Idx < Player.HelmetAppearances.Length; Idx++)
//                     {
//                         ChkName = Player.bIsFemale ? Player.HelmetAppearances[Idx].Mesh.Female : Player.HelmetAppearances[Idx].Mesh.Male;
//                         if (ChkName == HelmetName && Player.HelmetAppearances[Idx].Mesh.bHasBreather)
//                         {
//                             Player.OverrideHelmetID = Player.HelmetAppearances[Idx].Id;
//                             return;
//                         }
//                     }
//                 }
//             }
//         }
//         for (Idx = 0; Idx < Player.HelmetAppearances.Length; Idx++)
//         {
//             ChkName = Player.bIsFemale ? Player.HelmetAppearances[Idx].Mesh.Female : Player.HelmetAppearances[Idx].Mesh.Male;
//             if (ChkName != "" && Player.HelmetAppearances[Idx].Mesh.bHasBreather)
//             {
//                 Player.OverrideHelmetID = Player.HelmetAppearances[Idx].Id;
//                 return;
//             }
//         }
//         if (Player.HelmetAppearances.Length > 0)
//         {
//             Player.OverrideHelmetID = Player.HelmetAppearances[0].Id;
//             return;
//         }
//     }
//     Player.OverrideHelmetID = -1;
// }
// public function SaveAppearance(SFXPawn_Player Player, out AppearanceSaveRecord Record)
// {
//     Record.CombatAppearance = Player.CombatAppearance;
//     Record.CasualID = Player.CasualID;
//     Record.FullBodyID = Player.FullBodyID;
//     Record.TorsoID = Player.TorsoID;
//     Record.ShoulderID = Player.ShoulderID;
//     Record.ArmID = Player.ArmID;
//     Record.LegID = Player.LegID;
//     Record.SpecID = Player.SpecID;
//     Record.Tint1ID = Player.Tint1ID;
//     Record.Tint2ID = Player.Tint2ID;
//     Record.Tint3ID = 0;
//     Record.PatternID = Player.PatternID;
//     Record.PatternColorID = Player.PatternColorID;
//     Record.HelmetID = Player.HelmetID;
//     Record.bHasMorphHead = FALSE;
//     if (SaveMorphHead(Player.MorphHead, Record.MorphHead))
//     {
//         Record.bHasMorphHead = TRUE;
//     }
// }
// public function bool SaveMorphHead(BioMorphFace Morph, out MorphHeadSaveRecord Record)
// {
//     local int Idx;
//     local BioMaterialOverride MatOverride;
    
//     if (Morph != None)
//     {
//         Record.HairMesh = Name(PathName(Morph.m_oHairMesh));
//         Record.AccessoryMeshes.Length = Morph.m_oOtherMeshes.Length;
//         for (Idx = 0; Idx < Morph.m_oOtherMeshes.Length; Idx++)
//         {
//             Record.AccessoryMeshes[Idx] = Name(PathName(Morph.m_oOtherMeshes[Idx]));
//         }
//         Record.MorphFeatures.Length = Morph.m_aMorphFeatures.Length;
//         for (Idx = 0; Idx < Morph.m_aMorphFeatures.Length; Idx++)
//         {
//             Record.MorphFeatures[Idx].Feature = Morph.m_aMorphFeatures[Idx].sFeatureName;
//             Record.MorphFeatures[Idx].Offset = Morph.m_aMorphFeatures[Idx].Offset;
//         }
//         Record.OffsetBones.Length = Morph.m_aFinalSkeleton.Length;
//         for (Idx = 0; Idx < Morph.m_aFinalSkeleton.Length; Idx++)
//         {
//             Record.OffsetBones[Idx].Name = Morph.m_aFinalSkeleton[Idx].nName;
//             Record.OffsetBones[Idx].Offset = Morph.m_aFinalSkeleton[Idx].vPos;
//         }
//         Record.LOD0Vertices.Length = Morph.GetNumVerts(0);
//         for (Idx = 0; Idx < Morph.GetNumVerts(0); Idx++)
//         {
//             Record.LOD0Vertices[Idx] = Morph.GetPosition(0, Idx);
//         }
//         MatOverride = Morph.m_oMaterialOverrides;
//         if (MatOverride != None)
//         {
//             Record.ScalarParameters.Length = MatOverride.m_aScalarOverrides.Length;
//             for (Idx = 0; Idx < MatOverride.m_aScalarOverrides.Length; Idx++)
//             {
//                 Record.ScalarParameters[Idx].Name = MatOverride.m_aScalarOverrides[Idx].nName;
//                 Record.ScalarParameters[Idx].Value = MatOverride.m_aScalarOverrides[Idx].sValue;
//             }
//             Record.VectorParameters.Length = MatOverride.m_aColorOverrides.Length;
//             for (Idx = 0; Idx < MatOverride.m_aColorOverrides.Length; Idx++)
//             {
//                 Record.VectorParameters[Idx].Name = MatOverride.m_aColorOverrides[Idx].nName;
//                 Record.VectorParameters[Idx].Value = MatOverride.m_aColorOverrides[Idx].cValue;
//             }
//             Record.TextureParameters.Length = MatOverride.m_aTextureOverrides.Length;
//             for (Idx = 0; Idx < MatOverride.m_aTextureOverrides.Length; Idx++)
//             {
//                 Record.TextureParameters[Idx].Name = MatOverride.m_aTextureOverrides[Idx].nName;
//                 Record.TextureParameters[Idx].Texture = Name(PathName(MatOverride.m_aTextureOverrides[Idx].m_pTexture));
//             }
//         }
//         return TRUE;
//     }
//     return FALSE;
// }
