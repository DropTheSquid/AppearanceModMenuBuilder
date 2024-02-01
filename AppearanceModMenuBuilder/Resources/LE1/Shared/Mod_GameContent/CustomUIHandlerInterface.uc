Class CustomUIHandlerInterface extends BioSFHandler
    abstract
    transient;

// Variables
var transient delegate<OnCloseCallback> __OnCloseCallback__Delegate;

// Functions
public delegate function bool OnCloseCallback(BioSFHandler self);

public function SetOnCloseCallback(delegate<OnCloseCallback> fn_OnCloseDelegate)
{
    __OnCloseCallback__Delegate = fn_OnCloseDelegate;
}
public static function CustomUIHandlerInterface LaunchMenu(optional string Param);


//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}