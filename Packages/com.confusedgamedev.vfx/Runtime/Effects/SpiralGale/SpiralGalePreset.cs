using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Spiraling Wind Spear. Defaults match the site's spiral-gale catalog entry.</summary>
    [CreateAssetMenu(fileName = "SpiralGalePreset", menuName = "ConfusedGameDev/VFX/Spiraling Wind Spear Preset")]
    public sealed class SpiralGalePreset : VfxPreset
    {
        public SpiralGalePreset()
        {
            color = new Color(0xb4 / 255f, 0xe5 / 255f, 0xd5 / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.35f;
            stopDuration = 0.8f;
        }
    }
}
