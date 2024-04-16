using MassEffectModBuilder.Models;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public class AppearanceItemData : StructCoalesceValue
    {
        /*
         *  ALL of the properties of this struct as of this writing
            var stringref srActionText;
            var string sActionText;
            var stringref srLeftText;
            var string sLeftText;
            var stringref srCenterText;
            var string sCenterText;
            var stringref srRightText;
            var string sRightText;
            var array<PlotIntSetting> ApplySettingInts;
            var array<int> ApplySettingBools;
            var int DisplayConditional;
            var int DisplayBool;
            var PlotIntSetting DisplayInt;
            var int EnableConditional;
            var int EnableBool;
            var PlotIntSetting EnableInt;
            var string SubMenuClassName;
            var Class<AppearanceSubmenu> SubmenuClass;
            var AppearanceSubmenu submenuInstance;
            var bool inlineSubmenu;
            var bool disabled;
            var bool hidden;
            var string comment;
            var array<string> displayVars;
            var array<string> displayRequiredPackageExports;
            var float sortPriority;
            var eGender gender;
            var array<string> aApplicableCharacters;
            var int applyOutfitId;
            var string pawnOverride;
            var array<string> aMenuParameters;
            var int applyHelmetId;
            var int applyBreatherId;
         */

        public enum EGender
        {
            Either,
            Male,
            Female
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
    }
}
