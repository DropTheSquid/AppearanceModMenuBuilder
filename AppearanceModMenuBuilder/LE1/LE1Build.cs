using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;

namespace AppearanceModMenuBuilder.LE1
{
    public static class LE1Build
    {
        public static void RunBuild(string mode)
        {
            ModBuilderWithCustomContext<LE1CustomContext> LE1ModBuilder = new()
            {
                Game = MEGame.LE1,
                ModDLCName = "DLC_MOD_AMM",
                ModOutputPathBase = @"C:\src\M3Mods\LE1\AppearanceModMenu",
                StartupName = "Startup_MOD_AMM.pcc"
            };

            switch (mode)
            {
                case "merge":
                    LE1ModBuilder.AddMergeTasks();
                    break;
                case "dlc":
                    LE1ModBuilder.AddDlcTasks();
                    break;
                case "full":
                    LE1ModBuilder
                        .AddMergeTasks()
                        .AddDlcTasks();
                    break;
                case "":
                    throw new Exception($"you must specify the build mode in the second command line arg");
                default:
                    throw new Exception($"unsupported build mode {mode}");
            }

            LE1ModBuilder.Build(new LE1CustomContext());
        }
    }
}
