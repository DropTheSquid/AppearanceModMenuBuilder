using MassEffectModBuilder.Models;

namespace AppearanceModMenuBuilder.LE2.UScriptStructs
{
    public class SFXChoiceEntry : StructCoalesceValue
    {
        public int? SrChoiceName
        {
            get => GetInt(nameof(SrChoiceName));
            set => SetInt(nameof(SrChoiceName), value);
        }

        public bool? BDisabled
        {
            get => GetBool(nameof(BDisabled));
            set => SetBool(nameof(BDisabled), value);
        }

        public bool? BNested
        {
            get => GetBool(nameof(BNested));
            set => SetBool(nameof(BNested), value);
        }

        // TODO add more of these as I need them
    }
}
