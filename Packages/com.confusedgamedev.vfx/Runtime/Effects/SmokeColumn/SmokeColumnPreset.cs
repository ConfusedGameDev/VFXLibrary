using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Billowing Smoke Column. Defaults match the site's smoke-column catalog entry.</summary>
    [CreateAssetMenu(fileName = "SmokeColumnPreset", menuName = "ConfusedGameDev/VFX/Billowing Smoke Column Preset")]
    public sealed class SmokeColumnPreset : VfxGroundPreset
    {
        public SmokeColumnPreset() : base(new Color(0xae / 255f, 0xb9 / 255f, 0xcb / 255f))
        {
            startDuration = 0.5f;
            stopDuration = 1.2f;
        }
    }
}
