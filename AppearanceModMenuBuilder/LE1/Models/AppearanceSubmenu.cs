using MassEffectModBuilder.Models;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public class AppearanceSubmenu : ModConfigClass
    {
        // TODO should this be private to allow a "get if already exists" static accessor?
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

        public AppearanceItemData GetEntryPoint(int srCenterText)
        {
            return new AppearanceItemData()
            {
                SrCenterText = srCenterText,
                SubMenuClassName = ClassFullPath
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
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    Remove(nameof(PawnTag));
                }
                else
                {
                    SetValue(nameof(PawnTag), value);
                }
            }
        }

        public string? PawnAppearanceType
        {
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    Remove(nameof(PawnAppearanceType));
                }
                else
                {
                    SetValue(nameof(PawnAppearanceType), value);
                }
            }
        }

        public string? ArmorOverride
        {
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    Remove(nameof(ArmorOverride));
                }
                else
                {
                    SetValue(nameof(ArmorOverride), value);
                }
            }
        }

        public int? SrTitle
        {
            set
            {
                if (!value.HasValue)
                {
                    Remove(nameof(SrTitle));
                }
                else
                {
                    SetValue(nameof(SrTitle), value.Value);
                }
            }
        }

        public int? SrSubtitle
        {
            set
            {
                if (!value.HasValue)
                {
                    Remove(nameof(SrSubtitle));
                }
                else
                {
                    SetValue(nameof(SrSubtitle), value.Value);
                }
            }
        }
    }
}
