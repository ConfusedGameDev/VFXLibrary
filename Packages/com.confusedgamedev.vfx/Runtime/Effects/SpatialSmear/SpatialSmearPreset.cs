using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Riftblade Trail. Defaults match the site's spatial-smear catalog entry.</summary>
    [CreateAssetMenu(fileName = "SpatialSmearPreset", menuName = "ConfusedGameDev/VFX/Riftblade Trail Preset")]
    public sealed class SpatialSmearPreset : VfxPreset
    {
        public SpatialSmearPreset()
        {
            color = new Color(0xe9 / 255f, 0xf5 / 255f, 0xff / 255f);
            playback = VfxPlayback.Looping;
            duration = 4f;
            startDuration = 0.001f;
            stopDuration = VfxBladeTrailEffect.Lifetime;
        }
    }
}
