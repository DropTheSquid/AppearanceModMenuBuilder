namespace AppearanceModMenuBuilder.LE1.Models
{
    public abstract record class BodyAppearance(int AmmAppearanceId)
    {
        public abstract string MeshPath { get; }
        public abstract string[] MaterialPaths { get; }
    }
}
