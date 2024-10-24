public function Deactivated()
{
    bIsActive = FALSE;
    if (bAllowMovement == FALSE)
    {
        Outer.IgnoreMoveInput(FALSE);
    }
    if (bAllowCamera == FALSE)
    {
        Outer.IgnoreLookInput(FALSE);
    }
    // signal AMM that the game mode has changed
    class'AMM_AppearanceUpdater_Base'.static.GameModeChangedStatic(self, false);
}