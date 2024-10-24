public function Activated()
{
    bIsActive = TRUE;
    if (bAllowMovement == FALSE)
    {
        Outer.IgnoreMoveInput(TRUE);
    }
    if (bAllowCamera == FALSE)
    {
        Outer.IgnoreLookInput(TRUE);
    }
    // signal AMM that the game mode has changed
    class'AMM_AppearanceUpdater_Base'.static.GameModeChangedStatic(self, true);
}