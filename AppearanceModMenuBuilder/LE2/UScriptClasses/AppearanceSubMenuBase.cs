using AppearanceModMenuBuilder.LE2.UScriptStructs;
using MassEffectModBuilder.Models;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE2.UScriptClasses
{
    internal class AppearanceSubMenuBase : ModConfigClass
    {
        public string ClassName { get; }

        public AppearanceSubMenuBase(string partialClassName) : base($"SFXGameContent_AMM.SFXGuiData_AMM_{partialClassName}", "BioUI.ini")
        {
            ClassName = $"SFXGuiData_AMM_{partialClassName}";
        }

        public ClassToCompile GetClassToCompile()
        {
            return new ClassToCompile(ClassName, $"Class {ClassName} extends AppearanceSubMenuBase;", ["SFXGameContent_AMM"]);
        }

        public int? M_srTitle
        {
            get => GetIntValue(nameof(M_srTitle));
            set => SetIntValue(nameof(M_srTitle), value);
        }

        public (int stringref, string comment) SrTitleWithComment
        {
            set => SetIntValue(nameof(M_srTitle), value.stringref, value.comment);
        }

        public int? M_srSubTitle
        {
            get => GetIntValue(nameof(M_srSubTitle));
            set => SetIntValue(nameof(M_srSubTitle), value);
        }

        public void AddMenuEntry(AppearanceItemData item)
        {
            // ensure this is added to the config merge
            item.DoubleType = "+";
            AddArrayEntries("appearanceItems", item);
        }

    }
}
