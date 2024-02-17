Class AMM_Pawn_Parameters_Romanceable extends AMM_Pawn_Parameters_Squad
    abstract
    config(Game);

var config string romancePawnTag;

public function bool matchesPawn(BioPawn targetPawn)
{
    if (string(targetPawn.Tag) ~= romancePawnTag)
    {
        return TRUE;
    }
    return Super.matchesPawn(targetPawn);
}
public function string GetAppearanceType(BioPawn targetPawn)
{
    if (string(targetPawn.Tag) ~= romancePawnTag)
    {
        return "romance";
    }
    return Super.GetAppearanceType(targetPawn);
}
