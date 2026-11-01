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
        private double lastTickTime;

        private VfxEffect Effect => (VfxEffect)target;

        protected virtual void OnEnable()
        {
            lastTickTime = EditorApplication.timeSinceStartup;
            EditorApplication.update += TickPreview;
        }

        protected virtual void OnDisable()
        {
            EditorApplication.update -= TickPreview;
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
                RepaintViews();
            }
        }

        private void DrawTransport()
        {
            using (new EditorGUI.DisabledScope(Effect.Preset == null))
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button(Effect.IsPlaying ? "Replay" : "Play"))
                {
                    Effect.Play();
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

        private void TickPreview()
        {
            double now = EditorApplication.timeSinceStartup;
            float deltaTime = (float)(now - lastTickTime);
            lastTickTime = now;

            if (target == null || Application.isPlaying || !Effect.IsPlaying)
            {
                return;
            }

            Effect.Tick(deltaTime);
            RepaintViews();
            Repaint();
        }

        private static void RepaintViews()
        {
            EditorApplication.QueuePlayerLoopUpdate();
            SceneView.RepaintAll();
        }
    }
}
