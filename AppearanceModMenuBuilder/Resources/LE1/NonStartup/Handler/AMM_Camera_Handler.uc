Class AMM_Camera_Handler extends AMM_Handler_Helper;

// Variables
var transient InterpTrackMove _interp;
var transient PlayerStart _playerStart;
var transient SeqAct_SetLocation _setLocationAct;
var transient Vector _originalCameraPosition;
var transient Rotator _originalRotation;
var Vector2D MaxZoomedOutCameraXY;
var Vector2D MaxZoomedInCameraXY;
var Vector MaxZoomedOutCameraPosition;
var Vector MaxZoomedInHighCameraPosition;
var Vector MaxZoomedInLowCameraPosition;

var InterpCurveFloat ZoomToXYInterp;
var InterpCurveFloat ZoomToMaxZInterp;
var InterpCurveFloat ZoomToMinZInterp;

var transient float currentZoom;
var transient float currentHeight;
var transient Rotator currentRotation;

var transient float zoomInTriggerPressed;
var transient float zoomOutTriggerPressed;
var transient float moveUpDownMouse;
var transient float moveUpDownController;
var transient float rotateMouse;
var transient float rotateController;

// Functions
public function Init(ModHandler_AMM outerMenu)
{
	super.Init(outerMenu);
	// get the interp that determines camera position
    _interp = GetInterpData();
	// get the sequence action that sets the pawn rotation
	_setLocationAct = GetSetLocationNode();
	_playerStart = GetPlayerStart();
	_originalRotation = _playerStart.Rotation;
	currentRotation = _originalRotation;
	// initialize the setLocation action with the right value
	_setLocationAct.RotationValue = _originalRotation;

	// cache the original camera position
    _originalCameraPosition = GetCameraPositionRaw();
	// set it where we want it
    SetCameraPositionRaw(MaxZoomedOutCameraPosition);
	// zoomed all the way out
	currentZoom = 0;
	// head height if we zoomed in (approx)
	// TODO tune this starting position
	CurrentHeight = 0.95;
    CommitCamera();
}
public function Cleanup()
{
	// restore it to the original position
    SetCameraPositionRaw(_originalCameraPosition);
	_playerStart.Rotation = _originalRotation;
	CommitCamera();
}
public function Update(float fDeltaT)
{
	local float netZoom;

	netZoom = zoomInTriggerPressed - zoomOutTriggerPressed;
	// handle zoom in/out
	if (netZoom != 0)
	{
		// TODO tune this factor to get a comfortable speed
		zoom(netZoom * 0.5 * fDeltaT);
	}
	// handle moving the camera up/down
	if (moveUpDownController != 0)
	{
		// TODO tune this factor to get a comfortable speed
		ChangeHeight(moveUpDownController * 0.5 * fDeltaT);
	}
	if (moveUpDownMouse != 0)
	{
		// TODO tune this factor to get a comfortable speed
		ChangeHeight(moveUpDownMouse * 0.5 * fDeltaT);
	}
	if (rotateMouse != 0.0)
	{
		currentRotation.Yaw += rotateMouse * 10000 * fDeltaT;
	}
	if (rotateController != 0)
	{
		currentRotation.Yaw += rotateController * 10000 * fDeltaT;
	}
	
	if (rotateMouse != 0.0 || rotateController != 0)
	{
		LogInternal("UpdateRotation mouse"@rotateMouse@rotateMouse * 10000 * fDeltaT);
		LogInternal("UpdateRotation controller"@rotateMouse@rotateController * 10000 * fDeltaT);
		CommitRotation();
	}
}
private function CommitRotation()
{
	local BioWorldInfo BWI;

	currentRotation = Normalize(currentRotation);
	_setLocationAct.RotationValue = currentRotation;
	_playerStart.Rotation = currentRotation;
	BWI = BioWorldInfo(_outerMenu.oWorldInfo);
    BWI.m_UIWorld.TriggerEvent('re_AMM_SetRotation', BWI);
}
public function Zoom(float step)
{
	CurrentZoom = FClamp(CurrentZoom + step, 0, 1);
	SetCameraPosition(CurrentZoom, CurrentHeight);
}
public function ChangeHeight(float step)
{
	CurrentHeight = FClamp(CurrentHeight + step, 0, 1);
	SetCameraPosition(CurrentZoom, CurrentHeight);
}
private function SetCameraPosition(float zoom, float height)
{
	local vector desiredCameraLocation;
	local float MinZ;
	local float MaxZ;

    // Interpolate Camera X and Y according to zoom
	desiredCameraLocation.X = InterpolateFloat(ZoomToXYInterp, zoom, MaxZoomedOutCameraXY.X,  MaxZoomedInCameraXY.X);
	desiredCameraLocation.Y = InterpolateFloat(ZoomToXYInterp, zoom, MaxZoomedOutCameraXY.Y,  MaxZoomedInCameraXY.Y);
	// get the min z interpolated between -9 (max zoomed out camera z) and -88 (max zoom in camera z)
	MinZ = InterpolateFloat(ZoomToMinZInterp, zoom, -9, -88.5265);
	// same but from -9 to 87 (human max Z, will need to vary per character eventually)
	MaxZ = InterpolateFloat(ZoomToMaxZInterp, zoom, -9, 87);

	desiredCameraLocation.Z = Lerp(Minz, MaxZ, height);
	LogInternal("Setting camera position: inputs zoom"@zoom@"height"@height);
	LogInternal("Setting camera position: output"@desiredCameraLocation.x@desiredCameraLocation.y@desiredCameraLocation.z);
	SetCameraPositionRaw(desiredCameraLocation);
	CommitCamera();
}
// this takes in an interpCurveFloat which is assumed to run from 0,0 to 1,1
// which is then scaled to output1 - output0, then offset by output 0
// making it as if it was a curve from 0,output0 to 1,output1
// letting us reuse curves for different limits
private function float InterpolateFloat(InterpCurveFloat curve, float displacement, float output0, float output1)
{
	local float rawResult;

	Class'BioInterpolator'.static.InterpolateFloatCurve(rawResult, curve, 0.0, 1.0, displacement);
	return (rawResult * (output1 - output0)) + output0;
}
// public function moveCamera(Vector move)
// {
// 	local Vector currentPosition;

// 	if (VSize(move) > 0)
// 	{
// 		currentPosition = GetCameraPositionRaw();
// 		currentPosition += move;
// 		SetCameraPositionRaw(currentPosition);
// 		LogInternal("moving camera: new position"@currentPosition.x@currentPosition.y@currentPosition.z);
// 		CommitCamera();
// 	}
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
private final function SeqAct_SetLocation GetSetLocationNode()
{
	local SeqAct_SetLocation seqAct;

	seqAct = SeqAct_SetLocation(FindObject("BIOG_UIWorld.TheWorld.PersistentLevel.Main_Sequence.SeqAct_SetLocation_0", Class'SeqAct_SetLocation'));
	return seqAct;
}
private final function PlayerStart GetPlayerStart()
{
    local PlayerStart start;
    
    start = PlayerStart(FindObject("BIOG_UIWorld.TheWorld.PersistentLevel.PlayerStart_2", Class'PlayerStart'));
    return start;
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
	// the position by default for outfits for all characters
    MaxZoomedOutCameraPosition = {X = -1974.85974, Y = -234.663101, Z = -9.0}

	MaxZoomedOutCameraXY = {X = -1974.85974, Y = -234.663101}
	MaxZoomedInCameraXY = {X = -1265.6636, Y = -136.8608}
	// Untested, but these are the high/low zoomed in positions
	// -1264.9181 -136.8398 105.8366
	// -1264.7749 -135.2986 103.9956
	// Z will vary per character
	// Wrex: 105
	// Humans/Asari/Quarians: 87
	// Garrus: 97
	// MaxZoomedInHighCameraPosition = {X = -1265.6636, Y = -136.8608, Z = 87.0}
	// shared for all characters
	// MaxZoomedInLowCameraPosition = {X = -1265.6636, Y = -136.8608, Z = -88.5265}
	// as zoom varies from 1 to 0
	// TODO tune this interp to get an even zoom speed
	ZoomToXYInterp = {
		Points = ({InVal = 0.0, OutVal = 0.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}, 
					{InVal = 1.0, OutVal = 1.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
					), 
		InterpMethod = EInterpMethodType.IMT_UseFixedTangentEvalAndNewAutoTangents
		}
	ZoomToMaxZInterp = {
		Points = ({InVal = 0.0, OutVal = 0.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}, 
					{InVal = 1.0, OutVal = 1.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
					), 
		InterpMethod = EInterpMethodType.IMT_UseFixedTangentEvalAndNewAutoTangents
		}
	ZoomToMinZInterp = {
		Points = ({InVal = 0.0, OutVal = 0.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}, 
					{InVal = 1.0, OutVal = 1.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
					), 
		InterpMethod = EInterpMethodType.IMT_UseFixedTangentEvalAndNewAutoTangents
		}
}

// Tali Face zoom  moving camera: new position -1324.2717 -144.1307 70.6261
// male human face zoom new position -1324.2717 -144.1307 74.3055
// female human same
// garrus -1324.2717 -144.1307 80.4759
// wrex is totally different moving camera: new position -1403.0068 -148.1730 74.9644

// I am going to make it work for humans/asari first, and then worry about others