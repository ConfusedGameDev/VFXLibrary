using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Budget and bounds shared by the one-shot bursts.</summary>
    public static class VfxBurstMeshes
    {
        public static readonly Bounds EffectBounds = new Bounds(Vector3.zero, new Vector3(16f, 16f, 16f));

        /// <summary>
        /// The source's split of a particle budget. desired = round(cap * density), less any slots held by
        /// fixed pieces; layers past the first take min(maximum, round(desired * weight)) from last to first,
        /// and the first gets what remains. Holds up to four layers, in allocation order.
        /// </summary>
        public static Vector4 LayerCounts(int cap, int fixedSlots, float density, int[] maxima, float[] weights)
        {
            int desired = Mathf.Max(1, RoundLikeSource(cap * density));
            int remaining = desired - fixedSlots;
            var counts = new Vector4();
            for (int i = maxima.Length - 1; i >= 1; i--)
            {
                int n = Mathf.Min(maxima[i], RoundLikeSource(desired * weights[i]));
                counts[i] = n;
                remaining -= n;
            }
            counts[0] = Mathf.Max(0, remaining);
            return counts;
        }

        // Math.round goes up at .5, Mathf.RoundToInt to the even number.
        private static int RoundLikeSource(float value)
        {
            return Mathf.FloorToInt(value + 0.5f);
        }
    }
}
