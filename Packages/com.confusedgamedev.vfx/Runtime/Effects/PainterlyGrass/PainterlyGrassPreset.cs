using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Windswept Meadow. Defaults match the site's painterly-grass catalog entry.</summary>
    [CreateAssetMenu(fileName = "PainterlyGrassPreset", menuName = "ConfusedGameDev/VFX/Windswept Meadow Preset")]
    public sealed class PainterlyGrassPreset : VfxGroundPreset
    {
        public PainterlyGrassPreset() : base(new Color(0x82 / 255f, 0x95 / 255f, 0x44 / 255f))
        {
            startDuration = 0.6f;
            stopDuration = 0.8f;
            density = 0.75f;
        }
    }
}
