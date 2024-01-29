public function PostBeginPlay()
{
    Super.PostBeginPlay();
    m_oBehavior.PostBeginPlay();
    SetBaseEyeheight();
    CylinderComponent.SetTraceBlocking(default.CylinderComponent.BlockZeroExtent, default.CylinderComponent.BlockNonZeroExtent);
    m_oCustomCollision.SetTraceBlocking(default.m_oCustomCollision.BlockZeroExtent, default.m_oCustomCollision.BlockNonZeroExtent);
    Mesh.SetTraceBlocking(default.Mesh.BlockZeroExtent, default.Mesh.BlockNonZeroExtent);
    Mesh.SetActorCollision(default.Mesh.CollideActors, default.Mesh.BlockActors, default.Mesh.AlwaysCheckCollision);
	// added in;
	// this covers most pawns that just exist in levels, as well as most enemy spawns.
	// It does not cover squadmates or Shepard, as their appearance gets updated later and it overwrites this
	// there are also a bunch of other places it will not cover
	Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(self, "BioPawn.PostBeginPlay");
}