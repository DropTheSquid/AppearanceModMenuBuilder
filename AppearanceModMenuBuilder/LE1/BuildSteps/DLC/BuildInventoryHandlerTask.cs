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
            // make a new file to house the new Inventory handler and GUI
            var inventoryHandlerPackge = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "Inventory_AMM.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            inventoryHandlerPackge.GetOrCreateObjectReferencer();

            // port the GUI into the file
            var portGuiTask = new PortAssetsIntoFile(_ => inventoryHandlerPackge, @"Resources\LE1\NonStartup\Mod_Gui_Inventory_AMM.pcc");
            portGuiTask.RunModTask(context);

            // put the basegame added class in; the code I compile below depends on it
            var basegameTask = new AddMergeClassesToFile("SFXGame.pcc", "AMM_AppearanceUpdater_Base", _ => inventoryHandlerPackge);
            basegameTask.RunModTask(context);

            // add a few classes
            var classTask = new AddClassesToFile(
                _ => inventoryHandlerPackge,
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\NonStartup\ModHandler_Inventory_AMM.uc"),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\CustomUIHandlerInterface.uc", ["Mod_GameContent"]));
            classTask.RunModTask(context);
        }
    }
}
