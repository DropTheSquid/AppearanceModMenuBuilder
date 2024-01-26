using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.MergeTasks;
using MassEffectModBuilder.UtilityTasks;

ModBuilder LE1ModBuilder = new()
{
    Game = MEGame.LE1,
    ModDLCName = "DLC_MOD_AMM",
    ModOutputPathBase = @"C:\src\M3Mods\LE1\AppearanceModMenu",
    StartupName = "Startup_MOD_AMM.pcc"
};

string game = args.Length > 0 ? args[0] : "";
string mode = args.Length > 1 ? args[1] : "";

const string MergeModName = "AMM";

if (game == "")
{
    throw new Exception("You must specific the game target in the first command line arg");
}
// TODO add more supported targets here eventually
else if (game != "LE1")
{
    throw new Exception($"unsupported game target {game}");
}

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
            .AddTask(new InitializeStartup())
            .AddTask(new AddMergeClassesToStartup("SFXGame.pcc", "AppearanceUpdater"))
            .AddTask(new AddClassesToStartup(@"Resources\LE1\Startup"))
            .AddTask(new CustomTask(context =>
            {
                var startup = context.GetStartupFile();

                var newExport = ExportCreator.CreateExport(startup, "AMM_AppearanceUpdaterInstance", "AMM_AppearanceUpdater", indexed: false);

                // experiment to add stuff to the object referencer
                var objectReferencer = startup.FindExport("CombinedStartupReferencer") ?? throw new Exception("Could not find object referencer");
                var referenceProp = objectReferencer.GetProperties()?.GetProp<ArrayProperty<ObjectProperty>>("ReferencedObjects");

                referenceProp ??= new ArrayProperty<ObjectProperty>("ReferencedObjects");
                referenceProp.Add(new ObjectProperty(newExport));
                objectReferencer.WriteProperty(referenceProp);

                startup.Save();
            }))
            .AddTask(new ImportGame1TlkLocaliazation(MELocalization.INT, @"Resources\LE1\tlk\GlobalTlk_tlk.xml"))
            .AddTask(new OutputTlk())
            .Build();
        // TODO
        break;
    case "":
        throw new Exception($"you must specific the build mode in the second command line arg");
    default:
        throw new Exception($"unsupported build mode {mode}");
}


// merge mod tasks

    