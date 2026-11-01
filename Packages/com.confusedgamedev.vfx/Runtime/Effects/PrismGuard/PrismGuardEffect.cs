namespace ConfusedGameDev.Vfx
{
    /// <summary>Prismatic Crystal Bulwark. Hexagonal plates fold out into a curved wall and run until Stop(), then retract one by one.</summary>
    public sealed class PrismGuardEffect : VfxGroundEffect
    {
        protected override int MaxParticles => PrismGuardMeshes.MaxParticles;
    }
}
