using System.Collections;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Test tool that fires a projectile prefab from its shoot point along that point's forward, from the
    /// inspector's Shoot button or from code. Add a VfxProjectileHitDetector to the prefab so shots hit what they reach.
    /// </summary>
    public sealed class VfxProjectileShooter : MonoBehaviour
    {
        [SerializeField] private VfxProjectileEffect projectile;
        [Tooltip("Where shots leave, such as the end of a barrel. Empty uses this transform.")]
        [SerializeField] private Transform shootPoint;
        [Tooltip("Multiplies each shot's scale. Projectiles are built about 2 units long, so use less on small weapons.")]
        [SerializeField, Min(0.01f)] private float shotScale = 1f;
        [Tooltip("Units per second.")]
        [SerializeField, Min(0.01f)] private float speed = 4f;
        [Tooltip("Seconds before a shot that hit nothing ends without an impact.")]
        [SerializeField, Min(0f)] private float maxLifetime = 5f;

        /// <summary>The prefab each shot is made from.</summary>
        public VfxProjectileEffect Projectile
        {
            get => projectile;
            set => projectile = value;
        }

        /// <summary>Where shots leave. Null uses this transform.</summary>
        public Transform ShootPoint
        {
            get => shootPoint;
            set => shootPoint = value;
        }

        /// <summary>Multiplies each shot's scale.</summary>
        public float ShotScale
        {
            get => shotScale;
            set => shotScale = Mathf.Max(0.01f, value);
        }

        public VfxProjectileEffect Shoot()
        {
            if (projectile == null)
            {
                Debug.LogWarning($"{name} has no projectile to shoot.", this);
                return null;
            }

            Transform origin = shootPoint != null ? shootPoint : transform;
            VfxProjectileEffect shot = Instantiate(projectile, origin.position, origin.rotation);
            shot.transform.localScale *= shotScale;
            shot.onFinished.AddListener(() => Destroy(shot.gameObject));

            if (!shot.IsPlaying)
            {
                shot.Play();
            }

            shot.SetDirection(origin.forward, speed);
            StartCoroutine(ExpireAfterLifetime(shot));
            return shot;
        }

        private IEnumerator ExpireAfterLifetime(VfxProjectileEffect shot)
        {
            yield return new WaitForSeconds(maxLifetime);

            if (shot != null && shot.State == VfxState.Playing)
            {
                shot.Stop();
            }
        }
    }
}
