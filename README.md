# Shader graphics and VFX - HLSL in Unity


## Important references

- [Unity HLSL](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl)

- [HLSL variables functions](https://github.com/Unity-Technologies/Graphics/blob/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl)

## Shading modes cheat-sheet

“Lambertian shading is view independent: the color of a surface does not depend on the direction from which you look.” ([“Fundamentals of Computer Graphics, Fourth Edition”, p. 82](zotero://select/library/items/L7XG5IT7)) ([pdf](zotero://open-pdf/library/items/TDYJ9I4M?page=97))

``` C
VertexNormalInputs normals = GetVertexNormalInputs(input.normal.xyz);
float3 worldNormal = normals.normalWS.xyz; 


float intensity = max(0, dot(light.direction, worldNormal /*N*/)); // < 0 ? 0 : dot(light.direction, input.normal) ;

float4 lambertianColor = float4(surfaceColor.xyz, 1) * float4(light.color.xyz, 1) * intensity;

float ambientLightIntensity = 0.05;
float4 ambientColor = surfaceColor * ambientLightIntensity;

float4 colorWithAmbient = lambertianColor + ambientColor;
```