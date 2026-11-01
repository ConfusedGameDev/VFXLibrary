namespace ConfusedGameDev.Vfx
{
    /// <summary>Threadwoven Beam. A thin ray with filaments winding around it, and sparks where it lands.</summary>
    public sealed class ContinuousBeamEffect : VfxBeamEffect
    {
        protected override int MaxParticles => ContinuousBeamMeshes.MaxParticles;
    }
}
