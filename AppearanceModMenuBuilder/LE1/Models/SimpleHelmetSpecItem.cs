namespace AppearanceModMenuBuilder.LE1.Models
{
    public class SimpleHelmetSpecItem : SpecItemBase
    {
        public SimpleHelmetSpecItem(int id, string helmetMesh, string[] helmetMaterials, AppearanceMeshPaths? visorMesh) : base(id)
        {
            HelmetMesh = new AppearanceMeshPaths(helmetMesh, helmetMaterials);
            VisorMesh = visorMesh;
        }

        public AppearanceMeshPaths HelmetMesh
        {
            get => GetStruct<AppearanceMeshPaths>(nameof(HelmetMesh))!;
            set => SetStruct(nameof(HelmetMesh), value);
        }

        public AppearanceMeshPaths? VisorMesh
        {
            get => GetStruct<AppearanceMeshPaths>(nameof(VisorMesh));
            set => SetStruct(nameof(VisorMesh), value);
        }

        public bool? SuppressVisor
        {
            get => GetBool(nameof(SuppressVisor));
            set => SetBool(nameof(SuppressVisor), value);
        }

        public bool? SuppressBreather
        {
            get => GetBool(nameof(SuppressBreather));
            set => SetBool(nameof(SuppressBreather), value);
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

        public int? BreatherSpec
        {
            get => GetInt(nameof(BreatherSpec));
            set => SetInt(nameof(BreatherSpec), value);
        }
    }
}
