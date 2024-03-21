namespace AppearanceModMenuBuilder.LE1.Models
{
    internal class LoadedOutfitSpecItem : OutfitSpecItemBase
    {
        public LoadedOutfitSpecItem(int id, string specPath) : base(id)
        {
            SpecPath = specPath;
        }

        public string SpecPath
        {
            get => GetString(nameof(SpecPath))!;
            set => SetString(nameof(SpecPath), value);
        }
    }
}
