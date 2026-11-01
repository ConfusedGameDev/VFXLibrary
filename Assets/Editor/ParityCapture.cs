using System;
using System.IO;
using ConfusedGameDev.Vfx;
using ConfusedGameDev.Vfx.Editor;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Renders the fireball at fixed moments for comparison with the site, with no tonemapping or bloom.
/// Run with -executeMethod ParityCapture.Run. VFX_CAPTURE_DIR sets the output folder.
/// </summary>
public static class ParityCapture
{
    private const float Step = 1f / 60f;
    private const int Width = 960;
    private const int Height = 540;

    public static void Run()
    {
        FireballAssetBuilder.Build();

        string folder = Environment.GetEnvironmentVariable("VFX_CAPTURE_DIR");
        folder = string.IsNullOrEmpty(folder) ? "Logs/Parity" : folder;
        Directory.CreateDirectory(folder);

        EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        var cameraObject = new GameObject("Camera");
        var camera = cameraObject.AddComponent<Camera>();
        camera.clearFlags = CameraClearFlags.SolidColor;
        camera.backgroundColor = new Color(0.03f, 0.03f, 0.05f);
        camera.fieldOfView = 35f;
        camera.nearClipPlane = 0.1f;
        camera.transform.position = new Vector3(6.5f, 0.6f, -0.6f);
        camera.transform.LookAt(new Vector3(0f, 0f, -0.6f));
        cameraObject.AddComponent<UniversalAdditionalCameraData>().renderPostProcessing = false;

        var target = new RenderTexture(Width, Height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
        camera.targetTexture = target;

        var prefab = AssetDatabase.LoadAssetAtPath<FireballEffect>(FireballAssetBuilder.PrefabPath);
        FireballEffect effect = UnityEngine.Object.Instantiate(prefab);

        effect.Play();
        Advance(effect, 0.15f);
        Save(camera, target, folder, "1_starting");
        Advance(effect, 1.35f);
        Save(camera, target, folder, "2_steady");
        effect.Stop();
        Advance(effect, 0.25f);
        Save(camera, target, folder, "3_ending");

        effect.Play();
        Advance(effect, 1.5f);
        effect.Hit();
        Advance(effect, 0.1f);
        Save(camera, target, folder, "4_impact_early");
        Advance(effect, 0.2f);
        Save(camera, target, folder, "5_impact_late");

        Debug.Log("ParityCapture finished: " + Path.GetFullPath(folder));
    }

    private static void Advance(VfxEffect effect, float seconds)
    {
        for (float elapsed = 0f; elapsed < seconds; elapsed += Step)
        {
            effect.Tick(Step);
        }
    }

    private static void Save(Camera camera, RenderTexture target, string folder, string name)
    {
        camera.Render();

        RenderTexture.active = target;
        var image = new Texture2D(Width, Height, TextureFormat.RGB24, false);
        image.ReadPixels(new Rect(0, 0, Width, Height), 0, 0);
        image.Apply();
        RenderTexture.active = null;

        File.WriteAllBytes(Path.Combine(folder, name + ".png"), image.EncodeToPNG());
        UnityEngine.Object.DestroyImmediate(image);
    }
}
