using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.MergeTasks;
using MassEffectModBuilder.UtilityTasks;

namespace AppearanceModMenuBuilder.LE1
{
    public static class MergeBuild
    {
        public const string MergeModName = "AMM";
        public static ModBuilder AddMergeTasks(this ModBuilder builder)
        {
            return builder
                // clear the merge mod directory
                .AddTask(new CleanMergeModDirectory())
                // compile the components for a merge mod
                .AddTask(new AddNewClass("SFXGame.pcc", @"Resources\LE1\SFXGame\AMM_AppearanceUpdater_Base.uc", MergeModName) { SkipMergeMod = true })
                .AddTask(new CustomTask(context =>
                {
                    // custom task that adds an instance of AppearanceUpdater to the basegame; this can serve as the default instance and also let me check whether the basegame changes are in place
                    // based on the presence of this. 
                    var mergePkg = MEPackageHandler.OpenMEPackage(Path.Combine(context.MergeModsFolder, "SFXGameClasses.pcc"));
                    ExportCreator.CreateExport(mergePkg, "AMM_AppearanceUpdater_Base", "AMM_AppearanceUpdater_Base", indexed: true);
                    mergePkg.Save();

                    var task = new UpdateAsset("SFXGame.pcc", MergeModName, "AMM_AppearanceUpdater_Base_0", "AMM_AppearanceUpdater_Base_0", mergePkg.FilePath, true);
                    task.RunModTask(context);
                }))
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioPawn.PostBeginPlay", @"Resources\LE1\SFXGame\BioPawn.PostBeginPlay.uc"))
                // TODO add more merge mod tasks
                // generate the actual json for the merge mod
                .AddTask(new GenerateMergeJson());
        }
    }
}
