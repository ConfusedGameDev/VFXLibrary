using UnityEditor;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>Says when a weapon trail is showing the stand-in blade, or has nothing to trace.</summary>
    [CustomEditor(typeof(VfxBladeTrailEffect), true)]
    public class VfxBladeTrailEffectEditor : VfxEffectEditor
    {
        public override void OnInspectorGUI()
        {
            var effect = (VfxBladeTrailEffect)target;
            if (effect.UsesPreviewSwing)
            {
                EditorGUILayout.HelpBox("No weapon assigned, so the Editor swings a stand-in blade. A build draws nothing until it has a weapon.", MessageType.Info);
            }
            else if (!effect.HasWeapon)
            {
                EditorGUILayout.HelpBox("No weapon assigned, so this trail draws nothing.", MessageType.Warning);
            }

            base.OnInspectorGUI();
        }
    }
}
