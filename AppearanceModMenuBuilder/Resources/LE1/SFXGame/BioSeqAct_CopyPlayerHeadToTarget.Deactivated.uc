public function Deactivated()
{
    local array<Object> Objects;
    local BioPawn TargetPawn;

	// this entire function is added to run after the vanilla squence action. 
	// This targets the romance player pawn (the naked one)
    GetObjectVars(Objects, "Target");
    if (Objects.Length < 1)
    {
        return;
    }
    TargetPawn = BioPawn(Objects[0]);
    if (TargetPawn == None)
    {
        return;
    }
	Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(TargetPawn, "BioSeqAct_CopyPlayerHeadToTarget.Deactivated");
}