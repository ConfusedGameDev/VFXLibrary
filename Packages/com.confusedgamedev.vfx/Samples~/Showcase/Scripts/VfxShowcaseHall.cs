using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Showcase
{
    /// <summary>
    /// Spawns one category's bays along both walls of the hall. Only that category exists at a time, so
    /// the hall never runs more than one category's effects together.
    /// </summary>
    public sealed class VfxShowcaseHall : MonoBehaviour
    {
        private const float BayOffset = 5f;
        private const float BaySpacing = 8f;
        private const float FirstBay = 8f;
        private const float WallOffset = 9.9f;
        private const int LineLength = 44;
        private const float ViewDistance = 6f;
        private const float HeldViewDistance = 2.5f;

        [SerializeField] private VfxShowcaseCatalog catalog;
        [SerializeField] private Material surfaceMaterial;
        [SerializeField] private Material targetMaterial;
        [SerializeField] private Material labelMaterial;
        [SerializeField] private VfxShowcaseFlyCamera flyCamera;

        private readonly List<VfxShowcaseBay> bays = new List<VfxShowcaseBay>();
        private Transform bayRoot;
        private Font font;
        private Material fontMaterial;

        public VfxShowcaseCatalog Catalog => catalog;

        public IReadOnlyList<VfxShowcaseBay> Bays => bays;

        public int CategoryIndex { get; private set; } = -1;

        public Material SurfaceMaterial => surfaceMaterial;

        public Material TargetMaterial => targetMaterial;

        public void Show(int categoryIndex)
        {
            if (bayRoot != null)
            {
                Destroy(bayRoot.gameObject);
            }

            bays.Clear();
            bayRoot = new GameObject("Bays").transform;
            bayRoot.SetParent(transform, false);
            CategoryIndex = categoryIndex;

            VfxShowcaseCategory category = catalog.categories[categoryIndex];
            for (int i = 0; i < category.items.Count; i++)
            {
                float side = i % 2 == 0 ? -1f : 1f;
                var position = new Vector3(side * BayOffset, 0f, FirstBay + i / 2 * BaySpacing);
                string number = $"{categoryIndex + 1}.{i + 1}";

                var bay = new GameObject(number).AddComponent<VfxShowcaseBay>();
                bay.transform.SetParent(bayRoot, false);
                bay.transform.localPosition = position;
                bay.Build(this, category.items[i]);
                bays.Add(bay);

                AddLabel(bay.transform, side, number, category.items[i]);
            }
        }

        /// <summary>Restarts every bay at once.</summary>
        public void ReplayAll()
        {
            foreach (VfxShowcaseBay bay in bays)
            {
                bay.Replay();
            }
        }

        /// <summary>Flies to a bay and replays it.</summary>
        public void Focus(int bayIndex)
        {
            VfxShowcaseBay bay = bays[bayIndex];
            Vector3 focus = bay.transform.position + Vector3.up * 1.2f;
            float distance = bay.Item.display == VfxShowcaseDisplay.Held ? HeldViewDistance : ViewDistance;
            float x = bay.transform.position.x;
            var view = new Vector3(x - Mathf.Sign(x) * distance, 2.2f, bay.transform.position.z);
            flyCamera.Glide(view, Quaternion.LookRotation(focus - view));
            bay.Replay();
        }

        private void AddLabel(Transform bay, float side, string number, VfxShowcaseItem item)
        {
            var label = new GameObject("Label").transform;
            label.SetParent(bay, false);
            label.position = new Vector3(side * WallOffset, 3.4f, bay.position.z);
            label.rotation = Quaternion.LookRotation(Vector3.right * side);

            AddText(label, number, Vector3.up * 0.9f, 0.09f, new Color(1f, 0.55f, 0.1f));
            AddText(label, item.name, Vector3.zero, 0.04f, Color.white);
            AddText(label, Wrap(item.description), Vector3.down * 0.5f, 0.02f, new Color(0.8f, 0.8f, 0.8f));
        }

        private void AddText(Transform parent, string text, Vector3 offset, float size, Color color)
        {
            if (font == null)
            {
                font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
                fontMaterial = new Material(labelMaterial) { mainTexture = font.material.mainTexture };
            }

            var mesh = new GameObject("Text").AddComponent<TextMesh>();
            mesh.transform.SetParent(parent, false);
            mesh.transform.localPosition = offset;
            mesh.font = font;
            mesh.fontSize = 64;
            mesh.characterSize = size;
            mesh.anchor = TextAnchor.UpperCenter;
            mesh.alignment = TextAlignment.Center;
            mesh.color = color;
            mesh.text = text;
            mesh.GetComponent<MeshRenderer>().sharedMaterial = fontMaterial;
        }

        // TextMesh does not wrap by itself.
        private static string Wrap(string text)
        {
            var wrapped = new StringBuilder();
            int line = 0;
            foreach (string word in (text ?? string.Empty).Split(' '))
            {
                if (line > 0 && line + word.Length > LineLength)
                {
                    wrapped.Append('\n');
                    line = 0;
                }
                else if (line > 0)
                {
                    wrapped.Append(' ');
                    line++;
                }

                wrapped.Append(word);
                line += word.Length;
            }
            return wrapped.ToString();
        }

        private void OnDestroy()
        {
            if (fontMaterial != null)
            {
                Destroy(fontMaterial);
            }
        }
    }
}
