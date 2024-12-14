using LegendaryExplorerCore.Unreal.Classes;
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

        public string? SChoiceName
        {
            get => GetString(nameof(SChoiceName));
            set => SetString(nameof(SChoiceName), value);
        }

        public bool? BNested
        {
            get => GetBool(nameof(BNested));
            set => SetBool(nameof(BNested), value);
        }

        public int? SrActionText
        {
            get => GetInt(nameof(SrActionText));
            set => SetInt(nameof(SrActionText), value);
        }

        public string? SActionText
        {
            get => GetString(nameof(SActionText));
            set => SetString(nameof(SActionText), value);
        }

        // TODO add more of these as I need them
    }
}
