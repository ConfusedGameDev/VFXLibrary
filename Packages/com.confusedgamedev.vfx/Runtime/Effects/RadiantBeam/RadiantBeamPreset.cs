using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Solar Halo Beam. Defaults match the site's radiant-beam catalog entry.</summary>
    [CreateAssetMenu(fileName = "RadiantBeamPreset", menuName = "ConfusedGameDev/VFX/Solar Halo Beam Preset")]
    public sealed class RadiantBeamPreset : VfxPreset
    {
        public RadiantBeamPreset()
        {
            color = new Color(0xff / 255f, 0xe3 / 255f, 0xa0 / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.4f;
            stopDuration = 0.6f;
        }
    }
}
