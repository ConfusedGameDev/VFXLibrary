using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Falling Frost Spear Array. Defaults match the site's frost-lance-rain catalog entry.</summary>
    [CreateAssetMenu(fileName = "FrostLanceRainPreset", menuName = "ConfusedGameDev/VFX/Falling Frost Spear Array Preset")]
    public sealed class FrostLanceRainPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Lances that land, each with its shards and frost patch.")]
        [Range(1, 18)] public int quantity = 9;

        [Tooltip("Moves the landing points. Lance size stays.")]
        [Range(0.5f, 3f)] public float spread = 1f;

        public FrostLanceRainPreset() : base(new Color(0xa9 / 255f, 0xdf / 255f, 0xff / 255f), 2.4f)
        {
        }

        public override int Quantity => quantity;

        public override float Spread => spread;
    }
}
