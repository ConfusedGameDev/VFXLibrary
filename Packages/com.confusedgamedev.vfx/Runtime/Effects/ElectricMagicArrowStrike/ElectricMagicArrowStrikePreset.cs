using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Golden-Bladed Lightning Arrow. Defaults match the site's electric-magic-arrow-strike catalog entry.</summary>
    [CreateAssetMenu(fileName = "ElectricMagicArrowStrikePreset", menuName = "ConfusedGameDev/VFX/Golden-Bladed Lightning Arrow Preset")]
    public sealed class ElectricMagicArrowStrikePreset : VfxPreset
    {
        public ElectricMagicArrowStrikePreset()
        {
            color = new Color(0xff / 255f, 0xd3 / 255f, 0x6a / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 1.2f;
            stopDuration = 1.4f;
        }
    }
}
