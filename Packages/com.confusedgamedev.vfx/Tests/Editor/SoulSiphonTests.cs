using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class SoulSiphonTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<SoulSiphonPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("A883E8"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.35f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.65f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitThePool()
        {
            var root = new GameObject("Beam");
            var effect = root.AddComponent<SoulSiphonEffect>();

            Assert.That(effect.LayerCounts(0.5f), Is.EqualTo(new Vector2Int(256, 0)));

            Object.DestroyImmediate(root);
        }

        [Test]
        public void Body_HasEveryPiece()
        {
            Mesh mesh = SoulSiphonMeshes.CreateBody();

            int strands = 3 * 37 * 6;
            int orbs = 18 * (6 * 9 + 2 * 6);
            int arcs = 10 * (4 * (4 * 6) + 6 + 6) * 1;
            Assert.That(mesh.vertexCount, Is.EqualTo(strands + orbs + arcs));
            Assert.That(mesh.normals.Length, Is.EqualTo(mesh.vertexCount));

            Object.DestroyImmediate(mesh);
        }
    }
}
