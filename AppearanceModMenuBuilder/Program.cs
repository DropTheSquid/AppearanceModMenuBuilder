using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.MergeTasks;
using MassEffectModBuilder.UtilityTasks;

string game = args.Length > 0 ? args[0] : "";
string mode = args.Length > 1 ? args[1] : "";

const string MergeModName = "AMM";

if (game == "")
{
    throw new Exception("You must specify the game target in the first command line arg");
}

// TODO add more supported targets here eventually
else if (game != "LE1")
{
    throw new Exception($"unsupported game target {game}");
}

ModBuilder LE1ModBuilder = new()
{
    Game = MEGame.LE1,
    ModDLCName = "DLC_MOD_AMM",
    ModOutputPathBase = @"C:\src\M3Mods\LE1\AppearanceModMenu",
    StartupName = "Startup_MOD_AMM.pcc"
};

switch (mode)
{
    case "merge":
        LE1ModBuilder
            // clear the merge mod directory
            .AddTask(new CleanMergeModDirectory())
            // compile the components for a merge mod
            .AddTask(new AddNewClass("SFXGame.pcc", @"Resources\LE1\SFXGame\AppearanceUpdater.uc", "AppearanceUpdater", MergeModName) { SkipMergeMod = true })
            .AddTask(new CustomTask(context =>
            {
                // custom task that adds an instance of AppearanceUpdater to the basegame; this can serve as the default instance and also let me check whether the basegame changes are in place
                // based on the presence of this. 
                var mergePkg = MEPackageHandler.OpenMEPackage(Path.Combine(context.MergeModsFolder, "SFXGameClasses.pcc"));
                ExportCreator.CreateExport(mergePkg, "AppearanceUpdaterInstance", "AppearanceUpdater", indexed: false);
                mergePkg.Save();

                var task = new UpdateAsset("SFXGame.pcc", MergeModName, "AppearanceUpdaterInstance", "AppearanceUpdaterInstance", mergePkg.FilePath, true);
                task.RunModTask(context);
            }))
            .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioPawn.PostBeginPlay", @"Resources\LE1\SFXGame\BioPawn.PostBeginPlay.uc"))
            // TODO add more merge mod tasks
            // generate the actual json for the merge mod
            .AddTask(new GenerateMergeJson())
            .Build();
        break;
    case "dlc":
        LE1ModBuilder
            .AddTask(new CleanDlcDirectory())
            // copy the moddesc
            .AddTask(new CopyFiles(@"Resources\LE1", context => context.ModOutputPathBase))
            // copy the autoload
            .AddTask(new CopyFiles(@"Resources\LE1\dlc", context => context.DLCBaseFolder))
            // copy anyting else I need (eventually?)
            //.AddTask(new CopyFiles(@"Resources\LE1\cookedPCConsole", context => context.CookedPCConsoleFolder))
            // make sure the startup file has a correct object referencer
            .AddTask(new InitializeStartup())
            // make sure the merge class is added to the startup file so that the game will not insta crash if the basegame changes are reverted
            .AddTask(new AddMergeClassesToStartup("SFXGame.pcc", "AppearanceUpdater"))
            // compile some classes into the startup file and 
            .AddTask(new AddClassesToStartup(@"Resources\LE1\Startup"))
            // add an instance of the class at a hardercoded location, add it to the object referencer
            .AddTask(new CustomTask(context =>
            {
                var startup = context.GetStartupFile();

                var newExport = ExportCreator.CreateExport(startup, "AMM_AppearanceUpdaterInstance", "AMM_AppearanceUpdater", indexed: false);

                startup.AddToObjectReferencer(newExport);

                startup.Save();
            }))
            // compile tlks
            .AddTask(new ImportGame1TlkLocaliazation(MELocalization.INT, @"Resources\LE1\tlk\GlobalTlk_tlk.xml"))
            .AddTask(new OutputTlk())
            .Build();
        // TODO
        break;
    case "":
        throw new Exception($"you must specify the build mode in the second command line arg");
    default:
        throw new Exception($"unsupported build mode {mode}");
}


// merge mod tasks

    