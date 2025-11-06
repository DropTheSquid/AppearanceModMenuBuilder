Class SFXSeqAct_SetPawnMesh extends SequenceAction;

enum EBioPawnComponent
{
    BioPawnComponent_Mesh,
    BioPawnComponent_Head,
    BioPawnComponent_Hair,
    BioPawnComponent_Headgear,
    BioPawnComponent_Visor,
    BioPawnComponent_FacePlate,
    BioPawnComponent_Accessory,
};

var(SFXSeqAct_SetPawnMesh) EBioPawnComponent m_eBioPawnComponent;
var(SFXSeqAct_SetPawnMesh) SkeletalMesh m_oMesh;
var(SFXSeqAct_SetPawnMesh) array<MaterialInterface> m_aoMaterials;
var(SFXSeqAct_SetPawnMesh) int m_nAccessory;
var(SFXSeqAct_SetPawnMesh) bool m_bPreserveAnimation;

public function Activated()
{
    local Object ChkObject;
    local BioPawn Pawn;
    
    foreach Targets(ChkObject, )
    {
        Pawn = BioPawn(ChkObject);
        if (Pawn != None)
        {
            switch (m_eBioPawnComponent)
            {
                case EBioPawnComponent.BioPawnComponent_Mesh:
                    SetComponentMesh(Pawn, Pawn.Mesh, m_oMesh, m_aoMaterials);
                    UpdateBoneMap(Pawn);
                    class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(Pawn, "SFXSeqAct_SetPawnMesh body");
                    break;
                case EBioPawnComponent.BioPawnComponent_Head:
                    SetComponentMesh(Pawn, Pawn.m_oHeadMesh, m_oMesh, m_aoMaterials);
                    break;
                case EBioPawnComponent.BioPawnComponent_Hair:
                    SetComponentMesh(Pawn, Pawn.m_oHairMesh, m_oMesh, m_aoMaterials);
                    break;
                case EBioPawnComponent.BioPawnComponent_Headgear:
                    SetComponentMesh(Pawn, Pawn.m_oHeadGearMesh, m_oMesh, m_aoMaterials);
                    class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(Pawn, "SFXSeqAct_SetPawnMesh headgear");
                    break;
                case EBioPawnComponent.BioPawnComponent_Visor:
                    SetComponentMesh(Pawn, Pawn.m_oVisorMesh, m_oMesh, m_aoMaterials);
                    class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(Pawn, "SFXSeqAct_SetPawnMesh visor");
                    break;
                case EBioPawnComponent.BioPawnComponent_FacePlate:
                    SetComponentMesh(Pawn, Pawn.m_oFacePlateMesh, m_oMesh, m_aoMaterials);
                    class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(Pawn, "SFXSeqAct_SetPawnMesh breather");
                    break;
                case EBioPawnComponent.BioPawnComponent_Accessory:
                    SetComponentMesh(Pawn, Pawn.m_aoAccessories[m_nAccessory], m_oMesh, m_aoMaterials);
                    break;
                default:
            }
        }
    }
}
public function SetComponentMesh(BioPawn InPawn, SkeletalMeshComponent InComponent, SkeletalMesh InMesh, array<MaterialInterface> InMaterials)
{
    local MaterialInstanceConstant MIC;
    local int idx;
    
    LogInternal("SetComponentMesh" @ InPawn.Tag @ InComponent @ InMesh @ InMaterials.Length, );
    for (idx = 0; idx < InComponent.GetNumElements(); ++idx)
    {
        InComponent.SetMaterial(idx, None);
    }
    InComponent.SetSkeletalMesh(InMesh, m_bPreserveAnimation);
    if (InComponent.SkeletalMesh != None)
    {
        for (idx = 0; idx < InComponent.SkeletalMesh.Materials.Length; ++idx)
        {
            MIC = new (InComponent) Class'MaterialInstanceConstant';
            MIC.SetParent(InComponent.SkeletalMesh.Materials[idx]);
            LogInternal("setting parent to" @ InComponent.SkeletalMesh.Materials[idx], );
            if (InMaterials[idx] != None)
            {
                MIC.SetParent(InMaterials[idx]);
                LogInternal("setting parent to" @ InMaterials[idx], );
            }
            ApplyBasicOverrides(InPawn, MIC);
            InComponent.SetMaterial(idx, MIC);
        }
    }
}
public function ApplyBasicOverrides(BioPawn InPawn, MaterialInstanceConstant InMaterial)
{
    local BioMorphFace Morph;
    local ColorParameter Param;
    
    Morph = InPawn.m_oBehavior.m_oAppearanceType.m_oMorphFace;
    if (Morph == None)
    {
        Morph = BioPawnChallengeScaledType(InPawn.m_oBehavior.m_oActorType).m_oMorphFace;
    }
    if (Morph == None || Morph.m_oMaterialOverrides == None)
    {
        return;
    }
    foreach Morph.m_oMaterialOverrides.m_aColorOverrides(Param, )
    {
        if (Param.nName == 'SkinTone' || Param.nName == 'HED_Hair_Colour_Vector')
        {
            InMaterial.SetVectorParameterValue(Param.nName, Param.cValue);
        }
    }
}
public function UpdateBoneMap(BioPawn InPawn)
{
    local SkeletalMeshComponent MeshCmpt;
    
    foreach InPawn.ComponentList(Class'SkeletalMeshComponent', MeshCmpt)
    {
        if (MeshCmpt != None && MeshCmpt != InPawn.Mesh)
        {
            MeshCmpt.UpdateParentBoneMap();
        }
    }
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    bCallHandler = FALSE
    VariableLinks = ({
                      LinkedVariables = (), 
                      LinkDesc = "Pawn", 
                      ExpectedType = Class'SeqVar_Object', 
                      LinkVar = 'None', 
                      PropertyName = 'Targets', 
                      CachedProperty = None, 
                      MinVars = 1, 
                      MaxVars = 255, 
                      bWriteable = FALSE, 
                      bModifiesLinkedObject = FALSE, 
                      bAllowAnyType = FALSE
                     }, 
                     {
                      LinkedVariables = (), 
                      LinkDesc = "Mesh", 
                      ExpectedType = Class'SeqVar_Object', 
                      LinkVar = 'None', 
                      PropertyName = 'm_oMesh', 
                      CachedProperty = None, 
                      MinVars = 1, 
                      MaxVars = 1, 
                      bWriteable = FALSE, 
                      bModifiesLinkedObject = FALSE, 
                      bAllowAnyType = FALSE
                     }
                    )
}