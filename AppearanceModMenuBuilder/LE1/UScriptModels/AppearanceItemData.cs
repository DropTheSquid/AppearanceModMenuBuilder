using MassEffectModBuilder.Models;
using static AppearanceModMenuBuilder.LE1.UScriptModels.AppearanceItemData;

namespace AppearanceModMenuBuilder.LE1.UScriptModels
{
    public class AppearanceItemData : StructCoalesceValue
    {
        public enum EGender
        {
            Either,
            Male,
            Female
        }

        public enum EMenuHelmetOverride
        {
            unchanged,
            Off,
            On,
            Full,
        }

        public class PlotIntSetting : StructCoalesceValue
        {
            public PlotIntSetting(int id, int value)
            {
                Id = id;
                Value = value;
            }

            public int Id
            {
                get => GetInt(nameof(Id))!.Value;
                set => SetInt(nameof(Id), value);
            }
            public int Value
            {
                get => GetInt(nameof(Value))!.Value;
                set => SetInt(nameof(Value), value);
            }
            
        }

        public int? SrCenterText
        {
            get => GetInt(nameof(SrCenterText));
            set => SetInt(nameof(SrCenterText), value);
        }

        public int? SrLeftText
        {
            get => GetInt(nameof(SrLeftText));
            set => SetInt(nameof(SrLeftText), value);
        }

        public int? SrRightText
        {
            get => GetInt(nameof(SrRightText));
            set => SetInt(nameof(SrRightText), value);
        }

        public string? SubMenuClassName
        {
            get => GetString(nameof(SubMenuClassName));
            set => SetString(nameof(SubMenuClassName), value);
        }

        public bool? InlineSubmenu
        {
            get => GetBool(nameof(InlineSubmenu));
            set => SetBool(nameof(InlineSubmenu), value);
        }

        public string[]? DisplayVars
        {
            get => GetStringArray(nameof(DisplayVars));
            set => SetStringArray(nameof(DisplayVars), value);
        }

        public int? ApplyOutfitId
        {
            get => GetInt(nameof(ApplyOutfitId));
            set => SetInt(nameof(ApplyOutfitId), value);
        }

        public int? ApplyHelmetId
        {
            get => GetInt(nameof(ApplyHelmetId));
            set => SetInt(nameof(ApplyHelmetId), value);
        }

        public int? ApplyBreatherId
        {
            get => GetInt(nameof(ApplyBreatherId));
            set => SetInt(nameof(ApplyBreatherId), value);
        }

        public EGender? Gender
        {
            get => GetEnum<EGender>(nameof(Gender));
            set => SetEnum(nameof(Gender), value);
        }

        public EMenuHelmetOverride? ApplyHelmetPreference
        {
            get => GetEnum<EMenuHelmetOverride>(nameof(ApplyHelmetPreference));
            set => SetEnum(nameof(ApplyHelmetPreference), value);
        }

        public bool? RequiresFramework
        {
            get => GetBool(nameof(RequiresFramework));
            set => SetBool(nameof(RequiresFramework), value);
        }

        public PlotIntSetting? DisplayInt
        {
            get => GetStruct<PlotIntSetting>(nameof(DisplayInt));
            set => SetStruct(nameof(DisplayInt), value);
        }


        public int? DisplayConditional
        {
            get => GetInt(nameof(DisplayConditional));
            set => SetInt(nameof(DisplayConditional), value);
        }

        public int? DisplayBool
        {
            get => GetInt(nameof(DisplayBool));
            set => SetInt(nameof(DisplayBool), value);
        }
    }
}
