public function PostBeginPlay()
{
    Super.PostBeginPlay();
    m_oBehavior.PostBeginPlay();
    SetBaseEyeheight();
    CylinderComponent.SetTraceBlocking(default.CylinderComponent.BlockZeroExtent, default.CylinderComponent.BlockNonZeroExtent);
    m_oCustomCollision.SetTraceBlocking(default.m_oCustomCollision.BlockZeroExtent, default.m_oCustomCollision.BlockNonZeroExtent);
    Mesh.SetTraceBlocking(default.Mesh.BlockZeroExtent, default.Mesh.BlockNonZeroExtent);
    Mesh.SetActorCollision(default.Mesh.CollideActors, default.Mesh.BlockActors, default.Mesh.AlwaysCheckCollision);
	// added in
	Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(self, "BioPawn.PostBeginPlay");
}