public final function bool SaveMorphHead(BioMorphFace Morph, out MorphHeadSaveRecord Record)
{
    local int Idx;
    local BioMaterialOverride MatOverride;
    local bool result;

    // if AMM is installed, do its handling instead
    if (class'AMM_AppearanceUpdater_Base'.static.SaveMorphHeadStatic(Morph, Record, result))
    {
        return result;
    }
    
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
        return TRUE;
    }
    return FALSE;
}