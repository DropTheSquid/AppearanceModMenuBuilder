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
            get => ((IntCoalesceValue)this[nameof(Id)]).Value;
            set => this[nameof(Id)] = new IntCoalesceValue(value);
        }
    }
}
