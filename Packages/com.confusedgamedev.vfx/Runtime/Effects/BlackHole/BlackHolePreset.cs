using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Luminous Vortex Black Hole. Defaults match the site's black-hole catalog entry.</summary>
    [CreateAssetMenu(fileName = "BlackHolePreset", menuName = "ConfusedGameDev/VFX/Luminous Vortex Black Hole Preset")]
    public sealed class BlackHolePreset : VfxGroundPreset
    {
        [Header("Controls")]
        [Tooltip("Replaces the shared size: the site runs this effect from 0.25 to 12. The hole sits 1.5 times this above the origin.")]
        [Range(0.25f, 12f)] public float holeSize = 6f;

        [Tooltip("Replaces the shared detail: the site runs this effect from 0.25 to 4. Sets the lens strength and light.")]
        [Range(0.25f, 4f)] public float holeDetail = 2f;

        public BlackHolePreset() : base(new Color(0xff / 255f, 0xab / 255f, 0x42 / 255f))
        {
            startDuration = 1.1f;
            stopDuration = 1.4f;
            density = 1f;
        }
    }
}
