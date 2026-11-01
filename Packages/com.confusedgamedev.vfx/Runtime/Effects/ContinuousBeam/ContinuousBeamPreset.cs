using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Threadwoven Beam. Defaults match the site's continuous-beam catalog entry.</summary>
    [CreateAssetMenu(fileName = "ContinuousBeamPreset", menuName = "ConfusedGameDev/VFX/Threadwoven Beam Preset")]
    public sealed class ContinuousBeamPreset : VfxPreset
    {
        public ContinuousBeamPreset()
        {
            color = new Color(0xff / 255f, 0x65 / 255f, 0x55 / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.4f;
            stopDuration = 0.6f;
        }
    }
}
