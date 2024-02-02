class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base
    config(Game);

var Pawn_Parameter_Handler paramHandler;

public function UpdatePawnAppearance(BioPawn target, string source)
{
	local AMM_Pawn_Parameters params;

	LogInternal("dlc appearance update for target"@target@"from source"@source);
	// test that this is having an effect which will be overwritten by native appearance update
	if (paramHandler.GetPawnParams(target, params))
	{
		LogInternal("found params for pawn"@target@target.Tag@params);
	}
	else
	{
		LogInternal("did not find params for pawn"@target@target.Tag);
	}
	target.Mesh.SetScale(0.6);
}

defaultproperties
{
    Begin Object Class=Pawn_Parameter_Handler Name=paramHandlerInstance
    End Object
    paramHandler = paramHandlerInstance
}
