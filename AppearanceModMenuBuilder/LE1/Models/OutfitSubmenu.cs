using LegendaryExplorerCore.Packages;
using static MassEffectModBuilder.LEXHelpers.LooseClassCompile;

namespace AppearanceModMenuBuilder.LE1.Models
{
    //public abstract record class OutfitSubmenu(string[] ContainingPath, string ClassName)
    //{
    //    protected const string SubmenuClassTemplate = "Class {0} extends AppearanceSubmenu config(UI);";
    //    protected const string AppearanceSubmenuClassPrefix = "AppearanceSubmenu_";

    //    // the entry to put into another menu as the entry to this one
    //    public abstract string[] GenerateEntryPoint();

    //    // the header of the config section for this menu
    //    public abstract string[] GenerateHeader();

    //    // the actual entries in this submenu
    //    public abstract string[] GenerateEntries();

    //    public IEnumerable<ClassToCompile> GenerateClassesToCompile()
    //    {
    //        return [GetSubmenuClass(ClassName, ContainingPath)];
    //    }

    //    public virtual void ModifyPackage(IMEPackage package) { }

    //    private static ClassToCompile GetSubmenuClass(string className, string[] path)
    //    {
    //        var fullClassName = $"{AppearanceSubmenuClassPrefix}{className}";
    //        return new ClassToCompile(fullClassName, string.Format(SubmenuClassTemplate, fullClassName), path);
    //    }
    //}
}
