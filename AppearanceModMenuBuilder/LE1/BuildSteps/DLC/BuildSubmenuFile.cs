﻿using AppearanceModMenuBuilder.LE1.Models;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.Models;
using static LegendaryExplorerCore.Unreal.UnrealFlags;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class BuildSubmenuFile : IModBuilderTask
    {
        private readonly List<ClassToCompile> classes = [];

        public struct SpeciesOutfitMenus
        {
            public AppearanceSubmenu Casual;
            public AppearanceSubmenu Combat;
            public AppearanceSubmenu Armor;
            public AppearanceSubmenu NonArmor;
        }

        public SpeciesOutfitMenus HumanOutfitMenus;
        public SpeciesOutfitMenus TurianOutfitMenus;
        public SpeciesOutfitMenus KroganOutfitMenus;
        public SpeciesOutfitMenus QuarianOutfitMenus;

        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building AMM_Submenus.pcc");
            // make a new file to house the new AMM handler and GUI
            // Either this needs to live in a file called AMM or it needs to be under a package called that in startup for compatibility with Remove Window Reflections that already launches it
            var submenuPackageFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "AMM_Submenus.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            submenuPackageFile.GetOrCreateObjectReferencer();

            classes.Add(GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AppearanceSubmenu.uc", ["Mod_GameContent"]));
            classes.Add(GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Utilities.uc", ["Mod_GameContent"]));

            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            var characterSelectMenu = new AppearanceSubmenu("AMM_Submenus.AppearanceSubmenu_CharacterSelect")
            {
                PawnTag = "None",
                // "Select a character"
                SrTitle = 210210217
            };

            configMergeFile.AddOrMergeClassConfig(characterSelectMenu);

            classes.Add(SquadMemberSubmenus.GetSubmenuClass("CharacterSelect", []));

            MakeCommonSubmenus(submenuPackageFile, configMergeFile);

            var squadMembers = MakeSquadmateSubmenus();

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

        public static (SpeciesOutfitMenus human, SpeciesOutfitMenus turian, SpeciesOutfitMenus quarian, SpeciesOutfitMenus krogan) InitCommonMenus(ModConfigMergeFile configMergeFile)
        {
            SpeciesOutfitMenus GetOrCreateMenus(string bodyType)
            {
                return new SpeciesOutfitMenus
                {
                    Casual = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_CasualOutfits", configMergeFile),
                    Combat = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_CombatOutfits", configMergeFile),
                    Armor = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.Armor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_ArmorOutfits", configMergeFile),
                    NonArmor = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits", configMergeFile)
                };
            }
            return (GetOrCreateMenus("Human"), GetOrCreateMenus("Turian"), GetOrCreateMenus("Quarian"), GetOrCreateMenus("Krogan"));
        }

        private void MakeCommonSubmenus(IMEPackage submenuPackageFile, ModConfigMergeFile configMergeFile)
        {
            (HumanOutfitMenus, TurianOutfitMenus, QuarianOutfitMenus, KroganOutfitMenus) = InitCommonMenus(configMergeFile);
            void SetupMenu(string bodyType, SpeciesOutfitMenus menus)
            {
                var packageExp = ExportCreator.CreatePackageExport(submenuPackageFile, bodyType);
                // remove the forced export flag on this package. We need it to be dynamic loadable, including this package name, so it needs to not be forced export
                packageExp.ExportFlags &= ~EExportFlags.ForcedExport;

                // make a new class and config type for each thing
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_CasualOutfits", [bodyType]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_CombatOutfits", [bodyType]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_ArmorOutfits", [bodyType, "Armor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits", [bodyType, "NonArmor"]));

                menus.Casual.AddMenuEntry(new AppearanceItemData()
                {
                    // "Default"
                    SrCenterText = 184218,
                    ApplyOutfitId = -1,
                });
                menus.Casual.AddMenuEntry(new AppearanceItemData()
                {
                    // "Casual"
                    SrCenterText = 771301,
                    ApplyOutfitId = -2,
                });
                menus.Casual.AddMenuEntry(new AppearanceItemData()
                {
                    // "Combat"
                    SrCenterText = 163187,
                    ApplyOutfitId = -3,
                });

                menus.Combat.AddMenuEntry(new AppearanceItemData()
                {
                    // "Default"
                    SrCenterText = 184218,
                    ApplyOutfitId = -1,
                });
                menus.Combat.AddMenuEntry(new AppearanceItemData()
                {
                    // "Casual"
                    SrCenterText = 771301,
                    ApplyOutfitId = -2,
                });
                menus.Combat.AddMenuEntry(new AppearanceItemData()
                {
                    // "Combat"
                    SrCenterText = 163187,
                    ApplyOutfitId = -3,
                });

                // "Armor"
                menus.Casual.AddMenuEntry(menus.Armor.GetEntryPoint(210210233));
                // "Non Armor"
                menus.Casual.AddMenuEntry(menus.NonArmor.GetEntryPoint(210210234));

                // "Armor"
                menus.Combat.AddMenuEntry(menus.Armor.GetEntryPoint(210210233));
                // "Non Armor"
                menus.Combat.AddMenuEntry(menus.NonArmor.GetEntryPoint(210210234));

                // TODO add titles and subtitles to these?
            }
            SetupMenu("Human", HumanOutfitMenus);
            SetupMenu("Turian", TurianOutfitMenus);
            SetupMenu("Quarian", QuarianOutfitMenus);
            SetupMenu("Krogan", KroganOutfitMenus);
        }

        private List<SquadMemberSubmenus> MakeSquadmateSubmenus()
        {
            List<SquadMemberSubmenus> squadMembers = [];

            squadMembers.Add(new SquadMemberSubmenus("Shepard", 210210218, "Player", HumanOutfitMenus)
            {
                Romanceable = true,
            });
            squadMembers.Add(new SquadMemberSubmenus("Kaidan", 166121, "Hench_HumanMale", HumanOutfitMenus)
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2500
            });
            squadMembers.Add(new SquadMemberSubmenus("Ashley", 163457, "Hench_HumanFemale", HumanOutfitMenus)
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2501
            });
            squadMembers.Add(new SquadMemberSubmenus("Liara", 172365, "Hench_Asari", HumanOutfitMenus)
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2505
            });
            squadMembers.Add(new SquadMemberSubmenus("Garrus", 125308, "Hench_Turian", TurianOutfitMenus)
            {
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2503
            });
            squadMembers.Add(new SquadMemberSubmenus("Wrex", 125307, "Hench_Krogan", KroganOutfitMenus)
            {
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2502
            });
            squadMembers.Add(new SquadMemberSubmenus("Tali", 146007, "Hench_Quarian", QuarianOutfitMenus)
            {
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2504
            });
            squadMembers.Add(new SquadMemberSubmenus("Jenkins", 163868, "Hench_Jenkins", HumanOutfitMenus)
            {
                // this bool will be set to true once Jenkins dies, which will block the menu from showing him from that point forward
                DisplayBool = -3551
            });

            return squadMembers;
        }
    }
}
