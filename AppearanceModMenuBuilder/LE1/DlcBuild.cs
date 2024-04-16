using AppearanceModMenuBuilder.LE1.BuildSteps.DLC;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.UtilityTasks;

namespace AppearanceModMenuBuilder.LE1
{
    internal static class DlcBuild
    {
        public static ModBuilderWithCustomContext<LE1CustomContext> AddDlcTasks(this ModBuilderWithCustomContext<LE1CustomContext> builder)
        {
            return builder
                // clean the DLC directory
                .AddTask(new CleanDlcDirectory())
                // copy the moddesc
                .AddTask(new CopyFiles(@"Resources\LE1\Root", context => context.ModOutputPathBase))
                // copy the autoload
                .AddTask(new CopyFiles(@"Resources\LE1\dlc", context => context.DLCBaseFolder))
                // copy anything else that goes in the cookedPCConsole, such as config merges
                .AddTask(new CopyFiles(@"Resources\LE1\cookedPCConsole", context => context.CookedPCConsoleFolder))
                // build submenus
                .AddTask(new BuildSubmenuFile())
                // build the startup file
                .AddTask(new BuildStartupFile())
                // build the file with the actual menu in it
                .AddTask(new BuildMenuFile())
                // build the inventory file
                .AddTask(new BuildInventoryHandlerTask())
                // build UI world
                .AddTask(new BuildUIWorldTask())
                // output any config merge files we worked on
                .AddTask(new OutputConfigMerge())
                // compile tlks
                .AddTask(new ImportGame1TlkLocaliazation(MELocalization.INT, @"Resources\LE1\tlk\GlobalTlk_tlk.xml"))
                .AddTask(new OutputTlk());
        }
    }
}
