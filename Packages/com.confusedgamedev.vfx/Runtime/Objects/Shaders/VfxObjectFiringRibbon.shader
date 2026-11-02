// The arc turret's current: one batch of screen-facing ribbons, with positions already in world space.
Shader "ConfusedGameDev/Vfx/Object Firing Ribbon"
{
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass
        {
            Name "Ribbon"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 previous : TEXCOORD1;
                float3 next : TEXCOORD2;
                float2 data : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float power : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                float3 view = TransformWorldToView(input.positionOS);
                float2 d = TransformWorldToView(input.next).xy - TransformWorldToView(input.previous).xy;
                float len = length(d);
                float2 normal = len > 0.00001 ? float2(-d.y, d.x) / len : float2(0.0, 1.0);
                view.xy += normal * (input.uv.y * 2.0 - 1.0) * input.data.x;
                output.positionCS = TransformWViewToHClip(view);
                output.uv = input.uv;
                output.power = input.data.y;
                return output;
            }

            float4 Fragment(Varyings input) : SV_Target
            {
                float e = abs(input.uv.y * 2.0 - 1.0);
                float core = exp(-e * e * 130.0);
                float sheath = exp(-e * e * 26.0);
                float halo = exp(-e * e * 5.0);
                float3 color = float3(0.021, 0.188, 1.0) * (0.9 + sheath * 0.65) + core * 1.8;
                return float4(color, (core + sheath * 0.5 + halo * 0.23) * (1.0 - smoothstep(0.75, 1.0, e)) * input.power);
            }
            ENDHLSL
        }
    }
}
