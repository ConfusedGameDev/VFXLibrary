namespace ConfusedGameDev.Vfx
{
    /// <summary>Sixfold Frost Sigil. A snowflake sigil lights up outward while ice flecks glint just above it.</summary>
    public sealed class FrostFieldEffect : VfxGroundEffect
    {
        protected override int MaxParticles => FrostFieldMeshes.MaxParticles;
    }
}
