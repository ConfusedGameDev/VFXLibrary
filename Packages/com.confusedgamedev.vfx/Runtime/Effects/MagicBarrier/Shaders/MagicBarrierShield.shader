Shader "ConfusedGameDev/Vfx/MagicBarrier Shield"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha One
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "MagicBarrierCommon.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 stagePosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                float3 p = input.positionOS * _EffectSize;
                output.stagePosition = p;
                output.positionCS = SourceToClip(p);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 grid = float2(input.uv.x * 24.0, input.uv.y * 12.0);
                grid.x += Mod(floor(grid.y), 2.0) * 0.5;
                float2 cell = abs(frac(grid) - 0.5);
                float tile = Band(max(cell.x * 0.866 + cell.y * 0.5, cell.y) - 0.44, 0.018);
                float latitude = sin(input.uv.y * VFX_PI * 0.5);
                float scan = exp(-pow((input.uv.y - frac(_EmitterTime * 0.17)) * 20.0, 2.0));
                float alpha = (tile * (0.11 + scan * 0.22) + scan * 0.04) * latitude;
                return float4(_EffectColor.rgb * (1.0 + scan * 0.6), saturate(alpha * _EffectDetail * PhaseCoverage(input.stagePosition)));
            }
            ENDHLSL
        }
    }
}
