namespace ConfusedGameDev.Vfx
{
    /// <summary>Thornvine Blossom Crown. Thorned vines climb from a leaf sigil and open around a seven-petalled blossom.</summary>
    public sealed class ThornCrownEffect : VfxGroundEffect
    {
        protected override int MaxParticles => ThornCrownMeshes.MaxParticles;
    }
}
