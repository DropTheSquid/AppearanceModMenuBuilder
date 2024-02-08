using AppearanceModMenuBuilder.LE1.Models;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1
{
    public class OutfitSpecListBuilder : IModBuilderTask
    {
        private const string OutfitSpecListCLassTemplate = "Class {0} extends OutfitSpecListBase config(Game);";
        private const string ConfigMergeName = "outfits";
        private const string containingPackage = "OutfitSpecs";
        private readonly List<ClassToCompile> classes = [];
        private readonly Dictionary<string, List<IOutfitSpec>> specsToPutInConfig = [];
        public void RunModTask(ModBuilderContext context)
        {
            var startup = context.GetStartupFile();

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            // TODO should these use enums? can I output matching helmet stuff here as well?
            // most light armor models
            var LGTa = new VanillaOutfitList(1, "BIOG_HMF_ARM_LGT_R", "LGTa", "HMF", 16, 1, "Vanilla LGTa variants; Most Light armor appearances fall under this");
            // N7 Armor
            var LGTb = new VanillaOutfitList(17, "BIOG_HMF_ARM_LGT_R", "LGTb", "HMF", 1, 1, "Vanilla LGTb; This is the N7 Onyx Armor that Shepard wears");
            // Asari Commando armor (female only)
            var LGTc = new VanillaOutfitList(18, "BIOG_HMF_ARM_LGT_R", "LGTc", "HMF", 1, 1, "Vanilla LGTc; This is the Asari Commando armor, normally not ever used by player characters; only used by NPC Asari");

            // most medium armor models
            var MEDa = new VanillaOutfitList(19, "BIOG_HMF_ARM_MED_R", "MEDa", "HMF", 16, 1, "Vanilla MEDa variants; Most Medium armor appearances fall under this");
            // N7 Armor
            var MEDb = new VanillaOutfitList(35, "BIOG_HMF_ARM_MED_R", "MEDb", "HMF", 1, 1, "Vanilla MEDb; this is the N7 Onyx armor that Shepard wears");
            // unused Asymmetric/tintable armor
            var MEDc = new VanillaOutfitList(36, "BIOG_HMF_ARM_MED_R", "MEDc", "HMF", 9, 1, "Asymmetric tintable armor. Not used by any equipment obtainable in vanilla or by any NPCs");

            // most heavy armor models
            var HVYa = new VanillaOutfitList(45, "BIOG_HMF_ARM_HVY_R", "HVYa", "HMF", 16, 1, "Vanilla HVYa variants. Most heavy armor falls under this");
            // N7 Armor
            var HVYb = new VanillaOutfitList(61, "BIOG_HMF_ARM_HVY_R", "HVYb", "HMF", 1, 1, "Vanilla HVYb. This is the N7 Onyx Armor Shepard wears");

            // TODO add vanilla NKD, CTH, extended vanilla options

            AddOutfitSpecList("HMF_OutfitSpec", LGTa, LGTb, LGTc, MEDa, MEDb, MEDc, HVYa, HVYb);
            // TODO create/populate other outfit spec lists for squadmates
            //AddOutfitSpecList("HMM_OutfitSpec");
            //AddOutfitSpecList("TUR_OutfitSpec");
            //AddOutfitSpecList("KRO_OutfitSpec");
            //AddOutfitSpecList("QRN_OutfitSpec");

            // TODO is it worth creating lists for other non squadmate body types? Female Turian, Volus, Salarian, Elcor, Hanar, male Quarian, Drell, others that do not show up in 1 such as Vorcha maybe?

            var compileClassesTask = new AddClassesToFile(_ => startup, classes);
            compileClassesTask.RunModTask(context);

            OutputConfig(context);
        }

        private void AddOutfitSpecList(string specListName, params IOutfitSpec[] outfitSpecs)
        {
            classes.Add(new ClassToCompile(specListName, string.Format(OutfitSpecListCLassTemplate, specListName), [containingPackage]));

            List<IOutfitSpec> specs = [];
            specs.AddRange(outfitSpecs);
            specsToPutInConfig[specListName] = specs;
        }

        private void OutputConfig(ModBuilderContext context)
        {
            List<string> lines = [];

            foreach (var (listName, specs) in specsToPutInConfig)
            {
                lines.Add($"[BioGame.ini {containingPackage}.{listName}]");
                foreach (var spec in specs)
                {
                    lines.AddRange(spec.OutputOutfitConfigMergeLines());
                }
                lines.Add("");
            }

            File.AppendAllLines(Path.Combine(context.CookedPCConsoleFolder, $"ConfigDelta-{ConfigMergeName}.m3cd"), lines);
        }
    }
}
