using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>White-Hot Fireburst. Defaults match the site's fire-explosion catalog entry.</summary>
    [CreateAssetMenu(fileName = "FireExplosionPreset", menuName = "ConfusedGameDev/VFX/White-Hot Fireburst Preset")]
    public sealed class FireExplosionPreset : VfxBurstPreset
    {
        public FireExplosionPreset() : base(new Color(0xff / 255f, 0x5c / 255f, 0x26 / 255f), 2.8f)
        {
        }
    }
}
