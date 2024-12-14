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
    SetTitle("test title");
    SetSubtitle("test subtitle");

    // set the initial list size to 10
    InitializeList(10);
    // int index, string leftText, string centerText, string rightText, string secondaryText, bool showPlus, bool disabled
    updateMenuEntry(0, "left text", "", "", "", false, false);
    updateMenuEntry(1, "", "center text", "", "", false, false);
    updateMenuEntry(2, "", "", "right text", "", false, false);
    updateMenuEntry(3, "", "", "", "secondary", false, false);
    updateMenuEntry(4, "disabled", "", "", "", true, false);
    updateMenuEntry(5, "nested", "", "", "", false, true);
    updateMenuEntry(6, "nested disabled", "", "", "", true, true);
    updateMenuEntry(7, "left", "", "right", "test", false, false);
    updateMenuEntry(8, "", "center", "", "test1", false, false);
    // purposely leaving off 9 for testing what happens

    SetSelectedIndex(0);
    SetScrollPosition(1, true);

    // set up the buttons
    SetActionButtonActive(true);
    SetActionButtonText("action");
    SetAuxButtonActive(true);
    SetAuxButtonText("aux");
    SetAux2ButtonActive(true);
    SetAux2ButtonText("aux2");
    SetBackButtonActive(true);
    SetBackButtonText("back");
    SetDescription("test description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\ntest description\n");
    SetRightTitle("test right title");
}

public function ExActionPressed(int index)
{
    LogInternal("action pressed"@index);
    SetActionButtonActive(false);
}

public function ExBackPressed()
{
    LogInternal("back pressed");
    SetBackButtonActive(false);
}

public function ExAuxPressed(int index)
{
    LogInternal("Aux pressed");
    SetAuxButtonActive(false);
}

public function ExAux2Pressed(int index)
{
    LogInternal("Aux 2 pressed");
    SetAux2ButtonActive(false);
}