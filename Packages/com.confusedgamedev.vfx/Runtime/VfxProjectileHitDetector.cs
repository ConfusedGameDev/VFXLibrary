using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Add to a projectile to end it on the first collider in its path. Sweeps instead of using physics
    /// callbacks, so the projectile needs no collider or Rigidbody and the hit carries a point and normal.
    /// </summary>
    [DisallowMultipleComponent]
    public sealed class VfxProjectileHitDetector : MonoBehaviour
    {
        [SerializeField] private LayerMask hitLayers = ~0;
        [SerializeField, Min(0f)] private float radius = 0.1f;

        private VfxProjectileEffect effect;
        private Vector3 lastPosition;

        private void Awake()
        {
            effect = GetComponent<VfxProjectileEffect>();
            if (effect == null)
            {
                Debug.LogError($"{nameof(VfxProjectileHitDetector)} needs a projectile effect on {name}.", this);
                enabled = false;
            }
        }

        private void OnEnable()
        {
            lastPosition = transform.position;
        }

        // Effects move in Update, so this sees the full step.
        private void LateUpdate()
        {
            Sweep();
        }

        /// <summary>Checks the path since the last sweep, up to the leading surface, and calls Hit on contact.</summary>
        public void Sweep()
        {
            Vector3 position = transform.position;
            float moved = Vector3.Distance(lastPosition, position);
            lastPosition = position;

            if (effect == null || effect.State != VfxState.Playing)
            {
                return;
            }

            // The leading surface sits ahead of the transform, and Hit expects it to land on the contact.
            Vector3 forward = transform.forward;
            float reach = Mathf.Max(0f, Vector3.Dot(effect.ContactPosition - position, forward));
            Vector3 origin = position - forward * moved;

            if (Physics.SphereCast(origin, radius, forward, out RaycastHit hit, moved + reach, hitLayers, QueryTriggerInteraction.Ignore))
            {
                effect.Hit(hit.point, hit.normal);
            }
        }
    }
}
