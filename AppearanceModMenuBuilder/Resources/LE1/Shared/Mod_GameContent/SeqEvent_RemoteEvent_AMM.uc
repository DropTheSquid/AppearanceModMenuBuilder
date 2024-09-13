Class SeqEvent_RemoteEvent_AMM extends SeqEvent_RemoteEvent;

public event function Activated()
{
	local BioSFPanel panel;

	Super(SequenceOp).Activated();
	if (class'AMM_AppearanceUpdater'.static.IsInAMM(panel))
	{
		ModHandler_AMM(panel.GetDefaultHandler()).OnRemoteEvent(EventName);
	}
}
public static function RegisterRemoteEvent(Name EventNameToListenFor)
{
	local BioWorldInfo BWI;
	local Name CurrentLevelName;
	local Sequence parentSeq;
	local SeqEvent_RemoteEvent_AMM newSeqEvent;
	local array<SequenceEvent> remoteEvents;
	local SequenceEvent se;
	local SeqEvent_RemoteEvent re;
	local SeqEvent_RemoteEvent_AMM recyclableEvent;
	
	BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());

	// LogInternal("registering event"@EventNameToListenFor);
	// first, check if there is already one present (and grab an empty one if it's available)
	BWI.GetGlobalEvents(Class'SeqEvent_RemoteEvent_AMM', remoteEvents);
	foreach remoteEvents(se)
	{
		re = SeqEvent_RemoteEvent_AMM(se);
		if (re != None)
		{
			if (re.EventName == Name(EventNameToListenFor))
			{
				// no need to add a new one, there is already one present
				return;
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
	}
	else
	{
		// otherwise, add a new one to the current level
		CurrentLevelName = BWI.GetPackageName();
		parentSeq = Sequence(FindObject(CurrentLevelName $ ".TheWorld.PersistentLevel.Main_Sequence", Class'Object'));
		newSeqEvent = new (parentSeq) Class'SeqEvent_RemoteEvent_AMM';
		newSeqEvent.ParentSequence = parentSeq;
		parentSeq.SequenceObjects.AddItem(newSeqEvent);
		newSeqEvent.EventName = EventNameToListenFor;
		// LogInternal("adding new event listener"@newSeqEvent);
	}
}
public static function UnregisterRemoteEvent(Name EventNameToListenFor)
{
	local BioWorldInfo BWI;
	local Sequence parentSeq;
	local array<SequenceEvent> remoteEvents;
	local SequenceEvent se;
	local SeqEvent_RemoteEvent re;
	local int i;
	
	BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());

	// LogInternal("unregistering event"@EventNameToListenFor);
	
	// find the SeqEvent listening for this, if present
	BWI.GetGlobalEvents(Class'SeqEvent_RemoteEvent_AMM', remoteEvents);
	foreach remoteEvents(se)
	{
		re = SeqEvent_RemoteEvent_AMM(se);
		if (re != None && re.EventName == Name(EventNameToListenFor))
		{
			// the game likes to crash if you actually remove it, so instead, just clear the event name so it will not trigger
			re.EventName = 'None';
			break;
		}
	}
}
