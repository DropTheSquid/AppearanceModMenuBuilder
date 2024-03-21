namespace AppearanceModMenuBuilder.LE1.Models
{
    public abstract class OutfitSpecItemBase : StructCoalesceValue
    {
        public OutfitSpecItemBase(int id)
        {
            Id = id;
        }

        public int Id
        {
            get => (int)GetInt(nameof(Id))!;
            set => SetInt(nameof(Id), value);
        }
    }
}
