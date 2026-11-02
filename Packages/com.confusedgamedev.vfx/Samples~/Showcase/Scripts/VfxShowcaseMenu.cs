using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UIElements;

namespace ConfusedGameDev.Vfx.Showcase
{
    /// <summary>Lists the categories, then the items of the open one. Tab hides and shows it.</summary>
    [RequireComponent(typeof(UIDocument))]
    public sealed class VfxShowcaseMenu : MonoBehaviour
    {
        private const float PanelWidth = 320f;

        private static readonly Color PanelColor = new Color(0.08f, 0.08f, 0.09f);
        private static readonly Color ButtonColor = new Color(0.2f, 0.2f, 0.23f);
        private static readonly Color Selected = new Color(1f, 0.55f, 0.1f);

        [SerializeField] private VfxShowcaseHall hall;

        private VisualElement panel;
        private VisualElement categoryList;
        private ScrollView itemList;

        private void OnEnable()
        {
            VisualElement root = GetComponent<UIDocument>().rootVisualElement;
            root.Clear();

            panel = new VisualElement();
            panel.style.position = Position.Absolute;
            panel.style.left = 0f;
            panel.style.top = 0f;
            panel.style.bottom = 0f;
            panel.style.width = PanelWidth;
            panel.style.paddingLeft = panel.style.paddingRight = 10f;
            panel.style.paddingTop = panel.style.paddingBottom = 10f;
            panel.style.backgroundColor = PanelColor;
            root.Add(panel);

            categoryList = new VisualElement();
            panel.Add(categoryList);

            itemList = new ScrollView { style = { flexGrow = 1f, marginTop = 8f } };
            panel.Add(itemList);

            panel.Add(Styled(new Button(hall.ReplayAll) { text = "Replay all" }, false));
            var hint = new Label("Tab: menu   WASD/QE: move   Right-drag: look   Middle-drag: pan   Shift: fast");
            hint.style.color = Color.gray;
            hint.style.whiteSpace = WhiteSpace.Normal;
            panel.Add(hint);

            OpenCategory(0);
        }

        private void Update()
        {
            Keyboard keyboard = Keyboard.current;
            if (keyboard != null && keyboard.tabKey.wasPressedThisFrame)
            {
                bool hidden = panel.style.display == DisplayStyle.None;
                panel.style.display = hidden ? DisplayStyle.Flex : DisplayStyle.None;
            }
        }

        /// <summary>Spawns a category's bays and lists its items.</summary>
        public void OpenCategory(int index)
        {
            hall.Show(index);
            BuildCategories(index);

            itemList.Clear();
            VfxShowcaseCategory category = hall.Catalog.categories[index];
            for (int i = 0; i < category.items.Count; i++)
            {
                int bay = i;
                itemList.Add(Styled(new Button(() => hall.Focus(bay)) { text = $"{index + 1}.{i + 1}  {category.items[i].name}" }, false));
            }
        }

        private static Button Styled(Button button, bool selected)
        {
            button.style.backgroundColor = selected ? Selected : ButtonColor;
            button.style.color = selected ? Color.black : Color.white;
            button.style.unityTextAlign = TextAnchor.MiddleLeft;
            button.style.borderTopWidth = button.style.borderBottomWidth = 0f;
            button.style.borderLeftWidth = button.style.borderRightWidth = 0f;
            return button;
        }

        private void BuildCategories(int open)
        {
            categoryList.Clear();
            bool? objects = null;

            for (int i = 0; i < hall.Catalog.categories.Count; i++)
            {
                VfxShowcaseCategory category = hall.Catalog.categories[i];
                if (objects != category.objects)
                {
                    objects = category.objects;
                    var heading = new Label(category.objects ? "OBJECTS" : "EFFECTS");
                    heading.style.color = Selected;
                    heading.style.unityFontStyleAndWeight = FontStyle.Bold;
                    heading.style.marginTop = 6f;
                    categoryList.Add(heading);
                }

                int index = i;
                categoryList.Add(Styled(new Button(() => OpenCategory(index)) { text = $"{i + 1}  {category.name} ({category.items.Count})" }, i == open));
            }
        }
    }
}
