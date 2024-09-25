using AppearanceModMenuBuilder.LE1.Models;
using LegendaryExplorerCore.Coalesced;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal;
using LegendaryExplorerCore.Unreal.ObjectInfo;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder.Models;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class FrameworkTest : IModBuilderTask
    {
        private static bool IndividualPawns = false;
        private static int currentPlotInt = 1700;
        private static ModConfigMergeFile ConfigMergeFile;

        private static AppearanceSubmenu CharacterSelectSubmenuConfig = new("AMM_Submenus.AppearanceSubmenu_CharacterSelect");
        private static ModConfigClass PawnParamHandlerConfig = new("Mod_GameContent.Pawn_Parameter_Handler", "BioGame.ini");

        public void RunModTask(ModBuilderContext context)
        {
            // disabled because I do not need to run this every time
            return;

            Console.WriteLine("generating framework test content");

            Directory.CreateDirectory(Path.Combine(context.CookedPCConsoleFolder, "FrameworkTest"));
            ConfigMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-FrameworkTest.m3cd");
            // TODO make this relative to output dir 
            var frameworkLibraryDir = Path.Combine(Directory.GetParent(context.DLCBaseFolder).Parent.FullName, @"LE1 Framework\DLC_MOD_Framework\CookedPCConsole");
            foreach (var file in Directory.EnumerateFiles(frameworkLibraryDir, "BIONPC_*", SearchOption.AllDirectories))
            {
                CheckBioNPCFile(file, context);
            }

            // sort the entries to make it easier to find them
            CharacterSelectSubmenuConfig["menuItems"] = new CoalesceProperty("menuItems", [.. CharacterSelectSubmenuConfig["menuItems"].OrderBy(x => x.Value)]);
            ConfigMergeFile.AddOrMergeClassConfig(PawnParamHandlerConfig);
            ConfigMergeFile.AddOrMergeClassConfig(CharacterSelectSubmenuConfig);
        }

        private static void CheckBioNPCFile(string filename, ModBuilderContext context)
        {
            // skip squadmates, player; they are already handled
            if (filename.Contains("Ashley")
                || filename.Contains("Kaidan")
                || filename.Contains("Garrus")
                || filename.Contains("Tali")
                || filename.Contains("Wrex")
                || filename.Contains("Liara")
                || filename.Contains("Jenkins")
                || filename.Contains("Shep_Romance")
                // special case handling for his skin tone
                || filename.Contains("Anderson")
                // already handled in an example
                || filename.Contains("Joker"))
            {
                return;
            }

            if (filename.Contains("_LOC_"))
            {
                // no need to open the localization files, they don't have any pawns in them.
                return;
            }

            Console.WriteLine("generating framework test content for " + filename);

            var pcc = MEPackageHandler.OpenMEPackage(filename);

            List<ExportEntry> pawns = [];
            List<string> altTags = [];
            // find all BioPawns (should usually only be one)
            foreach (var exp in pcc.Exports)
            {
                if (exp.ClassName == "BioPawn" && exp.InstancedFullPath.StartsWith("TheWorld.PersistentLevel"))
                {
                    pawns.Add(exp);
                    //firstPawn ??= exp;
                    var tag = exp.GetProperty<NameProperty>("Tag")?.ToString();
                    if (tag != null)
                    {
                        altTags.Add(tag);
                    }
                }
            }

            if (!IndividualPawns || pawns.Count == 1)
            {
                HandleBioNPCPawn(pawns.FirstOrDefault(), context, altTags, false);
            }
            else
            {
                foreach (var exp in pawns)
                {
                    var tag = exp.GetProperty<NameProperty>("Tag")?.ToString();
                    HandleBioNPCPawn(exp, context, [tag], true);
                }
            }
        }

        private static void HandleBioNPCPawn(ExportEntry? pawn, ModBuilderContext context, IEnumerable<string> altTags, bool separateFile)
        {
            if (pawn == null)
            {
                return;
            }
            //if (CheckBioPawn(pawn))
            //{
                CreatePawnInfrastructure(pawn, context, altTags, separateFile);
            //}
        }

        private static void CreatePawnInfrastructure(ExportEntry pawn, ModBuilderContext context, IEnumerable<string> altTags, bool separateFile)
        {
            var BioNPCName = pawn.FileRef.FileNameNoExtension;
            string uniqueName = BioNPCName;

            if (separateFile)
            {
                uniqueName = BioNPCName + "_" + pawn.GetProperty<NameProperty>("Tag")?.ToString();
            }

            string tag;
            // this one has two pawns in it, both without tags hardcoded. It assigns a tag to the correct one according to the mod setting for the appearance (from LE1CP)
            if (pawn.FileRef.FileNameNoExtension == "BIONPC_SalarianCSec")
            {
                tag = "sta60_css_response";
                altTags = ["sta60_css_response", .. altTags];
                // TODO handle this one better
                if (pawn.ObjectName.Number == 5)
                {
                    return;
                }
            }
            else
            {
                tag = pawn.GetProperty<NameProperty>("Tag").ToString();
            }

            var pcc = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "FrameworkTest", $"AMM_{uniqueName}.pcc"), context.Game);

            // need to add pawn Params, submenu class
            pcc.GetOrCreateObjectReferencer();

            // pawn params config
            var pawnParamsConfig = new ModConfigClass($"AMM_{uniqueName}.AMM_Pawn_Parameters_{uniqueName}", "BioGame.ini");
            pawnParamsConfig.SetStringValue("Tag", uniqueName);

            foreach (var altTag in altTags)
            {
                //if (altTag != tag)
                //{
                    pawnParamsConfig.AddArrayEntries("alternateTags", altTag);
                //}
            }

            ConfigMergeFile.AddOrMergeClassConfig(pawnParamsConfig);

            // add the pawn params into the master list
            var paramLoaderCoalescValue = new StructCoalesceValue() { { "parameterPath", new StringCoalesceValue($"AMM_{uniqueName}.AMM_Pawn_Parameters_{uniqueName}") } }.OutputValue();
            PawnParamHandlerConfig.AddEntry(new CoalesceProperty("pawnParamSpecs", new CoalesceValue(paramLoaderCoalescValue, CoalesceParseAction.AddUnique)));

            // inner menu
            var submenuConfig = new AppearanceSubmenu($"AMM_{uniqueName}.AppearanceSubmenu_{uniqueName}")
            {
                PawnTag = uniqueName,
                ArmorOverride = "overridden",
                STitle = uniqueName,
                SrSubtitle = 210210256,
                UseTitleForChildMenus = true,
                PreloadPawn = false
            };

            CharacterSelectSubmenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
            {
                SCenterText = uniqueName,
                SubMenuClassName = $"AMM_{uniqueName}.AppearanceSubmenu_{uniqueName}"
            });

            string meshPath = (GetOptionalObjectProperty(GetOptionalObjectProperty(pawn, "Mesh"), "SkeletalMesh")?.InstancedFullPath ?? "").ToLower();
            string headMeshPath = (GetOptionalObjectProperty(GetOptionalObjectProperty(pawn, "m_oHeadMesh"), "SkeletalMesh")?.InstancedFullPath ?? "").ToLower();

            // assume anyone in a default cth or nkd outfit is casual, otherwise combat
            var casual = meshPath.Contains("cth") || meshPath.Contains("nkd");

            if (meshPath.Contains("hmf"))
            {
                if (headMeshPath.Contains("asa"))
                {
                    // asa stuff
                    pawnParamsConfig.SetStringValue("outfitSpecListPath", "outfitSpecs.ASA_OutfitSpec");
                    pawnParamsConfig.SetStringValue("helmetSpecListPath", "OutfitSpecs.ASA_HelmetSpec");
                    pawnParamsConfig.SetStringValue("breatherSpecListPath", "OutfitSpecs.ASA_BreatherSpec");
                    submenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
                    {
                        InlineSubmenu = true,
                        SubMenuClassName = casual ? "AMM_Submenus.Asari.AppearanceSubmenu_Asari_CasualOutfits" : "AMM_Submenus.Asari.AppearanceSubmenu_Asari_CombatOutfits"
                    });
                }
                else
                {
                    // hmf stuff
                    pawnParamsConfig.SetStringValue("outfitSpecListPath", "outfitSpecs.HMF_OutfitSpec");
                    pawnParamsConfig.SetStringValue("helmetSpecListPath", "OutfitSpecs.HMF_HelmetSpec");
                    pawnParamsConfig.SetStringValue("breatherSpecListPath", "OutfitSpecs.HMF_BreatherSpec");
                    submenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
                    {
                        InlineSubmenu = true,
                        SubMenuClassName = casual ? "AMM_Submenus.HumanFemale.AppearanceSubmenu_HumanFemale_CasualOutfits" : "AMM_Submenus.HumanFemale.AppearanceSubmenu_HumanFemale_CombatOutfits"
                    });
                }
            }
            else if (meshPath.Contains("tur") || meshPath.Contains("Sar") || meshPath.Contains("cbt_end"))
            {
                // TUR stuff
                // Saren on his flyer should also be armor
                if (meshPath.Contains("cbt_end"))
                {
                    casual = false;
                }
                pawnParamsConfig.SetStringValue("outfitSpecListPath", "outfitSpecs.TUR_OutfitSpec");
                pawnParamsConfig.SetStringValue("helmetSpecListPath", "OutfitSpecs.TUR_HelmetSpec");
                pawnParamsConfig.SetStringValue("breatherSpecListPath", "OutfitSpecs.TUR_BreatherSpec");
                submenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
                {
                    InlineSubmenu = true,
                    SubMenuClassName = casual ? "AMM_Submenus.Turian.AppearanceSubmenu_Turian_CasualOutfits" : "AMM_Submenus.Turian.AppearanceSubmenu_Turian_CombatOutfits"
                });
            }
            // Benezia gets asari combat outfits
            else if (meshPath.Contains("mrc"))
            {
                // asa stuff
                pawnParamsConfig.SetStringValue("outfitSpecListPath", "outfitSpecs.ASA_OutfitSpec");
                pawnParamsConfig.SetStringValue("helmetSpecListPath", "OutfitSpecs.ASA_HelmetSpec");
                pawnParamsConfig.SetStringValue("breatherSpecListPath", "OutfitSpecs.ASA_BreatherSpec");
                submenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
                {
                    InlineSubmenu = true,
                    SubMenuClassName = "AMM_Submenus.Asari.AppearanceSubmenu_Asari_CombatOutfits"
                });
            }
            else if (meshPath.Contains("kro"))
            {
                // KRO stuff
                pawnParamsConfig.SetStringValue("outfitSpecListPath", "outfitSpecs.KRO_OutfitSpec");
                pawnParamsConfig.SetStringValue("helmetSpecListPath", "OutfitSpecs.KRO_HelmetSpec");
                pawnParamsConfig.SetStringValue("breatherSpecListPath", "OutfitSpecs.KRO_BreatherSpec");
                submenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
                {
                    InlineSubmenu = true,
                    SubMenuClassName = casual ? "AMM_Submenus.Krogan.AppearanceSubmenu_Krogan_CasualOutfits" : "AMM_Submenus.Krogan.AppearanceSubmenu_Krogan_CombatOutfits"
                });
            }
            else if (meshPath.Contains("sal"))
            {
                // sal stuff
                pawnParamsConfig.SetStringValue("outfitSpecListPath", "outfitSpecs.SAL_OutfitSpec");
                pawnParamsConfig.SetStringValue("helmetSpecListPath", "OutfitSpecs.SAL_HelmetSpec");
                pawnParamsConfig.SetStringValue("breatherSpecListPath", "OutfitSpecs.SAL_BreatherSpec");
                submenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
                {
                    InlineSubmenu = true,
                    SubMenuClassName = casual ? "AMM_Submenus.Salarian.AppearanceSubmenu_Salarian_CasualOutfits" : "AMM_Submenus.Salarian.AppearanceSubmenu_Salarian_CombatOutfits"
                });
            }
            else
            {
                // default to hmm for anything else
                pawnParamsConfig.SetStringValue("outfitSpecListPath", "outfitSpecs.HMM_OutfitSpec");
                pawnParamsConfig.SetStringValue("helmetSpecListPath", "OutfitSpecs.HMM_HelmetSpec");
                pawnParamsConfig.SetStringValue("breatherSpecListPath", "OutfitSpecs.HMM_BreatherSpec");
                submenuConfig.AddMenuEntry(new UScriptModels.AppearanceItemData()
                {
                    InlineSubmenu = true,
                    SubMenuClassName = casual ? "AMM_Submenus.HumanMale.AppearanceSubmenu_HumanMale_CasualOutfits" : "AMM_Submenus.HumanMale.AppearanceSubmenu_HumanMale_CombatOutfits"
                });
            }

            // these are the corpses on X57 that don't have heads under there
            // set it to full with no way to change it
            if (tag == "prc1_hmm_hymes" || tag == "prc1_hmm_mendel" || tag == "prc1_hmm_montoya" || tag == "prc1_hmm_slajs")
            {
                pawnParamsConfig.SetBoolValue("GiveFullHelmetControl", false);
                pawnParamsConfig.SetBoolValue("canChangeHelmetState", false);
                pawnParamsConfig.SetStringValue("defaultHelmetState", "full");
            }

            // others that default to on just for the aestetic
            if (tag == "sta60_assassin" || tag == "sp120_toombs")
            {
                pawnParamsConfig.SetBoolValue("GiveFullHelmetControl", false);
                pawnParamsConfig.SetStringValue("defaultHelmetState", "on");
            }

            // others that default to full
            // Durand is on a planet with no atmosphere, but she does have a head
            // same with Elanos Haliat
            // Tonn Actus is just wearing full helmet inside because he wants to
            // could include Duranr and Elanos in the must stay on camp
            // it would be even better if it forced it on via sequence, but alas
            if (tag == "UNC73_ELT_AllianceLieutenantDurand" || tag == "UNC53_Elanos" || tag == "NPCH_TonnActus")
            {
                pawnParamsConfig.SetBoolValue("GiveFullHelmetControl", false);
                pawnParamsConfig.SetStringValue("defaultHelmetState", "full");
            }

            StructCoalesceValue appearanceIdLookups = new();
            appearanceIdLookups.SetString("appearanceType", casual ? "casual" : "combat");
            appearanceIdLookups.SetString("FrameworkFileName", pawn.FileRef.FileNameNoExtension);
            var shortName = BioNPCName.Replace("BIONPC_", "");
            // a few have variants that use the same live/poll name
            shortName = shortName switch
            {
                "Helena_Citadel" => "Helena",
                "Chorban_Markets" => "Chorban",
                "Sparatus_Holo" => "Sparatus",
                "Valern_Holo" => "Valern",
                "Tevos_Holo" => "Tevos",
                "Emily_Tower" => "Emily",
                "Jenna_Flux" => "Jenna",
                "Chellick_Casual" => "Chellick",
                _ => shortName
            };
            appearanceIdLookups.SetString("FrameworkLiveEventName", $"Live_NPC_{shortName}");
            appearanceIdLookups.SetString("FrameworkPollEventName", $"Poll_NPC_{shortName}");
            appearanceIdLookups.SetStruct("bodyAppearanceLookup", new StructCoalesceValue { { "plotIntId", new IntCoalesceValue(currentPlotInt++) } });
            appearanceIdLookups.SetStruct("helmetAppearanceLookup", new StructCoalesceValue { { "plotIntId", new IntCoalesceValue(currentPlotInt++) } });
            appearanceIdLookups.SetStruct("breatherAppearanceLookup", new StructCoalesceValue { { "plotIntId", new IntCoalesceValue(currentPlotInt++) } });
            appearanceIdLookups.SetStruct("appearanceFlagsLookup", new StructCoalesceValue { { "plotIntId", new IntCoalesceValue(currentPlotInt++) } });
            pawnParamsConfig.SetStructValue("AppearanceIdLookupsList", appearanceIdLookups);

            var pawnParamsClass = new ClassToCompile($"AMM_Pawn_Parameters_{uniqueName}", $"Class AMM_Pawn_Parameters_{uniqueName} extends AMM_Pawn_Parameters config(Game); public function string GetAppearanceType(BioPawn targetPawn){{return \"{(casual ? "casual" : "combat")}\";}}");
            var normalSubmenu = new ClassToCompile($"AppearanceSubmenu_{uniqueName}", $"Class AppearanceSubmenu_{uniqueName} extends AppearanceSubmenu config(UI);");

            // add a few classes
            var classTask = new AddClassesToFile(
                _ => pcc,
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Common.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AppearanceSubmenu.uc", ["Mod_GameContent"]),
                GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Pawn_Parameters.uc", ["Mod_GameContent"]),
                pawnParamsClass,
                normalSubmenu);
            classTask.RunModTask(context);

            submenuConfig.PawnAppearanceType = casual ? "casual" : "combat";

            ConfigMergeFile.AddOrMergeClassConfig(submenuConfig);
        }

        private static bool CheckBioPawn(ExportEntry pawn)
        {
            // things I need to check for any possibly fix:
            // body/helmet meshes are not what is pointed to by the params
            // material parents are not what is pointed to by params
            // there are extra material params that affect the armor on the pawn


            var tag = pawn.GetProperty<NameProperty>("Tag");
            if (tag != null)
            {
                Console.WriteLine($"checking pawn {tag.Value} in file {pawn.FileRef.FileNameNoExtension}");
            }
            else
            {
                // this is an issue for AMM, but probably not a general problem
                Console.WriteLine($"detected a problem in {pawn.FileRef.FileNameNoExtension}; pawn at {pawn.InstancedFullPath} has no tag.");
                return false;
            }

            var behavior = GetObjectProperty(pawn, "m_oBehavior");
            var actorType = GetOptionalObjectProperty(behavior, "m_oActorType");

            if (actorType == null)
            {
                // this is more likely to be a general problem, but I am not sure; only some of the keepers seem to have this problem so far. It will cause issues spawning a preview and maybe doing a native appearance update, but I am unsure beyond that
                Console.WriteLine($"detected a problem in {pawn.FileRef.FileNameNoExtension}; pawn at {pawn.InstancedFullPath} has no actorType.");
                return false;
            }

            // config which determines which meshes get loaded for any given settings
            var appearanceConfig = GetObjectProperty(actorType, "m_oAppearance");
            var bodyConfig = GetObjectProperty(appearanceConfig, "Body");

            int armorType = 0;
            int meshVariant = 0;
            int materialVariant = 0;

            // the actual settings, ie which specific outfit to apply
            // the default is just all default settings for both
            var appearanceSettings = GetOptionalObjectProperty(actorType, "m_oAppearanceSettings");
            if (appearanceSettings != null)
            {
                ExportEntry? bodySettings = GetOptionalObjectProperty(appearanceSettings, "m_oBodySettings");
                if (bodySettings != null)
                {
                    armorType = GetEnumPropertyInt(bodySettings, "m_eArmorType");
                    meshVariant = GetIntProp(bodySettings, "m_nModelVariant");
                    materialVariant = GetIntProp(bodySettings, "m_nMaterialConfig");
                }
            }

            if (!GetExpectedMesh(armorType, meshVariant, materialVariant, bodyConfig, out var expectedMesh, out var expectedMats))
            {
                return false;
            }

            var mesh = GetObjectProperty(pawn, "Mesh");

            var actualMesh = GetObjectProperty(mesh, "SkeletalMesh").InstancedFullPath;

            if (actualMesh != expectedMesh)
            {
                Console.WriteLine($"Expected mesh: {expectedMesh}; actual mesh: {actualMesh}");
            }

            
            var mats = mesh.GetProperty<ArrayProperty<ObjectProperty>>("Materials");
            string[] actualMaterials = new string[mats.Count];

            for (int i = 0; i < mats.Count; i++)
            {
                var mat = mats[i].ResolveToEntry(pawn.FileRef);
                if (mat != null && mat.Parent == pawn && mat is ExportEntry entry)
                {
                    mat = entry.GetProperty<ObjectProperty>("Parent")?.ResolveToEntry(mat.FileRef);
                }
                actualMaterials[i] = mat?.InstancedFullPath ?? "null";
            }

            for (int i = 0; i < expectedMats.Length; i++)
            {
                if (actualMaterials.Length > i && !string.Equals(actualMaterials[i], expectedMats[i], StringComparison.OrdinalIgnoreCase))
                {
                    Console.WriteLine($"expected material {i} {expectedMats[i]}; actual {actualMaterials[i]}");
                }
            }
            return true;
        }

        private static bool GetExpectedMesh(int armorType, int meshVariant, int materialVariant, ExportEntry bodyConfig, out string expectedMesh, out string[] expectedMaterials)
        {
            expectedMesh = "";
            expectedMaterials = [];

            var appearancePrefix = bodyConfig.GetProperty<StrProperty>("AppearancePrefix");
            var armorEntry = bodyConfig.GetProperty<ArrayProperty<StructProperty>>("Armor")?[armorType];

            if (armorEntry == null)
            {
                Console.WriteLine("unable to get armor configs");
                return false;
            }
            var meshPackageName = armorEntry.GetProp<NameProperty>("m_meshPackageName");
            var materialPackageName = armorEntry.GetProp<NameProperty>("m_materialPackageName");

            var variants = armorEntry.GetProp<ArrayProperty<StructProperty>>("Variations");
            if (variants.Count < meshVariant + 1)
            {
                Console.WriteLine("missing variants");
                return false;
            }
            var meshVariantSpecs = variants[meshVariant];
            var materialsPerVariant = meshVariantSpecs.GetProp<IntProperty>("MaterialsPerVariation")?.Value ?? 0;

            var variantString = $"{GetArmorTypeName(armorType)}{CharFromInt(meshVariant)}";

            expectedMesh = $"{meshPackageName}.{variantString}.{appearancePrefix}_{variantString}_MDL";

            expectedMaterials =  new string[materialsPerVariant];

            for (int i = 0; i < materialsPerVariant; i++)
            {
                expectedMaterials[i] = $"{materialPackageName}.{variantString}.{appearancePrefix}_{variantString}_MAT_{materialVariant + 1}{CharFromInt(i)}";
            }
            return true;
        }

        private static ExportEntry GetObjectProperty(ExportEntry entry, string propName)
        {
            var result = GetOptionalObjectProperty(entry, propName);

            if ((result == null))
            {
                throw new Exception($"unexpected missing prop {propName} on {entry.InstancedFullPath} in {entry.FileRef.FileNameNoExtension}");
            }

            return result;
        }

        private static ExportEntry? GetOptionalObjectProperty(ExportEntry? entry, string propName)
        {
            return (ExportEntry?)entry?.GetProperty<ObjectProperty>(propName)?.ResolveToEntry(entry.FileRef);
        }

        private static int GetIntProp(ExportEntry entry, string propName)
        {
            return entry.GetProperty<IntProperty>(propName)?.Value ?? 0;
        }

        private static int GetEnumPropertyInt(ExportEntry entry, string propName)
        {
            var enumProp = entry.GetProperty<EnumProperty>(propName);
            if (enumProp == null)
            {
                return 0;
            }
            var enumValues = GlobalUnrealObjectInfo.GetEnumValues(entry.FileRef.Game, enumProp.EnumType);
            return enumValues.IndexOf(enumProp.Value);
        }

        private static string GetArmorTypeName(int armorType)
        {
            return armorType switch
            {
                0 => "NKD",
                1 => "CTH",
                2 => "LGT",
                3 => "MED",
                4 => "HVY",
                _ => throw new Exception($"Invalid armor type {armorType}")
            };
        }

        private static char CharFromInt(int value)
        {
            if (value < 0 || value > 25)
            {
                throw new IndexOutOfRangeException();
            }
            return (char)(value + 'a');
        }
    }
}
