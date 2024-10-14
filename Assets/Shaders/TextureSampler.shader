Shader "David/ShaderBasics/TextureSampler"
{
    Properties
    {

        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _AlphaMap("Alpha Map", 2D) = "white" {}
        _ScrollingYSpeed("Scrolling Y speed", Float) = 0.0
        _BaseColor("Color", Color) = (1,1,1,1)
        _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        //Do not name a materia variable _MainTex as it is a reserved property name
    }
    SubShader
    {
        Tags 
        { 

            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline" 
        }
        LOD 200
        Cull Off
        //Blend SrcAlpha One
        Blend SrcAlpha OneMinusSrcAlpha
	    //ZWrite Off

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            //#pragma target 3.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexObject
            {
                float2 uv : TEXCOORD0;
                float2 uvBlend : TEXCOORD1;
                float4 position : POSITION;
                float4 normal : NORMAL;
            };

            struct FragmentObject
            {
                float2 uv : TEXCOORD0;
                float2 uvBlend : TEXCOORD1;
                float4 position : SV_POSITION;
            };

            //TEXTURE2D and the SAMPLER macros
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_AlphaMap);
            SAMPLER(sampler_AlphaMap);

            //Buffer for compatibility
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _AlphaMap_ST;
                float _ScrollingYSpeed;
                float4 _BaseColor;
                float _AlphaCutoff;
            CBUFFER_END

            FragmentObject vert(VertexObject vertexInput)
            {
                FragmentObject vertOutput;

                //vertexInput.position.xyz += vertexInput.normal.xyz * _SinTime;

                //Initialization
                vertOutput.position = TransformObjectToHClip(vertexInput.position.xyz);
                vertOutput.uv = TRANSFORM_TEX(vertexInput.uv, _BaseMap);
                vertOutput.uvBlend = TRANSFORM_TEX(vertexInput.uvBlend, _AlphaMap);

                return vertOutput;
            }

            float GetAlpha (FragmentObject i) {
                float alpha = _BaseColor.a;
                #if !defined(_SMOOTHNESS_ALBEDO)
                    alpha *= SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv).a;
                #endif
                return alpha;
            }

            float4 frag(FragmentObject fragmentInput) : SV_Target
            {
                //fragmentInput.uv.x += _Time * 0.5 ;
               
                
                //SAMPLE_TEXTURE2D is a macro that wraps the functionality of samplying texture
                // allowing compatibility through different graphics APIs
                
                
                

                
                //finalPixelA.r *= SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, fragmentInput.uv);

                fragmentInput.uvBlend *= 0.2;
                fragmentInput.uvBlend.y += _Time * _ScrollingYSpeed;


                float alpha = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, fragmentInput.uvBlend).a;
                float4 finalPixelB = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, fragmentInput.uvBlend);

                fragmentInput.uv.y += _Time * _ScrollingYSpeed*2;

                fragmentInput.uv.x += finalPixelB.r * 0.5;
                fragmentInput.uv.y += finalPixelB.g * 0.5;

                float4 finalPixelA = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, fragmentInput.uv); //_BaseColor;//
                finalPixelA.a = alpha * 1.5;
                //fragmentInput.uv.y += finalPixelB.r * 1.2;
                //finalPixelA *= finalPixelB;
                //timeFactor = 0.5 * _SinTime.x + 0.5;
                //_AlphaCutoff = (0.5 * _SinTime.x + 0.5);
                //_AlphaCutoff += ((_SinTime * 0.5) - 0.5) ;//* frac(_Time);

                if(alpha < _AlphaCutoff) discard;
                //finalPixel.a = 0.1;
                


                return finalPixelA;
            }

            ENDHLSL
        }
    }
}
