Shader "Unlit/DisplacementNoise"
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

        //ZWrite Off // Disable depth writing for transparency
        //Blend SrcAlpha OneMinusSrcAlpha // Enable alpha blending
        Cull  Off //Off works as well// Back

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float hash(uint n)
            {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

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

            // To make the Unity shader SRP Batcher compatible, declare all
            // properties related to a Material in a a single CBUFFER block with 
            // the name UnityPerMaterial.
            CBUFFER_START(UnityPerMaterial)
                // The following line declares the _BaseColor variable, so that you
                // can use it in the fragment shader.
                //half - 16-bit floating point value. This data type is provided only for language compatibility.
                //float4 _BaseColor; // Add base color property       
            CBUFFER_END

            int _LayerCount;
            int _LayerIndex;
            float4 _BaseColor;  

            VertexOutput vert(VertexInput input)
            {
                VertexOutput output;

                // Calculate the displacement based on the layer index
                float shellHeight = (float)_LayerIndex / (float)_LayerCount;
                float shellLength = 0.2;
                float displacementForceAlongNormal = shellLength * shellHeight;

                // Offset the vertex position along the normal
                input.vertex.xyz += input.normal.xyz * displacementForceAlongNormal;

                //Recall to always initialize all output components
                output.normal = normalize(input.normal);  // Initialize the normal
                output.position = TransformObjectToHClip(input.vertex.xyz);
                output.uv = input.uv; // Initialize UVs
                output.layer = (float)_LayerIndex / (float)_LayerCount; // Store layer for color blending

                return output;
            }

            float4 frag(VertexOutput output) : SV_TARGET
            {
                float2 scaledUV = output.uv * 24;
                float2 localUV = frac(scaledUV) * 2 - 1; // by multiplying by 2 and then substracting -1, we change the domain from [0,1] to [-1,1]
                //float2 localUV = (output.uv) * 2 - 1;
                
                float localDistanceFromCenter = length(localUV); // Returns the magnitud of a vector https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-length
                uint2 tid = scaledUV; //just casting
				uint seed = tid.x + 100 * tid.y + 100 * 10; //just the random seed

                float shellIndex = _LayerIndex;
                float shellCount = _LayerCount;

                float rand = lerp(0, 1, hash(seed)); // Lerps between X0 and X1 by s https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-lerp

                float h = shellIndex / shellCount;

                float thicknessAtHeight = (1 * (rand - h));
                int outsideThickness = (localDistanceFromCenter) > (thicknessAtHeight);

                if (outsideThickness && shellIndex > 0)  discard; //&& _ShellIndex > 0)

                // -----------------------------
                // Use this to Debbug the reading of a texture and location of the UVs.
                //
                //float4 color = float4(output.uv.x,0,output.uv.y,_BaseColor.w);

                // -----------------------------
                // Use this to Debbug the noise.
                //
                //float4 color = float4(rand,rand,rand,_BaseColor.w);

                // -----------------------------
                // Use this to Debbug the frac, the tiling effect, as we scale our texture S times, the coordinate reset every 1/Sth of the texture space
                //
                // Manual tiling
                int repetitions = 4;
                float2 tiledUV = output.uv * repetitions - floor(output.uv * repetitions);
                //float4 color = float4(frac(output.uv * 3).x,frac(output.uv * 3).y,0,1);
                //float4 color = float4(tiledUV.x, tiledUV.y, 0, 1);
                

                // -----------------------------
                // Use this to Debbug localUV
                //
                //float4 color = float4(localUV.x,localUV.y,1.0, _BaseColor.w);
                //* ------------------------------------------------------ Bellow this, all works
                // Simple color based on UV and layer
                float4 color = _BaseColor;

                // Modify the alpha based on layer index to blend layers
                //color.r *= (1.0 - output.layer);
                //color.a *= (1.0 - output.layer);
                color.g = (1.0 - output.layer);
                color.b = 0.0;
                color.r *= (h);

                return color;
            }

            ENDHLSL
        }
    }

    Fallback Off
}

