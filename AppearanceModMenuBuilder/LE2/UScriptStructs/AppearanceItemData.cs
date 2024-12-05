using MassEffectModBuilder.Models;

namespace AppearanceModMenuBuilder.LE2.UScriptStructs
{
    public class AppearanceItemData : StructCoalesceValue
    {
        public AppearanceItemData(string? comment = null) { Comment = comment; }
        public string? SubMenuClassName
        {
            get => GetString(nameof(SubMenuClassName));
            set => SetString(nameof(SubMenuClassName), value);
        }

        public AppearanceDelta? Delta
        {
            get => GetStruct<AppearanceDelta>(nameof(Delta));
            set => SetStruct(nameof(Delta), value);
        }

        public SFXChoiceEntry? ChoiceEntry
        {
            get => GetStruct<SFXChoiceEntry>(nameof(ChoiceEntry));
            set => SetStruct(nameof(ChoiceEntry), value);
        }

        /*
         * TODO implement these as I need them
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
         */
    }
}
