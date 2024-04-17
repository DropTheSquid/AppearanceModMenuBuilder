using System.Diagnostics;
using System.Text.RegularExpressions;
using static AppearanceModMenuBuilder.LE1.Models.VanillaArmorSet.ArmorVariant;
using static AppearanceModMenuBuilder.LE1.Models.VanillaMeshUtilities;

namespace AppearanceModMenuBuilder.LE1.Models
{
    [DebuggerDisplay("VanillaArmorSet: {Label}")]
    public partial class VanillaArmorSet(string label)
    {
        // regex for parsing the pawn out of the propertyLabel
        // parses GP_ArmorAppr_PlayerFemaleL
        // to get out PlayerFemale
        [GeneratedRegex("^GP_ArmorAppr_([A-Za-z]+?)([LMH])$")]
        private static partial Regex StaticArmorAppearanceRegex();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private readonly Regex ArmorAppearanceRegex = StaticArmorAppearanceRegex();

        [GeneratedRegex("^GP_HelmetAppr_([A-Za-z]+?)$")]
        private static partial Regex StaticHelmetAppearanceRegex();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        private readonly Regex HelmetAppearanceRegex = StaticHelmetAppearanceRegex();

        [DebuggerDisplay("ArmorVariant: L:{LGT} M:{MED} H:{HVY} A:{AllWeights}")]
        public class ArmorVariant
        {
            [DebuggerDisplay("WeightVariant: {AmmAppearanceId} {MeshVariant} {MaterialVariant}")]
            public class WeightVariant
            {
                public EArmorType? AppearanceOverride { get; set; }
                public int? MeshVariant { get; set; }
                public int? MaterialVariant { get; set; }
                public int? AmmAppearanceId { get; set; }
            }

            public WeightVariant GetWeightVariant(EArmorType type)
            {
                switch (type)
                {
                    case EArmorType.LGT:
                        LGT ??= new WeightVariant();
                        return LGT;
                    case EArmorType.MED:
                        MED ??= new WeightVariant();
                        return MED;
                    case EArmorType.HVY:
                        HVY ??= new WeightVariant();
                        return HVY;
                    case EArmorType.All:
                        AllWeights ??= new WeightVariant();
                        return AllWeights;
                    default:
                        throw new Exception();

                }
            }

            public int NumberOfWeightVariants { get => CountVariant(LGT) + CountVariant(MED) + CountVariant(HVY); }
            public WeightVariant[] WeightVariants { get
                {
                    var numVars = NumberOfWeightVariants;
                    if (numVars == 0)
                    {
                        return [];
                    }
                    else if (numVars == 1)
                    {
                        return [LGT ?? MED ?? HVY!];
                    }
                    else if (numVars == 2)
                    {
                        if (LGT == null)
                        {
                            return [MED!, HVY!];
                        }
                        else if (MED == null)
                        {
                            return [LGT!, HVY!];
                        }
                        else
                        {
                            return [LGT!, MED!];
                        }
                    }
                    else
                    {
                        return [LGT!, MED!, HVY!];
                    }
                }
            }

            public WeightVariant? LGT { get; set; }
            public WeightVariant? MED { get; set; }
            public WeightVariant? HVY { get; set; }

            public WeightVariant? AllWeights { get; set; }

            public int? HelmetVariant { get; set; }

            private static int CountVariant(WeightVariant? variant)
            {
                if (variant == null)
                {
                    return 0;
                }
                return 1;
            }
        }

        public string Label { get; set; } = label;

        public int SrArmorName { get; set; }

        public int SrManufacturerName { get; set; }

        public ArmorVariant? MalePlayerVariant { get; set; }
        public ArmorVariant? FemalePlayerVariant { get; set; }
        public ArmorVariant? AnyPlayerVariant { get; set; }
        public ArmorVariant? HumanMaleHenchVariant { get; set; }
        public ArmorVariant? HumanFemaleHenchVariant { get; set; }
        public ArmorVariant? AnyHumanVariant { get; set; }
        public ArmorVariant? TurianVariant { get; set; }
        public ArmorVariant? KroganVariant { get; set; }
        public ArmorVariant? QuarianVariant { get; set; }

        public EArmorType? AppearanceOverride { get; set; }

        public void Add2DARow(string effectLabel, string propertyLabel, int value)
        {
            switch (effectLabel)
            {
                case "GE_Item_Name":
                    // technically there can be different names per armor weight but they almost never do that so I am going to pretend I don't see it
                    SrArmorName = value;
                    break;
                case "GE_Armor_ModelVariant_O":
                    GetWeightVariant(propertyLabel).MeshVariant = value;
                    break;
                case "GE_Armor_MatID_O":
                    GetWeightVariant(propertyLabel).MaterialVariant = value;
                    break;
                case "GE_Armor_HeadModelVariant_O":
                    GetCharacterVariantFromHelmet(propertyLabel).HelmetVariant = value;
                    break;
                case "GE_Armor_AppearanceOverride":
                    // this is not specific to the wearer; it just means all armor levels use a specific armor level model instead of
                    // using the same variant from a different armor level for each level
                    // and it applies to all wearers
                    AppearanceOverride = (EArmorType)value;
                    break;
                default:
                    // there are several other effect labels related to armor stats that I do not care about
                    return;
            }
        }

        private WeightVariant GetWeightVariant(string propertyLabel)
        {

            var match = ArmorAppearanceRegex.Match(propertyLabel);

            if (!match.Success)
            {
                throw new Exception($"Warning: got unrecognized property label {propertyLabel}");
            }

            var pawnTag = match.Groups[1].Value;
            var rawArmorType = match.Groups[2].Value;
            var type = rawArmorType switch
            {
                "L" => EArmorType.LGT,
                "M" => EArmorType.MED,
                "H" => EArmorType.HVY,
                _ => throw new Exception()
            };

            ArmorVariant variant = GetCharacterVariant(pawnTag);
            return variant.GetWeightVariant(type);
        }

        private ArmorVariant GetCharacterVariantFromHelmet(string propertyLabel)
        {
            var match = HelmetAppearanceRegex.Match(propertyLabel);

            if (!match.Success)
            {
                throw new Exception($"Warning: got unrecognized property label {propertyLabel}");
            }

            var pawnTag = match.Groups[1].Value;

            return GetCharacterVariant(pawnTag);
        }

        private ArmorVariant GetCharacterVariant(string pawnTag)
        {
            switch (pawnTag)
            {
                case "PlayerFemale":
                    FemalePlayerVariant ??= new ArmorVariant();
                    return FemalePlayerVariant;
                case "PlayerMale":
                    MalePlayerVariant ??= new ArmorVariant();
                    return MalePlayerVariant;
                case "HenchAsari":
                case "HenchFemale":
                    HumanFemaleHenchVariant ??= new ArmorVariant();
                    return HumanFemaleHenchVariant;
                case "HenchMale":
                    HumanMaleHenchVariant ??= new ArmorVariant();
                    return HumanMaleHenchVariant;
                case "HenchKrogan":
                    KroganVariant ??= new ArmorVariant();
                    return KroganVariant;
                case "HenchTurian":
                    TurianVariant ??= new ArmorVariant();
                    return TurianVariant;
                case "HenchQuarian":
                    QuarianVariant ??= new ArmorVariant();
                    return QuarianVariant;
                default:
                    throw new Exception($"unknown pawn tag {pawnTag}");
            }
        }
    }
}
