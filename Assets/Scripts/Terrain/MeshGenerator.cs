using System.Collections;
using UnityEngine;
using CielaSpike;
using PCT;
using UnityEngine.AI;
using Unity.Jobs;
using Unity.Collections;
using System.Collections.Generic;

[RequireComponent(typeof(MeshFilter))]
public class MeshGenerator : MonoBehaviour
{
    //Private
    private int patchSize, totalSize;
    private Vector2 offset;
    private NavMeshSurface surf;
    private List<MeshTerrainLayer> terrainLayers;

    private Mesh mesh;
    private MeshFilter meshFilter;
    private MeshCollider meshCollider;
    private Vector3[] vertices;
    private Vector2[] uv;
    private int[] triangles;
    private float density;

    private TerrainReferenceHolder terrainReferenceHolder;


    public void Init(in TerrainReferenceHolder terrainReferenceHolder, int patchSize, Vector2 offset)
    {
        
        //this.terrainLayers = terrainLayers; //Contains texturesampler, height
        this.terrainReferenceHolder = terrainReferenceHolder;
        terrainLayers = terrainReferenceHolder.mapData.terrainLayers;
        density = terrainReferenceHolder.mapData.density;
        this.patchSize = (int)(patchSize * 1/density);
        totalSize = terrainReferenceHolder.mapData.mapSize;
        this.offset = offset;

        mesh = new Mesh();


        surf = GetComponent<NavMeshSurface>();
        meshFilter = GetComponent<MeshFilter>();

        meshFilter.sharedMesh = mesh;
        meshCollider = GetComponent<MeshCollider>();

        //meshSimplifier = new UnityMeshSimplifier.MeshSimplifier();

        //vertices = new Vector3[(patchSize + 1) * (patchSize + 1) * (int)(1 / density) + 1];
        //vertices = new Vector3[(patchSize * (int)(1 / density) + 1) * (patchSize * (int)(1 / density) + 1)];
        vertices = new Vector3[(this.patchSize + 1) * (this.patchSize + 1)];
        //triangles = new int[patchSize * patchSize * 6];
        triangles = new int[vertices.Length * 6];
        uv = new Vector2[vertices.Length];
    }

    public void Go()
    {
        terrainReferenceHolder.generator.tickUpJob();
        StartCoroutine(updateCoroutine());
    }

    IEnumerator updateCoroutine()
    {
        Task task;
        this.StartCoroutineAsync(CreateShape(), out task);
        yield return StartCoroutine(task.Wait());
        UpdateMesh();
    }

    void UpdateMesh()
    {
        mesh.Clear();

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uv;
        //mesh.uv = Unwrapping.GeneratePerTriangleUV(mesh);

        //UnityEditor.MeshUtility.Optimize(mesh);


        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        meshCollider.sharedMesh = mesh;
        terrainReferenceHolder.navBuilder.RegisterNavMeshSurface(surf);

        //mesh.UploadMeshData(true);
        terrainReferenceHolder.generator.tickDownJob();
        this.GetComponent<DrawInstancedGrass>().GenerateGrass();
        System.GC.Collect();
    }

    IEnumerator CreateShape()
    {
        //Builds a mesh from the heightmap using Bilinear Filtering for some basic smoothing
        int vertexIndex = 0;
        for (int z = 0; z <= patchSize; z++)
        {
            for (int x = 0; x <= patchSize; x++, vertexIndex++)
            {
                try
                {
                    vertices[vertexIndex] = new Vector3(x * density, 0, z * density);
                }
                catch (System.Exception)
                {
                    Debug.Log("L:" + vertices.Length +" I:" + vertexIndex + " Z:" + z + " X:" + x + " S:" + patchSize);
                    throw;
                }
                
            }
        }

        foreach (MeshTerrainLayer tl in terrainLayers)
        {
            for (int z = 0, i = 0; z <= patchSize; z++)
            {
                for (int x = 0; x <= patchSize; x++, i++)
                {
                    //float y = tl.texSampler.GetPixelBilinear(((x + offset.x) / totalSize), ((z + offset.y) / totalSize)).grayscale;
                    float y = tl.Sample(((x * density) + offset.x) / totalSize, ((z * density) + offset.y) / totalSize).grayscale;
                    vertices[i] += new Vector3(0, y * tl.heightScale, 0);
                }
            }
        }       

        int tris = 0;
        int vert = 0;
        for (int z = 0; z < patchSize; z++)
        {
            for (int x = 0; x < patchSize; x++)
            {
                triangles[tris + 0] = vert + 0;
                triangles[tris + 1] = vert + patchSize + 1;
                triangles[tris + 2] = vert + 1;
                triangles[tris + 3] = vert + 1;
                triangles[tris + 4] = vert + patchSize + 1;
                triangles[tris + 5] = vert + patchSize + 2;

                vert++;
                tris += 6;
            }
            vert++;
        }

        //Optimization:
        //var returned = MeshColliderTools.Simplify(vertices, triangles);
        //vertices = returned.verts;
        //triangles = returned.tris;

        //Time to generate UVs

        for (int i = 0; i < uv.Length; i++)
        {
            uv[i] = new Vector2((vertices[i].x + offset.x) / totalSize, (vertices[i].z + offset.y) / totalSize);
        }

        yield return null;
    }

    IEnumerator SmoothStepShape()
    {
        //This might make patch edges look bad..?

        // Loop over every vertex
        /*for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i].y = i / 100f;
        }*/
        yield return null;
    }
}
/*
public struct CreateShapeJob : IJob
{
    public int patchSize, totalSize;
    public NativeArray<Vector3> vertices;
    public NativeArray<Vector2> uv;
    public NativeArray<int> triangles;
    public List<MeshTerrainLayerStruct> terrainLayers;
    public Vector2 offset;

    public void Execute()
    {
        for (int z = 0, i = 0; z <= patchSize; z++)
        {
            for (int x = 0; x <= patchSize; x++, i++)
            {
                vertices[i] = new Vector3(x, 0, z);
            }
        }

        foreach (MeshTerrainLayerStruct tl in terrainLayers)
        {
            for (int z = 0, i = 0; z <= patchSize; z++)
            {
                for (int x = 0; x <= patchSize; x++, i++)
                {
                    float y = tl.Sample(((x + offset.x) / totalSize), ((z + offset.y) / totalSize)).grayscale;
                    vertices[i] += new Vector3(0, y * tl.heightScale, 0);
                }
            }
        }

        int tris = 0;
        int vert = 0;
        for (int z = 0; z < patchSize; z++)
        {
            for (int x = 0; x < patchSize; x++)
            {
                triangles[tris + 0] = vert + 0;
                triangles[tris + 1] = vert + patchSize + 1;
                triangles[tris + 2] = vert + 1;
                triangles[tris + 3] = vert + 1;
                triangles[tris + 4] = vert + patchSize + 1;
                triangles[tris + 5] = vert + patchSize + 2;

                vert++;
                tris += 6;
            }
            vert++;
        }

        //Optimization:
        //var returned = MeshColliderTools.Simplify(vertices, triangles);
        //vertices = returned.verts;
        //triangles = returned.tris;

        //Time to generate UVs
        //TODO: Generate second set of UVs for detail textures?
        //Vector2[] uvs = new Vector2[vertices.Length];


        for (int i = 0; i < uv.Length; i++)
        {
            uv[i] = new Vector2((vertices[i].x + offset.x) / totalSize, (vertices[i].z + offset.y) / totalSize);
        }
        //uv = uvs;

    }
}*/
   