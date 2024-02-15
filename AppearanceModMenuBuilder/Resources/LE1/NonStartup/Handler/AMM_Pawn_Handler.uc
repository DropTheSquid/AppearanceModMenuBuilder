Class AMM_Pawn_Handler extends AMM_Handler_Helper;

// should I separately keep track of pawns and files? Seems like coupling those is actually making it messy.
// I need a list of pawns so I can quickly retrive a pawn I have already otherwise fetched
// I need to know which of those pawns need to be destroyed (because they were spawned in specifically)
// I need to know what state to put those back into

// so, list of pawns with a bool for destroy plus tag and appearance type for quick lookup. The RealWorldPawnRecord

// separately, I need a list of framework filenames and their original state, purely so that I can restore it at the end

// I could hypothetically load multiple files in the background at once. I would like to keep that possibility open. 
// it would feel more snappy if I could preload. 




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

// when we ask to put a file in a specific state. These are the states it can settle in
enum DesiredStreamingState
{
	// it is not present in the levelStreaming list
	NotPresent,
	// it is present, but not currently loaded (think future/other parts of the level)
	Unloaded,
	// it is loaded, but not visible. think immediate next part of the level
	Loaded,
	// it is fully visible and can be used
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

var transient array<StreamInRequest> streamingRequests;

var transient array<RealWorldPawnRecord> pawnRecords;
var transient BioPawn _currentDisplayedPawn;

private function log(string message)
{
	// I can comment this next line out to turn off logging
	LogInternal(message);
}
public function Cleanup()
{
	local RealWorldPawnRecord currentRecord;
	local StreamInRequest currentStreamRequest;

	LogInternal("Doing a cleanup"@pawnRecords.Length@streamingRequests.Length);
	if (_currentDisplayedPawn != None)
	{
		BioWorldInfo(_outerMenu.oWorldInfo).m_UIWorld.DestroyPawn(_currentDisplayedPawn);
	}
	// TODO clean up any pawns that need to be destroyed
	foreach pawnRecords(currentRecord)
	{
		if (currentRecord.shouldBeDestroyed)
		{
			LogInternal("Destroying pawn"@PathName(currentRecord.pawn));
			currentRecord.pawn.Destroy();
		}
	}
	pawnRecords.Length = 0;
	foreach streamingRequests(currentStreamRequest)
	{
		switch (currentStreamRequest.originalState)
		{
			case FrameworkStreamState.NotPresent:
				LogInternal("hard streaming out"@currentStreamRequest.frameworkFileName);
				SetLevelStreamingStatus(currentStreamRequest.frameworkFileName, DesiredStreamingState.NotPresent);
				break;
			case FrameworkStreamState.Loaded:
			case FrameworkStreamState.loading:
				LogInternal("unloading out"@currentStreamRequest.frameworkFileName);
				SetLevelStreamingStatus(currentStreamRequest.frameworkFileName, DesiredStreamingState.Loaded);
				break;
			case FrameworkStreamState.StreamedOut:
				LogInternal("soft streaming out"@currentStreamRequest.frameworkFileName);
				SetLevelStreamingStatus(currentStreamRequest.frameworkFileName, DesiredStreamingState.Unloaded);
				break;
		}
	}
	streamingRequests.Length = 0;
}

// load (but do not yet display) a pawn. It will either do it synchronously or asynchronously
public function PawnLoadState LoadPawn(string tag, string appearanceType)
{
	local RealWorldPawnRecord currentRecord;
	local AMM_Pawn_Parameters params;
	local BioPawn pawn;
	local string frameworkFileName;

	// first look to see if we already have a suitable pawn
	foreach pawnRecords(currentRecord)
	{
		LogInternal("checking if pawn is already loaded"@currentRecord.tag@currentRecord.appearanceType);
		if (currentRecord.tag == tag && currentRecord.appearanceType == appearanceType)
		{
			LogInternal("already loaded"@currentRecord.tag@currentRecord.appearanceType);
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

			return PawnLoadState.Loaded;
		}
		// next try streaming the pawn in
		if (params.GetFrameworkFileForAppearanceType(appearanceType, frameworkFileName))
		{
			if (LoadFrameworkFile(tag, appearanceType, FrameworkFileName))
			{
				return PawnLoadState.loaded;
			}
			return PawnLoadState.loading;
		}
		
		LogInternal("found params but couldn't find pawn for tag"@tag);
		return PawnLoadState.failed;
	}
	// could not find any params for this tag; that's not great.
	LogInternal("Could not find params for tag"@tag);
	return PawnLoadState.failed;
}

// display an already loaded pawn
public function bool DisplayPawn(string tag, string appearanceType)
{
	local RealWorldPawnRecord currentRecord;
	local BioWorldInfo oBWI;
	local BioPawn newDisplayPawn;

	foreach pawnRecords(currentRecord)
	{
		if (currentRecord.tag == tag && currentRecord.appearanceType == appearanceType)
		{
			newDisplayPawn = currentRecord.pawn;
			break;
		}
	}
	oBWI = BioWorldInfo(_outerMenu.oWorldInfo);
	if (newDisplayPawn == _currentDisplayedPawn)
	{
		// nothing to do
		return true;
	}
	if (newDisplayPawn != _currentDisplayedPawn)
	{
		if (_currentDisplayedPawn != None)
		{
			oBWI.m_UIWorld.DestroyPawn(_currentDisplayedPawn);
		}
		_currentDisplayedPawn = newDisplayPawn;
		oBWI.m_UIWorld.TriggerEvent('SetupInventory', _outerMenu.oWorldInfo);
		oBWI.m_UIWorld.spawnPawn(_currentDisplayedPawn, 'InventorySpawnPoint', 'InventoryPawn');
		return true;
	}
	return false;
}

// returns true if it is already loaded, false if it is happening asynchronously
private function bool LoadFrameworkFile(string tag, string appearanceType, string fileName)
{
	local StreamInRequest request;
	local int i;

	LogInternal("LoadFrameworkFile"@tag@appearanceType@Filename);
	// first, check if we already have a pending or in progress request for this
	if (GetAsyncRequest(streamingRequests, fileName, request, i))
	{
		// there is already a request in progress. See if it already has the requested tag and appearance type
		log("There is an in progress/finished request for framework file"@fileName);
		// TODO support more than one
		return request.completed;
	}
	log("Creating new streamInRequest for"@tag@appearanceType@fileName);
	// TODO check for a queued one and move it into inProgress once that is supported
	request.frameworkFileName = fileName;
	request.pawnIds.Length = 1;
	request.pawnIds[0].tag = tag;
	request.pawnIds[0].appearanceType = appearanceType;
	request.originalState = GetFileStreamingState(fileName);
	request.desiredState = DesiredStreamingState.visible;
	request.completed = false;
	streamingRequests.AddItem(request);
	return false;
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

public function update(float fDeltaT)
{
	local StreamInRequest currentRequest;
	local FrameworkStreamState currentState;
	local LevelStreaming tempLevelStreaming;
	local PawnId currentPawnId;
	local int i;
	local BioPawn pawn;
	local RealWorldPawnRecord newRecord;

	foreach streamingRequests(currentRequest, i)
	{
		if (currentRequest.completed)
		{
			continue;
		}
		currentState = GetFileStreamingState(currentRequest.frameworkFileName, tempLevelStreaming);
		if (currentRequest.desiredState == DesiredStreamingState.visible)
		{
			switch (currentState)
			{
				case FrameworkStreamState.visible:
					// good news! this is now in the desired state
					foreach currentRequest.PawnIds(currentPawnId)
					{
						if (FindStreamedInPawn(currentPawnId.tag, currentRequest.FrameworkFileName, pawn))
						{
							LogInternal("Adding a new pawn to the thing"@currentPawnId.tag@currentPawnId.appearanceType@currentRequest.FrameworkFileName);
							newRecord.Tag = currentPawnId.tag;
							newRecord.appearanceType = currentPawnId.appearanceType;
							newRecord.Pawn = pawn;
							// don't destroy pawns that are streamed in
							newRecord.shouldBeDestroyed = false;
							pawnRecords.AddItem(newRecord);
							_outerMenu.UpdateAsyncPawnLoadingState(currentPawnId.tag, currentPawnId.appearanceType, PawnLoadState.loaded);
							streamingRequests[i].completed = true;
						}
					}
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
					streamingRequests[i].completed = true;
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
			streamingRequests[i].completed = true;
		}
		else
		{
			SetLevelStreamingStatus(currentRequest.frameworkFileName, DesiredStreamingState.NotPresent);
			streamingRequests[i].completed = true;
		}
	}
}

private function bool FindStreamedInPawn(string tag, string fileName, out BioPawn foundPawn)
{
    local Actor tempActor;
	local AMM_Pawn_Parameters params;

	if (_outerMenu.paramHandler.GetPawnParamsByTag(tag, params))
	{
		foreach BioWorldInfo(_outerMenu.oWorldInfo).AllActors(Class'Actor', tempActor, )
		{
			if (BioPawn(tempActor) != None && string(tempActor.GetPackageName()) ~= fileName && params.matchesPawn(BioPawn(tempActor)))
			{
				foundPawn = BioPawn(tempActor);
				return TRUE;
			}
		}
	}
    return FALSE;
}

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
	// LogInternal("SetLevelStreamingStatus"@packageName@desiredState@bShouldBeLoaded@bShouldBeVisible);
	// actually make the internal request	
    foreach _outerMenu.oWorldInfo.AllControllers(Class'PlayerController', PC)
    {
		// LogInternal("Calling internal set status on"@PathName(PC));
        PC.ClientUpdateLevelStreamingStatus(packageName, bShouldBeLoaded, bShouldBeVisible, false);
    }
}
private function HardUnload(coerce string fileName)
{
    local int i;
    local LevelStreaming tempLevelStreaming;
    
    for (i = 0; i < _outerMenu.oWorldInfo.StreamingLevels.Length; i++)
    {
        tempLevelStreaming = _outerMenu.oWorldInfo.StreamingLevels[i];
        if (string(tempLevelStreaming.packageName) ~= fileName)
        {
            SetLevelStreamingStatus(tempLevelStreaming.packageName, DesiredStreamingState.Unloaded);
			_outerMenu.oWorldInfo.StreamingLevels.Remove(i, 1);
            return;
        }
    }
}