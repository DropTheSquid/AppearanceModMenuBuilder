using LegendaryExplorerCore.Packages;
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

        public string[] GenerateRootMenuEntry()
        {
            string displayConditionalString = DisplayConditional != null ? $", DisplayConditional={DisplayConditional}" : "";
            string displayBoolString = DisplayBool != null ? $", DisplayBool={DisplayBool}" : "";
            return
            [
                //$"; submenus for {SquadMemberName}",
                $"+menuItems=(srCenterText={SquadMemberNameStringref}{displayBoolString}{displayConditionalString}, SubMenuClassName=\"AMM_Submenus.{SquadMemberName}.AppearanceSubmenu_{SquadMemberName}\")"
            ];
        }

        public IEnumerable<string> GenerateSubmenuEntries()
        {
            List<string> lines = [];

            // add the root menu for this pawn
            lines.AddRange([
                $"[BioUI.ini AMM_Submenus.{SquadMemberName}.AppearanceSubmenu_{SquadMemberName}]",
                $"pawnOverride={PawnTag}",
                "appearanceType=casual",
                "menuAppearanceType=casual",
                $"srTitle={SquadMemberNameStringref}",
                // "Choose an outfit type"
                "srSubtitle=210210213",
                // casual outfits
                $"+menuItems=(srCenterText=210210214, SubMenuClassName=\"AMM_Submenus.{SquadMemberName}.AppearanceSubmenu_{SquadMemberName}_Casual\")",
                // combat outfits
                $"+menuItems=(srCenterText=210210215, SubMenuClassName=\"AMM_Submenus.{SquadMemberName}.AppearanceSubmenu_{SquadMemberName}_Combat\")",
                ]);
            if (Romanceable)
            {
                // romance appearance
                lines.Add($"+menuItems=(srCenterText=210210216, SubMenuClassName=\"AMM_Submenus.{SquadMemberName}.AppearanceSubmenu_{SquadMemberName}_Romance\")");
            }

            // TODO add entries for submenus to make them do literally anything
            return lines;
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
            //// remove the forced export flag on this package. We need it to be dynamic loadable, including this package name, so it needs to not be forced export
            handlerPackageExport.ExportFlags &= ~EExportFlags.ForcedExport;
        }

        private static ClassToCompile GetSubmenuClass(string className, string[] path)
        {
            var fullClassName = $"{AppearanceSubmenuClassPrefix}{className}";
            return new ClassToCompile(fullClassName, string.Format(SubmenuClassTemplate, fullClassName), path);
        }
    }
}
