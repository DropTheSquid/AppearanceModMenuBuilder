using AppearanceModMenuBuilder.LE1.Models;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.Models;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class OutfitSpecListBuilder : IModBuilderTask
    {
        public enum OutfitType
        {
            NKD,
            CTH,
            LGT,
            MED,
            HVY
        }

        private const string OutfitSpecListClassTemplate = "Class {0} extends OutfitSpecListBase config(Game);";
        private const string ConfigMergeName = "outfits";
        private const string containingPackage = "OutfitSpecs";
        private readonly List<ClassToCompile> classes = [];
        private readonly List<ModConfigClass> configs = [];
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("Building outfit lists");
            var startup = context.GetStartupFile();

            GenerateHMFSpecs();
            GenerateHMMSpecs();
            GenerateTURSpecs();
            GenerateKROSpecs();
            GenerateQRNSpecs();
            // TODO other ones to possibly add:
            // Female Turian, Volus, Salarian, Elcor, Hanar, male Quarian, Vorcha

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
            const string bodyType = "HMF";
            const string className = "HMF_OutfitSpec";

            // add the source code needed
            AddOutfitListClass(className);

            // now generate the configs
            var config = GetOutfitListConfig(className);

            var LgtFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);
            var MedFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var NkdFileName = GetVanillaArmorFileName(bodyType, OutfitType.NKD);
            var CthFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            AddVanillaOutfitSpecs(config, 1,  LgtFileName, OutfitType.LGT, 0, bodyType, 16, 1, "Vanilla LGTa variants; Most Light armor appearances fall under this");
            AddVanillaOutfitSpecs(config, 17, LgtFileName, OutfitType.LGT, 1, bodyType, 1, 1, "Vanilla LGTb; This is the N7 Onyx Armor that Shepard wears");
            AddVanillaOutfitSpecs(config, 18, LgtFileName, OutfitType.LGT, 2, bodyType, 1, 1, "Vanilla LGTc; This is the Asari Commando armor, normally not ever used by player characters; only used by NPC Asari");

            AddVanillaOutfitSpecs(config, 19, MedFileName, OutfitType.MED, 0, bodyType, 16, 1, "Vanilla MEDa variants; Most Medium armor appearances fall under this");
            AddVanillaOutfitSpecs(config, 35, MedFileName, OutfitType.MED, 1, bodyType, 1, 1, "Vanilla MEDb; this is the N7 Onyx armor that Shepard wears");
            AddVanillaOutfitSpecs(config, 36, MedFileName, OutfitType.MED, 2, bodyType, 9, 1, "Asymmetric tintable armor. Not used by any equipment obtainable in vanilla or by any NPCs");

            AddVanillaOutfitSpecs(config, 45, HvyFileName, OutfitType.HVY, 0, bodyType, 16, 1, "Vanilla HVYa variants. Most heavy armor falls under this");
            AddVanillaOutfitSpecs(config, 61, HvyFileName, OutfitType.HVY, 1, bodyType, 1, 1, "Vanilla HVYb. This is the N7 Onyx Armor Shepard wears");

            // Add NKD and CTH vanilla meshes (100-140)
            AddVanillaOutfitSpecs(config, 100, NkdFileName, OutfitType.NKD, 0, bodyType, 2, 1, "Vanilla NKDa; material 1 is just a naked human; material 2 is the Avina material");
            AddVanillaOutfitSpecs(config, 102, NkdFileName, OutfitType.NKD, 1, bodyType, 1, 1, "Vanilla NKDb; dancer with tintable skintone");
            AddVanillaOutfitSpecs(config, 103, NkdFileName, OutfitType.NKD, 2, bodyType, 1, 1, "Vanilla NKDc; Liara romance mesh");

            AddVanillaOutfitSpecs(config, 104, CthFileName, OutfitType.CTH, 0, bodyType, 6, 1, "Vanilla CTHa; Alliance Formal");
            AddVanillaOutfitSpecs(config, 110, CthFileName, OutfitType.CTH, 1, bodyType, 5, 1, "Vanilla CTHb; ME1 Alliance Fatigues");
            AddVanillaOutfitSpecs(config, 115, CthFileName, OutfitType.CTH, 2, bodyType, 6, 1, "Vanilla CTHc; dress 1");
            AddVanillaOutfitSpecs(config, 121, CthFileName, OutfitType.CTH, 3, bodyType, 6, 1, "Vanilla CTHd; dress 2");
            AddVanillaOutfitSpecs(config, 127, CthFileName, OutfitType.CTH, 4, bodyType, 2, 1, "Vanilla CTHe; Civilian clothes 1");
            AddVanillaOutfitSpecs(config, 129, CthFileName, OutfitType.CTH, 5, bodyType, 4, 1, "Vanilla CTHf; Civilian clothes 2");
            AddVanillaOutfitSpecs(config, 133, CthFileName, OutfitType.CTH, 6, bodyType, 1, 1, "Vanilla CTHg; dress 3");
            AddVanillaOutfitSpecs(config, 134, CthFileName, OutfitType.CTH, 7, bodyType, 7, 1, "Vanilla CTHh; scientist/medical uniform");

            // TODO extended Vanilla specs, add them into menus

            configs.Add(config);
        }

        private void GenerateHMMSpecs()
        {
            const string bodyType = "HMM";
            const string className = "HMM_OutfitSpec";

            // add the source code needed
            AddOutfitListClass(className);

            // now generate the configs
            var config = GetOutfitListConfig(className);

            var LgtFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);
            var MedFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var NkdFileName = GetVanillaArmorFileName(bodyType, OutfitType.NKD);
            var CthFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61); matches HMF ids
            AddVanillaOutfitSpecs(config, 1,  LgtFileName, OutfitType.LGT, 0, bodyType, 16, 1, "Vanilla LGTa variants; Most Light armor appearances fall under this");
            AddVanillaOutfitSpecs(config, 17, LgtFileName, OutfitType.LGT, 1, bodyType, 1, 1, "Vanilla LGTb; This is the N7 Onyx Armor that Shepard wears");
            // Note that there is no LGTc for HMM

            AddVanillaOutfitSpecs(config, 19, MedFileName, OutfitType.MED, 0, bodyType, 16, 1, "Vanilla MEDa variants; Most Medium armor appearances fall under this");
            AddVanillaOutfitSpecs(config, 35, MedFileName, OutfitType.MED, 1, bodyType, 1, 1, "Vanilla MEDb; this is the N7 Onyx armor that Shepard wears");
            AddVanillaOutfitSpecs(config, 36, MedFileName, OutfitType.MED, 2, bodyType, 9, 1, "Asymmetric tintable armor. Not used by any equipment obtainable in vanilla or by any NPCs");

            AddVanillaOutfitSpecs(config, 45, HvyFileName, OutfitType.HVY, 0, bodyType, 16, 1, "Vanilla HVYa variants. Most heavy armor falls under this");
            AddVanillaOutfitSpecs(config, 61, HvyFileName, OutfitType.HVY, 1, bodyType, 1, 1, "Vanilla HVYb. This is the N7 Onyx Armor Shepard wears");

            // Add NKD and CTH vanilla meshes (100-140)
            AddVanillaOutfitSpecs(config, 100, NkdFileName, OutfitType.NKD, 0, bodyType, 2, 1, "Vanilla NKDa; material 1 is just a naked human; material 2 is the VI material");

            // there is a missing material in HMM CTHa; it only has 1, 2, 3, and 5
            AddVanillaOutfitSpecs(config, 102, CthFileName, OutfitType.CTH, 0, bodyType, 5, 1, "Vanilla CTHa; Alliance Formal");
            AddVanillaOutfitSpecs(config, 107, CthFileName, OutfitType.CTH, 1, bodyType, 6, 1, "Vanilla CTHb; ME1 Alliance Fatigues");
            AddVanillaOutfitSpecs(config, 113, CthFileName, OutfitType.CTH, 2, bodyType, 5, 1, "Vanilla CTHc; Civilian clothes 1");
            AddVanillaOutfitSpecs(config, 118, CthFileName, OutfitType.CTH, 3, bodyType, 3, 1, "Vanilla CTHd; Civilian Clothes 2");
            AddVanillaOutfitSpecs(config, 121, CthFileName, OutfitType.CTH, 4, bodyType, 3, 1, "Vanilla CTHe; Civilian clothes 3");
            AddVanillaOutfitSpecs(config, 124, CthFileName, OutfitType.CTH, 5, bodyType, 3, 1, "Vanilla CTHf; Civilian clothes 4");
            AddVanillaOutfitSpecs(config, 127, CthFileName, OutfitType.CTH, 6, bodyType, 2, 1, "Vanilla CTHg; Civilian clothes 5");
            AddVanillaOutfitSpecs(config, 129, CthFileName, OutfitType.CTH, 7, bodyType, 2, 1, "Vanilla CTHh; scientist/medical uniform");

            // TODO add extended vanilla meshes

            configs.Add(config);
        }

        private void GenerateKROSpecs()
        {
            const string bodyType = "KRO";
            const string className = "KRO_OutfitSpec";

            // add the source code needed
            AddOutfitListClass(className);

            // now generate the configs
            var config = GetOutfitListConfig(className);
            
            var MedFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var CthFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            AddVanillaOutfitSpecs(config, 1, MedFileName, OutfitType.MED, 0, bodyType, 11, 1, "Vanilla MEDa");

            AddVanillaOutfitSpecs(config, 12, HvyFileName, OutfitType.HVY, 0, bodyType, 12, 1, "Vanilla HVYa");
            AddVanillaOutfitSpecs(config, 24, HvyFileName, OutfitType.HVY, 1, bodyType, 1, 1, "Vanilla HVYb");
            AddVanillaOutfitSpecs(config, 25, HvyFileName, OutfitType.HVY, 2, bodyType, 3, 1, "Vanilla HVYc");

            // Add CTH vanilla meshes (100-105)
            AddVanillaOutfitSpecs(config, 100, CthFileName, OutfitType.CTH, 0, bodyType, 5, 1, "Krogan Vanilla Casual Clothes");

            // TODO add extended vanilla meshes
            configs.Add(config);
        }

        private void GenerateTURSpecs()
        {
            const string bodyType = "TUR";
            const string className = "TUR_OutfitSpec";

            // add the source code needed
            AddOutfitListClass(className);

            // now generate the configs
            var config = GetOutfitListConfig(className);

            var LgtFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);
            var MedFileName = GetVanillaArmorFileName(bodyType, OutfitType.MED);
            var HvyFileName = GetVanillaArmorFileName(bodyType, OutfitType.HVY);
            var CthFileName = GetVanillaArmorFileName(bodyType, OutfitType.CTH);

            // add all vanilla armor variants into positive IDs less than 100
            AddVanillaOutfitSpecs(config, 1,  LgtFileName, OutfitType.LGT, 0, bodyType, 15, 1, "Vanilla LGTa");
            AddVanillaOutfitSpecs(config, 16, LgtFileName, OutfitType.LGT, 1, bodyType, 3, 1, "Vanilla LGTb");

            AddVanillaOutfitSpecs(config, 19, MedFileName, OutfitType.MED, 0, bodyType, 16, 1, "Vanilla MEDa variants");

            AddVanillaOutfitSpecs(config, 35, HvyFileName, OutfitType.HVY, 0, bodyType, 15, 1, "Vanilla HVYa variants");

            // Add CTH vanilla meshes (100+)
            AddVanillaOutfitSpecs(config, 100, CthFileName, OutfitType.CTH, 0, bodyType, 5, 1, "Vanilla CTHa; Alliance Formal");
            AddVanillaOutfitSpecs(config, 105, CthFileName, OutfitType.CTH, 1, bodyType, 4, 1, "Vanilla CTHb; ME1 Alliance Fatigues");
            AddVanillaOutfitSpecs(config, 109, CthFileName, OutfitType.CTH, 2, bodyType, 5, 1, "Vanilla CTHc; dress 1");

            // TODO add extended vanilla meshes
            configs.Add(config);
        }

        private void GenerateQRNSpecs()
        {
            const string bodyType = "QRN";
            const string className = "QRN_OutfitSpec";

            // add the source code needed
            AddOutfitListClass(className);

            // now generate the configs
            var config = GetOutfitListConfig(className);

            var LgtFileName = GetVanillaArmorFileName(bodyType, OutfitType.LGT);

            // add all vanilla armor variants into positive IDs less than 100
            AddVanillaOutfitSpecs(config, 1, LgtFileName, OutfitType.LGT, 0, bodyType, 6, 2, "Vanilla LGTa");

            // TODO add extended vanilla meshes
            configs.Add(config);
        }


        private static void AddVanillaOutfitSpecs(ModConfigClass configToAddTo, int startingId, string packagePrefix, OutfitType type, int meshVariant, string bodyTypePrefix, int modelVariants, int materialsPerVariant, string comment = "")
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
                    // where 1 is the variant, and a/b is the material number within the variant
                    materials[j] = $"{sharedPrefix}_Mat_{i + 1}{CharFromInt(j)}";
                }

                specs[i] = new SimpleOutfitSpecItem(id, mesh, materials);
            }

            configToAddTo.AddArrayEntries("outfitSpecs", specs.Select(x => x.OutputValue()));
        }

        private static char CharFromInt(int value)
        {
            if (value < 0 || value > 25)
            {
                throw new IndexOutOfRangeException();
            }
            return (char)(value + 'a');
        }

        private void AddOutfitListClass(string className)
        {
            classes.Add(new ClassToCompile(className, string.Format(OutfitSpecListClassTemplate, className), [containingPackage]));
        }

        private ModConfigClass GetOutfitListConfig(string className)
        {
            return new ModConfigClass($"{containingPackage}.{className}", "BioGame.ini");
        }

        private string GetVanillaArmorFileName(string bodyType, OutfitType outfitType)
        {
            return $"BIOG_{bodyType}_ARM_{outfitType}_R";
        }
    }
}
