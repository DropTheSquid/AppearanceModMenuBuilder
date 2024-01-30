using LegendaryExplorerCore.GameFilesystem;
using LegendaryExplorerCore.Kismet;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal.Classes;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;

namespace AppearanceModMenuBuilder.LE1
{
    internal class BuildUIWorldTask : IModBuilderTask
    {
        const string UIWorldFileName = "BIOG_UIWorld.pcc";
        public void RunModTask(ModBuilderContext context)
        {
            // I am getting the vanilla version of BIOG_UIWorld and copying it into my mod, then programatically modifying it
            if (!PackageHelpers.TryGetHighestMountedOfficialFile(UIWorldFileName, context.Game, out var packagePath))
            if (packagePath == null)
            {
                throw new Exception($"Could not find basegame file {UIWorldFileName}");
            }
            // this is how I would get the Mello version if installed
            //if (MELoadedFiles.TryGetHighestMountedFile(context.Game, UIWorldFileName, out string packagePath))
            //{

            //}
            var destinationPath = Path.Combine(context.CookedPCConsoleFolder, UIWorldFileName);
            File.Copy(packagePath, destinationPath);

            var pcc = MEPackageHandler.OpenMEPackage(destinationPath);

            // add the basegame class I need in
            var mergeClassTask = new AddMergeClassesToFile("SFXGame.pcc", "AMM_AppearanceUpdater_Base", _ => pcc);
            mergeClassTask.RunModTask(context);

            // add the new class I need
            var AddClassTask = new AddClassesToFile(_ => pcc, LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\ModSeqAct_UpdatePawnAppearance.uc", ["Mod_GameContent"]));
            AddClassTask.RunModTask(context);

            var mainSeq = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence");

            // add a sequence action to update whenever the character record changes is set up/changes characters
            AddPawnAppearanceUpdateSeqAct(
                pcc, 
                mainSeq,
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_16"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_5"));

            // same for inventory
            AddPawnAppearanceUpdateSeqAct(
                pcc,
                mainSeq,
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_12"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_0"));

            // and Character Creation, which has several different pawns for no good reason
            AddPawnAppearanceUpdateSeqAct(
                pcc,
                mainSeq,
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_22"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_8"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_31"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_33"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_30"));

            pcc.Save();
        }

        private static ExportEntry AddPawnAppearanceUpdateSeqAct(IMEPackage pcc, ExportEntry parentSequence, ExportEntry triggeringRE, params ExportEntry[] targets)
        {
            // create a new SequenceObject, add it to the parent sequence
            var newSeqAct = SequenceObjectCreator.CreateSequenceObject(pcc, "ModSeqAct_UpdatePawnAppearance");
            KismetHelper.AddObjectToSequence(newSeqAct, parentSequence);
            // link a remote event to trigger this
            KismetHelper.CreateOutputLink(triggeringRE, "Out", newSeqAct);
            // link it to one or more targets
            foreach (var target in targets)
            {
                KismetHelper.CreateVariableLink(newSeqAct, "Target", target);
            }

            return newSeqAct;
        }
    }
}
