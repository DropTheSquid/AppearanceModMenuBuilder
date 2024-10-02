using AppearanceModMenuBuilder.LE1.UScriptModels;
using LegendaryExplorerCore.Packages;
using static AppearanceModMenuBuilder.LE1.BuildSteps.DLC.BuildSubmenuFile;
using static LegendaryExplorerCore.Unreal.UnrealFlags;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public record class SquadMemberSubmenus(string SquadMemberName, int SquadMemberNameStringref, string PawnTag, SpeciesOutfitMenus OutfitSubmenus, AppearanceSubmenu CharacterSelect)
    {
        private const string SubmenuClassTemplate = "Class {0} extends AppearanceSubmenu config(UI);";
        public const string AppearanceSubmenuClassPrefix = "AppearanceSubmenu_";

        public int? DisplayBool { get; init; } = null;
        public int? DisplayConditional { get; init; } = null;
        public int? RomanceConditional { get; init; } = null;
        public int? RecruitedBool { get; init; } = null;
        // Liara gets a bit of special handling, in that her pre recruitment look is casual unless a setting is turned on to put her in armor
        public bool LiaraSpecialHandling { get; init; } = false;

        // Tali get a bit of special handling in that there is a setting to take her down to only a single appearance type (combat)
        public bool TaliSpecialHandling { get; init; } = false;

        public string ClassPath => $"AMM_Submenus.{SquadMemberName}.AppearanceSubmenu_{SquadMemberName}";

        private bool initCompleted;
        private readonly List<AppearanceSubmenu> _submenus = [];
        private readonly List<ClassToCompile> _classes = [];

        public IEnumerable<AppearanceSubmenu> Submenus
        {
            get
            {
                if (!initCompleted)
                {
                    Init();
                }
                return _submenus;
            }
        }

        public IEnumerable<ClassToCompile> Classes
        {
            get
            {
                if (!initCompleted)
                {
                    Init();
                }
                return _classes;
            }
        }

        private void Init()
        {
            if (initCompleted) return;
            const int srCausalAppearance = 210210214;
            const int srCombatAppearance = 210210215;
            const int srCausalOrPreRecruitAppearance = 210210280;
            const int srCombatOrPreRecruitAppearance = 210210281;

            var rootCharacterMenu = new AppearanceSubmenu(ClassPath)
            {
                PawnTag = PawnTag,
                PawnAppearanceType = "casual",
                ArmorOverride = "overridden",
                SrTitleWithComment = (SquadMemberNameStringref, "the squadmember's name"),
                SrSubtitleWithComment = (210210213, "Choose an outfit type"),
                // we want the character name to carry through to child menus
                UseTitleForChildMenus = true,
                Comment = "Do not add items directly to this menu; add them to the species specific outfit menus instead"
            };
            _submenus.Add(rootCharacterMenu);
            _classes.Add(GetSubmenuClass(SquadMemberName, [SquadMemberName]));

            var casualMenu = new AppearanceSubmenu($"{ClassPath}_Casual")
            {
                PawnTag = PawnTag,
                PawnAppearanceType = "casual",
                ArmorOverride = "overridden",
                SrTitleWithComment = (210210253, "Character name, newline, Casual"),
                UseTitleForChildMenus = true,
                SrSubtitleWithComment = (210210256, "Choose an outfit"),
                Comment = "Do not add items directly to this menu; add them to the species specific outfit menus instead"
            };

            // add the appropriate submenu into this one
            casualMenu.AddMenuEntry(OutfitSubmenus.Casual.GetInlineEntryPoint());
            _submenus.Add(casualMenu);
            _classes.Add(GetSubmenuClass($"{SquadMemberName}_Casual", [SquadMemberName]));

            var combatMenu = new AppearanceSubmenu($"{ClassPath}_Combat")
            {
                PawnTag = PawnTag,
                PawnAppearanceType = "combat",
                ArmorOverride = "equipped",
                SrTitleWithComment = (210210254, "Character name, newline, Combat"),
                UseTitleForChildMenus = true,
                SrSubtitleWithComment = (210210256, "Choose an outfit"),
                Comment = "Do not add items directly to this menu; add them to the species specific outfit menus instead"
            };

            if (LiaraSpecialHandling)
            {
                // Liara is complicated. this first menu entry point is "Pre Recruitment/Casual"
                // and it shows up as long as Liara has not been recruited and the setting to put Liara in Armor is not on
                rootCharacterMenu.AddMenuEntry(casualMenu.GetEntryPoint(srCausalOrPreRecruitAppearance, displayBool: -3943, displayInt: (-1599, 1)));
                // the one that just says "Casual" appears with the inverse of that logic, which is in a conditional
                rootCharacterMenu.AddMenuEntry(casualMenu.GetEntryPoint(srCausalAppearance, displayConditional: 2510));

                // next menu entry point is "Pre Recruitment/Combat"
                // and it shows up as long as Liara has not been recruited and the setting to put Liara in Armor is on
                rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatOrPreRecruitAppearance, displayBool: -3943, displayInt: (1599, 1)));
                // the one that just says "Combat" appears with the inverse of that logic, which is in a conditional
                rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatAppearance, displayConditional: 2511));

                // Add Liara into the character select menu
                var entryPoint = rootCharacterMenu.GetEntryPoint(SquadMemberNameStringref);
                entryPoint.DisplayConditional = DisplayConditional;
                entryPoint.DisplayBool = DisplayBool;
                CharacterSelect.AddMenuEntry(entryPoint);
            }
            else if (TaliSpecialHandling)
            {
                // Tali get the normal casual and combat or combat/pre recruitment, but all are hidden if int 1600 is 1, which is the setting for Tali having a single appearance type
                rootCharacterMenu.AddMenuEntry(casualMenu.GetEntryPoint(srCausalAppearance, displayInt: (-1600, 1)));
                // one of these two will show up based on whether Tali has been recruited yet
                rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatOrPreRecruitAppearance, displayBool: -3944, displayInt: (-1600, 1)));
                rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatAppearance, displayBool: 3944, displayInt: (-1600, 1)));

                // add a single appearance type menu in addition to combat and casual
                var singleAppearanceMenu = new AppearanceSubmenu($"{ClassPath}_Combined")
                {
                    PawnTag = PawnTag,
                    PawnAppearanceType = "combat",
                    ArmorOverride = "equipped",
                    SrTitleWithComment = (SquadMemberNameStringref, "the squadmember's name"),
                    UseTitleForChildMenus = true,
                    SrSubtitleWithComment = (210210256, "Choose an outfit"),
                    Comment = "Do not add items directly to this menu; add them to the species specific outfit menus instead"
                };

                singleAppearanceMenu.AddMenuEntry(OutfitSubmenus.Combat.GetInlineEntryPoint());
                _submenus.Add(singleAppearanceMenu);
                _classes.Add(GetSubmenuClass($"{SquadMemberName}_Combined", [SquadMemberName]));

                // add Tali into the character select menu, with one of two entry points showing up based on the single appearance setting
                var regularEntryPoint = rootCharacterMenu.GetEntryPoint(SquadMemberNameStringref);
                regularEntryPoint.DisplayConditional = DisplayConditional;
                regularEntryPoint.DisplayBool = DisplayBool;
                regularEntryPoint.DisplayInt = new(-1600, 1);
                regularEntryPoint.Comment = "Entry point to Tali's 'Choose Casual or Combat Appearance' menu if the setting to use a single appearance type for her is off";

                var singleAppearanceEntryPoint = singleAppearanceMenu.GetEntryPoint(SquadMemberNameStringref);
                singleAppearanceEntryPoint.DisplayConditional = DisplayConditional;
                singleAppearanceEntryPoint.DisplayBool = DisplayBool;
                singleAppearanceEntryPoint.DisplayInt = new(1600, 1);
                singleAppearanceEntryPoint.Comment = "Entry point to Tali's 'Choose an outfit' menu if the setting to use a single appearance type for her is on";

                CharacterSelect.AddMenuEntry(regularEntryPoint);
                CharacterSelect.AddMenuEntry(singleAppearanceEntryPoint);
            }
            else
            {
                // add this menu into the root character menu
                rootCharacterMenu.AddMenuEntry(casualMenu.GetEntryPoint(srCausalAppearance));
                if (RecruitedBool.HasValue)
                {
                    // add two entry points, one that shows up pre recruitment, one that shows up post
                    rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatOrPreRecruitAppearance, displayBool: -RecruitedBool.Value));
                    rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatAppearance, displayBool: RecruitedBool.Value));
                }
                else
                {
                    // add this menu into the root character menu
                    rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatAppearance));
                }

                // add this character into the character select menu
                var entryPoint = rootCharacterMenu.GetEntryPoint(SquadMemberNameStringref);
                entryPoint.DisplayConditional = DisplayConditional;
                entryPoint.DisplayBool = DisplayBool;
                CharacterSelect.AddMenuEntry(entryPoint);
            }

            // add the appropriate submenu into this one
            combatMenu.AddMenuEntry(OutfitSubmenus.Combat.GetInlineEntryPoint());
            _submenus.Add(combatMenu);
            _classes.Add(GetSubmenuClass($"{SquadMemberName}_Combat", [SquadMemberName]));

            if (RomanceConditional.HasValue)
            {
                const int srRomanceAppearance = 210210216;

                var romanceMenu = new AppearanceSubmenu($"{ClassPath}_Romance")
                {
                    PawnTag = PawnTag,
                    PawnAppearanceType = "romance",
                    ArmorOverride = "overridden",
                    SrTitleWithComment = (210210255, "Character name, newline, Romance"),
                    UseTitleForChildMenus = true,
                    SrSubtitleWithComment = (210210256, "Choose an outfit"),
                    Comment = "Do not add items directly to this menu; add them to the species specific outfit menus instead"
                };
                // add this menu into the root character menu
                rootCharacterMenu.AddMenuEntry(romanceMenu.GetEntryPoint(srRomanceAppearance, requiresFramework: true, displayConditional: RomanceConditional.Value));
                // add the appropriate submenu into this one
                romanceMenu.AddMenuEntry(OutfitSubmenus.Casual.GetInlineEntryPoint());
                _submenus.Add(romanceMenu);
                _classes.Add(GetSubmenuClass($"{SquadMemberName}_Romance", [SquadMemberName]));
            }
            initCompleted = true;
        }

        public void ModifyPackage(IMEPackage package)
        {
            var packageExp = ExportCreator.CreatePackageExport(package, SquadMemberName);
            // remove the forced export flag on this package. We need it to be dynamic loadable, including this package name, so it needs to not be forced export
            packageExp.ExportFlags &= ~EExportFlags.ForcedExport;
        }

        public static ClassToCompile GetSubmenuClass(string className, string[] path)
        {
            var fullClassName = $"{AppearanceSubmenuClassPrefix}{className}";
            return new ClassToCompile(fullClassName, string.Format(SubmenuClassTemplate, fullClassName), path);
        }
    }
}
