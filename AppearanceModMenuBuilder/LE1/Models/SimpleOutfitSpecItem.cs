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
            get => GetString(nameof(Mesh))!;
            set => SetString(nameof(Mesh), value);
        }

        public string[] Materials
        {
            get => GetStringArray(nameof(Materials))!;
            set => SetStringArray(nameof(Materials), value);
        }
    }
}
