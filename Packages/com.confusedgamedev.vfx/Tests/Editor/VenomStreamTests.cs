using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class VenomStreamTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<VenomStreamPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("ACDC6F"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.25f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.7f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitThePool()
        {
            var root = new GameObject("Beam");
            var effect = root.AddComponent<VenomStreamEffect>();

            Assert.That(effect.LayerCounts(0.5f), Is.EqualTo(new Vector2Int(256, 0)));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Body_HasEveryPiece()
        {
            Mesh mesh = VenomStreamMeshes.CreateBody();

            int slugs = 16 * 11 * 8;
            int droplets = 5 * 8 * 6;
            int tongues = 5 * (6 * 8 * 6 + 6 * 6);
            int drops = 5 * 9 * 7;
            Assert.That(mesh.vertexCount, Is.EqualTo(slugs + droplets + tongues + drops));
            Assert.That(mesh.normals.Length, Is.EqualTo(mesh.vertexCount));

            Object.DestroyImmediate(mesh);
        }
    }
}
