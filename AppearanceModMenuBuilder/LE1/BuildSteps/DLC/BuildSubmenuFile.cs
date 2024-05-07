using AppearanceModMenuBuilder.LE1.Models;
using AppearanceModMenuBuilder.LE1.UScriptModels;
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
            public AppearanceSubmenu? NonArmor;
            public AppearanceSubmenu Headgear;
            public AppearanceSubmenu Breather;
            public AppearanceSubmenu[] CasualOutfitMenus;
        }

        public SpeciesOutfitMenus HumanFemaleOutfitMenus;
        public SpeciesOutfitMenus HumanMaleOutfitMenus;
        public SpeciesOutfitMenus AsariOutfitMenus;
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

            classes.AddRange([
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AppearanceSubmenu.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Utilities.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Startup\AMM_AppearanceUpdater.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\Pawn_Parameter_Handler.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Pawn_Parameters.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\OutfitSpecBase.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\SimpleOutfitSpec.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\OutfitSpecListBase.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\HelmetSpecListBase.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\breatherSpecListBase.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\breatherSpecBase.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\SimpleBreatherSpec.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\SimpleHelmetSpec.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\helmetSpecBase.uc", ["Mod_GameContent"]),
                ]);

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

        public static (SpeciesOutfitMenus humanFemale, SpeciesOutfitMenus humanMale, SpeciesOutfitMenus asari, SpeciesOutfitMenus turian, SpeciesOutfitMenus quarian, SpeciesOutfitMenus krogan) InitCommonMenus(ModConfigMergeFile configMergeFile)
        {
            SpeciesOutfitMenus GetOrCreateMenus(string bodyType, bool skipNonArmor = false)
            {
                return new SpeciesOutfitMenus
                {
                    Casual = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_CasualOutfits", configMergeFile),
                    Combat = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_CombatOutfits", configMergeFile),
                    Armor = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.Armor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_ArmorOutfits", configMergeFile),
                    NonArmor = skipNonArmor ? null : AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits", configMergeFile),
                    Headgear = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_Headgear", configMergeFile),
                    Breather = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_Breather", configMergeFile)
                };
            }
            void AddHumanIshMenus(ref SpeciesOutfitMenus menus, string bodyType)
            {
                menus.CasualOutfitMenus = [
                    // misc, such as nude, VI materials, dancer; things that are implausible/immersion breaking and not shown by default
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_Misc", configMergeFile),
                    // CTHa
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHa", configMergeFile),
                    // CTHb
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHb", configMergeFile),
                    // CTHc
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHc", configMergeFile),
                    // CTHd
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHd", configMergeFile),
                    // CTHe
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHe", configMergeFile),
                    // CTHf
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHf", configMergeFile),
                    // CTHg
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHg", configMergeFile),
                    // CTHh
                    AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.{bodyType}.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_NonArmorOutfits_CTHh", configMergeFile),
                    ];
            }
            var humanFemale = GetOrCreateMenus("HumanFemale");
            var humanMale = GetOrCreateMenus("HumanMale");
            var asari = GetOrCreateMenus("Asari");
            AddHumanIshMenus(ref humanFemale, "HumanFemale");
            AddHumanIshMenus(ref humanMale, "HumanMale");
            AddHumanIshMenus(ref asari, "Asari");
            var turian = GetOrCreateMenus("Turian");
            turian.CasualOutfitMenus = [
                // CTHa (and the alt no hood version)
                AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.Turian.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}Turian_NonArmorOutfits_CTHa", configMergeFile),
                // CTHb
                AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.Turian.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}Turian_NonArmorOutfits_CTHb", configMergeFile),
                // CTHc
                AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.Turian.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}Turian_NonArmorOutfits_CTHc", configMergeFile)
                ];
            var quarian = GetOrCreateMenus("Quarian", true);
            // no additional submenus for Quarians
            var krogan = GetOrCreateMenus("Krogan");
            krogan.CasualOutfitMenus = [
                // CTHa, to be inlined
                AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus.Krogan.NonArmor.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}Krogan_NonArmorOutfits_CTHa", configMergeFile),
                ];

            return (humanFemale, humanMale, asari, turian, quarian, krogan);
        }

        private void MakeCommonSubmenus(IMEPackage submenuPackageFile, ModConfigMergeFile configMergeFile)
        {
            (HumanFemaleOutfitMenus, HumanMaleOutfitMenus, AsariOutfitMenus, TurianOutfitMenus, QuarianOutfitMenus, KroganOutfitMenus) = InitCommonMenus(configMergeFile);
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
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_Headgear", [bodyType]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_Breather", [bodyType]));

                // TODO I should hide this if there is no headgear available/perhaps skip it entirely for Tali and make mods add it/enable it
                menus.Casual.AddMenuEntry(menus.Headgear.GetEntryPoint(210210237, hideIfHeadgearSuppressed: true));
                menus.Casual.AddMenuEntry(new AppearanceItemData()
                {
                    // "Default"
                    SrCenterText = 184218,
                    ApplyOutfitId = -1,
                });
                //menus.Casual.AddMenuEntry(new AppearanceItemData()
                //{
                //    // "Casual"
                //    SrCenterText = 771301,
                //    ApplyOutfitId = -2,
                //});
                //menus.Casual.AddMenuEntry(new AppearanceItemData()
                //{
                //    // "Combat"
                //    SrCenterText = 163187,
                //    ApplyOutfitId = -3,
                //});

                menus.Combat.AddMenuEntry(menus.Headgear.GetEntryPoint(210210237, hideIfHeadgearSuppressed: true));
                menus.Combat.AddMenuEntry(new AppearanceItemData()
                {
                    // "Default"
                    SrCenterText = 184218,
                    ApplyOutfitId = -1,
                });
                //menus.Combat.AddMenuEntry(new AppearanceItemData()
                //{
                //    // "Casual"
                //    SrCenterText = 771301,
                //    ApplyOutfitId = -2,
                //});
                //menus.Combat.AddMenuEntry(new AppearanceItemData()
                //{
                //    // "Combat"
                //    SrCenterText = 163187,
                //    ApplyOutfitId = -3,
                //});

                if (menus.NonArmor != null)
                {
                    // "Armor"
                    menus.Armor.SrSubtitle = 210210233;
                    // "Non Armor"
                    menus.NonArmor.SrSubtitle = 210210234;
                    // the submenus only appear if the "allow armor in casual" setting is on
                    // "Armor"
                    menus.Casual.AddMenuEntry(menus.Armor.GetEntryPoint(210210233, displayInt: (1595, 1)));
                    // "Non Armor"
                    menus.Casual.AddMenuEntry(menus.NonArmor.GetEntryPoint(210210234, displayInt: (1595, 1)));
                    // otherwise the casuals menu appears inline
                    menus.Casual.AddMenuEntry(menus.NonArmor.GetInlineEntryPoint(displayInt: (1595, 0)));

                    // as above, the submenus only appear if the "allow casual in combat" setting is on
                    // "Armor"
                    menus.Combat.AddMenuEntry(menus.Armor.GetEntryPoint(210210233, displayInt: (1594, 1)));
                    // "Non Armor"
                    menus.Combat.AddMenuEntry(menus.NonArmor.GetEntryPoint(210210234, displayInt: (1594, 1)));
                    // otherwise armors appear inline
                    menus.Combat.AddMenuEntry(menus.Armor.GetInlineEntryPoint(displayInt: (1594, 0)));
                }
                else
                {
                    menus.Casual.AddMenuEntry(menus.Armor.GetInlineEntryPoint());
                    menus.Combat.AddMenuEntry(menus.Armor.GetInlineEntryPoint());
                }

                // "Headgear"
                menus.Headgear.SrSubtitle = 210210237;
                menus.Headgear.AddMenuEntry(new AppearanceItemData()
                {
                    // "Default"
                    SrCenterText = 184218,
                    ApplyHelmetId = -1
                });
                //menus.Headgear.AddMenuEntry(new AppearanceItemData()
                //{
                //    // "None"
                //    SrCenterText = 174743,
                //    ApplyHelmetId = -2
                //});
                // TODO this should have visibility rules similar to the button in squad screen based on what helmet will show up, should be a single button to cycle
                menus.Headgear.AddMenuEntry(new AppearanceItemData()
                {
                    // "[1] - [2]"
                    SrCenterText = 210210236,
                    ApplyHelmetPreference = AppearanceItemData.EMenuHelmetOverride.Off,
                    DisplayVars = ["helmet preference", "off"]
                });
                menus.Headgear.AddMenuEntry(new AppearanceItemData()
                {
                    // "[1] - [2]"
                    SrCenterText = 210210236,
                    ApplyHelmetPreference = AppearanceItemData.EMenuHelmetOverride.On,
                    DisplayVars = ["helmet preference", "on"]
                });
                menus.Headgear.AddMenuEntry(new AppearanceItemData()
                {
                    // "[1] - [2]"
                    SrCenterText = 210210236,
                    ApplyHelmetPreference = AppearanceItemData.EMenuHelmetOverride.Full,
                    DisplayVars = ["helmet preference", "full"]
                });

                menus.Headgear.AddMenuEntry(menus.Breather.GetEntryPoint(210210244, hideIfBreatherSuppressed: true));

                // "Breather"
                menus.Breather.SrSubtitle = 210210244;
                menus.Breather.AddMenuEntry(new AppearanceItemData()
                {
                    // "Default"
                    SrCenterText = 184218,
                    ApplyBreatherId = -1
                });

                menus.Breather.AddMenuEntry(new AppearanceItemData()
                {
                    // "None"
                    SrCenterText = 174743,
                    ApplyBreatherId = -2
                });
            }
            SetupMenu("HumanFemale", HumanFemaleOutfitMenus);
            SetupMenu("HumanMale", HumanMaleOutfitMenus);
            SetupMenu("Asari", AsariOutfitMenus);
            SetupMenu("Turian", TurianOutfitMenus);
            SetupMenu("Quarian", QuarianOutfitMenus);
            SetupMenu("Krogan", KroganOutfitMenus);

            void hmfAsaCommon(string bodyType, SpeciesOutfitMenus menus)
            {
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_Misc", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHa", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHb", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHc", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHd", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHe", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHf", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHg", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHh", [bodyType, "NonArmor"]));

                // "Miscellaneous"  (Naked, VI)
                menus.CasualOutfitMenus[0].SrSubtitle = 210210259;
                // TODO this should not show up without opting in
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[0].GetEntryPoint(210210259));

                // "Alliance Formal" CTHa
                menus.CasualOutfitMenus[1].SrSubtitle = 210210257;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[1].GetEntryPoint(210210257));

                // "Fatgiues" CTHb
                menus.CasualOutfitMenus[2].SrSubtitle = 210210262;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[2].GetEntryPoint(210210262));

                // "Science/Medical Uniform"
                menus.CasualOutfitMenus[8].SrSubtitle = 210210258;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[8].GetEntryPoint(210210258));
                
                // "Civilian Outfit 1"
                menus.CasualOutfitMenus[5].SrSubtitle = 210210267;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[5].GetEntryPoint(210210267));

                // "Civilian Outfit 2"
                menus.CasualOutfitMenus[6].SrSubtitle = 210210268;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[6].GetEntryPoint(210210268));

                // "Dress 1"
                menus.CasualOutfitMenus[3].SrSubtitle = 210210264;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[3].GetEntryPoint(210210264));

                // "Dress 2"
                menus.CasualOutfitMenus[4].SrSubtitle = 210210265;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[4].GetEntryPoint(210210265));

                // "Dress 3"
                menus.CasualOutfitMenus[7].SrSubtitle = 210210266;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[7].GetEntryPoint(210210266));
            }
            void hmmCasualMenus(string bodyType, SpeciesOutfitMenus menus)
            {
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_Misc", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHa", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHb", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHc", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHd", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHe", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHf", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHg", [bodyType, "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_NonArmorOutfits_CTHh", [bodyType, "NonArmor"]));

                // "Miscellaneous"  (Naked, VI)
                menus.CasualOutfitMenus[0].SrSubtitle = 210210259;
                // TODO this should not show up without opting in
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[0].GetEntryPoint(210210259));

                // "Alliance Formal" CTHa
                menus.CasualOutfitMenus[1].SrSubtitle = 210210257;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[1].GetEntryPoint(210210257));

                // "Fatgiues" CTHb
                menus.CasualOutfitMenus[2].SrSubtitle = 210210262;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[2].GetEntryPoint(210210262));

                // "Science/Medical Uniform"
                menus.CasualOutfitMenus[8].SrSubtitle = 210210258;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[8].GetEntryPoint(210210258));

                // "Civilian Outfit 1"
                menus.CasualOutfitMenus[5].SrSubtitle = 210210267;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[5].GetEntryPoint(210210267));

                // "Civilian Outfit 2"
                menus.CasualOutfitMenus[6].SrSubtitle = 210210268;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[6].GetEntryPoint(210210268));

                // "Civilian Outfit 3"
                menus.CasualOutfitMenus[4].SrSubtitle = 210210269;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[4].GetEntryPoint(210210269));
                // "Civilian Outfit 4"
                menus.CasualOutfitMenus[7].SrSubtitle = 210210270;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[7].GetEntryPoint(210210270));
                // "Suit"
                menus.CasualOutfitMenus[3].SrSubtitle = 210210263;
                menus.NonArmor!.AddMenuEntry(menus.CasualOutfitMenus[3].GetEntryPoint(210210263));
            }
            void turCasualMenus()
            {
                // the three Turian menus
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"Turian_NonArmorOutfits_CTHa", ["Turian", "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"Turian_NonArmorOutfits_CTHb", ["Turian", "NonArmor"]));
                classes.Add(SquadMemberSubmenus.GetSubmenuClass($"Turian_NonArmorOutfits_CTHc", ["Turian", "NonArmor"]));

                // "Civilian Outfit 1"
                TurianOutfitMenus.CasualOutfitMenus[0].SrSubtitle = 210210267;
                TurianOutfitMenus.NonArmor!.AddMenuEntry(TurianOutfitMenus.CasualOutfitMenus[0].GetEntryPoint(210210267));

                // "Civilian Outfit 2"
                TurianOutfitMenus.CasualOutfitMenus[1].SrSubtitle = 210210268;
                TurianOutfitMenus.NonArmor!.AddMenuEntry(TurianOutfitMenus.CasualOutfitMenus[1].GetEntryPoint(210210268));

                // "Civilian Outfit 3"
                TurianOutfitMenus.CasualOutfitMenus[2].SrSubtitle = 210210269;
                TurianOutfitMenus.NonArmor!.AddMenuEntry(TurianOutfitMenus.CasualOutfitMenus[2].GetEntryPoint(210210269));
            }
            hmfAsaCommon("HumanFemale", HumanFemaleOutfitMenus);
            hmfAsaCommon("Asari", AsariOutfitMenus);
            hmmCasualMenus("HumanMale", HumanMaleOutfitMenus);
            turCasualMenus();
            // the single krogan menu, which is inline and therefore doesn't need subtitle set
            classes.Add(SquadMemberSubmenus.GetSubmenuClass($"Krogan_NonArmorOutfits_CTHa", ["Krogan", "NonArmor"]));
            KroganOutfitMenus.NonArmor!.AddMenuEntry(KroganOutfitMenus.CasualOutfitMenus[0].GetInlineEntryPoint());
        }

        private List<SquadMemberSubmenus> MakeSquadmateSubmenus()
        {
            List<SquadMemberSubmenus> squadMembers = [];

            squadMembers.Add(new SquadMemberSubmenus("FemaleShepard", 210210218, "Player", HumanFemaleOutfitMenus)
            {
                Romanceable = true,
                // true only if player is female
                DisplayConditional = 144
            });
            squadMembers.Add(new SquadMemberSubmenus("MaleShepard", 210210218, "Player", HumanMaleOutfitMenus)
            {
                Romanceable = true,
                // true only if player is male
                DisplayConditional = 143
            });
            squadMembers.Add(new SquadMemberSubmenus("Kaidan", 166121, "Hench_HumanMale", HumanMaleOutfitMenus)
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2500
            });
            squadMembers.Add(new SquadMemberSubmenus("Ashley", 163457, "Hench_HumanFemale", HumanFemaleOutfitMenus)
            {
                Romanceable = true,
                // TODO add this in once I have actually implemented conditionals
                //DisplayConditional = 2501
            });
            squadMembers.Add(new SquadMemberSubmenus("Liara", 172365, "Hench_Asari", AsariOutfitMenus)
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
            squadMembers.Add(new SquadMemberSubmenus("Jenkins", 163868, "Hench_Jenkins", HumanMaleOutfitMenus)
            {
                // this bool will be set to true once Jenkins dies, which will block the menu from showing him from that point forward
                DisplayBool = -3551
            });

            return squadMembers;
        }
    }
}
