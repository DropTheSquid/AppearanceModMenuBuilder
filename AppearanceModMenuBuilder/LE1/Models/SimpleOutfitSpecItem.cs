namespace AppearanceModMenuBuilder.LE1.Models
{
    public class SimpleOutfitSpecItem : SpecItemBase
    {
        public SimpleOutfitSpecItem(int id, string bodyMesh, string[] bodyMaterials) : base(id)
        {
            BodyMesh = new AppearanceMeshPaths(bodyMesh, bodyMaterials);
        }

        public AppearanceMeshPaths BodyMesh
        {
            get => GetStruct<AppearanceMeshPaths>(nameof(BodyMesh))!;
            set => SetStruct(nameof(BodyMesh), value);
        }

        public int? HelmetSpec
        {
            get => GetInt(nameof(HelmetSpec));
            set => SetInt(nameof(HelmetSpec), value);
        }
    }
}
