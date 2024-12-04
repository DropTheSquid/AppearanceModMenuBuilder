class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base;

public function bool LoadMorphHead(out PlayerSaveRecord ThePlayerRecord, out BioMorphFace MorphHead)
{
    local MorphHeadSaveRecord Record;
    local string PackageName;
    local int Idx;
    local MorphFeature Feature;
    local OffsetBonePos Offset;
    local ScalarParameter ScalarParam;
    local ColorParameter ColorParam;
    local TextureParameter TextureParam;
    local array<int> BuffersToRefresh;

    LogInternal("DLC LoadMorphHead is running");
    
    if (ThePlayerRecord.Appearance.bHasMorphHead)
    {
        Record = ThePlayerRecord.Appearance.MorphHead;
        PackageName = Left(ThePlayerRecord.bIsFemale ? "BIOG_MORPH_FACE.Player_Base_Female" : "BIOG_MORPH_FACE.Player_Base_Male", InStr(ThePlayerRecord.bIsFemale ? "BIOG_MORPH_FACE.Player_Base_Female" : "BIOG_MORPH_FACE.Player_Base_Male", ".", FALSE, , ));
        Class'SFXGame'.static.LoadPackage(PackageName);
        MorphHead = BioMorphFace(FindObject(ThePlayerRecord.bIsFemale ? "BIOG_MORPH_FACE.Player_Base_Female" : "BIOG_MORPH_FACE.Player_Base_Male", Class'BioMorphFace'));
        if (MorphHead != None)
        {
            if (PathName(MorphHead.m_oHairMesh) != string(Record.HairMesh))
            {
                MorphHead.m_oHairMesh = SkeletalMesh(DynamicLoadObject(string(Record.HairMesh), Class'SkeletalMesh'));
            }
            if (MorphHead.m_oOtherMeshes.Length != Record.AccessoryMeshes.Length)
            {
                MorphHead.m_oOtherMeshes.Length = Record.AccessoryMeshes.Length;
                for (Idx = 0; Idx < Record.AccessoryMeshes.Length; Idx++)
                {
                    MorphHead.m_oOtherMeshes[Idx] = SkeletalMesh(DynamicLoadObject(string(Record.AccessoryMeshes[Idx]), Class'SkeletalMesh'));
                }
            }
            MorphHead.m_aMorphFeatures.Length = Record.MorphFeatures.Length;
            for (Idx = 0; Idx < Record.MorphFeatures.Length; Idx++)
            {
                Feature.sFeatureName = Record.MorphFeatures[Idx].Feature;
                Feature.Offset = Record.MorphFeatures[Idx].Offset;
                MorphHead.m_aMorphFeatures[Idx] = Feature;
            }
            MorphHead.m_aFinalSkeleton.Length = Record.OffsetBones.Length;
            for (Idx = 0; Idx < Record.OffsetBones.Length; Idx++)
            {
                Offset.nName = Record.OffsetBones[Idx].Name;
                Offset.vPos = Record.OffsetBones[Idx].Offset;
                MorphHead.m_aFinalSkeleton[Idx] = Offset;
            }
            for (Idx = 0; Idx < Record.LOD0Vertices.Length; Idx++)
            {
                MorphHead.SetPosition(0, Idx, Record.LOD0Vertices[Idx]);
            }
            BuffersToRefresh.AddItem(0);
            MorphHead.RefreshBuffers(BuffersToRefresh);
            MorphHead.m_oMaterialOverrides.m_aScalarOverrides.Length = Record.ScalarParameters.Length;
            for (Idx = 0; Idx < Record.ScalarParameters.Length; Idx++)
            {
                ScalarParam.nName = Record.ScalarParameters[Idx].Name;
                ScalarParam.sValue = Record.ScalarParameters[Idx].Value;
                MorphHead.m_oMaterialOverrides.m_aScalarOverrides[Idx] = ScalarParam;
            }
            MorphHead.m_oMaterialOverrides.m_aColorOverrides.Length = Record.VectorParameters.Length;
            for (Idx = 0; Idx < Record.VectorParameters.Length; Idx++)
            {
                ColorParam.nName = Record.VectorParameters[Idx].Name;
                ColorParam.cValue = Record.VectorParameters[Idx].Value;
                MorphHead.m_oMaterialOverrides.m_aColorOverrides[Idx] = ColorParam;
            }
            MorphHead.m_oMaterialOverrides.m_aTextureOverrides.Length = Record.TextureParameters.Length;
            for (Idx = 0; Idx < Record.TextureParameters.Length; Idx++)
            {
                TextureParam.nName = Record.TextureParameters[Idx].Name;
                TextureParam.m_pTexture = Texture2D(DynamicLoadObject(string(Record.TextureParameters[Idx].Texture), Class'Texture2D'));
                MorphHead.m_oMaterialOverrides.m_aTextureOverrides[Idx] = TextureParam;
            }
        }
    }
    return true;
}

public function bool SaveMorphHead(BioMorphFace Morph, out MorphHeadSaveRecord Record, out bool result)
{
    local int Idx;
    local BioMaterialOverride MatOverride;
    
    LogInternal("DLC SaveMorphHead is running");

    if (Morph != None)
    {
        Record.HairMesh = Name(PathName(Morph.m_oHairMesh));
        Record.AccessoryMeshes.Length = Morph.m_oOtherMeshes.Length;
        for (Idx = 0; Idx < Morph.m_oOtherMeshes.Length; Idx++)
        {
            Record.AccessoryMeshes[Idx] = Name(PathName(Morph.m_oOtherMeshes[Idx]));
        }
        Record.MorphFeatures.Length = Morph.m_aMorphFeatures.Length;
        for (Idx = 0; Idx < Morph.m_aMorphFeatures.Length; Idx++)
        {
            Record.MorphFeatures[Idx].Feature = Morph.m_aMorphFeatures[Idx].sFeatureName;
            Record.MorphFeatures[Idx].Offset = Morph.m_aMorphFeatures[Idx].Offset;
        }
        Record.OffsetBones.Length = Morph.m_aFinalSkeleton.Length;
        for (Idx = 0; Idx < Morph.m_aFinalSkeleton.Length; Idx++)
        {
            Record.OffsetBones[Idx].Name = Morph.m_aFinalSkeleton[Idx].nName;
            Record.OffsetBones[Idx].Offset = Morph.m_aFinalSkeleton[Idx].vPos;
        }
        Record.LOD0Vertices.Length = Morph.GetNumVerts(0);
        for (Idx = 0; Idx < Morph.GetNumVerts(0); Idx++)
        {
            Record.LOD0Vertices[Idx] = Morph.GetPosition(0, Idx);
        }
        MatOverride = Morph.m_oMaterialOverrides;
        if (MatOverride != None)
        {
            Record.ScalarParameters.Length = MatOverride.m_aScalarOverrides.Length;
            for (Idx = 0; Idx < MatOverride.m_aScalarOverrides.Length; Idx++)
            {
                Record.ScalarParameters[Idx].Name = MatOverride.m_aScalarOverrides[Idx].nName;
                Record.ScalarParameters[Idx].Value = MatOverride.m_aScalarOverrides[Idx].sValue;
            }
            Record.VectorParameters.Length = MatOverride.m_aColorOverrides.Length;
            for (Idx = 0; Idx < MatOverride.m_aColorOverrides.Length; Idx++)
            {
                Record.VectorParameters[Idx].Name = MatOverride.m_aColorOverrides[Idx].nName;
                Record.VectorParameters[Idx].Value = MatOverride.m_aColorOverrides[Idx].cValue;
            }
            Record.TextureParameters.Length = MatOverride.m_aTextureOverrides.Length;
            for (Idx = 0; Idx < MatOverride.m_aTextureOverrides.Length; Idx++)
            {
                Record.TextureParameters[Idx].Name = MatOverride.m_aTextureOverrides[Idx].nName;
                Record.TextureParameters[Idx].Texture = Name(PathName(MatOverride.m_aTextureOverrides[Idx].m_pTexture));
            }
        }
        result = TRUE;
    }
    result = False;
    return true;
}

public function bool UpdatePlayerAppearance(SFXPawn_Player target, bool part2, out bool callSuper)
{
    LogInternal("DLC UpdatePlayerAppearance is running");
    if (!part2)
    {
        target.ValidateAppearanceIDs();
        target.UpdateHairAppearance();
        target.UpdateBodyAppearance();
        callSuper = true;
    }
    else
    {
        target.UpdateParameters();
        target.UpdateWeaponVisibility();
        target.ForceUpdateComponents(TRUE, FALSE);
        target.UpdateGameEffects();
        target.BlockForTextureStreaming();
        target.SetPlayerLOD();
    }
    return true;
}