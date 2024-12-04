using AppearanceModMenuBuilder.LE1;
using AppearanceModMenuBuilder.LE2;

string game = args.Length > 0 ? args[0] : "";
string mode = args.Length > 1 ? args[1] : "";

switch (game)
{
    case "LE1":
        LE1Build.RunBuild(mode);
        break;
    case "LE2":
        LE2Build.RunBuild(mode);
        break;
    case "LE3":
    case "ME1":
    case "OT1":
    case "ME2":
    case "OT2":
    case "ME3":
    case "OT3":
        // TODO add more supported targets
        throw new Exception($"unsupported game target {game}");
    case "":
        throw new Exception("You must specify the game target in the first command line arg");
    default:
        throw new Exception($"unknown game target {game}");
}
