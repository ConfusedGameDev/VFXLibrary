using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Runic Mesh Barrier. Defaults match the site's magic-barrier catalog entry.</summary>
    [CreateAssetMenu(fileName = "MagicBarrierPreset", menuName = "ConfusedGameDev/VFX/Magic Barrier Preset")]
    public sealed class MagicBarrierPreset : VfxPreset
    {
        public MagicBarrierPreset()
        {
            color = new Color(0xbb / 255f, 0xa3 / 255f, 0xff / 255f);
            density = 0.5f;
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.7f;
            stopDuration = 1f;
        }
    }
}
