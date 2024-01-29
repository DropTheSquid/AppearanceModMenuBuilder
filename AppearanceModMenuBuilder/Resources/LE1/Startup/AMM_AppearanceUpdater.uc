class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base
    config(Game);

public function UpdatePawnAppearance(BioPawn target, string source)
{
	LogInternal("dlc appearance update for target"@target@"from source"@source);
	// test that this is having an effect which will be overwritten by native appearance update
	target.Mesh.SetScale(0.6);
}
