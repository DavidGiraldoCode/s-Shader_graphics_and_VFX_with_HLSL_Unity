Shader "David/TextureBased/Errosion"
{
    Properties
    {
        _BaseColor ("Base color", Color) = (1.0, 1.0, 1.0, 1.0)
        [MainTexture] _ErosionMap("ErosionMap", 2D) = "white" {}
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
        
        Cull Off
        // Recall the blanding equation -> finalValue = sourceFactor * sourceValue operation destinationFactor * destinationValue
        /*
        finalValue is the value that the GPU writes to the destination buffer.
        sourceFactor is defined in the Blend command.
        sourceValue is the value output by the fragment shader.
        operation is the blending operation.
        destinationFactor is defined in the Blend command.
        destinationValue is the value already in the destination buffer.
        */
        Blend SrcAlpha OneMinusSrcAlpha
        /*
        OneMinusSrcColor	The GPU multiplies the value of this input by (1 - source color).
        OneMinusSrcAlpha	The GPU multiplies the value of this input by (1 - source alpha).
        OneMinusDstColor	The GPU multiplies the value of this input by (1 - destination color).
        OneMinusDstAlpha	The GPU multiplies the value of this input by (1 - destination alpha).
        */

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

                fragmentOutput.position = TransformObjectToHClip(meshInput.vertex.xyz);
                fragmentOutput.uv       = TRANSFORM_TEX(meshInput.uv, _ErosionMap);
                fragmentOutput.normal   = meshInput.normal;
                fragmentOutput.errosion = meshInput.errosion; 


                return fragmentOutput;
            }

            float4 frag(FragmentData fragInput) : SV_Target
            {
                float4 pixelColor = float4(1.0, 1.0, 1.0, 1.0);

                //pixelColor = float4(fragInput.uv.xy, 1.0, 1.0);
                float4 erosionSample = SAMPLE_TEXTURE2D(_ErosionMap, sampler_ErosionMap, fragInput.uv);
                //pixelColor = erosionSample;
                
                // Smooth
                //pixelColor.a = erosionSample.r;
                float frecuency = _Time * 100;
                float reMappedFrecuency = (1.05 - sin(frecuency)) * 0.5;
                float alphaThreshold = reMappedFrecuency;// * reMappedFrecuency;
                if(erosionSample.r < alphaThreshold)
                    pixelColor.a = 0.0;

                // debuging
                //pixelColor.a = max(0, sin(_Time * 50));

                return pixelColor;
            }
            
            ENDHLSL
        }
    }
    //Fallback Off
}
