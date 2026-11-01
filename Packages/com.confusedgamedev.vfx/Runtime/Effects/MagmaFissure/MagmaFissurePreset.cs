using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Molten Vein Fissure. Defaults match the site's magma-fissure catalog entry.</summary>
    [CreateAssetMenu(fileName = "MagmaFissurePreset", menuName = "ConfusedGameDev/VFX/Molten Vein Fissure Preset")]
    public sealed class MagmaFissurePreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Rock pairs thrown up along the crack. The crack itself stays.")]
        [Range(1, 26)] public int quantity = 13;

        public MagmaFissurePreset() : base(new Color(0xff / 255f, 0x82 / 255f, 0x3e / 255f), 1.8f)
        {
        }

        public override int Quantity => quantity;
    }
}
