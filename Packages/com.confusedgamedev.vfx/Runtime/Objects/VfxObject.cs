using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// A baked game object from the object collection. Recolours its three palette roles, and lists
    /// its fire points. Colours stay on the shared materials until they differ from the defaults.
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public sealed class VfxObject : MonoBehaviour
    {
        private static readonly int BaseColorId = Shader.PropertyToID("_BaseColor");
        private static readonly int PrimaryId = Shader.PropertyToID("_Primary");
        private static readonly int SecondaryId = Shader.PropertyToID("_Secondary");
        private static readonly int AccentId = Shader.PropertyToID("_Accent");

        [SerializeField] private Color primary = Color.white;
        [SerializeField] private Color secondary = Color.white;
        [SerializeField] private Color accent = Color.white;

        [SerializeField, HideInInspector] private Color defaultPrimary = Color.white;
        [SerializeField, HideInInspector] private Color defaultSecondary = Color.white;
        [SerializeField, HideInInspector] private Color defaultAccent = Color.white;

        // Which palette role each material slot paints. Empty on vegetation, whose one material takes all three.
        [SerializeField, HideInInspector] private int[] slotRoles = System.Array.Empty<int>();
        [SerializeField] private Transform[] firePoints = System.Array.Empty<Transform>();

        private MeshRenderer target;
        private MaterialPropertyBlock block;

        public Color Primary => primary;

        public Color Secondary => secondary;

        public Color Accent => accent;

        /// <summary>Muzzles, in the order the source lists them. Their +Z is the firing direction.</summary>
        public Transform[] FirePoints => firePoints;

        public bool UsesDefaultColors => primary == defaultPrimary && secondary == defaultSecondary && accent == defaultAccent;

        public void SetColors(Color newPrimary, Color newSecondary, Color newAccent)
        {
            primary = newPrimary;
            secondary = newSecondary;
            accent = newAccent;
            ApplyColors();
        }

        public void ResetColors()
        {
            SetColors(defaultPrimary, defaultSecondary, defaultAccent);
        }

        /// <summary>Finds a fire point by its source id, such as "left-barrel".</summary>
        public Transform FindFirePoint(string id)
        {
            foreach (Transform point in firePoints)
            {
                if (point != null && point.name == id)
                {
                    return point;
                }
            }
            return null;
        }

        public void ApplyColors()
        {
            if (target == null && !TryGetComponent(out target))
            {
                return;
            }

            if (UsesDefaultColors)
            {
                target.SetPropertyBlock(null);
                for (int slot = 0; slot < slotRoles.Length; slot++)
                {
                    target.SetPropertyBlock(null, slot);
                }
                return;
            }

            block ??= new MaterialPropertyBlock();
            block.Clear();
            if (slotRoles.Length == 0)
            {
                block.SetColor(PrimaryId, primary);
                block.SetColor(SecondaryId, secondary);
                block.SetColor(AccentId, accent);
                target.SetPropertyBlock(block);
                return;
            }

            for (int slot = 0; slot < slotRoles.Length; slot++)
            {
                block.SetColor(BaseColorId, slotRoles[slot] switch { 0 => primary, 1 => secondary, _ => accent });
                target.SetPropertyBlock(block, slot);
            }
        }

        private void OnEnable()
        {
            ApplyColors();
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            ApplyColors();
        }
#endif
    }
}
