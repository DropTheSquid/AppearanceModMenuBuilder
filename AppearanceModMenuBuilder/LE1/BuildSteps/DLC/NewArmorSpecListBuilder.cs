using AppearanceModMenuBuilder.LE1.Models;
using LegendaryExplorerCore.GameFilesystem;
using LegendaryExplorerCore.Helpers;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal.Classes;
using MassEffectModBuilder;
using static AppearanceModMenuBuilder.LE1.Models.AppearanceItemData;
using static AppearanceModMenuBuilder.LE1.Models.VanillaArmorSet;
using static AppearanceModMenuBuilder.LE1.Models.VanillaMeshUtilities;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class NewArmorSpecListBuilder : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            // get all vanilla armor sets (including unobtainable ones) from the 2DAs
            var armorSets = GetVanillaArmorSets();

            // add "fake" armor sets to use the unused appearances
            AddFakeArmorSets(armorSets);
            // TODO consolidate together the armors that always look the same?

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
            VanillaBodyAppearance[] HMMAppearances = [
                .. VanillaBodyAppearance.GetVanillaVariants(1, EArmorType.LGT, hmmBodyType, (16, 1), (1, 1)),
                .. VanillaBodyAppearance.GetVanillaVariants(19, EArmorType.MED, hmmBodyType, (16, 1), (1, 1), (9,1)),
                .. VanillaBodyAppearance.GetVanillaVariants(45, EArmorType.HVY, hmmBodyType, (16, 1), (1, 1))
                ];
            VanillaBodyAppearance[] TURAppearances = [
                .. VanillaBodyAppearance.GetVanillaVariants(1, EArmorType.LGT, turBodyType, (15, 1), (3, 1)),
                .. VanillaBodyAppearance.GetVanillaVariants(19, EArmorType.MED, turBodyType, (16, 1)),
                .. VanillaBodyAppearance.GetVanillaVariants(35, EArmorType.HVY, turBodyType, (15, 1))
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
                            FindMatchingAppearance(appearances, characterVariant, EArmorType.All, armor.AppearanceOverride, armor, playerSpecific);
                        }
                    }
                }
                matchAppearances(armor, armor.HumanFemaleHenchVariant, HMFAppearances);
                matchAppearances(armor, armor.HumanMaleHenchVariant, HMMAppearances);
                matchAppearances(armor, armor.FemalePlayerVariant, HMFAppearances, true);
                matchAppearances(armor, armor.MalePlayerVariant, HMMAppearances, true);
                matchAppearances(armor, armor.AnyHumanVariant, HMFAppearances);
                matchAppearances(armor, armor.AnyPlayerVariant, HMFAppearances, true);
                matchAppearances(armor, armor.TurianVariant, TURAppearances);
                matchAppearances(armor, armor.KroganVariant, KROAppearances);
                matchAppearances(armor, armor.QuarianVariant, QRNAppearances);
            }

            // the code below detects unused appearances and when more than one set of armor uses the same appearance
            CheckAppearances(HMFAppearances, "hmf");
            //CheckAppearances(HMMAppearances, "hmm");
            CheckAppearances(TURAppearances, "tur");
            CheckAppearances(KROAppearances, "kro");
            CheckAppearances(QRNAppearances, "qrn");

            static void CheckAppearances(VanillaBodyAppearance[] appearances, string appearanceType)
            {
                foreach (var app in appearances)
                {
                    if (app.MenuEntries.IsEmpty())
                    {
                        Console.WriteLine($"warning: appearance {appearanceType} {app.AmmAppearanceId} {app.ArmorType} {app.ModelVariant} {app.MaterialVariant} is unused");
                    }
                    //checking for armors that use the same appearance as another armor
                    if (app.MenuEntries.Count > 1)
                    {
                        if (app.MenuEntries.Count == 2
                            && app.MenuEntries[0].IsPlayerSpecific != app.MenuEntries[1].IsPlayerSpecific)
                        {
                            continue;
                        }
                        Console.WriteLine($"warning: more than one armor is using the same appearance for appearance {appearanceType} {app.ArmorType} {app.ModelVariant} {app.MaterialVariant}");
                        foreach (var entry in app.MenuEntries)
                        {
                            Console.WriteLine($"appearance: {entry.Label}");
                        }
                    }
                }
            }

            // add all unused appearances to the menu
            AddUnusedAppearances(context, HMFAppearances, HMMAppearances, TURAppearances, KROAppearances, QRNAppearances);
            // add all armors (including fake ones) by armor set to the menu
            AddMenuEntriesFromVanillaArmors(context, armorSets);
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
                if (armor.AppearanceOverride != null)
                {
                    DeduplicateCharacterWeightVariants(armor.MalePlayerVariant);
                    DeduplicateCharacterWeightVariants(armor.FemalePlayerVariant);
                    DeduplicateCharacterWeightVariants(armor.HumanMaleHenchVariant);
                    DeduplicateCharacterWeightVariants(armor.HumanFemaleHenchVariant);
                    DeduplicateCharacterWeightVariants(armor.AnyHumanVariant);
                    DeduplicateCharacterWeightVariants(armor.QuarianVariant);
                    DeduplicateCharacterWeightVariants(armor.TurianVariant);
                    DeduplicateCharacterWeightVariants(armor.KroganVariant);
                }

            }

            static void DeduplicateCharacterWeightVariants(ArmorVariant? armorVariant)
            {
                if (armorVariant != null)
                {
                    int numWeightVariants = armorVariant.NumberOfWeightVariants;
                    if (numWeightVariants <= 0 || numWeightVariants > 3)
                    {
                        // this shouldn't happen
                        throw new InvalidOperationException();
                    }
                    else if (numWeightVariants == 1)
                    {
                        var weightVar = armorVariant.LGT ?? armorVariant.MED ?? armorVariant.HVY;
                        armorVariant.AllWeights = weightVar;
                        armorVariant.LGT = null;
                        armorVariant.MED = null;
                        armorVariant.HVY = null;
                    }
                    else if (numWeightVariants == 2)
                    {
                        ArmorVariant.WeightVariant first;
                        ArmorVariant.WeightVariant second;
                        if (armorVariant.LGT == null)
                        {
                            first = armorVariant.MED!;
                            second = armorVariant.HVY!;
                        }
                        else if (armorVariant.MED == null)
                        {
                            first = armorVariant.LGT!;
                            second = armorVariant.HVY!;
                        }
                        else
                        {
                            first = armorVariant.LGT!;
                            second = armorVariant.MED!;
                        }
                        if (AreWeightVariantsIdentical(first, second))
                        {
                            armorVariant.AllWeights = first;
                            armorVariant.LGT = null;
                            armorVariant.MED = null;
                            armorVariant.HVY = null;
                        }
                    }
                    else
                    {
                        if (AreWeightVariantsIdentical(armorVariant.LGT, armorVariant.MED) && AreWeightVariantsIdentical(armorVariant.MED, armorVariant.HVY))
                        {
                            armorVariant.AllWeights = armorVariant.LGT;
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

            static bool AreWeightVariantsIdentical(ArmorVariant.WeightVariant? variant1, ArmorVariant.WeightVariant? variant2)
            {
                return variant1?.MeshVariant == variant2?.MeshVariant && variant1?.MaterialVariant == variant2?.MaterialVariant;
            }
        }

        private static void AddFakeArmorSets(List<VanillaArmorSet> armorSets)
        {
            // asssign Turian HVYa 10 to be Thermal Armor Heavy; there is no heavy variant of this armor and it matches pretty well
            var turianThermalSet = armorSets.First(x => x.SrArmorName == 171735 && x.TurianVariant != null);
            // "Thermal"
            turianThermalSet.SrArmorName = 210210242;
            turianThermalSet.TurianVariant!.HVY = new ArmorVariant.WeightVariant()
            {
                //AmmAppearanceId = 44,
                MeshVariant = 0,
                MaterialVariant = 10
            };

            // assign Turian HVYa 8 to be Silverback heavy; there is no heavy variant and it matches well
            var turianSilverbackSet = armorSets.First(x => x.SrArmorName == 172517 && x.TurianVariant != null);
            turianSilverbackSet.TurianVariant!.HVY = new ArmorVariant.WeightVariant()
            {
                //AmmAppearanceId = 44,
                MeshVariant = 0,
                MaterialVariant = 8
            };

            // changing from "Spectre Armor" to just "Spectre"
            var spectreArmor = armorSets.First(x => x.SrArmorName == 174134);
            spectreArmor.SrArmorName = 210210243;

            // get the onyx, separate out the player specific parts

            var onyxIndex = armorSets.FindIndex(x => x.SrArmorName == 143390);
            var onyxArmor = armorSets[onyxIndex];
            armorSets.Insert(onyxIndex, new VanillaArmorSet("AMM_N7_Onyx")
            {
                SrManufacturerName = onyxArmor.SrManufacturerName,
                // "N7 Onyx"
                SrArmorName = 210210241,
                MalePlayerVariant = onyxArmor.MalePlayerVariant,
                FemalePlayerVariant = onyxArmor.FemalePlayerVariant
            });
            onyxArmor.MalePlayerVariant = null;
            onyxArmor.FemalePlayerVariant = null;

            // adding a fake armor set for human armor 40 (MEDc 4; yellow and gray)
            armorSets.Add(new VanillaArmorSet("AMM_DevlonThermal")
            {
                // "Thermal"
                SrArmorName = 210210242,
                // "Devlon Industries"
                SrManufacturerName = 125360,
                AppearanceOverride = EArmorType.MED,
                AnyHumanVariant = new ArmorVariant()
                {
                    MED = new ArmorVariant.WeightVariant()
                    {
                        //AmmAppearanceId = 40,
                        MeshVariant = 2,
                        MaterialVariant = 4
                    }
                }
            });

            // adding a fake armor set for the Asari Commando armor (HMF LGTc 0)
            armorSets.Add(new VanillaArmorSet("AMM_CommandoArmor")
            {
                // "Armali Council"
                SrManufacturerName = 125361,
                // "Commando"
                SrArmorName = 93988,
                AppearanceOverride = EArmorType.LGT,
                HumanFemaleHenchVariant = new ArmorVariant()
                {
                    LGT = new ArmorVariant.WeightVariant()
                    {
                        //AmmAppearanceId = 18,
                        MeshVariant = 2,
                        MaterialVariant = 0
                    }
                }
            });
        }

        private static void AddMenuEntriesFromVanillaArmors(ModBuilderContext context, IEnumerable<VanillaArmorSet> armorSets)
        {
            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            var (humanOutfitMenus, turianOutfitMenus, quarianOutfitMenus, kroganOutfitMenus) = BuildSubmenuFile.InitCommonMenus(configMergeFile);

            foreach (var item in armorSets)
            {
                AddArmorToMenu(humanOutfitMenus.Armor, item, item.MalePlayerVariant, EGender.Male);
                AddArmorToMenu(humanOutfitMenus.Armor, item, item.FemalePlayerVariant, EGender.Female);
                AddArmorToMenu(humanOutfitMenus.Armor, item, item.HumanMaleHenchVariant, EGender.Male);
                AddArmorToMenu(humanOutfitMenus.Armor, item, item.HumanFemaleHenchVariant, EGender.Female);
                AddArmorToMenu(humanOutfitMenus.Armor, item, item.AnyHumanVariant);
                AddArmorToMenu(humanOutfitMenus.Armor, item, item.AnyPlayerVariant);
                AddArmorToMenu(kroganOutfitMenus.Armor, item, item.KroganVariant);
                AddArmorToMenu(turianOutfitMenus.Armor, item, item.TurianVariant);
                AddArmorToMenu(quarianOutfitMenus.Armor, item, item.QuarianVariant);
            }

            void AddArmorToMenu(AppearanceSubmenu submenu, VanillaArmorSet armorSet, ArmorVariant? variant, EGender? gender = null)
            {
                if (variant == null)
                {
                    return;
                }
                AppearanceItemData GetMenuEntry(EArmorType armorType, int? ammAppearanceId)
                {
                    var result = new AppearanceItemData()
                    {
                        Gender = gender,
                        SrCenterText = 210210236,
                        ApplyOutfitId = ammAppearanceId,
                        DisplayVars = [$"${armorSet.SrManufacturerName}", $"${armorSet.SrArmorName}"]
                    };
                    if (armorType != EArmorType.All)
                    {
                        result.SrCenterText = 210210237;
                        result.DisplayVars = [.. result.DisplayVars, $"${GetArmorTypeStringRef(armorType)}"];
                    }
                    return result;
                }
                if (variant.LGT != null)
                {
                    submenu.AddMenuEntry(
                        GetMenuEntry(EArmorType.LGT, variant.LGT.AmmAppearanceId)
                    );
                }
                if (variant.MED != null)
                {
                    submenu.AddMenuEntry(
                        GetMenuEntry(EArmorType.MED, variant.MED.AmmAppearanceId)
                    );
                }
                if (variant.HVY != null)
                {
                    submenu.AddMenuEntry(
                        GetMenuEntry(EArmorType.HVY, variant.HVY.AmmAppearanceId)
                    );
                }
                if (variant.AllWeights != null)
                {
                    submenu.AddMenuEntry(
                        GetMenuEntry(EArmorType.All, variant.AllWeights.AmmAppearanceId)
                    );
                }
            }
        }

        private static void AddUnusedAppearances(ModBuilderContext context, IEnumerable<VanillaBodyAppearance> hmf, IEnumerable<VanillaBodyAppearance> hmm, IEnumerable<VanillaBodyAppearance> tur, IEnumerable<VanillaBodyAppearance> kro, IEnumerable<VanillaBodyAppearance> qrn)
        {
            var configMergeFile = context.GetOrCreateConfigMergeFile("ConfigDelta-amm_Submenus.m3cd");

            var (humanOutfitMenus, turianOutfitMenus, quarianOutfitMenus, kroganOutfitMenus) = BuildSubmenuFile.InitCommonMenus(configMergeFile);

            //AddEntries(humanOutfitMenus, hmf, EGender.Female);
            //AddEntries(humanOutfitMenus, hmm, EGender.Male);
            AddEntries(turianOutfitMenus, tur, EGender.Male);
            AddEntries(kroganOutfitMenus, kro, EGender.Male);
            AddEntries(quarianOutfitMenus, qrn, EGender.Female);

            static void AddEntries(BuildSubmenuFile.SpeciesOutfitMenus menus, IEnumerable<VanillaBodyAppearance> appearances, EGender gender = EGender.Either)
            {
                foreach (var appearance in appearances)
                {
                    if (appearance.MenuEntries == null || appearance.MenuEntries.Count == 0)
                    {
                        menus.Armor.AddMenuEntry(new AppearanceItemData()
                        {
                            Gender = gender,
                            // "<Blank1> <Blank2>"
                            SrCenterText = 210210236,
                            ApplyOutfitId = appearance.AmmAppearanceId,
                            // fills in the blank
                            DisplayVars = ["unused appearance", $"{appearance.ArmorType} {appearance.ModelVariant} {appearance.MaterialVariant}"]
                        });
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

        private List<VanillaArmorSet> GetVanillaArmorSets()
        {
            // get an index of all the manufacturers so we can match up the names
            var manufacturers = GetArmorManufacturers();

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
                // I can ignore the armor weight, as appearance stuff does not vary between weights
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

            // at this point I should have a complete inventory of the armors
            // add the manufacturer labels
            foreach (var armor in armorSets.Values)
            {
                armor.SrManufacturerName = manufacturers[armor.Label!];
            }

            return [.. armorSets.Values];
        }

        private Dictionary<string, int> GetArmorManufacturers()
        {
            if (!MELoadedFiles.TryGetHighestMountedFile(MEGame.LE1, "Engine.pcc", out string packagePath))
            {
                throw new Exception("Couldn't find Engine.pcc???");
            }

            var enginePcc = MEPackageHandler.OpenMEPackage(packagePath);

            var manufacturersExport = enginePcc.FindExport("BIOG_2DA_Equipment_X.Items_Manufacturer");

            var manufacturers2DA = new Bio2DA(manufacturersExport);
            var results = new Dictionary<string, int>();


            for (int i = 0; i < manufacturers2DA.RowCount; i++)
            {
                // get the row name, which, since this is a Bio2DANumberedRows, will be an int, aka the manufacturer id
                //var rowName = int.Parse(manufacturers2DA.RowNames[i]);

                // get the string value from column 0, the manufacturer label
                var label = manufacturers2DA.Cells[i, 0].NameValue;
                // filter it to just the armor manufacturers
                if (!IsArmorManufacturer(label))
                {
                    continue;
                }
                // get the stringref (int) from column 1 for the name of the manufacturer
                var name = manufacturers2DA.Cells[i, 1].IntValue;

                results.Add(label, name);
            }
            return results;
        }

        public static bool IsArmorManufacturer(string manufacturer)
        {
            return manufacturer.StartsWith("Manf") && manufacturer.Contains("_Armor_");
        }
    }
}
