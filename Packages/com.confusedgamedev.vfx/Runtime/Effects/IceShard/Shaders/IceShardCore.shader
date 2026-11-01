Shader "ConfusedGameDev/Vfx/IceShard Core"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent+2" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            Cull Front

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #define VFX_VARIANT 2
            #include "Packages/com.confusedgamedev.vfx/Runtime/Shaders/VfxProjectile.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalVS : TEXCOORD1;
                float3 viewVS : TEXCOORD2;
                float3 local : TEXCOORD3;
                float3 stagePosition : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.uv;
                output.local = input.positionOS;

                float roll = sin(_EffectTime * 0.7) * 0.12;
                float c = cos(roll);
                float s = sin(roll);
                float3 p = input.positionOS * _EffectSize;
                p.yz = float2(c * p.y - s * p.z, s * p.y + c * p.z);
                float3 n = input.normalOS;
                n.yz = float2(c * n.y - s * n.z, s * n.y + c * n.z);
                p.x += 0.85;

                output.normalVS = TransformWorldToViewDir(TransformObjectToWorldDir(ToUnity(n), false), false);
                output.viewVS = -SourceToView(p);
                output.positionCS = StageClip(p, output.stagePosition);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float3 n = normalize(input.normalVS);
                float rim = pow(abs(1.0 - abs(dot(n, normalize(input.viewVS)))), 2.0);
                float lit = max(0.0, dot(n, normalize(float3(-0.35, 0.8, 0.5))));
                float sweep = pow(max(0.0, sin(input.local.x * 3.0 - _EffectTime * 2.4)), 24.0);
                float3 c = ToonShade(_EffectColor.rgb, 0.18 + lit * 0.53 + rim * 0.17 + sweep * 0.24);
                float alpha = _LifeStage == 1.0 ? 1.0 : 0.97 * StageAlpha(input.stagePosition);
                return float4(c, alpha);
            }
            ENDHLSL
        }
    }
}
