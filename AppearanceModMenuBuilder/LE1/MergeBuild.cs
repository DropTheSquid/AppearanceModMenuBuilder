using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.MergeTasks;
using MassEffectModBuilder.UtilityTasks;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

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
                // TODO remove this now that it isn't actually used by the merge mod anymore
                .AddTask(new AddNewClasses("SFXGame.pcc", MergeModName, LooseClassCompile.GetClassFromFile(@"Resources\LE1\SFXGame\AMM_AppearanceUpdater_Base.uc")) { SkipMergeMod = true })
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
                .AddTask(new AddOrUpdateClass("SFXGame.pcc", MergeModName, @"Resources\LE1\SFXGame\AMM_AppearanceUpdater_Base.uc"))
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
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_NewCharacter.UpdateUIState", @"Resources\LE1\SFXGame\BioSFHandler_NewCharacter.UpdateUIState.uc"))
                // update several functions in squad screen so that it handles it better and updates the appearance
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_CharacterRecord.ToggleHelmet", @"Resources\LE1\SFXGame\BioSFHandler_CharacterRecord.ToggleHelmet.uc"))
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_CharacterRecord.Update", @"Resources\LE1\SFXGame\BioSFHandler_CharacterRecord.Update.uc"))
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_CharacterRecord.ChangeToCharacter", @"Resources\LE1\SFXGame\BioSFHandler_CharacterRecord.ChangeToCharacter.uc"))
                // adding an appearance update to the xmods handler so helmets don't disappear when changing mods in some cases
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "BioSFHandler_XMods.EquipSelectedItem", @"Resources\LE1\SFXGame\BioSFHandler_XMods.EquipSelectedItem.uc"))
                // update GameModeBase so it signals us when the game mode changes
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "SFXGameModeBase.Activated", @"Resources\LE1\SFXGame\SFXGameModeBase.Activated.uc"))
                .AddTask(new UpdateFunction("SFXGame.pcc", MergeModName, "SFXGameModeBase.Deactivated", @"Resources\LE1\SFXGame\SFXGameModeBase.Deactivated.uc"))
                // generate the actual json for the merge mod
                .AddTask(new GenerateMergeJson())
                // and finally, compile the merge mod
                .AddTask(new CompileMergeMod(MergeModName, FeatureLevel: "9.0"));
        }
    }
}
