using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class BuildPlotManagerFile : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building PlotManager into startup");

            // add a few classes
            var classTask = new AddClassesToFile(
                _ => context.GetStartupFile()!,
                // BioAutoCOnditionals class
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\BioAutoConditionals.uc", []));
            classTask.RunModTask(context);
        }
    }
}
