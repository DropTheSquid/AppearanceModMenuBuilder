using LegendaryExplorerCore.Coalesced;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder.Models;
using static LegendaryExplorerCore.Unreal.UnrealFlags;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public record class SquadMemberSubmenus(string SquadMemberName, int SquadMemberNameStringref, string PawnTag)
    {
        private const string SubmenuClassTemplate = "Class {0} extends AppearanceSubmenu config(UI);";
        private const string AppearanceSubmenuClassPrefix = "AppearanceSubmenu_";

        public int? DisplayBool { get; init; } = null;
        public int? DisplayConditional { get; init; } = null;
        public bool Romanceable { get; init; } = false;

        public string ClassPath => $"AMM_Submenus.{SquadMemberName}.AppearanceSubmenu_{SquadMemberName}";

        public CoalesceProperty GetMenuEntryPoint()
        {
            string displayConditionalString = DisplayConditional != null ? $", DisplayConditional={DisplayConditional}" : "";
            string displayBoolString = DisplayBool != null ? $", DisplayBool={DisplayBool}" : "";
            string value = $"(srCenterText={SquadMemberNameStringref}{displayBoolString}{displayConditionalString}, SubMenuClassName=\"{ClassPath}\")";
            return new CoalesceProperty("menuItems", new CoalesceValue(value, CoalesceParseAction.AddUnique));
        }

        public IEnumerable<ModConfigClass> GenerateConfigs()
        {
            List<ModConfigClass> configs = [];
            var rootCharacterMenu = new ModConfigClass(ClassPath, "BioUI.ini");
            rootCharacterMenu.SetValue("pawnTag", PawnTag);
            rootCharacterMenu.SetValue("pawnAppearanceType", "casual");
            rootCharacterMenu.SetValue("armorOverride", "overridden");
            rootCharacterMenu.SetValue("srTitle", SquadMemberNameStringref);
            // "Choose an outfit type"
            rootCharacterMenu.SetValue("srSubtitle", "210210213");

            configs.Add(rootCharacterMenu);

            var casualMenu = new ModConfigClass($"{ClassPath}_Casual", "BioUI.ini");
            // TODO make it so menus can easily inherit this from the outer menu
            casualMenu.SetValue("srTitle", SquadMemberNameStringref);
            // "Casual Appearance"
            casualMenu.SetValue("srSubtitle", "210210214");

            rootCharacterMenu.AddArrayEntries("menuItems", $"(srCenterText=210210214, SubMenuClassName=\"{ClassPath}_Casual\")");
            configs.Add(casualMenu);

            var combatMenu = new ModConfigClass($"{ClassPath}_Combat", "BioUI.ini");
            combatMenu.SetValue("pawnAppearanceType", "combat");
            combatMenu.SetValue("armorOverride", "equipped");
            // TODO make it so menus can easily inherit this from the outer menu
            combatMenu.SetValue("srTitle", SquadMemberNameStringref);
            // "Combat Appearance"
            combatMenu.SetValue("srSubtitle", "210210215");
            rootCharacterMenu.AddArrayEntries("menuItems", $"(srCenterText=210210215, SubMenuClassName=\"{ClassPath}_Combat\")");

            configs.Add(combatMenu);

            if (Romanceable)
            {
                var romanceMenu = new ModConfigClass($"{ClassPath}_Romance", "BioUI.ini");
                // TODO make it so menus can easily inherit this from the outer menu
                romanceMenu.SetValue("srTitle", SquadMemberNameStringref);
                // "Romance Appearance"
                romanceMenu.SetValue("srSubtitle", "210210216");
                rootCharacterMenu.AddArrayEntries("menuItems", $"(srCenterText=210210216, SubMenuClassName=\"{ClassPath}_Romance\")");

                configs.Add(romanceMenu);
            }

            return configs;
        }

        public IEnumerable<ClassToCompile> GenerateClassesToCompile()
        {
            List<ClassToCompile> classes = [];

            classes.Add(GetSubmenuClass(SquadMemberName, [SquadMemberName]));
            classes.Add(GetSubmenuClass($"{SquadMemberName}_Casual", [SquadMemberName]));
            classes.Add(GetSubmenuClass($"{SquadMemberName}_Combat", [SquadMemberName]));
            if (Romanceable)
            {
                classes.Add(GetSubmenuClass($"{SquadMemberName}_Romance", [SquadMemberName]));
            }
            return classes;
        }

        public void ModifyPackage(IMEPackage package)
        {
            var handlerPackageExport = ExportCreator.CreatePackageExport(package, SquadMemberName);
            // remove the forced export flag on this package. We need it to be dynamic loadable, including this package name, so it needs to not be forced export
            handlerPackageExport.ExportFlags &= ~EExportFlags.ForcedExport;
        }

        private static ClassToCompile GetSubmenuClass(string className, string[] path)
        {
            var fullClassName = $"{AppearanceSubmenuClassPrefix}{className}";
            return new ClassToCompile(fullClassName, string.Format(SubmenuClassTemplate, fullClassName), path);
        }
    }
}
