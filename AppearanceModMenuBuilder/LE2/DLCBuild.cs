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
                // clean the DLC directory
                .AddTask(new CleanDlcDirectory())
                // copy the moddesc
                .AddTask(new CopyFiles(@"Resources\LE2\Root", context => context.ModOutputPathBase))
                // copy anything else that goes in the cookedPCConsole, such as config merges
                .AddTask(new CopyFiles(@"Resources\LE2\cookedPCConsole", context => context.CookedPCConsoleFolder))
                //// build the startup file
                .AddTask(new BuildStartupFile());

            if (!skipNonEssential)
            {
                //intermediate = intermediate
                    // build some template files
                    //.AddTask(new BuildTemplateFiles())
                    //// doing some testing of the framework
                    //.AddTask(new FrameworkTest());
            }

            intermediate
                // output any config merge files we worked on
                .AddTask(new OutputConfigMerge())
                // compile tlks
                .AddTask(new ImportGame23TlkLocaliazation(MELocalization.INT, @"Resources\LE2\tlk\DLC_2555_INT.xml"))
                //.AddTask(new ImportGame23TlkLocaliazation(MELocalization.DEU, @"Resources\LE2\tlk\DLC_2555_DEU.xml"))
                //.AddTask(new ImportGame23TlkLocaliazation(MELocalization.ESN, @"Resources\LE2\tlk\DLC_2555_ESN.xml"))
                //.AddTask(new ImportGame23TlkLocaliazation(MELocalization.POL, @"Resources\LE2\tlk\DLC_2555_POL.xml"))
                //.AddTask(new ImportGame23TlkLocaliazation(MELocalization.RUS, @"Resources\LE2\tlk\DLC_2555_RUS.xml"))
                //.AddTask(new ImportGame23TlkLocaliazation(MELocalization.FRA, @"Resources\LE2\tlk\DLC_2555_FRA.xml"))
                //.AddTask(new ImportGame23TlkLocaliazation(MELocalization.ITA, @"Resources\LE2\tlk\DLC_2555_ITA.xml"))
                //.AddTask(new ImportGame23TlkLocaliazation(MELocalization.JPN, @"Resources\LE2\tlk\DLC_2555_JPN.xml"))
                .AddTask(new OutputTlk(1865980));

            return intermediate;
        }
    }
}
