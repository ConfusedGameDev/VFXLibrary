using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace ConfusedGameDev.Vfx
{
    public enum VfxFiringKind
    {
        EnergyPistol,
        PulseRifle,
        TwinCannon,
        Laser,
        Railgun,
        Missile,
        Arc
    }

    /// <summary>
    /// The single-shot firing effects of the weapons and turrets. Everything is drawn each frame with
    /// Graphics.RenderMesh, so a shot adds nothing to the scene. There is no damage or collision here.
    /// </summary>
    [ExecuteAlways]
    [RequireComponent(typeof(VfxObject))]
    public sealed class VfxObjectFiring : VfxEffect
    {
        private const int RibbonCapacity = 512;
        private const float MissileFlight = 1.75f;
        private const float MissileScale = 0.26f / 0.9f;

        private static readonly int ColorId = Shader.PropertyToID("_Color");
        private static readonly Color Cream = Hex(0xfffdf4);

        private static Mesh cylinder;
        private static Mesh sphere;
        private static Mesh torus;
        private static Mesh quad;

        [SerializeField] private VfxFiringKind kind;
        [SerializeField] private Material flatMaterial;
        [SerializeField] private Material glowMaterial;
        [SerializeField] private Material arcCoreMaterial;
        [SerializeField] private Material arcHaloMaterial;
        [SerializeField] private Material smokeMaterial;
        [SerializeField] private Material ribbonMaterial;
        [SerializeField] private Mesh missileMesh;
        [SerializeField] private Material[] missileMaterials = Array.Empty<Material>();

        private readonly List<Transform> selected = new List<Transform>();
        private readonly Vector3[] arcPath = new Vector3[97];
        private readonly Vector3[] arcMainPath = new Vector3[65];

        private Vector3[] ribbonPositions;
        private Vector3[] ribbonPrevious;
        private Vector3[] ribbonNext;
        private Vector2[] ribbonData;
        private Mesh ribbon;
        private int ribbonCount;

        private VfxObject owner;
        private MaterialPropertyBlock block;
        private Vector3? target;
        private Pose launch;
        private int missileCursor;
        private float rootScale;
        private Bounds drawBounds;

        private struct Pose
        {
            public Vector3 origin;
            public Vector3 direction;
            public Vector3 right;
            public Vector3 up;
            public float distance;
            public Vector3 end;
        }

        private readonly struct Line
        {
            public readonly Color core;
            public readonly Color glow;
            public readonly float coreRadius;
            public readonly float glowRadius;

            public Line(int core, float coreRadius, float glowRadius, int glow)
            {
                this.core = Hex(core);
                this.glow = Hex(glow);
                this.coreRadius = coreRadius;
                this.glowRadius = glowRadius;
            }
        }

        private static readonly Line RifleTracer = new Line(0xfff0bf, 0.009f, 0.032f, 0xff8d32);
        private static readonly Line CannonTracer = new Line(0xffe7a4, 0.009f, 0.027f, 0xff8b24);
        private static readonly Line RailBeam = new Line(0xe6f5ff, 0.007f, 0.029f, 0x5799ff);
        private static readonly Line LaserBeam = new Line(0xceffff, 0.01f, 0.044f, 0x14d9dd);
        private static readonly Line MissileFlame = new Line(0xfff1b8, 0.023f, 0.06f, 0xff8c22);

        public VfxFiringKind Kind => kind;

        /// <summary>Limits the shot to one camera. Null draws it for every camera.</summary>
        public Camera RenderCamera { get; set; }

        /// <summary>How far a shot reaches with no target, in world units.</summary>
        public float Range => RangeOf(kind);

        /// <summary>The fire points in use by the current shot.</summary>
        public int ActivePointCount => selected.Count;

        public static float DurationOf(VfxFiringKind kind)
        {
            switch (kind)
            {
                case VfxFiringKind.EnergyPistol: return 0.9f;
                case VfxFiringKind.PulseRifle: return 1.1f;
                case VfxFiringKind.TwinCannon: return 1.65f;
                case VfxFiringKind.Laser: return 1.8f;
                case VfxFiringKind.Railgun: return 1.55f;
                case VfxFiringKind.Missile: return 2.5f;
                default: return 2.2f;
            }
        }

        public static float RangeOf(VfxFiringKind kind)
        {
            switch (kind)
            {
                case VfxFiringKind.EnergyPistol: return 1.2f;
                case VfxFiringKind.PulseRifle: return 1.8f;
                case VfxFiringKind.Railgun: return 4f;
                case VfxFiringKind.Missile: return 3.6f;
                default: return 3.4f;
            }
        }

        /// <summary>
        /// Fires once, restarting any shot in progress. With no pointId, every point fires, except the
        /// missile turret, which launches from its next pod. Target is a world position.
        /// </summary>
        public void Fire(string pointId = null, Vector3? worldTarget = null)
        {
            if (owner == null)
            {
                owner = GetComponent<VfxObject>();
            }

            Transform requested = null;
            if (pointId != null)
            {
                requested = owner.FindFirePoint(pointId);
                if (requested == null)
                {
                    throw new ArgumentException("Unknown firing point: " + pointId, nameof(pointId));
                }
            }

            target = worldTarget;
            Select(requested);
            Play();
        }

        /// <summary>Ends the shot at once.</summary>
        public void StopFire()
        {
            Stop(true);
        }

        /// <summary>Issues this frame's draws. LateUpdate calls it, so only call it to render outside the player loop.</summary>
        public void DrawFrame()
        {
            if (!IsPlaying || selected.Count == 0)
            {
                return;
            }

            rootScale = transform.lossyScale.y;
            drawBounds = new Bounds(transform.position, Vector3.one * (Range * 4f + 8f));
            block ??= new MaterialPropertyBlock();
            EnsureMeshes();

            float t = EffectTime;
            Pose first = PoseOf(selected[0]);
            switch (kind)
            {
                case VfxFiringKind.EnergyPistol:
                case VfxFiringKind.PulseRifle:
                    DrawHandgun(t, first);
                    break;
                case VfxFiringKind.TwinCannon:
                    DrawCannon(t);
                    break;
                case VfxFiringKind.Laser:
                    DrawLaser(t, first);
                    break;
                case VfxFiringKind.Railgun:
                    DrawRailgun(t);
                    break;
                case VfxFiringKind.Missile:
                    DrawMissile(t);
                    break;
                default:
                    DrawArc(t, first);
                    break;
            }
        }

        protected override void OnPlay()
        {
            if (selected.Count == 0)
            {
                Select(null);
            }

            if (kind == VfxFiringKind.Missile && selected.Count > 0)
            {
                launch = PoseOf(selected[0]);
            }
        }

        private void LateUpdate()
        {
            DrawFrame();
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            if (ribbon == null)
            {
                return;
            }

            if (Application.isPlaying)
            {
                Destroy(ribbon);
            }
            else
            {
                DestroyImmediate(ribbon);
            }
        }

        private void Select(Transform requested)
        {
            if (owner == null)
            {
                owner = GetComponent<VfxObject>();
            }

            selected.Clear();
            Transform[] points = owner.FirePoints;
            if (requested != null)
            {
                selected.Add(requested);
            }
            else if (kind == VfxFiringKind.Missile && points.Length > 0)
            {
                selected.Add(points[missileCursor++ % points.Length]);
            }
            else
            {
                selected.AddRange(points);
            }
        }

        private void DrawHandgun(float t, Pose first)
        {
            bool pistol = kind == VfxFiringKind.EnergyPistol;
            Color color = Hex(pistol ? 0x19d8e6 : 0xff8d32);
            float speed = pistol ? 4.5f : 10f;
            int shots = pistol ? 1 : 3;

            for (int i = 0; i < shots; i++)
            {
                float age = t - i * 0.19f;
                if (age < 0f)
                {
                    continue;
                }

                if (age < 0.12f)
                {
                    DrawFlash(color, first, (pistol ? 0.07f : 0.055f) * (1f - age / 0.14f));
                    DrawRing(color, first, At(first, 0.025f), 0.025f + age * 0.22f, 1f - age / 0.12f, 0f);
                }

                float head = age * speed;
                if (head > 0f && head < first.distance)
                {
                    if (pistol)
                    {
                        Pose moved = first;
                        moved.origin = At(first, Mathf.Max(0f, head - 0.055f));
                        DrawFlash(color, moved, 0.06f);
                    }
                    else
                    {
                        DrawLine(RifleTracer, At(first, Mathf.Max(0f, head - 0.3f)), At(first, head));
                    }
                }
            }
        }

        private void DrawCannon(float t)
        {
            for (int i = 0; i < 6; i++)
            {
                float age = t - i * 0.18f;
                if (age < 0f)
                {
                    continue;
                }

                Pose pose = PoseOf(selected[i % selected.Count]);
                if (age < 0.095f)
                {
                    DrawFlash(Hex(0xff9b24), pose, 0.13f * (1f - age / 0.11f), 1f - age / 0.105f);
                }

                float head = age * 11f;
                if (head > 0.05f && head < pose.distance)
                {
                    DrawLine(CannonTracer, At(pose, Mathf.Max(0.05f, head - 0.38f)), At(pose, head));
                }
            }
        }

        private void DrawLaser(float t, Pose first)
        {
            Color color = Hex(0x14d9dd);
            bool charging = t < 0.42f;
            float power = charging ? t / 0.42f : Mathf.Max(0f, 1f - (t - 1.42f) / 0.32f);

            if (t < 1.74f)
            {
                DrawFlash(color, first, 0.02f + 0.055f * power, 0.65f + 0.35f * power);
                for (int i = 0; i < 3; i++)
                {
                    DrawRing(color, first, At(first, 0.04f + i * 0.055f), (0.16f - i * 0.03f) * (charging ? 1.25f - power * 0.55f : 1f), 0.65f * power, t * (i + 1));
                }
            }

            if (t >= 0.42f && t < 1.58f)
            {
                float width = Mathf.Max(0.05f, Mathf.Min(1f, Mathf.Min((t - 0.42f) / 0.055f, (1.58f - t) / 0.16f)));
                DrawLine(LaserBeam, At(first, 0.025f), first.end, width * (1f + 0.08f * Mathf.Sin(t * 65f)));
            }
        }

        private void DrawRailgun(float t)
        {
            const float chargeTime = 0.62f;
            Color color = Hex(0x5799ff);

            foreach (Transform point in selected)
            {
                Pose pose = PoseOf(point);
                if (t < chargeTime)
                {
                    float power = t / chargeTime;
                    DrawFlash(color, pose, 0.02f + 0.055f * power);
                    for (int i = 0; i < 3; i++)
                    {
                        DrawRing(color, pose, At(pose, 0.025f + i * 0.06f), (0.095f - i * 0.014f) * (1f - 0.4f * power), 0.35f + 0.6f * power, t * 6f + i);
                    }
                    continue;
                }

                float age = t - chargeTime;
                float fade = Mathf.Max(0f, 1f - age / 0.75f);
                if (age < 0.18f)
                {
                    DrawFlash(color, pose, 0.105f * (1f - age / 0.18f));
                }

                if (age < 0.62f)
                {
                    DrawLine(RailBeam, At(pose, 0.005f), pose.end, age < 0.09f ? 1.6f : 0.65f, Mathf.Max(0f, 1f - age / 0.62f));
                }

                for (int i = 0; i < 3; i++)
                {
                    DrawRing(color, pose, At(pose, 0.10f + age * (1.1f + i * 0.35f)), 0.065f + age * 0.16f, fade * 0.75f, age * 3f + i);
                }
            }
        }

        private void DrawMissile(float t)
        {
            float travel = Mathf.Min(1f, t / MissileFlight);
            float distance = launch.distance * (0.12f * travel + 0.88f * travel * travel);
            Vector3 tail = launch.origin + launch.direction * distance;

            if (t < MissileFlight)
            {
                // The source fades the missile's material. This one is opaque, so it shrinks away instead.
                float fade = Mathf.Min(1f, (MissileFlight - t) / 0.12f);
                DrawMissileBody(tail, fade);
                DrawLine(MissileFlame, tail - launch.direction * (0.16f + 0.035f * Mathf.Sin(t * 89f)), tail, 0.8f + 0.1f * Mathf.Sin(t * 75f));
            }

            for (int i = 0; i < 22; i++)
            {
                float born = 0.04f + i * 0.072f;
                float age = t - born;
                if (age < 0f || age > 0.88f)
                {
                    continue;
                }

                float p = born / MissileFlight;
                float d = launch.distance * (0.12f * p + 0.88f * p * p);
                Vector3 world = launch.origin + launch.direction * (d - 0.025f) + launch.up * (age * 0.14f) + launch.right * (Mathf.Sin(i * 5.71f) * age * 0.055f);
                DrawBillboard(smokeMaterial, world, 0.052f + age * 0.20f, 0.48f * (1f - age / 0.88f), Hex(0x59626d), 0);
            }
        }

        private void DrawMissileBody(Vector3 tail, float fade)
        {
            if (missileMesh == null || fade <= 0f)
            {
                return;
            }

            Matrix4x4 matrix = Matrix4x4.TRS(tail, Quaternion.FromToRotation(Vector3.up, launch.direction), Vector3.one * (MissileScale * rootScale * fade));
            int count = Mathf.Min(missileMesh.subMeshCount, missileMaterials.Length);
            for (int i = 0; i < count; i++)
            {
                var parameters = new RenderParams(missileMaterials[i])
                {
                    layer = gameObject.layer,
                    camera = RenderCamera,
                    worldBounds = drawBounds,
                    lightProbeUsage = LightProbeUsage.BlendProbes
                };
                Graphics.RenderMesh(parameters, missileMesh, i, matrix);
            }
        }

        private void DrawArc(float t, Pose first)
        {
            ribbonCount = 0;
            bool charging = t < 0.5f;
            int phase = Mathf.FloorToInt(t * 18f);
            float power = charging ? t / 0.5f : Mathf.Max(0f, 1f - (t - 1.3f) / 0.45f);

            Vector3 center = Vector3.zero;
            foreach (Transform point in selected)
            {
                center += point.position;
            }
            center /= selected.Count;
            Vector3 junction = center + first.direction * 0.24f;

            if (t < 1.75f)
            {
                Vector3 origin = charging ? center : junction;
                DrawBillboard(arcCoreMaterial, origin, 0.10f + 0.09f * power, power, Color.white, 3);
                DrawBillboard(arcHaloMaterial, origin, 0.34f + 0.2f * power, power * 0.85f, Color.white, 1);

                for (int i = 0; i < selected.Count; i++)
                {
                    Jagged(selected[i].position, junction, first, phase + i, 0.045f, 0.065f, 0.75f * power, 6);
                }

                if (!charging)
                {
                    Jagged(junction, first.end, first, phase, 0.23f, 0.22f, power, 64, false, true);

                    for (int i = 0; i < 3; i++)
                    {
                        Vector3 start = arcMainPath[14 + i * 15];
                        float angle = i * 2.399f + phase * 0.17f;
                        Vector3 end = start + first.direction * 0.48f + first.right * (Mathf.Cos(angle) * 0.48f) + first.up * (Mathf.Sin(angle) * 0.48f);
                        float flicker = 0.3f + 0.7f * (Mathf.Sin(phase * 3.7f + i * 4.1f) > -0.2f ? 1f : 0f);
                        Jagged(start, end, first, phase + 9 + i, 0.07f, 0.09f, power * 0.7f * flicker, 16, true);
                    }

                    for (int i = 0; i < 5; i++)
                    {
                        float a = i * 2.399f + phase * 0.09f;
                        Vector3 end = junction + first.right * (Mathf.Cos(a) * 0.43f) + first.up * (Mathf.Sin(a) * 0.43f) - first.direction * 0.12f;
                        Jagged(junction, end, first, phase + i, 0.05f, 0.085f, power * 0.65f, 12, true);
                    }
                }
            }

            if (t >= 0.5f)
            {
                DrawArcImpact(t - 0.5f, t, phase, first);
            }

            FlushRibbon();
        }

        private void DrawArcImpact(float age, float t, int phase, Pose first)
        {
            float fade = Mathf.Clamp01((2.2f - t) / 0.55f);
            float pulse = 0.85f + 0.15f * Mathf.Sin(age * 48f);
            float burst = 1f + Mathf.Exp(-age * 24f) * 0.4f;
            DrawBillboard(arcCoreMaterial, first.end, 0.30f * pulse * burst * fade, fade, Color.white, 3);
            DrawBillboard(arcHaloMaterial, first.end, 1.0f * pulse * burst * fade, fade, Color.white, 1);

            for (int i = 0; i < 9; i++)
            {
                float angle = i * 2.399f + Mathf.Sin(phase * 0.7f + i) * 0.18f;
                float reach = (0.36f + 0.30f * (0.5f + 0.5f * Mathf.Sin(i * 7.3f))) * fade;
                Vector3 end = first.end + first.right * (Mathf.Cos(angle) * reach) + first.up * (Mathf.Sin(angle) * reach) + first.direction * (Mathf.Sin(i * 4.1f) * reach * 0.45f);
                float flash = 0.25f + 0.75f * (Mathf.Sin(phase * 2.3f + i * 7.9f) > 0f ? 1f : 0f);
                Jagged(first.end, end, first, phase + i, 0.065f, 0.12f, fade * flash, 16, true);
            }

            for (int i = 0; i < 12; i++)
            {
                float life = Mathf.Repeat(age * (1.3f + (i % 3) * 0.2f) + i * 0.618f, 1f);
                float angle = i * 2.399f;
                float travel = life * 0.85f;
                Vector3 center = first.end + first.right * (Mathf.Cos(angle) * travel) + first.up * (Mathf.Sin(angle) * travel) + first.direction * (Mathf.Sin(i * 3.7f) * travel * 0.35f);
                Vector3 end = center + first.right * (Mathf.Cos(angle) * 0.09f * (1f - life)) + first.up * (Mathf.Sin(angle) * 0.09f * (1f - life));
                ArcSegment(center, end, 0.018f, fade * (1f - life), center, end, 0f, end, center);
            }
        }

        private static float ArcNoise(float h, int cells, float key)
        {
            float x = h * cells;
            float k = Mathf.Floor(x);
            float f = x - k;
            return ArcHash(k, key) * (1f - f) + ArcHash(k + 1f, key) * f;
        }

        private static float ArcHash(float n, float key)
        {
            float v = Mathf.Sin(n * 127.1f + key * 311.7f) * 43758.5453f;
            return (v - Mathf.Floor(v)) * 2f - 1f;
        }

        private void Jagged(Vector3 start, Vector3 end, Pose pose, int seed, float amplitude, float width, float opacity, int steps, bool taper = false, bool saveMain = false)
        {
            for (int i = 0; i <= steps; i++)
            {
                float t = (float)i / steps;
                float edge = Mathf.Sin(t * Mathf.PI);
                Vector3 point = Vector3.Lerp(start, end, t);
                point += pose.right * ((ArcNoise(t, 7, seed) + ArcNoise(t, 53, seed + 9) * 0.17f) * amplitude * edge);
                point += pose.up * ((ArcNoise(t, 8, seed + 21) + ArcNoise(t, 57, seed + 17) * 0.17f) * amplitude * edge);
                arcPath[i] = point;
                if (saveMain)
                {
                    arcMainPath[i] = point;
                }
            }

            for (int i = 0; i < steps; i++)
            {
                float startWidth = width * (taper ? 1f - (float)i / steps * 0.9f : 1f);
                float endWidth = width * (taper ? 1f - (float)(i + 1) / steps * 0.9f : 1f);
                ArcSegment(arcPath[i], arcPath[i + 1], startWidth, opacity,
                    arcPath[Mathf.Max(0, i - 3)], arcPath[Mathf.Min(steps, i + 4)], endWidth,
                    arcPath[Mathf.Min(steps, i + 3)], arcPath[Mathf.Max(0, i - 2)]);
            }
        }

        private void ArcSegment(Vector3 start, Vector3 end, float width, float opacity, Vector3 before, Vector3 after, float endWidth, Vector3 startNext, Vector3 endPrevious)
        {
            if (ribbonCount >= RibbonCapacity || (start - end).sqrMagnitude < 1e-12f || opacity <= 0f)
            {
                return;
            }

            int index = ribbonCount * 4;
            for (int vertex = 0; vertex < 4; vertex++)
            {
                bool finish = vertex > 1;
                int i = index + vertex;
                ribbonPositions[i] = finish ? end : start;
                ribbonPrevious[i] = finish ? endPrevious : before;
                ribbonNext[i] = finish ? after : startNext;
                ribbonData[i] = new Vector2((finish ? endWidth : width) * rootScale, opacity);
            }
            ribbonCount++;
        }

        private void FlushRibbon()
        {
            if (ribbonCount == 0 || ribbonMaterial == null)
            {
                return;
            }

            int vertices = ribbonCount * 4;
            ribbon.SetVertices(ribbonPositions, 0, vertices, MeshUpdateFlags.DontRecalculateBounds);
            ribbon.SetUVs(1, ribbonPrevious, 0, vertices, MeshUpdateFlags.DontRecalculateBounds);
            ribbon.SetUVs(2, ribbonNext, 0, vertices, MeshUpdateFlags.DontRecalculateBounds);
            ribbon.SetUVs(3, ribbonData, 0, vertices, MeshUpdateFlags.DontRecalculateBounds);
            ribbon.SetSubMesh(0, new SubMeshDescriptor(0, ribbonCount * 6), MeshUpdateFlags.DontRecalculateBounds | MeshUpdateFlags.DontValidateIndices);
            ribbon.bounds = drawBounds;

            var parameters = Parameters(ribbonMaterial, 2);
            Graphics.RenderMesh(parameters, ribbon, 0, Matrix4x4.identity);
        }

        private Pose PoseOf(Transform point)
        {
            var pose = new Pose
            {
                origin = point.position,
                direction = point.forward,
                distance = Range
            };

            if (target.HasValue)
            {
                Vector3 toTarget = target.Value - pose.origin;
                if (toTarget.sqrMagnitude > 1e-10f)
                {
                    pose.distance = toTarget.magnitude;
                    pose.direction = toTarget.normalized;
                }
            }

            pose.right = point.right;
            pose.up = Vector3.Cross(pose.direction, pose.right).normalized;
            if (pose.up.sqrMagnitude < 1e-8f)
            {
                pose.up = Vector3.up;
            }
            pose.right = Vector3.Cross(pose.up, pose.direction).normalized;
            pose.end = pose.origin + pose.direction * pose.distance;
            return pose;
        }

        private static Vector3 At(Pose pose, float distance)
        {
            return pose.origin + pose.direction * distance;
        }

        private RenderParams Parameters(Material material, int order)
        {
            return new RenderParams(material)
            {
                layer = gameObject.layer,
                camera = RenderCamera,
                worldBounds = drawBounds,
                matProps = block,
                rendererPriority = order,
                shadowCastingMode = ShadowCastingMode.Off,
                receiveShadows = false,
                lightProbeUsage = LightProbeUsage.Off,
                reflectionProbeUsage = ReflectionProbeUsage.Off
            };
        }

        private void DrawMesh(Material material, Mesh mesh, Matrix4x4 matrix, Color color, float opacity, int order)
        {
            if (material == null)
            {
                return;
            }

            color.a = opacity;
            block.SetColor(ColorId, color);
            Graphics.RenderMesh(Parameters(material, order), mesh, 0, matrix);
        }

        private void DrawSegment(Vector3 start, Vector3 end, float radius, Color color, float opacity, int order)
        {
            Vector3 delta = end - start;
            float length = delta.magnitude;
            if (length <= 1e-7f || opacity <= 0f)
            {
                return;
            }

            float width = radius * rootScale;
            Matrix4x4 matrix = Matrix4x4.TRS(start + delta * 0.5f, Quaternion.FromToRotation(Vector3.up, delta / length), new Vector3(width, length, width));
            DrawMesh(flatMaterial, cylinder, matrix, color, opacity, order);
        }

        private void DrawLine(Line line, Vector3 start, Vector3 end, float weight = 1f, float opacity = 1f)
        {
            DrawSegment(start, end, line.coreRadius * weight, line.core, opacity, 2);
            DrawSegment(start, end, line.glowRadius * weight, line.glow, opacity * 0.32f, 1);
        }

        private void DrawFlash(Color color, Pose pose, float size, float opacity = 1f)
        {
            if (size <= 0f || opacity <= 0f)
            {
                return;
            }

            Vector3 center = At(pose, size * 0.38f);
            Quaternion rotation = Quaternion.LookRotation(pose.direction);
            float core = size * 0.42f * rootScale;
            float glow = size * rootScale;
            DrawMesh(flatMaterial, sphere, Matrix4x4.TRS(center, rotation, new Vector3(core, core, core * 2.1f)), Cream, opacity, 2);
            DrawMesh(glowMaterial, sphere, Matrix4x4.TRS(center, rotation, new Vector3(glow, glow, glow * 2.1f)), color, opacity * 0.4f, 1);
        }

        private void DrawRing(Color color, Pose pose, Vector3 position, float radius, float opacity, float rotation)
        {
            if (radius <= 0f || opacity <= 0f)
            {
                return;
            }

            Quaternion facing = Quaternion.LookRotation(pose.direction) * Quaternion.Euler(0f, 0f, rotation * Mathf.Rad2Deg);
            DrawMesh(flatMaterial, torus, Matrix4x4.TRS(position, facing, Vector3.one * (radius * rootScale)), color, opacity, 0);
        }

        private void DrawBillboard(Material material, Vector3 position, float radius, float opacity, Color color, int order)
        {
            if (radius <= 0f || opacity <= 0f)
            {
                return;
            }

            DrawMesh(material, quad, Matrix4x4.TRS(position, Quaternion.identity, Vector3.one * (radius * rootScale)), color, opacity, order);
        }

        private void EnsureMeshes()
        {
            cylinder = cylinder != null ? cylinder : CreateCylinder();
            sphere = sphere != null ? sphere : CreateSphere();
            torus = torus != null ? torus : CreateTorus();
            quad = quad != null ? quad : CreateQuad();

            if (kind == VfxFiringKind.Arc && ribbon == null)
            {
                CreateRibbon();
            }
        }

        private void CreateRibbon()
        {
            int vertices = RibbonCapacity * 4;
            ribbonPositions = new Vector3[vertices];
            ribbonPrevious = new Vector3[vertices];
            ribbonNext = new Vector3[vertices];
            ribbonData = new Vector2[vertices];
            var uvs = new Vector2[vertices];
            var indices = new int[RibbonCapacity * 6];
            for (int i = 0; i < RibbonCapacity; i++)
            {
                int n = i * 4;
                uvs[n] = new Vector2(0f, 0f);
                uvs[n + 1] = new Vector2(0f, 1f);
                uvs[n + 2] = new Vector2(1f, 0f);
                uvs[n + 3] = new Vector2(1f, 1f);
                int t = i * 6;
                indices[t] = n;
                indices[t + 1] = n + 1;
                indices[t + 2] = n + 2;
                indices[t + 3] = n + 1;
                indices[t + 4] = n + 3;
                indices[t + 5] = n + 2;
            }

            ribbon = new Mesh { name = "ArcRibbon", hideFlags = HideFlags.HideAndDontSave, indexFormat = IndexFormat.UInt32 };
            ribbon.MarkDynamic();
            ribbon.SetVertices(ribbonPositions);
            ribbon.SetUVs(0, uvs);
            ribbon.SetUVs(1, ribbonPrevious);
            ribbon.SetUVs(2, ribbonNext);
            ribbon.SetUVs(3, ribbonData);
            ribbon.SetTriangles(indices, 0, false);
        }

        private static Mesh Finish(string name, Vector3[] vertices, int[] triangles)
        {
            var mesh = new Mesh { name = name, hideFlags = HideFlags.HideAndDontSave };
            mesh.SetVertices(vertices);
            mesh.SetTriangles(triangles, 0);
            mesh.RecalculateBounds();
            return mesh;
        }

        // A unit radius, unit height open tube along Y.
        private static Mesh CreateCylinder()
        {
            const int sides = 8;
            var vertices = new Vector3[sides * 2];
            var triangles = new int[sides * 6];
            for (int i = 0; i < sides; i++)
            {
                float angle = i * Mathf.PI * 2f / sides;
                var ring = new Vector3(Mathf.Cos(angle), 0f, Mathf.Sin(angle));
                vertices[i * 2] = ring + Vector3.down * 0.5f;
                vertices[i * 2 + 1] = ring + Vector3.up * 0.5f;
                int next = (i + 1) % sides;
                int t = i * 6;
                triangles[t] = i * 2;
                triangles[t + 1] = i * 2 + 1;
                triangles[t + 2] = next * 2;
                triangles[t + 3] = next * 2;
                triangles[t + 4] = i * 2 + 1;
                triangles[t + 5] = next * 2 + 1;
            }
            return Finish("FiringCylinder", vertices, triangles);
        }

        private static Mesh CreateSphere()
        {
            const int rings = 8;
            const int sides = 12;
            var vertices = new Vector3[(rings + 1) * (sides + 1)];
            var triangles = new int[rings * sides * 6];
            for (int y = 0; y <= rings; y++)
            {
                float polar = y * Mathf.PI / rings;
                for (int x = 0; x <= sides; x++)
                {
                    float angle = x * Mathf.PI * 2f / sides;
                    vertices[y * (sides + 1) + x] = new Vector3(Mathf.Sin(polar) * Mathf.Cos(angle), Mathf.Cos(polar), Mathf.Sin(polar) * Mathf.Sin(angle));
                }
            }

            int t = 0;
            for (int y = 0; y < rings; y++)
            {
                for (int x = 0; x < sides; x++)
                {
                    int a = y * (sides + 1) + x;
                    int b = a + sides + 1;
                    triangles[t++] = a;
                    triangles[t++] = a + 1;
                    triangles[t++] = b;
                    triangles[t++] = b;
                    triangles[t++] = a + 1;
                    triangles[t++] = b + 1;
                }
            }
            return Finish("FiringSphere", vertices, triangles);
        }

        // A unit ring around Z, with the source's tube of 0.045.
        private static Mesh CreateTorus()
        {
            const int rings = 32;
            const int sides = 5;
            const float tube = 0.045f;
            var vertices = new Vector3[rings * sides];
            var triangles = new int[rings * sides * 6];
            int t = 0;
            for (int i = 0; i < rings; i++)
            {
                float angle = i * Mathf.PI * 2f / rings;
                var center = new Vector3(Mathf.Cos(angle), Mathf.Sin(angle), 0f);
                for (int j = 0; j < sides; j++)
                {
                    float around = j * Mathf.PI * 2f / sides;
                    vertices[i * sides + j] = center * (1f + tube * Mathf.Cos(around)) + Vector3.forward * (tube * Mathf.Sin(around));
                    int a = i * sides + j;
                    int b = (i + 1) % rings * sides + j;
                    int c = i * sides + (j + 1) % sides;
                    int d = (i + 1) % rings * sides + (j + 1) % sides;
                    triangles[t++] = a;
                    triangles[t++] = b;
                    triangles[t++] = c;
                    triangles[t++] = b;
                    triangles[t++] = d;
                    triangles[t++] = c;
                }
            }
            return Finish("FiringTorus", vertices, triangles);
        }

        // The billboard shaders expand it around the object's origin, so its bounds stay generous.
        private static Mesh CreateQuad()
        {
            var mesh = Finish("FiringQuad",
                new[] { new Vector3(-1f, -1f, 0f), new Vector3(-1f, 1f, 0f), new Vector3(1f, -1f, 0f), new Vector3(1f, 1f, 0f) },
                new[] { 0, 1, 2, 2, 1, 3 });
            mesh.SetUVs(0, new[] { new Vector2(0f, 0f), new Vector2(0f, 1f), new Vector2(1f, 0f), new Vector2(1f, 1f) });
            return mesh;
        }

        private static Color Hex(int rgb)
        {
            return new Color32((byte)(rgb >> 16), (byte)(rgb >> 8), (byte)rgb, 255);
        }
    }
}
