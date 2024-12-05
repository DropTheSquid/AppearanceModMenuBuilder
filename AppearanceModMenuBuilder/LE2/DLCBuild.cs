using AppearanceModMenuBuilder.LE2.DLCBuildSteps;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.UtilityTasks;

namespace AppearanceModMenuBuilder.LE2
{
    internal static class DlcBuild
    {
        public static ModBuilderWithCustomContext<LE2CustomContext> AddDlcTasks(this ModBuilderWithCustomContext<LE2CustomContext> builder, bool skipNonEssential = false)
        {
            var intermediate = builder
                .AddTasks(
                    // clean the DLC directory
                    new CleanDlcDirectory(),
                    // copy the moddesc
                    new CopyFiles(@"Resources\LE2\Root", context => context.ModOutputPathBase),
                    // copy anything else that goes in the cookedPCConsole, such as config merges
                    new CopyFiles(@"Resources\LE2\cookedPCConsole", context => context.CookedPCConsoleFolder),
                    // build the startup file
                    new BuildStartupFile(),
                    // build the submenus file
                    new BuildSubmenuFile()
                );

            if (!skipNonEssential)
            {
                // TODO if there are nonessential tasks like generating template files, put them here
            }

            intermediate
                .AddTasks(
                    // add the tlks
                    new ImportGame23TlkLocaliazation(MELocalization.INT, @"Resources\LE2\tlk\DLC_2555_INT.xml")
                    //new ImportGame23TlkLocaliazation(MELocalization.DEU, @"Resources\LE2\tlk\DLC_2555_DEU.xml"),
                    //new ImportGame23TlkLocaliazation(MELocalization.ESN, @"Resources\LE2\tlk\DLC_2555_ESN.xml"),
                    //new ImportGame23TlkLocaliazation(MELocalization.POL, @"Resources\LE2\tlk\DLC_2555_POL.xml"),
                    //new ImportGame23TlkLocaliazation(MELocalization.RUS, @"Resources\LE2\tlk\DLC_2555_RUS.xml"),
                    //new ImportGame23TlkLocaliazation(MELocalization.FRA, @"Resources\LE2\tlk\DLC_2555_FRA.xml"),
                    //new ImportGame23TlkLocaliazation(MELocalization.ITA, @"Resources\LE2\tlk\DLC_2555_ITA.xml"),
                    //new ImportGame23TlkLocaliazation(MELocalization.JPN, @"Resources\LE2\tlk\DLC_2555_JPN.xml"),
                );

            return intermediate;
        }
    }
}
