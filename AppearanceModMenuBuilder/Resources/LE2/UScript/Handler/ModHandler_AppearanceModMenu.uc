Class ModHandler_AppearanceModMenu extends ModHandler_ModMenuBase
    config(UI);

var transient GFxMovieInfo movieInfo;

public function OnPanelAdded()
{
    Super.OnPanelAdded();
    // just hold onto this for as long as the handler is alive, it prevents textures from being garbage collected
    movieInfo = GFXMovieInfo(FindObject("ModMenu.ModMenu", class'GFxMovieInfo'));
}

public function ExASLoaded()
{
    Super.ExASLoaded();
    LogInternal("AS loaded");
    ASSetTitle("test title");
    ASSetSubtitle("test subtitle");

    // set the initial list size to 10
    ASInitializeList(10, 0, 0);
    // int index, string leftText, string centerText, string rightText, string secondaryText, bool showPlus, bool disabled
    ASupdateMenuEntry(0, "left text", "", "", "", false, false);
    ASupdateMenuEntry(1, "", "center text", "", "", false, false);
    ASupdateMenuEntry(2, "", "", "right text", "", false, false);
    ASupdateMenuEntry(3, "", "", "", "secondary", false, false);
    ASupdateMenuEntry(4, "disabled", "", "", "", true, false);
    ASupdateMenuEntry(5, "nested", "", "", "", false, true);
    ASupdateMenuEntry(6, "nested disabled", "", "", "", true, true);
    ASupdateMenuEntry(7, "left", "", "right", "test", false, false);
    ASupdateMenuEntry(8, "", "center", "", "test1", false, false);
    // purposely leaving off 9 for testing what happens

    // ASSetSelectedIndex(0, true);
    // ASSetScrollPosition(1, true);

    // set up the buttons
    ASSetActionButtonActive(true);
    ASSetActionButtonText("5000");
    ASSetAuxButtonActive(true);
    ASSetAuxButtonText("1000");
    ASSetAux2ButtonActive(true);
    ASSetAux2ButtonText("50");
    ASSetBackButtonActive(true);
    ASSetBackButtonText("10");
    ASSetDescription(generateLines(5000));
    ASSetRightTitle("5000");
}

private function string generateLines(int lineCount)
{
    local int i;
    local string result;

    result = "";
    for (i = 0; i < lineCount; i++)
    {
        result $= i;
        if (i != lineCount - 1)
        {
            result $= "\n";
        }
    }
    return result;
}

public function ExActionPressed(int index)
{
    LogInternal("action pressed"@index);
    // ASSetActionButtonActive(false);
    ASSetDescription(generateLines(5000));
    ASSetRightTitle("5000");
}

public function ExBackPressed()
{
    LogInternal("back pressed");
    // ASSetBackButtonActive(false);
    ASSetDescription(generateLines(10));
    ASSetRightTitle("10");
}

public function ExAuxPressed(int index)
{
    LogInternal("Aux pressed");
    // ASSetAuxButtonActive(false);
    ASSetDescription(generateLines(1000));
    ASSetRightTitle("1000");
}

public function ExAux2Pressed(int index)
{
    LogInternal("Aux 2 pressed");
    // ASSetAux2ButtonActive(false);
    ASSetDescription(generateLines(50));
    ASSetRightTitle("50");
}