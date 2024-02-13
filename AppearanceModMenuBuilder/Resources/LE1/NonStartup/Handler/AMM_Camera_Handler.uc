Class AMM_Camera_Handler extends AMM_Handler_Helper;

// Variables
var transient InterpTrackMove _interp;
var transient Vector _originalCameraPosition;
var Vector MaxZoomedOutCameraPosition;
var Vector MaxZoomedInHighCameraPosition;
var Vector MaxZoomedInLowCameraPosition;

// Functions
public function Init(ModHandler_AMM outerMenu)
{
	super.Init(outerMenu);
	// get the interp that determines camera position
    _interp = GetInterpData();
	// cache the original camera position
    _originalCameraPosition = GetCameraPositionRaw();
	// set it where we want it
    SetCameraPositionRaw(MaxZoomedOutCameraPosition);
    CommitCamera();
}
public function Cleanup()
{
	// restore it to the original position
    SetCameraPositionRaw(_originalCameraPosition);
	CommitCamera();
}
// public function SetCameraPosition(float height, float zoom)
// {
// }
// public function DebugChangeAxis(bool increase, int axis)
// {
//     local Vector currentPosition;
//     local float delta;
    
//     currentPosition = GetCameraPositionRaw();
//     delta = increase ? 1.0 : -1.0;
//     switch (axis)
//     {
//         case 0:
//             currentPosition.X += delta;
//             break;
//         case 1:
//             currentPosition.Y += delta;
//             break;
//         case 2:
//             currentPosition.Z += delta;
//             break;
//         default:
//             LogInternal("Invalid Axis" @ axis, );
//             return;
//     }
//     Self.SetCameraPositionRaw(currentPosition);
//     LogInternal("new camera position:" @ currentPosition.X @ currentPosition.Y @ currentPosition.Z, );
//     CommitCamera();
// }
public function SetCameraPositionRaw(Vector position)
{
    _interp.PosTrack.Points[0].OutVal = position;
}
public function Vector GetCameraPositionRaw()
{
    return _interp.PosTrack.Points[0].OutVal;
}
public function CommitCamera()
{
	local BioWorldInfo BWI;

	BWI = BioWorldInfo(_outerMenu.oWorldInfo);
    BWI.m_UIWorld.TriggerEvent('re_AMM_UpdateCameraPosition', BWI);
}
private final function InterpTrackMove GetInterpData()
{
    local InterpTrackMove interp;
    
    interp = InterpTrackMove(FindObject("BIOG_UIWorld.TheWorld.PersistentLevel.Main_Sequence.InterpData_1.InterpGroup_0.InterpTrackMove_0", Class'InterpTrackMove'));
    return interp;
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
	// the position by default for outfits for all characters
    MaxZoomedOutCameraPosition = {X = -1974.85974, Y = -234.663101, Z = -9.0}
	// Untested, but these are the high/low zoomed in positions
    MaxZoomedInHighCameraPosition = {X = -1316.85974, Y = -142.663101, Z = 95.0}
    MaxZoomedInLowCameraPosition = {X = -1316.85974, Y = -142.663101, Z = -84.0}
}