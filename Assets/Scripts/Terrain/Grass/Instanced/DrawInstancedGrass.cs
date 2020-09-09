using CielaSpike;
using NaughtyAttributes;
using System;
using System.Collections;
using System.Threading;
using UnityEngine;

public class DrawInstancedGrass : MonoBehaviour
{
    private Mesh parentMesh;

    public int population;
    public float range;

    public Material material;
    [System.NonSerialized]
    private Material _material;

    private ComputeBuffer meshPropertiesBuffer;
    private ComputeBuffer argsBuffer;

    public Mesh grassMesh;
    
    private Bounds bounds;

    private bool isReady = false;

    // Mesh Properties struct to be read from the GPU.
    // Size() is a convenience funciton which returns the stride of the struct.
    //MUST match the struct in the shader!!!
    public struct MeshProperties
    {
        public Matrix4x4 TRSMatrix;
        public Vector2 groundUV;

        public static int Size()
        {
            return
                sizeof(float) * 4 * 4// matrix;
                + sizeof(float) * 2; //GroundUV
        }
    }
    public struct MeshData
    {
        public Vector3[] verts;
        public int[] tris;
        public Vector2[] uvs;
    }

    MeshProperties[] properties;

    public IEnumerator Setup()
    {
       // Mesh mesh = CreateQuad();
        //this.mesh = mesh;
        parentMesh = GetComponent<MeshFilter>().sharedMesh;
        MeshData meshData;
        meshData.verts = parentMesh.vertices;
        meshData.tris = parentMesh.triangles;
        meshData.uvs = parentMesh.uv;

        _material = Instantiate(material);

        // Boundary surrounding the meshes we will be drawing.  Used for occlusion.
        bounds = new Bounds(transform.position, Vector3.one * (range + 1));

        //Setup:
        uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
        // Arguments for drawing mesh.
        // 0 == number of triangle indices, 1 == population, others are only relevant if drawing submeshes.
        args[0] = (uint)grassMesh.GetIndexCount(0);
        args[1] = (uint)population;
        args[2] = (uint)grassMesh.GetIndexStart(0);
        args[3] = (uint)grassMesh.GetBaseVertex(0);
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        argsBuffer.SetData(args);

        properties = new MeshProperties[population];


        Task task;
        this.StartCoroutineAsync(InitializeBuffers(meshData), out task);
        yield return StartCoroutine(task.Wait());

        meshPropertiesBuffer = new ComputeBuffer(population, MeshProperties.Size());
        meshPropertiesBuffer.SetData(properties);

        _material.SetBuffer("_Properties", meshPropertiesBuffer);

        isReady = true;
    }

    struct MeshPointAndUV
    {
        public Vector3 point;
        public Vector2 uv;

        public MeshPointAndUV(Vector3 point, Vector2 uv)
        {
            this.point = point;
            this.uv = uv;
        }
    }

    private MeshPointAndUV getPointOnMesh(MeshData meshData)
    {
        System.Random rnd = StaticRandom.random.Value;
        //System.Random rnd = new System.Random();
        Vector3[] meshPoints = meshData.verts;
        int[] tris = meshData.tris;
        Vector2[] uvs = meshData.uvs;

        //int triStart = rnd.Next(0, meshPoints.Length / 3); // get first index of each triangle
        int triStart = rnd.Next(tris.Length / 3);



        float a = (float)rnd.NextDouble();
        float b = (float)rnd.NextDouble();
        //float a = StaticRandom.Rand();
        //float b = StaticRandom.Rand();

        if (a + b >= 1)
        { // reflect back if > 1
            a = 1 - a;
            b = 1 - b;
        }

        // apply formula to get new random point inside triangle
        //Vector3 newPointOnMesh = meshPoints[triStart] + (a * (meshPoints[triStart + 1] - meshPoints[triStart])) + (b * (meshPoints[triStart + 2] - meshPoints[triStart]));
        int vertIndex1 = tris[triStart * 3 + 0];
        int vertIndex2 = tris[triStart * 3 + 1];
        int vertIndex3 = tris[triStart * 3 + 2];

        Vector2 UV1 = uvs[tris[triStart * 3 + 0]];

        //Vector3 newPointOnMesh = meshPoints[vertIndex1];
        Vector3 newPointOnMesh = meshPoints[vertIndex1] + (a * (meshPoints[vertIndex2] - meshPoints[vertIndex1])) + (b * (meshPoints[vertIndex3] - meshPoints[vertIndex1]));

        //newPointOnMesh = transform.TransformPoint(newPointOnMesh); // convert back to worldspace
        //newPointOnMesh -= transform.position;
        
        return new MeshPointAndUV(newPointOnMesh, UV1);
        //return new Vector3(Random.Range(-range, range), Random.Range(-range, range), Random.Range(-range, range));
    }
    private IEnumerator InitializeBuffers(MeshData meshData)
    {
        // Argument buffer used by DrawMeshInstancedIndirect.


        // Initialize buffer with the given population.
        //System.Random rnd = new System.Random();
        System.Random rnd = StaticRandom.random.Value;

        for (int i = 0; i < population; i++)
        {
            MeshProperties props = new MeshProperties();

            //yield return Ninja.JumpToUnity;
            MeshPointAndUV pointAndUV = getPointOnMesh(meshData);
            Vector3 position = pointAndUV.point;
            //yield return Ninja.JumpBack;
            
            //Rotate 90 degrees at most because otherwise lighting can break... Not sure if shader can be fixed v_v
            Quaternion rotation = Quaternion.Euler(0, rnd.Next(90), 0); // Quaternion.Euler(270, Random.Range(-180, 180), 0);
            Vector3 scale = Vector3.one * (float)(rnd.NextDouble() * 1.5);
            position.y += scale.y * 0.5f;

            props.TRSMatrix = Matrix4x4.TRS(position, rotation, scale);
            props.groundUV = pointAndUV.uv;
            //props.color = Vector4.zero;
            //props.mat = Matrix4x4.identity;

            properties[i] = props;
        }

        
        yield return null;
    }

    Camera maincam;

    private void OnEnable()
    {
        maincam = Camera.main;
    }

    [Button]
    private void GenerateGrass()
    {
        StartCoroutine(Setup());
    }


    private void Update()
    {
        if (isReady)
        {
            float dist = Vector3.Distance(maincam.transform.position, transform.position);
            if (dist < 200f)
            {
                Graphics.DrawMeshInstancedIndirect(grassMesh, 0, _material, bounds, argsBuffer);
            }
            
        }
        
    }

    private void OnDisable()
    {
        // Release gracefully.
        isReady = false;
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

public static class StaticRandom
{
    static int seed = Environment.TickCount;

    static public readonly ThreadLocal<System.Random> random =
        new ThreadLocal<System.Random>(() => new System.Random(Interlocked.Increment(ref seed)));

    public static int Rand()
    {
        return random.Value.Next();
    }
}