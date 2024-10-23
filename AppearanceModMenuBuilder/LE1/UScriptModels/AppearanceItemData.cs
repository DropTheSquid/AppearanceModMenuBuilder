using MassEffectModBuilder.Models;

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
            onOrFull,
            offOrOn,
            offOrFull
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

        public string? SCenterText
        {
            get => GetString(nameof(SCenterText));
            set => SetString(nameof(SCenterText), value);
        }

        public int? SrLeftText
        {
            get => GetInt(nameof(SrLeftText));
            set => SetInt(nameof(SrLeftText), value);
        }

        public string? SLeftText
        {
            get => GetString(nameof(SLeftText));
            set => SetString(nameof(SLeftText), value);
        }

        public int? SrRightText
        {
            get => GetInt(nameof(SrRightText));
            set => SetInt(nameof(SrRightText), value);
        }

        public string? SRightText
        {
            get => GetString(nameof(SRightText));
            set => SetString(nameof(SRightText), value);
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

        public bool? HideIfHeadgearSuppressed
        {
            get => GetBool(nameof(HideIfHeadgearSuppressed));
            set => SetBool(nameof(HideIfHeadgearSuppressed), value);
        }

        public bool? HideIfBreatherSuppressed
        {
            get => GetBool(nameof(HideIfBreatherSuppressed));
            set => SetBool(nameof(HideIfBreatherSuppressed), value);
        }

        public bool? HideIfHatsSuppressed
        {
            get => GetBool(nameof(HideIfHatsSuppressed));
            set => SetBool(nameof(HideIfHatsSuppressed), value);
        }

        public bool? DisableIfHelmetLocked
        {
            get => GetBool(nameof(DisableIfHelmetLocked));
            set => SetBool(nameof(DisableIfHelmetLocked), value);
        }

        public bool? DisableIfBreatherLocked
        {
            get => GetBool(nameof(DisableIfBreatherLocked));
            set => SetBool(nameof(DisableIfBreatherLocked), value);
        }

        public string[]? AApplicableCharacters
        {
            get => GetStringArray(nameof(AApplicableCharacters));
            set => SetStringArray(nameof(AApplicableCharacters), value);
        }

        public string[]? AApplicableAppearanceTypes
        {
            get => GetStringArray(nameof(AApplicableAppearanceTypes));
            set => SetStringArray(nameof(AApplicableAppearanceTypes), value);
        }

        public string[]? ANotApplicableCharacters
        {
            get => GetStringArray(nameof(ANotApplicableCharacters));
            set => SetStringArray(nameof(ANotApplicableCharacters), value);
        }

        public string[]? ANotApplicableAppearanceTypes
        {
            get => GetStringArray(nameof(ANotApplicableAppearanceTypes));
            set => SetStringArray(nameof(ANotApplicableAppearanceTypes), value);
        }
    }
}
