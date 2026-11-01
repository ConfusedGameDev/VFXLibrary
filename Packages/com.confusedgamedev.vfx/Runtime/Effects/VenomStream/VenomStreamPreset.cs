using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Corrosive Venom Jet. Defaults match the site's venom-stream catalog entry.</summary>
    [CreateAssetMenu(fileName = "VenomStreamPreset", menuName = "ConfusedGameDev/VFX/Corrosive Venom Jet Preset")]
    public sealed class VenomStreamPreset : VfxPreset
    {
        [Header("Beam Controls")]
        [Tooltip("Main slugs per cycle. Droplets and the end splash stay. Not the number visible at once.")]
        [Range(1, 16)] public int quantity = 8;

        public VenomStreamPreset()
        {
            color = new Color(0xac / 255f, 0xdc / 255f, 0x6f / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.25f;
            stopDuration = 0.7f;
        }
    }
}
