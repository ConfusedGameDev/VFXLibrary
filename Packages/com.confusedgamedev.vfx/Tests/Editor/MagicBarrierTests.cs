using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class MagicBarrierTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<MagicBarrierPreset>();

            Assert.AreEqual(VfxPlayback.Looping, preset.playback);
            Assert.AreEqual(0.5f, preset.density);
            Assert.AreEqual(0.7f, preset.startDuration);
            Assert.AreEqual(1f, preset.stopDuration);

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Shield_IsAnUpperHemisphere()
        {
            Mesh mesh = MagicBarrierMeshes.CreateShield();

            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.GreaterOrEqual(vertex.y, -0.0001f);
                Assert.AreEqual(1.85f, vertex.magnitude, 0.0001f);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
