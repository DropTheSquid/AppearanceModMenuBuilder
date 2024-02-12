using LegendaryExplorerCore.Kismet;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    internal class BuildUIWorldTask : IModBuilderTask
    {
        const string UIWorldFileName = "BIOG_UIWorld.pcc";
        public void RunModTask(ModBuilderContext context)
        {
            // I am getting the vanilla version of BIOG_UIWorld and copying it into my mod, then programatically modifying it
            if (!PackageHelpers.TryGetHighestMountedOfficialFile(UIWorldFileName, context.Game, out var packagePath) || packagePath == null)
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

            // another trigger for the ForceTexture remote event, to update after new armor etc is equipped
            AddPawnAppearanceUpdateSeqAct(
                pcc,
                mainSeq,
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_19"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_0"));

            // and Character Creation, which has several different pawns for no good reason
            var charCreateSeqAct = AddPawnAppearanceUpdateSeqAct(
                pcc,
                mainSeq,
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_22"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_8"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_31"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_33"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_30"));

            // new remote event to trigger appearance update for character creation on demand
            var CharCreateRE = SequenceObjectCreator.CreateSequenceObject(pcc, "SeqEvent_RemoteEvent");
            KismetHelper.AddObjectToSequence(CharCreateRE, mainSeq);
            KismetHelper.CreateOutputLink(CharCreateRE, "Out", charCreateSeqAct);

            KismetHelper.SetComment(CharCreateRE, "Triggered from code; updates the character create pawn(s)");
            CharCreateRE.WriteProperty(new NameProperty("re_amm_update_cc", "EventName"));

            // new remote event to trigger the camera position update for inventory setup
            var cameraInterp = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqAct_Interp_2") 
                ?? throw new Exception("Could not find camera interp in UI world to hook up to");
            var cameraUpdateRE = SequenceObjectCreator.CreateSequenceObject(pcc, "SeqEvent_RemoteEvent");
            KismetHelper.AddObjectToSequence(cameraUpdateRE, mainSeq);
            KismetHelper.SetComment(cameraUpdateRE, "Triggered from code; updates the camera position");
            cameraUpdateRE.WriteProperty(new NameProperty("re_AMM_UpdateCameraPosition", "EventName"));
            KismetHelper.CreateOutputLink(cameraUpdateRE, "Out", cameraInterp, 0);

            // hide the ugly black rectangle under the pawn's feet
            var pedestalStaticMesh = pcc.FindExport("TheWorld.PersistentLevel.InterpActor_2.StaticMeshComponent_3")
                ?? throw new Exception("Could not find pedestal static mesh in UI world to hide");
            pedestalStaticMesh.WriteProperty(new BoolProperty(true, "HiddenGame"));

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
