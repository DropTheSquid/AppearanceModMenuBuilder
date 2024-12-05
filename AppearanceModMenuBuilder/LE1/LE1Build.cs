using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.M3Tasks;

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
                ModOutputPathBase = @"E:\General Mod Manager\ME3TweaksModManager\mods\LE1\AppearanceModMenu",
                StartupName = "Startup_MOD_AMM.pcc"
            };

            switch (mode)
            {
                // build the merge stuff only
                case "merge":
                    LE1ModBuilder.AddMergeTasks();
                    LE1ModBuilder.OutputConfigAndTlk = false;
                    break;
                // build the DLC stuff only
                case "dlc":
                    LE1ModBuilder.AddDlcTasks();
                    break;
                // build both merge and DLC and install the mod
                case "full":
                    LE1ModBuilder
                        .AddMergeTasks()
                        .AddDlcTasks()
                        .AddTask(new InstallModTask(false));
                    break;
                // build just the dlc and install the mod; assumes you have previously built the merge or the full mod, but if you are not changing the merge, it is faster to build and isntall
                case "quick":
                    LE1ModBuilder
                        .AddDlcTasks(skipNonEssential: true)
                        .AddTask(new InstallModTask(false));
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
