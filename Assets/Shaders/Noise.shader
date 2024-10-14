Shader "Unlit/Noise"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalRenderPipeline"
            //"LightMode" = "ForwardBase"
        }
        LOD 100

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
                float4 position : POSITION;
                float2 uv       : TEXCOORD0; //Semantics conveys information about the intended use of a parameter. 
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION;
                float2 uv       : TEXCOORD0;
            };

            VertexOutput vert(VertexInput input)
            {

                VertexOutput output;
                output.position = TransformObjectToHClip(input.position.xyz);
                output.uv = input.uv;

                return output;
            }

            float4 frag(VertexOutput output) : SV_TARGET
            {

                float2 scaledUV = output.uv * 1;
                float2 localUV = frac(scaledUV) * 2 - 1; // by multiplying by 2 and then substracting -1, we change the domain from [0,1] to [-1,1]
                //float2 localUV = (output.uv) * 2 - 1;
                
                float localDistanceFromCenter = length(localUV); // Returns the magnitud of a vector https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-length
                uint2 tid = scaledUV; //just casting
				uint seed = tid.x + 100 * tid.y + 100 * 10; //just the random seed

                float shellIndex = 1.0;
                float shellCount = 4.0;

                float rand = lerp(0, 1, hash(seed)); // Lerps between X0 and X1 by s https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-lerp

                float h = shellIndex / shellCount;

                float thicknessAtHeight = (1 * (rand - h));
                int outsideThickness = (localDistanceFromCenter) > (thicknessAtHeight);

                //if (outsideThickness && shellIndex > 0)  discard; //&& _ShellIndex > 0)

                // -----------------------------
                // Use this to Debbug the reading of a texture and location of the UVs.
                //
                //float4 color = float4(output.uv.x,0,output.uv.y,1);

                // -----------------------------
                // Use this to Debbug the noise.
                //
                float4 color = float4(rand,rand,rand,1);

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
                //float4 color = float4(localUV.x,localUV.y,0,1);

                
                
                return color;
            }

            ENDHLSL

        }
    }
}
