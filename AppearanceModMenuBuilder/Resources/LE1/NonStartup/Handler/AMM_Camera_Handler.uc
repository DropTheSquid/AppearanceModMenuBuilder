Class AMM_Camera_Handler extends AMM_Handler_Helper;

// Things we need to modify/restore to change the camera and pawn rotation
var transient InterpTrackMove _interp;
var transient PlayerStart _playerStart;
var transient SeqAct_SetLocation _setLocationAct;
var transient Vector _originalCameraPositionRaw;
var transient Rotator _originalRotation;

// hardcoded
var Vector2D MaxZoomedOutCameraXY;
var Vector2D MaxZoomedInCameraXY;
var float ZoomedOutHeight;
var float ZoomedInMinHeight;
var float controllerZoomMultiplier;
var float mouseWheelZoomStep;
var float controllerMoveUpDownMultiplier;
var float mouseMoveUpDownMultiplier;
var float controllerRotateMultiplier;
var float mouseRotateMultiplier;
// varies by character
var float ZoomedInMaxHeight;

// interps to make everything feel smooth
var InterpCurveFloat ZoomToXYInterp;
var InterpCurveFloat MoveUpDownSensitivityByZoom;

// the current state of the variables that determine the view
var transient cameraPosition currentCameraPosition;

// indicates whether/to what degree the camera is being moved right now
var transient float zoomInTriggerPressed;
var transient float zoomOutTriggerPressed;
var transient float moveUpDownMouse;
var transient float moveUpDownController;
var transient float rotateMouse;
var transient float rotateController;

var transient cameraTransition currentCameraTransition;
var InterpCurveFloat CameraTransitionCurve;

var bool debugLogging;

struct cameraPosition
{
	var float zoom;
	var float height;
	// yaw is the relevant bit, it is in unreal units of 365 deg = 65535
	var rotator rotation;
};

struct cameraTransition
{
	var cameraPosition start;
	var cameraPosition end;
	var float transitionTime;
	var float remainingTime;
};

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
	currentCameraPosition.Rotation = _originalRotation;
	// initialize the setLocation action with the right value
	_setLocationAct.RotationValue = _originalRotation;

	// cache the original camera position
    _originalCameraPositionRaw = GetCameraPositionRaw();
}

public function Cleanup()
{
	// restore it to the original position
    SetCameraPositionRaw(_originalCameraPositionRaw);
	_playerStart.Rotation = _originalRotation;
	CommitCamera();
}

public function ResetCameraForCharacter(string tag)
{
	local AMM_Pawn_Parameters params;

	if (tag != "None" && _outerMenu.paramHandler.GetPawnParamsByTag(tag, params))
	{
		// zoomed all the way out
		currentCameraPosition.zoom = 0;
		// head height if we zoomed in (approx)
		currentCameraPosition.Height = 0.95;
		// get the max camera height from the body spec list
		ZoomedInMaxHeight = OutfitSpecListBase(params.GetOutfitSpecList(_outermenu.pawnHandler.GetUIWorldPawn())).PreviewCameraMaxHeight;
		// it can be overridden by the pawn params
		if (params.PreviewCameraMaxHeight != 0)
		{
			ZoomedInMaxHeight = params.PreviewCameraMaxHeight;
		}
		UpdateCameraPosition();

		currentCameraPosition.Rotation = _originalRotation;
		CommitRotation();
	}
	else
	{
		SetCameraPositionRaw(_originalCameraPositionRaw);
	}
}

public function Update(float fDeltaT)
{
	local float netZoom;
	local float upDownSensitivityMultiplier;
	local float transitionPercent;

	// handle zoom in/out
	netZoom = (zoomInTriggerPressed - zoomOutTriggerPressed) * controllerZoomMultiplier;
	if (netZoom != 0)
	{
		zoom(netZoom * fDeltaT);
	}

	// handle moving the camera up/down
	if (moveUpDownMouse != 0)
	{
		upDownSensitivityMultiplier = InterpolateFloat(MoveUpDownSensitivityByZoom, currentCameraPosition.zoom, 0.0, 1.0);
		// I need to exclude fDeltaT from this calculation because it is essentialy already included in how much the mouse moves each frame
		ChangeHeight(moveUpDownMouse * mouseMoveUpDownMultiplier * upDownSensitivityMultiplier);
	}
	if (moveUpDownController != 0)
	{
		// if the sensitivity is the same at all zoom levels, then it is way too sensitive while zoomed in, and not sensitive enough while zoomed out
		// this makes it feel smooth
		upDownSensitivityMultiplier = InterpolateFloat(MoveUpDownSensitivityByZoom, currentCameraPosition.zoom, 0.0, 1.0);
		// if (debugLogging)
		// {
		// 	LogInternal("UpDownSensitivity zoom"@currentCameraPosition.zoom@"sensitivity"@upDownSensitivityMultiplier);
		// }
		ChangeHeight(moveUpDownController * controllerMoveUpDownMultiplier * fDeltaT * upDownSensitivityMultiplier);
	}
	if (moveUpDownMouse != 0 || moveUpDownController != 0 || netZoom != 0)
	{
		// cancel any in progress camera transition
		currentCameraTransition.RemainingTime = 0;
		UpdateCameraPosition();
	}
	
	// handle rotation
	if (rotateController != 0)
	{
		currentCameraPosition.Rotation.yaw += int(rotateController * controllerRotateMultiplier * fDeltaT);
	}
	if (rotateMouse != 0)
	{
		currentCameraPosition.Rotation.yaw += int(rotateMouse * mouseRotateMultiplier);
	}
	if (rotateController != 0 || rotateMouse != 0)
	{
		// cancel any in progress camera transition
		currentCameraTransition.RemainingTime = 0;
		CommitRotation();
	}

	// there is an active transition; update it
	if (currentCameraTransition.RemainingTime > 0)
	{
		currentCameraTransition.RemainingTime -= fDeltaT;
		if (currentCameraTransition.RemainingTime < 0)
		{
			currentCameraTransition.RemainingTime = 0;
		}

		transitionPercent = InterpolateFloat(CameraTransitionCurve, (currentCameraTransition.TransitionTime - currentCameraTransition.RemainingTime) / currentCameraTransition.TransitionTime, 0, 1);
		currentCameraPosition.zoom = Lerp(currentCameraTransition.Start.zoom, currentCameraTransition.end.zoom, transitionPercent);
		currentCameraPosition.Height = Lerp(currentCameraTransition.Start.Height, currentCameraTransition.end.Height, transitionPercent);
		currentCameraPosition.rotation = RLerp(currentCameraTransition.Start.Rotation, currentCameraTransition.end.Rotation, transitionPercent, true);
		UpdateCameraPosition();
		CommitRotation();
	}
}

private function CommitRotation()
{
	local BioWorldInfo BWI;

	if (debugLogging)
	{
		LogInternal("Setting rotation to"@currentCameraPosition.Rotation.yaw@Normalize(currentCameraPosition.Rotation).yaw);
	}

	currentCameraPosition.Rotation = Normalize(currentCameraPosition.Rotation);
	_setLocationAct.RotationValue = currentCameraPosition.Rotation;
	_playerStart.Rotation = currentCameraPosition.Rotation;
	BWI = BioWorldInfo(_outerMenu.oWorldInfo);
    BWI.m_UIWorld.TriggerEvent('re_AMM_SetRotation', BWI);
}

public function MouseWheelZoom(bool zoomIn)
{
	// cancel any in progress camera transition
	currentCameraTransition.RemainingTime = 0;
	Zoom(mouseWheelZoomStep * (zoomIn ? -1 : 1));
	UpdateCameraPosition();
}

private function Zoom(float step)
{
	// if (step > 0)
	// {
	// 	_outerMenu.UIWorldEvent('re_AMM_ZoomedIn');
	// }
	// else
	// {
	// 	_outerMenu.UIWorldEvent('re_AMM_ZoomedOut');
	// }
	currentCameraPosition.zoom = FClamp(currentCameraPosition.zoom + step, 0, 1);
}

private function ChangeHeight(float step)
{
	currentCameraPosition.height = FClamp(currentCameraPosition.height + step, 0, 1);
}

public function GoToCameraPosition(float zoom, float height, float rotation, float transitionTime)
{
	zoom = FClamp(zoom, 0, 1);
	height = FClamp(height, 0, 1);
	Rotation = FClamp(Rotation, -1, 1);

	// if the transition time is zero, go straight to the final position with no delay
	if (TransitionTime == 0)
	{
		// cancel any in progress camera transition
		currentCameraTransition.RemainingTime = 0;
		// immediately go to the new position
		currentCameraPosition.zoom = zoom;
		currentCameraPosition.height = height;
		currentCameraPosition.rotation.yaw = _originalRotation.yaw + (rotation * 65535);
		UpdateCameraPosition();
		CommitRotation();
	}

	// height has no effect on when all the way zoomed out, so we can skip straight to the desired height
	if (currentCameraPosition.zoom == 0)
	{
		currentCameraPosition.Height = height;
	}

	// similarly, if the target is to zoom all the way out, we don't need to transition the height
	// this will minimize the appearance of the camera moving up and down while moving out
	if (zoom == 0)
	{
		height = currentCameraPosition.Height;
	}

	currentCameraTransition.start = currentCameraPosition;
	currentCameraTransition.end.zoom = zoom;
	currentCameraTransition.end.height = height;
	currentCameraTransition.end.rotation.yaw = _originalRotation.yaw + (rotation * 65535);
	
	currentCameraTransition.transitionTime = TransitionTime;
	currentCameraTransition.RemainingTime = TransitionTime;
}

private function UpdateCameraPosition()
{
	local vector desiredCameraLocation;
	local float MinZ;
	local float MaxZ;

    // Interpolate Camera X and Y according to zoom
	desiredCameraLocation.X = InterpolateFloat(ZoomToXYInterp, currentCameraPosition.zoom, MaxZoomedOutCameraXY.X, MaxZoomedInCameraXY.X);
	desiredCameraLocation.Y = InterpolateFloat(ZoomToXYInterp, currentCameraPosition.zoom, MaxZoomedOutCameraXY.Y, MaxZoomedInCameraXY.Y);
	// get the min z interpolated between zoomed out camera z and zoomed in camera min z (looking at feet)
	MinZ = InterpolateFloat(ZoomToXYInterp, currentCameraPosition.zoom, ZoomedOutHeight, ZoomedInMinHeight);
	// same but max z, looking at the top of the head. this will need to vary by character
	MaxZ = InterpolateFloat(ZoomToXYInterp, currentCameraPosition.zoom, ZoomedOutHeight, ZoomedInMaxHeight);

	desiredCameraLocation.Z = Lerp(Minz, MaxZ, currentCameraPosition.Height);
	if (debugLogging)
	{
		LogInternal("Setting camera position: inputs zoom"@currentCameraPosition.Zoom@"height"@currentCameraPosition.Height);
		LogInternal("Setting camera position: output"@desiredCameraLocation.x@desiredCameraLocation.y@desiredCameraLocation.z);
	}
	
	SetCameraPositionRaw(desiredCameraLocation);
	CommitCamera();
}

// this takes in an interpCurveFloat which is assumed to run from 0 to 1 inputs and 0 to 1 outputs
// which is then scaled to output1 - output0, then offset by output0
// making it as if it was a curve from 0,output0 to 1,output1
// letting us reuse curves for different limits
private function float InterpolateFloat(InterpCurveFloat curve, float displacement, float output0, float output1)
{
	local float rawResult;

	Class'BioInterpolator'.static.InterpolateFloatCurve(rawResult, curve, 0.0, 1.0, displacement);
	return (rawResult * (output1 - output0)) + output0;
}

private function SetCameraPositionRaw(Vector position)
{
    _interp.PosTrack.Points[0].OutVal = position;
}

private function Vector GetCameraPositionRaw()
{
    return _interp.PosTrack.Points[0].OutVal;
}

private function CommitCamera()
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
	// determined through testing to be pretty comfortable values
	controllerRotateMultiplier = -50000
	mouseRotateMultiplier = -66.66666
	controllerZoomMultiplier = 0.5
	controllerMoveUpDownMultiplier = 3.5
	mouseMoveUpDownMultiplier = -0.0035
	// intended to have 20 steps between 0 (zoomed out) and 1 (zoomed in) so this is 1/20th
	mouseWheelZoomStep = 0.05
	ZoomedOutHeight = -9
	ZoomedInMinHeight = -88.5

	debugLogging = false

	MaxZoomedOutCameraXY = {X = -1974.85974, Y = -234.663101}
	MaxZoomedInCameraXY = {X = -1265.6636, Y = -136.8608}
	
	// Maps from zoom (0 = zoomed out fully, 1 = zoomed in fully) to the relative x/y/z position between the zoomed out and zoomed in camera locations
	// if this relationship is linear, then it is way too sensitive far away from the character and not sensitive enough close to the character
	// with this, the halfway zoom point is a good view of the head and it feels smooth
	ZoomToXYInterp = {
		Points = ({InVal = -0.000000000000000222044605, OutVal = 0.0, ArriveTangent = 2.21512413, LeaveTangent = 2.21512413, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
				{InVal = 0.5, OutVal = 0.802072883, ArriveTangent = 0.598061323, LeaveTangent = 0.598061323, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
				{InVal = 1.0, OutVal = 1.0, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_Linear}
				)
		}
	// maps from zoom to the relative sensitivity of moving the camera up/down.
	// without this, it is way too sensitive up close and too insensitive far away. This evens it out
	MoveUpDownSensitivityByZoom = {
		Points = ({InVal = 0.0, OutVal = 2.47969842, ArriveTangent = -7.64156532, LeaveTangent = -7.64156532, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
					{InVal = 0.35, OutVal = 0.381911516, ArriveTangent = -2.18307185, LeaveTangent = -2.18307185, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
					{InVal = 0.5, OutVal = 0.197620898, ArriveTangent = -0.651773274, LeaveTangent = -0.651773274, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
					{InVal = 0.8, OutVal = 0.0702829957, ArriveTangent = -0.295241803, LeaveTangent = -0.295241803, InterpMode = EInterpCurveMode.CIM_CurveAuto}, 
					{InVal = 1.0, OutVal = 0.0500000007, ArriveTangent = 0.0, LeaveTangent = 0.0, InterpMode = EInterpCurveMode.CIM_CurveAuto}
				)
		}

	// makes camera transitions nice and smooth
	CameraTransitionCurve = {
		Points = ({InVal = 0, OutVal = 0.00157867733, ArriveTangent = -0.0326901302, LeaveTangent = -0.0326901302, InterpMode = EInterpCurveMode.CIM_CurveBreak}, 
				{InVal = 0.484916598, OutVal = 0.494218081, ArriveTangent = 1.32384884, LeaveTangent = 1.32384884, InterpMode = EInterpCurveMode.CIM_CurveUser}, 
				{InVal = 1.0, OutVal = 1.0, ArriveTangent = -0.0195635185, LeaveTangent = -0.0195635185, InterpMode = EInterpCurveMode.CIM_CurveUser}
				)
		}
}