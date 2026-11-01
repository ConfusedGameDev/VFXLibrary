using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Golden Chain Rain. Defaults match the site's golden-chain-rain catalog entry.</summary>
    [CreateAssetMenu(fileName = "GoldenChainRainPreset", menuName = "ConfusedGameDev/VFX/Golden Chain Rain Preset")]
    public sealed class GoldenChainRainPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Chains per wave. There are always three waves.")]
        [Range(1, 12)] public int quantity = 8;

        [Tooltip("Horizontal distance between chain sources and landings.")]
        [Range(0.5f, 2f)] public float spread = 1f;

        [Tooltip("Strength of the soft light around the cracks.")]
        [Range(0f, 5f)] public float crackBloom = 0.15f;

        [Tooltip("Width of the soft light around the cracks.")]
        [Range(0.25f, 3f)] public float crackBloomSpread = 1f;

        [Tooltip("Scale of the liquid pattern on the gold.")]
        [Range(0.25f, 3f)] public float textureDensity = 0.7f;

        public GoldenChainRainPreset() : base(new Color(0xff / 255f, 0xd1 / 255f, 0x66 / 255f), 4.8f)
        {
        }

        public override int Quantity => quantity;

        public override float Spread => spread;
    }
}
