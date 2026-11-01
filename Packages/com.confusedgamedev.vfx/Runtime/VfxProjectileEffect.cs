using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Base for projectiles. They fly along transform.forward until the game calls Hit on contact, then
    /// end with an impact. Keep calling Tick (Update does this in Play mode) until the effect finishes.
    /// </summary>
    public abstract class VfxProjectileEffect : VfxEffect
    {
        private static readonly int ParticleCountId = Shader.PropertyToID("_ParticleCount");
        private static readonly int ImpactUpId = Shader.PropertyToID("_ImpactUp");
        private static readonly int ImpactId = Shader.PropertyToID("_Impact");

        [SerializeField] private Renderer impactRenderer;
        [SerializeField] private Renderer glowRenderer;

        private Vector3 impactUp = Vector3.up;
        private float travelSpeed;

        protected bool Impacted { get; private set; }

        protected bool IsTraveling => travelSpeed > 0f;

        protected abstract int MaxParticles { get; }

        /// <summary>The leading surface in local space right now, including the start-up deformation.</summary>
        protected abstract Vector3 CurrentContact(VfxPreset parameters);

        /// <summary>Aims the projectile and sets its travel speed in units per second. 0 leaves movement to the game.</summary>
        public void SetDirection(Vector3 direction, float speed = 4f)
        {
            if (!IsPlaying || State == VfxState.Stopping || direction.sqrMagnitude <= 0f)
            {
                return;
            }

            transform.rotation = Quaternion.LookRotation(direction);
            travelSpeed = Mathf.Max(0f, speed);
        }

        /// <summary>
        /// Ends the projectile with its impact. Without a point it bursts at its leading surface; with one,
        /// the projectile moves so that surface sits on the contact. The normal defaults to facing back along flight.
        /// </summary>
        public void Hit(Vector3? worldPoint = null, Vector3? worldNormal = null)
        {
            if (State != VfxState.Playing)
            {
                return;
            }

            Vector3 contact = CurrentContact(ActiveParameters);

            if (worldPoint.HasValue)
            {
                transform.position = worldPoint.Value - transform.rotation * Vector3.Scale(contact, transform.lossyScale);
            }

            Vector3 normal = worldNormal ?? -transform.forward;
            if (normal.sqrMagnitude < 1e-10f)
            {
                normal = -transform.forward;
            }

            Transform impact = impactRenderer.transform;
            impact.localPosition = contact;
            impact.rotation = Quaternion.FromToRotation(Vector3.forward, normal.normalized);
            glowRenderer.transform.localPosition = contact;

            // Swapped to the source's axes, which the impact shaders work in.
            Vector3 localUp = impact.InverseTransformDirection(Vector3.up);
            impactUp = new Vector3(localUp.z, localUp.y, localUp.x);

            Impacted = true;
            Stop();
        }

        protected override void OnPlay()
        {
            Impacted = false;
            travelSpeed = 0f;
            impactUp = Vector3.up;
            SetImpactVisible(false, false);
        }

        protected override void OnTick(float deltaTime)
        {
            if (State == VfxState.Playing && travelSpeed > 0f)
            {
                transform.position += transform.forward * (deltaTime * travelSpeed);
            }

            bool ending = Impacted && State == VfxState.Stopping;
            SetImpactVisible(ending, ending && EndProgress < 0.28f);
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            block.SetFloat(ParticleCountId, ParticleCount(parameters));
            block.SetVector(ImpactUpId, impactUp);
            block.SetFloat(ImpactId, Impacted ? 1f : 0f);
        }

        protected virtual int ParticleCount(VfxPreset parameters)
        {
            return Mathf.Max(1, Mathf.RoundToInt(MaxParticles * parameters.density));
        }

        private void SetImpactVisible(bool impact, bool glow)
        {
            if (impactRenderer != null)
            {
                impactRenderer.enabled = impact;
            }

            if (glowRenderer != null)
            {
                glowRenderer.enabled = glow;
            }
        }
    }
}
