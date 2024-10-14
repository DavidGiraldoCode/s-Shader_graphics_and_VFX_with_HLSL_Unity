using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;

public class RepetitionController : MonoBehaviour
{
    public Mesh mesh;
    public Shader shader;
    public Color color;
    private GameObject[] layers;
    private Material displacementMAT;
    [Range(1,32)]
    public uint layerCount = 0;

    private void OnEnable() 
    {
        displacementMAT = new Material(shader);
        layers = new GameObject[layerCount];

        for (int i = 0; i < layerCount; ++i) {
            layers[i] = new GameObject("Layer " + i.ToString());
            layers[i].AddComponent<MeshFilter>();
            layers[i].AddComponent<MeshRenderer>();
            
            layers[i].GetComponent<MeshFilter>().mesh = mesh;
            layers[i].GetComponent<MeshRenderer>().material = displacementMAT;
            layers[i].transform.SetParent(this.transform, false);
            
            layers[i].GetComponent<MeshRenderer>().material.SetInt("_LayerCount", (int)layerCount);
            layers[i].GetComponent<MeshRenderer>().material.SetInt("_LayerIndex", i);
            //layers[i].GetComponent<MeshRenderer>().material.SetVector("_BaseColor", color);
        }
    }

}
