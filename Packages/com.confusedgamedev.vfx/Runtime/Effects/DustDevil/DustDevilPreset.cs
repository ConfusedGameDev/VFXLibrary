using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Sand-Swept Vortex. Defaults match the site's dust-devil catalog entry.</summary>
    [CreateAssetMenu(fileName = "DustDevilPreset", menuName = "ConfusedGameDev/VFX/Sand-Swept Vortex Preset")]
    public sealed class DustDevilPreset : VfxGroundPreset
    {
        public DustDevilPreset() : base(new Color(0xdc / 255f, 0xbb / 255f, 0x87 / 255f))
        {
            startDuration = 1.7f;
            stopDuration = 1.4f;
        }
    }
}
