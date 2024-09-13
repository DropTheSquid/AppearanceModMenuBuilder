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
	
	BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());

	// first, check if there is already one present
	BWI.GetGlobalEvents(Class'SeqEvent_RemoteEvent_AMM', remoteEvents);
	foreach remoteEvents(se)
	{
		re = SeqEvent_RemoteEvent_AMM(se);
		if (re != None && re.EventName == Name(EventNameToListenFor))
		{
			// no need to add a new one, there is already one present
			return;
		}
	}

	// otherwise, add a new one to the current level
	CurrentLevelName = BWI.GetPackageName();
	parentSeq = Sequence(FindObject(CurrentLevelName $ ".TheWorld.PersistentLevel.Main_Sequence", Class'Object'));
	newSeqEvent = new (parentSeq) Class'SeqEvent_RemoteEvent_AMM';
	newSeqEvent.ParentSequence = parentSeq;
	parentSeq.SequenceObjects.AddItem(newSeqEvent);
	newSeqEvent.EventName = EventNameToListenFor;
}
public static function UnregisterRemoteEvent(Name EventNameToListenFor)
{
	local BioWorldInfo BWI;
	local Name CurrentLevelName;
	local Object parentSeqObject;
	local Sequence parentSeq;
	local SeqEvent_RemoteEvent_AMM newSeqEvent;
	local array<SequenceEvent> remoteEvents;
	local SequenceEvent se;
	local SeqEvent_RemoteEvent re;
	
	BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());

	// find the SeqEvent listening for this, if present
	BWI.GetGlobalEvents(Class'SeqEvent_RemoteEvent_AMM', remoteEvents);
	foreach remoteEvents(se)
	{
		re = SeqEvent_RemoteEvent_AMM(se);
		if (re != None && re.EventName == Name(EventNameToListenFor))
		{
			// once we have found it, remove it from its parent sequence so it will no longer trigger
			re.ParentSequence.SequenceObjects.RemoveItem(re);
			// clean it up for good measure
			re.ParentSequence = None;
			re.EventName = 'None';
		}
	}
}
