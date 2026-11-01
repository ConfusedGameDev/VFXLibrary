using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>The effect's clock-driven values. Pure functions of time, so seeking and replay agree.</summary>
    public struct DarkchainMotion
    {
        public const float Burst = 3.65f;

        private const float CompressionStart = 3.47f;
        private const float CompressionScale = 0.65f / 3f;
        private const float OrbStart = 1.15f;
        private const float Settle = 0.036f;
        private const float Attack = 0.012f;
        private const float Overshoot = 1.1f;
        private const float RestRadius = 0.2f;
        private const float BlastRadiusEnd = 4.2f;
        private const float BlastExpand = 0.08f;
        private const float BlastLife = 1.3f;
        private const float WarpLife = 1.5f;
        private const float WarpCycles = 10f;
        private const float WaveRadiusEnd = 10.6f;
        private const float WaveExpand = 0.8f;
        private const float ChainEnd = 0.85f;
        private const float ChainSettle = 0.4f;

        // Thirty absorption beats: start, then the radius the orb lands on.
        private static readonly float[] Beats =
        {
            1.350000f, 0.236000f,
            1.450000f, 0.272000f,
            1.550000f, 0.308000f,
            1.650000f, 0.344000f,
            1.750000f, 0.380000f,
            1.850000f, 0.420000f,
            1.940000f, 0.460000f,
            2.030000f, 0.500000f,
            2.120000f, 0.540000f,
            2.210000f, 0.580000f,
            2.300000f, 0.624000f,
            2.380000f, 0.668000f,
            2.460000f, 0.712000f,
            2.540000f, 0.756000f,
            2.620000f, 0.800000f,
            2.700000f, 0.844000f,
            2.770000f, 0.888000f,
            2.840000f, 0.932000f,
            2.910000f, 0.976000f,
            2.980000f, 1.020000f,
            3.050000f, 1.064000f,
            3.110000f, 1.108000f,
            3.170000f, 1.152000f,
            3.230000f, 1.196000f,
            3.290000f, 1.240000f,
            3.350000f, 1.282000f,
            3.410000f, 1.324000f,
            3.470000f, 1.366000f,
            3.530000f, 1.408000f,
            3.590000f, 1.450000f
        };

        private static float LastBeatRadius => Beats[Beats.Length - 1];

        public float radius;
        public float beat;
        public float flow;
        public float orbAlive;
        public float blastRadius;
        public float jetTravel;
        public float jetFade;
        public float warpFade;
        public float warpKick;
        public float waveRadius;
        public float tension;

        public static DarkchainMotion At(float time)
        {
            float t = Mathf.Max(0f, time);
            float radius = RestRadius;
            float beat = 0f;
            float pulseTime = Mathf.Min(t, CompressionStart);
            for (int i = 0; i < Beats.Length; i += 2)
            {
                float start = Beats[i];
                float target = Beats[i + 1];
                if (pulseTime < start)
                {
                    break;
                }

                float age = pulseTime - start;
                float peak = target * Overshoot;
                if (age < Attack)
                {
                    float q = Mathf.Clamp01(age / Attack);
                    radius += (peak - radius) * (1f - Cube(1f - q));
                    beat = Mathf.Sin(q * Mathf.PI * 0.5f);
                    break;
                }

                if (age < Attack + Settle)
                {
                    float q = Mathf.Clamp01((age - Attack) / Settle);
                    radius = peak + (target - peak) * (1f - (1f - q) * (1f - q));
                    beat = 1f - Smooth(0f, 1f, q);
                    break;
                }
                radius = target;
            }

            // Only the core changes scale. The blast, wave and fragment radii stay independent.
            if (t >= CompressionStart)
            {
                beat = 0f;
                for (int i = 0; i < Beats.Length; i += 2)
                {
                    float start = Beats[i];
                    if (t < start)
                    {
                        break;
                    }

                    float age = t - start;
                    if (age < Attack)
                    {
                        beat = Mathf.Sin(Mathf.Clamp01(age / Attack) * Mathf.PI * 0.5f);
                        break;
                    }

                    if (age < Attack + Settle)
                    {
                        beat = 1f - Smooth(0f, 1f, Mathf.Clamp01((age - Attack) / Settle));
                        break;
                    }
                }

                float q = Mathf.Clamp01((t - CompressionStart) / (Burst - CompressionStart));
                radius *= 1f - (1f - CompressionScale) * q * (0.35f + 0.65f * q);
            }

            var motion = new DarkchainMotion
            {
                radius = radius * Smooth(OrbStart, OrbStart + 0.12f, t),
                beat = beat,
                flow = Mathf.Max(0f, t - OrbStart) * 0.36f,
                orbAlive = Smooth(OrbStart, OrbStart + 0.1f, t) * (t < Burst ? 1f : 0f)
            };
            for (int i = 0; i < Beats.Length; i += 2)
            {
                motion.flow += 0.03f * Smooth(Beats[i] - 0.044f, Beats[i] + 0.012f, t);
            }

            motion.blastRadius = LastBeatRadius + (BlastRadiusEnd - LastBeatRadius) * (1f - Cube(1f - Mathf.Clamp01((t - Burst) / BlastExpand)));
            float jet = Mathf.Clamp01((t - Burst - BlastExpand) / (BlastLife - BlastExpand));
            motion.jetTravel = 1.25f * (1f - Cube(1f - jet));
            float jetFade = 1f - Mathf.Clamp01((t - Burst - 0.25f) / (BlastLife - 0.25f));
            motion.jetFade = jetFade * jetFade;

            float warpAge = t - Burst;
            float warp = Mathf.Clamp01(warpAge / WarpLife);
            motion.warpFade = warpAge >= 0f ? Mathf.Pow(1f - warp, 1.25f) : 0f;
            motion.warpKick = warpAge >= 0f && warpAge < WarpLife ? Mathf.Sin(warp * Mathf.PI * 2f * WarpCycles) * Mathf.Exp(-warp * 3f) : 0f;
            float wave = 1f - Mathf.Clamp01((t - Burst) / WaveExpand);
            motion.waveRadius = LastBeatRadius + (WaveRadiusEnd - LastBeatRadius) * (1f - wave * wave * wave * wave * wave);
            motion.tension = Tension(t);
            return motion;
        }

        /// <summary>The chains' whip after they land, as a fraction of their bend.</summary>
        public static float Tension(float time)
        {
            float q = Mathf.Clamp01((time - ChainEnd) / ChainSettle);
            return Mathf.Exp(-1.6f * q) * Mathf.Cos(q * Mathf.PI * 2f) * (1f - Smooth(0.75f, 1f, q));
        }

        private static float Cube(float x)
        {
            return x * x * x;
        }

        private static float Smooth(float a, float b, float x)
        {
            float q = Mathf.Clamp01((x - a) / (b - a));
            return q * q * (3f - 2f * q);
        }
    }
}
