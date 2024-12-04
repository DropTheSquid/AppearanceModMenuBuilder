public function UpdateAppearance()
{
    local bool callSuper;
    // if AMM is installed, do its handling instead
    if (class'AMM_AppearanceUpdater_Base'.static.UpdatePlayerAppearanceStatic(self, false, callSuper))
    {
        // I can't directly call the super in my redirected function, so this allows me to still call it if needed
        if (callSuper)
        {
            Super(BioPawn).UpdateAppearance();
        }
        // and then to do any remaining work after it is called
        class'AMM_AppearanceUpdater_Base'.static.UpdatePlayerAppearanceStatic(self, true, callSuper);
        return;
    }
    ValidateAppearanceIDs();
    UpdateHairAppearance();
    UpdateBodyAppearance();
    Super(BioPawn).UpdateAppearance();
    UpdateParameters();
    UpdateWeaponVisibility();
    ForceUpdateComponents(TRUE, FALSE);
    UpdateGameEffects();
    BlockForTextureStreaming();
    SetPlayerLOD();
}