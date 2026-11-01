using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    /// <summary>
    /// Runs effects outside Play mode, whether or not they are selected. The menu toggle loops every
    /// effect in the open scenes, and the inspector's Play button previews one until it finishes.
    /// </summary>
    [InitializeOnLoad]
    public static class VfxEditorPreview
    {
        private const string MenuPath = "Tools/ConfusedGameDev/VFX/Preview All Effects In Edit Mode";
        private const string EnabledKey = "ConfusedGameDev.Vfx.PreviewAll";
        private const double ScanInterval = 0.5;

        private static readonly HashSet<VfxEffect> Previewing = new HashSet<VfxEffect>();
        private static readonly List<VfxEffect> Finished = new List<VfxEffect>();

        private static double lastTickTime;
        private static double nextScanTime;

        static VfxEditorPreview()
        {
            lastTickTime = EditorApplication.timeSinceStartup;
            EditorApplication.update += Tick;
            EditorApplication.playModeStateChanged += OnPlayModeChanged;
            EditorSceneManager.sceneSaving += (scene, path) => RestoreScene();
            AssemblyReloadEvents.beforeAssemblyReload += RestoreScene;
        }

        /// <summary>True while every effect in the open scenes loops.</summary>
        public static bool PreviewAll
        {
            get => EditorPrefs.GetBool(EnabledKey, false);
            set
            {
                EditorPrefs.SetBool(EnabledKey, value);
                nextScanTime = 0;
                if (!value)
                {
                    StopAll();
                }
            }
        }

        /// <summary>Starts one effect, which runs even when it is not selected.</summary>
        public static void Play(VfxEffect effect)
        {
            Previewing.Add(effect);
            effect.Play();
        }

        public static void RepaintViews()
        {
            EditorApplication.QueuePlayerLoopUpdate();
            SceneView.RepaintAll();
        }

        [MenuItem(MenuPath)]
        private static void TogglePreviewAll()
        {
            PreviewAll = !PreviewAll;
        }

        [MenuItem(MenuPath, true)]
        private static bool ValidateTogglePreviewAll()
        {
            Menu.SetChecked(MenuPath, PreviewAll);
            return !EditorApplication.isPlayingOrWillChangePlaymode;
        }

        private static void Tick()
        {
            double now = EditorApplication.timeSinceStartup;
            float deltaTime = (float)(now - lastTickTime);
            lastTickTime = now;

            if (EditorApplication.isPlayingOrWillChangePlaymode || EditorApplication.isCompiling)
            {
                return;
            }

            if (PreviewAll && now >= nextScanTime)
            {
                nextScanTime = now + ScanInterval;
                StartSceneEffects();
            }

            if (Previewing.Count == 0)
            {
                return;
            }

            Finished.Clear();
            foreach (VfxEffect effect in Previewing)
            {
                if (effect == null || !effect.isActiveAndEnabled)
                {
                    Finished.Add(effect);
                    continue;
                }

                effect.Tick(deltaTime);
                if (effect.IsPlaying)
                {
                    continue;
                }

                if (PreviewAll)
                {
                    effect.Play();
                }
                else
                {
                    Finished.Add(effect);
                }
            }

            foreach (VfxEffect effect in Finished)
            {
                Previewing.Remove(effect);
                if (effect != null)
                {
                    effect.EndEditPreview();
                }
            }

            RepaintViews();
        }

        private static void StartSceneEffects()
        {
            foreach (VfxEffect effect in Object.FindObjectsByType<VfxEffect>(FindObjectsInactive.Exclude))
            {
                if (!Previewing.Contains(effect) && effect.Preset != null)
                {
                    Play(effect);
                }
            }
        }

        private static void StopAll()
        {
            foreach (VfxEffect effect in Previewing)
            {
                if (effect != null)
                {
                    effect.Stop(true);
                    effect.EndEditPreview();
                }
            }

            Previewing.Clear();
            RepaintViews();
        }

        // The preview resumes on the next scan, or the next press of Play.
        private static void RestoreScene()
        {
            StopAll();
        }

        private static void OnPlayModeChanged(PlayModeStateChange change)
        {
            if (change == PlayModeStateChange.ExitingEditMode)
            {
                StopAll();
            }
        }
    }
}
