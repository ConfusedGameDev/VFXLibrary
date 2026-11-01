using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Base of the weapon trails: a ribbon of the blade's recent world-space history. There is no sword,
    /// input or animation here. Give it a weapon with AttachWeapon, or in the inspector, and swing that.
    /// Until then the Editor swings a stand-in blade, so the trail can be seen. Builds draw nothing.
    /// </summary>
    public abstract class VfxBladeTrailEffect : VfxEffect
    {
        /// <summary>Blade positions the ribbon can hold.</summary>
        public const int Capacity = 64;

        /// <summary>Seconds of effect time each position lasts.</summary>
        public const float Lifetime = 0.18f;

        private const float PreviewCycle = 1.2f;
        private const float PreviewSweep = 0.4f;
        private const float PreviewArc = 75f;

        private static readonly int DensityId = Shader.PropertyToID("_Quantity");

        [Header("Weapon")]
        [SerializeField] private Transform weapon;
        [Tooltip("Blade root, in the weapon's local space.")]
        [SerializeField] private Vector3 bladeBase = Vector3.zero;
        [Tooltip("Blade tip, in the weapon's local space.")]
        [SerializeField] private Vector3 bladeTip = Vector3.up;
        [Tooltip("With no weapon, swing a stand-in blade around this object in the Editor. Never runs in a build.")]
        [SerializeField] private bool previewSwing = true;

        private readonly Vector3[] bases = new Vector3[Capacity];
        private readonly Vector3[] tips = new Vector3[Capacity];
        private readonly float[] times = new float[Capacity];
        private readonly Vector3[] positions = new Vector3[Capacity * 2];
        private readonly Vector2[] ages = new Vector2[Capacity * 2];

        private Mesh ribbon;
        private MeshFilter[] filters;
        private Mesh[] bakedMeshes;
        private int count;
        private float clock;

        /// <summary>Blade positions in the ribbon right now.</summary>
        public int SampleCount => count;

        public bool HasWeapon => weapon != null;

        /// <summary>True while there is no weapon, so the Editor swings the stand-in blade.</summary>
        public bool UsesPreviewSwing => weapon == null && previewSwing && Application.isEditor;

        /// <summary>Starts a fresh trail from a weapon. Base and tip are in its local space.</summary>
        public void AttachWeapon(Transform target, Vector3 root, Vector3 tip)
        {
            if (target == null)
            {
                throw new ArgumentNullException(nameof(target));
            }

            if ((root - tip).sqrMagnitude < 1e-12f)
            {
                throw new ArgumentException("Blade base and tip must differ.");
            }

            weapon = target;
            bladeBase = root;
            bladeTip = tip;
            ResetTrail();
        }

        /// <summary>Lets go of the weapon, and the trail runs out.</summary>
        public void DetachWeapon()
        {
            weapon = null;
            Stop();
        }

        protected override void OnPlay()
        {
            EnsureRibbon();
            ResetTrail();
        }

        protected override void OnTick(float deltaTime)
        {
            if (!(deltaTime >= 0f) || float.IsInfinity(deltaTime))
            {
                return;
            }

            clock += deltaTime * ActiveSpeed();
            while (count > 0 && clock - times[0] > Lifetime)
            {
                RemoveFirst();
            }

            if (State == VfxState.Playing)
            {
                if (weapon != null)
                {
                    Sample(deltaTime, weapon.TransformPoint(bladeBase), weapon.TransformPoint(bladeTip));
                }
                else if (UsesPreviewSwing)
                {
                    Quaternion blade = Quaternion.Euler(0f, 0f, PreviewAngle());
                    Sample(deltaTime, transform.TransformPoint(blade * (Vector3.up * 0.4f)), transform.TransformPoint(blade * (Vector3.up * 1.6f)));
                }
            }

            Rebuild();
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            // Sets how many fine lines the blade shows.
            block.SetFloat(DensityId, parameters.density);
        }

        // Animators run after Update, and the blade has to be read after them.
        protected override void Update()
        {
        }

        protected virtual void LateUpdate()
        {
            if (Application.isPlaying)
            {
                Tick(Time.deltaTime);
            }
        }

        protected virtual void OnDisable()
        {
            if (!Application.isPlaying)
            {
                EndEditPreview();
            }
        }

        /// <summary>Puts the baked meshes back, so an edit-mode preview cannot be saved into the scene.</summary>
        public override void EndEditPreview()
        {
            if (filters == null)
            {
                return;
            }

            for (int i = 0; i < filters.Length; i++)
            {
                if (filters[i] != null)
                {
                    filters[i].sharedMesh = bakedMeshes[i];
                }
            }
            filters = null;
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

        private float ActiveSpeed()
        {
            return ActiveParameters != null ? ActiveParameters.speed : 1f;
        }

        private void ResetTrail()
        {
            count = 0;
            clock = 0f;
            Rebuild();
        }

        // A quick sweep, a pause so the ribbon can fade, then a sweep back.
        private float PreviewAngle()
        {
            int cycle = Mathf.FloorToInt(clock / PreviewCycle);
            float sweep = Mathf.SmoothStep(-PreviewArc, PreviewArc, (clock - cycle * PreviewCycle) / PreviewSweep);
            return cycle % 2 == 0 ? sweep : -sweep;
        }

        private void Sample(float deltaTime, Vector3 root, Vector3 tip)
        {
            float length = Vector3.Distance(root, tip);
            if (float.IsNaN(length) || float.IsInfinity(length) || length <= 1e-6f)
            {
                count = 0;
                return;
            }

            // A long frame or a teleport would draw a sheet across the gap.
            if (deltaTime > 0.25f || (count > 0 && Mathf.Max(Vector3.Distance(root, bases[count - 1]), Vector3.Distance(tip, tips[count - 1])) > length * 3f))
            {
                count = 0;
            }

            if (count == 0 || Mathf.Max((root - bases[count - 1]).sqrMagnitude, (tip - tips[count - 1]).sqrMagnitude) > length * length * 1e-10f)
            {
                if (count == Capacity)
                {
                    RemoveFirst();
                }

                bases[count] = root;
                tips[count] = tip;
                times[count] = clock;
                count++;
            }
        }

        private void RemoveFirst()
        {
            Array.Copy(bases, 1, bases, 0, count - 1);
            Array.Copy(tips, 1, tips, 0, count - 1);
            Array.Copy(times, 1, times, 0, count - 1);
            count--;
        }

        private void EnsureRibbon()
        {
            if (ribbon == null)
            {
                ribbon = VfxBladeTrailMeshes.CreateRibbon(name + "Ribbon");
                ribbon.hideFlags = HideFlags.DontSave;
                ribbon.MarkDynamic();
            }

            if (filters != null)
            {
                return;
            }

            filters = GetComponentsInChildren<MeshFilter>(true);
            bakedMeshes = new Mesh[filters.Length];
            for (int i = 0; i < filters.Length; i++)
            {
                bakedMeshes[i] = filters[i].sharedMesh;
                filters[i].sharedMesh = ribbon;
            }
        }

        private void Rebuild()
        {
            if (ribbon == null)
            {
                return;
            }

            VfxPreset active = ActiveParameters;
            float reach = active != null ? Mathf.Clamp(active.size, 0.25f, 1f) : 1f;
            Matrix4x4 toLocal = transform.worldToLocalMatrix;
            var bounds = new Bounds(Vector3.zero, Vector3.zero);

            for (int i = 0; i < count; i++)
            {
                Vector3 root = toLocal.MultiplyPoint3x4(Vector3.Lerp(tips[i], bases[i], reach));
                Vector3 tip = toLocal.MultiplyPoint3x4(tips[i]);
                positions[i * 2] = root;
                positions[i * 2 + 1] = tip;
                float age = Mathf.Min(1f, (clock - times[i]) / Lifetime);
                ages[i * 2] = new Vector2(age, 0f);
                ages[i * 2 + 1] = new Vector2(age, 0f);

                if (i == 0)
                {
                    bounds = new Bounds(root, Vector3.zero);
                }
                else
                {
                    bounds.Encapsulate(root);
                }
                bounds.Encapsulate(tip);
            }

            ribbon.SetVertices(positions);
            ribbon.SetUVs(1, ages);
            ribbon.SetSubMesh(0, new SubMeshDescriptor(0, Mathf.Max(0, count - 1) * 6), MeshUpdateFlags.DontRecalculateBounds | MeshUpdateFlags.DontValidateIndices);
            ribbon.bounds = bounds;
        }
    }
}
