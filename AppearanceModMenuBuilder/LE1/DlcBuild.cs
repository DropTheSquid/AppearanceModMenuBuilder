using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.UtilityTasks;

namespace AppearanceModMenuBuilder.LE1
{
    internal static class DlcBuild
    {
        public static ModBuilder AddDlcTasks(this ModBuilder builder)
        {
            return builder
                // clean the DLC directory
                .AddTask(new CleanDlcDirectory())
                // copy the moddesc
                .AddTask(new CopyFiles(@"Resources\LE1", context => context.ModOutputPathBase))
                // copy the autoload
                .AddTask(new CopyFiles(@"Resources\LE1\dlc", context => context.DLCBaseFolder))
                // copy anything else that goes in the cookedPCConsole, such as config merges
                .AddTask(new CopyFiles(@"Resources\LE1\cookedPCConsole", context => context.CookedPCConsoleFolder))
                // make sure the startup file has a correct object referencer
                .AddTask(new InitializeStartup())
                // make sure the merge class is added to the startup file so that the game will not insta crash if the basegame changes are reverted
                .AddTask(new AddMergeClassesToStartup("SFXGame.pcc", "AMM_AppearanceUpdater_Base"))
                // compile some classes into the startup file
                .AddTask(new AddClassesToFile(
                    context => context.GetStartupFile(),
                    LooseClassCompile.GetClassesFromDirectories(@"Resources\LE1\Startup", @"Resources\LE1\Shared")))
                // add an instance of the handler class at a hardercoded location, add it to the object referencer
                .AddTask(new CustomTask(context =>
                {
                    var startup = context.GetStartupFile();
                    var newExport = ExportCreator.CreateExport(startup, "AMM_AppearanceUpdater", "AMM_AppearanceUpdater", indexed: true);
                    startup.GetObjectReferencer()!.AddToObjectReferencer(newExport);
                    startup.Save();
                }))
                // add a new file with shared classes in it
                .AddTask(new CustomTask(context =>
                {
                    var dlcFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "test.pcc"), context.Game);
                    dlcFile.AddObjectReferencer();
                    var compileTask = new AddClassesToFile(_ => dlcFile, LooseClassCompile.GetClassesFromDirectories(@"Resources\LE1\Shared"));
                    compileTask.RunModTask(context);
                }))
                // compile tlks
                .AddTask(new ImportGame1TlkLocaliazation(MELocalization.INT, @"Resources\LE1\tlk\GlobalTlk_tlk.xml"))
                .AddTask(new OutputTlk());
        }
    }
}
