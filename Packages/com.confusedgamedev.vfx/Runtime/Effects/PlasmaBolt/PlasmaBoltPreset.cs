using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Plasma Dart. Defaults match the site's plasma-bolt catalog entry.</summary>
    [CreateAssetMenu(fileName = "PlasmaBoltPreset", menuName = "ConfusedGameDev/VFX/Plasma Dart Preset")]
    public sealed class PlasmaBoltPreset : VfxPreset
    {
        public PlasmaBoltPreset()
        {
            color = new Color(0x73 / 255f, 0xe3 / 255f, 0xff / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.35f;
            stopDuration = 0.8f;
        }
    }
}
