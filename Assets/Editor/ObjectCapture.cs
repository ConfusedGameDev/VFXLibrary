using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;

/// <summary>
/// Renders every imported object once, framed on its bounds. Run with -executeMethod ObjectCapture.Run.
/// Environment: VFX_CAPTURE_DIR is the output folder, VFX_OBJECT an optional comma-separated filter.
/// </summary>
public static class ObjectCapture
{
    private const string Root = "Packages/com.confusedgamedev.vfx/Runtime/Objects";
    private const int Size = 512;

    public static void Run()
    {
        string folder = Environment.GetEnvironmentVariable("VFX_CAPTURE_DIR");
        string filter = Environment.GetEnvironmentVariable("VFX_OBJECT");
        Directory.CreateDirectory(folder);

        Scene scene = EditorSceneManager.NewPreviewScene();

        var lightObject = new GameObject("Light");
        SceneManager.MoveGameObjectToScene(lightObject, scene);
        var light = lightObject.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 2f;
        light.shadows = LightShadows.Soft;
        lightObject.transform.rotation = Quaternion.Euler(50f, -30f, 0f);

        var cameraObject = new GameObject("Camera");
        SceneManager.MoveGameObjectToScene(cameraObject, scene);
        var camera = cameraObject.AddComponent<Camera>();
        camera.scene = scene;
        camera.clearFlags = CameraClearFlags.SolidColor;
        camera.backgroundColor = new Color(0.34f, 0.37f, 0.41f);
        camera.fieldOfView = 30f;
        cameraObject.AddComponent<UniversalAdditionalCameraData>().renderPostProcessing = false;

        var target = new RenderTexture(Size, Size, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
        camera.targetTexture = target;

        foreach (string guid in AssetDatabase.FindAssets("t:Prefab", new[] { Root }))
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            string name = Path.GetFileNameWithoutExtension(path);
            if (!string.IsNullOrEmpty(filter) && Array.IndexOf(filter.Split(','), name) < 0)
            {
                continue;
            }

            var instance = (GameObject)UnityEngine.Object.Instantiate(AssetDatabase.LoadAssetAtPath<GameObject>(path));
            SceneManager.MoveGameObjectToScene(instance, scene);
            Bounds bounds = instance.GetComponent<Renderer>().bounds;
            float distance = bounds.extents.magnitude / Mathf.Sin(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
            camera.nearClipPlane = Mathf.Max(0.01f, distance * 0.05f);
            camera.farClipPlane = distance * 4f;
            camera.transform.position = bounds.center + Quaternion.Euler(18f, 150f, 0f) * Vector3.forward * distance;
            camera.transform.LookAt(bounds.center);
            Save(camera, target, folder, name);
            UnityEngine.Object.DestroyImmediate(instance);
        }

        camera.targetTexture = null;
        UnityEngine.Object.DestroyImmediate(target);
        EditorSceneManager.ClosePreviewScene(scene);
        Debug.Log("ObjectCapture finished: " + Path.GetFullPath(folder));
    }

    private static void Save(Camera camera, RenderTexture target, string folder, string name)
    {
        camera.Render();

        RenderTexture.active = target;
        var image = new Texture2D(Size, Size, TextureFormat.RGB24, false);
        image.ReadPixels(new Rect(0, 0, Size, Size), 0, 0);
        image.Apply();
        RenderTexture.active = null;

        File.WriteAllBytes(Path.Combine(folder, name + ".png"), image.EncodeToPNG());
        UnityEngine.Object.DestroyImmediate(image);
    }
}
