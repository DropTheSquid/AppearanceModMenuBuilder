using AppearanceModMenuBuilder.LE2.Models;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE2.DLCBuildSteps
{
    internal class BuildSubmenuFile : IModBuilderTask
    {
        private readonly List<ClassToCompile> classes = [];
        private readonly List<AMM_Submenu> submenus = [];

        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building submenus");

            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            var submenuPackageFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "AMM_Submenus.pcc"), context.Game);

            // make an object referencer
            submenuPackageFile.GetOrCreateObjectReferencer();

            classes.AddRange([
                GetClassFromFile(@"Resources\LE2\UScript\AppearanceModMenu\AppearanceSubMenuBase.uc", ["AppearanceModMenu"]),
                ]);

            var rootMenu = new AMM_Submenu("Root");

            classes.Add(rootMenu.GetClassToCompile());
            configMergeFile.AddOrMergeClassConfig(rootMenu);
            // TODO add more classes


            // add all the classes I have collected
            var classTask = new AddClassesToFile(
                _ => submenuPackageFile,
                classes);

            classTask.RunModTask(context);
        }
    }
}
