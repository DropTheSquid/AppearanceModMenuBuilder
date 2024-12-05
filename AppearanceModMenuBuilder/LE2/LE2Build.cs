using LegendaryExplorerCore.Packages;
using MassEffectModBuilder.M3Tasks;
using MassEffectModBuilder;

namespace AppearanceModMenuBuilder.LE2
{
    public static class LE2Build
    {
        public static void RunBuild(string mode)
        {
            ModBuilderWithCustomContext<LE2CustomContext> LE2ModBuilder = new()
            {
                Game = MEGame.LE2,
                ModDLCName = "DLC_MOD_AMM",
                ModOutputPathBase = @$"{Config.LibraryRootPath}\LE2\Appearance Modification Menu",
                StartupName = "Startup_MOD_AMM.pcc",
                ModuleNumber = 2555,
                LocalizationStringref = 1865980
            };

            switch (mode)
            {
                // builds only the merge portion of the mod
                case "merge":
                    LE2ModBuilder.AddMergeTasks();
                    LE2ModBuilder.OutputConfigAndTlk = false;
                    break;
                // builds only the dlc portion of the mod
                case "dlc":
                    LE2ModBuilder.AddDlcTasks();
                    break;
                // builds both the 
                case "full":
                    LE2ModBuilder
                        .AddMergeTasks()
                        .AddDlcTasks()
                        .AddTask(new InstallModTask(false));
                    break;
                case "quick":
                    LE2ModBuilder
                        .AddDlcTasks(skipNonEssential: true)
                        .AddTask(new InstallModTask(false));
                    break;
                case "":
                    throw new Exception($"you must specify the build mode in the second command line arg");
                default:
                    throw new Exception($"unsupported build mode {mode}");
            }

            LE2ModBuilder.Build(new LE2CustomContext());
        }
    }
}
