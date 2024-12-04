using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
namespace AppearanceModMenuBuilder.LE2.DLCBuildSteps
{
    internal class BuildStartupFile : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building startup file");
            // make sure the startup file has a proper object referencer
            new InitializeStartup().RunModTask(context);
            // make sure the merge class is added to the startup file so that the game will not insta crash if the basegame changes are reverted
            new AddMergeClassesToStartup("SFXGame.pcc", "AMM_AppearanceUpdater_Base").RunModTask(context);
            // compile some classes into the startup file
            new AddClassesToFile(
                context => context.GetStartupFile()!,
                [
                    LooseClassCompile.GetClassFromFile(@"Resources\LE2\UScript\Startup_MOD_AMM\AMM_AppearanceUpdater.uc"),
                    ])
                .RunModTask(context);
            // add an instance of the handler class at a hardercoded location, add it to the object referencer
            var startup = context.GetStartupFile()!;
            var newExport = ExportCreator.CreateExport(startup, "AMM_AppearanceUpdater", "AMM_AppearanceUpdater", indexed: true);
            startup.GetOrCreateObjectReferencer().AddToObjectReferencer(newExport);
            startup.Save();
        }
    }
}
