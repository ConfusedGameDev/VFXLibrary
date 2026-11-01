namespace ConfusedGameDev.Vfx
{
    /// <summary>Flame-Etched Ground. A five-bladed sigil over glowing cracks, with tongues of flame licking up and dying away.</summary>
    public sealed class BurningGroundEffect : VfxGroundEffect
    {
        protected override int MaxParticles => BurningGroundMeshes.MaxParticles;
    }
}
