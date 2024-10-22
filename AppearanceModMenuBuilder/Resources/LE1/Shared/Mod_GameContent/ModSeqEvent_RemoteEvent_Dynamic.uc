Class ModSeqEvent_RemoteEvent_Dynamic extends SeqEvent_RemoteEvent;

var transient delegate<OnActivateCallback> __OnActivateCallback__Delegate;

var transient Array<QueuedActivationParams> queuedActivations;

struct QueuedActivationParams
{
    var Array<Object> objectParams;
    var Array<string> stringParams;
};

// Functions
public delegate function bool OnActivateCallback(name eventName, optional Array<Object> params1, optional Array<string> params2);

private function SetOnActivateCallback(delegate<OnActivateCallback> fn_OnActivateDelegate)
{
    __OnActivateCallback__Delegate = fn_OnActivateDelegate;
}

// don't override this function
public event function Activated()
{
    local QueuedActivationParams params;
	local bool handled;

    params = QueuedActivations[0];
    QueuedActivations.Remove(0, 1);

	Super(SequenceOp).Activated();
	// TODO get params if invoked by sequence?
	// or make a new class that invokes these properly if needed
	if (__OnActivateCallback__Delegate != None)
	{
		handled = __OnActivateCallback__Delegate(EventName, params.objectParams, params.stringParams);
	}
	if (!handled)
	{
		OnActivatedDefault(EventName, params.objectParams, params.stringParams);
	}
}

public function QueueActivation(actor Originator, Array<Object> params1, Array<string> params2)
{
    local QueuedActivationParams params;

    params.objectParams = params1;
    params.stringParams = params2;
    if (CheckActivate(Originator, Originator, true))
    {
        QueuedActivations.AddItem(params);
        CheckActivate(Originator, Originator);
    }
}

// do override this function if you want handling in your class without needing to set a classback
public function OnActivatedDefault(name eventName, Array<Object> params1, Array<string> params2);

// this lets you call all handlers of this event. you can optionally tell it to invoke non dymanic event handlers without params. You can pass arbitrary params
public static function InvokeDynamicEvent(Name EventNameToInvoke, optional bool invokeGenericEvents = false, optional Array<Object> params1, optional Array<string> params2)
{
	local BioWorldInfo BWI;
    local array<SequenceEvent> seqEvents;
    local SequenceEvent se;
    local ModSeqEvent_RemoteEvent_Dynamic dynamicEvent;
    local SeqEvent_RemoteEvent re;
    local bool activated;
    
    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    BWI.GetGlobalEvents(Class'SeqEvent_RemoteEvent', seqEvents);
    foreach seqEvents(se, )
    {
        dynamicEvent = ModSeqEvent_RemoteEvent_Dynamic(se);
        if (invokeGenericEvents && dynamicEvent == None)
        {
            re = SeqEvent_RemoteEvent(se);
            if (re != None && re.EventName == Name(EventNameToInvoke))
            {
                re.CheckActivate(BWI, BWI);
            }
        }
        if (dynamicEvent != None && dynamicEvent.EventName == Name(EventNameToInvoke))
        {
            dynamicEvent.QueueActivation(BWI, params1, params2);
        }
    }
}

public static function ModSeqEvent_RemoteEvent_Dynamic RegisterRemoteEvent(Name EventNameToListenFor, optional delegate<OnActivateCallback> OnActivateDelegate, optional class<ModSeqEvent_RemoteEvent_Dynamic> classType = class'ModSeqEvent_RemoteEvent_Dynamic')
{
	local BioWorldInfo BWI;
	local Name CurrentLevelName;
	local Sequence parentSeq;
	local ModSeqEvent_RemoteEvent_Dynamic newSeqEvent;
	local array<SequenceEvent> remoteEvents;
	local SequenceEvent se;
	local ModSeqEvent_RemoteEvent_Dynamic re;
	local ModSeqEvent_RemoteEvent_Dynamic recyclableEvent;
	
	BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());

	// LogInternal("registering event"@EventNameToListenFor);
	// first, check if there is already one present (and grab an empty one if it's available)
	BWI.GetGlobalEvents(classType, remoteEvents);
	foreach remoteEvents(se)
	{
		re = ModSeqEvent_RemoteEvent_Dynamic(se);
		if (re != None && re.class == classType)
		{
			if (re.EventName == Name(EventNameToListenFor))
			{
				// no need to add a new one, there is already one present
				return re;
			}
			if (re.EventName == 'None' && recyclableEvent == None)
			{
				recyclableEvent = re;
			}
		}
	}

	if (recyclableEvent != None)
	{
		// LogInternal("recycling"@recyclableEvent);
		recyclableEvent.EventName = EventNameToListenFor;
        recyclableEvent.SetOnActivateCallback(OnActivateDelegate);
        return recyclableEvent;
	}
	else
	{
		// otherwise, add a new one to the current level
		CurrentLevelName = BWI.GetPackageName();
		parentSeq = Sequence(FindObject(CurrentLevelName $ ".TheWorld.PersistentLevel.Main_Sequence", Class'Object'));
		newSeqEvent = new (parentSeq) classType;
		newSeqEvent.ParentSequence = parentSeq;
		parentSeq.SequenceObjects.AddItem(newSeqEvent);
		newSeqEvent.EventName = EventNameToListenFor;
        newSeqEvent.SetOnActivateCallback(OnActivateDelegate);
        return newSeqEvent;
		// LogInternal("adding new event listener"@newSeqEvent);
	}
}
public static function UnregisterRemoteEvent(Name EventNameToListenFor, optional class<ModSeqEvent_RemoteEvent_Dynamic> classType = class'ModSeqEvent_RemoteEvent_Dynamic')
{
	local BioWorldInfo BWI;
	local array<SequenceEvent> remoteEvents;
	local SequenceEvent se;
	local ModSeqEvent_RemoteEvent_Dynamic re;
	
	BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());

	// LogInternal("unregistering event"@EventNameToListenFor);
	
	// find the SeqEvent listening for this, if present
	BWI.GetGlobalEvents(Class'ModSeqEvent_RemoteEvent_Dynamic', remoteEvents);
	foreach remoteEvents(se)
	{
		re = ModSeqEvent_RemoteEvent_Dynamic(se);
		if (re != None && re.class == classType && re.EventName == Name(EventNameToListenFor))
		{
			// the game likes to crash if you actually remove it, so instead, just clear the event name so it will not trigger
			re.EventName = 'None';
            re.SetOnActivateCallback(None);
			break;
		}
	}
}
