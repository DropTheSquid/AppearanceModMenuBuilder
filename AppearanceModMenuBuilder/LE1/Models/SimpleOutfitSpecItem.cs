namespace AppearanceModMenuBuilder.LE1.Models
{
    public class SimpleOutfitSpecItem : OutfitSpecItemBase
    {
        public SimpleOutfitSpecItem(int id, string mesh, string[] materials) : base(id)
        {
            BodyMesh = new AppearanceMeshPaths(mesh, materials);
        }

        public AppearanceMeshPaths? BodyMesh
        {
            get => GetStruct<AppearanceMeshPaths>(nameof(BodyMesh));
            set => SetStruct(nameof(BodyMesh), value);
        }
    }
}
