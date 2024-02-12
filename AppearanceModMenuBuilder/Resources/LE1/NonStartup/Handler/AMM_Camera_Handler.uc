Class AMM_Camera_Handler;

// Variables
var transient ModHandler_AMM _outerMenu;
var transient InterpTrackMove _interp;
var transient BioWorldInfo BWI;
var transient Vector _originalCameraPosition;
var Vector MaxZoomedOutCameraPosition;
var Vector MaxZoomedInHighCameraPosition;
var Vector MaxZoomedInLowCameraPosition;

// Functions
public function Initialize(ModHandler_AMM outerMenu)
{
    _outerMenu = outerMenu;
    _interp = GetInterpData();
    BWI = BioWorldInfo(_outerMenu.oWorldInfo);
    _originalCameraPosition = GetCameraPositionRaw();
    SetCameraPositionRaw(MaxZoomedOutCameraPosition);
    CommitCamera();
}
public function Cleanup()
{
    SetCameraPositionRaw(_originalCameraPosition);
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
    MaxZoomedOutCameraPosition = {X = -1974.85974, Y = -234.663101, Z = -9.0}
    MaxZoomedInHighCameraPosition = {X = -1316.85974, Y = -142.663101, Z = 95.0}
    MaxZoomedInLowCameraPosition = {X = -1316.85974, Y = -142.663101, Z = -84.0}
}