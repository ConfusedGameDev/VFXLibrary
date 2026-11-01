using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Recycles instances of one effect prefab, so spawning does not allocate during gameplay.</summary>
    public sealed class VfxPool
    {
        private readonly VfxEffect prefab;
        private readonly Transform parent;
        private readonly Stack<VfxEffect> available;

        public VfxPool(VfxEffect prefab, int prewarmCount = 0, Transform parent = null)
        {
            this.prefab = prefab;
            this.parent = parent;
            available = new Stack<VfxEffect>(prewarmCount);

            for (int i = 0; i < prewarmCount; i++)
            {
                Release(Create());
            }
        }

        public int AvailableCount => available.Count;

        /// <summary>Takes an instance from the pool, or creates one when empty, and plays it.</summary>
        public VfxEffect Spawn(Vector3 position, Quaternion rotation)
        {
            VfxEffect effect = available.Count > 0 ? available.Pop() : Create();
            effect.transform.SetPositionAndRotation(position, rotation);
            effect.gameObject.SetActive(true);
            effect.Play();
            return effect;
        }

        /// <summary>Hides an instance and returns it to the pool.</summary>
        public void Release(VfxEffect effect)
        {
            effect.gameObject.SetActive(false);
            available.Push(effect);
        }

        private VfxEffect Create()
        {
            VfxEffect effect = Object.Instantiate(prefab, parent);
            effect.ownerPool = this;
            return effect;
        }
    }
}
