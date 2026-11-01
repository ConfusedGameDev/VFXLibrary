namespace ConfusedGameDev.Vfx
{
    /// <summary>Sand-Gathering Sigil. Dunes rise in turn inside a triangular seal and slide inward, with fine sand streaming after them.</summary>
    public sealed class QuicksandSealEffect : VfxGroundEffect
    {
        protected override int MaxParticles => QuicksandSealMeshes.MaxParticles;
    }
}
