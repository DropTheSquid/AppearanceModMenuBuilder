using AppearanceModMenuBuilder.LE1.Models;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.Models;
using static AppearanceModMenuBuilder.LE1.BuildSteps.DLC.BuildSubmenuFile;
using static AppearanceModMenuBuilder.LE1.Models.AppearanceItemData;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class OutfitSpecListBuilder : IModBuilderTask
    {
        private SpeciesOutfitMenus humanOutfitMenus;
        private SpeciesOutfitMenus turianOutfitMenus;
        private SpeciesOutfitMenus kroganOutfitMenus;
        private SpeciesOutfitMenus quarianOutfitMenus;

        public enum OutfitType
        {
            NKD,
            CTH,
            LGT,
            MED,
            HVY
        }

        private const string OutfitSpecListClassTemplate = "Class {0} extends OutfitSpecListBase config(Game);";
        private const string HelmetSpecListClassTemplate = "Class {0} extends HelmetSpecListBase config(Game);";
        private const string BreatherSpecListClassTemplate = "Class {0} extends BreatherSpecListBase config(Game);";
        private const string ConfigMergeName = "outfits";
        private const string containingPackage = "OutfitSpecs";
        private readonly List<ClassToCompile> classes = [];
        private readonly List<ModConfigClass> configs = [];
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building outfit lists");
            var startup = context.GetStartupFile();

            var submenuConfigMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            (humanOutfitMenus, turianOutfitMenus, quarianOutfitMenus, kroganOutfitMenus) = InitCommonMenus(submenuConfigMergeFile);

            GenerateHMFAndASASpecs();
            GenerateHMMSpecs();
            GenerateTURSpecs();
            GenerateKROSpecs();
            GenerateQRNSpecs();
            // TODO other ones to possibly add:
            // Female Turian, Volus, Salarian, Elcor, Hanar, male Quarian, Vorcha, Drell, Batarian

            var compileClassesTask = new AddClassesToFile(_ => startup, classes);
            compileClassesTask.RunModTask(context);

            var configMergeFile = context.GetOrCreateConfigMergeFile($"ConfigDelta-{ConfigMergeName}.m3cd");
            foreach (var config in configs)
            {
                configMergeFile.AddOrMergeClassConfig(config);
            }
        }

        private void GenerateHMFAndASASpecs()
        {
            /* 
             * Human Females (HMF) and Asari (ASA) are weird in that they share some meshes but not others
             * so for example, all body meshes are shared, with skintone tinting taking care of the blue skin if applicable
             * helmet meshes are NOT shared, as Asari have a longer back to accomodate the tentacles. 
             * So separate helmet meshes, but same breather meshes. 
             * the helmets hide hair if applicable, but not the full head. 
             * when a helmet is worn without a breather, the helmet and visor are visible
             * the breather generally does not suppress the visor, unless overridden for a specific faceplate
             * 
             * additionally, the armor ids for human female and male nearly match, so I am only going to generate the menu entries once in this method
            */

            /*
             * Planned stuff based on previous build
            ; -10 and on are breathers not matched to a specific outfit, which is the vanilla player and squadmate behavior
            +breatherSpecs=(Id=-15, Mesh="BIOG_AMM_HMF_HGR.BRT.HVYa.HMF_BRT_HVYa_MDL", Materials=("BIOG_AMM_HMF_HGR.BRT.HVYa.HMF_BRT_HVYa_MAT_Default"),  suppressVisor=true, comment="NPC faceplate in black.Gray to match any outfit")
            ; TODO port this one to female height
            ; +breatherSpecs=(Id=-14, Mesh="BIOG_AMM_HMM_HGR.BRT.MEDb.HMM_BRTb_MED_MDL", Materials=("BIOG_AMM_HMM_HGR.BRT.MEDb.HMM_BRT_MEDb_Mat_1a", "BIOG_AMM_HMM_HGR.BRT.MEDb.HMM_BRTb_MED_MAT_2a"), suppressVisor=true, comment="Kaidan faceplate")
            +breatherSpecs=(Id=-13, Mesh="BIOG_AMM_HMF_HGR.BRT.LGT.HMF_BRT_LGT_MDL", Materials=("BIOG_AMM_HMF_HGR.BRT.LGT.HMF_HGR_LGTa_BRT_MAT_1a"), comment="Ashley faceplate")
            +breatherSpecs=(Id=-12, Mesh="BIOG_AMM_HMF_HGR.BRT.MED.HMF_BRT_MEDa_MDL", Materials=("BIOG_AMM_HMF_HGR.BRT.MED.HMF_BRT_MEDa_MAT_1a"), comment="Liara faceplate")
            +breatherSpecs=(Id=-11, Mesh="BIOG_AMM_HMF_HGR.BRT.HVYb.HMF_BRT_HVYb_MDL", Materials=("BIOG_AMM_HMF_HGR.BRT.HVYb.HMF_BRT_HVY_MAT_1a"), comment="Shepard faceplate")
            +breatherSpecs=(Id=-10,specPath="AMM_BreatherSpec.NPCFaceplateBreatherSpec", comment="NPC faceplate spec; will look for a helmet with an id matching the armor id and use that if it exists. Otherwise fall back to vanilla faceplate")
            ; 0 to -9 are special cases with specific behavior, reserved and not species specific
            +breatherSpecs=(Id=-3,specPath="AMM_BreatherSpec.DefaultBreatherSpec", comment="determined by pawn params, with fallback to true vanilla if value is invalid")
            +breatherSpecs=(Id=-2,specPath="AMM_BreatherSpec.NoBreatherSpec",      comment="no faceplate (even in no atmosphere)")
            +breatherSpecs=(Id=-1,specPath="AMM_BreatherSpec.VanillaBreatherSpec", comment="same as 0")
            +breatherSpecs=(Id=0, specPath="AMM_BreatherSpec.VanillaBreatherSpec", comment="vanilla behavior, determined by vanilla appearance system, can be overridden by older style mods")
             * Then the positive numbers are id matched NPC full face plates matched to the colors of the armor
             */

            const string bodyType = "HMF";
            const string asariBodyType = "ASA";

            // add the source code needed
            AddSpecListClasses(bodyType);
            AddSpecListClasses(asariBodyType, skipBody: true, skipBreather: true);

            // now generate the configs
            var bodyConfig = GetOutfitListConfig(bodyType);
            var helmetConfig = GetHelmetListConfig(bodyType);
            var asariHelmetConfig = GetHelmetListConfig(asariBodyType);
            var breatherConfig = GetBreatherListConfig(bodyType);

            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation 
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the vanilla appearance
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaOutfitSpec")
            };
            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs =
            [
                // loads the default/casual look, even if they are in combat, ignoring their equipped armor
                new LoadedSpecItem(-5, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are in casual mode
                new LoadedSpecItem(-4, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // load the vanilla appearance, even if overridden by the outfit spec
                new LoadedSpecItem(-3, "Mod_GameContent.VanillaHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs = [
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs.Select(x => x.OutputValue()));

            var LgtArmorFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);
            var MedArmorFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyArmorFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var NkdClothesFileName = GetVanillaArmorFileName(bodyType, OutfitType.NKD);
            var CthClothesFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);
            var LgtHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.LGT);
            var MedHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.MED);
            var HvyHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.HVY);
            var LgtAsariHelmetFileName = GetVanillaHelmetFileName(asariBodyType, OutfitType.LGT);
            var MedAsariHelmetFileName = GetVanillaHelmetFileName(asariBodyType, OutfitType.MED);
            var HvyAsariHelmetFileName = GetVanillaHelmetFileName(asariBodyType, OutfitType.HVY);

            var visorMesh = new AppearanceMeshPaths("BIOG_HMF_HGR_HVY_R.HVYa.HMF_VSR_HVYa_MDL", ["BIOG_HMF_HGR_HVY_R.HVYa.HMF_VSR_HVYa_MAT_1a"]);
            var asariVisorMesh = new AppearanceMeshPaths("BIOG_ASA_HGR_HVY_R.HVYa.ASA_VSR_HVYa_MDL", ["BIOG_ASA_HGR_HVY_R.HVYa.ASA_VSR_HVYa_MAT_1a"]);

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            // LGTa variants; Most Light armor appearances fall under this
            AddVanillaOutfitSpecs(bodyConfig, 1, LgtArmorFileName, OutfitType.LGT, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, LgtHelmetFileName, OutfitType.LGT, 0, bodyType, 16, 1, visorMesh, hideHair: true);
            AddVanillaHelmetSpecs(asariHelmetConfig, 1, LgtAsariHelmetFileName, OutfitType.LGT, 0, asariBodyType, 16, 1, asariVisorMesh, hideHair: true);

            // LGTb; This is the N7 Onyx Armor that Shepard wears
            AddVanillaOutfitSpecs(bodyConfig, 17, LgtArmorFileName, OutfitType.LGT, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 17, LgtHelmetFileName, OutfitType.LGT, 1, bodyType, 1, 1, visorMesh, hideHair: true);
            AddVanillaHelmetSpecs(asariHelmetConfig, 17, LgtAsariHelmetFileName, OutfitType.LGT, 1, asariBodyType, 1, 1, asariVisorMesh, hideHair: true);
            // LGTc; This is the Asari Commando armor, normally not ever used by player characters; only used by NPC Asari
            AddVanillaOutfitSpecs(bodyConfig, 18, LgtArmorFileName, OutfitType.LGT, 2, bodyType, 1, 1, true);
            // manually add this one because there is not actually a corresponding helmet for HMF, using HMF LGTa model and ASA materials
            // TODO test that this looks correct
            helmetConfig.AddArrayEntries(
                "helmetSpecs",
                new SimpleHelmetSpecItem(18, "BIOG_HMF_HGR_LGT_R.LGTa.HMF_HGR_LGTa_MDL", ["BIOG_ASA_HGR_LGT_R.LGTc.ASA_HGR_LGTc_MAT_1a"], visorMesh)
                {
                    HideHair = true
                }.OutputValue());
            AddVanillaHelmetSpecs(asariHelmetConfig, 18, LgtAsariHelmetFileName, OutfitType.LGT, 2, asariBodyType, 1, 1, asariVisorMesh, hideHair: true);

            // add armor entries for both genders in the female one
            AddMenuEntries(humanOutfitMenus.Armor, 1, 17);
            // make this one female only
            AddMenuEntries(humanOutfitMenus.Armor, 18, 1, EGender.Female);

            // MEDa variants; Most Medium armor appearances fall under this
            AddVanillaOutfitSpecs(bodyConfig, 19, MedArmorFileName, OutfitType.MED, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 19, MedHelmetFileName, OutfitType.MED, 0, bodyType, 16, 1, visorMesh, hideHair: true);
            AddVanillaHelmetSpecs(asariHelmetConfig, 19, MedAsariHelmetFileName, OutfitType.MED, 0, asariBodyType, 16, 1, asariVisorMesh, hideHair: true);

            // MEDb; this is the N7 Onyx armor that Shepard wears
            AddVanillaOutfitSpecs(bodyConfig, 35, MedArmorFileName, OutfitType.MED, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 35, MedHelmetFileName, OutfitType.MED, 1, bodyType, 1, 1, visorMesh, hideHair: true);
            AddVanillaHelmetSpecs(asariHelmetConfig, 35, MedAsariHelmetFileName, OutfitType.MED, 1, asariBodyType, 1, 1, asariVisorMesh, hideHair: true);
            // MEDc Asymmetric tintable armor. Not used by any equipment obtainable in vanilla or by any NPCs, but can be accessed using Black Market Licenses/console commands
            AddVanillaOutfitSpecs(bodyConfig, 36, MedArmorFileName, OutfitType.MED, 2, bodyType, 9, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 36, MedHelmetFileName, OutfitType.MED, 2, bodyType, 9, 1, visorMesh, hideHair: true);
            AddVanillaHelmetSpecs(asariHelmetConfig, 36, MedAsariHelmetFileName, OutfitType.MED, 2, asariBodyType, 9, 1, asariVisorMesh);

            // HVYa variants. Most heavy armor falls under this
            AddVanillaOutfitSpecs(bodyConfig, 45, HvyArmorFileName, OutfitType.HVY, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 45, HvyHelmetFileName, OutfitType.HVY, 0, bodyType, 16, 1, visorMesh, hideHair: true);
            AddVanillaHelmetSpecs(asariHelmetConfig, 45, HvyAsariHelmetFileName, OutfitType.HVY, 0, asariBodyType, 16, 1, asariVisorMesh, hideHair: true);
            // HVYb. This is the N7 Onyx Armor Shepard wears
            AddVanillaOutfitSpecs(bodyConfig, 61, HvyArmorFileName, OutfitType.HVY, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 61, HvyHelmetFileName, OutfitType.HVY, 1, bodyType, 1, 1, visorMesh, hideHair: true);
            AddVanillaHelmetSpecs(asariHelmetConfig, 61, HvyAsariHelmetFileName, OutfitType.HVY, 1, asariBodyType, 1, 1, asariVisorMesh, hideHair: true);
            // add the rest of the armor entries
            AddMenuEntries(humanOutfitMenus.Armor, 19, 43);

            // add entries for the non armor outfits
            AddMenuEntries(humanOutfitMenus.NonArmor, 100, 38, EGender.Female);
            // Add NKD and CTH vanilla meshes (100-140)
            // NKDa: material 1 is naked human (with tintable skintone), material 2 is Avina materials on the naked mesh
            AddVanillaOutfitSpecs(bodyConfig, 100, NkdClothesFileName, OutfitType.NKD, 0, bodyType, 2, 1);
            // NKDb: dancer outfit with tintable skintone
            AddVanillaOutfitSpecs(bodyConfig, 102, NkdClothesFileName, OutfitType.NKD, 1, bodyType, 1, 1);
            // NKDc: Liara romance mesh, not sure it is tintable
            AddVanillaOutfitSpecs(bodyConfig, 103, NkdClothesFileName, OutfitType.NKD, 2, bodyType, 1, 1);

            // CTHa Alliance Formal
            AddVanillaOutfitSpecs(bodyConfig, 104, CthClothesFileName, OutfitType.CTH, 0, bodyType, 6, 1);
            // CTHb Alliance Fatigues and related, such as C Sec color variant
            AddVanillaOutfitSpecs(bodyConfig, 110, CthClothesFileName, OutfitType.CTH, 1, bodyType, 5, 1);
            // CTHc dress used by many NPCs, except variant 6 (id 120) is the Mira VI material
            AddVanillaOutfitSpecs(bodyConfig, 115, CthClothesFileName, OutfitType.CTH, 2, bodyType, 6, 1);
            // CTHd different dress worn by many NPCs
            AddVanillaOutfitSpecs(bodyConfig, 121, CthClothesFileName, OutfitType.CTH, 3, bodyType, 3, 1);
            // CTHe civilian clothes 1
            AddVanillaOutfitSpecs(bodyConfig, 124, CthClothesFileName, OutfitType.CTH, 4, bodyType, 2, 1);
            // CTHf civilian clothes 2
            AddVanillaOutfitSpecs(bodyConfig, 126, CthClothesFileName, OutfitType.CTH, 5, bodyType, 4, 1);
            // CTHg a third dress worn by NPCs
            AddVanillaOutfitSpecs(bodyConfig, 130, CthClothesFileName, OutfitType.CTH, 6, bodyType, 1, 1);
            // CTHh Scientist/medic uniform worn by many NPCs
            AddVanillaOutfitSpecs(bodyConfig, 131, CthClothesFileName, OutfitType.CTH, 7, bodyType, 7, 1);

            // TODO extended Vanilla specs, add them into menus

            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(asariHelmetConfig);
            configs.Add(breatherConfig);
        }

        private void GenerateHMMSpecs()
        {
            /*
             * Human males are nearly the same rules as human females, but without the Asari complication. 
             */
            const string bodyType = "HMM";

            // add the source code needed
            AddSpecListClasses(bodyType);

            // now generate the configs
            var bodyConfig = GetOutfitListConfig(bodyType);
            var helmetConfig = GetHelmetListConfig(bodyType);
            var breatherConfig = GetBreatherListConfig(bodyType);

            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation 
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the vanilla appearance
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaOutfitSpec")
            };
            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs =
            [
                // loads the default/casual look, even if they are in combat, ignoring their equipped armor
                new LoadedSpecItem(-5, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are in casual mode
                new LoadedSpecItem(-4, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // load the vanilla appearance, even if overridden by the outfit spec
                new LoadedSpecItem(-3, "Mod_GameContent.VanillaHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs = [
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs.Select(x => x.OutputValue()));

            var LgtFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);
            var MedFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var NkdFileName = GetVanillaArmorFileName(bodyType, OutfitType.NKD);
            var CthFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);
            var LgtHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.LGT);
            var MedHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.MED);
            var HvyHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.HVY);

            var visorMesh = new AppearanceMeshPaths("BIOG_HMM_HGR_HVY_R.HVYa.HMM_VSR_HVYa_MDL", ["BIOG_HMM_HGR_HVY_R.HVYa.HMM_VSR_HVYa_MAT_1a"]);

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61); matches HMF ids
            // LGTa variants
            AddVanillaOutfitSpecs(bodyConfig, 1, LgtFileName, OutfitType.LGT, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, LgtHelmetFileName, OutfitType.LGT, 0, bodyType, 16, 1, visorMesh, hideHair: true);

            // LGTb: Shepard's Onyx armor with N7 logo
            AddVanillaOutfitSpecs(bodyConfig, 17, LgtFileName, OutfitType.LGT, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 7, LgtHelmetFileName, OutfitType.LGT, 1, bodyType, 1, 1, visorMesh, hideHair: true);
            // Note that there is no LGTc for HMM, and I am intentionally skipping id 18

            // MEDa variants
            AddVanillaOutfitSpecs(bodyConfig, 19, MedFileName, OutfitType.MED, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 19, MedHelmetFileName, OutfitType.MED, 0, bodyType, 16, 1, visorMesh, hideHair: true);

            // MEDb: Shep's N7 Onyx Armor
            AddVanillaOutfitSpecs(bodyConfig, 35, MedFileName, OutfitType.MED, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 35, MedHelmetFileName, OutfitType.MED, 1, bodyType, 1, 1, visorMesh, hideHair: true);

            // MEDc: Assymmetric tintable armor. never used by NPCs, only usable by player using console commands or Black Market License
            AddVanillaOutfitSpecs(bodyConfig, 36, MedFileName, OutfitType.MED, 2, bodyType, 9, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 36, MedHelmetFileName, OutfitType.MED, 2, bodyType, 9, 1, visorMesh, hideHair: true);


            // HVYa variants
            AddVanillaOutfitSpecs(bodyConfig, 45, HvyFileName, OutfitType.HVY, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 45, HvyHelmetFileName, OutfitType.HVY, 0, bodyType, 16, 1, visorMesh, hideHair: true);

            // HVYb: Shep's N7 Onyx armor
            AddVanillaOutfitSpecs(bodyConfig, 61, HvyFileName, OutfitType.HVY, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 61, HvyHelmetFileName, OutfitType.HVY, 1, bodyType, 1, 1, visorMesh, hideHair: true);

            // add all the non armor outfits for male humans to the menu
            AddMenuEntries(humanOutfitMenus.NonArmor, 100, 31, EGender.Male);

            // Add NKD and CTH vanilla meshes (100-130)
            // NKDa: material 1 is tintable naked human, material 2 is a VI material
            AddVanillaOutfitSpecs(bodyConfig, 100, NkdFileName, OutfitType.NKD, 0, bodyType, 2, 1);

            // CTHa Alliance formal
            // TODO there is a missing material: it only has 1 2 3 5, no 4
            AddVanillaOutfitSpecs(bodyConfig, 102, CthFileName, OutfitType.CTH, 0, bodyType, 5, 1);
            // CTHb Alliance Fatigues and related outfits
            AddVanillaOutfitSpecs(bodyConfig, 107, CthFileName, OutfitType.CTH, 1, bodyType, 6, 1);
            // CTHc-CTHg, various civilian clothes, except 117 is the ExoGeni VI
            AddVanillaOutfitSpecs(bodyConfig, 113, CthFileName, OutfitType.CTH, 2, bodyType, 5, 1);
            AddVanillaOutfitSpecs(bodyConfig, 118, CthFileName, OutfitType.CTH, 3, bodyType, 3, 1);
            AddVanillaOutfitSpecs(bodyConfig, 121, CthFileName, OutfitType.CTH, 4, bodyType, 3, 1);
            AddVanillaOutfitSpecs(bodyConfig, 124, CthFileName, OutfitType.CTH, 5, bodyType, 3, 1);
            AddVanillaOutfitSpecs(bodyConfig, 127, CthFileName, OutfitType.CTH, 6, bodyType, 2, 1);
            // CTHh: scientist.medical uniform
            AddVanillaOutfitSpecs(bodyConfig, 129, CthFileName, OutfitType.CTH, 7, bodyType, 2, 1);

            // TODO add extended vanilla meshes

            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(breatherConfig);
        }

        private void GenerateKROSpecs()
        {
            /*
             * Krogan helmets are a bit different from human/Asari
             * there is no separate visor mesh or faceplate/breather mesh in vanilla.
             * All vanilla Krogan helmets hide the head.
             */
            const string bodyType = "KRO";

            // add the source code needed
            AddSpecListClasses(bodyType);

            // now generate the configs
            var bodyConfig = GetOutfitListConfig(bodyType);
            var helmetConfig = GetHelmetListConfig(bodyType);
            var breatherConfig = GetBreatherListConfig(bodyType);

            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation 
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the vanilla appearance
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaOutfitSpec")
            };

            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs =
            [
                // loads the default/casual look, even if they are in combat, ignoring their equipped armor
                new LoadedSpecItem(-5, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are in casual mode
                new LoadedSpecItem(-4, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // load the vanilla appearance, even if overridden by the outfit spec
                new LoadedSpecItem(-3, "Mod_GameContent.VanillaHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs = [
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs.Select(x => x.OutputValue()));

            var MedFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var CthFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);
            var MedHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.MED);
            var HvyHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.HVY);

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            // MEDa variants. There are not light Korgan armor meshes, and no other medium variants
            AddVanillaOutfitSpecs(bodyConfig, 1, MedFileName, OutfitType.MED, 0, bodyType, 11, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, MedHelmetFileName, OutfitType.MED, 0, bodyType, 11, 1, suppressBreather: true, hideHead: true);

            // Heavy armor variants
            AddVanillaOutfitSpecs(bodyConfig, 12, HvyFileName, OutfitType.HVY, 0, bodyType, 12, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 12, MedHelmetFileName, OutfitType.MED, 0, bodyType, 12, 1, suppressBreather: true, hideHead: true);
            AddVanillaOutfitSpecs(bodyConfig, 24, HvyFileName, OutfitType.HVY, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 24, MedHelmetFileName, OutfitType.MED, 1, bodyType, 1, 1, suppressBreather: true, hideHead: true);
            // this is the fun glowy ones
            AddVanillaOutfitSpecs(bodyConfig, 25, HvyFileName, OutfitType.HVY, 2, bodyType, 3, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 25, MedHelmetFileName, OutfitType.MED, 2, bodyType, 3, 1, suppressBreather: true, hideHead: true);

            // Add CTH vanilla meshes (100-105)
            // Krogan casuals only get one mesh in vanilla, sad.
            AddVanillaOutfitSpecs(bodyConfig, 100, CthFileName, OutfitType.CTH, 0, bodyType, 5, 1);

            // add all the outfits for krogans to the menu
            AddMenuEntries(kroganOutfitMenus.Armor, 1, 27);
            AddMenuEntries(kroganOutfitMenus.NonArmor, 100, 5);

            // TODO add extended vanilla meshes
            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(breatherConfig);

        }

        private void GenerateTURSpecs()
        {
            /*
             * Turian helmets are a bit weird also.
             * For light and heavy armor:
             * There is a visor mesh, but it is only used when the breather is on, unlike human where the visor is always on unless suppressed by the faceplate
             * as there is a transparent portion, it never hides the head.
             * it does, however, hide the "hair" which includes Garrus' eyepiece
             * 
             * medium armor, the regular helmet hides the entire head and suppresses the visor and breather
             */
            const string bodyType = "TUR";

            // add the source code needed
            AddSpecListClasses(bodyType);

            // now generate the configs
            var bodyConfig = GetOutfitListConfig(bodyType);
            var helmetConfig = GetHelmetListConfig(bodyType);
            var breatherConfig = GetBreatherListConfig(bodyType);


            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation 
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the vanilla appearance
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaOutfitSpec")
            };

            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs =
            [
                // loads the default/casual look, even if they are in combat, ignoring their equipped armor
                new LoadedSpecItem(-5, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are in casual mode
                new LoadedSpecItem(-4, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // load the vanilla appearance, even if overridden by the outfit spec
                new LoadedSpecItem(-3, "Mod_GameContent.VanillaHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs.Select(x => x.OutputValue()));

            specialSpecs = [
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs.Select(x => x.OutputValue()));

            var LgtFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);
            var MedFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var CthFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);
            var LgtHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.LGT);
            var MedHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.MED);
            var HvyHelmetFileName = GetVanillaHelmetFileName(bodyType, OutfitType.HVY);

            //var visorMesh = new AppearanceMeshPaths("BIOG_TUR_HGR_HVY_R.HVYa.TUR_HGR_VSRa_MDL", ["BIOG_TUR_HGR_HVY_R.HVYa.TUR_VSR_HVYa_MAT_1a"]);

            // add all vanilla armor variants into positive IDs less than 100
            // LGTa
            AddVanillaOutfitSpecs(bodyConfig, 1, LgtFileName, OutfitType.LGT, 0, bodyType, 15, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, LgtHelmetFileName, OutfitType.LGT, 0, bodyType, 15, 1, hideHair: true);

            // LGTb
            AddVanillaOutfitSpecs(bodyConfig, 16, LgtFileName, OutfitType.LGT, 1, bodyType, 3, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 6, LgtHelmetFileName, OutfitType.LGT, 1, bodyType, 3, 1, hideHair: true);

            // MEDa
            AddVanillaOutfitSpecs(bodyConfig, 19, MedFileName, OutfitType.MED, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 19, MedHelmetFileName, OutfitType.MED, 0, bodyType, 16, 1, hideHead: true, suppressBreather: true);

            // HVYa
            AddVanillaOutfitSpecs(bodyConfig, 35, HvyFileName, OutfitType.HVY, 0, bodyType, 15, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 35, HvyHelmetFileName, OutfitType.HVY, 0, bodyType, 15, 1, hideHair: true);

            // Add CTH vanilla meshes (100+)
            // CTHa
            AddVanillaOutfitSpecs(bodyConfig, 100, CthFileName, OutfitType.CTH, 0, bodyType, 5, 1);
            // CTHb
            AddVanillaOutfitSpecs(bodyConfig, 105, CthFileName, OutfitType.CTH, 1, bodyType, 4, 1);
            // CTHc
            AddVanillaOutfitSpecs(bodyConfig, 109, CthFileName, OutfitType.CTH, 2, bodyType, 5, 1);

            // add all the outfits for Turians to the menu
            AddMenuEntries(turianOutfitMenus.Armor, 1, 49);
            AddMenuEntries(turianOutfitMenus.NonArmor, 100, 14);

            // TODO add extended vanilla meshes
            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(breatherConfig);
        }

        private void GenerateQRNSpecs()
        {
            /*
             * Quarians (meaning just Tali in LE1) are extra weird. There is no separate head mesh from the body mesh, no helmet meshes, and no breather meshes
             * it is just the body mesh in all circumstances in vanilla
             * note that some mods add a "helmet" mesh that includes a metal plate covering part of the suit visor glass
             * Children of Rannoch is the one I know of.
             * So I want to build support to extend this if folks want to make things for this. 
             */
            const string bodyType = "QRN";

            // add the source code needed
            AddSpecListClasses(bodyType);

            // now generate the configs
            var config = GetOutfitListConfig(bodyType);

            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation 
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the vanilla appearance
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaOutfitSpec")
            };

            config.AddArrayEntries("outfitSpecs", specialSpecs.Select(x => x.OutputValue()));

            var LgtFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);

            // add all vanilla armor variants into positive IDs less than 100
            // Tali is the only vanilla Quarian, and she only has 6 color/texture variants of the same LGTa mesh
            AddVanillaOutfitSpecs(config, 1, LgtFileName, OutfitType.LGT, 0, "QRN_FAC", 6, 2);
            // TODO add some theoretical helmet support

            // add all the outfits for Turians to the menu
            AddMenuEntries(quarianOutfitMenus.Armor, 1, 6);

            configs.Add(config);
        }


        private static void AddVanillaOutfitSpecs(
            ModConfigClass configToAddTo,
            int startingId,
            string packagePrefix,
            OutfitType type,
            int meshVariant,
            string bodyTypePrefix,
            int modelVariants,
            int materialsPerVariant,
            bool matchingHelmetSpec = false)
        {
            SimpleOutfitSpecItem[] specs = new SimpleOutfitSpecItem[modelVariants];

            for (int i = 0; i < modelVariants; i++)
            {
                var id = startingId + i;
                // eg LGTa
                var meshVariantString = type.ToString() + CharFromInt(meshVariant);

                // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa
                var sharedPrefix = $"{packagePrefix}.{meshVariantString}.{bodyTypePrefix}_ARM_{meshVariantString}";

                // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa_MDL
                var mesh = $"{sharedPrefix}_MDL";
                string[] materials = new string[materialsPerVariant];
                for (int j = 0; j < materialsPerVariant; j++)
                {
                    // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa_MAT_1a
                    // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa_MAT_1b
                    // where 1 is the variant (1 based, not 0 based), and a/b is the material number within the variant
                    materials[j] = $"{sharedPrefix}_Mat_{i + 1}{CharFromInt(j)}";
                }

                specs[i] = new SimpleOutfitSpecItem(id, mesh, materials)
                {
                    // either a spec with the same id or -2 (no helmet) as the default
                    HelmetSpec = matchingHelmetSpec ? id : -2
                };

            }

            configToAddTo.AddArrayEntries("outfitSpecs", specs.Select(x => x.OutputValue()));
        }

        private static void AddVanillaHelmetSpecs(
            ModConfigClass configToAddTo,
            int startingId,
            string packagePrefix,
            OutfitType type,
            int meshVariant,
            string bodyTypePrefix,
            int modelVariants,
            int materialsPerVariant,
            AppearanceMeshPaths? visorMesh = null,
            bool? hideHair = null,
            bool? hideHead = null,
            bool? suppressVisor = null,
            bool? suppressBreather = null)
        {
            SimpleHelmetSpecItem[] specs = new SimpleHelmetSpecItem[modelVariants];
            if (visorMesh == null)
            {
                suppressVisor = true;
            }

            for (int i = 0; i < modelVariants; i++)
            {
                var id = startingId + i;
                // eg LGTa
                var meshVariantString = type.ToString() + CharFromInt(meshVariant);

                // eg BIOG_HMM_HGR_HVY_R.HVYa.HMM_HGR_HVYa
                var sharedPrefix = $"{packagePrefix}.{meshVariantString}.{bodyTypePrefix}_HGR_{meshVariantString}";

                // eg BIOG_HMM_HGR_HVY_R.HVYa.HMM_HGR_HVYa_MDL
                var mesh = $"{sharedPrefix}_MDL";
                string[] materials = new string[materialsPerVariant];
                for (int j = 0; j < materialsPerVariant; j++)
                {
                    // eg BIOG_HMM_HGR_HVY_R.HVYa.HMM_HGR_HVYa_MAT_1a
                    // where 1 is the variant (1 based, not 0 based), and a/b is the material number within the variant
                    materials[j] = $"{sharedPrefix}_Mat_{i + 1}{CharFromInt(j)}";
                }

                specs[i] = new SimpleHelmetSpecItem(id, mesh, materials, visorMesh)
                {
                    HideHair = hideHair,
                    HideHead = hideHead,
                    SuppressVisor = suppressVisor,
                    SuppressBreather = suppressBreather
                };
            }

            configToAddTo.AddArrayEntries("helmetSpecs", specs.Select(x => x.OutputValue()));
        }

        private static void AddMenuEntries(AppearanceSubmenu submenu, int startingId, int count, EGender? gender = null)
        {
            for (int i = startingId; i < startingId + count; i++)
            {
                submenu.AddMenuEntry(new AppearanceItemData()
                {
                    // "Outfit <0>"
                    SrCenterText = 210210235,
                    ApplyOutfitId = i,
                    DisplayVars = [i.ToString()],
                    Gender = gender
                });
            }
        }

        private static char CharFromInt(int value)
        {
            if (value < 0 || value > 25)
            {
                throw new IndexOutOfRangeException();
            }
            return (char)(value + 'a');
        }

        private void AddSpecListClasses(string bodyType, bool skipBody = false, bool skipHelmet = false, bool skipBreather = false)
        {
            if (!skipBody)
            {
                var OutfitSpecClassName = $"{bodyType}_OutfitSpec";
                classes.Add(new ClassToCompile(OutfitSpecClassName, string.Format(OutfitSpecListClassTemplate, OutfitSpecClassName), [containingPackage]));
            }
            if (!skipHelmet)
            {
                var HelmetSpecClassName = $"{bodyType}_HelmetSpec";
                classes.Add(new ClassToCompile(HelmetSpecClassName, string.Format(HelmetSpecListClassTemplate, HelmetSpecClassName), [containingPackage]));
            }
            if (!skipBreather)
            {
                var BreatherSpecClassName = $"{bodyType}_BreatherSpec";
                classes.Add(new ClassToCompile(BreatherSpecClassName, string.Format(BreatherSpecListClassTemplate, BreatherSpecClassName), [containingPackage]));

            }
            // TODO breather spec lists
        }

        private static ModConfigClass GetOutfitListConfig(string bodyType)
        {
            return new ModConfigClass($"{containingPackage}.{bodyType}_OutfitSpec", "BioGame.ini");
        }

        private static ModConfigClass GetHelmetListConfig(string bodyType)
        {
            return new ModConfigClass($"{containingPackage}.{bodyType}_HelmetSpec", "BioGame.ini");
        }

        private static ModConfigClass GetBreatherListConfig(string bodyType)
        {
            return new ModConfigClass($"{containingPackage}.{bodyType}_BreatherSpec", "BioGame.ini");
        }

        private static string GetVanillaArmorFileName(string bodyType, OutfitType outfitType)
        {
            return $"BIOG_{bodyType}_ARM_{outfitType}_R";
        }

        private static string GetVanillaHelmetFileName(string bodyType, OutfitType outfitType)
        {
            return $"BIOG_{bodyType}_HGR_{outfitType}_R";
        }
    }
}
