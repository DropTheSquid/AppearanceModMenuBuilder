using AppearanceModMenuBuilder.LE1.UScriptModels;
using MassEffectModBuilder.Models;

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

        /*
            var config stringref srTitle;
            var config string sTitle;
            var config stringref srSubtitle;
            var config string sSubtitle;
            var config stringref defaultActionText;
            var config array<AppearanceItemData> menuItems;
            var transient int selectedIndex;
            var transient int scrollIndex;
            var transient array<string> inlineStack;
            var config eArmorOverrideState armorOverride;
            var transient array<string> MenuParameters;
            var config string pawnTag;
            var config string pawnAppearanceType;
            // var config eMenuHelmetOverride menuHelmetOverride;
            var config bool preloadPawn;
         */

        public void AddMenuEntry(AppearanceItemData item)
        {
            AddArrayEntries("menuItems", item.OutputValue());
        }

        public AppearanceItemData GetEntryPoint(int srCenterText, bool requiresFramework = false)
        {
            return new AppearanceItemData()
            {
                SrCenterText = srCenterText,
                SubMenuClassName = ClassFullPath,
                RequiresFramework = requiresFramework ? true : null
            };
        }

        public AppearanceItemData GetInlineEntryPoint()
        {
            return new AppearanceItemData()
            {
                InlineSubmenu = true,
                SubMenuClassName = ClassFullPath
            };
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

        public int? SrTitle
        {
            get => GetIntValue(nameof(SrTitle));
            set => SetIntValue(nameof(SrTitle), value);
        }

        public int? SrSubtitle
        {
            get => GetIntValue(nameof(SrSubtitle));
            set => SetIntValue(nameof(SrSubtitle), value);
        }
    }
}
