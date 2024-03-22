namespace AppearanceModMenuBuilder.LE1.Models
{
    public class AppearanceMeshPaths : StructCoalesceValue
    {
        public AppearanceMeshPaths(string mesh, string[] materials)
        {
            MeshPath = mesh;
            MaterialPaths = materials;
        }

        public string MeshPath
        {
            get => GetString(nameof(MeshPath))!;
            set => SetString(nameof(MeshPath), value);
        }

        public string[] MaterialPaths
        {
            get => GetStringArray(nameof(MaterialPaths))!;
            set => SetStringArray(nameof(MaterialPaths), value);
        }
    }
}
