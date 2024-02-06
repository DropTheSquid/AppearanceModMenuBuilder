namespace AppearanceModMenuBuilder.LE1.Models
{
    public record class SimpleOutfitSpec(int Id, string Mesh, IEnumerable<string> Materials, string? Description = null): IOutfitSpec
    {
        public IEnumerable<string> OutputOutfitConfigMergeLines()
        {
            if (string.IsNullOrWhiteSpace(Mesh))
            {
                throw new Exception("invalid simple outfit spec; mesh is required");
            }
            if (Materials == null || !Materials.Any())
            {
                throw new Exception("Invalid outfit spec. materials are required");
            }
            var configLine = $@"+outfitSpecs=(Id={Id},Mesh=""{Mesh}"", Materials=({string.Join(",", Materials.Select(mat => $@"""{mat}"""))}))";
            
            if (string.IsNullOrWhiteSpace(Description))
            {
                return [configLine];
            }
            else
            {
                var comment = $"; {Description}";
                return [comment, configLine];
            }
        }
    }
}
