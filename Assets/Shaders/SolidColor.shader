//Simple Shader Example in URP
Shader "Unlit/SolidColor"
{
    //Define variables that will be expose in the Unity Editor
    Properties 
    {
        _MainTex ("Texture", 2D)  = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
        LOD 100
        // A Pass represents how many time the GPU applies this shaders
        Pass
        {
            //C-style code, We need to specify where the HLSL code start and ends, and include the Core.hlsl library
            HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //Define the entry points for the shaders, this tells the GPU which functions correspond to the vertex and fragment shaders.
            #pragma vertex vert            
            #pragma fragment frag

            //As the GPU know nothing about the CPU, we pass the appliation variables value from outside
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            //Declare the data that is going to pass through the veretex and fragment shaders.
            //The position is a 4D vector since it will undergo a 4x4 Matrix transformation
            struct VertexInput
            {
                float4 position : POSITION; 
                float2 uv : TEXCOORD0;
            }
            //System-Value Position represent the vertex position after the Matrix transformation to clip space
            struct VertexOut
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            }
            
            //Declare and implement the shaders
            //Vertex Shader
            VertexOut vert(VertexInput INPUT)
            {
                VertexOut OUTPUT;
                OUTPUT.position = TransformObjectToHClip(INPUT.position.xyz);
                OUTPUT.uv = INPUT.uv;

                return OUTPUT;
            }
            //Fragment Shader
            float4 frag(VertexOut vrt_OUTPUT) : SV_Target
            {
                float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, vrt_OUTPUT.uv);
                return baseTex * _BaseColor;
            }

            ENDHLSL
        }
    }
}
