namespace ConfusedGameDev.Vfx
{
    /// <summary>Flame-Swept Vortex. Orange flame sheets wind upward and light the dust beneath them.</summary>
    public sealed class FireVortexEffect : VfxVortexEffect
    {
        protected override int MaxParticles => FireVortexMeshes.MaxParticles;
    }
}
