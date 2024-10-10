﻿using AppearanceModMenuBuilder.LE1.Models;
using AppearanceModMenuBuilder.LE1.UScriptModels;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.Models;
using static AppearanceModMenuBuilder.LE1.BuildSteps.DLC.BuildSubmenuFile;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class OutfitSpecListBuilder : IModBuilderTask
    {
        private SpeciesOutfitMenus humanFemaleOutfitMenus;
        private SpeciesOutfitMenus humanMaleOutfitMenus;
        private SpeciesOutfitMenus asariOutfitMenus;
        private SpeciesOutfitMenus turianOutfitMenus;
        private SpeciesOutfitMenus kroganOutfitMenus;
        private SpeciesOutfitMenus salarianOutfitMenus;

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

            (humanFemaleOutfitMenus, humanMaleOutfitMenus, asariOutfitMenus, turianOutfitMenus, _, kroganOutfitMenus, salarianOutfitMenus) = InitCommonMenus(submenuConfigMergeFile);

            GenerateHMFSpecs();
            GenerateASASpecs();
            GenerateHMMSpecs();
            GenerateTURSpecs();
            GenerateKROSpecs();
            GenerateQRNSpecs();
            GenerateSALSpecs();
            // TODO other ones to possibly add:
            // Female Turian, Volus, Elcor, Hanar, male Quarian, Vorcha, Drell, Batarian

            var compileClassesTask = new AddClassesToFile(_ => startup, classes);
            compileClassesTask.RunModTask(context);

            var configMergeFile = context.GetOrCreateConfigMergeFile($"ConfigDelta-{ConfigMergeName}.m3cd");
            foreach (var config in configs)
            {
                configMergeFile.AddOrMergeClassConfig(config);
            }
        }

        private void GenerateHMFSpecs()
        {
            /* 
             * Human Females (HMF) and Asari (ASA) are weird in that they share some meshes but not others
             * so for example, all vanilla body meshes are shared, with skintone tinting taking care of the blue skin if applicable
             * helmet meshes are NOT shared, as Asari have a longer back of the helmet to accomodate the tentacles.
             * So separate helmet meshes, but same breather meshes. 
             * Since there may be modded outfits that fit one head but not the other, we need to have them in separate lists.
             * the helmets hide hair if applicable, but not the full head. 
             * when a helmet is worn without a breather, the helmet and visor are visible
             * the breather generally does not suppress the visor, unless overridden for a specific faceplate
             * 
             * additionally, the armor ids for human female and male nearly match, so I am only going to generate the menu entries once in this method
            */
            const string bodyType = "HMF";
            var visorMesh = new AppearanceMeshPaths("BIOG_HMF_HGR_AMM.VSR.HMF_VSR_MDL", ["BIOG_HMF_HGR_AMM.VSR.HMF_VSR_MAT_1a"]);

            var breatherSpecs = new List<SpecItemBase> {
                // clear, smooth
                new SimpleBreatherSpecItem(-23, "HMN_Faceplate_AMM.HMF.HMF_VSR_FULL_MDL", ["HMN_Faceplate_AMM.HMN.HMN_VSR_FULL_MAT"])
                {
                    SuppressVisor = true,
                },
                //// clear with sides, with jaws
                //new SimpleBreatherSpecItem(-22, "BIOG_HMF_BRT_AMM.Custom.HMF_BRT_NPC_Separate_Materials_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},
                // reinforced faceplate (sides and corners from NPC plate, glass from clear)
                new SimpleBreatherSpecItem(-21, "HMN_Faceplate_AMM.HMF.HMF_VSR_FULL_REINFORCED_MDL", ["HMN_Faceplate_AMM.HMN.HMN_VSR_FULL_MAT", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                },
                //// for the sake of completeness, the full face plate with the jaw bits
                //new SimpleBreatherSpecItem(-20, "BIOG_HMF_BRT_AMM.Custom.HMF_BRT_NPC_JAW_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    VisorMeshOverride = new AppearanceMeshPaths("BIOG_HMF_BRT_AMM.Custom.HMF_VSR_FULL_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR"]),
                //},
                //// NPC faceplate without jaw, with transparent center bit
                //new SimpleBreatherSpecItem(-19, "BIOG_HMF_BRT_AMM.Custom.HMF_BRT_NPC_NO_JAW_BACK_FACES_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},
                //// like above, but with the jaw included
                //new SimpleBreatherSpecItem(-18, "BIOG_HMF_BRT_AMM.Custom.HMF_BRT_NPC_BACK_FACES_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},

                ////; -10 and on are breathers not matched to a specific outfit, which is the vanilla player and squadmate behavior
                //// -17 is a full glass faceplate, derived from the NPC plate
                //new SimpleBreatherSpecItem(-17, "BIOG_HMF_BRT_AMM.Custom.HMF_VSR_FULL_MDL", ["BIOG_HMF_BRT_AMM.Custom.HMF_VSR_FULL_MAT_CLEAR"])
                //{
                //    SuppressVisor = true,
                //},
                // -15 is the NPC faceplate with generic colors and without the jaw bits
                new SimpleBreatherSpecItem(-17, "HMN_Faceplate_AMM.HMF.HMF_BRT_FACEPLATE_Min_MDL", ["HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                    HideHead = true
                },
                // -15 is the NPC faceplate with generic colors
                new SimpleBreatherSpecItem(-15, "HMN_Faceplate_AMM.HMF.HMF_BRT_FACEPLATE_MDL", ["HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                    HideHead = true
                },
                // -14 is Kaidan's faceplate (ported a bit from LE2)
                new SimpleBreatherSpecItem(-14, "BIOG_HMF_BRT_AMM.Kaidan.HMF_BRT_Kaidan_MDL", ["BIOG_HMF_BRT_AMM.Kaidan.HMM_BRT_Kaidan_Mat_1a", "BIOG_HMF_BRT_AMM.Kaidan.HMM_BRT_Kaidan_Mat_2a"])
                {
                    // with a new mesh for blocking the eyes and/or the texture details on the mesh that are visible
                    VisorMeshOverride = new AppearanceMeshPaths("BIOG_HMF_BRT_AMM.Kaidan.hmf_eye_blocker", ["BIOG_HMF_BRT_AMM.Kaidan.Eye_Blocker_mat"]),
                    HideHead = true
                },
                 // -13 is Ashley's default faceplate
                new SimpleBreatherSpecItem(-13, "BIOG_HMF_BRT_AMM.Ashley.HMF_BRT_Ashley_MDL", ["BIOG_HMF_BRT_AMM.Ashley.HMF_BRT_Ashley_MAT_1a"]),
                // -11 is Shepard's
                new SimpleBreatherSpecItem(-11, "BIOG_HMF_BRT_AMM.Shepard.HMF_BRT_Shepard_MDL", ["BIOG_HMF_BRT_AMM.Shepard.HMF_BRT_Shepard_MAT_1a"]),
            };

            HmfAsaCommon(bodyType, bodyType, visorMesh, humanFemaleOutfitMenus, breatherSpecs);
        }

        private void GenerateASASpecs()
        {
            const string bodyType = "HMF";
            const string helmetType = "ASA";
            var visorMesh = new AppearanceMeshPaths("BIOG_ASA_HGR_AMM.VSR.ASA_VSR_MDL", ["BIOG_ASA_HGR_AMM.VSR.ASA_VSR_MAT_1a"]);

            var breatherSpecs = new List<SpecItemBase> {
                // clear, smooth
                new SimpleBreatherSpecItem(-23, "HMN_Faceplate_AMM.ASA.ASA_VSR_FULL_MDL", ["HMN_Faceplate_AMM.HMN.HMN_VSR_FULL_MAT"])
                {
                    SuppressVisor = true,
                },
                //// clear with sides, with jaws
                //new SimpleBreatherSpecItem(-22, "BIOG_ASA_HGR_AMM.BRT.Custom.ASA_BRT_NPC_Separate_Materials_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},
                // reinforced faceplate (sides and corners from NPC plate, glass from clear)
                new SimpleBreatherSpecItem(-21, "HMN_Faceplate_AMM.ASA.ASA_VSR_FULL_REINFORCED_MDL", ["HMN_Faceplate_AMM.HMN.HMN_VSR_FULL_MAT", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                },
                // // for the sake of completeness, the full face plate with the jaw bits
                //new SimpleBreatherSpecItem(-20, "BIOG_ASA_HGR_AMM.BRT.Custom.ASA_BRT_NPC_JAW_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    VisorMeshOverride = new AppearanceMeshPaths("BIOG_ASA_HGR_AMM.BRT.Custom.ASA_VSR_FULL_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR"]),
                //},
                //// NPC faceplate without jaw, with transparent center bit
                //new SimpleBreatherSpecItem(-19, "BIOG_ASA_HGR_AMM.BRT.Custom.ASA_BRT_NPC_NO_JAW_BACK_FACES_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},
                //// like above, but with the jaw included
                //new SimpleBreatherSpecItem(-18, "BIOG_ASA_HGR_AMM.BRT.Custom.ASA_BRT_NPC_BACK_FACES_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},

                ////; -10 and on are breathers not matched to a specific outfit, which is the vanilla player and squadmate behavior
                //// -18 is a kitbash of my full clear plate with Shepard's breather
                new SimpleBreatherSpecItem(-18, "BIOG_ASA_HGR_AMM.BRT.Shepard.ASA_Shep_Clear", ["BIOG_HMF_BRT_AMM.Shepard.HMF_BRT_Shepard_MAT_1a", "HMN_Faceplate_AMM.HMN.HMN_VSR_FULL_MAT"])
                {
                    SuppressVisor = true,
                },
                // -17 is the NPC faceplate with generic colors and without the jaw bits
                new SimpleBreatherSpecItem(-17, "HMN_Faceplate_AMM.ASA.ASA_BRT_FACEPLATE_Min_MDL", ["HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                    HideHead = true
                },
                // -15 is the NPC faceplate with generic colors
                new SimpleBreatherSpecItem(-15, "HMN_Faceplate_AMM.ASA.ASA_BRT_FACEPLATE_MDL", ["HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                    HideHead = true
                },

                 // -13 is Ashley's default faceplate
                new SimpleBreatherSpecItem(-13, "BIOG_ASA_HGR_AMM.BRT.Ashley.ASA_BRT_Ashley_MDL", ["BIOG_HMF_BRT_AMM.Ashley.HMF_BRT_Ashley_MAT_1a"]),

                
                
                //// -15 is the NPC faceplate with generic colors
                //new SimpleBreatherSpecItem(-15, "BIOG_ASA_HGR_AMM.BRT.Custom.ASA_BRT_NPC_Separate_Materials_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //    HideHead = true
                //},

                // -14 is Kaidan's faceplate (ported a bit from LE2)
                new SimpleBreatherSpecItem(-14, "BIOG_ASA_HGR_AMM.BRT.Kaidan.ASA_BRT_Kaidan_MDL", ["BIOG_HMF_BRT_AMM.Kaidan.HMM_BRT_Kaidan_Mat_1a", "BIOG_HMF_BRT_AMM.Kaidan.HMM_BRT_Kaidan_Mat_2a"])
                {
                    // with a new mesh for blocking the eyes and/or the texture details on the mesh that are visible
                    VisorMeshOverride = new AppearanceMeshPaths("BIOG_HMF_BRT_AMM.Kaidan.hmf_eye_blocker", ["BIOG_HMF_BRT_AMM.Kaidan.Eye_Blocker_mat"]),
                    HideHead = true
                },
                // -11 is Shepard's
                new SimpleBreatherSpecItem(-11, "BIOG_ASA_HGR_AMM.BRT.Shepard.ASA_BRT_Shepard_MDL", ["BIOG_HMF_BRT_AMM.Shepard.HMF_BRT_Shepard_MAT_1a"]),
            };

            HmfAsaCommon(bodyType, helmetType, visorMesh, asariOutfitMenus, breatherSpecs);
        }

        private void HmfAsaCommon(string bodyType, string helmetType, AppearanceMeshPaths visorMesh, SpeciesOutfitMenus speciesMenus, IEnumerable<SpecItemBase> breatherSpecs)
        {
            // add the source code needed
            AddSpecListClasses(helmetType);
            // now generate the configs
            var bodyConfig = GetOutfitListConfig(helmetType);
            var helmetConfig = GetHelmetListConfig(helmetType);
            var breatherConfig = GetBreatherListConfig(helmetType);

            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                 // loads the vanilla appearance, even if this is a squadmate with different equipped armor
                new LoadedSpecItem(-4, "Mod_GameContent.VanillaOutfitSpec"),
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the default appearance, which might go to equipped armor depending on mod settings
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultOutfitSpec")
            };
            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs);

            specialSpecs =
            [
                 // loads the equipped armor look, even if they are in casual mode or outside of the squad
                new LoadedSpecItem(-3, "Mod_GameContent.EquippedArmorHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs);

            specialSpecs = [
                ..breatherSpecs,
                // -16 is Liara's (light variant with textures from unused model)
                new SimpleBreatherSpecItem(-16, "BIOG_HMF_BRT_AMM.Liara.HMF_BRT_Liara_MDL", ["BIOG_HMM_BRT_AMM.Liara.HMM_BRT_Liara_MAT_2a"]),
                // -12 is Liara's
                new SimpleBreatherSpecItem(-12, "BIOG_HMF_BRT_AMM.Liara.HMF_BRT_Liara_MDL", ["BIOG_HMF_BRT_AMM.Liara.HMF_BRT_Liara_MAT_1a"]),
                // TODO a special loaded spec for the NPC faceplate in -10
                //+ breatherSpecs = (Id = -10, specPath = "AMM_BreatherSpec.NPCFaceplateBreatherSpec", comment = "NPC faceplate spec; will look for a helmet with an id matching the armor id and use that if it exists. Otherwise fall back to vanilla faceplate")
                //; 0 to - 9 are special cases with specific behavior, reserved and not species specific
                new LoadedSpecItem(-2, "Mod_GameContent.NoBreatherSpec"),
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaBreatherSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs);

            string armorFileName = $"BIOG_{bodyType}_ARM_AMM";
            string helmetFileName = $"BIOG_{helmetType}_HGR_AMM";

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            // LGTa variants; Most Light armor appearances fall under this
            AddVanillaOutfitSpecs(bodyConfig, 1, armorFileName, OutfitType.LGT, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, helmetFileName, OutfitType.LGT, 0, helmetType, 16, 1, visorMesh, hideHair: true);

            // LGTb; This is the N7 Onyx Armor that Shepard wears
            AddVanillaOutfitSpecs(bodyConfig, 17, armorFileName, OutfitType.LGT, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 17, helmetFileName, OutfitType.LGT, 1, helmetType, 1, 1, visorMesh, hideHair: true);
            // Note that this one needed to be manually corrected to use a clone of the HMF LGTb material to look correct
            // LGTc; This is the Asari Commando armor, normally not ever used by player characters; only used by NPC Asari
            AddVanillaOutfitSpecs(bodyConfig, 18, armorFileName, OutfitType.LGT, 2, bodyType, 1, 1, true);

            // manually add the no tubes helmet version for LGTc, as there is no place for the tubes to connect
            var lgtc = new SimpleHelmetSpecItem(18, $"{helmetFileName}.LGTc.{helmetType}_HGR_LGTc_NoTubes_MDL", [$"{helmetFileName}.LGTc.{helmetType}_HGR_LGTc_MAT_1a"], visorMesh)
            {
                HideHair = true,
            };
            helmetConfig.AddArrayEntries("helmetSpecs", lgtc);

            // MEDa variants; Most Medium armor appearances fall under this
            AddVanillaOutfitSpecs(bodyConfig, 19, armorFileName, OutfitType.MED, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 19, helmetFileName, OutfitType.MED, 0, helmetType, 16, 1, visorMesh, hideHair: true);

            // MEDb; this is the N7 Onyx armor that Shepard wears
            AddVanillaOutfitSpecs(bodyConfig, 35, armorFileName, OutfitType.MED, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 35, helmetFileName, OutfitType.MED, 1, helmetType, 1, 1, visorMesh, hideHair: true);
            // MEDc Asymmetric tintable armor. Not used by any equipment obtainable in vanilla or by any NPCs, but can be accessed using Black Market Licenses/console commands
            AddVanillaOutfitSpecs(bodyConfig, 36, armorFileName, OutfitType.MED, 2, bodyType, 9, 1, true);
            // note that I had to clone the HMF MEDc material 9 as it did not exist for ASA
            AddVanillaHelmetSpecs(helmetConfig, 36, helmetFileName, OutfitType.MED, 2, helmetType, 9, 1, visorMesh, hideHair: true);

            // HVYa variants. Most heavy armor falls under this
            AddVanillaOutfitSpecs(bodyConfig, 45, armorFileName, OutfitType.HVY, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 45, helmetFileName, OutfitType.HVY, 0, helmetType, 16, 1, visorMesh, hideHair: true);
            // HVYb. This is the N7 Onyx Armor Shepard wears
            AddVanillaOutfitSpecs(bodyConfig, 61, armorFileName, OutfitType.HVY, 1, bodyType, 1, 1, true);
            // needed to clone this as there was no ASA HVYb mesh or material. mesh cloned from HVYa, material cloned from HMF HVYb mat
            AddVanillaHelmetSpecs(helmetConfig, 61, helmetFileName, OutfitType.HVY, 1, helmetType, 1, 1, visorMesh, hideHair: true);

            AddClasssicColossusEntries(helmetFileName, armorFileName, bodyType, helmetType, visorMesh, bodyConfig, helmetConfig);

            // add entries for the non armor outfits
            // NKDa (naked human/Avina)
            int miscEndId = 100;
            // NKDb (dancer)
            miscEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMF_NKD_AMM.NKDb.HMF_ARM_NKDb_MDL",
                "BIOG_HMF_NKD_AMM.NKDb.HMF_ARM_NKDb_MAT_1a");
            if (helmetType == "HMF")
            {
                miscEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMF_NKD_AMM.NKDa.HMF_ARM_NKDa_MDL",
                    // human female romance body
                    "BIOG_HMF_NKD_AMM.NKDa.HMF_ARM_NKDa_MAT_1a");
            }
            else
            {
                miscEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMF_NKD_AMM.NKDc.HMF_ARM_NKDc_MDL",
                    // Liara romance body
                    "BIOG_HMF_NKD_AMM.NKDc.HMF_ARM_NKDc_MAT_1a");
            }
            // Avina VI
            miscEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMF_NKD_AMM.NKDa.HMF_ARM_NKDa_MDL",
                "BIOG_HMF_NKD_AMM.NKDa.HMF_ARM_NKDa_Mat_2a");
            // Mira VI
            miscEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MDL",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_6a");

            speciesMenus.CasualOutfitMenus[0].AddMenuEntry(new AppearanceItemData()
            {
                // "Dancer"
                SrCenterText = 210210261,
                ApplyOutfitId = 100
            });
            speciesMenus.CasualOutfitMenus[0].AddMenuEntry(new AppearanceItemData()
            {
                // "Nude"
                SrCenterText = 210210260,
                ApplyOutfitId = 101
            });
            speciesMenus.CasualOutfitMenus[0].AddMenuEntry(new AppearanceItemData()
            {
                // "Avina"
                SrCenterText = 169391,
                ApplyOutfitId = 102
            });
            speciesMenus.CasualOutfitMenus[0].AddMenuEntry(new AppearanceItemData()
            {
                // "Mira"
                SrCenterText = 169193,
                ApplyOutfitId = 103
            });

            // CTHa vanilla
            var cthaEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMF_CTHa_AMM.CTHa.HMF_ARM_CTHa_MDL",
                "BIOG_HMF_CTHa_AMM.CTHa.HMF_ARM_CTHa_MAT_1a",
                "BIOG_HMF_CTHa_AMM.CTHa.HMF_ARM_CTHa_MAT_2a",
                "BIOG_HMF_CTHa_AMM.CTHa.HMF_ARM_CTHa_MAT_3a",
                "BIOG_HMF_CTHa_AMM.CTHa.HMF_ARM_CTHa_MAT_4a",
                "BIOG_HMF_CTHa_AMM.CTHa.HMF_ARM_CTHa_MAT_5a",
                "BIOG_HMF_CTHa_AMM.CTHa.HMF_ARM_CTHa_MAT_6a");

            // CTHa
            AddMenuEntries(speciesMenus.CasualOutfitMenus[1], miscEndId, cthaEndId - miscEndId);

            // CTHb
            var cthbEndId = AddCustomOutfitSpecs(bodyConfig, cthaEndId, "BIOG_HMF_CTHb_AMM.CTHb.HMF_ARM_CTHb_MDL",
                "BIOG_HMF_CTHb_AMM.CTHb.HMF_ARM_CTHb_MAT_1a",
                "BIOG_HMF_CTHb_AMM.CTHb.HMF_ARM_CTHb_MAT_2a",
                "BIOG_HMF_CTHb_AMM.CTHb.HMF_ARM_CTHb_MAT_3a",
                "BIOG_HMF_CTHb_AMM.CTHb.HMF_ARM_CTHb_MAT_4a",
                "BIOG_HMF_CTHb_AMM.CTHb.HMF_ARM_CTHb_MAT_5a");

            // CTHb menu
            AddMenuEntries(speciesMenus.CasualOutfitMenus[2], cthaEndId, cthbEndId - cthaEndId);

            // CTHc
            var cthcEndId = AddCustomOutfitSpecs(bodyConfig, cthbEndId, "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MDL",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_3a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_4a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5a",
                // skipping CTHc 6, as this is the Mira material
                // extended vanilla
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1e",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1f",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1g",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1h",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1i",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1j",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1k",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1l",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1m",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1n",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1o",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1p",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1q",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1r",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1s",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1t",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_1u",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1e",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1f",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1g",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1h",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_tower_1i",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE2_1a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE2_1b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE2_1c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE2_1d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1e",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1f",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1g",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1h",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1i",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1j",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1k",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1l",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1m",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1n",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1o",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1p",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_LE3_1q",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1a",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1e",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1f",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1h",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1k",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_dress_1l",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2e",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2f",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2g",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2h",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2i",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2j",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2k",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2l",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2m",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_2n",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_3b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_3c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_3d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_4b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_4c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5b",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5c",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5d",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5e",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5f",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5g",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5h",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5i",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5j",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5k",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5l",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5m",
                "BIOG_HMF_CTHc_AMM.CTHc.HMF_ARM_CTHc_MAT_5n");

            // CTHc menu
            AddMenuEntries(speciesMenus.CasualOutfitMenus[3], cthbEndId, cthcEndId - cthbEndId);

            // CTHd
            var cthdEndId = AddCustomOutfitSpecs(bodyConfig, cthcEndId, "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MDL",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_1a",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_2a",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_3a",
                // extended vanilla
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_1b",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_2b",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_2c",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_2d",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_3b",
                "BIOG_HMF_CTHd_AMM.CTHd.HMF_ARM_CTHd_MAT_3c");

            // CTHd menu
            AddMenuEntries(speciesMenus.CasualOutfitMenus[4], cthcEndId, cthdEndId - cthcEndId);

            // CTHe
            var ctheEndId = AddCustomOutfitSpecs(bodyConfig, cthdEndId, "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MDL",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_1a",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2a",
                // extended vanilla
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_1b",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_1c",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_1d",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_1e",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_1f",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_1g",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2b",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2c",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2d",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2e",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2f",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2g",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2h",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2i",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2j",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2k",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2l",
                "BIOG_HMF_CTHe_AMM.CTHe.HMF_ARM_CTHe_MAT_2m");

            // CTHe menu
            AddMenuEntries(speciesMenus.CasualOutfitMenus[5], cthdEndId, ctheEndId - cthdEndId);

            // CTHf
            var cthfEndId = AddCustomOutfitSpecs(bodyConfig, ctheEndId, "BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MDL",
                "BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_1a",
                "BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_2a",
                "BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_3a",
                "BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_4a");

            // CTHf alt model (smaller chest, shoulders)
            cthfEndId = AddCustomOutfitSpecs(bodyConfig, cthfEndId, "BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_ALT_MDL",
                ["BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_1a","BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_1a"],
                ["BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_2a","BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_2a"],
                ["BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_3a","BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_3a"],
                ["BIOG_HMF_CTHf_AMM.CTHf.HMF_ARM_CTHf_MAT_4a","BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_4a"]);

            // CTHf menu
            AddMenuEntries(speciesMenus.CasualOutfitMenus[6], ctheEndId, cthfEndId - ctheEndId);

            // CTHg
            var cthgEndId = AddCustomOutfitSpecs(bodyConfig, cthfEndId, "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MDL",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1a",
                // extended vanilla
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_2a",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3a",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1b",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1c",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1d",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1e",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1f",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1g",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1h",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1i",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1j",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1k",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1l",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1m",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1n",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1o",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1p",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1q",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1r",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1s",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1t",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1u",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1v",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_1w",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_AsariSkimpy",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2a",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2b",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2c",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2d",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2f",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2g",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2h",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2i",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2j",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2k",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_dress_2l",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3b",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3c",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3d",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3e",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3f",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3g",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3h",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3i",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3j",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3k",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3l",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3m",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3n",
                "BIOG_HMF_CTHg_AMM.CTHg.HMF_ARM_CTHg_MAT_3o");

            // CTHg menu
            AddMenuEntries(speciesMenus.CasualOutfitMenus[7], cthfEndId, cthgEndId - cthfEndId);

            // CTHh
            var cthhEndId = AddCustomOutfitSpecs(bodyConfig, cthgEndId, "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MDL",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_1a",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2a",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_3a",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_4a",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_5a",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_6a",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_7a",
                // extended vanilla
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_1b",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_1c",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_1d",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2b",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2c",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2d",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2e",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2f",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2g",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2h",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2i",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2j",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2k",
                "BIOG_HMF_CTHh_AMM.CTHh.HMF_ARM_CTHh_MAT_2l");

            // CTHh menu
            AddMenuEntries(speciesMenus.CasualOutfitMenus[8], cthgEndId, cthhEndId - cthgEndId);

            AddFaceplateSpecs(helmetType, breatherConfig);

            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(breatherConfig);
        }

        private static void AddClasssicColossusEntries(string helmetFileName, string armorFileName, string bodyType, string helmetType, AppearanceMeshPaths visorMesh, ModConfigClass bodyConfig, ModConfigClass helmetConfig)
        {
            string[] weights = ["LGT", "MED", "HVY"];
            int[] ids = [62, 63, 64];

            for (int i = 0; i < 3; i++)
            {
                var arm = new SimpleOutfitSpecItem(ids[i], $"{armorFileName}.{weights[i]}a.{bodyType}_ARM_{weights[i]}a_MDL", [$"{armorFileName}.{weights[i]}a.{bodyType}_ARM_{weights[i]}a_Mat_12a"])
                {
                    HelmetSpec = ids[i]
                };

                var helm = new SimpleHelmetSpecItem(ids[i], $"{helmetFileName}.{weights[i]}a.{helmetType}_HGR_{weights[i]}a_MDL", ["BIOG_HMM_HGR_AMM.Alt.Colossus_Classic"], visorMesh)
                {
                    HideHair = true,
                };
                
                helmetConfig.AddArrayEntries("helmetSpecs", helm);
                bodyConfig.AddArrayEntries("outfitSpecs", arm);
            }
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
                // loads the vanilla appearance, even if this is a squadmate with different equipped armor
                //new LoadedSpecItem(-4, "Mod_GameContent.VanillaOutfitSpec"),
                // loads the default/casual look, even if they are in combat
                //new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation/outside the squad
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the default appearance, which might go to equipped armor depending on mod settings
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultOutfitSpec")
            };
            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs);

            specialSpecs =
            [
                 // loads the equipped armor look, even if they are in casual mode or outside of the squad
                new LoadedSpecItem(-3, "Mod_GameContent.EquippedArmorHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs);

            specialSpecs = [
                // clear, smooth
                new SimpleBreatherSpecItem(-23, "HMN_Faceplate_AMM.HMM.HMM_VSR_FULL_MDL", ["HMN_Faceplate_AMM.HMN.HMN_VSR_FULL_MAT"])
                {
                    SuppressVisor = true,
                },
                //// clear with sides, with jaws
                //new SimpleBreatherSpecItem(-22, "BIOG_HMM_BRT_AMM.Custom.HMM_BRT_NPC_Separate_Materials_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},
                // reinforced faceplate (sides and corners from NPC plate, glass from clear)
                new SimpleBreatherSpecItem(-21, "HMN_Faceplate_AMM.HMM.HMM_VSR_FULL_REINFORCED_MDL", ["HMN_Faceplate_AMM.HMN.HMN_VSR_FULL_MAT", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                },
                //// for the sake of completeness, the full face plate with the jaw bits
                //new SimpleBreatherSpecItem(-20, "BIOG_HMM_BRT_AMM.Custom.HMM_BRT_NPC_JAW_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    VisorMeshOverride = new AppearanceMeshPaths("BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR"]),
                //},
                //// NPC faceplate without jaw, with transparent center bit
                //new SimpleBreatherSpecItem(-19, "BIOG_HMM_BRT_AMM.Custom.HMM_BRT_NPC_NO_JAW_BACK_FACES_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},
                //// like above, but with the jaw included
                //new SimpleBreatherSpecItem(-18, "BIOG_HMM_BRT_AMM.Custom.HMM_BRT_NPC_BACK_FACES_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic", "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true,
                //},
                //// -17 is a full glass faceplate, derived from the NPC plate
                //new SimpleBreatherSpecItem(-17, "BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MDL", ["BIOG_HMM_BRT_AMM.Custom.HMM_VSR_FULL_MAT_CLEAR"])
                //{
                //    SuppressVisor = true,
                //},
                // -17 is the NPC faceplate with generic colors and without the jaw bits
                new SimpleBreatherSpecItem(-17, "HMN_Faceplate_AMM.HMM.HMM_BRT_FACEPLATE_Min_MDL", ["HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                    HideHead = true
                },
                // -15 is the NPC faceplate with generic colors
                new SimpleBreatherSpecItem(-15, "HMN_Faceplate_AMM.HMM.HMM_BRT_FACEPLATE_MDL", ["HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic", "HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_Generic"])
                {
                    SuppressVisor = true,
                    HideHead = true
                },

                // -16 is Liara's (light variant)
                new SimpleBreatherSpecItem(-16, "BIOG_HMM_BRT_AMM.Liara.HMM_BRT_Liara_MDL", ["BIOG_HMM_BRT_AMM.Liara.HMM_BRT_Liara_MAT_2a"]),
                //; -10 and on are breathers not matched to a specific outfit, which is the vanilla player and squadmate behavior
                // -15 is the NPC faceplate (TODO match colors better; I'm thinking at least a neutral black/gray)
                //new SimpleBreatherSpecItem(-15, "BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MDL", ["BIOG_HMM_BRT_AMM.NPC.HMM_BRT_NPC_MAT_Generic"])
                //{
                //    SuppressVisor = true
                //},
                // -14 is Kaidan's faceplate
                new SimpleBreatherSpecItem(-14, "BIOG_HMM_BRT_AMM.Kaidan.HMM_BRT_Kaidan_MDL", ["BIOG_HMM_BRT_AMM.Kaidan.HMM_BRT_Kaidan_Mat_1a", "BIOG_HMM_BRT_AMM.Kaidan.HMM_BRT_Kaidan_Mat_2a"])
                {
                    // with a new mesh for blocking the eyes and/or the texture details on the mesh that are visible
                    VisorMeshOverride = new AppearanceMeshPaths("BIOG_HMM_BRT_AMM.Kaidan.hmm_eye_blocker", ["BIOG_HMM_BRT_AMM.Kaidan.Eye_Blocker_mat"]),
                    HideHead = true
                },
                // -13 is Ashley's default faceplate
                new SimpleBreatherSpecItem(-13, "BIOG_HMM_BRT_AMM.Ashley.HMM_BRT_Ashley_MDL", ["BIOG_HMM_BRT_AMM.Ashley.HMM_BRT_Ashley_MAT_1a"]),
                // -12 is Liara's
                new SimpleBreatherSpecItem(-12, "BIOG_HMM_BRT_AMM.Liara.HMM_BRT_Liara_MDL", ["BIOG_HMM_BRT_AMM.Liara.HMM_BRT_Liara_MAT_1a"]),
                // -11 is Shepard's
                new SimpleBreatherSpecItem(-11, "BIOG_HMM_BRT_AMM.Shepard.HMM_BRT_Shepard_MDL", ["BIOG_HMM_BRT_AMM.Shepard.HMM_BRT_Shepard_MAT_1a"]),
                // TODO a special loaded spec for the NPC faceplate in -10
                //+ breatherSpecs = (Id = -10, specPath = "AMM_BreatherSpec.NPCFaceplateBreatherSpec", comment = "NPC faceplate spec; will look for a helmet with an id matching the armor id and use that if it exists. Otherwise fall back to vanilla faceplate")
                //; 0 to - 9 are special cases with specific behavior, reserved and not species specific
                new LoadedSpecItem(-2, "Mod_GameContent.NoBreatherSpec"),
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaBreatherSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];

            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs);

            const string hmmArmorFileName = "BIOG_HMM_ARM_AMM";
            const string hmmHelmetFileName = "BIOG_HMM_HGR_AMM";

            // this is the visor from Visor Clipping Fix version 1.1 by Oakstar519, also included in LE1CP
            // https://www.nexusmods.com/masseffectlegendaryedition/mods/1801
            var visorMesh = new AppearanceMeshPaths($"{hmmHelmetFileName}.VSR.HMM_VSR_MDL", [$"{hmmHelmetFileName}.VSR.HMM_VSR_MAT_1a"]);

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61); matches HMF ids
            // LGTa variants
            AddVanillaOutfitSpecs(bodyConfig, 1, hmmArmorFileName, OutfitType.LGT, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, hmmHelmetFileName, OutfitType.LGT, 0, bodyType, 16, 1, visorMesh, hideHair: true);

            // LGTb: Shepard's Onyx armor with N7 logo
            AddVanillaOutfitSpecs(bodyConfig, 17, hmmArmorFileName, OutfitType.LGT, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 17, hmmHelmetFileName, OutfitType.LGT, 1, bodyType, 1, 1, visorMesh, hideHair: true);
            // Note that there is no LGTc for HMM, and I am intentionally skipping id 18

            // MEDa variants
            AddVanillaOutfitSpecs(bodyConfig, 19, hmmArmorFileName, OutfitType.MED, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 19, hmmHelmetFileName, OutfitType.MED, 0, bodyType, 16, 1, visorMesh, hideHair: true);

            // MEDb: Shep's N7 Onyx Armor
            AddVanillaOutfitSpecs(bodyConfig, 35, hmmArmorFileName, OutfitType.MED, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 35, hmmHelmetFileName, OutfitType.MED, 1, bodyType, 1, 1, visorMesh, hideHair: true);

            // MEDc: Assymmetric tintable armor. never used by NPCs, only usable by player using console commands or Black Market License
            AddVanillaOutfitSpecs(bodyConfig, 36, hmmArmorFileName, OutfitType.MED, 2, bodyType, 9, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 36, hmmHelmetFileName, OutfitType.MED, 2, bodyType, 9, 1, visorMesh, hideHair: true);

            // HVYa variants
            AddVanillaOutfitSpecs(bodyConfig, 45, hmmArmorFileName, OutfitType.HVY, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 45, hmmHelmetFileName, OutfitType.HVY, 0, bodyType, 16, 1, visorMesh, hideHair: true);

            // HVYb: Shep's N7 Onyx armor
            AddVanillaOutfitSpecs(bodyConfig, 61, hmmArmorFileName, OutfitType.HVY, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 61, hmmHelmetFileName, OutfitType.HVY, 1, bodyType, 1, 1, visorMesh, hideHair: true);

            AddClasssicColossusEntries(hmmHelmetFileName, hmmArmorFileName, bodyType, bodyType, visorMesh, bodyConfig, helmetConfig);

            // add all the non armor outfits for male humans to the menu
            // NKDa (naked human/VI)
            var miscEndId = 100;
            miscEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMM_NKD_AMM.NKDa.HMM_ARM_NKDa_MDL",
                // naked human
                "BIOG_HMM_NKD_AMM.NKDa.HMM_ARM_NKDa_MAT_1a");
                // VI (I think totally unused, actually; it is the Avina material but the UV clearly doesn't match at all)
                //"BIOG_HMM_NKD_AMM.NKDa.HMM_ARM_NKDa_MAT_2a"

            // Exogeni VI
            miscEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MDL",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_5a");

            humanMaleOutfitMenus.CasualOutfitMenus[0].AddMenuEntry(new AppearanceItemData()
            {
                // "Nude"
                SrCenterText = 210210260,
                ApplyOutfitId = 100
            });
            humanMaleOutfitMenus.CasualOutfitMenus[0].AddMenuEntry(new AppearanceItemData()
            {
                // "VI"
                SrCenterText = 145793,
                ApplyOutfitId = 101
            });

            // CTHa vanilla
            var cthaEndId = AddCustomOutfitSpecs(bodyConfig, miscEndId, "BIOG_HMM_CTHa_AMM.CTHa.HMM_ARM_CTHa_MDL",
                "BIOG_HMM_CTHa_AMM.CTHa.HMM_ARM_CTHa_MAT_1a",
                "BIOG_HMM_CTHa_AMM.CTHa.HMM_ARM_CTHa_MAT_2a",
                "BIOG_HMM_CTHa_AMM.CTHa.HMM_ARM_CTHa_MAT_3a",
                // material 4 is missing from vanilla
                "BIOG_HMM_CTHa_AMM.CTHa.HMM_ARM_CTHa_MAT_5a");

            // CTHa
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[1], miscEndId, cthaEndId - miscEndId);

            // CTHb
            var cthbEndId = AddCustomOutfitSpecs(bodyConfig, cthaEndId, "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MDL",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_1a",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_2a",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_3a",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4a",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_5a",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_6a",
                // extended vanilla
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_2b",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4b",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4c",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4d",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4e",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4f",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4g",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_4h",
                "BIOG_HMM_CTHb_AMM.CTHb.HMM_ARM_CTHb_MAT_5b");

            // CTHb
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[2], cthaEndId, cthbEndId - cthaEndId);

            // CTHc
            var cthcEndId = AddCustomOutfitSpecs(bodyConfig, cthbEndId, "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MDL",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_1a",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_2a",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3a",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_4a",
                // skipping CTHc 5 because this is the Exogeni VI material and it is in misc
                // extended vanilla
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01a",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01b",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01c",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01d",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01e",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01f",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01g",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01h",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01i",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01j",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01k",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01l",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01m",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_01n",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_Suit_Albino",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_1b",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_1c",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_2b",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_2c",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_2d",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_2e",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3b",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3c",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3d",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3e",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3f",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3g",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3h",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3i",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3j",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3k",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3l",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3m",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_3n",
                "BIOG_HMM_CTHc_AMM.CTHc.HMM_ARM_CTHc_MAT_4b");

			// CTHc
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[3], cthbEndId, cthcEndId - cthbEndId);

            // CTHd
            var cthdEndId = AddCustomOutfitSpecs(bodyConfig, cthcEndId, "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MDL",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_1a",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_2a",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_3a",
                // extended vanilla
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_1b",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_1c",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_1d",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_1e",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_1f",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_2b",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_2c",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_2d",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_2e",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_3b",
                "BIOG_HMM_CTHd_AMM.CTHd.HMM_ARM_CTHd_MAT_3c");

            // CTHd
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[4], cthcEndId, cthdEndId - cthcEndId);

            // CTHe
            var ctheEndId = AddCustomOutfitSpecs(bodyConfig, cthdEndId, "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MDL",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1a",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2a",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_3a",
                // extended vanilla
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1b",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1c",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1d",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1e",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1f",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1g",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1h",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1i",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_1j",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2b",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2c",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2d",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2e",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2f",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2g",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_2h",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_3b",
                "BIOG_HMM_CTHe_AMM.CTHe.HMM_ARM_CTHe_MAT_3c");

            // CTHe menu
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[5], cthdEndId, ctheEndId - cthdEndId);

            // CTHf
            var cthfEndId = AddCustomOutfitSpecs(bodyConfig, ctheEndId, "BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MDL",
                "BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_1a",
                "BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_2a",
                "BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_3a",
                "BIOG_HMM_CTHf_AMM.CTHf.HMM_ARM_CTHf_MAT_4a");

            // CTHf menu
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[6], ctheEndId, cthfEndId - ctheEndId);

            // CTHg
            var cthgEndId = AddCustomOutfitSpecs(bodyConfig, cthfEndId, "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MDL",
                "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MAT_1a",
                "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MAT_2a",
                // extended vanilla
                "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MAT_3a",
                "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MAT_1b",
                "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MAT_1c",
                "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MAT_2b",
                "BIOG_HMM_CTHg_AMM.CTHg.HMM_ARM_CTHg_MAT_2c");

            // CTHg menu
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[7], cthfEndId, cthgEndId - cthfEndId);

            // CTHh
            var cthhEndId = AddCustomOutfitSpecs(bodyConfig, cthgEndId, "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MDL",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_1a",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2a",
                // extended vanilla
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_3a",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_4a",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_1b",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2b",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2c",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2d",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2e",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2f",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2g",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2h",
                "BIOG_HMM_CTHh_AMM.CTHh.HMM_ARM_CTHh_MAT_2i");

            // CTHh menu
            AddMenuEntries(humanMaleOutfitMenus.CasualOutfitMenus[8], cthgEndId, cthhEndId - cthgEndId);

            AddFaceplateSpecs(bodyType, breatherConfig);

            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(breatherConfig);
        }

        private void AddFaceplateSpecs(string helmetType, ModConfigClass breatherConfig)
        {
            // add a modified version of the NPC faceplate breather into the outfits list
            for (int i = 1; i <= 16; i++)
            {
                // each one has three materials: the plate, the side bits intersecting with the plate, and the jaw bits
                var breatherSpec = new SimpleBreatherSpecItem(i, $"HMN_Faceplate_AMM.{helmetType}.{helmetType}_BRT_FACEPLATE_MDL", [$"HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_{i}a", $"HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_{i}a", $"HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_{i}a"])
                {
                    SuppressVisor = true,
                    HideHead = true
                };
                breatherConfig.AddArrayEntries("breatherSpecs", breatherSpec);
            }
            // same as above, wut without the jaw bit
            for (int i = 1; i <= 16; i++)
            {
                var breatherSpec = new SimpleBreatherSpecItem(i + 100, $"HMN_Faceplate_AMM.{helmetType}.{helmetType}_BRT_FACEPLATE_Min_MDL", [$"HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_{i}a", $"HMN_Faceplate_AMM.HMN.HMN_BRT_FACEPLATE_MAT_{i}a"])
                {
                    SuppressVisor = true,
                    HideHead = true
                };
                breatherConfig.AddArrayEntries("breatherSpecs", breatherSpec);
            }
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
                 // loads the vanilla appearance, even if this is a squadmate with different equipped armor
                new LoadedSpecItem(-4, "Mod_GameContent.VanillaOutfitSpec"),
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the default appearance, which might go to equipped armor depending on mod settings
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultOutfitSpec")
            };

            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs);

            specialSpecs =
            [
                 // loads the equipped armor look, even if they are in casual mode or outside of the squad
                new LoadedSpecItem(-3, "Mod_GameContent.EquippedArmorHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs);

            specialSpecs = [
                new LoadedSpecItem(-2, "Mod_GameContent.NoBreatherSpec"),
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaBreatherSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs);

            const string kroArmorFileName = "BIOG_KRO_ARM_AMM";
            const string kroHelmetFileName = "BIOG_KRO_HGR_AMM";

            // add all vanilla armor variants into positive IDs less than 100
            // MEDa variants. There are not light Korgan armor meshes, and no other medium variants
            AddVanillaOutfitSpecs(bodyConfig, 1, kroArmorFileName, OutfitType.MED, 0, bodyType, 11, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, kroHelmetFileName, OutfitType.MED, 0, bodyType, 11, 1, suppressBreather: true, hideHead: true);

            // Heavy armor variants
            AddVanillaOutfitSpecs(bodyConfig, 12, kroArmorFileName, OutfitType.HVY, 0, bodyType, 12, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 12, kroHelmetFileName, OutfitType.HVY, 0, bodyType, 12, 1, suppressBreather: true, hideHead: true);
            AddVanillaOutfitSpecs(bodyConfig, 24, kroArmorFileName, OutfitType.HVY, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 24, kroHelmetFileName, OutfitType.HVY, 1, bodyType, 1, 1, suppressBreather: true, hideHead: true);
            // this is the fun glowy ones
            AddVanillaOutfitSpecs(bodyConfig, 25, kroArmorFileName, OutfitType.HVY, 2, bodyType, 3, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 25, kroHelmetFileName, OutfitType.HVY, 2, bodyType, 3, 1, suppressBreather: true, hideHead: true);

            var cthaEndId = AddCustomOutfitSpecs(bodyConfig, 100, "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MDL",
                "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MAT_1a",
                "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MAT_2a",
                "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MAT_3a",
                "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MAT_4a",
                "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MAT_5a",
                // extended vanilla
                "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MAT_6a",
                "BIOG_KRO_CTHa_AMM.CTHa.KRO_ARM_CTHa_MAT_7a");

            // add all the outfits for Krogan to the CTHa menu
            AddMenuEntries(kroganOutfitMenus.CasualOutfitMenus[0], 100, cthaEndId - 100);

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
                 // loads the vanilla appearance, even if this is a squadmate with different equipped armor
                new LoadedSpecItem(-4, "Mod_GameContent.VanillaOutfitSpec"),
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the default appearance, which might go to equipped armor depending on mod settings
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultOutfitSpec")
            };

            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs);

            specialSpecs =
            [
                 // loads the equipped armor look, even if they are in casual mode or outside of the squad
                new LoadedSpecItem(-3, "Mod_GameContent.EquippedArmorHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs);

            specialSpecs = [
                // the default breather/visor combo for LGT and HVY (MED suppresses it, as the helmet covers the head)
                // note that the helmet without the breather never shows the visor, and the breather, if not suppressed, always does. It's confusing
                new SimpleBreatherSpecItem(-10, "BIOG_TUR_HGR_AMM.BRT.TUR_BRT_MDL", ["BIOG_TUR_HGR_AMM.BRT.TUR_BRT_MAT_1a"])
                {
                    VisorMeshOverride = new AppearanceMeshPaths("BIOG_TUR_HGR_AMM.VSR.TUR_VSR_MDL", ["BIOG_TUR_HGR_AMM.VSR.TUR_VSR_MAT_1a"])
                },
                new LoadedSpecItem(-2, "Mod_GameContent.NoBreatherSpec"),
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaBreatherSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs);

            const string turArmorFileName = "BIOG_TUR_ARM_AMM";
            const string turHeadgearFileName = "BIOG_TUR_HGR_AMM";

            // add all vanilla armor variants into positive IDs less than 100
            // LGTa
            AddVanillaOutfitSpecs(bodyConfig, 1, turArmorFileName, OutfitType.LGT, 0, bodyType, 15, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, turHeadgearFileName, OutfitType.LGT, 0, bodyType, 15, 1, hideHair: true);

            // LGTb
            // this is the Phantom armor. technically it has three material variants, but the other two are just blue and yellow LEDs that don't even match the red of the rest of the armor, so I am ignoring them.
            AddVanillaOutfitSpecs(bodyConfig, 16, turArmorFileName, OutfitType.LGT, 1, bodyType, 1, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 16, turHeadgearFileName, OutfitType.LGT, 1, bodyType, 1, 1, hideHair: true);

            // MEDa
            AddVanillaOutfitSpecs(bodyConfig, 17, turArmorFileName, OutfitType.MED, 0, bodyType, 16, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 17, turHeadgearFileName, OutfitType.MED, 0, bodyType, 16, 1, hideHead: true, suppressBreather: true);

            // HVYa
            AddVanillaOutfitSpecs(bodyConfig, 33, turArmorFileName, OutfitType.HVY, 0, bodyType, 15, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 33, turHeadgearFileName, OutfitType.HVY, 0, bodyType, 15, 1, hideHair: true);

            // Add CTH vanilla meshes (100+)
            // CTHa vanilla and extended vanilla variants (collected from the Trilogy by Diversification Project team)
            var cthaEndId = AddCustomOutfitSpecs(bodyConfig, 100, "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MDL",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_2a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_3a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_4a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_5a",
                // extended vanilla options
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1b",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1c",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1d",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1e",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1f",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1g",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_2b",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_4b");

            // CTHa no hood variant
            cthaEndId = AddCustomOutfitSpecs(bodyConfig, cthaEndId, "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_ALT_MDL",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_2a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_3a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_4a",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_5a",
                // extended vanilla options
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1b",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1c",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1d",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1e",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1f",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_1g",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_2b",
                "BIOG_TUR_CTHa_AMM.CTHa.TUR_ARM_CTHa_MAT_4b");

            // add all the outfits for Krogan to the CTHa menu
            AddMenuEntries(turianOutfitMenus.CasualOutfitMenus[0], 100, cthaEndId - 100);

            // CTHb
            var cthbEndId = AddCustomOutfitSpecs(bodyConfig, cthaEndId, "BIOG_TUR_CTHb_AMM.CTHb.TUR_ARM_CTHb_MDL",
                "BIOG_TUR_CTHb_AMM.CTHb.TUR_ARM_CTHb_MAT_1a",
                "BIOG_TUR_CTHb_AMM.CTHb.TUR_ARM_CTHb_MAT_2a",
                "BIOG_TUR_CTHb_AMM.CTHb.TUR_ARM_CTHb_MAT_3a",
                "BIOG_TUR_CTHb_AMM.CTHb.TUR_ARM_CTHb_MAT_4a",
                // extended vanilla
                "BIOG_TUR_CTHb_AMM.CTHb.TUR_ARM_CTHb_MAT_5a");

            // CTHb menu
            AddMenuEntries(turianOutfitMenus.CasualOutfitMenus[1], cthaEndId, cthbEndId - cthaEndId);

            var cthcEndId = AddCustomOutfitSpecs(bodyConfig, cthbEndId, "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MDL",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1a",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_2a",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_3a",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_4a",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_5a",
                // extended vanilla
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1b",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1c",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1d",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1e",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1f",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1g",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1h",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1i",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1j",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1k",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1l",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1m",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1n",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_1o",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_2b",
                "BIOG_TUR_CTHc_AMM.CTHc.TUR_ARM_CTHc_MAT_3b");

            // CTHb menu
            AddMenuEntries(turianOutfitMenus.CasualOutfitMenus[2], cthbEndId, cthcEndId - cthbEndId);

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
            var bodyConfig = GetOutfitListConfig(bodyType);
            var helmetConfig = GetHelmetListConfig(bodyType);
            var breatherConfig = GetBreatherListConfig(bodyType);

            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                 // loads the vanilla appearance, even if this is a squadmate with different equipped armor
                new LoadedSpecItem(-4, "Mod_GameContent.VanillaOutfitSpec"),
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the default appearance, which might go to equipped armor depending on mod settings
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultOutfitSpec")
            };

            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs);

            specialSpecs =
            [
                 // loads the equipped armor look, even if they are in casual mode or outside of the squad
                new LoadedSpecItem(-3, "Mod_GameContent.EquippedArmorHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs);

            specialSpecs = [
                new LoadedSpecItem(-2, "Mod_GameContent.NoBreatherSpec"),
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaBreatherSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs);

            const string qrnArmorFileName = "BIOG_QRN_ARM_AMM";

            // add all vanilla armor variants into positive IDs less than 100
            // Tali is the only vanilla Quarian, and she only has 6 color/texture variants of the same LGTa mesh
            AddVanillaOutfitSpecs(bodyConfig, 1, qrnArmorFileName, OutfitType.LGT, 0, "QRN_FAC", 6, 2);

            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(breatherConfig);
        }

        private void GenerateSALSpecs()
        {
            /*
             * Salarian vanilla helmets have no separate visor or breather, and they hide the whole head similar to krogan
             */
            const string bodyType = "SAL";

            // add the source code needed
            AddSpecListClasses(bodyType);

            // now generate the configs
            var bodyConfig = GetOutfitListConfig(bodyType);
            var helmetConfig = GetHelmetListConfig(bodyType);
            var breatherConfig = GetBreatherListConfig(bodyType);

            // Add the special case ones
            var specialSpecs = new List<SpecItemBase>
            {
                 // loads the vanilla appearance, even if this is a squadmate with different equipped armor
                new LoadedSpecItem(-4, "Mod_GameContent.VanillaOutfitSpec"),
                // loads the default/casual look, even if they are in combat
                new LoadedSpecItem(-3, "Mod_GameContent.ArmorOverrideVanillaOutfitSpec"),
                // loads the equipped armor look, even if they are out of combat/in a casual situation
                new LoadedSpecItem(-2, "Mod_GameContent.EquippedArmorOutfitSpec"),
                // loads the default appearance, which might go to equipped armor depending on mod settings
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultOutfitSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultOutfitSpec")
            };

            bodyConfig.AddArrayEntries("outfitSpecs", specialSpecs);

            specialSpecs =
            [
                 // loads the equipped armor look, even if they are in casual mode or outside of the squad
                new LoadedSpecItem(-3, "Mod_GameContent.EquippedArmorHelmetSpec"),
                // force there to be no helmet
                new LoadedSpecItem(-2, "Mod_GameContent.NoHelmetSpec"),
                // loads the vanilla appearance, unless overridden by the outfit spec
                new LoadedSpecItem(-1, "Mod_GameContent.DefaultHelmetSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.DefaultHelmetSpec")
            ];
            helmetConfig.AddArrayEntries("helmetSpecs", specialSpecs);

            specialSpecs = [
                new LoadedSpecItem(-2, "Mod_GameContent.NoBreatherSpec"),
                new LoadedSpecItem(-1, "Mod_GameContent.VanillaBreatherSpec"),
                new LoadedSpecItem(0, "Mod_GameContent.VanillaBreatherSpec")
            ];
            breatherConfig.AddArrayEntries("breatherSpecs", specialSpecs);

            // using the names of vanilla files they never shipped, but would have existed in a non stripped game
            // this allows vanilla outfits to dynamic load and I can also add extras from other games
            const string salArmorFileName = "BIOG_SAL_ARM_LGT_R";
            const string salHelmetFileName = "BIOG_SAL_HGR_LGT_R";

            // add all vanilla armor variants into positive IDs less than 100
            // salarians only have LGTa, and only 4 material variants
            AddVanillaOutfitSpecs(bodyConfig, 1, salArmorFileName, OutfitType.LGT, 0, bodyType, 4, 1, true);
            AddVanillaHelmetSpecs(helmetConfig, 1, salHelmetFileName, OutfitType.LGT, 0, bodyType, 4, 1, suppressBreather: true, hideHead: true);

            AddMenuEntries(salarianOutfitMenus.Armor, 1, 4);
            AddHelmetMenuEntries(salarianOutfitMenus.ArmorHeadgear, 1, 4);


            var cthaEndId = AddCustomOutfitSpecs(bodyConfig, 100, "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MDL",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1a",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_2a",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_3a",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1b",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1c",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1d",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1e",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1f",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1g",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1h",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1i",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1j",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1k",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1l",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1m",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_1n",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_2b",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_2c",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_3b",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_3c",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_3d",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_3e",
                "BIOG_SAL_ARM_CTH_R.CTHa.SAL_ARM_CTHa_MAT_3f");

            // CTHa menu
            AddMenuEntries(salarianOutfitMenus.CasualOutfitMenus[0], 100, cthaEndId - 100);

            var cthbEndId = AddCustomOutfitSpecs(bodyConfig, cthaEndId, "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MDL",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_1a",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_2a",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_3a",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_2b",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_1b",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_1c",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_1d",
                "BIOG_SAL_ARM_CTH_R.CTHb.SAL_ARM_CTHb_MAT_1e");

            // CTHb menu
            AddMenuEntries(salarianOutfitMenus.CasualOutfitMenus[1], cthaEndId, cthbEndId - cthaEndId);

            var cthcEndId = AddCustomOutfitSpecs(bodyConfig, cthbEndId, "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MDL",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1a",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_2a",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_3a",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1b",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1c",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1d",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1e",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1f",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1g",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1h",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1i",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_1j",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_2b",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_2c",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_2d",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_2e",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_3b",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_3c",
                "BIOG_SAL_ARM_CTH_R.CTHc.SAL_ARM_CTHc_MAT_3d");

            // CTHc menu
            AddMenuEntries(salarianOutfitMenus.CasualOutfitMenus[2], cthbEndId, cthcEndId - cthbEndId);

            var cthdEndId = AddCustomOutfitSpecs(bodyConfig, cthcEndId, "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MDL",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_1a",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_2a",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_3a",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_4a",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_5a",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_1b",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_1c",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_1d",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_1e",
                "BIOG_SAL_ARM_CTH_R.CTHd.SAL_ARM_CTHd_MAT_1f");

            // CTHd menu
            AddMenuEntries(salarianOutfitMenus.CasualOutfitMenus[3], cthcEndId, cthdEndId - cthcEndId);

            var ctheEndId = AddCustomOutfitSpecs(bodyConfig, cthdEndId, "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MDL",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_1a",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_2a",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_3a",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_4a",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_5a",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_6a",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_7a",
                "BIOG_SAL_ARM_CTH_R.CTHe.SAL_ARM_CTHe_MAT_8a");

            // CTHe menu
            AddMenuEntries(salarianOutfitMenus.CasualOutfitMenus[4], cthdEndId, ctheEndId - cthdEndId);

            configs.Add(bodyConfig);
            configs.Add(helmetConfig);
            configs.Add(breatherConfig);
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

            configToAddTo.AddArrayEntries("outfitSpecs", specs);
        }

        private static int AddCustomOutfitSpecs(
            ModConfigClass specListConfig,
            int startingId,
            string meshPath,
            params string[] materialPaths
            )
        {
            SimpleOutfitSpecItem[] specs = new SimpleOutfitSpecItem[materialPaths.Length];
            for (int i = 0; i < materialPaths.Length; i++)
            {
                specs[i] = new SimpleOutfitSpecItem(startingId + i, meshPath, [materialPaths[i]])
                {
                    HelmetSpec = -2
                };
            }

            specListConfig.AddArrayEntries("outfitSpecs", specs);

            // the starting id for the next set
            return startingId + specs.Length;
        }

        private static int AddCustomOutfitSpecs(
           ModConfigClass specListConfig,
           int startingId,
           string meshPath,
           params string[][] materialPaths
           )
        {
            SimpleOutfitSpecItem[] specs = new SimpleOutfitSpecItem[materialPaths.Length];
            for (int i = 0; i < materialPaths.Length; i++)
            {
                specs[i] = new SimpleOutfitSpecItem(startingId + i, meshPath, materialPaths[i])
                {
                    HelmetSpec = -2
                };
            }

            specListConfig.AddArrayEntries("outfitSpecs", specs);

            // the starting id for the next set
            return startingId + specs.Length;
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

            configToAddTo.AddArrayEntries("helmetSpecs", specs);
        }

        private static void AddMenuEntries(AppearanceSubmenu submenu, int startingId, int count)
        {
            for (int i = 0; i < count; i++)
            {
                submenu.AddMenuEntry(new AppearanceItemData()
                {
                    // "Style <0>"
                    SrCenterText = 210210235,
                    ApplyOutfitId = startingId + i,
                    DisplayVars = [(i + 1).ToString()]
                });
            }
        }

        private static void AddHelmetMenuEntries(AppearanceSubmenu submenu, int startingId, int count)
        {
            for (int i = 0; i < count; i++)
            {
                submenu.AddMenuEntry(new AppearanceItemData()
                {
                    // "Style <0>"
                    SrCenterText = 210210235,
                    ApplyHelmetId = startingId + i,
                    DisplayVars = [(i + 1).ToString()]
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

        //private static string GetVanillaArmorFileName(string bodyType, OutfitType outfitType)
        //{
        //    return $"BIOG_{bodyType}_ARM_{outfitType}_R";
        //}

        //private static string GetVanillaHelmetFileName(string bodyType, OutfitType outfitType)
        //{
        //    return $"BIOG_{bodyType}_HGR_{outfitType}_R";
        //}
    }
}
