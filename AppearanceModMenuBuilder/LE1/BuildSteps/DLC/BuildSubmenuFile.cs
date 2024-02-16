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
            List<string> submenuConfigLines = [];
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

            // header:
            submenuConfigLines.AddRange([
                "[BioUI.ini AMM_Submenus.AppearanceSubmenu_CharacterSelect]",
                // make sure there is no pawn in this menu. 
                "pawnTag=None",
                // Select a Character
                "srTitle=210210217"
                ]);
            // go through each and add to the top of the file
            foreach (var member in squadMembers)
            {
                member.ModifyPackage(submenuPackageFile);
                classes.AddRange(member.GenerateClassesToCompile());
                submenuConfigLines.AddRange(member.GenerateRootMenuEntry());
            }
            // then add to the bottom in chunks
            foreach (var member in squadMembers)
            {
                submenuConfigLines.Add("");
                submenuConfigLines.AddRange(member.GenerateSubmenuEntries());
            }

            File.WriteAllLines(Path.Combine(context.CookedPCConsoleFolder, "ConfigDelta-amm_Submenus.m3cd"), submenuConfigLines);

            // add a few classes
            var classTask = new AddClassesToFile(
                _ => submenuPackageFile,
                classes);
                
            classTask.RunModTask(context);
        }
    }
}
