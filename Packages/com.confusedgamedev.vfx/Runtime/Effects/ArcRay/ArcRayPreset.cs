using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Forked Lightning Stream. Defaults match the site's arc-ray catalog entry.</summary>
    [CreateAssetMenu(fileName = "ArcRayPreset", menuName = "ConfusedGameDev/VFX/Forked Lightning Stream Preset")]
    public sealed class ArcRayPreset : VfxPreset
    {
        [Header("Beam Controls")]
        [Tooltip("Independent arcs between the ends. The end flares and the range stay as they are.")]
        [Range(1, 12)] public int quantity = 6;

        public ArcRayPreset()
        {
            color = new Color(0x28 / 255f, 0x78 / 255f, 0xff / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.4f;
            stopDuration = 0.6f;
        }
    }
}
