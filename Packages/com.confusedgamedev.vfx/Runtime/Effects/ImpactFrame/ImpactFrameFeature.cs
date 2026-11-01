using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

namespace ConfusedGameDev.Vfx
{
    /// <summary>
    /// Draws ImpactFrameTrigger's sequence over the camera image. It records nothing while no trigger is
    /// showing a stage, so an idle frame costs nothing.
    /// </summary>
    [DisallowMultipleRendererFeature("Impact Frame")]
    public sealed class ImpactFrameFeature : ScriptableRendererFeature
    {
        private const string ShaderName = "ConfusedGameDev/Vfx/ImpactFrame";

        [SerializeField] private Shader shader;
        [Tooltip("Before post-processing keeps the source's order: input is linear, and tone mapping still follows.")]
        [SerializeField] private RenderPassEvent injectionPoint = RenderPassEvent.BeforeRenderingPostProcessing;

        private Material material;
        private ImpactFramePass pass;

        public override void Create()
        {
            shader = shader != null ? shader : Shader.Find(ShaderName);
            material = shader != null ? CoreUtils.CreateEngineMaterial(shader) : null;
            pass = new ImpactFramePass(material);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            Camera camera = renderingData.cameraData.camera;
            if (material == null || renderingData.cameraData.cameraType != CameraType.Game)
            {
                return;
            }

            ImpactFrameTrigger trigger = ImpactFrameTrigger.For(camera);
            if (trigger == null)
            {
                return;
            }

            pass.renderPassEvent = injectionPoint;
            pass.requiresIntermediateTexture = true;
            pass.Setup(trigger);
            renderer.EnqueuePass(pass);
        }

        protected override void Dispose(bool disposing)
        {
            CoreUtils.Destroy(material);
            material = null;
        }

        private void Reset()
        {
            shader = Shader.Find(ShaderName);
        }

        private sealed class ImpactFramePass : ScriptableRenderPass
        {
            private const int FullscreenPass = 0;
            private const int MaskPass = 1;

            private static readonly int SubjectMaskId = Shader.PropertyToID("_SubjectMask");
            private static readonly int HasSubjectId = Shader.PropertyToID("_HasSubject");
            private static readonly int ThresholdId = Shader.PropertyToID("_Threshold");
            private static readonly int SoftnessId = Shader.PropertyToID("_Softness");
            private static readonly int IntensityId = Shader.PropertyToID("_Intensity");
            private static readonly int InvertedId = Shader.PropertyToID("_Inverted");
            private static readonly int StrokeLengthId = Shader.PropertyToID("_StrokeLength");
            private static readonly int InkDensityId = Shader.PropertyToID("_InkDensity");
            private static readonly int FrameId = Shader.PropertyToID("_Frame");
            private static readonly int BackgroundSuppressionId = Shader.PropertyToID("_BackgroundSuppression");
            private static readonly int StarSizeId = Shader.PropertyToID("_StarSize");
            private static readonly int StarStrengthId = Shader.PropertyToID("_StarStrength");
            private static readonly int CenterId = Shader.PropertyToID("_Center");
            private static readonly int ResolutionId = Shader.PropertyToID("_Resolution");
            private static readonly int AttackDirectionId = Shader.PropertyToID("_AttackDirection");
            private static readonly int StarsId = Shader.PropertyToID("_Stars");
            private static readonly int ReverseStarsId = Shader.PropertyToID("_ReverseStars");

            private readonly Material material;
            private ImpactFrameTrigger trigger;

            public ImpactFramePass(Material material)
            {
                this.material = material;
            }

            public void Setup(ImpactFrameTrigger current)
            {
                trigger = current;
            }

            public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
            {
                var resources = frameData.Get<UniversalResourceData>();
                if (resources.isActiveTargetBackBuffer || !trigger.TryGetStage(out ImpactFrameStage stage))
                {
                    return;
                }

                TextureHandle source = resources.activeColorTexture;
                TextureDesc colorDesc = renderGraph.GetTextureDesc(source);

                TextureHandle mask = TextureHandle.nullHandle;
                bool hasRenderers = trigger.subjectMask == null && trigger.subjects != null && trigger.subjects.Length > 0;
                if (hasRenderers && resources.activeDepthTexture.IsValid())
                {
                    mask = RecordMask(renderGraph, resources.activeDepthTexture, colorDesc);
                }

                TextureDesc targetDesc = colorDesc;
                targetDesc.name = "_ImpactFrameColor";
                targetDesc.clearBuffer = false;
                targetDesc.depthBufferBits = DepthBits.None;
                TextureHandle target = renderGraph.CreateTexture(targetDesc);

                using (var builder = renderGraph.AddRasterRenderPass<FramePassData>("Impact Frame", out FramePassData data))
                {
                    data.source = source;
                    data.mask = mask;
                    data.externalMask = trigger.subjectMask;
                    data.material = material;
                    Fill(material, trigger, stage, colorDesc);

                    builder.UseTexture(source);
                    if (mask.IsValid())
                    {
                        builder.UseTexture(mask);
                    }

                    builder.SetRenderAttachment(target, 0);
                    builder.SetRenderFunc(static (FramePassData d, RasterGraphContext context) => ExecuteFrame(d, context));
                }

                resources.cameraColor = target;
            }

            private TextureHandle RecordMask(RenderGraph renderGraph, TextureHandle depth, TextureDesc colorDesc)
            {
                TextureDesc depthDesc = renderGraph.GetTextureDesc(depth);
                TextureDesc maskDesc = colorDesc;
                maskDesc.name = "_ImpactFrameSubjects";
                maskDesc.format = GraphicsFormat.R8_UNorm;
                maskDesc.msaaSamples = depthDesc.msaaSamples;
                maskDesc.depthBufferBits = DepthBits.None;
                maskDesc.clearBuffer = true;
                maskDesc.clearColor = Color.black;
                TextureHandle mask = renderGraph.CreateTexture(maskDesc);

                using (var builder = renderGraph.AddRasterRenderPass<MaskPassData>("Impact Frame Subjects", out MaskPassData data))
                {
                    data.renderers = trigger.subjects;
                    data.material = material;
                    builder.SetRenderAttachment(mask, 0);
                    builder.SetRenderAttachmentDepth(depth, AccessFlags.Read);
                    builder.SetRenderFunc(static (MaskPassData d, RasterGraphContext context) => ExecuteMask(d, context));
                }
                return mask;
            }

            private static void Fill(Material target, ImpactFrameTrigger trigger, ImpactFrameStage stage, TextureDesc desc)
            {
                target.SetFloat(ThresholdId, trigger.threshold);
                target.SetFloat(SoftnessId, trigger.softness);
                target.SetFloat(IntensityId, ImpactFrameTrigger.Strength(stage));
                target.SetFloat(InvertedId, stage.mode == ImpactFrameMode.Inverted ? 1f : 0f);
                target.SetFloat(StrokeLengthId, trigger.strokeLength);
                target.SetFloat(InkDensityId, trigger.inkDensity);
                target.SetFloat(FrameId, (int)stage.pose);
                target.SetFloat(BackgroundSuppressionId, trigger.backgroundSuppression);
                target.SetFloat(StarSizeId, trigger.starSize);
                target.SetFloat(StarStrengthId, trigger.starStrength);
                target.SetVector(CenterId, trigger.Center);
                target.SetVector(AttackDirectionId, trigger.Direction);
                target.SetVector(ResolutionId, new Vector2(desc.width, desc.height));
                target.SetVectorArray(StarsId, ImpactFrameTrigger.StarsOf(stage.pose));
                target.SetVector(ReverseStarsId, ImpactFrameTrigger.ReverseStarsOf(stage.pose));
            }

            private static void ExecuteFrame(FramePassData data, RasterGraphContext context)
            {
                Texture subject = data.externalMask;
                if (data.mask.IsValid())
                {
                    subject = ((RTHandle)data.mask).rt;
                }

                data.material.SetFloat(HasSubjectId, subject != null ? 1f : 0f);
                data.material.SetTexture(SubjectMaskId, subject != null ? subject : Texture2D.blackTexture);
                Blitter.BlitTexture(context.cmd, data.source, new Vector4(1f, 1f, 0f, 0f), data.material, FullscreenPass);
            }

            private static void ExecuteMask(MaskPassData data, RasterGraphContext context)
            {
                foreach (Renderer target in data.renderers)
                {
                    if (target == null || !target.enabled || !target.gameObject.activeInHierarchy)
                    {
                        continue;
                    }

                    int count = target.sharedMaterials.Length;
                    for (int i = 0; i < count; i++)
                    {
                        context.cmd.DrawRenderer(target, data.material, i, MaskPass);
                    }
                }
            }

            private sealed class FramePassData
            {
                public TextureHandle source;
                public TextureHandle mask;
                public Texture externalMask;
                public Material material;
            }

            private sealed class MaskPassData
            {
                public Renderer[] renderers;
                public Material material;
            }
        }
    }
}
