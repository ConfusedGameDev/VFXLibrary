using System;
using System.IO;
using ConfusedGameDev.Vfx;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Renders each firing object side on at set moments. Run with -executeMethod FiringCapture.Run in a
/// project with no Editor open: the draws need a real scene, so it replaces the open one.
/// Environment: VFX_CAPTURE_DIR is the output folder.
/// </summary>
public static class FiringCapture
{
    private const string Root = "Packages/com.confusedgamedev.vfx/Runtime/Objects";
    private const int Width = 640;
    private const int Height = 360;
    private const float Step = 1f / 60f;

    private static readonly (string name, float[] times)[] Shots =
    {
        ("EnergyPistol", new[] { 0.06f, 0.2f }),
        ("PulseRifle", new[] { 0.08f, 0.3f }),
        ("TwinCannonTurret", new[] { 0.05f, 0.25f }),
        ("LaserTurret", new[] { 0.3f, 0.9f }),
        ("RailgunTurret", new[] { 0.4f, 0.68f }),
        ("MissileTurret", new[] { 0.5f, 1.2f }),
        ("ArcTurret", new[] { 0.35f, 1f })
    };

    public static void Run()
    {
        string folder = Environment.GetEnvironmentVariable("VFX_CAPTURE_DIR");
        Directory.CreateDirectory(folder);

        EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        var lightObject = new GameObject("Light");
        var light = lightObject.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 2f;
        lightObject.transform.rotation = Quaternion.Euler(50f, -30f, 0f);

        var camera = new GameObject("Camera").AddComponent<Camera>();
        camera.clearFlags = CameraClearFlags.SolidColor;
        camera.backgroundColor = new Color(0.05f, 0.06f, 0.08f);
        camera.fieldOfView = 30f;
        camera.gameObject.AddComponent<UniversalAdditionalCameraData>().renderPostProcessing = false;

        var target = new RenderTexture(Width, Height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
        camera.targetTexture = target;

        foreach ((string name, float[] times) in Shots)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>($"{Root}/{name}/{name}.prefab");
            var instance = (GameObject)UnityEngine.Object.Instantiate(prefab);
            var firing = instance.GetComponent<VfxObjectFiring>();

            Bounds bounds = instance.GetComponent<Renderer>().bounds;
            Transform point = instance.GetComponent<VfxObject>().FirePoints[0];
            Vector3 middle = (bounds.center + point.position + point.forward * firing.Range) * 0.5f;
            float distance = (bounds.extents.magnitude + firing.Range * 0.5f) / Mathf.Sin(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
            camera.nearClipPlane = 0.05f;
            camera.farClipPlane = distance * 3f;
            camera.transform.position = middle + Vector3.Cross(point.forward, Vector3.up).normalized * distance + Vector3.up * distance * 0.2f;
            camera.transform.LookAt(middle);

            firing.Fire();
            float elapsed = 0f;
            foreach (float time in times)
            {
                while (elapsed < time)
                {
                    firing.Tick(Step);
                    elapsed += Step;
                }

                // Queued draws last until the frame ends, and no frame ends here, so each moment gets a camera of its own.
                Camera moment = UnityEngine.Object.Instantiate(camera);
                moment.targetTexture = target;
                firing.RenderCamera = moment;
                firing.DrawFrame();
                Save(moment, target, folder, $"{name}_{time:0.00}");
                UnityEngine.Object.DestroyImmediate(moment.gameObject);
            }

            UnityEngine.Object.DestroyImmediate(instance);
        }

        camera.targetTexture = null;
        UnityEngine.Object.DestroyImmediate(target);
        Debug.Log("FiringCapture finished: " + Path.GetFullPath(folder));
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
