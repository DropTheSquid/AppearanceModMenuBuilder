Class AMM_Pawn_Parameters_Liara extends AMM_Pawn_Parameters_Romanceable
    config(Game);

var config bool CasualOnTherum;
var config bool CasualOnVirmire;
var config bool casualInFramework;

public function string GetAppearanceType(BioPawn targetPawn)
{
	// by default, Liara is considered to be in casual appearance on Therum, despite not having armor overridden. the pawn just has no armor so it does its best
    if (targetPawn.GetPackageName() == 'BIOA_LAV70_07_DSG' && CasualOnTherum)
    {
        return "casual";
    }
	// same with Virmire
	if (targetPawn.GetPackageName() == 'BIOA_JUG20_08_DSG' && CasualOnVirmire)
    {
        return "casual";
    }
	// covers both above cases, but for framework
	if (targetPawn.GetPackageName() == 'BIONPC_Liara' && casualInFramework)
    {
        return "casual";
    }
    return Super(AMM_Pawn_Parameters_Romanceable).GetAppearanceType(targetPawn);
}

defaultproperties
{
	CasualOnTherum = true
	CasualOnVirmire = true
	casualInFramework = true
}