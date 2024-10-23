using AppearanceModMenuBuilder.LE1.UScriptModels;
using MassEffectModBuilder.Models;
using static AppearanceModMenuBuilder.LE1.UScriptModels.AppearanceItemData;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public class AppearanceSubmenu : ModConfigClass
    {
        public AppearanceSubmenu(string classFullPath) : base(classFullPath, "BioUI.ini") {}

        public static AppearanceSubmenu GetOrAddSubmenu(string classFullPath, ModConfigMergeFile configFile)
        {
            var existing = configFile.GetClass(classFullPath);
            if (existing is not null and AppearanceSubmenu)
            {
                return (AppearanceSubmenu)existing;
            }
            var newConfig = new AppearanceSubmenu(classFullPath);
            configFile.AddOrMergeClassConfig(newConfig);
            return newConfig;
        }

        public void AddMenuEntry(AppearanceItemData item)
        {
            AddArrayEntries("menuItems", item);
        }

        public AppearanceItemData GetEntryPoint(
            int srCenterText,
            bool requiresFramework = false,
            bool inline = false,
            (int id, int value)? displayInt = null,
            int? displayBool = null,
            int? displayConditional = null,
            bool? hideIfHeadgearSuppressed = null,
            bool? hideIfBreatherSuppressed = null,
            bool? hideIfHatsSuppressed = null,
            string[]? displayVars = null)
        {
            var result =  new AppearanceItemData()
            {
                InlineSubmenu = inline ? true : null,
                SrCenterText = srCenterText == 0 ? null : srCenterText,
                SubMenuClassName = ClassFullPath,
                RequiresFramework = requiresFramework ? true : null,
                HideIfHeadgearSuppressed = hideIfHeadgearSuppressed,
                HideIfBreatherSuppressed = hideIfBreatherSuppressed,
                HideIfHatsSuppressed = hideIfHatsSuppressed,
                DisplayBool = displayBool,
                DisplayConditional = displayConditional,
                DisplayVars = displayVars
            };
            if (displayInt.HasValue)
            {
                result.DisplayInt = new AppearanceItemData.PlotIntSetting(displayInt.Value.id, displayInt.Value.value);
            }
            return result;
        }

        public AppearanceItemData GetInlineEntryPoint(bool requiresFramework = false, (int id, int value)? displayInt = null)
        {
            return GetEntryPoint(0, requiresFramework, true, displayInt);
        }

        public string? PawnTag
        {
            get => GetStringValue(nameof(PawnTag));
            set => SetStringValue(nameof(PawnTag), value);
        }

        public string? PawnAppearanceType
        {
            get => GetStringValue(nameof(PawnAppearanceType));
            set => SetStringValue(nameof(PawnAppearanceType), value);
        }

        public string? ArmorOverride
        {
            get => GetStringValue(nameof(ArmorOverride));
            set => SetStringValue(nameof(ArmorOverride), value);
        }

        public (int stringref, string comment) SrTitleWithComment
        {
            set => SetIntValue(nameof(SrTitle), value.stringref, value.comment);
        }

        public int? SrTitle
        {
            get => GetIntValue(nameof(SrTitle));
            set => SetIntValue(nameof(SrTitle), value);
        }

        public string? STitle
        {
            get => GetStringValue(nameof(STitle));
            set => SetStringValue(nameof(STitle), value);
        }

        public (int stringref, string comment) SrSubtitleWithComment
        {
            set => SetIntValue(nameof(SrSubtitle), value.stringref, value.comment);
        }

        public int? SrSubtitle
        {
            get => GetIntValue(nameof(SrSubtitle));
            set => SetIntValue(nameof(SrSubtitle), value);
        }

        public bool? UseTitleForChildMenus
        {
            get => GetBoolValue(nameof(UseTitleForChildMenus));
            set => SetBoolValue(nameof(UseTitleForChildMenus), value);
        }

        public bool? UseSubtitleForChildMenus
        {
            get => GetBoolValue(nameof(UseSubtitleForChildMenus));
            set => SetBoolValue(nameof(UseSubtitleForChildMenus), value);
        }

        public EMenuHelmetOverride? MenuHelmetOverride
        {
            get => GetEnumValue<EMenuHelmetOverride>(nameof(MenuHelmetOverride));
            set => SetEnumValue(nameof(MenuHelmetOverride), value);
        }

        public bool? PreloadPawn
        {
            get => GetBoolValue(nameof(PreloadPawn));
            set => SetBoolValue(nameof(PreloadPawn), value);
        }

        public bool? DoNotCheckAppliedInSubmenu
        {
            get => GetBoolValue(nameof(DoNotCheckAppliedInSubmenu));
            set => SetBoolValue(nameof(DoNotCheckAppliedInSubmenu), value);
        }

        public string? CameraPosition
        {
            get => GetStringValue(nameof(CameraPosition));
            set => SetStringValue(nameof(CameraPosition), value);
        }
    }
}
