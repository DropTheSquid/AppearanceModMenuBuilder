Class AppearanceModMenu extends BioSFHandler_PCChoiceGUI
    config(UI);

struct AMM_AppearanceRecord 
{
    var MorphHeadSaveRecord MorphHead;
    // var bool bUseCasualAppearance;
    // var int CasualID;
    // var int FullBodyID;
    // var int TorsoID;
    // var int ShoulderID;
    // var int ArmID;
    // var int LegID;
    // var int SpecId;
    // var int Tint1ID;
    // var int Tint2ID;
    // var int PatternID;
    // var int PatternColorID;
    // var int HelmetID;
    // var EPlayerAppearanceType CombatAppearance;
    // var EHelmetState helmetState;
};
enum EHelmetState
{
    hidden,
    shown,
    breather,
};

var transient BioWorldInfo m_WorldInfo;
var transient SFXPawn_Player m_oUIWorldPawn;
var transient SFXPawn_Player m_oPlayerPawn;
var transient float m_nRotating;
var config float RotationDegreesPerSecond;
var delegate<ExternalCallback_OnComplete> __ExternalCallback_OnComplete__Delegate;
var transient int currentPreviewYaw;
var config float controllerDeadzone;
var transient array<AppearanceSubMenuBase> submenuStack;
var transient bool rightClickHeld;
var config float mouseRotationMultiplier;
var config float mouseUpDownMultiplier;
var config float MoveUpDownSpeedMultiplier;
var transient Vector OriginalPawnPosition;
var transient Rotator OriginalPawnRotation;
var transient Vector OriginalCameraPosition;
var transient Vector OriginalCameraRotation;
var config Vector AMMPawnPosition;
var config Rotator AMMPawnRotation;
var config Vector AMMCameraPosition;
var config Vector AMMCameraRotation;
var transient float moveUpDownSpeed;
var transient float zoomSpeed;
var transient array<AMM_AppearanceRecord> history;
var transient bool tempLeft;
var transient bool tempRight;
var transient bool tempUp;
var transient bool tempDown;
var transient float currentZoomLevel;
var transient float CurrentHeightLevel;
var InterpCurveFloat ZoomCameraXInterp;
var InterpCurveFloat MaxCameraZInterp;
var InterpCurveFloat MinCameraZInterp;
var config float ZoomXYRatio;
var config float startingHeight;
var config float controllerZoomSpeed;
var config bool debugCamera;

public final function SetDisplayText(string title, string subTitle, string aText, string bText)
{
    local ASParams stParam;
    local array<ASParams> lstParams;
    
    stParam.Type = 2;
    stParam.sVar = title;
    lstParams.AddItem(stParam);
    stParam.sVar = subTitle;
    lstParams.AddItem(stParam);
    stParam.sVar = aText;
    lstParams.AddItem(stParam);
    stParam.sVar = bText;
    lstParams.AddItem(stParam);
    oPanel.InvokeMethodArgs("SetTitles", lstParams);
}
private final function PositionView()
{
    local Vector Location;
    local float zoomCorrection;
    local float MaxHeight;
    local float MinHeight;
    local float Height;
    
    LogInternal("position view", );
    LogInternal("current Zoom Level" @ currentZoomLevel, );
    LogInternal("current Height Level" @ CurrentHeightLevel, );
    Location = GetCameraPosition();
    // Interpolate Camera X and Y according to zoom
    Class'BioInterpolator'.static.InterpolateFloatCurve(zoomCorrection, ZoomCameraXInterp, 0.0, 1.0, currentZoomLevel);
    Location.X = AMMCameraPosition.X + zoomCorrection;
    Location.Y = AMMCameraPosition.Y + zoomCorrection / ZoomXYRatio;
    // calculate camera height range from zoom level
    Class'BioInterpolator'.static.InterpolateFloatCurve(MaxHeight, MaxCameraZInterp, 0.0, 1.0, currentZoomLevel);
    Class'BioInterpolator'.static.InterpolateFloatCurve(MinHeight, MinCameraZInterp, 0.0, 1.0, currentZoomLevel);
    Height = MinHeight + CurrentHeightLevel * (MaxHeight - MinHeight);
    Location.Z = Height;
    LogInternal("new Camera Position:" @ Location, );
    SetCameraPosition(Location);
    CommitCamera();
}

// public final function Vector GetBonePosition(Name Bone)
// {
//     local Class<CustomMorphTargetSet> MorphTargetSet;
//     local bool isFemale;
//     local BioGlobalVariableTable PlotStateData;
//     local int foundIndex;
//     local Vector Offset;
    
//     // first check the current save record
//     foundIndex = history[history.Length - 1].MorphHead.OffsetBones.Find('Name', Bone);
//     if (foundIndex != -1)
//     {
//         Offset = history[history.Length - 1].MorphHead.OffsetBones[foundIndex].Offset;
//         return Offset;
//     }
//     MorphTargetSet = Class'AMM_AppearanceUpdater'.static.GetCustomMorphTargets(PathName(m_oUIWorldPawn.MorphHead.m_oBaseHead), m_oUIWorldPawn.bIsFemale);
//     if (MorphTargetSet == None)
//     {
//         MorphTargetSet = Class'CustomMorphTargetSet';
//     }
//     foundIndex = MorphTargetSet.default.OriginalMeshBoneOffsets.Find('Bone', Bone);
//     if (foundIndex != -1)
//     {
//         Offset = MorphTargetSet.default.OriginalMeshBoneOffsets[foundIndex].Offset;
//     }
//     return Offset;
// }
private final function MorphHeadSaveRecord HandleDefaultShep()
{
    local SFXPawn_Player player;
    local MorphHeadSaveRecord record;
    local MaterialInterface mat;
    local MaterialExpression matExp;
    local string ParamName;
    local MaterialExpressionVectorParameter vectExpr;
    local MaterialExpressionScalarParameter scalExpr;
    local MaterialExpressionTextureSampleParameter2D texExpr;
    local VectorParameterSaveRecord vectorParam;
    local ScalarParameterSaveRecord ScalarParam;
    local TextureParameterSaveRecord TextureParam;
    local LinearColor cValue;
    local float sValue;
    local Texture tValue;
    local int Idx;
    local PlayerSaveRecord completeSaveRecord;
    
    player = m_oPlayerPawn;
    completeSaveRecord.Appearance.bHasMorphHead = TRUE;
    completeSaveRecord.bIsFemale = player.bIsFemale;
    record.AccessoryMeshes.AddItem(Name(PathName(player.HeadMesh.SkeletalMesh) $ "|BaseHead"));
    if (player.m_oHairMesh.SkeletalMesh != None)
    {
        record.HairMesh = Name(PathName(player.m_oHairMesh.SkeletalMesh));
    }
    foreach player.HeadMesh.SkeletalMesh.Materials(mat, )
    {
        foreach mat.GetMaterial().Expressions(matExp, )
        {
            vectExpr = MaterialExpressionVectorParameter(matExp);
            if (vectExpr != None)
            {
                ParamName = string(vectExpr.ParameterName);
                if (ParamName == "EYE_White_Colour_Vector" || ParamName == "EYE_Iris_Colour_Vector" || ParamName == "SkinTone" || ParamName == "Highlight2Color" || ParamName == "HED_Hair_Colour_Vector" || ParamName == "Highlight1Color")
                {
                    if (record.VectorParameters.Find('Name', Name(ParamName)) == -1 && mat.GetVectorParameterValue(Name(ParamName), cValue))
                    {
                        vectorParam.Name = Name(ParamName);
                        vectorParam.Value = cValue;
                        record.VectorParameters.AddItem(vectorParam);
                    }
                }
            }
            scalExpr = MaterialExpressionScalarParameter(matExp);
            if (scalExpr != None)
            {
                ParamName = string(scalExpr.ParameterName);
                if (ParamName == "HED_SPwr_Scalar" || ParamName == "Highlight2SpecExp_Scalar" || ParamName == "Highlight1SpecExp_Scalar" || ParamName == "Hightlight2Intensity" || ParamName == "Hightlight1Intensity")
                {
                    if (record.ScalarParameters.Find('Name', Name(ParamName)) == -1 && mat.GetScalarParameterValue(Name(ParamName), sValue))
                    {
                        ScalarParam.Name = Name(ParamName);
                        ScalarParam.Value = sValue;
                        record.ScalarParameters.AddItem(ScalarParam);
                    }
                }
            }
            texExpr = MaterialExpressionTextureSampleParameter2D(matExp);
            if (texExpr != None)
            {
                ParamName = string(texExpr.ParameterName);
                if (ParamName == "HED_Scalp_Diff" || ParamName == "HAIR_Diff" || ParamName == "HED_Lash_Diff")
                {
                    if (record.TextureParameters.Find('Name', Name(ParamName)) == -1 && mat.GetTextureParameterValue(Name(ParamName), tValue))
                    {
                        TextureParam.Name = Name(ParamName);
                        TextureParam.Texture = Name(PathName(tValue));
                        record.TextureParameters.AddItem(TextureParam);
                    }
                }
            }
        }
    }
    if (player.m_oHairMesh.SkeletalMesh != None)
    {
        foreach player.m_oHairMesh.SkeletalMesh.Materials(mat, )
        {
            foreach mat.GetMaterial().Expressions(matExp, )
            {
                vectExpr = MaterialExpressionVectorParameter(matExp);
                if (vectExpr != None)
                {
                    ParamName = string(vectExpr.ParameterName);
                    if (ParamName == "EYE_White_Colour_Vector" || ParamName == "EYE_Iris_Colour_Vector" || ParamName == "SkinTone" || ParamName == "Highlight2Color" || ParamName == "HED_Hair_Colour_Vector" || ParamName == "Highlight1Color")
                    {
                        if (record.VectorParameters.Find('Name', Name(ParamName)) == -1 && mat.GetVectorParameterValue(Name(ParamName), cValue))
                        {
                            vectorParam.Name = Name(ParamName);
                            vectorParam.Value = cValue;
                            record.VectorParameters.AddItem(vectorParam);
                        }
                    }
                }
                scalExpr = MaterialExpressionScalarParameter(matExp);
                if (scalExpr != None)
                {
                    ParamName = string(scalExpr.ParameterName);
                    if (ParamName == "HED_SPwr_Scalar" || ParamName == "Highlight2SpecExp_Scalar" || ParamName == "Highlight1SpecExp_Scalar" || ParamName == "Hightlight2Intensity" || ParamName == "Hightlight1Intensity")
                    {
                        if (record.ScalarParameters.Find('Name', Name(ParamName)) == -1 && mat.GetScalarParameterValue(Name(ParamName), sValue))
                        {
                            ScalarParam.Name = Name(ParamName);
                            ScalarParam.Value = sValue;
                            record.ScalarParameters.AddItem(ScalarParam);
                        }
                    }
                }
                texExpr = MaterialExpressionTextureSampleParameter2D(matExp);
                if (texExpr != None)
                {
                    ParamName = string(texExpr.ParameterName);
                    if (ParamName == "HED_Scalp_Diff" || ParamName == "HAIR_Diff" || ParamName == "HED_Lash_Diff")
                    {
                        if (record.TextureParameters.Find('Name', Name(ParamName)) == -1 && mat.GetTextureParameterValue(Name(ParamName), tValue))
                        {
                            TextureParam.Name = Name(ParamName);
                            TextureParam.Texture = Name(PathName(tValue));
                            record.TextureParameters.AddItem(TextureParam);
                        }
                    }
                }
            }
        }
    }
    completeSaveRecord.Appearance.MorphHead = record;
    player.MorphHead = Class'SFXSaveGame'.static.LoadMorphHead(completeSaveRecord);
    player.UpdateAppearance();
    return record;
}
public function bool ShouldItemBeIncluded(AppearanceItemData data)
{
    if (data.Gender != EGender.Gender_Either)
    {
        if (data.Gender == EGender.Gender_Female != m_oPlayerPawn.bIsFemale)
        {
            return FALSE;
        }
    }
    return TRUE;
}
public function GetInitialAppearanceRecord()
{
    local AMM_AppearanceRecord record;
    local SFXEngine oEngine;
    
    oEngine = Class'SFXEngine'.static.GetEngine();
    oEngine.CurrentSaveGame.SaveMorphHead(m_oPlayerPawn.MorphHead, record.MorphHead);
    // record.bUseCasualAppearance = m_oPlayerPawn.bUseCasualAppearance;
    // record.CombatAppearance = m_oPlayerPawn.CombatAppearance;
    // record.CasualID = m_oPlayerPawn.CasualID;
    // record.FullBodyID = m_oPlayerPawn.FullBodyID;
    // record.TorsoID = m_oPlayerPawn.TorsoID;
    // record.ShoulderID = m_oPlayerPawn.ShoulderID;
    // record.ArmID = m_oPlayerPawn.ArmID;
    // record.LegID = m_oPlayerPawn.LegID;
    // record.SpecId = m_oPlayerPawn.SpecId;
    // record.Tint1ID = m_oPlayerPawn.Tint1ID;
    // record.Tint2ID = m_oPlayerPawn.Tint2ID;
    // record.PatternID = m_oPlayerPawn.PatternID;
    // record.PatternColorID = m_oPlayerPawn.PatternColorID;
    // record.HelmetID = m_oPlayerPawn.HelmetID;
    history.AddItem(record);
}
public function OnItemSelected(int selectedIndex)
{
    local AppearanceSubMenuBase currentSubMenu;
    local AppearanceItemData selectedItem;
    
    currentSubMenu = GetCurrentSubmenu();
    if (currentSubMenu != None && !currentSubMenu.OnItemSelected(selectedIndex))
    {
        if (selectedIndex >= 0 && selectedIndex < currentSubMenu.shownItems.Length)
        {
            selectedItem = currentSubMenu.shownItems[selectedIndex];
            if (selectedItem.submenuClassName != "")
            {
                PushMenu(selectedItem.submenuClassName, selectedItem.menuParam);
            }
            else
            {
                ApplyAppearanceItem(selectedItem);
            }
        }
    }
}
public function ApplyAppearanceItem(AppearanceItemData Item)
{
    local AMM_AppearanceRecord currentRecord;
    local AMM_AppearanceRecord modifiedRecord;
    
    currentRecord = history[history.Length - 1];
    if (Item.RemoveHeadMorph)
    {
        // This is more complicated than I expected because the game really does not expect to load Iconic Shepard after loading a custom one.
        return;
    }
    else
    {
        modifiedRecord = ApplyDelta(currentRecord, Item);
    }
    m_oUIWorldPawn = SFXPawn_Player(m_WorldInfo.m_UIWorld.GetSpawnedPawn(m_oPlayerPawn));
    ApplyRecord(modifiedRecord, m_oUIWorldPawn);
    history.AddItem(modifiedRecord);
}
public static function ApplyRecord(AMM_AppearanceRecord record, SFXPawn_Player player, optional bool ignoreTransients = FALSE)
{
    local PlayerSaveRecord completeSaveRecord;
    
    if (!ignoreTransients)
    {
        // player.CombatAppearance = record.CombatAppearance;
        // player.bUseCasualAppearance = record.bUseCasualAppearance;
    }
    // player.CasualID = record.CasualID;
    // player.FullBodyID = record.FullBodyID;
    // player.TorsoID = record.TorsoID;
    // player.ShoulderID = record.ShoulderID;
    // player.ArmID = record.ArmID;
    // player.LegID = record.LegID;
    // player.SpecId = record.SpecId;
    // player.Tint1ID = record.Tint1ID;
    // player.Tint2ID = record.Tint2ID;
    // player.PatternID = record.PatternID;
    // player.PatternColorID = record.PatternColorID;
    // player.HelmetID = record.HelmetID;
    completeSaveRecord.Appearance.bHasMorphHead = TRUE;
    completeSaveRecord.Appearance.MorphHead = record.MorphHead;
    completeSaveRecord.bIsFemale = player.bIsFemale;
    player.MorphHead = Class'SFXSaveGame'.static.LoadMorphHead(completeSaveRecord);
    player.UpdateAppearance();
}
public function AMM_AppearanceRecord ApplyDelta(AMM_AppearanceRecord record, AppearanceItemData Item)
{
    record = ApplyClearDelta(record, Item.delta);
    record = ApplyHairMeshDelta(record, Item.delta);
    record = ApplyVectorDelta(record, Item.delta);
    record = ApplyScalarDelta(record, Item.delta);
    record = ApplyTextureDelta(record, Item.delta);
    record = ApplyMorphDelta(record, Item.delta);
    record = ApplyBoneDelta(record, Item.delta);
    record = ApplyAccessoryDelta(record, Item.delta);
    record = ApplyHeadMeshDelta(record, Item.delta);
    record = ApplyBodymeshDelta(record, Item.delta);
    record = ApplyHelmetMeshDelta(record, Item.delta);
    record = ApplyAppearanceConfigDelta(record, Item);
    return record;
}
public static function bool IsNonDefaultName(Name testName)
{
    return testName != 'None';
}
public function AMM_AppearanceRecord ApplyClearDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local MorphHeadSaveRecord EmptyMorphHead;
    
    if (delta.ClearAll)
    {
        record.MorphHead = EmptyMorphHead;
    }
    return record;
}
public function AMM_AppearanceRecord ApplyHairMeshDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    if (delta.HairMesh.Remove)
    {
        record.MorphHead.HairMesh = 'None';
    }
    else if (IsNonDefaultName(delta.HairMesh.Name))
    {
        record.MorphHead.HairMesh = delta.HairMesh.Name;
    }
    return record;
}
public function AMM_AppearanceRecord ApplyVectorDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local int foundIndex;
    local VectorParameterDelta vectorDelta;
    local VectorParameterSaveRecord vectorRecord;
    local LinearColor color;
    
    foreach delta.VectorParameterDeltas(vectorDelta, )
    {
        foundIndex = record.MorphHead.VectorParameters.Find('Name', vectorDelta.Name);
        if (vectorDelta.Remove)
        {
            if (foundIndex != -1)
            {
                record.MorphHead.VectorParameters.Remove(foundIndex, 1);
            }
            if (vectorDelta.Name == '*')
            {
                record.MorphHead.VectorParameters.Length = 0;
            }
        }
        else if (foundIndex != -1)
        {
            record.MorphHead.VectorParameters[foundIndex].Value.R = ApplyFloatDelta(record.MorphHead.VectorParameters[foundIndex].Value.R, vectorDelta.Value.R, 0.0, 1.0);
            record.MorphHead.VectorParameters[foundIndex].Value.G = ApplyFloatDelta(record.MorphHead.VectorParameters[foundIndex].Value.G, vectorDelta.Value.G, 0.0, 1.0);
            record.MorphHead.VectorParameters[foundIndex].Value.B = ApplyFloatDelta(record.MorphHead.VectorParameters[foundIndex].Value.B, vectorDelta.Value.B, 0.0, 1.0);
            record.MorphHead.VectorParameters[foundIndex].Value.A = ApplyFloatDelta(record.MorphHead.VectorParameters[foundIndex].Value.A, vectorDelta.Value.A, 0.0, 1.0);
        }
        else
        {
            color = GetColorParamValue(vectorDelta.Name);
            vectorRecord.Value.R = ApplyFloatDelta(color.R, vectorDelta.Value.R, 0.0, 1.0);
            vectorRecord.Value.G = ApplyFloatDelta(color.G, vectorDelta.Value.G, 0.0, 1.0);
            vectorRecord.Value.B = ApplyFloatDelta(color.B, vectorDelta.Value.B, 0.0, 1.0);
            vectorRecord.Value.A = ApplyFloatDelta(color.A, vectorDelta.Value.A, 0.0, 1.0);
            vectorRecord.Name = vectorDelta.Name;
            record.MorphHead.VectorParameters.AddItem(vectorRecord);
        }
    }
    return record;
}
public final function LinearColor GetColorParamValue(Name colorParameter)
{
    local AMM_AppearanceRecord currentRecord;
    local int foundIndex;
    local LinearColor color;
    
    // first check the current record
    currentRecord = history[history.Length - 1];
    foundIndex = currentRecord.MorphHead.VectorParameters.Find('Name', colorParameter);
    if (foundIndex != -1)
    {
        color = currentRecord.MorphHead.VectorParameters[foundIndex].Value;
        return color;
    }
    // TODO look up the current value if not found
    return color;
}
public final function float GetScalarParamValue(Name scalarParameter)
{
    local float scalar;
    local AMM_AppearanceRecord currentRecord;
    local int foundIndex;
    
    // first check the current record
    currentRecord = history[history.Length - 1];
    foundIndex = currentRecord.MorphHead.ScalarParameters.Find('Name', scalarParameter);
    if (foundIndex != -1)
    {
        scalar = currentRecord.MorphHead.ScalarParameters[foundIndex].Value;
        return scalar;
    }
    // TODO look up the current value if not found
    return scalar;
}
public function AMM_AppearanceRecord ApplyScalarDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local int foundIndex;
    local ScalarParameterDelta scalarDelta;
    local ScalarParameterSaveRecord scalarRecord;
    local float scalar;
    local array<ScalarParameterSaveRecord> scalarParamsToSave;
    
    foreach delta.ScalarParameterDeltas(scalarDelta, )
    {
        foundIndex = record.MorphHead.ScalarParameters.Find('Name', scalarDelta.Name);
        if (scalarDelta.Remove)
        {
            if (foundIndex != -1)
            {
                record.MorphHead.ScalarParameters.Remove(foundIndex, 1);
            }
            if (scalarDelta.Name == '*')
            {
                foreach record.MorphHead.ScalarParameters(scalarRecord, )
                {
                    if (Left(string(scalarRecord.Name), 16) == "AccessoryCombat|" || Left(string(scalarRecord.Name), 16) == "AccessoryCasual|" || Left(string(scalarRecord.Name), 14) == "AccessoryTint|" || Left(string(scalarRecord.Name), 14) == "AccessoryCopy|")
                    {
                        scalarParamsToSave.AddItem(scalarRecord);
                    }
                    record.MorphHead.ScalarParameters = scalarParamsToSave;
                }
            }
        }
        else if (foundIndex != -1)
        {
            record.MorphHead.ScalarParameters[foundIndex].Value = ApplyFloatDelta(record.MorphHead.ScalarParameters[foundIndex].Value, scalarDelta.Value, -100000000.0, 9999999.0);
        }
        else
        {
            scalar = GetScalarParamValue(scalarDelta.Name);
            scalarRecord.Value = ApplyFloatDelta(scalar, scalarDelta.Value, -100000000.0, 9999999.0);
            scalarRecord.Name = scalarDelta.Name;
            record.MorphHead.ScalarParameters.AddItem(scalarRecord);
        }
    }
    return record;
}
public static function AMM_AppearanceRecord ApplyTextureDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local TextureParameterDelta textureDelta;
    local TextureParameterSaveRecord textureRecord;
    local int foundIndex;
    
    foreach delta.TextureParameterDeltas(textureDelta, )
    {
        foundIndex = record.MorphHead.TextureParameters.Find('Name', textureDelta.Name);
        if (textureDelta.Remove)
        {
            if (foundIndex != -1)
            {
                record.MorphHead.TextureParameters.Remove(foundIndex, 1);
            }
            if (textureDelta.Name == '*')
            {
                record.MorphHead.TextureParameters.Length = 0;
            }
        }
        else if (foundIndex != -1)
        {
            record.MorphHead.TextureParameters[foundIndex].Texture = textureDelta.Texture;
        }
        else
        {
            textureRecord.Name = textureDelta.Name;
            textureRecord.Texture = textureDelta.Texture;
            record.MorphHead.TextureParameters.AddItem(textureRecord);
        }
    }
    return record;
}
public static function AMM_AppearanceRecord ApplyMorphDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local int foundIndex;
    local MorphFeatureDelta featureDelta;
    local MorphFeatureSaveRecord featureRecord;
    
    foreach delta.MorphFeatureDeltas(featureDelta, )
    {
        foundIndex = record.MorphHead.MorphFeatures.Find('Feature', featureDelta.Feature);
        if (featureDelta.Remove)
        {
            if (foundIndex != -1)
            {
                record.MorphHead.MorphFeatures.Remove(foundIndex, 1);
            }
            if (featureDelta.Feature == '*')
            {
                for (foundIndex = record.MorphHead.MorphFeatures.Length - 1; foundIndex >= 0; foundIndex--)
                {
                    if (!IsMorphFeatureABoneAdjust(string(record.MorphHead.MorphFeatures[foundIndex].Feature)))
                    {
                        record.MorphHead.MorphFeatures.Remove(foundIndex, 1);
                    }
                }
            }
        }
        else if (foundIndex != -1)
        {
            record.MorphHead.MorphFeatures[foundIndex].Offset = ApplyFloatDelta(record.MorphHead.MorphFeatures[foundIndex].Offset, featureDelta.Offset, 0.0, 1.0);
        }
        else
        {
            featureRecord.Offset = ApplyFloatDelta(0.0, featureDelta.Offset, 0.0, 1.0);
            featureRecord.Feature = featureDelta.Feature;
            record.MorphHead.MorphFeatures.AddItem(featureRecord);
        }
    }
    return record;
}
private static final function bool IsMorphFeatureABoneAdjust(coerce string featureName)
{
    if (Left(featureName, 5) == "bone_")
    {
        return TRUE;
    }
    return FALSE;
}
public static function AMM_AppearanceRecord ApplyBoneDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local int foundIndex;
    local OffsetBoneDelta boneDelta;
    local MorphFeatureSaveRecord featureRecord;
    local MeshDelta accessoryDelta;
    
    foreach delta.OffsetBoneDeltas(boneDelta, )
    {
        if (boneDelta.Remove)
        {
            if (boneDelta.Name == '*')
            {
                for (foundIndex = record.MorphHead.MorphFeatures.Length - 1; foundIndex >= 0; foundIndex--)
                {
                    if (IsMorphFeatureABoneAdjust(string(record.MorphHead.MorphFeatures[foundIndex].Feature)))
                    {
                        record.MorphHead.MorphFeatures.Remove(foundIndex, 1);
                    }
                }
            }
            else
            {
                foundIndex = record.MorphHead.MorphFeatures.Find('Feature', Name("bone_" $ boneDelta.Name $ "_x"));
                if (foundIndex != -1)
                {
                    record.MorphHead.MorphFeatures.Remove(foundIndex, 1);
                }
                foundIndex = record.MorphHead.MorphFeatures.Find('Feature', Name("bone_" $ boneDelta.Name $ "_y"));
                if (foundIndex != -1)
                {
                    record.MorphHead.MorphFeatures.Remove(foundIndex, 1);
                }
                foundIndex = record.MorphHead.MorphFeatures.Find('Feature', Name("bone_" $ boneDelta.Name $ "_z"));
                if (foundIndex != -1)
                {
                    record.MorphHead.MorphFeatures.Remove(foundIndex, 1);
                }
            }
        }
        else
        {
            if (boneDelta.Offset.X != "")
            {
                foundIndex = record.MorphHead.MorphFeatures.Find('Feature', Name("bone_" $ boneDelta.Name $ "_x"));
                if (foundIndex != -1)
                {
                    record.MorphHead.MorphFeatures[foundIndex].Offset = ApplyFloatDelta(record.MorphHead.MorphFeatures[foundIndex].Offset, boneDelta.Offset.X, -100000000.0, 9999999.0);
                }
                else
                {
                    featureRecord.Offset = ApplyFloatDelta(0.0, boneDelta.Offset.X, -100000000.0, 9999999.0);
                    featureRecord.Feature = Name("bone_" $ boneDelta.Name $ "_x");
                    record.MorphHead.MorphFeatures.AddItem(featureRecord);
                }
            }
            if (boneDelta.Offset.Y != "")
            {
                foundIndex = record.MorphHead.MorphFeatures.Find('Feature', Name("bone_" $ boneDelta.Name $ "_y"));
                if (foundIndex != -1)
                {
                    record.MorphHead.MorphFeatures[foundIndex].Offset = ApplyFloatDelta(record.MorphHead.MorphFeatures[foundIndex].Offset, boneDelta.Offset.Y, -100000000.0, 9999999.0);
                }
                else
                {
                    featureRecord.Offset = ApplyFloatDelta(0.0, boneDelta.Offset.Y, -100000000.0, 9999999.0);
                    featureRecord.Feature = Name("bone_" $ boneDelta.Name $ "_y");
                    record.MorphHead.MorphFeatures.AddItem(featureRecord);
                }
            }
            if (boneDelta.Offset.Z != "")
            {
                foundIndex = record.MorphHead.MorphFeatures.Find('Feature', Name("bone_" $ boneDelta.Name $ "_z"));
                if (foundIndex != -1)
                {
                    record.MorphHead.MorphFeatures[foundIndex].Offset = ApplyFloatDelta(record.MorphHead.MorphFeatures[foundIndex].Offset, boneDelta.Offset.Z, -100000000.0, 9999999.0);
                }
                else
                {
                    featureRecord.Offset = ApplyFloatDelta(0.0, boneDelta.Offset.Z, -100000000.0, 9999999.0);
                    featureRecord.Feature = Name("bone_" $ boneDelta.Name $ "_z");
                    record.MorphHead.MorphFeatures.AddItem(featureRecord);
                }
            }
        }
    }
    return record;
}
public static function AMM_AppearanceRecord ApplyAccessoryDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local int foundIndex;
    local MeshDelta accessoryDelta;
    local int i;
    local Name accessory;
    local Name combatHair;
    local Name baseHead;
    
    foreach delta.AccessoryMeshDeltas(accessoryDelta, )
    {
        foundIndex = record.MorphHead.AccessoryMeshes.Find(accessoryDelta.Name);
        if (accessoryDelta.Remove)
        {
            if (accessoryDelta.Name == '*')
            {
                foreach record.MorphHead.AccessoryMeshes(accessory, i)
                {
                    if (Right(string(accessory), 11) == "|CombatHair")
                    {
                        combatHair = accessory;
                    }
                    if (Right(string(accessory), 9) == "|BaseHead")
                    {
                        baseHead = accessory;
                    }
                }
                record.MorphHead.AccessoryMeshes.Length = 0;
                if (combatHair != 'None')
                {
                    record.MorphHead.AccessoryMeshes.AddItem(combatHair);
                }
                if (baseHead != 'None')
                {
                    record.MorphHead.AccessoryMeshes.AddItem(baseHead);
                }
                for (i = record.MorphHead.ScalarParameters.Length - 1; i > 0; i--)
                {
                    if (InStr(string(record.MorphHead.ScalarParameters[i].Name), "AccessoryCombat|", , , ) != -1 || InStr(string(record.MorphHead.ScalarParameters[i].Name), "AccessoryCasual|", , , ) != -1 || InStr(string(record.MorphHead.ScalarParameters[i].Name), "AccessoryTint|", , , ) != -1)
                    {
                        record.MorphHead.ScalarParameters.Remove(i, 1);
                    }
                }
            }
            else
            {
                for (i = record.MorphHead.ScalarParameters.Length - 1; i > 0; i--)
                {
                    if (InStr(string(record.MorphHead.ScalarParameters[i].Name), string(accessoryDelta.Name), , TRUE, ) != -1)
                    {
                        record.MorphHead.ScalarParameters.Remove(i, 1);
                    }
                }
                if (foundIndex != -1)
                {
                    record.MorphHead.AccessoryMeshes.Remove(foundIndex, 1);
                }
            }
        }
        else if (foundIndex == -1)
        {
            record.MorphHead.AccessoryMeshes.AddItem(accessoryDelta.Name);
        }
    }
    return record;
}
public static function AMM_AppearanceRecord ApplyHeadMeshDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    local int currentHeadMeshIndex;
    local int i;
    local Name accessory;
    
    if (IsNonDefaultName(delta.HeadMesh.Name))
    {
        currentHeadMeshIndex = -1;
        foreach record.MorphHead.AccessoryMeshes(accessory, i)
        {
            if (Right(string(accessory), 9) == "|BaseHead")
            {
                currentHeadMeshIndex = i;
            }
        }
        if (delta.HeadMesh.Remove)
        {
            if (currentHeadMeshIndex != -1)
            {
                record.MorphHead.AccessoryMeshes.Remove(currentHeadMeshIndex, 1);
            }
        }
        else if (currentHeadMeshIndex != -1)
        {
            record.MorphHead.AccessoryMeshes[currentHeadMeshIndex] = Name(delta.HeadMesh.Name $ "|BaseHead");
        }
        else
        {
            record.MorphHead.AccessoryMeshes.AddItem(Name(delta.HeadMesh.Name $ "|BaseHead"));
        }
    }
    return record;
}
public static function AMM_AppearanceRecord ApplyBodymeshDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    return record;
}
public static function AMM_AppearanceRecord ApplyHelmetMeshDelta(AMM_AppearanceRecord record, AppearanceDelta delta)
{
    return record;
}
public static function AMM_AppearanceRecord ApplyAppearanceConfigDelta(AMM_AppearanceRecord record, AppearanceItemData data)
{
    // this will allow for things like changing the appearance type or helmet visibility that only affect view in the menu
    // switch (data.appearanceChange)
    // {
    //     case EAppearanceType.Appearance_Casual:
    //         record.bUseCasualAppearance = TRUE;
    //         break;
    //     case EAppearanceType.Appearance_Combat:
    //         record.bUseCasualAppearance = FALSE;
    //         break;
    //     case EAppearanceType.Appearance_Toggle:
    //         record.bUseCasualAppearance = !record.bUseCasualAppearance;
    //         break;
    //     default:
    // }
    return record;
}
public static final function float ApplyFloatDelta(float input, string delta, float defaultLower, float defaultUpper)
{
    local array<string> splitValue;
    local string lower;
    local string upper;
    local string Value;
    local string operator;
    local float LowerLimit;
    local float UpperLimit;
    
    splitValue = SplitString(delta $ "||", "|", FALSE);
    Value = splitValue[0];
    lower = splitValue[1];
    upper = splitValue[2];
    if (lower == "")
    {
        LowerLimit = defaultLower;
    }
    else
    {
        LowerLimit = float(lower);
    }
    if (upper == "")
    {
        UpperLimit = defaultUpper;
    }
    else
    {
        UpperLimit = float(upper);
    }
    if (Value == "")
    {
        return input;
    }
    if (Left(Value, 2) == "=-")
    {
        return FClamp(float(Repl(Value, "=", "", )), LowerLimit, UpperLimit);
    }
    if (Left(Value, 1) == "+")
    {
        return FClamp(input + float(Repl(Value, "+", "", )), LowerLimit, UpperLimit);
    }
    if (Left(Value, 1) == "-")
    {
        return FClamp(input - float(Repl(Value, "-", "", )), LowerLimit, UpperLimit);
    }
    if (Left(Value, 1) == "*")
    {
        return FClamp(input * float(Repl(Value, "*", "", )), LowerLimit, UpperLimit);
    }
    if (Left(Value, 1) == "/")
    {
        return FClamp(input / float(Repl(Value, "/", "", )), LowerLimit, UpperLimit);
    }
    return FClamp(float(Value), LowerLimit, UpperLimit);
}
public final function PushMenu(string submenu, string menuParam)
{
    local Class<AppearanceSubMenuBase> submenuClass;
    local AppearanceSubMenuBase submenuInstance;
    
    submenuClass = Class<AppearanceSubMenuBase>(FindObject(submenu, Class'Class'));
    if (submenuClass == None)
    {
        if (Class'SFXEngine'.static.IsSeekFreeObjectSupported(submenu))
        {
            submenuClass = Class<AppearanceSubMenuBase>(Class'SFXEngine'.static.LoadSeekFreeObject(submenu, Class'Class'));
        }
    }
    if (submenuClass != None)
    {
        submenuInstance = new (Self) submenuClass;
        submenuInstance.menuParam = menuParam;
        PushMenuInstance(submenuInstance);
    }
}
public final function PushMenuInstance(AppearanceSubMenuBase submenuInstance)
{
    submenuStack.AddItem(submenuInstance);
    Refresh();
}
public final function PopMenu()
{
    if (submenuStack.Length > 1)
    {
        submenuStack.Remove(submenuStack.Length - 1, 1);
        // Refresh(GetCurrentSubmenu().selectedSubmenuIndex);
        Refresh();
    }
    else
    {
        submenuStack.Length = 0;
        Exit();
    }
}
public final function AppearanceSubMenuBase GetCurrentSubmenu()
{
    return submenuStack[submenuStack.Length - 1];
}
public final function Refresh(optional int selectedIndex)
{
    Initialize(PopulateSubmenu());
    ShowChoiceGUI();
}
public function AppearanceSubMenuBase PopulateSubmenu()
{
    local AppearanceSubMenuBase currentSubMenu;
    local AppearanceItemData data;
    
    currentSubMenu = GetCurrentSubmenu();
    if (!currentSubMenu.SetupMenu())
    {
        currentSubMenu.ClearChoiceList();
        currentSubMenu.shownItems.Length = 0;
        foreach currentSubMenu.appearanceItems(data, )
        {
            if (!ShouldItemBeIncluded(data))
            {
                continue;
            }
            if (data.submenuClassName != "")
            {
                data.ChoiceEntry.srActionText = currentSubMenu.srOpenSubmenu;
            }
            if (data.ChoiceEntry.sChoiceName == "")
            {
                ClearCustomTokens();
                SetCustomToken(0, data.number);
                data.ChoiceEntry.sChoiceName = string(data.ChoiceEntry.srChoiceName);
            }
            currentSubMenu.shownItems.AddItem(data);
            currentSubMenu.AddChoice(data.ChoiceEntry);
        }
    }
    return currentSubMenu;
}
public final function Exit()
{
    local MassEffectGuiManager manager;
    local BioSFPanel personalizationPanel;
    
    UpdatePlayerAppearance();
    manager = MassEffectGuiManager(oPanel.oParentManager);
    manager.HideGuiByTag('AMM');
    if (__ExternalCallback_OnComplete__Delegate != None)
    {
        __ExternalCallback_OnComplete__Delegate();
    }
}
public final function UpdatePlayerAppearance()
{
    ApplyRecord(history[history.Length - 1], m_oPlayerPawn, TRUE);
}
public final function ChoiceGUIInputPressed(bool bAPressed, int nContext)
{
    if (bAPressed)
    {
        OnItemSelected(nContext);
    }
    else
    {
        PopMenu();
    }
}
public event function OnPanelAdded()
{
    SetMouseShown(!oPanel.bUsingGamepad);
    HandleButtonRefresh(oPanel.bUsingGamepad);
    Super(BioSFHandler).OnPanelAdded();
    oPanel.SetExternalInterface(Self);
    PlayGuiSound('ConsoleEnter');
    SetInputDelegate(ChoiceGUIInputPressed);
    PushMenu("SFXGameContent_AMM.SFXGuiData_AMM_Root", "");
}
public function onExIntDoInitialize()
{
    oPanel.SetVariableBool("_root.handleScrollEvents", TRUE);
    InitializeUIWorld();
}
public event function OnPanelRemoved()
{
    PlayGuiSound('ConsoleExit');
    CleanUpDelegateReferences();
    Super(BioSFHandler_ChoiceGUI).OnPanelRemoved();
    if (m_WorldInfo != None)
    {
        RestoreData();
        if (m_oPlayerPawn != None)
        {
            if (m_WorldInfo.m_UIWorld != None)
            {
                m_WorldInfo.m_UIWorld.DestroyPawn(m_oPlayerPawn);
            }
        }
        if (m_WorldInfo.m_UIWorld != None)
        {
            m_WorldInfo.m_UIWorld.ResetActors();
            m_WorldInfo.m_UIWorld.TriggerEvent('LightsOff', m_WorldInfo);
        }
    }
}
private final function InstantZoom(float delta)
{
    currentZoomLevel = FClamp(currentZoomLevel + delta, -1.0, 1.0);
    PositionView();
}
public function HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    local ASParams stParam;
    local array<ASParams> lstParams;
    local SFXGameModeManager manager;
    local MassEffectGuiManager GuiMan;
    local BioPlayerController PC;
    
    switch (Event)
    {
        case 47:
            rightClickHeld = TRUE;
            stParam.Type = 3;
            stParam.bVar = TRUE;
            lstParams.AddItem(stParam);
            oPanel.InvokeMethodArgs("DissableMouseEvents", lstParams);
            oPanel.SetVariableBool("_root.handleScrollEvents", FALSE);
            SetMouseShown(FALSE);
            break;
        case 49:
            rightClickHeld = FALSE;
            stParam.Type = 3;
            stParam.bVar = FALSE;
            lstParams.AddItem(stParam);
            oPanel.InvokeMethodArgs("DissableMouseEvents", lstParams);
            oPanel.SetVariableBool("_root.handleScrollEvents", TRUE);
            SetMouseShown(TRUE);
            m_nRotating = 0.0;
            moveUpDownSpeed = 0.0;
            break;
        case 6:
            if (rightClickHeld)
            {
                if (fValue < -0.0000999999975)
                {
                    m_nRotating = FClamp(fValue * mouseRotationMultiplier, -3.0, 3.0);
                }
                else if (fValue > 0.0000999999975)
                {
                    m_nRotating = FClamp(fValue * mouseRotationMultiplier, -3.0, 3.0);
                }
                else
                {
                    m_nRotating = 0.0;
                }
            }
            break;
        case 7:
            if (rightClickHeld)
            {
                if (fValue < -0.0000999999975)
                {
                    moveUpDownSpeed = FClamp(fValue * mouseUpDownMultiplier, -3.0, 3.0);
                }
                else if (fValue > 0.0000999999975)
                {
                    moveUpDownSpeed = FClamp(fValue * mouseUpDownMultiplier, -3.0, 3.0);
                }
                else
                {
                    moveUpDownSpeed = 0.0;
                }
            }
            break;
        case 5:
            // the game imposes a really big deadzone. This gets the raw value and the imposes a much more reasonable one.
            fValue = BioPlayerInput(m_WorldInfo.GetLocalPlayerController().PlayerInput).AxisBuffer[3];
            if (Abs(fValue) > controllerDeadzone)
            {
                moveUpDownSpeed = fValue;
            }
            else
            {
                moveUpDownSpeed = 0.0;
            }
            break;
        case 4:
            // the game imposes a really big deadzone. This gets the raw value and the imposes a much more reasonable one.
            fValue = BioPlayerInput(m_WorldInfo.GetLocalPlayerController().PlayerInput).AxisBuffer[2];
            if (Abs(fValue) > controllerDeadzone)
            {
                m_nRotating = -fValue;
            }
            else
            {
                m_nRotating = 0.0;
            }
            break;
        case 17:
            zoomSpeed += controllerZoomSpeed;
            break;
        case 16:
            zoomSpeed -= controllerZoomSpeed;
            break;
        case 38:
            zoomSpeed -= controllerZoomSpeed;
            break;
        case 37:
            zoomSpeed += controllerZoomSpeed;
            break;
        case 27:
            if (rightClickHeld)
            {
                InstantZoom(0.100000001);
            }
            return;
        case 28:
            if (rightClickHeld)
            {
                InstantZoom(-0.100000001);
            }
            return;
        default:
            break;
    }
    if (debugCamera)
    {
        switch (Event)
        {
            case 9:
                tempLeft = TRUE;
                return;
            case 10:
                tempRight = TRUE;
                return;
            case 30:
                tempLeft = FALSE;
                return;
            case 31:
                tempRight = FALSE;
                return;
            case 11:
                tempUp = TRUE;
                return;
            case 8:
                tempDown = TRUE;
                return;
            case 32:
                tempUp = FALSE;
                return;
            case 29:
                tempDown = FALSE;
                return;
            default:
        }
    }
    Super(BioSFHandler_ChoiceGUI).HandleInputEvent(Event, fValue);
}
public event function Update(float fDeltaT)
{
    local Rotator rotCurrentPreviewRotation;
    local int yawDelta;
    local Vector pawnPosition;
    local Vector CameraPosition;
    
    Super(BioSFHandler).Update(fDeltaT);
    if (m_oUIWorldPawn == None)
    {
        m_oUIWorldPawn = SFXPawn_Player(m_WorldInfo.m_UIWorld.GetSpawnedPawn(m_oPlayerPawn));
        if (m_oUIWorldPawn != None)
        {
            InitializeUIWorldPawn(m_oUIWorldPawn);
        }
    }
    if (m_nRotating != 0.0)
    {
        rotCurrentPreviewRotation = m_oUIWorldPawn.Rotation;
        yawDelta = int(m_nRotating * fDeltaT * 182.044449 * RotationDegreesPerSecond);
        currentPreviewYaw += yawDelta;
        rotCurrentPreviewRotation.Yaw = currentPreviewYaw;
        rotCurrentPreviewRotation = Normalize(rotCurrentPreviewRotation);
        currentPreviewYaw = rotCurrentPreviewRotation.Yaw;
        m_WorldInfo.m_UIWorld.RotatePawn(m_oPlayerPawn, rotCurrentPreviewRotation);
    }
    if (moveUpDownSpeed != 0.0)
    {
        CurrentHeightLevel = FClamp(CurrentHeightLevel + moveUpDownSpeed * fDeltaT * MoveUpDownSpeedMultiplier, 0.0, 1.0);
    }
    if (zoomSpeed != 0.0)
    {
        currentZoomLevel = FClamp(currentZoomLevel + zoomSpeed * fDeltaT, -1.0, 1.0);
    }
    if (moveUpDownSpeed != 0.0 || zoomSpeed != 0.0)
    {
        PositionView();
    }
    if (debugCamera)
    {
        if (tempLeft != tempRight)
        {
            CameraPosition = GetCameraPosition();
            CameraPosition.Y += (tempLeft ? 0.25 : -0.25);
            LogInternal("New camera Position" @ CameraPosition, );
            SetCameraPosition(CameraPosition);
            CommitCamera();
        }
        if (tempUp != tempDown)
        {
            CameraPosition = GetCameraPosition();
            CameraPosition.X += (tempDown ? 0.25 : -0.25);
            LogInternal("New camera Position" @ CameraPosition, );
            SetCameraPosition(CameraPosition);
            CommitCamera();
        }
    }
}
private final function InterpTrackMove GetCameraInterp()
{
    return InterpTrackMove(FindObject("BIOG_UIWORLD.TheWorld.PersistentLevel.Main_Sequence.InterpData_4.InterpGroup_0.InterpTrackMove_0", Class'InterpTrackMove'));
}
private final function SetCameraPosition(Vector Position)
{
    local InterpTrackMove cameraInterp;
    
    cameraInterp = GetCameraInterp();
    cameraInterp.PosTrack.Points[1].OutVal = Position;
}
private final function Vector GetCameraPosition()
{
    local InterpTrackMove cameraInterp;
    
    cameraInterp = GetCameraInterp();
    return cameraInterp.PosTrack.Points[1].OutVal;
}
private final function SetCameraRotation(Vector Rotation)
{
    local InterpTrackMove cameraInterp;
    
    cameraInterp = GetCameraInterp();
    cameraInterp.EulerTrack.Points[1].OutVal = Rotation;
}
private final function Vector GetCameraRotation()
{
    local InterpTrackMove cameraInterp;
    
    cameraInterp = GetCameraInterp();
    return cameraInterp.EulerTrack.Points[1].OutVal;
}
private final function CommitCamera()
{
    m_WorldInfo.m_UIWorld.TriggerEvent('SetupCharRec', m_WorldInfo);
}
public function ClearDelegates()
{
    __ExternalCallback_OnComplete__Delegate = None;
}
public function SetExternalCallback_OnComplete(delegate<ExternalCallback_OnComplete> pDelegate)
{
    __ExternalCallback_OnComplete__Delegate = pDelegate;
}
public delegate function ExternalCallback_OnComplete();

private final function PlayerStart GetPawnLocator()
{
    return PlayerStart(FindObject("BIOG_UIWORLD.TheWorld.PersistentLevel.PlayerStart_4", Class'PlayerStart'));
}
private final function SaveInitialData()
{
    OriginalPawnPosition = GetPawnLocator().Location;
    OriginalPawnRotation = GetPawnLocator().Rotation;
    OriginalCameraPosition = GetCameraPosition();
    OriginalCameraRotation = GetCameraRotation();
}
private final function SetInitialPawnPosition()
{
    local PlayerStart pawnLocator;
    
    pawnLocator = GetPawnLocator();
    pawnLocator.Location.X = AMMPawnPosition.X;
    pawnLocator.Location.Y = AMMPawnPosition.Y;
    pawnLocator.Location.Z = AMMPawnPosition.Z;
    pawnLocator.Rotation.Pitch = AMMPawnRotation.Pitch;
    pawnLocator.Rotation.Yaw = AMMPawnRotation.Yaw;
    pawnLocator.Rotation.Roll = AMMPawnRotation.Roll;
    currentPreviewYaw = AMMPawnRotation.Yaw;
}
private final function SetInitialCameraPosition()
{
    SetCameraRotation(AMMCameraRotation);
    if (FALSE)
    {
        SetCameraPosition(AMMCameraPosition);
    }
    CurrentHeightLevel = startingHeight;
    PositionView();
}
private final function RestoreData()
{
    local PlayerStart pawnLocator;
    
    pawnLocator = GetPawnLocator();
    pawnLocator.Location.X = OriginalPawnPosition.X;
    pawnLocator.Location.Y = OriginalPawnPosition.Y;
    pawnLocator.Location.Z = OriginalPawnPosition.Z;
    pawnLocator.Rotation.Pitch = OriginalPawnRotation.Pitch;
    pawnLocator.Rotation.Yaw = OriginalPawnRotation.Yaw;
    pawnLocator.Rotation.Roll = OriginalPawnRotation.Roll;
    SetCameraPosition(OriginalCameraPosition);
    SetCameraRotation(OriginalCameraRotation);
}
public function InitializeUIWorld()
{
    local BioPlayerController PC;
    
    SaveInitialData();
    if (oWorldInfo != None)
    {
        m_WorldInfo = BioWorldInfo(oWorldInfo);
        PC = m_WorldInfo.GetLocalPlayerController();
        if (PC != None)
        {
            m_oPlayerPawn = SFXPawn_Player(PC.Pawn);
        }
    }
    if (m_oPlayerPawn.MorphHead == None)
    {
        HandleDefaultShep();
    }
    if (m_WorldInfo.m_UIWorld.GetSpawnedPawn(m_oPlayerPawn) != None)
    {
        m_WorldInfo.m_UIWorld.DestroyPawn(m_oPlayerPawn);
    }
    SetInitialPawnPosition();
    SetInitialCameraPosition();
    CommitCamera();
    m_WorldInfo.m_UIWorld.SpawnPawn(m_oPlayerPawn, 'CharRecSpawnPoint', 'CharRecPawn');
    GetInitialAppearanceRecord();
}
public function InitializeUIWorldPawn(SFXPawn_Player UIWorldPawn)
{
    m_oUIWorldPawn = UIWorldPawn;
    m_oUIWorldPawn.bInPersonalization = TRUE;
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    bSetGameMode = TRUE
    RotationDegreesPerSecond = 180.0
    controllerDeadzone = 0.25
    mouseRotationMultiplier = -0.100000001
    mouseUpDownMultiplier = -0.100000001
    MoveUpDownSpeedMultiplier = 0.100000001
    startingHeight = 0.926599979
    AMMPawnPosition = {X = -1198.57983, Y = -3305.99219, Z = 29.3976135}
    AMMPawnRotation = {Pitch = 0, Yaw = 36441, Roll = 0}
    AMMCameraPosition = {X = -1367.43005, Y = -3326.61011, Z = 107.400002}
    AMMCameraRotation = {X = 0.0, Y = 0.0, Z = 0.0}
    ZoomCameraXInterp = {
                         Points = ({InVal = -1.0, OutVal = -519.25, ArriveTangent = 996.173584, LeaveTangent = 996.173584, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
                                   {InVal = 0.0, OutVal = 0.0, ArriveTangent = 234.378357, LeaveTangent = 234.378357, InterpMode = EInterpCurveMode.CIM_CurveAutoClamped}, 
                                   {InVal = 1.0, OutVal = 121.25, ArriveTangent = 86.1795731, LeaveTangent = 86.1795731, InterpMode = EInterpCurveMode.CIM_CurveUser}
                                  )
                        }
    ZoomXYRatio = 7.4000001
    MaxCameraZInterp = {
                        Points = ({InVal = -1.0, OutVal = 34.1199989, ArriveTangent = 181.014435, LeaveTangent = 181.014435, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
                                  {InVal = 0.0, OutVal = 108.879364, ArriveTangent = 12.5056505, LeaveTangent = 12.5056505, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
                                  {InVal = 0.400000006, OutVal = 112.893715, ArriveTangent = 6.36415577, LeaveTangent = 6.36415577, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
                                  {InVal = 0.699999988, OutVal = 115.014114, ArriveTangent = 6.02714539, LeaveTangent = 6.02714539, InterpMode = EInterpCurveMode.CIM_CurveAuto}, 
                                  {InVal = 1.0, OutVal = 116.510002, ArriveTangent = 2.98371816, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
                                 )
                       }
    MinCameraZInterp = {
                        Points = ({InVal = -1.0, OutVal = 34.1199989, ArriveTangent = -107.405861, LeaveTangent = -107.405861, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
                                  {InVal = -0.699999988, OutVal = -5.0, ArriveTangent = -107.405861, LeaveTangent = -107.405861, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
                                  {InVal = -0.400000006, OutVal = -25.0, ArriveTangent = -50.0571442, LeaveTangent = -50.0571442, InterpMode = EInterpCurveMode.CIM_CurveAuto}, 
                                  {InVal = 0.0, OutVal = -40.0400009, ArriveTangent = -25.6103859, LeaveTangent = -25.6103859, InterpMode = EInterpCurveMode.CIM_CurveAuto}, 
                                  {InVal = 0.600000024, OutVal = -50.6103859, ArriveTangent = -13.9699974, LeaveTangent = -13.9699974, InterpMode = EInterpCurveMode.CIM_CurveAuto}, 
                                  {InVal = 1.0, OutVal = -54.0099983, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
                                 )
                       }
    controllerZoomSpeed = 0.5
}