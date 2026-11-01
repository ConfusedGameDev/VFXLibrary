namespace ConfusedGameDev.Vfx
{
    /// <summary>Floating Rune Matrix. Crystals with small rings bob over a lattice and take quarter turns together.</summary>
    public sealed class ArcaneMatrixEffect : VfxGroundEffect
    {
        protected override int MaxParticles => ArcaneMatrixMeshes.MaxParticles;
    }
}
