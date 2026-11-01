namespace ConfusedGameDev.Vfx
{
    /// <summary>Gate of Astral Tracery. A segmented frame unfolds around a starlit membrane and runs until Stop(), then folds shut.</summary>
    public sealed class AstralGateEffect : VfxGroundEffect
    {
        protected override int MaxParticles => AstralGateMeshes.MaxParticles;
    }
}
