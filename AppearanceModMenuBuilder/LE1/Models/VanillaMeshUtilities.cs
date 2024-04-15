namespace AppearanceModMenuBuilder.LE1.Models
{
    public static class VanillaMeshUtilities
    {
        public enum EArmorType
        {
            NKD,
            CTH,
            LGT,
            MED,
            HVY,
            All
        }

        public static string GetMeshVariantString(EArmorType type, int meshVariant)
        {
            // eg LGTa for LGT variant 0
            return type.ToString() + CharFromInt(meshVariant);
        }

        public static char CharFromInt(int value)
        {
            if (value < 0 || value > 25)
            {
                throw new IndexOutOfRangeException();
            }
            return (char)(value + 'a');
        }

        public static string GetVanillaArmorFileName(string bodyType, EArmorType outfitType)
        {
            return $"BIOG_{bodyType}_ARM_{outfitType}_R";
        }
    }
}
