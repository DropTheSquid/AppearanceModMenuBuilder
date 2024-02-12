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

            AddOutfitSpecList("HMF_OutfitSpec", GetHMFOutfits());
            // TODO create/populate other outfit spec lists for squadmates
            AddOutfitSpecList("HMM_OutfitSpec", GetHMMOutfits());
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

        private VanillaOutfitList[] GetHMFOutfits()
        {
            const string bodyType = "HMF";

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            var LGTa = new VanillaOutfitList(1, GetVanillaArmorFileName(bodyType, OutfitType.LGT), OutfitType.LGT, 0, bodyType, 16, 1, "Vanilla LGTa variants; Most Light armor appearances fall under this");
            var LGTb = new VanillaOutfitList(17, GetVanillaArmorFileName(bodyType, OutfitType.LGT), OutfitType.LGT, 1, bodyType, 1, 1, "Vanilla LGTb; This is the N7 Onyx Armor that Shepard wears");
            var LGTc = new VanillaOutfitList(18, GetVanillaArmorFileName(bodyType, OutfitType.LGT), OutfitType.LGT, 2, bodyType, 1, 1, "Vanilla LGTc; This is the Asari Commando armor, normally not ever used by player characters; only used by NPC Asari");

            var MEDa = new VanillaOutfitList(19, GetVanillaArmorFileName(bodyType, OutfitType.MED), OutfitType.MED, 0, bodyType, 16, 1, "Vanilla MEDa variants; Most Medium armor appearances fall under this");
            var MEDb = new VanillaOutfitList(35, GetVanillaArmorFileName(bodyType, OutfitType.MED), OutfitType.MED, 1, bodyType, 1, 1, "Vanilla MEDb; this is the N7 Onyx armor that Shepard wears");
            var MEDc = new VanillaOutfitList(36, GetVanillaArmorFileName(bodyType, OutfitType.MED), OutfitType.MED, 2, bodyType, 9, 1, "Asymmetric tintable armor. Not used by any equipment obtainable in vanilla or by any NPCs");

            var HVYa = new VanillaOutfitList(45, GetVanillaArmorFileName(bodyType, OutfitType.HVY), OutfitType.HVY, 0, bodyType, 16, 1, "Vanilla HVYa variants. Most heavy armor falls under this");
            var HVYb = new VanillaOutfitList(61, GetVanillaArmorFileName(bodyType, OutfitType.HVY), OutfitType.HVY, 1, bodyType, 1, 1, "Vanilla HVYb. This is the N7 Onyx Armor Shepard wears");

            // Add NKD and CTH vanilla meshes (100-140)
            var NKDa = new VanillaOutfitList(100, GetVanillaArmorFileName(bodyType, OutfitType.NKD), OutfitType.NKD, 0, bodyType, 2, 1, "Vanilla NKDa; material 1 is just a naked human; material 2 is the Avina material");
            var NKDb = new VanillaOutfitList(102, GetVanillaArmorFileName(bodyType, OutfitType.NKD), OutfitType.NKD, 1, bodyType, 1, 1, "Vanilla NKDb; dancer with tintable skintone");
            var NKDc = new VanillaOutfitList(103, GetVanillaArmorFileName(bodyType, OutfitType.NKD), OutfitType.NKD, 2, bodyType, 1, 1, "Vanilla NKDc; Liara romance mesh");

            var CTHa = new VanillaOutfitList(104, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 0, bodyType, 6, 1, "Vanilla CTHa; Alliance Formal");
            var CTHb = new VanillaOutfitList(110, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 1, bodyType, 5, 1, "Vanilla CTHb; ME1 Alliance Fatigues");
            var CTHc = new VanillaOutfitList(115, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 2, bodyType, 6, 1, "Vanilla CTHc; dress 1");
            var CTHd = new VanillaOutfitList(121, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 3, bodyType, 6, 1, "Vanilla CTHd; dress 2");
            var CTHe = new VanillaOutfitList(127, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 4, bodyType, 2, 1, "Vanilla CTHe; Civilian clothes 1");
            var CTHf = new VanillaOutfitList(129, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 5, bodyType, 4, 1, "Vanilla CTHf; Civilian clothes 2");
            var CTHg = new VanillaOutfitList(133, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 6, bodyType, 1, 1, "Vanilla CTHg; dress 3");
            var CTHh = new VanillaOutfitList(134, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 7, bodyType, 7, 1, "Vanilla CTHh; scientist/medical uniform");

            // TODO add extended vanilla meshes

            return [LGTa, LGTb, LGTc, MEDa, MEDb, MEDc, HVYa, HVYb, NKDa, NKDb, NKDc, CTHa, CTHb, CTHc, CTHd, CTHe, CTHf, CTHg, CTHh];
        }

        private VanillaOutfitList[] GetHMMOutfits()
        {
            const string bodyType = "HMM";

            // add all vanilla armor variants into positive IDs less than 100 (only goes up to 61)
            var LGTa = new VanillaOutfitList(1, GetVanillaArmorFileName(bodyType, OutfitType.LGT), OutfitType.LGT, 0, bodyType, 16, 1, "Vanilla LGTa variants; Most Light armor appearances fall under this");
            var LGTb = new VanillaOutfitList(17, GetVanillaArmorFileName(bodyType, OutfitType.LGT), OutfitType.LGT, 1, bodyType, 1, 1, "Vanilla LGTb; This is the N7 Onyx Armor that Shepard wears");
            // Note that there is no LGTc for HMM

            var MEDa = new VanillaOutfitList(19, GetVanillaArmorFileName(bodyType, OutfitType.MED), OutfitType.MED, 0, bodyType, 16, 1, "Vanilla MEDa variants; Most Medium armor appearances fall under this");
            var MEDb = new VanillaOutfitList(35, GetVanillaArmorFileName(bodyType, OutfitType.MED), OutfitType.MED, 1, bodyType, 1, 1, "Vanilla MEDb; this is the N7 Onyx armor that Shepard wears");
            var MEDc = new VanillaOutfitList(36, GetVanillaArmorFileName(bodyType, OutfitType.MED), OutfitType.MED, 2, bodyType, 9, 1, "Asymmetric tintable armor. Not used by any equipment obtainable in vanilla or by any NPCs");

            var HVYa = new VanillaOutfitList(45, GetVanillaArmorFileName(bodyType, OutfitType.HVY), OutfitType.HVY, 0, bodyType, 16, 1, "Vanilla HVYa variants. Most heavy armor falls under this");
            var HVYb = new VanillaOutfitList(61, GetVanillaArmorFileName(bodyType, OutfitType.HVY), OutfitType.HVY, 1, bodyType, 1, 1, "Vanilla HVYb. This is the N7 Onyx Armor Shepard wears");

            // Add NKD and CTH vanilla meshes (100-140)
            var NKDa = new VanillaOutfitList(100, GetVanillaArmorFileName(bodyType, OutfitType.NKD), OutfitType.NKD, 0, bodyType, 2, 1, "Vanilla NKDa; material 1 is just a naked human; material 2 is the VI material");

            // there is a missing material in HMM CTHa; it only has 1, 2, 3, and 5
            var CTHa = new VanillaOutfitList(102, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 0, bodyType, 5, 1, "Vanilla CTHa; Alliance Formal");
            var CTHb = new VanillaOutfitList(107, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 1, bodyType, 6, 1, "Vanilla CTHb; ME1 Alliance Fatigues");
            var CTHc = new VanillaOutfitList(113, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 2, bodyType, 5, 1, "Vanilla CTHc; Civilian clothes 1");
            var CTHd = new VanillaOutfitList(118, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 3, bodyType, 3, 1, "Vanilla CTHd; Civilian Clothes 2");
            var CTHe = new VanillaOutfitList(121, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 4, bodyType, 3, 1, "Vanilla CTHe; Civilian clothes 3");
            var CTHf = new VanillaOutfitList(124, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 5, bodyType, 3, 1, "Vanilla CTHf; Civilian clothes 4");
            var CTHg = new VanillaOutfitList(127, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 6, bodyType, 2, 1, "Vanilla CTHg; Civilian clothes 5");
            var CTHh = new VanillaOutfitList(129, GetVanillaArmorFileName(bodyType, OutfitType.CTH), OutfitType.CTH, 7, bodyType, 2, 1, "Vanilla CTHh; scientist/medical uniform");

            // TODO add extended vanilla meshes

            return [LGTa, LGTb, MEDa, MEDb, MEDc, HVYa, HVYb, NKDa, CTHa, CTHb, CTHc, CTHd, CTHe, CTHf, CTHg, CTHh];
        }
        private string GetVanillaArmorFileName(string bodyType, OutfitType outfitType)
        {
            return $"BIOG_{bodyType}_ARM_{outfitType}_R";
        }
    }
}
