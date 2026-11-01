using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>A fixed-capacity pool of lightning ribbons in one dynamic mesh.</summary>
    public sealed class ElectricArrowPool
    {
        private readonly Vector3[] positions;
        private readonly Vector4[] tangents;
        private readonly Vector4[] events;
        private bool dirty;

        public ElectricArrowPool(string name, int channels, int forks, int segments, int rings = 0)
        {
            Channels = channels;
            Forks = forks;
            int total = channels * 2 * (forks + 1) + rings;
            Points = new float[total][];
            Offsets = new int[total];
            Cache = new int[channels * 2];

            int vertices = 0;
            int triangles = 0;
            for (int i = 0; i < total; i++)
            {
                int n = i >= total - rings ? 64 : segments;
                Points[i] = new float[(n + 1) * 3];
                Offsets[i] = vertices;
                vertices += (n + 1) * 2;
                triangles += n * 2;
            }

            positions = new Vector3[vertices];
            tangents = new Vector4[vertices];
            events = new Vector4[vertices];
            var uvs = new Vector2[vertices];
            var indices = new int[triangles * 3];
            int cursor = 0;
            for (int i = 0; i < total; i++)
            {
                int n = Points[i].Length / 3 - 1;
                for (int j = 0; j <= n; j++)
                {
                    int a = Offsets[i] + j * 2;
                    uvs[a] = new Vector2((float)j / n, -1f);
                    uvs[a + 1] = new Vector2((float)j / n, 1f);
                    if (j < n)
                    {
                        indices[cursor++] = a;
                        indices[cursor++] = a + 1;
                        indices[cursor++] = a + 2;
                        indices[cursor++] = a + 1;
                        indices[cursor++] = a + 3;
                        indices[cursor++] = a + 2;
                    }
                }
            }

            Mesh = new Mesh { name = name, indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            Mesh.SetVertices(positions);
            Mesh.SetUVs(0, uvs);
            Mesh.SetUVs(1, tangents);
            Mesh.SetUVs(2, events);
            Mesh.SetTriangles(indices, 0, false);
            Mesh.bounds = ElectricMagicArrowStrikeMeshes.EffectBounds;
            ResetCache();
        }

        public Mesh Mesh { get; }

        public int Channels { get; }

        public int Forks { get; }

        public float[][] Points { get; }

        public int[] Offsets { get; }

        public int[] Cache { get; }

        public int Mode { get; set; } = -1;

        public void ResetCache()
        {
            for (int i = 0; i < Cache.Length; i++)
            {
                Cache[i] = int.MinValue;
            }
        }

        /// <summary>Writes a path's ribbon. Kind 2 is a ring, 1 a fork, 0 a leader.</summary>
        public void Upload(int index, float birth, float life, float power, float width, int kind = 0)
        {
            float[] p = Points[index];
            int n = p.Length / 3 - 1;
            for (int i = 0; i <= n; i++)
            {
                int before = Mathf.Max(0, i - 1) * 3;
                int after = Mathf.Min(n, i + 1) * 3;
                var tangent = new Vector3(p[after] - p[before], p[after + 1] - p[before + 1], p[after + 2] - p[before + 2]);
                float length = tangent.magnitude;
                tangent = length > 0f ? tangent / length : tangent;
                float w = width * (kind == 2 ? 1f : 1f - (float)i / n * 0.82f);
                var data = new Vector4(tangent.x, tangent.y, tangent.z, w);
                var eventData = new Vector4(birth, life, power, kind);
                var position = new Vector3(p[i * 3], p[i * 3 + 1], p[i * 3 + 2]);
                for (int side = 0; side < 2; side++)
                {
                    int v = Offsets[index] + i * 2 + side;
                    positions[v] = position;
                    tangents[v] = data;
                    events[v] = eventData;
                }
            }
            dirty = true;
        }

        public void Apply()
        {
            if (!dirty)
            {
                return;
            }

            const UnityEngine.Rendering.MeshUpdateFlags Flags = UnityEngine.Rendering.MeshUpdateFlags.DontRecalculateBounds | UnityEngine.Rendering.MeshUpdateFlags.DontValidateIndices;
            Mesh.SetVertices(positions, 0, positions.Length, Flags);
            Mesh.SetUVs(1, tangents, 0, tangents.Length, Flags);
            Mesh.SetUVs(2, events, 0, events.Length, Flags);
            dirty = false;
        }
    }

    /// <summary>
    /// The arrow's lightning: seeded events on fixed clocks, regenerated only when a channel's event
    /// changes. Everything is preallocated, so it costs no garbage per frame.
    /// </summary>
    public sealed class ElectricArrowDischarge
    {
        private const uint Seed = 829646;
        private const float Start = 1.2f;

        private readonly float[] startPoint = new float[3];
        private readonly float[] endPoint = new float[3];
        private uint variationSeed;

        public ElectricArrowDischarge(uint seed)
        {
            variationSeed = seed;
            Arcs = ElectricMagicArrowStrikeMeshes.CreateArcPool();
            Trails = ElectricMagicArrowStrikeMeshes.CreateTrailPool();
            Blast = ElectricMagicArrowStrikeMeshes.CreateBlastPool();

            // Two shock rings stay in the impact's paths for good.
            for (int k = 0; k < 2; k++)
            {
                int index = Blast.Points.Length - 2 + k;
                float[] points = Blast.Points[index];
                int n = points.Length / 3 - 1;
                float r = 3.25f - k * 0.45f;
                for (int i = 0; i <= n; i++)
                {
                    float a = i / (float)n * Mathf.PI * 2f;
                    int j = i * 3;
                    points[j] = k == 1 ? Mathf.Sin(a) * r * 0.58f : 0f;
                    points[j + 1] = Mathf.Cos(a) * r;
                    points[j + 2] = Mathf.Sin(a) * r * (k == 1 ? 0.82f : 1f);
                }
                Blast.Upload(index, 0.08f + k * 0.10f, 1.1f, 0.44f, 0.13f, 2);
            }
        }

        public ElectricArrowPool Arcs { get; }

        public ElectricArrowPool Trails { get; }

        public ElectricArrowPool Blast { get; }

        /// <summary>A new cast, with its own lightning.</summary>
        public void Restart(uint seed)
        {
            variationSeed = seed;
            Arcs.ResetCache();
            Trails.ResetCache();
            Blast.ResetCache();
        }

        public void Release()
        {
            Dispose(Arcs.Mesh);
            Dispose(Trails.Mesh);
            Dispose(Blast.Mesh);
        }

        /// <summary>Brings the arrow's lightning up to a clock, which stops at the moment of Stop or Hit.</summary>
        public void SyncArrow(float clock, bool flying)
        {
            Sync(Arcs, clock, flying ? 1 : 0, 0.145f);
            Sync(Trails, clock, 0, 0.16f);
        }

        /// <summary>Brings the impact's lightning up to seconds since contact.</summary>
        public void SyncImpact(float clock)
        {
            Sync(Blast, Mathf.Min(0.70f, clock), 0, 0.15f);
        }

        private static void Dispose(Mesh mesh)
        {
            if (Application.isPlaying)
            {
                Object.Destroy(mesh);
            }
            else
            {
                Object.DestroyImmediate(mesh);
            }
        }

        private float Noise(int key, int salt = 0)
        {
            uint x = unchecked(variationSeed ^ Seed ^ ((uint)(key + 1) * 0x9e3779b1u) ^ ((uint)(salt + 1) * 0x85ebca6bu));
            x = unchecked((x ^ (x >> 16)) * 0x7feb352du);
            x = unchecked((x ^ (x >> 15)) * 0x846ca68bu);
            return (float)((x ^ (x >> 16)) / 4294967296.0);
        }

        private void Sync(ElectricArrowPool batch, float clock, int mode, float period)
        {
            if (batch.Mode != mode)
            {
                batch.ResetCache();
                batch.Mode = mode;
            }

            bool blast = batch == Blast;
            for (int c = 0; c < batch.Channels; c++)
            {
                float offset = blast ? (c < 4 ? c * 0.002f : 0.035f + (c - 4) * 0.022f) : c * period / batch.Channels;
                int current = Mathf.FloorToInt((clock - offset + 1e-6f) / period);
                for (int bank = 0; bank < 2; bank++)
                {
                    int eventIndex = current - bank;
                    int index = c * 2 + bank;
                    if (batch.Cache[index] == eventIndex)
                    {
                        continue;
                    }

                    batch.Cache[index] = eventIndex;
                    float birth = eventIndex * period + offset + (blast && eventIndex == 0 && c < 4 ? 0f : Noise(c + eventIndex * 47, blast ? 700 : 300) * 0.012f);
                    Generate(batch, c, eventIndex, bank, birth, mode);
                }
            }
            batch.Apply();
        }

        private void Generate(ElectricArrowPool batch, int channel, int eventIndex, int bank, float birth, int mode)
        {
            bool isBlast = batch == Blast;
            bool isTrail = batch == Trails;
            int family = isBlast ? 10000 : isTrail ? 20000 : 0;
            int key = family + channel * 701 + eventIndex * 47;

            // Some alternate strokes revisit the channel before them, with different pulse energy.
            int routeEvent = eventIndex > 0 && eventIndex % 2 == 1 && Noise(key, 99) < 0.5f ? eventIndex - 1 : eventIndex;
            int route = family + channel * 701 + routeEvent * 47;
            int first = (channel * 2 + bank) * (batch.Forks + 1);
            float life = 0.09f + Noise(key, 1) * 0.05f;

            // Four unequal outward leaders, with surface crawlers between them.
            float angle = Noise(route, 2) * Mathf.PI * 2f;
            if (isBlast)
            {
                float lobe = channel % 4 == 0 ? 0f : channel % 4 == 1 ? 0.85f : channel % 4 == 2 ? 2.70f : 4.15f;
                angle = Noise(432, 2) * Mathf.PI * 2f + lobe + (Noise(route, 2) - 0.5f) * 0.68f;
            }

            float charge = Mathf.Min(1f, Mathf.Max(0f, birth) / Start);
            float power = 1.05f + Noise(key, 5) * 0.40f;
            float width = 0.235f;
            float amplitude = 0.40f;
            if (isBlast)
            {
                bool secondary = channel >= 4;
                float z = secondary ? (Noise(route, 3) - 0.5f) * 0.18f : 0.15f + Noise(route, 3) * 0.68f;
                float r = Mathf.Sqrt(1f - z * z);
                float reach = secondary ? 1.60f + Noise(route, 4) * 1.25f : 2.45f + Noise(route, 4) * 0.80f;
                startPoint[0] = 0f;
                startPoint[1] = 0f;
                startPoint[2] = 0f;
                endPoint[0] = z * reach;
                endPoint[1] = Mathf.Cos(angle) * r * reach;
                endPoint[2] = Mathf.Sin(angle) * r * reach;
                amplitude = secondary ? 0.28f : 0.52f;
                width = secondary ? 0.11f : 0.25f;
                power *= secondary ? Mathf.Max(0f, 1f - Mathf.Max(0f, birth - 0.22f) / 0.55f) * 0.42f : birth < 0.45f ? 1.12f : 0f;
            }
            else if (isTrail)
            {
                startPoint[0] = -1.2f;
                startPoint[1] = Mathf.Cos(angle) * 0.06f;
                startPoint[2] = Mathf.Sin(angle) * 0.06f;
                endPoint[0] = -2f - Noise(route, 4) * 2.1f;
                endPoint[1] = Mathf.Cos(angle + 0.6f) * 0.36f;
                endPoint[2] = Mathf.Sin(angle + 0.6f) * 0.36f;
                amplitude = 0.16f;
                width = 0.095f;
                power *= 0.58f;
            }
            else
            {
                float tight = 1f - 0.72f * Smooth(0.875f, 1f, charge);
                float radius = (0.38f + Noise(route, 3) * 0.65f) * tight;
                startPoint[0] = charge < 0.3f ? -1.7f : -1.6f + Noise(route, 6) * 0.9f;
                float ring = charge < 0.3f ? 0.88f : radius;
                startPoint[1] = Mathf.Cos(angle) * ring;
                startPoint[2] = Mathf.Sin(angle) * ring;
                endPoint[0] = charge < 0.3f ? -0.55f + charge * 3f : 0.90f + Noise(route, 7) * 0.72f;
                endPoint[1] = Mathf.Cos(angle + Noise(route, 8) * 2f) * 0.10f;
                endPoint[2] = Mathf.Sin(angle + Noise(route, 8) * 2f) * 0.10f;
                amplitude = (0.36f + Noise(route, 10) * 0.38f) * tight;
                power *= charge < 0.25f ? (channel < 2 ? 0.65f : 0f) : charge < 0.5f ? (channel < 3 ? 0.85f : 0f) : 1f;
                if (mode == 1)
                {
                    startPoint[0] -= 0.85f;
                    startPoint[1] *= 1.25f;
                    startPoint[2] *= 1.25f;
                    amplitude = 0.34f + Noise(route, 10) * 0.2f;
                }
            }

            if (eventIndex < 0 || birth < 0f)
            {
                power = 0f;
            }

            float[] main = batch.Points[first];
            Fracture(main, route, amplitude, isBlast ? 3.25f : 0f);
            batch.Upload(first, birth, life, power, width);
            for (int branch = 1; branch <= batch.Forks; branch++)
            {
                int branchKey = route + branch * 151;
                int root = 5 + Mathf.FloorToInt(Noise(branchKey, 12) * 19f);
                int j = root * 3;
                startPoint[0] = main[j];
                startPoint[1] = main[j + 1];
                startPoint[2] = main[j + 2];
                float a = Noise(branchKey, 13) * Mathf.PI * 2f;
                float reach = (isBlast ? 0.6f : 0.30f) + Noise(branchKey, 14) * (isBlast ? 0.8f : 0.66f);
                endPoint[0] = startPoint[0] + (isBlast ? (Noise(branchKey, 15) - 0.25f) * reach : mode == 1 ? -0.3f - reach * 0.6f : 0.16f + Noise(branchKey, 15) * 0.45f);
                endPoint[1] = startPoint[1] + Mathf.Cos(a) * reach;
                endPoint[2] = startPoint[2] + Mathf.Sin(a) * reach;
                if (!isBlast && charge > 0.86f && mode == 0)
                {
                    endPoint[1] *= 0.65f;
                    endPoint[2] *= 0.65f;
                }

                Fracture(batch.Points[first + branch], branchKey, 0.14f + reach * 0.16f, isBlast ? 3.25f : 0f);

                // Forks appear only once the leader has reached their connection.
                float strength = Noise(key, 30 + branch) < 0.18f ? 0f : power * (0.38f + Noise(branchKey, 31) * 0.30f);
                int segments = main.Length / 3 - 1;
                batch.Upload(first + branch, birth + (float)root / segments * (isBlast ? 0.012f : 0.024f), life * 0.65f, strength, width * 0.50f, 1);
            }
        }

        // Midpoint displacement between startPoint and endPoint, then the arrow's or the blast's limit.
        private void Fracture(float[] p, int key, float amplitude, float limit)
        {
            int n = p.Length / 3 - 1;
            for (int c = 0; c < 3; c++)
            {
                p[c] = startPoint[c];
                p[n * 3 + c] = endPoint[c];
            }

            for (int stride = n; stride > 1; stride /= 2)
            {
                int half = stride / 2;
                float amp = amplitude * Mathf.Pow((float)stride / n, 0.72f);
                for (int i = half; i < n; i += stride)
                {
                    for (int c = 0; c < 3; c++)
                    {
                        p[i * 3 + c] = (p[(i - half) * 3 + c] + p[(i + half) * 3 + c]) * 0.5f + (Noise(key, i * 3 + c) - 0.5f) * 2f * amp * (c == 0 ? 0.55f : 1f);
                    }
                }
            }

            for (int i = 0; i <= n; i++)
            {
                int j = i * 3;
                if (limit > 0f)
                {
                    float r = Mathf.Sqrt(p[j] * p[j] + p[j + 1] * p[j + 1] + p[j + 2] * p[j + 2]);
                    if (r > limit)
                    {
                        float shrink = limit / r;
                        p[j] *= shrink;
                        p[j + 1] *= shrink;
                        p[j + 2] *= shrink;
                    }
                }
                else
                {
                    p[j] = Mathf.Clamp(p[j], -4.2f, 1.72f);
                    float r = Mathf.Sqrt(p[j + 1] * p[j + 1] + p[j + 2] * p[j + 2]);
                    if (r > 1.35f)
                    {
                        p[j + 1] *= 1.35f / r;
                        p[j + 2] *= 1.35f / r;
                    }
                }
            }
        }

        private static float Smooth(float a, float b, float x)
        {
            float q = Mathf.Clamp01((x - a) / (b - a));
            return q * q * (3f - 2f * q);
        }
    }
}
