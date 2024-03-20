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

        public int? SrCenterText
        {
            get => ((IntCoalesceValue)this[nameof(SrCenterText)])?.Value;
            set {
                if (value.HasValue)
                {
                    this[nameof(SrCenterText)] = new IntCoalesceValue(value.Value);
                }
                else
                {
                    Remove(nameof(SrCenterText));
                }
            }
        }

        public string? SubMenuClassName
        {
            get => ((StringCoalesceValue)this[nameof(SubMenuClassName)])?.Value;
            set {
                if (string.IsNullOrWhiteSpace(value))
                {
                    Remove(nameof(SubMenuClassName));
                }
                else
                {
                    this[nameof(SubMenuClassName)] = new StringCoalesceValue(value);
                }
            }
        }
    }
}
