namespace ConfusedGameDev.Vfx
{
    /// <summary>Leaf-Swept Vortex. Toon wind sheets wind upward while leaves cross the middle and ground dust is drawn in.</summary>
    public sealed class WindVortexEffect : VfxVortexEffect
    {
        protected override int MaxParticles => WindVortexMeshes.MaxParticles;
    }
}
