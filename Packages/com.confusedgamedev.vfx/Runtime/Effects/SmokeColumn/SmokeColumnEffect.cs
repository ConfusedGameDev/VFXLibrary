namespace ConfusedGameDev.Vfx
{
    /// <summary>Billowing Smoke Column. Puffs rise, spread and thin out as they climb.</summary>
    public sealed class SmokeColumnEffect : VfxGroundEffect
    {
        protected override int MaxParticles => SmokeColumnMeshes.MaxParticles;
    }
}
