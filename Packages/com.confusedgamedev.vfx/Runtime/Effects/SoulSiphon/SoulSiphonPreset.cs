using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Dark Energy Siphon. Defaults match the site's soul-siphon catalog entry.</summary>
    [CreateAssetMenu(fileName = "SoulSiphonPreset", menuName = "ConfusedGameDev/VFX/Dark Energy Siphon Preset")]
    public sealed class SoulSiphonPreset : VfxPreset
    {
        [Header("Beam Controls")]
        [Tooltip("Orbs returning each cycle, split between the strands. Not the number visible at once.")]
        [Range(1, 18)] public int quantity = 9;

        public SoulSiphonPreset()
        {
            color = new Color(0xa8 / 255f, 0x83 / 255f, 0xe8 / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.35f;
            stopDuration = 0.65f;
        }
    }
}
