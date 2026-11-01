using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Thornvine Blossom Crown. Defaults match the site's thorn-crown catalog entry.</summary>
    [CreateAssetMenu(fileName = "ThornCrownPreset", menuName = "ConfusedGameDev/VFX/Thornvine Blossom Crown Preset")]
    public sealed class ThornCrownPreset : VfxGroundPreset
    {
        [Header("Ground Controls")]
        [Tooltip("Vines, each with its leaves and thorns. The blossom in the centre stays.")]
        [Range(1, 8)] public int quantity = 4;

        public ThornCrownPreset() : base(new Color(0x88 / 255f, 0xd4 / 255f, 0x9a / 255f))
        {
        }

        public override int Quantity => quantity;
    }
}
