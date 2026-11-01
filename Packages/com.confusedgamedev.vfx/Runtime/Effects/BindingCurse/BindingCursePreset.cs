using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Hooked Binding Sigil. Defaults match the site's binding-curse catalog entry.</summary>
    [CreateAssetMenu(fileName = "BindingCursePreset", menuName = "ConfusedGameDev/VFX/Hooked Binding Sigil Preset")]
    public sealed class BindingCursePreset : VfxGroundPreset
    {
        [Header("Ground Controls")]
        [Tooltip("Binding arcs around the target. The ground sigil stays.")]
        [Range(1, 6)] public int quantity = 3;

        public BindingCursePreset() : base(new Color(0xae / 255f, 0x7b / 255f, 0xe5 / 255f))
        {
        }

        public override int Quantity => quantity;
    }
}
