public final function LoadAppearance(SFXPawn_Player Player, out PlayerSaveRecord Record)
{
    local AppearanceUpdater AppearanceUpdater;
    
    AppearanceUpdater = Class'AppearanceUpdater'.static.GetInstance();
    AppearanceUpdater.LoadAppearance(Self, Player, Record);
}