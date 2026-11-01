using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>
    /// Base inspector for every effect: embeds the preset for live tuning and adds Play / Stop / Replay
    /// buttons that work outside Play mode. Subclass this only for effect-specific controls.
    /// </summary>
    [CustomEditor(typeof(VfxEffect), true)]
    public class VfxEffectEditor : UnityEditor.Editor
    {
        private UnityEditor.Editor presetEditor;

        private VfxEffect Effect => (VfxEffect)target;

        protected virtual void OnDisable()
        {
            DestroyImmediate(presetEditor);
        }

        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            DrawPreset();
            EditorGUILayout.Space();
            DrawTransport();
        }

        private void DrawPreset()
        {
            if (Effect.Preset == null)
            {
                EditorGUILayout.HelpBox("Assign a preset to tune this effect.", MessageType.Info);
                return;
            }

            CreateCachedEditor(Effect.Preset, null, ref presetEditor);
            EditorGUILayout.Space();
            EditorGUILayout.LabelField(Effect.Preset.name, EditorStyles.boldLabel);

            EditorGUI.BeginChangeCheck();
            presetEditor.OnInspectorGUI();
            if (EditorGUI.EndChangeCheck())
            {
                Effect.ApplyParameters();
                VfxEditorPreview.RepaintViews();
            }
        }

        private void DrawTransport()
        {
            // A prefab asset is not in a scene, so a preview has nothing to run on.
            using (new EditorGUI.DisabledScope(Effect.Preset == null || EditorUtility.IsPersistent(Effect)))
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button(Effect.IsPlaying ? "Replay" : "Play"))
                {
                    if (Application.isPlaying)
                    {
                        Effect.Play();
                    }
                    else
                    {
                        VfxEditorPreview.Play(Effect);
                    }
                }

                using (new EditorGUI.DisabledScope(!Effect.IsPlaying))
                {
                    if (GUILayout.Button("Stop"))
                    {
                        Effect.Stop();
                    }
                }
            }

            EditorGUILayout.LabelField("State", $"{Effect.State}  ({Effect.EffectTime:0.00}s)");
        }

        public override bool RequiresConstantRepaint()
        {
            return Effect.IsPlaying;
        }
    }
}
