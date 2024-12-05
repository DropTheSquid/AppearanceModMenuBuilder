Class AppearanceSubMenuBase extends SFXGameChoiceGUIData
    abstract
    config(UI);

struct AppearanceItemData 
{
    struct PlotIntSetting 
    {
        var int PlotIntValue;
        var int PlotIntId;
    };
    struct MaterialSpecificOverride 
    {
        var string mesh;
        var string materialIndex;
    };
    var string submenuClassName;
    var SFXChoiceEntry ChoiceEntry;
    var AppearanceDelta delta;
    var EGender Gender;
    var int DisplayConditional;
    var int DisplayPlotBool;
    var string number;
    var string ApplicableHeadMeshes;
    var string ApplicableHairMeshes;
    var string ApplicableAccessoryMeshes;
    var array<string> requiredMeshes;
    var EAppearanceType appearanceChange;
    var EAppearanceType requiredappearanceType;
    var string RequiredMorphTargets;
    var EHelmetAppearance helmetAppearanceChange;
    var array<PlotIntSetting> ApplySettingInts;
    var array<int> ApplySettingBools;
    var string ApplicableMaterials;
    var string tag;
    var bool RemoveHeadMorph;
    var string menuParam;
    
    structdefaultproperties
    {
        ChoiceEntry = {eResource = None}
    }
};
struct AppearanceDelta 
{
    struct TextureParameterDelta 
    {
        var Name Name;
        var Name Texture;
        var bool Remove;
    };
    struct ColorDelta 
    {
        var string R;
        var string G;
        var string B;
        var string A;
    };
    struct VectorParameterDelta 
    {
        var ColorDelta Value;
        var Name Name;
        var bool Remove;
    };
    struct ScalarParameterDelta 
    {
        var Name Name;
        var string Value;
        var bool Remove;
    };
    struct vectorDelta 
    {
        var string X;
        var string Y;
        var string Z;
    };
    struct OffsetBoneDelta 
    {
        var vectorDelta Offset;
        var Name Name;
        var bool Remove;
    };
    struct MorphFeatureDelta 
    {
        var Name Feature;
        var string Offset;
        var bool Remove;
    };
    struct MeshDelta 
    {
        var Name Name;
        var bool Remove;
    };
    var array<MeshDelta> AccessoryMeshDeltas;
    var array<OffsetBoneDelta> OffsetBoneDeltas;
    var array<MorphFeatureDelta> MorphFeatureDeltas;
    var array<ScalarParameterDelta> ScalarParameterDeltas;
    var array<VectorParameterDelta> VectorParameterDeltas;
    var array<TextureParameterDelta> TextureParameterDeltas;
    var MeshDelta HairMesh;
    var MeshDelta HeadMesh;
    // var MeshDelta CombatHairMesh;
    // var MeshDelta BodyMesh;
    var MeshDelta HelmetMesh;
    var MeshDelta BreatherHelmetMesh;
    var bool ClearAll;
};
enum EGender
{
    Gender_Either,
    Gender_Female,
    Gender_Male,
};
enum EAppearanceType
{
    Appearance_Unchanged,
    Appearance_Casual,
    Appearance_Combat,
    Appearance_Toggle,
};
enum EHelmetAppearance
{
    HelmetAppearance_Unchanged,
    HelmetAppearance_On,
    HelmetAppearance_On_Full,
    HelmetAppearance_Off,
};

var config array<AppearanceItemData> appearanceItems;
var transient array<AppearanceItemData> shownItems;
var config stringref srOpenSubmenu;
var string menuParam;

var config string m_sTitle;
var config string m_sSubTitle;
var config string m_sAText;
var config string m_sBText;

public function bool SetupMenu()
{
    return FALSE;
}
public function bool OnItemSelected(int itemIndex)
{
    return FALSE;
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    srOpenSubmenu = $308548
    m_srAText = $247370
    m_srBText = $318455
}