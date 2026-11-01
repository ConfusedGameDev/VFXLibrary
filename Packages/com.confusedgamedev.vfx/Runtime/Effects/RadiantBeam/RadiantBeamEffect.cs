namespace ConfusedGameDev.Vfx
{
    /// <summary>Solar Halo Beam. A bright shaft joins two petal seals, which open and turn slowly at each end.</summary>
    public sealed class RadiantBeamEffect : VfxBeamEffect
    {
        protected override int MaxParticles => RadiantBeamMeshes.MaxParticles;
    }
}
