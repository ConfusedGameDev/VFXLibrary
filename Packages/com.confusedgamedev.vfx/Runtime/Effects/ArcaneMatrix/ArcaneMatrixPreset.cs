using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Floating Rune Matrix. Defaults match the site's arcane-matrix catalog entry.</summary>
    [CreateAssetMenu(fileName = "ArcaneMatrixPreset", menuName = "ConfusedGameDev/VFX/Floating Rune Matrix Preset")]
    public sealed class ArcaneMatrixPreset : VfxGroundPreset
    {
        [Header("Ground Controls")]
        [Tooltip("Floating crystals, each with its ring. The ground matrix stays whole.")]
        [Range(1, 18)] public int quantity = 9;

        public ArcaneMatrixPreset() : base(new Color(0xbd / 255f, 0x9a / 255f, 0xff / 255f))
        {
        }

        public override int Quantity => quantity;
    }
}
