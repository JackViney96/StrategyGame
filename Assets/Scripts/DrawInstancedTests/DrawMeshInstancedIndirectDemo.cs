using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//TODO:
/*
 * Maybe collect points from every terrain chunk as it's generated?
*/

public class DrawMeshInstancedIndirectDemo : MonoBehaviour
{
    private Mesh parentMesh;

    public int population;
    public float range;

    public Material material;
    private Material _material;

    private ComputeBuffer meshPropertiesBuffer;
    private ComputeBuffer argsBuffer;

    public Mesh grassMesh;
    
    private Bounds bounds;

    private bool isReady = false;

    // Mesh Properties struct to be read from the GPU.
    // Size() is a convenience funciton which returns the stride of the struct.
    private struct MeshProperties
    {
        public Matrix4x4 mat;
        public Vector4 color;

        public static int Size()
        {
            return
                sizeof(float) * 4 * 4 + // matrix;
                sizeof(float) * 4;      // color;
        }
    }

    public void Setup()
    {
       // Mesh mesh = CreateQuad();
        //this.mesh = mesh;
        parentMesh = GetComponent<MeshFilter>().sharedMesh;

        _material = Instantiate(material);

        // Boundary surrounding the meshes we will be drawing.  Used for occlusion.
        bounds = new Bounds(transform.position, Vector3.one * (range + 1));

        InitializeBuffers();
        isReady = true;
    }

    private Vector3 getPointOnMesh()
    {
        Vector3[] meshPoints = parentMesh.vertices;
        int[] tris = parentMesh.triangles;
        int triStart = Random.Range(0, meshPoints.Length / 3) * 3; // get first index of each triangle

        float a = Random.value;
        float b = Random.value;

        if (a + b >= 1)
        { // reflect back if > 1
            a = 1 - a;
            b = 1 - b;
        }

        Vector3 newPointOnMesh = meshPoints[triStart] + (a * (meshPoints[triStart + 1] - meshPoints[triStart])) + (b * (meshPoints[triStart + 2] - meshPoints[triStart])); // apply formula to get new random point inside triangle

        newPointOnMesh = transform.TransformPoint(newPointOnMesh); // convert back to worldspace
        newPointOnMesh -= transform.position;
        return newPointOnMesh;
        //return new Vector3(Random.Range(-range, range), Random.Range(-range, range), Random.Range(-range, range));
    }

    private void InitializeBuffers()
    {
        // Argument buffer used by DrawMeshInstancedIndirect.
        uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
        // Arguments for drawing mesh.
        // 0 == number of triangle indices, 1 == population, others are only relevant if drawing submeshes.
        args[0] = (uint)grassMesh.GetIndexCount(0);
        args[1] = (uint)population;
        args[2] = (uint)grassMesh.GetIndexStart(0);
        args[3] = (uint)grassMesh.GetBaseVertex(0);
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        argsBuffer.SetData(args);

        // Initialize buffer with the given population.
        MeshProperties[] properties = new MeshProperties[population];
        for (int i = 0; i < population; i++)
        {
            MeshProperties props = new MeshProperties();
            Vector3 position = getPointOnMesh();
            //TODO: grab both pos and rot
            Quaternion rotation = Quaternion.Euler(0,0,0); // Quaternion.Euler(270, Random.Range(-180, 180), 0);
            Vector3 scale = Vector3.one;

            props.mat = Matrix4x4.TRS(position, rotation, scale);
            props.color = Color.Lerp(Color.red, Color.blue, Random.value);

            properties[i] = props;
        }

        meshPropertiesBuffer = new ComputeBuffer(population, MeshProperties.Size());
        meshPropertiesBuffer.SetData(properties);
        _material.SetBuffer("_Properties", meshPropertiesBuffer);
    }

    private Mesh CreateQuad(float width = 1f, float height = 1f)
    {
        // Create a quad mesh.
        var mesh = new Mesh();

        float w = width * .5f;
        float h = height * .5f;
        var vertices = new Vector3[4] {
            new Vector3(-w, -h, 0),
            new Vector3(w, -h, 0),
            new Vector3(-w, h, 0),
            new Vector3(w, h, 0)
        };

        var tris = new int[6] {
            // lower left tri.
            0, 2, 1,
            // lower right tri
            2, 3, 1
        };

        var normals = new Vector3[4] {
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward,
        };

        var uv = new Vector2[4] {
            new Vector2(0, 0),
            new Vector2(1, 0),
            new Vector2(0, 1),
            new Vector2(1, 1),
        };

        mesh.vertices = vertices;
        mesh.triangles = tris;
        mesh.normals = normals;
        mesh.uv = uv;

        return mesh;
    }

    private void OnEnable()
    {
        Setup();
    }

    private void Update()
    {
        if (isReady)
        {
            Graphics.DrawMeshInstancedIndirect(grassMesh, 0, _material, bounds, argsBuffer);
        }
        
    }

    private void OnDisable()
    {
        // Release gracefully.
        if (meshPropertiesBuffer != null)
        {
            meshPropertiesBuffer.Release();
        }
        meshPropertiesBuffer = null;

        if (argsBuffer != null)
        {
            argsBuffer.Release();
        }
        argsBuffer = null;
    }
}




 