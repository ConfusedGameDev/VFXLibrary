// Bay labels. The built-in font material draws over everything, so this one respects depth.
Shader "ConfusedGameDev/Showcase/Label"
{
    Properties
    {
        _MainTex ("Font Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "UnityShaderVariables.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct Attributes
            {
                float4 position : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 position : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output;
                output.position = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(input.position.xyz, 1.0)));
                output.color = input.color;
                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return output;
            }

            float4 Fragment(Varyings input) : SV_Target
            {
                return float4(input.color.rgb, input.color.a * tex2D(_MainTex, input.uv).a);
            }
            ENDHLSL
        }
    }
}
