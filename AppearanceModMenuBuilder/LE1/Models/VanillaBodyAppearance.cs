﻿using static AppearanceModMenuBuilder.LE1.Models.VanillaMeshUtilities;

namespace AppearanceModMenuBuilder.LE1.Models
{
    public record class VanillaBodyAppearance(
        int AmmAppearanceId,
        EArmorType ArmorType,
        string PackageName,
        string AppearancePrefix,
        int ModelVariant,
        int MaterialVariant,
        int MaterialsPerVariant)
    {
        public struct MenuEntryDetails
        {
            public string Label { get; set; }
            public int SrName { get; set; }
            public int SrManufacturerName { get; set; }
            public bool IsPlayerSpecific { get; set; }
            public EArmorType ArmorType { get; set; }
        }

        public List<MenuEntryDetails> MenuEntries { get; set; } = [];

        public int HelmetAppearanceId { get; set; } = -2;

        public static IEnumerable<VanillaBodyAppearance> GetVanillaVariants(
            int startingId,
            EArmorType armorType,
            string bodyType,
            params (int materialVariants, int materialsPerVariant)[] modelVariants)
        {
            return GetVanillaVariants(startingId, armorType, GetVanillaArmorFileName(bodyType, armorType), bodyType, modelVariants);
        }

        public static IEnumerable<VanillaBodyAppearance> GetVanillaVariants(
            int startingId,
            EArmorType armorType,
            string packageName,
            string appearancePrefix,
            params (int materialVariants, int materialsPerVariant)[] modelVariants)
        {
            var currentId = startingId;
            var results = new List<VanillaBodyAppearance>();
            for (int i = 0; i <  modelVariants.Length; i++)
            {
                var (materialVariants, materialsPerVariant) = modelVariants[i];
                for (int j = 0; j < materialVariants; j++)
                {
                    results.Add(new VanillaBodyAppearance(
                        currentId++,
                        armorType,
                        packageName,
                        appearancePrefix,
                        i,
                        j,
                        materialsPerVariant));
                }
            }
            return results;
        }
    }
}
