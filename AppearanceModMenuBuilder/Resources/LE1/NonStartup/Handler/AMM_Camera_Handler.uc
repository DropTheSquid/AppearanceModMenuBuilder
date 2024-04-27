Class AMM_Camera_Handler extends AMM_Handler_Helper;

// Variables
var transient InterpTrackMove _interp;
var transient Vector _originalCameraPosition;
var Vector MaxZoomedOutCameraPosition;
var Vector MaxZoomedInHighCameraPosition;
var Vector MaxZoomedInLowCameraPosition;

// var InterpCurveFloat ZoomCameraXInterp;
// var InterpCurveFloat HeightCameraZInterp;
// var InterpCurveFloat HeightCameraPitchInterp;
// var InterpCurveFloat ZoomCameraHeightInterp;
// var InterpCurveFloat ZoomCameraMaxOffset;
// var InterpCurveFloat ZoomCameraMinOffset;

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
// public function SetCameraPosition(float zoom, float height)
// {
// 	local vector desiredCameraLocation;
    
    
//     // CommentFunc("Interpolate Camera X and Y according to zoom");
//     Class'BioInterpolator'.static.InterpolateFloatCurve(desiredCameraLocation.x, ZoomCameraXInterp, 0.0, 1.0, CurrentZoom);
//     location.X = originalCameraLocation.X + zoomCorrection;
//     location.Y = originalCameraLocation.Y + zoomCorrection * zoomYRatio;
//     // CommentFunc("interpolate camera Z based on height and zoom");
//     // CommentFunc("Height 0 is at feet, 1 is at top of head");
//     // CommentFunc("The max heigt and min height are determined by zoom, then height is interpolated between those.");
//     Class'BioInterpolator'.static.InterpolateFloatCurve(maxCameraHeight, ZoomCameraMaxOffset, 0.0, 1.0, CurrentZoom);
//     Class'BioInterpolator'.static.InterpolateFloatCurve(minCameraHeight, ZoomCameraMinOffset, 0.0, 1.0, CurrentZoom);
//     actualHeightDelta = minCameraHeight + CurrentHeight * (maxCameraHeight - minCameraHeight);
//     location.Z = originalCameraLocation.Z + actualHeightDelta;
// }
public function moveCamera(Vector move)
{
	local Vector currentPosition;

	if (VSize(move) > 0)
	{
		currentPosition = GetCameraPositionRaw();
		currentPosition += move;
		SetCameraPositionRaw(currentPosition);
		LogInternal("moving camera: new position"@currentPosition.x@currentPosition.y@currentPosition.z);
		CommitCamera();
	}
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
	// -1264.9181 -136.8398 105.8366
	// -1264.7749 -135.2986 103.9956
	// Z will vary per character
	// Wrex: 105
	// Humans/Asari/Quarians: 87
	// Garrus: 97
    MaxZoomedInHighCameraPosition = {X = -1265.6636, Y = -136.8608, Z = 87.0}
	// shared for all characters
    MaxZoomedInLowCameraPosition = {X = -1265.6636, Y = -136.8608, Z = -88.5265}
	// ZoomCameraXInterp = {
    //                      Points = ({InVal = -1.0, OutVal = -730.0, ArriveTangent = 1641.19446, LeaveTangent = 1641.19446, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
    //                                {InVal = 0.0, OutVal = -0.000000000000113686838, ArriveTangent = 324.959747, LeaveTangent = 324.959747, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
    //                                {InVal = 1.0, OutVal = 130.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_CurveAutoClamped}
    //                               )
    //                     }
    // HeightCameraZInterp = {
    //                        Points = ({InVal = -3.0, OutVal = -239.773209, ArriveTangent = 56.9743233, LeaveTangent = 56.9743233, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
    //                                  {InVal = 0.0, OutVal = -0.0000000000000568434189, ArriveTangent = 35.4740982, LeaveTangent = 35.4740982, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
    //                                  {InVal = 2.0, OutVal = 45.100071, ArriveTangent = 25.248373, LeaveTangent = 25.248373, InterpMode = EInterpCurveMode.CIM_CurveUser}
    //                                 )
    //                       }
    // ZoomCameraHeightInterp = {
    //                           Points = ({InVal = -1.0, OutVal = 0.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_CurveAuto}, 
    //                                     {InVal = 0.0, OutVal = 1.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}, 
    //                                     {InVal = 1.0, OutVal = 1.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
    //                                    )
    //                          }
    // ZoomCameraMaxOffset = {
    //                        Points = ({InVal = -1.0, OutVal = -70.0, ArriveTangent = 128.300858, LeaveTangent = 128.300858, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
    //                                  {InVal = 0.0, OutVal = 2.8599999, ArriveTangent = 20.1176414, LeaveTangent = 20.1176414, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
    //                                  {InVal = 1.0, OutVal = 10.5, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
    //                                 )
    //                       }
    // ZoomCameraMinOffset = {
    //                        Points = ({InVal = -1.0, OutVal = -70.0, ArriveTangent = -158.622437, LeaveTangent = -158.622437, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
    //                                  {InVal = 0.0, OutVal = -145.0, ArriveTangent = -26.752388, LeaveTangent = -26.752388, InterpMode = EInterpCurveMode.CIM_CurveAutoClamped}, 
    //                                  {InVal = 1.0, OutVal = -158.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
    //                                 )
    //                       }
}