using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Dust-Raising Shockwave. Defaults match the site's shockwave catalog entry.</summary>
    [CreateAssetMenu(fileName = "ShockwavePreset", menuName = "ConfusedGameDev/VFX/Dust-Raising Shockwave Preset")]
    public sealed class ShockwavePreset : VfxBurstPreset
    {
        public ShockwavePreset() : base(new Color(0xf0 / 255f, 0xcf / 255f, 0x9d / 255f), 2.8f)
        {
        }
    }
}
