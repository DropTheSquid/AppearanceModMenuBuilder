using AppearanceModMenuBuilder.LE2.UScriptClasses;
using AppearanceModMenuBuilder.LE2.UScriptStructs;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.Models;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE2.DLCBuildSteps
{
    internal class BuildSubmenuFile : IModBuilderTask
    {
        private readonly List<ClassToCompile> classes = [];
        private readonly List<AppearanceSubMenuBase> submenus = [];

        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building submenus");

            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            var engineConfig = configMergeFile.GetOrCreateClass("SFXGame.SFXEngine", "BioEngine.ini");

            var submenuPackageFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "AMM_Submenus.pcc"), context.Game);

            // make an object referencer
            submenuPackageFile.GetOrCreateObjectReferencer();

            classes.AddRange([
                GetClassFromFile(@"Resources\LE2\UScript\AppearanceModMenu\AppearanceSubMenuBase.uc", ["AppearanceModMenu"]),
                ]);

            var rootMenu = new AppearanceSubMenuBase("Root");
            rootMenu.SrTitleWithComment = (1865982, @"""Customize Appearance""");
            rootMenu.Comment = "testing class comment output";
            rootMenu.AddMenuEntry(new AppearanceItemData("Testing array entry comment ouput")
            {
                SubMenuClassName = "SFXGameContent_AMM.SFXGuiData_AMM_Settings",
                ChoiceEntry = new()
                {
                    // "Settings"
                    SrChoiceName = 1865986
                }
            });


            // make sure the class gets compiled and added to the file
            classes.Add(rootMenu.GetClassToCompile());
            // make sure we output the config
            configMergeFile.AddOrMergeClassConfig(rootMenu);
            // make sure this class gets added to the dynamic load mapping
            AddDynamicLoadMapping(engineConfig, rootMenu.ClassFullPath, "AMM_Submenus");

            // TODO add more classes


            // compile all the classes I have collected
            var classTask = new AddClassesToFile(
                _ => submenuPackageFile,
                classes);

            classTask.RunModTask(context);
        }

        private static void AddDynamicLoadMapping(ModConfigClass config, string objectName, string packageName)
        {
            var val = new StructCoalesceValue();
            val.SetString("ObjectName", objectName);
            val.SetString("SeekFreePackageName", packageName);
            config.AddArrayEntries("DynamicLoadMapping", val);
        }
    }
}
