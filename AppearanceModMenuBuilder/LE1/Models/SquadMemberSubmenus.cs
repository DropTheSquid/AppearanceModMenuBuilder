using AppearanceModMenuBuilder.LE1.UScriptModels;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder.Models;
using static AppearanceModMenuBuilder.LE1.BuildSteps.DLC.BuildSubmenuFile;
using static LegendaryExplorerCore.Unreal.UnrealFlags;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public record class SquadMemberSubmenus(string SquadMemberName, int SquadMemberNameStringref, string PawnTag, SpeciesOutfitMenus OutfitSubmenus)
    {
        private const string SubmenuClassTemplate = "Class {0} extends AppearanceSubmenu config(UI);";
        public const string AppearanceSubmenuClassPrefix = "AppearanceSubmenu_";

        public int? DisplayBool { get; init; } = null;
        public int? DisplayConditional { get; init; } = null;
        public bool Romanceable { get; init; } = false;

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

            var rootCharacterMenu = new AppearanceSubmenu(ClassPath)
            {
                PawnTag = PawnTag,
                PawnAppearanceType = "casual",
                ArmorOverride = "overridden",
                SrTitle = SquadMemberNameStringref,
                // "Choose an outfit type"
                SrSubtitle = 210210213
            };
            _submenus.Add(rootCharacterMenu);
            _classes.Add(GetSubmenuClass(SquadMemberName, [SquadMemberName]));

            var casualMenu = new AppearanceSubmenu($"{ClassPath}_Casual")
            {
                PawnTag = PawnTag,
                PawnAppearanceType = "casual",
                ArmorOverride = "overridden",
                // TODO make it so menus can easily inherit this from the outer menu
                SrTitle = SquadMemberNameStringref,
                SrSubtitle = srCausalAppearance
            };
            // add this menu into the root character menu
            rootCharacterMenu.AddMenuEntry(casualMenu.GetEntryPoint(srCausalAppearance));
            // add the appropriate submenu into this one
            casualMenu.AddMenuEntry(OutfitSubmenus.Casual.GetInlineEntryPoint());
            _submenus.Add(casualMenu);
            _classes.Add(GetSubmenuClass($"{SquadMemberName}_Casual", [SquadMemberName]));

            var combatMenu = new AppearanceSubmenu($"{ClassPath}_Combat")
            {
                PawnTag = PawnTag,
                PawnAppearanceType = "combat",
                ArmorOverride = "equipped",
                // TODO make it so menus can easily inherit this from the outer menu
                SrTitle = SquadMemberNameStringref,
                SrSubtitle = srCombatAppearance
            };
            // add this menu into the root character menu
            rootCharacterMenu.AddMenuEntry(combatMenu.GetEntryPoint(srCombatAppearance));
            // add the appropriate submenu into this one
            combatMenu.AddMenuEntry(OutfitSubmenus.Combat.GetInlineEntryPoint());
            _submenus.Add(combatMenu);
            _classes.Add(GetSubmenuClass($"{SquadMemberName}_Combat", [SquadMemberName]));

            if (Romanceable)
            {
                const int srRomanceAppearance = 210210216;

                var romanceMenu = new AppearanceSubmenu($"{ClassPath}_Romance")
                {
                    PawnTag = PawnTag,
                    PawnAppearanceType = "romance",
                    ArmorOverride = "overridden",
                    // TODO make it so menus can easily inherit this from the outer menu
                    SrTitle = SquadMemberNameStringref,
                    SrSubtitle = srRomanceAppearance
                };
                // add this menu into the root character menu
                rootCharacterMenu.AddMenuEntry(romanceMenu.GetEntryPoint(srRomanceAppearance, requiresFramework: true));
                // add the appropriate submenu into this one
                romanceMenu.AddMenuEntry(OutfitSubmenus.Casual.GetInlineEntryPoint());
                _submenus.Add(romanceMenu);
                _classes.Add(GetSubmenuClass($"{SquadMemberName}_Romance", [SquadMemberName]));
            }
            initCompleted = true;
        }

        public AppearanceItemData GetMenuEntryPoint()
        {
            if (!initCompleted)
            {
                Init();
            }
            var rootMenu = Submenus.First();
            var entryPoint = rootMenu.GetEntryPoint(SquadMemberNameStringref);
            // TODO convert these to strongly typed
            if (DisplayConditional != null)
            {
                entryPoint[nameof(DisplayConditional)] = new IntCoalesceValue(DisplayConditional.Value);
            }
            if (DisplayBool != null)
            {
                entryPoint[nameof(DisplayBool)] = new IntCoalesceValue(DisplayBool.Value);
            }

            return entryPoint;
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
