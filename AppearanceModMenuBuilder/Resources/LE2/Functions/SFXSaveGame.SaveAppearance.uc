public final function SaveAppearance(SFXPawn_Player Player, out AppearanceSaveRecord Record)
{
    local AppearanceUpdater AppearanceUpdater;
    
    AppearanceUpdater = Class'AppearanceUpdater'.static.GetInstance();
    AppearanceUpdater.SaveAppearance(Player, Record);
}