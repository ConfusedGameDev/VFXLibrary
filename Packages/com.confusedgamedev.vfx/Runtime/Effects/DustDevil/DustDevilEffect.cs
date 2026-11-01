namespace ConfusedGameDev.Vfx
{
    /// <summary>Sand-Swept Vortex. Sand billows and sheets wind up around an open middle, with grit flying beside them.</summary>
    public sealed class DustDevilEffect : VfxVortexEffect
    {
        protected override int MaxParticles => DustDevilMeshes.MaxParticles;

        protected override int FixedSlots => DustDevilMeshes.Billows;
    }
}
