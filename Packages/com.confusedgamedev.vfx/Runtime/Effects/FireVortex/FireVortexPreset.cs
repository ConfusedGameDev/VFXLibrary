using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Flame-Swept Vortex. Defaults match the site's fire-vortex catalog entry.</summary>
    [CreateAssetMenu(fileName = "FireVortexPreset", menuName = "ConfusedGameDev/VFX/Flame-Swept Vortex Preset")]
    public sealed class FireVortexPreset : VfxGroundPreset
    {
        public FireVortexPreset() : base(new Color(0xff / 255f, 0x88 / 255f, 0x4b / 255f))
        {
            startDuration = 1.7f;
            stopDuration = 1.4f;
        }
    }
}
