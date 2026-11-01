using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Ground-Hugging Mist. Defaults match the site's ground-fog catalog entry.</summary>
    [CreateAssetMenu(fileName = "GroundFogPreset", menuName = "ConfusedGameDev/VFX/Ground-Hugging Mist Preset")]
    public sealed class GroundFogPreset : VfxGroundPreset
    {
        public GroundFogPreset() : base(new Color(0xa6 / 255f, 0xc9 / 255f, 0xca / 255f))
        {
            startDuration = 0.5f;
            stopDuration = 1.2f;
        }
    }
}
