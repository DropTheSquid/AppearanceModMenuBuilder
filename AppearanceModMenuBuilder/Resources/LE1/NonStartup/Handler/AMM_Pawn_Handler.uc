Class AMM_Pawn_Handler extends AMM_Handler_Helper;

// a way to keep track of the real world pawns we spawn UI world pawns based on
// some need to be left alone at the end, some need to be destroyed/streamed out
struct RealWorldPawnRecord
{
	// the real world pawn
    var BioPawn Pawn;
	// the tag and appearance type that uniquely identifies them
	var string Tag;
	var string appearanceType;
	// if I spawned the pawn in, they should be destroyed at the end; if they were already there, they should not be. 
    var bool shouldBeDestroyed;

	// var bool shouldBeStreamedOut;
    
    // var Name streamedInName;
    // var originalStreamingState originalState;
};
enum PawnLoadState
{
	loaded,
	loading,
	failed
};
enum FrameworkStreamState
{
	// it is not present in the levelStreaming list and must be added to stream it in
	NotPresent,
	// it is present in the list, but not currently streamed in
    StreamedOut,
	// it is in the early process of loading
    Loading,
	// it is loaded, but not visible, and is not progressing further at the moment
    Loaded,
	// it is loaded and a request to make it visible is pending
    BecomingVisible,
	// it is loaded and visible
    visible,
};

enum DesiredStreamingState
{
	NotPresent,
	Unloaded,
	Loaded,
	Visible
};

// all the info needed for a single async request
struct StreamInRequest
{
	// which file are we waiting for?
	var string frameworkFileName;
	// what is the tag and appearance type of the pawn to look for in that file?
	var array<PawnId> pawnIds;
	// the original state of this framework file, so we can restore it when we are done
	var FrameworkStreamState originalState;
	// the state we want this file to be in
	var DesiredStreamingState desiredState;
	
	var bool completed;
	struct PawnId
	{
		var string tag;
		var string appearanceType;
	};
};

// these will never actually be used, but the compiler insists on them being here
// var transient delegate<WaitCallback> __WaitCallback__Delegate;
// var transient delegate<SettledCallback> __SettledCallback__Delegate;
// var transient delegate<FinishedLoadingPawnDelegate> __FinishedLoadingPawn__Delegate;

// delegates for signature
// public delegate function bool WaitCallback(PendingFrameworkStreamingRequest request);
// public delegate function SettledCallback(PendingFrameworkStreamingRequest request, optional bool succeeded);

// var delegate<FinishedLoadingPawnDelegate> __FinishedLoadingPawnDelegate__Delegate;

var transient array<StreamInRequest> inProgressRequests;
var transient array<StreamInRequest> queuedRequests;

var transient array<RealWorldPawnRecord> pawnRecords;
// var transient int currentPawnIndex;

// public delegate function FinishedLoadingPawnDelegate(string tag, string appearanceType, bool successful);

public function Cleanup()
{
	// TODO clean up any pawns that need to be destroyed/streamed out
}

public function PawnLoadState LoadPawn(string tag, string appearanceType)
{
	local RealWorldPawnRecord currentRecord;
	local AMM_Pawn_Parameters params;
	local BioPawn pawn;
	local string frameworkFileName;

	// first look to see if we already have a suitable pawn
	foreach pawnRecords(currentRecord)
	{
		if (currentRecord.tag == tag && currentRecord.appearanceType == appearanceType)
		{
			displayPawn(currentRecord.pawn);
			return PawnLoadState.Loaded;
		}
	}
	// next see if we can synchronously find/spawn a pawn.
	// The player we can always find; combat squadmates currently in party we can find
	// combat squadmates not currently in the party we can spawn
	// casual squadmates, we can stream in (if framework present) or spawn the combat version and override armor appearance
	if (_outerMenu.paramHandler.GetPawnParamsByTag(tag, params))
	{
		if (params.GetExistingPawn(appearanceType, pawn))
		{
			// add a record that should not be destroyed at the end
			currentRecord.Tag = tag;
			currentRecord.appearanceType = appearanceType;
			currentRecord.Pawn = pawn;
			currentRecord.shouldBeDestroyed = false;
			pawnRecords.AddItem(currentRecord);

			displayPawn(pawn);
			return PawnLoadState.loaded;
		}
		if (params.SpawnPawn(appearanceType, pawn))
		{
			// add a record that should be destroyed at the end
			currentRecord.Tag = tag;
			currentRecord.appearanceType = appearanceType;
			currentRecord.Pawn = pawn;
			currentRecord.shouldBeDestroyed = true;
			pawnRecords.AddItem(currentRecord);

			displayPawn(pawn);
			return PawnLoadState.Loaded;
		}
		// next try streaming the pawn in
		if (params.GetFrameworkFileForAppearanceType(appearanceType, frameworkFileName))
		{
			LoadFrameworkFile(tag, appearanceType, FrameworkFileName);
			return PawnLoadState.loading;
		}
		
		LogInternal("found params but couldn't find pawn for tag"@tag);
		return PawnLoadState.failed;
	}
	// could not find any params for this tag; that's not great. 
	LogInternal("Could not find params for tag"@tag);
	return PawnLoadState.failed;
}

private function displayPawn(BioPawn pawn)
{
	// TODO
}

private function LoadFrameworkFile(string tag, string appearanceType, string fileName)
{
	local StreamInRequest request;
	local int i;

	LogInternal("LoadFrameworkFile"@tag@appearanceType@Filename);
	// first, check if we already have a pending or in progress request for this
	if (GetAsyncRequest(inProgressRequests, fileName, request, i))
	{
		// there is already a request in progress. See if it already has the requested tag and appearance type
		// TODO support more than one
		return;
	}
	// TODO check for a queued one and move it into inProgress once that is supported
	request.frameworkFileName = fileName;
	request.pawnIds.Length = 1;
	request.pawnIds[0].tag = tag;
	request.pawnIds[0].appearanceType = appearanceType;
	request.originalState = GetFileStreamingState(fileName);
	request.desiredState = DesiredStreamingState.visible;
	inProgressRequests.AddItem(request);
}
private function bool GetAsyncRequest(array<StreamInRequest> requests, string fileName, out StreamInRequest request, out int index)
{
	local int i;

	foreach requests(request, i)
	{
		if (request.frameworkFilename == fileName)
		{
			return true;
		}
	}
	return false;
}

private final function FrameworkStreamState GetFileStreamingState(string fileName, optional out LevelStreaming tempLevelStreaming)
{
    local int i;

    for (i = 0; i < _outerMenu.oWorldInfo.StreamingLevels.Length; i++)
    {
        tempLevelStreaming = _outerMenu.oWorldInfo.StreamingLevels[i];
        if (string(tempLevelStreaming.packageName) ~= fileName)
        {
            if (tempLevelStreaming.bIsVisible)
            {
                return FrameworkStreamState.visible;
            }
            else if (tempLevelStreaming.bShouldBeVisible)
            {
                return FrameworkStreamState.BecomingVisible;
            }
            else if (tempLevelStreaming.bShouldBeLoaded)
            {
                if (tempLevelStreaming.bHasLoadRequestPending || tempLevelStreaming.LoadedLevel == None)
                {
                    return FrameworkStreamState.Loading;
                }
                else
                {
                    return FrameworkStreamState.Loaded;
                }
            }
            // LogInternal("File" @ fileName @ "is not streamed in, but hypothetically could be", );
            return FrameworkStreamState.StreamedOut;
        }
    }
    // LogInternal("File" @ fileName @ "is not streamed in, and is not in the list of StreamingLevels", );
    tempLevelStreaming = None;
    return FrameworkStreamState.NotPresent;
}
// private final function bool StreamInPawn(string tag, string appearanceType, string fileName)
// {
// 	local FrameworkStreamState originalState;
// 	local StreamInRequest request;

//     originalState = GetFileStreamingState(fileName);

// 	request.pawnIds.Length = 1;
//     // if (tempLevelStreaming.bShouldBeVisible)
//     // {
//     //     LogInternal("file" @ fileName @ "was already visible", );
//     //     originalState = state;
//     // }
//     // else if (tempLevelStreaming.bShouldBeLoaded)
//     // {
//     //     LogInternal("file" @ fileName @ "was already loaded", );
//     //     originalState = state;
//     // }
//     // else if (tempLevelStreaming != None)
//     // {
//     //     LogInternal("file" @ fileName @ "was not streamed in", );
//     //     originalState = originalStreamingState.NotLoaded;
//     // }
//     // else
//     // {
//     //     LogInternal("file" @ fileName @ "was not present in the LevelStreaming list", );
//     //     originalState = originalStreamingState.NotPresent;
//     // }
//     // if (state == FrameworkStreamState.NotStreamedIn)
//     // {
//     //     LogInternal("Starting to load in file" @ fileName $ "; waiting up to 2 seconds", );
//     //     SetLevelStreamingStatus(Name(fileName), TRUE, FALSE);
//     //     frameworkFileToWaitFor = fileName;
//     //     pawnKeysToWaitFor = pawnKeys;
//     //     appearanceTypeToWaitFor = appearanceType;
//     //     WaitFor(2.0, IsFrameworkFileLoaded, FileIsLoaded);
//     //     return FALSE;
//     // }
//     // else if (state == FrameworkStreamState.Loading)
//     // {
//     //     LogInternal("file is loading already. Not sure how we got here, but it's not an error case, just a weird one", );
//     //     frameworkFileToWaitFor = fileName;
//     //     pawnKeysToWaitFor = pawnKeys;
//     //     appearanceTypeToWaitFor = appearanceType;
//     //     WaitFor(2.0, IsFrameworkFileLoaded, FileIsLoaded);
//     //     return FALSE;
//     // }
//     // else if (state == FrameworkStreamState.Loaded)
//     // {
//     //     LogInternal("file is loaded already. make it visible", );
//     //     SetLevelStreamingStatus(Name(fileName), TRUE, TRUE);
//     //     frameworkFileToWaitFor = fileName;
//     //     pawnKeysToWaitFor = pawnKeys;
//     //     appearanceTypeToWaitFor = appearanceType;
//     //     WaitFor(2.0, IsFrameworkFileVisible, FileIsVisible);
//     //     return FALSE;
//     // }
//     // else if (state == FrameworkStreamState.BecomingVisible)
//     // {
//     //     LogInternal("File is becoming visible. Again, an odd one we are very unlikely to hit, but not an error case", );
//     //     frameworkFileToWaitFor = fileName;
//     //     pawnKeysToWaitFor = pawnKeys;
//     //     appearanceTypeToWaitFor = appearanceType;
//     //     WaitFor(2.0, IsFrameworkFileVisible, FileIsVisible);
//     //     return FALSE;
//     // }
//     // else if (state == FrameworkStreamState.visible)
//     // {
//     //     LogInternal("Pawn is already streamed in.", );
//     //     frameworkFileToWaitFor = fileName;
//     //     pawnKeysToWaitFor = pawnKeys;
//     //     appearanceTypeToWaitFor = appearanceType;
//     //     OriginalStreamedInState = 4;
//     //     VisibleWaitDone();
//     //     return TRUE;
//     // }
//     // return FALSE;
// }
// private function bool GetCurrentDisplayPawn(out RealWorldPawnRecord record)
// {
// 	if (currentPawnIndex >= 0 && currentPawnIndex < pawnRecords.Length)
// 	{
// 		record = pawnRecords[currentPawnIndex];
// 		return true;
// 	}
// 	return false;
// }

// private final function WaitFor(float timeout, delegate<WaitCallback> callback, optional delegate<SettledCallback> endCallback)
// {
//     LogInternal("WaitFor" @ timeout @ callback @ endCallback, );
//     if (callback())
//     {
//         LogInternal("WaitFor ended synchronously", );
//         SettledCallback(TRUE);
//         return;
//     }
//     remainingWaitTime = timeout;
//     __WaitCallback__Delegate = callback;
//     __SettledCallback__Delegate = endCallback;
//     _outerMenu.__PawnHandlerUpdate__Delegate = WaitUpdate;
// }
// private final function bool WaitUpdate(float fDeltaT)
// {
//     LogInternal("WaitUpdate" @ remainingWaitTime @ __WaitCallback__Delegate @ __SettledCallback__Delegate, );
//     if (remainingWaitTime > 0.0)
//     {
//         if (__WaitCallback__Delegate())
//         {
//             LogInternal("WaitFor ended asynchronously", );
//             __SettledCallback__Delegate(TRUE);
//         }
//         else
//         {
//             remainingWaitTime -= fDeltaT;
//         }
//     }
//     else
//     {
//         LogInternal("WaitFor timed out", );
//         remainingWaitTime = 0.0;
//         __SettledCallback__Delegate(FALSE);
//     }
//     return TRUE;
// }


public function update(float fDeltaT)
{
	local StreamInRequest currentRequest;
	local FrameworkStreamState currentState;
	local LevelStreaming tempLevelStreaming;
	local PawnId currentPawnId;
	local int i;
	local array<StreamInRequest> stillInProgress;

	foreach inProgressRequests(currentRequest, i)
	{
		currentState = GetFileStreamingState(currentRequest.frameworkFileName, tempLevelStreaming);
		LogInternal("update"@currentRequest.FrameworkFileName@currentState);
		if (currentRequest.desiredState == DesiredStreamingState.visible)
		{
			switch (currentState)
			{
				case FrameworkStreamState.visible:
					// good news! this is now in the desired state
					foreach currentRequest.PawnIds(currentPawnId)
					{
						_outerMenu.UpdateAsyncPawnLoadingState(currentPawnId.tag, currentPawnId.appearanceType, PawnLoadState.loaded);
					}
					inProgressRequests[i].completed = true;
					break;
				case FrameworkStreamState.BecomingVisible:
				case FrameworkStreamState.loading:
					// keep waiting
					break;
				case FrameworkStreamState.Loaded:
					// if it is properly loaded, now tell it to be visible. doing it this way will avoid blocking
					SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.visible);
					break;
				case FrameworkStreamState.StreamedOut:
					// tell it to load in the background
					SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.Loaded);
					break;
				case FrameworkStreamState.NotPresent:
					// tell it to load in the background
					// HardLoad(currentRequest.frameworkFileName);
					SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.Loaded);
					break;
				default:
					LogInternal("unknown streaming state"@currentState);
			}
		}
		else if (currentRequest.desiredState == DesiredStreamingState.Loaded)
		{
			switch (currentState)
			{
				case FrameworkStreamState.visible:
				case FrameworkStreamState.BecomingVisible:
					// tell it to become invisible/back to just loaded
					SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.Loaded);
					break;
				case FrameworkStreamState.loading:
					// keep waiting
					break;
				case FrameworkStreamState.Loaded:
					// This is now in the desired state!
					// TODO do I need to do anything?
					LogInternal("file"@currentRequest.frameworkFileName@"Is loaded, as desired");
					inProgressRequests[i].completed = true;
					break;
				case FrameworkStreamState.NotPresent:
				case FrameworkStreamState.StreamedOut:
					// tell it to load in the background
					SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.Loaded);
					break;
				default:
					LogInternal("unknown streaming state"@currentState);
			}
		}
		else if (currentRequest.desiredState == DesiredStreamingState.Unloaded)
		{
			SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.Unloaded);
			inProgressRequests[i].completed = true;
		}
		else
		{
			SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.NotPresent);
			inProgressRequests[i].completed = true;
		}
		if (!inProgressRequests[i].completed)
		{
			stillInProgress.AddItem(inProgressRequests[i]);
		}
	}

	// TODO now clear the completed ones
	inProgressRequests = stillInProgress;
}
// {
// 	local PendingFrameworkStreamingRequest currentRequest;
// 	local delegate<WaitCallback> currentWaitCallback;
// 	local delegate<SettledCallback> curentSettledCallback;

// 	foreach inProgressRequests(currentRequest)
// 	{
// 		currentRequest.remainingWaitTime -= fDeltaT;
// 		currentWaitCallback = currentRequest.WaitCallback;
// 		curentSettledCallback = currentRequest.SettledCallback;
// 		if (currentWaitCallback(currentRequest))
// 		{
// 			curentSettledCallback(currentRequest, true);
// 			currentRequest.remainingWaitTime = -1;
// 			// TODO remove the in progress request; hard to do while it is iterating
// 		}
// 		if (currentRequest.remainingWaitTime < 0)
// 		{
// 			curentSettledCallback(currentRequest, false);
// 		}
// 	}
// }

private final function SetLevelStreamingStatus(coerce Name packageName, DesiredStreamingState desiredState)
{
    local PlayerController PC;
	local bool bShouldBeloaded;
	local bool bShouldBeVisible;
    
	switch (desiredState)
	{
		case DesiredStreamingState.NotPresent:
			HardUnload(packageName);
			return;
		case DesiredStreamingState.Unloaded:
			bShouldBeLoaded = false;
			bShouldBeVisible = false;
			break;
		case DesiredStreamingState.Loaded:
			bShouldBeLoaded = true;
			bShouldBeVisible = false;
			break;
		case DesiredStreamingState.visible:
			bShouldBeLoaded = true;
			bShouldBeVisible = true;
			break;
		default:
			// this should never happen???
			LogInternal("unknown desired streaming state"@desiredState);
			break;
	}
	LogInternal("SetLevelStreamingStatus"@packageName@desiredState@bShouldBeLoaded@bShouldBeVisible);
	// actually make the internal request
    foreach _outerMenu.oWorldInfo.AllControllers(Class'PlayerController', PC)
    {
		LogInternal("Calling internal set status on"@PathName(PC));
        PC.ClientUpdateLevelStreamingStatus(packageName, bShouldBeLoaded, bShouldBeVisible, false);
    }
}
private final function HardUnload(coerce string fileName)
{
    local int i;
    local LevelStreaming tempLevelStreaming;
    
    for (i = 0; i < _outerMenu.oWorldInfo.StreamingLevels.Length; i++)
    {
        tempLevelStreaming = _outerMenu.oWorldInfo.StreamingLevels[i];
        // if (tempLevelStreaming.OwningWorldName == 'None')
        // {
        //     LogInternal("note: LSK" @ tempLevelStreaming.packageName @ "has owning level None", );
        // }
        if (string(tempLevelStreaming.packageName) ~= fileName)
        {
            // LogInternal("normal unloading before hard unloading", );
            SetLevelStreamingStatus(tempLevelStreaming.packageName, DesiredStreamingState.Unloaded);
			// LogInternal("removing from StreamingLevels list", );
			_outerMenu.oWorldInfo.StreamingLevels.Remove(i, 1);
            return;
        }
    }
    // LogInternal("no levelStreaming found to hard stream out", );
}
// private function HardLoad(coerce name fileName)
// {
//     local LevelStreamingKismet tempLevelStreaming;

// 	tempLevelStreaming = new (_outerMenu.oWorldInfo.Outer.Outer) class'LevelStreamingKismet';
    
//     tempLevelStreaming.packageName = fileName;
//     _outerMenu.oWorldInfo.StreamingLevels.AddItem(tempLevelStreaming);
// }
// public function SetupUIWorldPawn(string pawnKey, string appearanceType)
// {
    // local BioWorldInfo oBWI;
    // local AMM_Pawn_Parameters params;
    
    // if (pawnKey ~= "None" && GetCurrentDisplayPawn() != None)
    // {
    //     LogInternal("destroying UI world pawn", );
    //     oBWI = BioWorldInfo(_outerMenu.oWorldInfo);
    //     oBWI.m_UIWorld.DestroyPawn(currentDisplayPawn.Pawn);
    //     currentDisplayPawn.Pawn = None;
    //     currentDisplayPawn.spawned = FALSE;
    //     currentDisplayPawn.Tag = "";
    //     currentDisplayPawn.appearanceType = "";
    //     currentDisplayPawn.streamedInName = 'None';
    // }
    // if (pawnKey == currentDisplayPawn.Tag && appearanceType == currentDisplayPawn.appearanceType)
    // {
    //     LogInternal("No need to change UI world pawn", );
    //     return;
    // }
    // if (_outerMenu.paramHandler.GetPawnParamsByTag(pawnKey, params))
    // {
    //     if (currentDisplayPawn.Pawn != None)
    //     {
    //         LogInternal("destroying pawn based on real world pawn", );
    //         oBWI = BioWorldInfo(_outerMenu.oWorldInfo);
    //         oBWI.m_UIWorld.DestroyPawn(currentDisplayPawn.Pawn);
    //     }
    //     if (GetPawn(pawnKey, params, appearanceType))
    //     {
    //         LogInternal("got a pawn; making a UI world version", );
    //         spawnUIWorldPawn();
    //         LogInternal("spawned", );
    //     }
    //     else
    //     {
    //         LogInternal("Could not get real world pawn to spawn UI world pawn based on it", );
    //     }
    // }
    // else
    // {
    //     LogInternal("Could not find params for tag" @ pawnKey, );
    // }
// }