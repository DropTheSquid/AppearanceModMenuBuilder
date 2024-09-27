using AppearanceModMenuBuilder.LE1.Models;
using LegendaryExplorerCore.GameFilesystem;
using LegendaryExplorerCore.Helpers;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal.Classes;
using MassEffectModBuilder;
using static AppearanceModMenuBuilder.LE1.BuildSteps.DLC.BuildSubmenuFile;
using static AppearanceModMenuBuilder.LE1.Models.VanillaArmorSet;
using static AppearanceModMenuBuilder.LE1.Models.VanillaMeshUtilities;
using AppearanceModMenuBuilder.LE1.UScriptModels;
using static AppearanceModMenuBuilder.LE1.Models.VanillaArmorSet.ArmorVariant;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class OutfitMenuBuilder : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Populating outfit menus");
            // get all vanilla armor sets (including unobtainable ones) from the 2DAs
            var armorSets = GetVanillaArmorSets();

            // add "fake" armor sets to use the unused appearances
            ModifyArmorSets(armorSets);

            // remove actual duplicates that arise from the structure of the 2DA we are reading from
            DeduplicateArmors(armorSets);

            // now enumerate all of the vanilla armor appearances for each body type
            var hmfBodyType = "HMF";
            var hmmBodyType = "HMM";
            var turBodyType = "TUR";
            var kroBodyType = "KRO";
            var qrnBodyType = "QRN";
            VanillaBodyAppearance[] HMFAppearances = [
                .. VanillaBodyAppearance.GetVanillaVariants(1, EArmorType.LGT, hmfBodyType, (16, 1), (1, 1), (1,1)),
                .. VanillaBodyAppearance.GetVanillaVariants(19, EArmorType.MED, hmfBodyType, (16, 1), (1, 1), (9,1)),
                .. VanillaBodyAppearance.GetVanillaVariants(45, EArmorType.HVY, hmfBodyType, (16, 1), (1, 1))
                ];
            // identical except there is no LGTc
            VanillaBodyAppearance[] HMMAppearances = [
                .. VanillaBodyAppearance.GetVanillaVariants(1, EArmorType.LGT, hmmBodyType, (16, 1), (1, 1)),
                .. VanillaBodyAppearance.GetVanillaVariants(19, EArmorType.MED, hmmBodyType, (16, 1), (1, 1), (9,1)),
                .. VanillaBodyAppearance.GetVanillaVariants(45, EArmorType.HVY, hmmBodyType, (16, 1), (1, 1))
                ];
            VanillaBodyAppearance[] TURAppearances = [
                // yes, I know there are two more LGTb material variants, but they are lame, they are just LED recolors that don't even match the rest of the armor so I am omitting them.
                .. VanillaBodyAppearance.GetVanillaVariants(1, EArmorType.LGT, turBodyType, (15, 1), (1, 1)),
                .. VanillaBodyAppearance.GetVanillaVariants(17, EArmorType.MED, turBodyType, (16, 1)),
                .. VanillaBodyAppearance.GetVanillaVariants(33, EArmorType.HVY, turBodyType, (15, 1))
                ];
            VanillaBodyAppearance[] KROAppearances = [
                .. VanillaBodyAppearance.GetVanillaVariants(1, EArmorType.MED, kroBodyType, (11, 1)),
                .. VanillaBodyAppearance.GetVanillaVariants(12, EArmorType.HVY, kroBodyType, (12, 1), (1,1), (3,1))
                ];
            VanillaBodyAppearance[] QRNAppearances = [
                .. VanillaBodyAppearance.GetVanillaVariants(1, EArmorType.LGT, GetVanillaArmorFileName(qrnBodyType, EArmorType.MED), "QRN_FAC", (6, 2)),
                ];

            // now go through the vanilla armor sets and match them to appearances
            foreach (var armor in armorSets)
            {
                static void matchAppearances(VanillaArmorSet armor, ArmorVariant? characterVariant, VanillaBodyAppearance[] appearances, bool playerSpecific = false)
                {
                    if (characterVariant != null)
                    {
                        if (characterVariant.LGT != null)
                        {
                            FindMatchingAppearance(appearances, characterVariant, EArmorType.LGT, armor.AppearanceOverride, armor, playerSpecific);
                        }
                        if (characterVariant.MED != null)
                        {
                            FindMatchingAppearance(appearances, characterVariant, EArmorType.MED, armor.AppearanceOverride, armor, playerSpecific);
                        }
                        if (characterVariant.HVY != null)
                        {
                            FindMatchingAppearance(appearances, characterVariant, EArmorType.HVY, armor.AppearanceOverride, armor, playerSpecific);
                        }
                        if (characterVariant.AllWeights != null)
                        {
                            FindMatchingAppearance(appearances, characterVariant, EArmorType.All, characterVariant.AllWeights.AppearanceOverride ?? armor.AppearanceOverride, armor, playerSpecific);
                        }
                    }
                }
                matchAppearances(armor, armor.HumanFemaleHenchVariant, HMFAppearances);
                matchAppearances(armor, armor.HumanMaleHenchVariant, HMMAppearances);
                matchAppearances(armor, armor.FemalePlayerVariant, HMFAppearances, true);
                matchAppearances(armor, armor.MalePlayerVariant, HMMAppearances, true);
                matchAppearances(armor, armor.AnyHumanVariant, HMFAppearances);
                matchAppearances(armor, armor.AnyPlayerVariant, HMFAppearances, true);
                matchAppearances(armor, armor.AnyHumanVariant, HMMAppearances);
                matchAppearances(armor, armor.AnyPlayerVariant, HMMAppearances, true);
                matchAppearances(armor, armor.TurianVariant, TURAppearances); 
                matchAppearances(armor, armor.KroganVariant, KROAppearances);
                matchAppearances(armor, armor.QuarianVariant, QRNAppearances);
            }

            // the code below detects unused appearances and when more than one set of armor uses the same appearance
            //CheckAppearances(HMFAppearances, "hmf");
            //CheckAppearances(HMMAppearances, "hmm");
            //// I am aware that Turian Guardian L/M duplicates appearance with Onyx (there is a Guardian H but not Onyx)
            //// I'm choosing to leave that in place, as it is not confusing
            //CheckAppearances(TURAppearances, "tur");
            //CheckAppearances(KROAppearances, "kro");
            //CheckAppearances(QRNAppearances, "qrn");

            //static void CheckAppearances(VanillaBodyAppearance[] appearances, string appearanceType)
            //{
            //    foreach (var app in appearances)
            //    {
            //        if (app.MenuEntries.IsEmpty())
            //        {
            //            Console.WriteLine($"warning: appearance {appearanceType} {app.AmmAppearanceId} {app.ArmorType} {app.ModelVariant} {app.MaterialVariant} is unused");
            //        }
            //        //checking for armors that use the same appearance as another armor
            //        if (app.MenuEntries.Count > 1)
            //        {
            //            Console.WriteLine($"warning: more than one armor is using the same appearance for appearance {appearanceType} {app.ArmorType} {app.ModelVariant} {app.MaterialVariant}");
            //            foreach (var entry in app.MenuEntries)
            //            {
            //                Console.WriteLine($"appearance: {entry.Label}");
            //            }
            //        }
            //    }
            //}

            // add all armors (including fake ones) by armor set to the menu
            AddMenuEntriesFromVanillaArmors(context, armorSets);
            AddBreatherMenuEntries(context);
        }

        private static void DeduplicateArmors(List<VanillaArmorSet> armorSets)
        {
            // confusingly, this does not remove cases where two different armor sets have the same appearance. I am leaving those alone for now
            // it does deal with cases where the human henches have the same appearance as the player, and where all humans use the same mesh/material variant, which is most of them.
            // also, cases where all weights of the same armor have the same appearance, as with many of the MEDc unobtainable armors
            foreach (var armor in armorSets)
            {
                // if the different human ones are the same, remove the duplicates
                DeduplicateCharacterVariants(armor);

                // if the different weights all have the same appearance, deduplicate that
                DeduplicateCharacterWeightVariants(armor, armor.MalePlayerVariant);
                DeduplicateCharacterWeightVariants(armor, armor.FemalePlayerVariant);
                DeduplicateCharacterWeightVariants(armor, armor.HumanMaleHenchVariant);
                DeduplicateCharacterWeightVariants(armor, armor.HumanFemaleHenchVariant);
                DeduplicateCharacterWeightVariants(armor, armor.AnyHumanVariant);
                DeduplicateCharacterWeightVariants(armor, armor.QuarianVariant);
                DeduplicateCharacterWeightVariants(armor, armor.TurianVariant);
                DeduplicateCharacterWeightVariants(armor, armor.KroganVariant);
            }

            static void DeduplicateCharacterWeightVariants(VanillaArmorSet armor, ArmorVariant? armorVariant)
            {
                if (armorVariant != null)
                {
                    var variants = armorVariant.WeightVariants;

                    if (variants.Length <= 0 || variants.Length > 3)
                    {
                        // this shouldn't happen
                        throw new InvalidOperationException();
                    }
                    else if (variants.Length == 1)
                    {
                        variants[0].AppearanceOverride = armorVariant.LGT != null ? EArmorType.LGT : armorVariant.MED != null ? EArmorType.MED : EArmorType.HVY;
                        armorVariant.AllWeights = variants[0];
                        armorVariant.LGT = null;
                        armorVariant.MED = null;
                        armorVariant.HVY = null;
                    }
                    else
                    {
                        // if the appearance type is not overridden, it is not safe to do this
                        if (!armor.AppearanceOverride.HasValue)
                        {
                            return;
                        }
                        if (AreWeightVariantsIdentical(variants[0], variants[1])
                            && (variants.Length == 2 || AreWeightVariantsIdentical(variants[1], variants[2])))
                        {
                            armorVariant.AllWeights = variants[0];
                            armorVariant.LGT = null;
                            armorVariant.MED = null;
                            armorVariant.HVY = null;
                        }
                    }
                }
            }

            static void DeduplicateCharacterVariants(VanillaArmorSet armorSet)
            {
                // if mShep and Kaidan have the same appearance, eliminate the unique Shep part
                if (AreVariantsIdentical(armorSet.MalePlayerVariant, armorSet.HumanMaleHenchVariant))
                {
                    armorSet.MalePlayerVariant = null;
                }
                // if fShep and Ashley/Liara have the same appearance, eliminate the unique Shep part
                if (AreVariantsIdentical(armorSet.FemalePlayerVariant, armorSet.HumanFemaleHenchVariant))
                {
                    armorSet.FemalePlayerVariant = null;
                }
                // if the player has an override and it is the same for both genders, combine them
                if (armorSet.MalePlayerVariant != null && AreVariantsIdentical(armorSet.MalePlayerVariant, armorSet.FemalePlayerVariant))
                {
                    armorSet.AnyPlayerVariant = armorSet.MalePlayerVariant;
                    armorSet.MalePlayerVariant = null;
                    armorSet.FemalePlayerVariant = null;
                }
                // if the hench/non player versions are identical, combine them
                // note that we can have Any Human and also AnyPlayer at the same time
                if (AreVariantsIdentical(armorSet.HumanMaleHenchVariant, armorSet.HumanFemaleHenchVariant))
                {
                    armorSet.AnyHumanVariant ??= armorSet.HumanMaleHenchVariant;
                    armorSet.HumanMaleHenchVariant = null;
                    armorSet.HumanFemaleHenchVariant = null;
                }
            }

            static bool AreVariantsIdentical(ArmorVariant? variant1, ArmorVariant? variant2)
            {
                if (variant1 == null ^ variant2 == null)
                {
                    return false;
                }
                if (variant1 == null && variant2 == null)
                {
                    return true;
                }
                // at this point, both are non null
                if (AreWeightVariantsIdentical(variant1!.LGT, variant2!.LGT)
                    && AreWeightVariantsIdentical(variant1!.MED, variant2!.MED)
                    && AreWeightVariantsIdentical(variant1!.HVY, variant2!.HVY)
                    && AreWeightVariantsIdentical(variant1!.AllWeights, variant2!.AllWeights))
                {
                    return true;
                }
                return false;
            }

            static bool AreWeightVariantsIdentical(WeightVariant? variant1, WeightVariant? variant2)
            {
                return variant1?.MeshVariant == variant2?.MeshVariant && variant1?.MaterialVariant == variant2?.MaterialVariant;
            }
        }

        private static void ModifyArmorSets(List<VanillaArmorSet> armorSets)
        {
            var thermalSet = armorSets.First(x => x.Label == "Manf_Devlon_Armor_Thermal");
            // set the name to just "Thermal"
            thermalSet.SrArmorName = 210210242;
            // asssign Turian HVYa 10 to be Thermal Armor Heavy; there is no heavy variant of this armor and it matches pretty well
            thermalSet.TurianVariant!.HVY = new WeightVariant()
            {
                //AmmAppearanceId = 44,
                MeshVariant = 0,
                MaterialVariant = 10
            };
            // assign human MEDc 4 to Thermal
            thermalSet.AnyHumanVariant = new ArmorVariant()
            {
                MED = new WeightVariant()
                {
                    //AmmAppearanceId = 40,
                    MeshVariant = 2,
                    MaterialVariant = 4
                }
            };

            // assign unused TUR HVYa 8 to Janissary
            var janissaryArmorSet = armorSets.First(x => x.Label == "Manf_HKShadow_Armor_Janissary");
            janissaryArmorSet.TurianVariant = new ArmorVariant()
            {
                HVY = new WeightVariant()
                {
                    //AmmAppearanceId = 44,
                    MeshVariant = 0,
                    MaterialVariant = 8
                }
            };

            // assign unused TUR LGTa 14 to Skirmish
            var skirmishArmorSet = armorSets.First(x => x.Label == "Manf_Batarian_Armor_Skirmish");
            skirmishArmorSet.TurianVariant = new ArmorVariant()
            {
                LGT = new WeightVariant()
                {
                    //AmmAppearanceId = 14,
                    MeshVariant = 0,
                    MaterialVariant = 14
                }
            };

            // assign unused TUR MEDa 4 to Crisis armor
            var crisisArmorSet = armorSets.First(x => x.Label == "Manf_Jorman_Armor_Crisis");
            crisisArmorSet.TurianVariant = new ArmorVariant()
            {
                MED = new WeightVariant()
                {
                    // TODO what is the appearance id?
                    MeshVariant = 0,
                    MaterialVariant = 4
                }
            };

            // assign unused TUR LGTa 6 to Freedom armor
            var freedomArmorSet = armorSets.First(x => x.Label == "Manf_Cerberus_Armor_Freedom");
            freedomArmorSet.TurianVariant = new ArmorVariant()
            {
                LGT = new WeightVariant()
                {
                    // TODO what is the appearance id?
                    MeshVariant = 0,
                    MaterialVariant = 6
                }
            };

            // assign unused TUR HVYa 4 to Hazard armor
            var hazardArmorSet = armorSets.First(x => x.Label == "Manf_Jorman_Armor_Hazard");
            hazardArmorSet.TurianVariant = new ArmorVariant()
            {
                HVY = new WeightVariant()
                {
                    // TODO what is the appearance id?
                    MeshVariant = 0,
                    MaterialVariant = 4
                }
            };

            // assign unused TUR HVYa 5 to Partisan armor
            var partisanArmorSet = armorSets.First(x => x.Label == "Manf_Batarian_Armor_Partisan");
            partisanArmorSet.TurianVariant = new ArmorVariant()
            {
                HVY = new WeightVariant()
                {
                    // TODO what is the appearance id?
                    MeshVariant = 0,
                    MaterialVariant = 5
                }
            };

            // changing from "Spectre Armor" to just "Spectre"
            var spectreArmor = armorSets.First(x => x.Label == "Manf_HKShadow_Armor_Spectre");
            spectreArmor.SrArmorName = 210210243;

            // get the onyx, separate out the player specific parts
            var onyxIndex = armorSets.FindIndex(x => x.Label == "Manf_Aldrin_Armor_Onyx");
            var onyxArmor = armorSets[onyxIndex];
            var N7Onyx = new VanillaArmorSet("AMM_N7_Onyx")
            {
                SrManufacturerName = onyxArmor.SrManufacturerName,
                // "N7 Onyx"
                SrArmorName = 210210241,
                AnyPlayerVariant = onyxArmor.MalePlayerVariant,
                AnyHumanVariant = onyxArmor.FemalePlayerVariant,
            };
            // show the player variants only for Shep and Anderson if the immersion breaking outfits setting is off/default
            N7Onyx.AnyPlayerVariant.DisplayInt = new AppearanceItemData.PlotIntSetting(1598, 0);
            N7Onyx.AnyPlayerVariant.ApplicableCharacters = ["Human_Female", "Human_Male", "sta20_captain"];
            // show for everyone if the immersion breaking outfits setting is on
            N7Onyx.AnyHumanVariant.DisplayInt = new AppearanceItemData.PlotIntSetting(1598, 1);
            armorSets.Insert(onyxIndex, N7Onyx);
            onyxArmor.MalePlayerVariant = null;
            onyxArmor.FemalePlayerVariant = null;

            // adding a fake armor set for the Asari Commando armor (HMF LGTc 0)
            armorSets.Add(new VanillaArmorSet("AMM_CommandoArmor")
            {
                // "Serrice Council"
                SrManufacturerName = 125358,
                // "Commando"
                SrArmorName = 93988,
                AppearanceOverride = EArmorType.LGT,
                HumanFemaleHenchVariant = new ArmorVariant()
                {
                    LGT = new WeightVariant()
                    {
                        //AmmAppearanceId = 18,
                        MeshVariant = 2,
                        MaterialVariant = 0
                    }
                }
            });

            // remove extraneous/confusing armor sets. there are a few sets that not only have confusing names (Predator vs Predator H, from different manufacturers) but don't even have unique appearances
            // I can clean this state of affairs up pretty easily
            var armaxPredatorHIndex = armorSets.FindIndex(x => x.Label == "Manf_Armax_Armor_Predator");
            armorSets.RemoveAt(armaxPredatorHIndex);
            var hkPredatorIndex = armorSets.FindIndex(x => x.Label == "Manf_HK_Armor_Predator");
            armorSets.RemoveAt(hkPredatorIndex);
        }

        private static void AddBreatherMenuEntries(ModBuilderContext context)
        {
            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            var (humanFemaleOutfitMenus, humanMaleOutfitMenus, asariOutfitMenus, turianOutfitMenus, _, _, _) = InitCommonMenus(configMergeFile);

            // hmf breathers
            humanFemaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Shepard"
                SrCenterText = 125303,
                ApplyBreatherId = -11
            });
            humanFemaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Ashley"
                SrCenterText = 168842,
                ApplyBreatherId = -13,
                // TODO port to male
            });
            humanFemaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Liara"
                SrCenterText = 149285,
                ApplyBreatherId = -12,
                // TODO port to male
            });
            humanFemaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Kaidan"
                SrCenterText = 151316,
                ApplyBreatherId = -14,
            });
            humanFemaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "NPC"
                SrCenterText = 210210245,
                ApplyBreatherId = -15,
            });

            // hmm breathers
            humanMaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Shepard"
                SrCenterText = 125303,
                ApplyBreatherId = -11
            });

            humanMaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Kaidan"
                SrCenterText = 151316,
                ApplyBreatherId = -14,
            });
            humanMaleOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "NPC"
                SrCenterText = 210210245,
                ApplyBreatherId = -15,
            });

            // asa breathers
            asariOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Shepard"
                SrCenterText = 125303,
                ApplyBreatherId = -11
            });
            asariOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Ashley"
                SrCenterText = 168842,
                ApplyBreatherId = -13,
            });
            asariOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Liara"
                SrCenterText = 149285,
                ApplyBreatherId = -12,
            });
            asariOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Kaidan"
                SrCenterText = 151316,
                ApplyBreatherId = -14,
            });
            asariOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "NPC"
                SrCenterText = 210210245,
                ApplyBreatherId = -15,
            });

            // default Turian LGT and HVY breather
            turianOutfitMenus.Breather.AddMenuEntry(new AppearanceItemData()
            {
                // "Turian"
                SrCenterText = 165651,
                ApplyBreatherId = -10,
            });
        }
        private static void AddMenuEntriesFromVanillaArmors(ModBuilderContext context, IEnumerable<VanillaArmorSet> armorSets)
        {
            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            var (humanFemaleOutfitMenus, humanMaleOutfitMenus, asariOutfitMenus, turianOutfitMenus, quarianOutfitMenus, kroganOutfitMenus, _) = InitCommonMenus(configMergeFile);

            foreach (var item in armorSets)
            {
                AddArmorToMenu(humanMaleOutfitMenus, item, item.MalePlayerVariant, humanoid: true);
                AddArmorToMenu(humanFemaleOutfitMenus, item, item.FemalePlayerVariant, humanoid: true);
                AddArmorToMenu(humanMaleOutfitMenus, item, item.HumanMaleHenchVariant, humanoid: true);
                AddArmorToMenu(humanFemaleOutfitMenus, item, item.HumanFemaleHenchVariant, humanoid: true);
                AddArmorToMenu(humanFemaleOutfitMenus, item, item.AnyHumanVariant, humanoid: true);
                AddArmorToMenu(humanFemaleOutfitMenus, item, item.AnyPlayerVariant, humanoid: true);
                AddArmorToMenu(humanMaleOutfitMenus, item, item.AnyHumanVariant, humanoid: true);
                AddArmorToMenu(humanMaleOutfitMenus, item, item.AnyPlayerVariant, humanoid: true);
                AddArmorToMenu(asariOutfitMenus, item, item.FemalePlayerVariant, humanoid: true);
                AddArmorToMenu(asariOutfitMenus, item, item.HumanFemaleHenchVariant, humanoid: true);
                AddArmorToMenu(asariOutfitMenus, item, item.AnyHumanVariant, humanoid: true);
                AddArmorToMenu(asariOutfitMenus, item, item.AnyPlayerVariant, humanoid: true);
                AddArmorToMenu(kroganOutfitMenus, item, item.KroganVariant);
                AddArmorToMenu(turianOutfitMenus, item, item.TurianVariant);
                AddArmorToMenu(quarianOutfitMenus, item, item.QuarianVariant, skipHelmets: true);
            }

            void AddArmorToMenu(SpeciesOutfitMenus submenu, VanillaArmorSet armorSet, ArmorVariant? variant, bool skipHelmets = false, bool humanoid = false)
            {
                const int srColossusClassic = 210210299;
                if (variant == null)
                {
                    return;
                }
                AppearanceItemData GetOutfitMenuEntry(EArmorType armorType, int? ammAppearanceId)
                {
                    if (armorType == EArmorType.All)
                    {
                        return new AppearanceItemData()
                        {
                            SrCenterText = armorSet.SrArmorName,
                            ApplyOutfitId = ammAppearanceId,
                            DisplayInt = variant.DisplayInt,
                            AApplicableCharacters = variant.ApplicableCharacters
                        };
                    }
                    else
                    {
                        return new AppearanceItemData()
                        {
                            // "<ArmorName> - <Weight>"
                            SrCenterText = 210210236,
                            ApplyOutfitId = ammAppearanceId,
                            DisplayVars = [$"${armorSet.SrArmorName}", $"${GetArmorTypeStringRef(armorType)}"],
                            DisplayInt = variant.DisplayInt,
                            AApplicableCharacters = variant.ApplicableCharacters
                        };
                    }
                }
                AppearanceItemData GetHelmetMenuEntry(EArmorType armorType, int? ammAppearanceId)
                {
                    if (armorType == EArmorType.All)
                    {
                        return new AppearanceItemData()
                        {
                            SrCenterText = armorSet.SrArmorName,
                            ApplyHelmetId = ammAppearanceId,
                            DisplayInt = variant.DisplayInt,
                            AApplicableCharacters = variant.ApplicableCharacters
                        };
                    }
                    else
                    {
                        return new AppearanceItemData()
                        {
                            // "<ArmorName> - <Weight>"
                            SrCenterText = 210210236,
                            ApplyHelmetId = ammAppearanceId,
                            DisplayVars = [$"${armorSet.SrArmorName}", $"${GetArmorTypeStringRef(armorType)}"],
                            DisplayInt = variant.DisplayInt,
                            AApplicableCharacters = variant.ApplicableCharacters
                        };
                    }
                }
                if (variant.LGT != null)
                {
                    submenu.Armor.AddMenuEntry(
                        GetOutfitMenuEntry(EArmorType.LGT, variant.LGT.AmmAppearanceId)
                    );
                    if (!skipHelmets)
                    {
                        submenu.ArmorHeadgear.AddMenuEntry(
                            GetHelmetMenuEntry(EArmorType.LGT, variant.LGT.AmmAppearanceId)
                        );
                        if (armorSet.Label == "Manf_Kassa_Armor_Colossus" && humanoid)
                        {
                            submenu.ArmorHeadgear.AddMenuEntry(
                                new AppearanceItemData()
                                {
                                    // "<ArmorName> - <Weight>"
                                    SrCenterText = 210210236,
                                    ApplyHelmetId = 62,
                                    DisplayVars = [$"${srColossusClassic}", $"${GetArmorTypeStringRef(EArmorType.LGT)}"]
                                }
                            );
                        }
                    }
                }
                if (variant.MED != null)
                {
                    submenu.Armor.AddMenuEntry(
                        GetOutfitMenuEntry(EArmorType.MED, variant.MED.AmmAppearanceId)
                    );
                    if (!skipHelmets)
                    {
                        submenu.ArmorHeadgear.AddMenuEntry(
                            GetHelmetMenuEntry(EArmorType.MED, variant.MED.AmmAppearanceId)
                        );
                        if (armorSet.Label == "Manf_Kassa_Armor_Colossus" && humanoid)
                        {
                            submenu.ArmorHeadgear.AddMenuEntry(
                                new AppearanceItemData()
                                {
                                    // "<ArmorName> - <Weight>"
                                    SrCenterText = 210210236,
                                    ApplyHelmetId = 63,
                                    DisplayVars = [$"${srColossusClassic}", $"${GetArmorTypeStringRef(EArmorType.MED)}"]
                                }
                            );
                        }
                    }
                }
                if (variant.HVY != null)
                {
                    submenu.Armor.AddMenuEntry(
                        GetOutfitMenuEntry(EArmorType.HVY, variant.HVY.AmmAppearanceId)
                    );
                    if (!skipHelmets)
                    {
                        submenu.ArmorHeadgear.AddMenuEntry(
                            GetHelmetMenuEntry(EArmorType.HVY, variant.HVY.AmmAppearanceId)
                        );
                        if (armorSet.Label == "Manf_Kassa_Armor_Colossus" && humanoid)
                        {
                            submenu.ArmorHeadgear.AddMenuEntry(
                                new AppearanceItemData()
                                {
                                    // "<ArmorName> - <Weight>"
                                    SrCenterText = 210210236,
                                    ApplyHelmetId = 64,
                                    DisplayVars = [$"${srColossusClassic}", $"${GetArmorTypeStringRef(EArmorType.HVY)}"]
                                }
                            );
                        }
                    }
                }
                if (variant.AllWeights != null)
                {
                    submenu.Armor.AddMenuEntry(
                        GetOutfitMenuEntry(EArmorType.All, variant.AllWeights.AmmAppearanceId)
                    );
                    if (!skipHelmets)
                    {
                        submenu.ArmorHeadgear.AddMenuEntry(
                            GetHelmetMenuEntry(EArmorType.All, variant.AllWeights.AmmAppearanceId)
                        );
                    }
                }
            }
        }

        private static int GetArmorTypeStringRef(EArmorType type)
        {
            return type switch
            {
                // "Light"
                EArmorType.LGT => 210210238,
                // "Medium"
                EArmorType.MED => 210210239,
                // "Heavy"
                EArmorType.HVY => 210210240,
                _ => throw new Exception("invalid armor type"),
            };
        }

        private static void FindMatchingAppearance(
            VanillaBodyAppearance[] appearances,
            ArmorVariant characterVariant,
            EArmorType armorType,
            EArmorType? appearanceOverride,
            VanillaArmorSet armor,
            bool playerSpecific = false)
        {
            var weightVariant = characterVariant.GetWeightVariant(armorType);
            var matchingAppearance = appearances.FirstOrDefault(
                                        x => x.ArmorType == (appearanceOverride ?? armorType)
                                        && x.ModelVariant == weightVariant.MeshVariant
                                        && x.MaterialVariant == weightVariant.MaterialVariant) ?? throw new Exception("could not find matching appearance");

            // add info about the vanilla armor to the appearance, which is useful for detecting unused appearances and duplicate appearances
            matchingAppearance.MenuEntries.Add(new VanillaBodyAppearance.MenuEntryDetails()
            {
                Label = armor.Label,
                SrName = armor.SrArmorName,
                SrManufacturerName = armor.SrManufacturerName,
                IsPlayerSpecific = playerSpecific,
                ArmorType = armorType
            });

            // also add the amm appearance id to the armor set, so we can enumerate those and have that ID.
            weightVariant.AmmAppearanceId = matchingAppearance.AmmAppearanceId;
        }

        private static List<VanillaArmorSet> GetVanillaArmorSets()
        {
            if (!MELoadedFiles.TryGetHighestMountedFile(MEGame.LE1, "Engine.pcc", out string packagePath))
            {
                throw new Exception("Couldn't find Engine.pcc???");
            }

            var enginePcc = MEPackageHandler.OpenMEPackage(packagePath);

            var itemEffectsLevelExport = enginePcc.FindExport("BIOG_2DA_Equipment_X.Items_ItemEffectLevels");

            var itemEffectsLevel2DA = new Bio2DA(itemEffectsLevelExport);

            var armorSets = new Dictionary<string, VanillaArmorSet>();

            for (int i = 0; i < itemEffectsLevel2DA.RowCount; i++)
            {
                // get the row name, which, since this is a Bio2DANumberedRows, will be an int, aka the manufacturer id
                //var rowName = int.Parse(itemEffectsLevel2DA.RowNames[i]);

                // get the item label
                var itemLabel = itemEffectsLevel2DA.Cells[i, 14].NameValue.ToString();
                // if this is not an armor item, skip it
                if (!IsArmorManufacturer(itemLabel))
                {
                    continue;
                }

                // column Level1
                // technically these things could vary per level but they never do for the appearance stuff I care about, so I will ignore the other levels
                var value = itemEffectsLevel2DA.Cells[i, 4].IntValue;
                // column GamePropertyLabel
                // either redundant with effect label or tells us which pawn it applies to
                // eg "GP_ArmorAppr_HenchAsariH" means Liara heavy armor
                var propertyLabel = itemEffectsLevel2DA.Cells[i, 15].NameValue.ToString();
                // tells us how to interpret the propertyLabel and value
                // whether this is the armor name stringref, the model variant, the material variant, or overridding part of the appearance
                var effectLabel = itemEffectsLevel2DA.Cells[i, 16].NameValue.ToString();

                if (!armorSets.TryGetValue(itemLabel, out VanillaArmorSet? armor))
                {
                    armor = new VanillaArmorSet(itemLabel);
                    armorSets[itemLabel] = armor;
                }

                armor.Add2DARow(effectLabel, propertyLabel, value);
            }

            return [.. armorSets.Values];
        }
        private static bool IsArmorManufacturer(string manufacturer)
        {
            return manufacturer.StartsWith("Manf") && manufacturer.Contains("_Armor_");
        }
    }
}
