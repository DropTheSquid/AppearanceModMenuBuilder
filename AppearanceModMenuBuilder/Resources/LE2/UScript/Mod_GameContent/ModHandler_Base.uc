class ModHandler_base extends BioSFHandler;

var delegate<ExternalCallback_OnComplete> __ExternalCallback_OnComplete__Delegate;

public function ClearDelegates()
{
    __ExternalCallback_OnComplete__Delegate = None;
}
public function SetExternalCallback_OnComplete(delegate<ExternalCallback_OnComplete> pDelegate)
{
    __ExternalCallback_OnComplete__Delegate = pDelegate;
}
public delegate function ExternalCallback_OnComplete();