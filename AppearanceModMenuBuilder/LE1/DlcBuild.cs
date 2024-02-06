﻿using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Packages.CloningImportingAndRelinking;
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
                    [..LooseClassCompile.GetClassesFromDirectories(@"Resources\LE1\Startup"),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Pawn_Parameters.uc", ["Mod_GameContent"])]))
                // add an instance of the handler class at a hardercoded location, add it to the object referencer
                .AddTask(new CustomTask(context =>
                {
                    var startup = context.GetStartupFile();
                    var newExport = ExportCreator.CreateExport(startup, "AMM_AppearanceUpdater", "AMM_AppearanceUpdater", indexed: true);
                    startup.GetOrCreateObjectReferencer().AddToObjectReferencer(newExport);
                    startup.Save();
                }))
                .AddTask(new OutfitSpecListBuilder())
                .AddTask(new BuildInventoryHandlerTask())
                .AddTask(new BuildUIWorldTask())
                // compile tlks
                .AddTask(new ImportGame1TlkLocaliazation(MELocalization.INT, @"Resources\LE1\tlk\GlobalTlk_tlk.xml"))
                .AddTask(new OutputTlk());
        }
    }
}
