using AppearanceModMenuBuilder.LE1.BuildSteps.DLC;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.UtilityTasks;

namespace AppearanceModMenuBuilder.LE1
{
    internal static class DlcBuild
    {
        public static ModBuilderWithCustomContext<LE1CustomContext> AddDlcTasks(this ModBuilderWithCustomContext<LE1CustomContext> builder, bool skipNonEssential = false)
        {
            var intermediate = builder.AddTasks([
                // clean the DLC directory
                new CleanDlcDirectory(),
                // copy the moddesc
                new CopyFiles(@"Resources\LE1\Root", context => context.ModOutputPathBase),
                // copy the autoload
                new CopyFiles(@"Resources\LE1\dlc", context => context.DLCBaseFolder),
                // copy anything else that goes in the cookedPCConsole, such as config merges
                new CopyFiles(@"Resources\LE1\cookedPCConsole", context => context.CookedPCConsoleFolder),
                // build images for the mod settings submenu
                new BuildMenuImages(),
                // build the startup file
                new BuildStartupFile(),
                // build the file with the actual menu in it
                new BuildMenuFile(),
                // build submenus
                new BuildSubmenuFile(),
                // actually populate the outfit menus
                new OutfitMenuBuilder(),
                // populate the outfit/headgear spec lists
                new OutfitSpecListBuilder(),
                // build the inventory file
                new BuildInventoryHandlerTask(),
                // build UI world
                new BuildUIWorldTask(),
                // build a few NOR files for the armor locker
                //new BuildNor10_09_Files(),
                // add some new conditionals we need
                new BuildPlotManagerFile(),
            ]);

            if (!skipNonEssential)
            {
                intermediate = intermediate.AddTasks(
                    // build some template files
                    new BuildTemplateFiles(),
                    // doing some testing of the framework
                    new FrameworkTest()
                );
            }

            intermediate
                .AddTasks([
                    new ImportGame1TlkLocaliazation(MELocalization.INT, @"Resources\LE1\tlk\GlobalTlk_tlk.xml"),
                    new ImportGame1TlkLocaliazation(MELocalization.DEU, @"Resources\LE1\tlk\GlobalTlk_tlk_DE.xml"),
                    new ImportGame1TlkLocaliazation(MELocalization.ESN, @"Resources\LE1\tlk\GlobalTlk_tlk_ES.xml"),
                    new ImportGame1TlkLocaliazation(MELocalization.POL, @"Resources\LE1\tlk\GlobalTlk_tlk_PL_M.xml", @"Resources\LE1\tlk\GlobalTlk_tlk_PL.xml"),
                    new ImportGame1TlkLocaliazation(MELocalization.RUS, @"Resources\LE1\tlk\GlobalTlk_tlk_RU.xml"),
                    new ImportGame1TlkLocaliazation(MELocalization.FRA, @"Resources\LE1\tlk\GlobalTlk_tlk_FR.xml"),
                    new ImportGame1TlkLocaliazation(MELocalization.ITA, @"Resources\LE1\tlk\GlobalTlk_tlk_IT.xml"),
                    //new ImportGame1TlkLocaliazation(MELocalization.JPN, @"Resources\LE1\tlk\GlobalTlk_tlk_JA.xml")]
                ]);

            return intermediate;
        }
    }
}
