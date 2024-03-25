using AppearanceModMenuBuilder.LE1.Models;
using LegendaryExplorerCore.GameFilesystem;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal.Classes;
using MassEffectModBuilder;
using static AppearanceModMenuBuilder.LE1.Models.VanillaMeshUtilities;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class NewArmorSpecListBuilder : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            // get all vanilla armor sets (including unobtainable ones) from the 2DAs
            var armorSets = GetVanillaArmorSets();

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

            // now go through the vanilla armor sets and matche them to appearances
            foreach (var armor in armorSets)
            {
                static void matchAppearances(VanillaArmorSet armor, VanillaArmorSet.ArmorVariant? characterVariant, VanillaBodyAppearance[] appearances, bool playerSpecific = false)
                {
                    if (characterVariant != null)
                    {
                        EArmorType[] displayArmorTypes;
                        if (armor.AppearanceOverride != null)
                        {
                            // TODO should I just call it once with the override?
                            // that would work unless it still picks different ones per weight. 
                            displayArmorTypes = [armor.AppearanceOverride.Value, armor.AppearanceOverride.Value, armor.AppearanceOverride.Value];
                        }
                        else
                        {
                            displayArmorTypes = [EArmorType.LGT, EArmorType.MED, EArmorType.HVY];
                        }
                        if (characterVariant.LGT != null)
                        {
                            AddMenuEntryForMatchingAppearance(appearances, characterVariant, displayArmorTypes[0], armor, playerSpecific);
                        }
                        if (characterVariant.MED != null)
                        {
                            AddMenuEntryForMatchingAppearance(appearances, characterVariant, displayArmorTypes[1], armor, playerSpecific);
                        }
                        if (characterVariant.HVY != null)
                        {
                            AddMenuEntryForMatchingAppearance(appearances, characterVariant, displayArmorTypes[2], armor, playerSpecific);
                        }
                    }
                }
                matchAppearances(armor, armor.HumanHenchVariant, HMFAppearances);
                matchAppearances(armor, armor.HumanHenchVariant, HMMAppearances);
                matchAppearances(armor, armor.PlayerVariant, HMFAppearances, true);
                matchAppearances(armor, armor.PlayerVariant, HMMAppearances, true);
                matchAppearances(armor, armor.TurianVariant, TURAppearances);
                matchAppearances(armor, armor.KroganVariant, KROAppearances);
                matchAppearances(armor, armor.QuarianVariant, QRNAppearances);
            }

            //CheckAppearances(HMFAppearances, "hmf");
            //CheckAppearances(HMMAppearances, "hmm");
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
            //            if (app.MenuEntries.Count == 2
            //                && app.MenuEntries[0].IsPlayerSpecific != app.MenuEntries[1].IsPlayerSpecific)
            //            {
            //                continue;
            //            }
            //            Console.WriteLine($"warning: more than one armor is using the same appearance for appearance {appearanceType} {app.ArmorType} {app.ModelVariant} {app.MaterialVariant}");
            //            foreach (var entry in app.MenuEntries)
            //            {
            //                Console.WriteLine($"appearance: {entry.Label}");
            //            }
            //        }
            //    }
            //}
        }

        private static void AddMenuEntryForMatchingAppearance(
            VanillaBodyAppearance[] appearances,
            VanillaArmorSet.ArmorVariant characterVariant,
            EArmorType armorType,
            VanillaArmorSet armor,
            bool playerSpecific = false)
        {
            var weightVariant = characterVariant.GetWeightVariant(armorType);
            var matchingAppearance = appearances.FirstOrDefault(
                                        x => x.ArmorType == armorType
                                        && x.ModelVariant == weightVariant.MeshVariant
                                        && x.MaterialVariant == weightVariant.MaterialVariant);

            if (matchingAppearance == null)
            {
                throw new Exception("could not find matching appearance");
            }

            // add info about the vanilla armor to the appearance, which is useful for detecting unused appearances and duplicate appearances
            matchingAppearance.MenuEntries.Add(new VanillaBodyAppearance.MenuEntryDetails()
            {
                Label = armor.Label,
                SrName = armor.SrArmorName,
                SrManufacturerName = armor.SrManufacturerName,
                IsPlayerSpecific = playerSpecific
            });

            // also add the amm appearance id to the armor set, so we can enumerate those and have that ID. 
            weightVariant.AmmAppearanceId = matchingAppearance.AmmAppearanceId;
        }

        private VanillaArmorSet[] GetVanillaArmorSets()
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

            return armorSets.Values.ToArray();
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
