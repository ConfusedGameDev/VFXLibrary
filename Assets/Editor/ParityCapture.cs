using System;
using System.Globalization;
using System.IO;
using ConfusedGameDev.Vfx;
using ConfusedGameDev.Vfx.Editor;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;

/// <summary>
/// Rebuilds an effect and renders it at fixed moments for comparison with the site, with no tonemapping
/// or bloom. Run with -executeMethod ParityCapture.Run. Environment: VFX_EFFECT is the effect folder,
/// VFX_TIMES comma-separated seconds, VFX_CAPTURE_DIR the output folder, VFX_YAW an optional turn in degrees.
/// </summary>
public static class ParityCapture
{
    private const float Step = 1f / 60f;
    private const int Width = 960;
    private const int Height = 540;

    public static void Run()
    {
        string effectName = Environment.GetEnvironmentVariable("VFX_EFFECT");
        string times = Environment.GetEnvironmentVariable("VFX_TIMES") ?? "0.5,1.5";
        string folder = Environment.GetEnvironmentVariable("VFX_CAPTURE_DIR");
        folder = string.IsNullOrEmpty(folder) ? "Logs/Parity" : folder;
        Directory.CreateDirectory(folder);

        VfxAssetBuilder.Rebuild(effectName);

        // A preview scene leaves whatever is open in the Editor untouched.
        Scene scene = EditorSceneManager.NewPreviewScene();

        var cameraObject = new GameObject("Camera");
        SceneManager.MoveGameObjectToScene(cameraObject, scene);
        var camera = cameraObject.AddComponent<Camera>();
        camera.scene = scene;
        camera.clearFlags = CameraClearFlags.SolidColor;
        camera.backgroundColor = new Color(0.03f, 0.03f, 0.05f);
        camera.fieldOfView = 35f;
        camera.nearClipPlane = 0.1f;
        camera.transform.position = new Vector3(8f, 1.2f, -0.6f);
        camera.transform.LookAt(new Vector3(0f, 0f, -0.6f));
        cameraObject.AddComponent<UniversalAdditionalCameraData>().renderPostProcessing = false;

        var target = new RenderTexture(Width, Height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
        camera.targetTexture = target;

        var prefab = AssetDatabase.LoadAssetAtPath<VfxEffect>(VfxAssetBuilder.PrefabPath(effectName));
        VfxEffect effect = UnityEngine.Object.Instantiate(prefab);
        SceneManager.MoveGameObjectToScene(effect.gameObject, scene);

        float.TryParse(Environment.GetEnvironmentVariable("VFX_YAW"), NumberStyles.Float, CultureInfo.InvariantCulture, out float yaw);
        effect.transform.rotation = Quaternion.Euler(0f, yaw, 0f);

        effect.Play();
        float elapsed = 0f;
        foreach (string entry in times.Split(','))
        {
            float time = float.Parse(entry, CultureInfo.InvariantCulture);
            while (elapsed < time)
            {
                effect.Tick(Step);
                elapsed += Step;
            }
            Save(camera, target, folder, $"{effectName}_{entry}");
        }

        camera.targetTexture = null;
        UnityEngine.Object.DestroyImmediate(target);
        EditorSceneManager.ClosePreviewScene(scene);
        Debug.Log("ParityCapture finished: " + Path.GetFullPath(folder));
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
