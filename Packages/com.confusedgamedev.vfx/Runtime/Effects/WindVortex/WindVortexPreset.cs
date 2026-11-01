using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Leaf-Swept Vortex. Defaults match the site's wind-vortex catalog entry.</summary>
    [CreateAssetMenu(fileName = "WindVortexPreset", menuName = "ConfusedGameDev/VFX/Leaf-Swept Vortex Preset")]
    public sealed class WindVortexPreset : VfxGroundPreset
    {
        public WindVortexPreset() : base(new Color(0xa4 / 255f, 0xdf / 255f, 0xd1 / 255f))
        {
            startDuration = 1.7f;
            stopDuration = 1.4f;
        }
    }
}
