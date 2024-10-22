Class ModSeqEvent_RemoteEvent_AMM extends ModSeqEvent_RemoteEvent_Dynamic;

public function OnActivatedDefault(name eventName, Array<Object> params1, Array<string> params2)
{
	local BioSFPanel panel;

	Super(SequenceOp).Activated();
	if (class'AMM_AppearanceUpdater'.static.IsInAMM(panel))
	{
		ModHandler_AMM(panel.GetDefaultHandler()).OnRemoteEvent(EventName);
	}
}
