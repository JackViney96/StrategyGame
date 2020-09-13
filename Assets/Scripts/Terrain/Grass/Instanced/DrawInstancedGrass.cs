using CielaSpike;
using NaughtyAttributes;
using System;
using System.Collections;
using System.Threading;
using UnityEngine;

public class DrawInstancedGrass : MonoBehaviour
{
    private Mesh parentMesh;

    public int bladesPerTri;
    private int population;
    public float range;
    public float distance;
    public float bladeSize;
    public bool shadows = true;

    public Material material;
    [System.NonSerialized]
    private Material _material;

    private ComputeBuffer meshPropertiesBuffer;
    private ComputeBuffer argsBuffer;

    public Mesh grassMesh;
    
    private Bounds bounds;

    [SerializeField]
    private bool isReady = false;
    private bool canGenerate = false;

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
                sizeof(float) * 4 * 4// matrix1;
                + sizeof(float) * 2; //GroundUV
        }
    }
    class MeshData
    {
        public Vector3[] verts;
        public int[] tris;
        public Vector2[] uvs;
    }

    MeshProperties[] properties;

    public IEnumerator Setup(Vector3 worldPosition)
    {
       // Mesh mesh = CreateQuad();
        //this.mesh = mesh;
        parentMesh = GetComponent<MeshFilter>().sharedMesh;
        MeshData meshData = new MeshData();
        meshData.verts = parentMesh.vertices;
        meshData.tris = parentMesh.triangles;
        meshData.uvs = parentMesh.uv;

        _material = Instantiate(material);

        population = meshData.tris.Length * bladesPerTri;

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
        this.StartCoroutineAsync(InitializeBuffers(meshData, worldPosition), out task);
        yield return StartCoroutine(task.Wait());

        meshPropertiesBuffer = new ComputeBuffer(population, MeshProperties.Size());
        meshPropertiesBuffer.SetData(properties);

        _material.SetBuffer("_Properties", meshPropertiesBuffer);

        properties = null;

        isReady = true;
    }

    class PointAndUV
    {
        public Vector3 point;
        public Vector2 uv;

        public PointAndUV(Vector3 point, Vector2 uv)
        {
            this.point = point;
            this.uv = uv;
        }
    }

    private PointAndUV getPointOnMesh(int curTri, MeshData meshData, Vector3 worldPos, int blade)
    {
        System.Random rnd = GrassRandom.random.Value;
        Vector3[] meshPoints = meshData.verts;
        int[] tris = meshData.tris;
        Vector2[] uvs = meshData.uvs;

        float a = (float)rnd.NextDouble();
        float b = (float)rnd.NextDouble();

        for (int i = 0; i < blade; i++)
        {
            a = (float)rnd.NextDouble();
            b = (float)rnd.NextDouble();
        }

        
        if (a + b >= 1)
        { // reflect back if > 1
            a = 1 - a;
            b = 1 - b;
        }

        int vertIndex1 = tris[curTri * 3 + 0];
        int vertIndex2 = tris[curTri * 3 + 1];
        int vertIndex3 = tris[curTri * 3 + 2];

        Vector2 UV1 = uvs[tris[curTri * 3 + 0]];

        Vector3 newPointOnMesh = meshPoints[vertIndex1] + (a * (meshPoints[vertIndex2] - meshPoints[vertIndex1])) + (b * (meshPoints[vertIndex3] - meshPoints[vertIndex1]));
        newPointOnMesh += worldPos;
        //newPointOnMesh += Vector3.up * blade;
        
        return new PointAndUV(newPointOnMesh, UV1);
    }
    private IEnumerator InitializeBuffers(MeshData meshData, Vector3 worldPos)
    {
        // Argument buffer used by DrawMeshInstancedIndirect.


        // Initialize buffer with the given population.
        //System.Random rnd = new System.Random();
        System.Random rnd = GrassRandom.random.Value;
        //Why oh why does this work?? why can't it just be 100% of the tris????
        for (int j = 0; j < bladesPerTri; j++)
        {
            for (int i = 0; i < meshData.tris.Length * 0.96; i++)
            {
            
                MeshProperties props = new MeshProperties();

                //yield return Ninja.JumpToUnity;
                PointAndUV pointAndUV = getPointOnMesh(i / 3, meshData, worldPos, j);
                Vector3 position = pointAndUV.point;
                //yield return Ninja.JumpBack;

                Quaternion rotation = Quaternion.Euler(0, rnd.Next(359), 0); // Quaternion.Euler(270, Random.Range(-180, 180), 0);
                Vector3 scale = Vector3.one * (float)(rnd.NextDouble() * bladeSize);
                position.y += scale.y * 0.5f; //raise up out of the ground

                props.TRSMatrix = Matrix4x4.TRS(position, rotation, scale);
                props.groundUV = pointAndUV.uv;
                //props.color = Vector4.zero;
                //props.mat = Matrix4x4.identity;

                properties[i+(j*i)] = props;
            }
        }

        

        
        yield return null;
    }

    Camera maincam;
    Collider coll;

    private void OnEnable()
    {
        maincam = Camera.main;
        coll = GetComponent<Collider>();
    }

    [Button]
    public void GenerateGrass()
    {
        canGenerate = true;
    }


    private void Update()
    {
        Vector3 closestPoint = coll.ClosestPointOnBounds(maincam.transform.position);
        float dist = Vector3.Distance(maincam.transform.position, closestPoint);

        if (canGenerate && dist < distance * 1.5)
        {
            StartCoroutine(Setup(transform.position));
            canGenerate = false;
        }
        if (isReady && dist < distance)
        {
            if (shadows)
            {
                Graphics.DrawMeshInstancedIndirect(grassMesh, 0, _material, bounds, argsBuffer, 0, null, UnityEngine.Rendering.ShadowCastingMode.TwoSided, true);
            }
            else
            {
                Graphics.DrawMeshInstancedIndirect(grassMesh, 0, _material, bounds, argsBuffer, 0, null, UnityEngine.Rendering.ShadowCastingMode.Off, false);
            }
            
        }

        if (isReady && dist > distance * 1.5)
        {
            ReleaseBuffers();
            canGenerate = true;
        }

    }

    private void OnDisable()
    {
        ReleaseBuffers();   
    }

    private void ReleaseBuffers()
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

public static class GrassRandom
{
    static int seed = 8008135;

    static public readonly ThreadLocal<System.Random> random =
        new ThreadLocal<System.Random>(() => new System.Random(Interlocked.Increment(ref seed)));

    public static int Rand()
    {
        return random.Value.Next();
    }
}