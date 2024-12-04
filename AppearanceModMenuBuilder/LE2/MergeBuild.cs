using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.MergeTasks;
using MassEffectModBuilder.UtilityTasks;
using MassEffectModBuilder;
using LegendaryExplorerCore.Packages;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;
using MassEffectModBuilder.DLCTasks;

namespace AppearanceModMenuBuilder.LE2
{
    public static class MergeBuild
    {
        public const string MergeModName = "AMM";
        public static ModBuilderWithCustomContext<LE2CustomContext> AddMergeTasks(this ModBuilderWithCustomContext<LE2CustomContext> builder)
        {
            return builder
                .AddTask(new CustomTask(_ => Console.WriteLine("Building Merge component of mod")))
                // clear the merge mod directory
                .AddTask(new CleanMergeModDirectory())
                // TODO remove this now that it isn't actually used by the merge mod anymore
                .AddTask(new AddNewClasses("SFXGame.pcc", MergeModName, LooseClassCompile.GetClassFromFile(@"Resources\LE2\UScript\SFXGame\AMM_AppearanceUpdater_Base.uc")) { SkipMergeMod = true })
                // first, add an instance of the new class via assetUpdate (which will also add an empty stub if installing for the first time)
                .AddTask(new CustomTask(context =>
                {
                    // first, make an empty package
                    using IMEPackage mergePackage = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.MergeModsFolder, "AMM_AppearanceUpdater_Base.pcc"), context.Game);

                    // add the empty stub class to the file
                    new AddClassesToFile(context => mergePackage, new ClassToCompile("AMM_AppearanceUpdater_Base", "class AMM_AppearanceUpdater_Base;"))
                        .RunModTask(context);

                    ExportCreator.CreateExport(mergePackage, "AMM_AppearanceUpdater_Base", "AMM_AppearanceUpdater_Base", indexed: true);
                    mergePackage.Save();

                    var task = new UpdateAsset("SFXGame.pcc", MergeModName, "AMM_AppearanceUpdater_Base_0", "AMM_AppearanceUpdater_Base_0", mergePackage.FilePath, true);
                    task.RunModTask(context);
                }))
                // then update the class to have all the things it should
                .AddTask(new AddOrUpdateClass("SFXGame.pcc", MergeModName, @"Resources\LE2\UScript\SFXGame\AMM_AppearanceUpdater_Base.uc"))
                // add hook to LoadMorphHead
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "SFXSaveGame.LoadMorphHead", @"Resources\LE2\Functions\SFXSaveGame.LoadMorphHead.uc"))
                // add hook to SaveMorphHead
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "SFXSaveGame.SaveMorphHead", @"Resources\LE2\Functions\SFXSaveGame.SaveMorphHead.uc"))
                // add hook to UpdateAppearance
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "SFXPawn_Player.UpdateAppearance", @"Resources\LE2\Functions\SFXPawn_Player.UpdateAppearance.uc"))
                // TODO add more hooks, such as UpdateAppearance
                // generate the actual json for the merge mod
                .AddTask(new GenerateMergeJson())
                // and finally, compile the merge mod
                .AddTask(new CompileMergeMod(MergeModName, FeatureLevel: "9.0"));
        }
    }
}
