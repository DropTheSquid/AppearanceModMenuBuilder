namespace AppearanceModMenuBuilder.LE1.UScriptStructs
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

        public bool? SuppressHelmet
        {
            get => GetBool(nameof(SuppressHelmet));
            set => SetBool(nameof(SuppressHelmet), value);
        }

        public bool? HideHair
        {
            get => GetBool(nameof(HideHair));
            set => SetBool(nameof(HideHair), value);
        }

        public bool? HideHead
        {
            get => GetBool(nameof(HideHead));
            set => SetBool(nameof(HideHead), value);
        }

        public int? HelmetOnBodySpec
        {
            get => GetInt(nameof(HelmetOnBodySpec));
            set => SetInt(nameof(HelmetOnBodySpec), value);
        }
    }
}
