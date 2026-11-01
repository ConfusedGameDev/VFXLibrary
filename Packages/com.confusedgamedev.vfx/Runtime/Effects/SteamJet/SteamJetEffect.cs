namespace ConfusedGameDev.Vfx
{
    /// <summary>Rising Steam Jet. A narrow jet shoots upward and breaks into mist at the top.</summary>
    public sealed class SteamJetEffect : VfxGroundEffect
    {
        protected override int MaxParticles => SteamJetMeshes.MaxParticles;
    }
}
