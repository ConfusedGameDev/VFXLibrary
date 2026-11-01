namespace ConfusedGameDev.Vfx
{
    /// <summary>Charged Light Cannon. Light gathers at the source, then a lance of five blades fires and keeps firing.</summary>
    public sealed class ChargedBeamEffect : VfxBeamEffect
    {
        protected override int MaxParticles => ChargedBeamMeshes.MaxParticles;

        protected override int SecondaryMaximum => ChargedBeamMeshes.MaxStreams;

        protected override float SecondaryWeight => 0.016f;
    }
}
