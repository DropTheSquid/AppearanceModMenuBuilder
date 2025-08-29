using AppearanceModMenuBuilder.LE1.Models;
using AppearanceModMenuBuilder.LE1.UScriptClasses;
using AppearanceModMenuBuilder.LE1.UScriptStructs;
using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.Models;
using static LegendaryExplorerCore.Unreal.UnrealFlags;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class BuildAuxilliaryMenus : IModBuilderTask
    {
        private readonly List<ClassToCompile> menuClasses = [];
        private readonly List<ClassToCompile> startupClasses = [];

        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building auxiliary submenus");

            var submenuPackageFile = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "AMM_Submenus_Aux.pcc"), context.Game);

            // make an object referencer (probably not strictly necessary? LE1 can dynamic load without this)
            submenuPackageFile.GetOrCreateObjectReferencer();

            menuClasses.AddRange([
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AppearanceSubmenu.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Common.uc", ["Mod_GameContent"]),
                ]);

            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_aliensubmenus.m3cd");

            void SetupOutfits(string bodyType, bool outputMenus = true)
            {
                if (outputMenus)
                {
                    // set up configs for the basic menu classes
                    var Outfits = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus_Aux.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_Outfits", configMergeFile);
                    var Headgear = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus_Aux.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_Headgear", configMergeFile);
                    var Breather = AppearanceSubmenu.GetOrAddSubmenu($"AMM_Submenus_Aux.{bodyType}.{SquadMemberSubmenus.AppearanceSubmenuClassPrefix}{bodyType}_Breather", configMergeFile);

                    // do not check applied through these submenus
                    Headgear.DoNotCheckAppliedInSubmenu = true;
                    Breather.DoNotCheckAppliedInSubmenu = true;

                    // set up the classes:
                    var packageExp = ExportCreator.CreatePackageExport(submenuPackageFile, bodyType);
                    // remove the forced export flag on this package. We need it to be dynamic loadable, including this package name, so it needs to not be forced export
                    packageExp.ExportFlags &= ~EExportFlags.ForcedExport;

                    // make a new class and config type for each thing
                    menuClasses.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_Outfits", [bodyType]));
                    menuClasses.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_Headgear", [bodyType]));
                    menuClasses.Add(SquadMemberSubmenus.GetSubmenuClass($"{bodyType}_Breather", [bodyType]));

                    // add the default entries
                    Outfits.AddMenuEntry(new AppearanceItemData()
                    {
                        Comment = "\"Default outfit\"",
                        SrCenterText = 210210283,
                        ApplyOutfitId = -1,
                    });

                    Headgear.AddMenuEntry(new AppearanceItemData()
                    {
                        // "Default Helmet Matching outfit"
                        SrCenterText = 210210284,
                        ApplyHelmetId = -1,
                        Comment = "always present Default Helmet option"
                    });

                    Breather.AddMenuEntry(new AppearanceItemData()
                    {
                        // "Default Breather"
                        SrCenterText = 210210285,
                        ApplyBreatherId = -1,
                        Comment = "Always present default breather option"
                    });

                    // add the entry points between menus
                    Outfits.AddMenuEntry(Headgear.GetEntryPoint(210210237, hideIfHeadgearSuppressed: true, disableIfHeadgearLocked: true));
                    Headgear.AddMenuEntry(Breather.GetEntryPoint(210210244, hideIfBreatherSuppressed: true, disableIfBreatherLocked: true));

                    // set up the basic traits of each menu
                    Headgear.SrSubtitle = 210210237;
                    Headgear.MenuHelmetOverride = AppearanceItemData.EMenuHelmetOverride.onOrFull;
                }

                // set up the spec lists
                var OutfitSpecClassName = $"{bodyType}_OutfitSpec";
                startupClasses.Add(new ClassToCompile(OutfitSpecClassName, string.Format(OutfitSpecListBuilder.OutfitSpecListClassTemplate, OutfitSpecClassName), [OutfitSpecListBuilder.containingPackage]));
                var HelmetSpecClassName = $"{bodyType}_HelmetSpec";
                startupClasses.Add(new ClassToCompile(HelmetSpecClassName, string.Format(OutfitSpecListBuilder.HelmetSpecListClassTemplate, HelmetSpecClassName), [OutfitSpecListBuilder.containingPackage]));
                var BreatherSpecClassName = $"{bodyType}_BreatherSpec";
                startupClasses.Add(new ClassToCompile(BreatherSpecClassName, string.Format(OutfitSpecListBuilder.BreatherSpecListClassTemplate, BreatherSpecClassName), [OutfitSpecListBuilder.containingPackage]));

                // TODO add the very basics to the spec lists
                var bodyConfig = new ModConfigClass($"{OutfitSpecListBuilder.containingPackage}.{bodyType}_OutfitSpec", "BioGame.ini");
                var helmetConfig =  new ModConfigClass($"{OutfitSpecListBuilder.containingPackage}.{bodyType}_HelmetSpec", "BioGame.ini");
                var breatherConfig =  new ModConfigClass($"{OutfitSpecListBuilder.containingPackage}.{bodyType}_BreatherSpec", "BioGame.ini");

                var specialSpecs = new List<SpecItemBase>
                {
                    new LoadedSpecItem(-1, "Mod_GameContent.DefaultOutfitSpec"),
                    new LoadedSpecItem(0, "Mod_GameContent.DefaultOutfitSpec")
                };
                bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs);

                specialSpecs =
                [
                    new LoadedSpecItem(-1, "Mod_GameContent.DefaultHelmetSpec"),
                    new LoadedSpecItem(0, "Mod_GameContent.DefaultHelmetSpec")
                ];
                helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs);

                specialSpecs = [
                    new LoadedSpecItem(-2, "Mod_GameContent.NoBreatherSpec"),
                    new LoadedSpecItem(-1, "Mod_GameContent.DefaultBreatherSpec"),
                    new LoadedSpecItem(0, "Mod_GameContent.DefaultBreatherSpec")
                ];
                breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs);

                configMergeFile.AddOrMergeClassConfig(bodyConfig);
                configMergeFile.AddOrMergeClassConfig(helmetConfig);
                configMergeFile.AddOrMergeClassConfig(breatherConfig);
            }

            SetupOutfits("Hanar");
            SetupOutfits("Volus");
            SetupOutfits("Elcor");
            SetupOutfits("Misc", false);

            var compileMenuClassesTask = new AddClassesToFile(_ => submenuPackageFile, menuClasses);
            compileMenuClassesTask.RunModTask(context);

            var compileStartupClassesTask = new AddClassesToFile(context => context.GetStartupFile(), startupClasses);
            compileStartupClassesTask.RunModTask(context);
        }
    }
}
