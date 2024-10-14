Shader "Unlit/DisplacementWithAlpha"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        ZWrite Off // Disable depth writing for transparency
        Blend SrcAlpha OneMinusSrcAlpha // Enable alpha blending
        Cull Back

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION;
                float3 normal   : TEXCOORD1;
                float2 uv       : TEXCOORD0;
                float layer     : TEXCOORD2;  // Add layer for color control in fragment
            };

            int _LayerCount;
            int _LayerIndex;
            float4 _BaseColor;  // Add base color property

            VertexOutput vert(VertexInput input)
            {
                VertexOutput output;

                // Calculate the displacement based on the layer index
                float shellHeight = (float)_LayerIndex / (float)_LayerCount;
                float shellLength = 0.2;
                float displacementForceAlongNormal = shellLength * shellHeight;

                // Offset the vertex position along the normal
                input.vertex.xyz += input.normal.xyz * displacementForceAlongNormal;
                
                output.position = TransformObjectToHClip(input.vertex.xyz);
                output.uv = input.uv;
                output.layer = (float)_LayerIndex / (float)_LayerCount; // Store layer for color blending

                return output;
            }

            float4 frag(VertexOutput output) : SV_TARGET
            {
                // Simple color based on UV and layer
                float4 color = _BaseColor;

                // Modify the alpha based on layer index to blend layers
                color.a *= (1.0 - output.layer);

                return color;
            }

            ENDHLSL
        }
    }

    Fallback Off
}

