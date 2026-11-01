using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Vortex Lightning Strike. Defaults match the site's thunder-strike catalog entry.</summary>
    [CreateAssetMenu(fileName = "ThunderStrikePreset", menuName = "ConfusedGameDev/VFX/Vortex Lightning Strike Preset")]
    public sealed class ThunderStrikePreset : VfxBurstPreset
    {
        public ThunderStrikePreset() : base(new Color(0x28 / 255f, 0x78 / 255f, 0xff / 255f), 2.6f)
        {
        }
    }
}
