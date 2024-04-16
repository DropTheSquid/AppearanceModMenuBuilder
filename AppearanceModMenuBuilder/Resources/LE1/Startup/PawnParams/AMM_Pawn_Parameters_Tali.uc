Class AMM_Pawn_Parameters_Tali extends AMM_Pawn_Parameters_Squad
    config(Game);

// Tali has a bug where her Normandy Pawn does not have armor overridden, even on the Normandy. This causes it to think she is in combat mode. 
// this is true even in the Framework, and is perhaps a bug I should report.
// This fixes it so she uses the casual appearance.
// I think just having it grab a different appearance type for this tag would work also.
public function SpecialHandling(BioPawn targetPawn)
{
    local string sComment;
    
    if (targetPawn.UniqueTag == 'hench_quarian_engineering')
    {
        sComment = "If this is Tali on the Normandy, she will not correctly have the casual flag set. Set it now.";
        targetPawn.m_oBehavior.ForceArmorOverride(TRUE);
    }
}