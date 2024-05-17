using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder;
using LegendaryExplorerCore.Packages;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    internal class BuildTemplateFiles : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            // partly to generate an up to date template file for distribution, partly to make sure I have not introduced any nasty dependencies
            Console.WriteLine("Building SubmenuTemplate.pcc");

            // make the folder
            Directory.CreateDirectory(Path.Combine(context.ModOutputPathBase, @"Templates"));

            var submenuTemplateFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.ModOutputPathBase, @"Templates\SubmenuTemplate.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            submenuTemplateFile.GetOrCreateObjectReferencer();

            // add a few classes
            var classTask = new AddClassesToFile(
                _ => submenuTemplateFile,
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Common.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AppearanceSubmenu.uc", ["Mod_GameContent"]));
            classTask.RunModTask(context);


            // partly to generate an up to date template file for distribution, partly to make sure I have not introduced any nasty dependencies
            Console.WriteLine("Building PawnParamsTemplate.pcc");

            var pawnParamsTemplateFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.ModOutputPathBase, @"Templates\PawnParamsTemplate.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            pawnParamsTemplateFile.GetOrCreateObjectReferencer();

            // add a few classes
            classTask = new AddClassesToFile(
                _ => pawnParamsTemplateFile,
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Common.uc", ["Mod_GameContent"]),
                LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Pawn_Parameters.uc", ["Mod_GameContent"]));
            classTask.RunModTask(context);


        }
    }
}
