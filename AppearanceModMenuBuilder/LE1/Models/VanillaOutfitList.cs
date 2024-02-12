namespace AppearanceModMenuBuilder.LE1.Models
{
    public enum OutfitType
    {
        NKD,
        CTH,
        LGT,
        MED,
        HVY
    }

    public record class VanillaOutfitList(int StartingId, string PackagePrefix, OutfitType Type, int MeshVariant, string BodyTypePrefix, int ModelVariants, int MaterialsPerVariant, string Comment = "") : IOutfitSpec
    {
        public IEnumerable<string> OutputOutfitConfigMergeLines()
        {
            SimpleOutfitSpec[] specs = new SimpleOutfitSpec[ModelVariants];

            for (int i = 0; i < ModelVariants; i++)
            {
                var id = StartingId + i;
                var meshVariantString = Type.ToString() + CharFromInt(MeshVariant);
                // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa
                var sharedPrefix = $"{PackagePrefix}.{meshVariantString}.{BodyTypePrefix}_ARM_{meshVariantString}";
                // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa_MDL
                var mesh = $"{sharedPrefix}_MDL";
                string[] materials = new string[MaterialsPerVariant];
                for (int j = 0; j < MaterialsPerVariant; j++)
                {
                    // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa_MAT_1a
                    // eg BIOG_QRN_ARM_LGT_R.LGTa.QRN_FAC_ARM_LGTa_MAT_1b
                    // where 1 is the variant, and a/b is the material number within the variant
                    materials[j] = $"{sharedPrefix}_Mat_{i+1}{CharFromInt(j)}";
                }

                specs[i] = new SimpleOutfitSpec(id, mesh, materials);
            }
            var specOutput = specs.SelectMany(x => x.OutputOutfitConfigMergeLines());
            
            if (string.IsNullOrWhiteSpace(Comment))
            {
                return specOutput;
            }
            else
            {
                return [$"; {Comment}", .. specOutput];
            }
        }

        /// <summary>
        /// returns the lowercase letter at the given position in the alphabet; 0 is 'a', 1 is 'b', etc
        /// </summary>
        private static char CharFromInt(int value )
        {
            if ( value < 0 || value > 25)
            {
                throw new IndexOutOfRangeException();
            }
            return (char)(value + 'a');
        }
    }
}
