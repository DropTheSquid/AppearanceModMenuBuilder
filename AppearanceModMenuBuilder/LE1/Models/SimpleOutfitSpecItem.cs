namespace AppearanceModMenuBuilder.LE1.Models
{
    public class SimpleOutfitSpecItem : OutfitSpecItemBase
    {
        public SimpleOutfitSpecItem(int id, string mesh, string[] materials) : base(id)
        {
            Mesh = mesh;
            Materials = materials;
        }

        public string Mesh
        {
            get => ((StringCoalesceValue)this[nameof(Mesh)]).Value;
            set => this[nameof(Mesh)] = new StringCoalesceValue(value);
        }

        public string[] Materials
        {
            get => ((StringArrayCoalesceValue)this[nameof(Materials)]).Value;
            set => this[nameof(Materials)] = new StringArrayCoalesceValue(value);
        }
    }
}
