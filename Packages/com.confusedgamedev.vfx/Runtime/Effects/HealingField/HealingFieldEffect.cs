namespace ConfusedGameDev.Vfx
{
    /// <summary>Healing Sigil. A flowering sigil glows in spreading rings while small crosses drift up from it.</summary>
    public sealed class HealingFieldEffect : VfxGroundEffect
    {
        protected override int MaxParticles => HealingFieldMeshes.MaxParticles;
    }
}
