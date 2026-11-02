using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>Adds a Shoot button. Shots need physics, so it only works in Play mode.</summary>
    [CustomEditor(typeof(VfxProjectileShooter))]
    public class VfxProjectileShooterEditor : UnityEditor.Editor
    {
        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            EditorGUILayout.Space();

            if (!Application.isPlaying)
            {
                EditorGUILayout.HelpBox("Enter Play mode to shoot.", MessageType.Info);
            }

            using (new EditorGUI.DisabledScope(!Application.isPlaying))
            {
                if (GUILayout.Button("Shoot"))
                {
                    ((VfxProjectileShooter)target).Shoot();
                }
            }
        }
    }
}
