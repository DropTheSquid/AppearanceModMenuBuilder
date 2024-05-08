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
            Console.WriteLine("Building PlotManagerDLC_AMM.pcc");
            
            var plotPackageFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "PlotManagerDLC_AMM.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            plotPackageFile.GetOrCreateObjectReferencer();

            // add a few classes
            var classTask = new AddClassesToFile(
                _ => plotPackageFile,
                // the handler inheritance tree
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\BioAutoConditionals.uc", []));
            classTask.RunModTask(context);
        }
    }
}
