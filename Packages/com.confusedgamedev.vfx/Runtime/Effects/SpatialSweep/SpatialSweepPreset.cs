using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Riftblade Sweep. Defaults match the site's spatial-sweep catalog entry.</summary>
    [CreateAssetMenu(fileName = "SpatialSweepPreset", menuName = "ConfusedGameDev/VFX/Riftblade Sweep Preset")]
    public sealed class SpatialSweepPreset : VfxBurstPreset
    {
        public SpatialSweepPreset() : base(new Color(0xe9 / 255f, 0xf5 / 255f, 0xff / 255f), 0.85f)
        {
        }
    }
}
