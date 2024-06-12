using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.MergeTasks;
using MassEffectModBuilder.UtilityTasks;

namespace AppearanceModMenuBuilder.LE1
{
    public static class MergeBuild
    {
        public const string MergeModName = "AMM";
        public static ModBuilderWithCustomContext<LE1CustomContext> AddMergeTasks(this ModBuilderWithCustomContext<LE1CustomContext> builder)
        {
            return builder
                // clear the merge mod directory
                .AddTask(new CleanMergeModDirectory())
                // compile the components for a merge mod
                .AddTask(new AddNewClasses("SFXGame.pcc", MergeModName, LooseClassCompile.GetClassFromFile(@"Resources\LE1\SFXGame\AMM_AppearanceUpdater_Base.uc")) { SkipMergeMod = true })
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
                // add hook to cover most pawns who are not modified after loading in
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioPawn.PostBeginPlay", @"Resources\LE1\SFXGame\BioPawn.PostBeginPlay.uc"))
                // hook to cover player after they get more dynamically spawned in
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSPGame.SpawnPlayer", @"Resources\LE1\SFXGame\BioSPGame.SpawnPlayer.uc"))
                // hook to cover henchmen after they get more dynamically spawned in
                // need to update here so it covers invocations of this function from native, such as the SpawnHenchman seq act
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSPGame.SpawnHenchman", @"Resources\LE1\SFXGame\BioSPGame.SpawnHenchman.uc"))
                // hook to handle romance player pawn
                .AddTask(new AddOrReplaceOnClass("SFXGame.pcc", MergeModName, "BioSeqAct_CopyPlayerHeadToTarget", @"Resources\LE1\SFXGame\BioSeqAct_CopyPlayerHeadToTarget.Deactivated.uc"))
                // hook to handle casual outfits, helmet override, and a variety of cutscene changes
                .AddTask(new AddOrReplaceOnClass("SFXGame.pcc", MergeModName, "BioSeqAct_ModifyPropertyPawn", @"Resources\LE1\SFXGame\BioSeqAct_ModifyPropertyPawn.Deactivated.uc"))
                // hook to handle Character creator places that overwrite the appearance
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_NewCharacter.UpdateCharacter", @"Resources\LE1\SFXGame\BioSFHandler_NewCharacter.UpdateCharacter.uc"))
                // update several functions in squad screen so that it handles it better and updates the appearance
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_CharacterRecord.ToggleHelmet", @"Resources\LE1\SFXGame\BioSFHandler_CharacterRecord.ToggleHelmet.uc"))
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_CharacterRecord.Update", @"Resources\LE1\SFXGame\BioSFHandler_CharacterRecord.Update.uc"))
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_CharacterRecord.ChangeToCharacter", @"Resources\LE1\SFXGame\BioSFHandler_CharacterRecord.ChangeToCharacter.uc"))
                // generate the actual json for the merge mod
                .AddTask(new GenerateMergeJson())
                // and finally, compile the merge mod
                .AddTask(new CompileMergeMod(MergeModName, @"H:\MELE_Mods\tools\M3 v9\ME3TweaksModManager\ME3TweaksModManager.exe", "8.0"));
        }
    }
}
