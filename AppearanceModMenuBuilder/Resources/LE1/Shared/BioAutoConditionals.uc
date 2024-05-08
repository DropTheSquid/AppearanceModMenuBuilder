Class BioAutoConditionals extends BioConditionals;

public function bool F2500(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Kaidan show up?
	// Yes, from the very start (he is already part of the crew) until/unless he dies
	// 3939 will be true from Eden Prime until he dies
	// 5032 will be FALSE until Eden Prime is completed.
	// So 3939 || !5032 should work
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Kaidan in party and alive (3939) || Eden Prime incomplete (!5032)
	return gv.GetBool(3939) == TRUE || gv.GetBool(5032) == FALSE;
}
public function bool F2501(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Ashley show up?
	// yes, if she is in your party or pre recruitment customization is enabled
	// until/unless she dies
	// 3940 will be true from when she is added to your party after you first real convo with her until/unless she dies
	// If pre recruitment is enabled and Eden Prime is incomplete, it can also show up.
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Ashley in party and alive (3940) || (allow pre recruitment && Eden Prime incomplete)
	return gv.GetBool(3940) == TRUE || (gv.GetInt(1597) == 1 && gv.GetBool(5032) == FALSE);
}
public function bool F2502(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Wrex show up?
	// yes from when he is added to the party (or before if pre recruitment) until/unless he dies
	// Wrex in Party and alive 
	// OR (pre recruitment AND Wrex not Rejected AND citadel prologue not complete)
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Wrex in party and alive (3942) || allow pre recruitment
	// TODO remove once you are no longer able to recruit him (post starting Virmire I think?)
	return gv.GetBool(3942) == TRUE || gv.GetInt(1597) == 1;
}
public function bool F2503(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Garrus show up?
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Garrus in party (3941) || allow pre recruitment
	// TODO remove once you can no longer recruit him (I think post starting Ilos?)
	return gv.GetBool(3941) == TRUE || gv.GetInt(1597) == 1;
}
public function bool F2504(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Tali show up?
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Tali in party (3944) || allow pre recruitment
	return gv.GetBool(3944) == TRUE || gv.GetInt(1597) == 1;
}
public function bool F2505(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Liara show up?
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Liara in party (3943) || allow pre recruitment
	return gv.GetBool(3943) == TRUE || gv.GetInt(1597) == 1;
}
public function bool F2506(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Shepard romance appearance show up?
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Turn on customize romance appearance && have not already completed romance (!6800)
	return gv.GetInt(1596) == 1 && gv.GetBool(6800) == FALSE;
}
public function bool F2507(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Liara romance appearance show up?
	local BioGlobalVariableTable gv;

	gv = bioWorld.GetGlobalVariables();

	// Turn on customize romance appearance && have not already completed romance
	// TODO hide if romance active with Kaidan/Ashley?
	return gv.GetInt(1596) == 1 && gv.GetBool(6800) == FALSE;
}
public function bool F2508(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Kaidan romance appearance show up?
	local BioGlobalVariableTable gv;
	local bool isSGRInstalled;

	isSGRInstalled = DynamicLoadObject("DLC_MOD_SameGender_GlobalTlk.GlobalTlk_tlk", Class'Object') != None;
	gv = bioWorld.GetGlobalVariables();

	// TODO hide if romance active with Liara/Ashley?
	// pre recruitment customization enabled
	return gv.GetInt(1596) == 1
		// and have not already completed romance
		&& !gv.GetBool(6800)
		// and player is female or SGR installed
		&& (gv.GetBool(4639) || isSGRInstalled);
}
public function bool F2509(BioWorldInfo bioWorld, int Argument)
{
	// Should AMM submenu for Ashley romance appearance show up?
	local BioGlobalVariableTable gv;
	local bool isSGRInstalled;

	isSGRInstalled = DynamicLoadObject("DLC_MOD_SameGender_GlobalTlk.GlobalTlk_tlk", Class'Object') != None;
	gv = bioWorld.GetGlobalVariables();

	// Turn on customize romance appearance (1596) && have not already completed romance
	// TODO hide if romance active with Kaidan/Liara?
	// pre recruitment customization enabled
	return gv.GetInt(1596) == 1
		// and have not already completed romance
		&& !gv.GetBool(6800)
		// and player is male or SGR installed
		&& (!gv.GetBool(4639) || isSGRInstalled);
}