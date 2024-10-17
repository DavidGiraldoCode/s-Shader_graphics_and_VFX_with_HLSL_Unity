/*
Recall:
“Lambertian shading is view independent: the color of a surface does not depend on the direction from which you look.” ([“Fundamentals of Computer Graphics, Fourth Edition”, p. 82](zotero://select/library/items/L7XG5IT7)) ([pdf](zotero://open-pdf/library/items/TDYJ9I4M?page=97))
*/

Shader "David/Classic/LambertianDiffuse" //Lambertian Shading
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
                float2 uv           : TEXCOORD0;
                float3 normal       : NORMAL;
                half4  lightColor   : TEXCOORD1;
                float3 positionWP   : TEXCOORD2;
            };

            FragmentData vert(MeshData input)
            {
                FragmentData output;

                output.position     = TransformObjectToHClip(input.vertex.xyz); // apply MVP matrix, from 3D world to the viewport
                output.normal       = normalize(input.normal);                  // normalize normals (the interpolated ones)
                output.uv           = input.uv;                                 // Pass UV directly if we do not have a sampler
                output.positionWP   = GetVertexPositionInputs(input.vertex.xyz).positionWS;
                // Ref https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/use-built-in-shader-methods-transformations.html
                
                // Note that computing the light model on the vertex shader will yield
                // facetaded shading, due to the interpolation
                //output.lightColor = half4(colorWithAmbient);
                return output;
            };

            float4 frag(FragmentData input) : SV_Target
            {
                
                //return input.lightColor;

            
                light = GetMainLight();
                
                //diffuse coefficient
                float4 surfaceColor = _BaseColor;

                // Recall that the dot product is a range [-1, 1].
                // This is "wrong" as we are computing the light with the normals in object space,
                // meaning that if we rotate the object in world space, the light is still being computed with the normals
                // that as if the object has not rotated
                float3 N = normalize(input.normal.xyz); 

                //GetVertexNormalInputs
                VertexNormalInputs normals = GetVertexNormalInputs(input.normal.xyz);
                float3 worldNormal = normals.normalWS.xyz; 


                float intensity = max(0, dot(light.direction, worldNormal /*N*/)); // < 0 ? 0 : dot(light.direction, input.normal) ;

                float4 lambertianColor = float4(surfaceColor.xyz, 1) * float4(light.color.xyz, 1) * intensity;

                float ambientLightIntensity = 0.05;
                float4 ambientColor = surfaceColor * ambientLightIntensity;

                float4 colorWithAmbient = lambertianColor + ambientColor;

                // Specular
                float3 cameraPos = GetCameraPositionWS();
                // We compute the vector that determines the were the camera is.
                float3 eyeDirection = normalize(input.positionWP - cameraPos) * -1;
                float3 lightDirection = normalize(light.direction);
                float3 halfVector = normalize(eyeDirection + lightDirection);
                float phongExponent = 100;

                //specular coefficient, or the specular color, of the surface.
                float4 specularK = float4(1,1,1,1);
                float4 specularIntensity = max(0, pow(dot(halfVector, worldNormal), phongExponent));
                float4 specularColor = specularK * specularIntensity;
                

                //return colorWithAmbient;
                return specularColor; // Debugging only the specular part
                //return float4(input.positionWP, 1);
                //return float4(eyeDirection.xyz, 1); // Debugging the position of the camera
                //return float4(normals.normalWS.xyz,1); // Debugging the normals of the object transform in world space.

                
            };


            ENDHLSL
        }
    }
}
