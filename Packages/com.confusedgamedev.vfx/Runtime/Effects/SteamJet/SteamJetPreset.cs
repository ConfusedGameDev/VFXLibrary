using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Rising Steam Jet. Defaults match the site's steam-jet catalog entry.</summary>
    [CreateAssetMenu(fileName = "SteamJetPreset", menuName = "ConfusedGameDev/VFX/Rising Steam Jet Preset")]
    public sealed class SteamJetPreset : VfxGroundPreset
    {
        public SteamJetPreset() : base(new Color(0xd1 / 255f, 0xdf / 255f, 0xe8 / 255f))
        {
            startDuration = 0.5f;
            stopDuration = 1.2f;
        }
    }
}
