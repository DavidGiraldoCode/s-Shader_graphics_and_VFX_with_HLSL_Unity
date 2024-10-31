Shader "David/TextureBased/TexBaseVertexDeformation"
{
    Properties
    {
        _BaseColor ("Base color", Color) = (1.0, 1.0, 1.0, 1.0)
        [MainTexture] _ErosionMap("ErosionMap", 2D) = "white" {}
        _DeformCoefficient ("DeformCoefficient", Float) = 1.0
    }
    SubShader
    {
        Tags
        { 
            "Queue" = "Transparent"
            "RenderType"="Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

            #pragma vertex vert
            #pragma fragment frag

            // Two components in the sampling of textures
            // 1 setup the texture
            TEXTURE2D(_ErosionMap);
            // 2 intantiate the sampler
            SAMPLER(sampler_ErosionMap);

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColorl;
            float4 _ErosionMap_ST;
            float _DeformCoefficient;
            CBUFFER_END

            struct MeshData
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
                float2 errosion : TEXCOORD1;
            };

            struct FragmentData
            {
                float4 position     : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 normal       : NORMAL;
                float2 errosion     : TEXCOORD1;
            };

            FragmentData vert(MeshData meshInput)
            {
                FragmentData fragmentOutput;
                
                fragmentOutput.uv       = TRANSFORM_TEX(meshInput.uv, _ErosionMap);

                fragmentOutput.position = TransformObjectToHClip(meshInput.vertex.xyz);
                fragmentOutput.normal   = meshInput.normal;
                fragmentOutput.errosion = meshInput.errosion; 


                return fragmentOutput;
            }

            float4 frag(FragmentData fragInput) : SV_Target
            {
                float4 pixelColor = float4(1.0, 1.0, 1.0, 1.0);

                //pixelColor = float4(fragInput.uv.xy, 1.0, 1.0);
                float4 erosionSample = SAMPLE_TEXTURE2D(_ErosionMap, sampler_ErosionMap, fragInput.uv);
                pixelColor = erosionSample;
                

                return pixelColor;
            }
            
            ENDHLSL
        }
    }
}
