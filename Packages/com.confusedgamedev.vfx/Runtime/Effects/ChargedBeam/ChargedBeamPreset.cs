using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Charged Light Cannon. Defaults match the site's charged-beam catalog entry.</summary>
    [CreateAssetMenu(fileName = "ChargedBeamPreset", menuName = "ConfusedGameDev/VFX/Charged Light Cannon Preset")]
    public sealed class ChargedBeamPreset : VfxPreset
    {
        public ChargedBeamPreset()
        {
            color = new Color(0xf6 / 255f, 0xc7 / 255f, 0x6c / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 1.6f;
            stopDuration = 0.6f;
        }
    }
}
