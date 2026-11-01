using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Crystal-Toothed Ice Wheel. Defaults match the site's frost-wheel catalog entry.</summary>
    [CreateAssetMenu(fileName = "FrostWheelPreset", menuName = "ConfusedGameDev/VFX/Crystal-Toothed Ice Wheel Preset")]
    public sealed class FrostWheelPreset : VfxPreset
    {
        public FrostWheelPreset()
        {
            color = new Color(0xa9 / 255f, 0xdf / 255f, 0xff / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.35f;
            stopDuration = 0.8f;
        }
    }
}
