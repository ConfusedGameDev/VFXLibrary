namespace ConfusedGameDev.Vfx
{
    /// <summary>Runic Ring Vortex. Glowing bands wind upward while rune motes ride rings up the open middle.</summary>
    public sealed class EnergyVortexEffect : VfxVortexEffect
    {
        protected override int MaxParticles => EnergyVortexMeshes.MaxParticles;
    }
}
