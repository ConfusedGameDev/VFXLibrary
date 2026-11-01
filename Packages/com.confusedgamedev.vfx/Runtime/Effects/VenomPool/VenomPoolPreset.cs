using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Bubbling Venom Sigil. Defaults match the site's venom-pool catalog entry.</summary>
    [CreateAssetMenu(fileName = "VenomPoolPreset", menuName = "ConfusedGameDev/VFX/Bubbling Venom Sigil Preset")]
    public sealed class VenomPoolPreset : VfxGroundPreset
    {
        [Header("Ground Controls")]
        [Tooltip("Bubbles swelling on the pool. The pool itself stays.")]
        [Range(1, 14)] public int quantity = 7;

        public VenomPoolPreset() : base(new Color(0xac / 255f, 0xdc / 255f, 0x6f / 255f))
        {
        }

        public override int Quantity => quantity;
    }
}
