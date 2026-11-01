using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Ringpulse Ray. Defaults match the site's pulse-beam catalog entry.</summary>
    [CreateAssetMenu(fileName = "PulseBeamPreset", menuName = "ConfusedGameDev/VFX/Ringpulse Ray Preset")]
    public sealed class PulseBeamPreset : VfxPreset
    {
        [Header("Beam Controls")]
        [Tooltip("Main pulses within the fixed range. More pulses sit closer together at the same flow speed.")]
        [Range(1, 8)] public int quantity = 4;

        public PulseBeamPreset()
        {
            color = new Color(0x71 / 255f, 0xe7 / 255f, 0xdc / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.4f;
            stopDuration = 0.6f;
        }
    }
}
