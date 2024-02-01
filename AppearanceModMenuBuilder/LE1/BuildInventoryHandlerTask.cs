using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;

namespace AppearanceModMenuBuilder.LE1
{
    public class BuildInventoryHandlerTask : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            // need to make a new file, clone basegame class into it, and then compile the new handler class into it

            var inventoryHandlerPackge = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "Inventory_AMM.pcc"), context.Game);

            var basegameTask = new AddMergeClassesToFile("SFXGame.pcc", "AMM_AppearanceUpdater_Base", _ => inventoryHandlerPackge);
            basegameTask.RunModTask(context);

            var classTask = new AddClassesToFile(
                _ => inventoryHandlerPackge,
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\ModHandler_Inventory_AMM.uc"),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\CustomUIHandlerInterface.uc", ["Mod_GameContent"]));
            classTask.RunModTask(context);

            var portGuiTask = new PortAssetsIntoFile(_ => inventoryHandlerPackge, @"Resources\LE1\NonStartup\Mod_Gui_Inventory_AMM.pcc");
            portGuiTask.RunModTask(context);
        }
    }
}
