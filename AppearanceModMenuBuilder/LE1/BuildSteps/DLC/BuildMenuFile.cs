using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using static LegendaryExplorerCore.Unreal.UnrealFlags;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class BuildMenuFile : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building AMM.pcc");
            // make a new file to house the new AMM handler and GUI
            // Either this needs to live in a file called AMM or it needs to be under a package called that in startup for compatibility with Remove Window Reflections that already launches it
            var ammPackageFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "AMM.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            ammPackageFile.GetOrCreateObjectReferencer();

            // port the GUI into the file
            var portGuiTask = new PortAssetsIntoFile(_ => ammPackageFile, @"Resources\LE1\NonStartup\GUI_MOD_AMM.pcc");
            portGuiTask.RunModTask(context);

            var handlerPackageExport = ExportCreator.CreatePackageExport(ammPackageFile, "Handler");
            // remove the forced export flag on this package. We need it to be dynamic loadable, including this package name, so it needs to not be forced export
            handlerPackageExport.ExportFlags &= ~EExportFlags.ForcedExport;

            // add a few classes
            var classTask = new AddClassesToFile(
                _ => ammPackageFile,
                // the handler inheritance tree
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\CustomUIHandlerInterface.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\Handler\ModMenuBase.uc", ["Handler"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\Handler\ModHandler_AMM.uc", ["Handler"]),
                // needed by the AMM handler
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\Handler\AMM_Handler_Helper.uc", ["Handler"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\Handler\AMM_Pawn_Handler.uc", ["Handler"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\Handler\AMM_Camera_Handler.uc", ["Handler"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\Handler\AMM_DialogBox_Handler.uc", ["Handler"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AppearanceSubmenu.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Pawn_Parameters.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\Pawn_Parameter_Handler.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\OutfitSpecBase.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\SimpleOutfitSpec.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\OutfitSpecListBase.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Utilities.uc", ["Mod_GameContent"]));
            classTask.RunModTask(context);
        }
    }
}
