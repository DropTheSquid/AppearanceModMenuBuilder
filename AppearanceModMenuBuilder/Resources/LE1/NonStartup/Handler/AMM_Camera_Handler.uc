Class AMM_Camera_Handler extends AMM_Handler_Helper;

// Variables
var transient InterpTrackMove _interp;
var transient PlayerStart _playerStart;
var transient SeqAct_SetLocation _setLocationAct;
var transient Vector _originalCameraPosition;
var transient Rotator _originalRotation;

var Vector2D MaxZoomedOutCameraXY;
var Vector2D MaxZoomedInCameraXY;
var float ZoomedOutHeight;
var float ZoomedInMinHeight;
var float ZoomedInMaxHeight;
// var Vector MaxZoomedOutCameraPosition;
// var Vector MaxZoomedInHighCameraPosition;
// var Vector MaxZoomedInLowCameraPosition;
var float controllerZoomMultiplier;
var float mouseWheelZoomStep;
var float controllerMoveUpDownMultiplier;
var float mouseMoveUpDownMultiplier;
var float controllerRotateMultiplier;
var float mouseRotateMultiplier;

var InterpCurveFloat ZoomToXYInterp;
// var InterpCurveFloat ZoomToMaxZInterp;
// var InterpCurveFloat ZoomToMinZInterp;

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
	// zoomed all the way out
	currentZoom = 0;
	// head height if we zoomed in (approx)
	CurrentHeight = 0.95;
	UpdateCameraPosition();
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
	local float netRotate;
	local float netMoveUpDown;

	// handle zoom in/out
	netZoom = (zoomInTriggerPressed - zoomOutTriggerPressed) * controllerZoomMultiplier;
	if (netZoom != 0)
	{
		zoom(netZoom * fDeltaT);
	}

	// handle moving the camera up/down
	netMoveUpDown = (moveUpDownController * controllerMoveUpDownMultiplier) + (moveUpDownMouse * mouseMoveUpDownMultiplier);
	if (netMoveUpDown != 0)
	{
		ChangeHeight(netMoveUpDown * fDeltaT);
	}
	
	// handle rotation
	netRotate = (rotateController * controllerRotateMultiplier) + (rotateMouse * mouseRotateMultiplier);
	if (netRotate != 0)
	{
		currentRotation.Yaw += int(netRotate * fDeltaT);
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
public function MouseWheelZoom(bool zoomIn)
{
	Zoom(mouseWheelZoomStep * (zoomIn ? -1 : 1));
}
private function Zoom(float step)
{
	CurrentZoom = FClamp(CurrentZoom + step, 0, 1);
	UpdateCameraPosition();
}
private function ChangeHeight(float step)
{
	CurrentHeight = FClamp(CurrentHeight + step, 0, 1);
	UpdateCameraPosition();
}
private function UpdateCameraPosition()
{
	local vector desiredCameraLocation;
	local float MinZ;
	local float MaxZ;

    // Interpolate Camera X and Y according to zoom
	desiredCameraLocation.X = InterpolateFloat(ZoomToXYInterp, currentZoom, MaxZoomedOutCameraXY.X,  MaxZoomedInCameraXY.X);
	desiredCameraLocation.Y = InterpolateFloat(ZoomToXYInterp, currentZoom, MaxZoomedOutCameraXY.Y,  MaxZoomedInCameraXY.Y);
	// get the min z interpolated between zoomed out camera z and zoomed in camera min z (looking at feet)
	MinZ = InterpolateFloat(ZoomToXYInterp, currentZoom, ZoomedOutHeight, ZoomedInMinHeight);
	// same but max z, looking at the top of the head. this will need to vary by character
	MaxZ = InterpolateFloat(ZoomToXYInterp, currentZoom, ZoomedOutHeight, ZoomedInMaxHeight);

	desiredCameraLocation.Z = Lerp(Minz, MaxZ, CurrentHeight);
	LogInternal("Setting camera position: inputs zoom"@currentZoom@"height"@CurrentHeight);
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
	// determined through testing to be a pretty comfortable value
	controllerRotateMultiplier = -50000
	mouseRotateMultiplier = -4000
	controllerZoomMultiplier = 0.5
	controllerMoveUpDownMultiplier = -0.5
	mouseMoveUpDownMultiplier = -0.15
	// intended to have 20 steps between 0 (zoomed out) and 1 (zoomed in) so this is 1/20th
	mouseWheelZoomStep = 0.05

	ZoomedOutHeight = -9
	ZoomedInMinHeight = -88.5
	// TODO this will need to vary by character
	ZoomedInMaxHeight = 87

	// the position by default for outfits for all characters
	// MaxZoomedOutCameraPosition = {X = -1974.85974, Y = -234.663101, Z = -9.0}
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
	ZoomToXYInterp = {
		Points = ({InVal = -0.000000000000000222044605, OutVal = 0.0, ArriveTangent = 2.21512413, LeaveTangent = 2.21512413, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
				{InVal = 0.5, OutVal = 0.802072883, ArriveTangent = 0.598061323, LeaveTangent = 0.598061323, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
				{InVal = 1.0, OutVal = 1.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
				)
		}
}

// Tali Face zoom  moving camera: new position -1324.2717 -144.1307 70.6261
// male human face zoom new position -1324.2717 -144.1307 74.3055
// female human same
// garrus -1324.2717 -144.1307 80.4759
// wrex is totally different moving camera: new position -1403.0068 -148.1730 74.9644

// I am going to make it work for humans/asari first, and then worry about others