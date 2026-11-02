using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>Adds a Hit button, which ends a playing projectile with its impact in place.</summary>
    [CustomEditor(typeof(VfxProjectileEffect), true)]
    public class VfxProjectileEffectEditor : VfxEffectEditor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            var effect = (VfxProjectileEffect)target;
            using (new EditorGUI.DisabledScope(effect.State != VfxState.Playing))
            {
                if (GUILayout.Button("Hit"))
                {
                    effect.Hit();
                }
            }
        }
    }
}
