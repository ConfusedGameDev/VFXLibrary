using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Sacred Relic Descent. Defaults match the site's sacred-relic-descent catalog entry.</summary>
    [CreateAssetMenu(fileName = "SacredRelicDescentPreset", menuName = "ConfusedGameDev/VFX/Sacred Relic Descent Preset")]
    public sealed class SacredRelicDescentPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Reach of the ground wave and the raised smoke ring. Height, the relic and the timing stay put.")]
        [Range(0.5f, 1.5f)] public float spread = 1f;

        public SacredRelicDescentPreset() : base(new Color(0xf5 / 255f, 0xcc / 255f, 0x75 / 255f), 13f)
        {
            stopDuration = 0.45f;
        }

        public override float Spread => spread;
    }
}
