Shader "David/Classic/LambertianDiffuse"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }
        LOD 100

        Pass
        {
            
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" // To get the main light
            // https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/use-built-in-shader-methods-lighting.html

            #pragma vertex      vert
            #pragma fragment    frag

            Light light;
            
            
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
            CBUFFER_END

            struct MeshData
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
            };

            struct FragmentData
            {
                float4 position     : SV_POSITION;
                float3 normal       : NORMAL;
                half4  lightColor   : TEXCOORD1;
            };

            FragmentData vert(MeshData input)
            {
                FragmentData output;

                output.position = TransformObjectToHClip(input.vertex.xyz); // apply MVP matrix, from 3D world to the viewport
                output.normal   = normalize(input.normal);                  // normalize normals (the interpolated ones)
                //output.uv       = input.uv;                                 // Pass UV directly if we do not have a sampler

                light = GetMainLight();

                //diffuse coefficient
                float4 surfaceColor = _BaseColor;

                // Recall that the dot product is a range [-1, 1]. 
                float intensity = max(0, dot(light.direction, input.normal)); // < 0 ? 0 : dot(light.direction, input.normal) ;

                float4 lambertianColor = float4(surfaceColor.xyz, 1) * float4(light.color.xyz, 1) * intensity;

                float shadowIntensity = 0.05;
                float4 ambientLightColor = float4(surfaceColor.xyz, 1) * shadowIntensity;

                float4 ColorWithAmbient = lambertianColor + ambientLightColor;

                output.lightColor = half4(ColorWithAmbient);

                return output;
            };

            float4 frag(FragmentData input) : SV_Target
            {
                
                return input.lightColor;
            };


            ENDHLSL
        }
    }
}
