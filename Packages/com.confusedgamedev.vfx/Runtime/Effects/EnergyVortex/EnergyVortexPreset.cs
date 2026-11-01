using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Runic Ring Vortex. Defaults match the site's energy-vortex catalog entry.</summary>
    [CreateAssetMenu(fileName = "EnergyVortexPreset", menuName = "ConfusedGameDev/VFX/Runic Ring Vortex Preset")]
    public sealed class EnergyVortexPreset : VfxGroundPreset
    {
        public EnergyVortexPreset() : base(new Color(0xbb / 255f, 0xa5 / 255f, 0xff / 255f))
        {
            startDuration = 1.7f;
            stopDuration = 1.4f;
        }
    }
}
