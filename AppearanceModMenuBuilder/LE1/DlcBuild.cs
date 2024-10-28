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
            var intermediate = builder
                // clean the DLC directory
                .AddTask(new CleanDlcDirectory())
                // copy the moddesc
                .AddTask(new CopyFiles(@"Resources\LE1\Root", context => context.ModOutputPathBase))
                // copy the autoload
                .AddTask(new CopyFiles(@"Resources\LE1\dlc", context => context.DLCBaseFolder))
                // copy anything else that goes in the cookedPCConsole, such as config merges
                .AddTask(new CopyFiles(@"Resources\LE1\cookedPCConsole", context => context.CookedPCConsoleFolder))
                // build the startup file
                .AddTask(new BuildStartupFile())
                // build the file with the actual menu in it
                .AddTask(new BuildMenuFile())
                // build submenus
                .AddTask(new BuildSubmenuFile())
                // actually populate the outfit menus
                .AddTask(new OutfitMenuBuilder())
                // populate the outfit/headgear spec lists
                .AddTask(new OutfitSpecListBuilder())
                // build the inventory file
                .AddTask(new BuildInventoryHandlerTask())
                // build UI world
                .AddTask(new BuildUIWorldTask())
                // build a few NOR files for the armor locker
                //.AddTask(new BuildNor10_09_Files())
                // add some new conditionals we need
                .AddTask(new BuildPlotManagerFile());

            if (!skipNonEssential)
            {
                intermediate = intermediate
                    // build some template files
                    .AddTask(new BuildTemplateFiles())
                    // doing some testing of the framework
                    .AddTask(new FrameworkTest());
            }

            intermediate
                // output any config merge files we worked on
                .AddTask(new OutputConfigMerge())
                // compile tlks
                .AddTask(new ImportGame1TlkLocaliazation(MELocalization.INT, @"Resources\LE1\tlk\GlobalTlk_tlk.xml"))
                //.AddTask(new ImportGame1TlkLocaliazation(MELocalization.DEU, @"Resources\LE1\tlk\GlobalTlk_tlk_DE.xml"))
                //.AddTask(new ImportGame1TlkLocaliazation(MELocalization.ESN, @"Resources\LE1\tlk\GlobalTlk_tlk_ES.xml"))
                .AddTask(new ImportGame1TlkLocaliazation(MELocalization.POL, @"Resources\LE1\tlk\GlobalTlk_tlk_PL_M.xml", @"Resources\LE1\tlk\GlobalTlk_tlk_PL.xml"))
                //.AddTask(new ImportGame1TlkLocaliazation(MELocalization.RUS, @"Resources\LE1\tlk\GlobalTlk_tlk_RU.xml"))
                .AddTask(new OutputTlk());

            return intermediate;
        }
    }
}
