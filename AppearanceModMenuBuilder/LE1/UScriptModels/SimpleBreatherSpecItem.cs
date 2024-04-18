namespace AppearanceModMenuBuilder.LE1.UScriptModels
{
    public class SimpleBreatherSpecItem : SpecItemBase
    {
        public SimpleBreatherSpecItem(int id, string breatherMesh, string[] breatherMaterials) : base(id)
        {
            BreatherMesh = new AppearanceMeshPaths(breatherMesh, breatherMaterials);
        }

        public AppearanceMeshPaths BreatherMesh
        {
            get => GetStruct<AppearanceMeshPaths>(nameof(BreatherMesh))!;
            set => SetStruct(nameof(BreatherMesh), value);
        }

        public AppearanceMeshPaths VisorMeshOverride
        {
            get => GetStruct<AppearanceMeshPaths>(nameof(VisorMeshOverride))!;
            set => SetStruct(nameof(VisorMeshOverride), value);
        }

        public bool? SuppressVisor
        {
            get => GetBool(nameof(SuppressVisor));
            set => SetBool(nameof(SuppressVisor), value);
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
    }
}
