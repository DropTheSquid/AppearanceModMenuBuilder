Class AMM_Pawn_Parameters_Romanceable extends AMM_Pawn_Parameters_Squad
    abstract
    config(Game);

var config string romancePawnTag;

public function bool matchesPawn(BioPawn targetPawn)
{
    if (string(targetPawn.Tag) ~= romancePawnTag)
    {
        return ShouldAffectRomanceAppearance();
    }
    return Super.matchesPawn(targetPawn);
}
private function bool ShouldAffectRomanceAppearance()
{
    local BioWorldInfo BWI;
    local BioGlobalVariableTable gv;

    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    gv = BWI.GetGlobalVariables();
    // only affect romance appearances if the framework is installed and romance customization is enabled
    if (class'AMM_Common'.static.IsFrameworkInstalled() && gv.GetInt(1596) == 1)
    {
        return true;
    }
    return false;
}
public function string GetAppearanceType(BioPawn targetPawn)
{
    if (string(targetPawn.Tag) ~= romancePawnTag)
    {
        return "romance";
    }
    return Super.GetAppearanceType(targetPawn);
}
