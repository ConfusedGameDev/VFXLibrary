using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Base for beams. A beam is centred on the transform and lies along transform.forward. Its length
    /// is the root's Z scale, the source's group scale, so both end points stay fixed while it animates.
    /// With both emitters assigned the beam runs from A to B every frame, and can stop at the first collider.
    /// </summary>
    public abstract class VfxBeamEffect : VfxEffect
    {
        /// <summary>The length the meshes are built at.</summary>
        public const float BaseLength = 4.8f;

        private const float MinimumLength = 0.001f;

        private static readonly int ParticleCountId = Shader.PropertyToID("_ParticleCount");
        private static readonly int LayerCountsId = Shader.PropertyToID("_LayerCounts");
        private static readonly int StretchId = Shader.PropertyToID("_Stretch");
        private static readonly int EmitterTimeId = Shader.PropertyToID("_EmitterTime");

        [SerializeField, Min(MinimumLength)] private float length = BaseLength;

        [Header("Emitters")]
        [Tooltip("Where the beam starts. Needs Emitter B too. Child or scene transforms both work.")]
        [SerializeField] private Transform emitterA;
        [Tooltip("Where the beam ends, unless something blocks it.")]
        [SerializeField] private Transform emitterB;
        [Tooltip("Ends the beam on the first non-trigger collider between the emitters.")]
        [SerializeField] private bool detectHits;
        [SerializeField] private LayerMask hitLayers = ~0;

        private Vector3 lastStart;
        private Vector3 lastEnd;

        /// <summary>Distance between the end points, in units of the root's own scale.</summary>
        public float Length
        {
            get => length;
            set
            {
                length = Mathf.Max(MinimumLength, value);
                ApplyLength();
                ApplyParameters();
            }
        }

        protected abstract int MaxParticles { get; }

        /// <summary>Capacity of a second instanced layer, which takes its count from the same pool.</summary>
        protected virtual int SecondaryMaximum => 0;

        protected virtual float SecondaryWeight => 0f;

        /// <summary>Places the beam between two world positions.</summary>
        public void SetEndpoints(Vector3 start, Vector3 end)
        {
            Vector3 span = end - start;
            transform.position = (start + end) * 0.5f;
            if (span.sqrMagnitude > 0f)
            {
                transform.rotation = Quaternion.LookRotation(span);
            }

            Length = span.magnitude / transform.lossyScale.y;
        }

        /// <summary>Runs the beam between two transforms from now on, stopping at colliders if detectHits is true.</summary>
        public void SetEmitters(Transform start, Transform end, bool detectHits)
        {
            emitterA = start;
            emitterB = end;
            this.detectHits = detectHits;
            FollowEmitters();
        }

        /// <summary>Runs the beam between the emitters. LateUpdate calls this, so only call it to update sooner.</summary>
        public void FollowEmitters()
        {
            if (emitterA == null || emitterB == null)
            {
                return;
            }

#if UNITY_EDITOR
            if (IsEmitterDragged())
            {
                return;
            }
#endif

            Vector3 start = emitterA.position;
            Vector3 target = emitterB.position;
            Vector3 end = detectHits ? FirstContact(start, target) : target;

            if (start == lastStart && end == lastEnd && transform.position == (start + end) * 0.5f)
            {
                return;
            }

            lastStart = start;
            lastEnd = end;
            SetEndpoints(start, end);

            // Child emitters move with the root, and must stay put when a hit shortens the beam.
            emitterA.position = start;
            emitterB.position = target;
        }

        /// <summary>Instances of the particle and second layers at a density, as the source splits its pool.</summary>
        public Vector2Int LayerCounts(float density)
        {
            int desired = Mathf.Max(1, RoundHalfUp(MaxParticles * density));
            int secondary = Mathf.Min(SecondaryMaximum, RoundHalfUp(desired * SecondaryWeight));
            return new Vector2Int(desired - secondary, secondary);
        }

        protected override void OnEnable()
        {
            FollowEmitters();
            ApplyLength();
            base.OnEnable();
        }

        protected override void Update()
        {
            ApplyLength();
            base.Update();
        }

        private void LateUpdate()
        {
            FollowEmitters();
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            Vector2Int counts = LayerCounts(parameters.density);
            block.SetFloat(ParticleCountId, counts.x);
            block.SetVector(LayerCountsId, new Vector4(counts.y, 0f, 0f, 0f));
            block.SetFloat(StretchId, length / BaseLength);
            block.SetFloat(EmitterTimeId, EffectTime - EndProgress * parameters.stopDuration);
        }

        private Vector3 FirstContact(Vector3 start, Vector3 target)
        {
            // Outside Play mode nothing else syncs colliders with their transforms.
            if (!Application.isPlaying)
            {
                Physics.SyncTransforms();
            }

            Vector3 span = target - start;
            float distance = span.magnitude;
            if (distance > 0f && Physics.Raycast(start, span / distance, out RaycastHit hit, distance, hitLayers, QueryTriggerInteraction.Ignore))
            {
                return hit.point;
            }

            return target;
        }

        private void ApplyLength()
        {
            Vector3 scale = transform.localScale;
            float z = scale.y * length / BaseLength;
            if (!Mathf.Approximately(scale.z, z))
            {
                scale.z = z;
                transform.localScale = scale;
            }
        }

        private static int RoundHalfUp(float value)
        {
            return Mathf.FloorToInt(value + 0.5f);
        }

#if UNITY_EDITOR
        // The move tool adds its drag to the local position from mouse down, so a parent that moves
        // mid-drag counts the drag again every frame. Updates keep coming so the release is seen.
        private bool IsEmitterDragged()
        {
            bool selected = UnityEditor.Selection.Contains(emitterA.gameObject) || UnityEditor.Selection.Contains(emitterB.gameObject);
            if (GUIUtility.hotControl == 0 || !selected)
            {
                return false;
            }

            UnityEditor.EditorApplication.QueuePlayerLoopUpdate();
            return true;
        }
#endif
    }
}
