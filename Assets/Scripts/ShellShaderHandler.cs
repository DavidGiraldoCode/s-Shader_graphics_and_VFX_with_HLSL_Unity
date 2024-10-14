using UnityEngine;

public class ShellShaderHandler : MonoBehaviour
{
    public Mesh shellMesh;
    public Shader shellShader;
    public Transform mainLight;
    [Range(1, 256)]
    public int shellCount = 16;

    [Range(0.0f, 1.0f)]
    public float shellLength = 0.15f;
    [Range(0.01f, 3.0f)]
    public float distanceAttenuation = 1.0f;
    [Range(1.0f, 1000.0f)]
    public float density = 100.0f;

    [Range(0.0f, 1.0f)]
    public float noiseMin = 0.0f;

    [Range(0.0f, 1.0f)]
    public float noiseMax = 1.0f;
    [Range(0.0f, 10.0f)]
    public float thickness = 1.0f;
    public Color shellColor;
    private Material shellMaterial;
    private GameObject[] shells;

    // Monobehaviour lifecyle

    private void OnEnable()
    {
        shellMaterial = new Material(shellShader);

        shells = new GameObject[shellCount];

        for (int i = 0; i < shellCount; ++i)
        {
            shells[i] = new GameObject("Shell " + i.ToString());
            shells[i].AddComponent<MeshFilter>();
            shells[i].AddComponent<MeshRenderer>();

            shells[i].GetComponent<MeshFilter>().mesh = shellMesh;
            shells[i].GetComponent<MeshRenderer>().material = shellMaterial;
            shells[i].transform.SetParent(this.transform, false);

            SetUpData(shells[i], i);
        }
    }

    void OnDisable()
    {
        for (int i = 0; i < shells.Length; ++i)
        {
            Destroy(shells[i]);
        }

        shells = null;
    }

    //private methods

    void SetUpData(GameObject gameObject, int i)
    {
        // In order to tell the GPU what its uniform variable values should be, we use these "Set" functions which will set the
        // values over on the GPU. 
        gameObject.GetComponent<MeshRenderer>().material.SetInt("_ShellCount", shellCount);
        gameObject.GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", i);
        gameObject.GetComponent<MeshRenderer>().material.SetFloat("_ShellLength", shellLength);
        gameObject.GetComponent<MeshRenderer>().material.SetFloat("_Density", density);
        gameObject.GetComponent<MeshRenderer>().material.SetFloat("_Thickness", thickness);
        //gameObject.GetComponent<MeshRenderer>().material.SetFloat("_Attenuation", occlusionAttenuation);
        gameObject.GetComponent<MeshRenderer>().material.SetFloat("_ShellDistanceAttenuation", distanceAttenuation);
        //gameObject.GetComponent<MeshRenderer>().material.SetFloat("_Curvature", curvature);
        //gameObject.GetComponent<MeshRenderer>().material.SetFloat("_DisplacementStrength", displacementStrength);
        //gameObject.GetComponent<MeshRenderer>().material.SetFloat("_OcclusionBias", occlusionBias);
        gameObject.GetComponent<MeshRenderer>().material.SetFloat("_NoiseMin", noiseMin);
        gameObject.GetComponent<MeshRenderer>().material.SetFloat("_NoiseMax", noiseMax);
        gameObject.GetComponent<MeshRenderer>().material.SetVector("_ShellColor", shellColor);

        //gameObject.GetComponent<MeshRenderer>().material.SetVector("_MainLightPosition", mainLight.position);
        
    }
}