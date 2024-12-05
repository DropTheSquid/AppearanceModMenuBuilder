using MassEffectModBuilder.Models;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE2.Models
{
    internal class AMM_Submenu : ModConfigClass
    {
        public string ClassName { get; }

        public AMM_Submenu(string partialClassName) : base($"SFXGameContent_AMM.SFXGuiData_AMM_{partialClassName}", "BioUI.ini")
        {
            ClassName = $"SFXGuiData_AMM_{partialClassName}";
        }

        public ClassToCompile GetClassToCompile()
        {
            return new ClassToCompile(ClassName, $"Class {ClassName} extends AppearanceSubMenuBase;", ["SFXGameContent_AMM"]);
        }
    }
}
