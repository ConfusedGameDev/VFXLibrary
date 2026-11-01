namespace ConfusedGameDev.Vfx
{
    /// <summary>Ground-Hugging Mist. Thin mist spreads along the ground.</summary>
    public sealed class GroundFogEffect : VfxGroundEffect
    {
        protected override int MaxParticles => GroundFogMeshes.MaxParticles;
    }
}
