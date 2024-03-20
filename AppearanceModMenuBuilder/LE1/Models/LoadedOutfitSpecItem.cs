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
            get => ((StringCoalesceValue)this[nameof(SpecPath)]).Value;
            set => this[nameof(SpecPath)] = new StringCoalesceValue(value);
        }
    }
}
