namespace AppearanceModMenuBuilder.LE1.Models
{
    public record class LoadedOutfitSpec(int Id, string ClassPath, string? Description = null) : IOutfitSpec
    {
        public IEnumerable<string> OutputOutfitConfigMergeLines()
        {
            var comment = !string.IsNullOrWhiteSpace(Description) ? $"; {Description}\r\n" : "";
            return [$@"{comment}+outfitSpecs=(Id={Id},specPath=""{ClassPath}"")"];
        }
    }
}
