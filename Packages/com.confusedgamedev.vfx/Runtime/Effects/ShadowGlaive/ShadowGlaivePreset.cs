using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Afterimage Glaive. Defaults match the site's shadow-glaive catalog entry.</summary>
    [CreateAssetMenu(fileName = "ShadowGlaivePreset", menuName = "ConfusedGameDev/VFX/Afterimage Glaive Preset")]
    public sealed class ShadowGlaivePreset : VfxPreset
    {
        public ShadowGlaivePreset()
        {
            color = new Color(0xa2 / 255f, 0x8b / 255f, 0xce / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.35f;
            stopDuration = 0.8f;
        }
    }
}
