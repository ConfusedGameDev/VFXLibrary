using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Vitality Blossom. Defaults match the site's revival-bloom catalog entry.</summary>
    [CreateAssetMenu(fileName = "RevivalBloomPreset", menuName = "ConfusedGameDev/VFX/Vitality Blossom Preset")]
    public sealed class RevivalBloomPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Petals, split between the two rings.")]
        [Range(1, 28)] public int quantity = 14;

        public RevivalBloomPreset() : base(new Color(0xff / 255f, 0x8f / 255f, 0xbd / 255f), 2.2f)
        {
        }

        public override int Quantity => quantity;
    }
}
