using AppearanceModMenuBuilder.LE1.Models;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class BuildSubmenuFile : IModBuilderTask
    {
        private readonly List<SquadMemberSubmenus> squadMembers = [];
        private readonly List<ClassToCompile> classes = [];

        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building AMM_Submenus.pcc");
            // make a new file to house the new AMM handler and GUI
            // Either this needs to live in a file called AMM or it needs to be under a package called that in startup for compatibility with Remove Window Reflections that already launches it
            var submenuPackageFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "AMM_Submenus.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            submenuPackageFile.GetOrCreateObjectReferencer();

            classes.Add(GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AppearanceSubmenu.uc", ["Mod_GameContent"]));
            classes.Add(GetClassFromFile(@"Resources\LE1\NonStartup\AppearanceSubmenu_CharacterSelect.uc"));
            classes.Add(GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Utilities.uc", ["Mod_GameContent"]));

            squadMembers.Add(new SquadMemberSubmenus("Shepard", 210210218, "Player")
            {
                Romanceable = true,
            });
            squadMembers.Add(new SquadMemberSubmenus("Kaidan", 166121, "Hench_HumanMale")
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2500
            });
            squadMembers.Add(new SquadMemberSubmenus("Ashley", 163457, "Hench_HumanFemale")
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2501
            });
            squadMembers.Add(new SquadMemberSubmenus("Liara", 172365, "Hench_Asari")
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2505
            });
            squadMembers.Add(new SquadMemberSubmenus("Garrus", 125308, "Hench_Turian")
            {
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2503
            });
            squadMembers.Add(new SquadMemberSubmenus("Wrex", 125307, "Hench_Krogan")
            {
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2502
            });
            squadMembers.Add(new SquadMemberSubmenus("Tali", 146007, "Hench_Quarian")
            {
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2504
            });
            squadMembers.Add(new SquadMemberSubmenus("Jenkins", 163868, "Hench_Jenkins")
            {
                DisplayBool = -3551
            });

            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            //var characterSelectMenu = configMergeFile.GetOrCreateClass("AMM_Submenus.AppearanceSubmenu_CharacterSelect", "BioUI.ini");
            var characterSelectMenu = new AppearanceSubmenu("AMM_Submenus.AppearanceSubmenu_CharacterSelect")
            {
                PawnTag = "None",
                SrTitle = 210210217
            };
            configMergeFile.AddOrMergeClassConfig(characterSelectMenu);

            // go through each and add the relevant entries
            foreach (var member in squadMembers)
            {
                member.ModifyPackage(submenuPackageFile);
                classes.AddRange(member.Classes);
                characterSelectMenu.AddMenuEntry(member.GetMenuEntryPoint());
                foreach (var config in member.Submenus)
                {
                    configMergeFile.AddOrMergeClassConfig(config);
                }
            }

            // add all the classes I have collected
            var classTask = new AddClassesToFile(
                _ => submenuPackageFile,
                classes);
                
            classTask.RunModTask(context);
        }
    }
}
