using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using NaughtyAttributes;
using PCT;

public class GroundGen : MonoBehaviour
{
    //private TerrainReferenceHolder terrainReferenceHolder;

#pragma warning disable CS0649 //'Never assigned to'
    //Public
    [Header("Core")]
    [SerializeField]
    GameObject prefab;

    [SerializeField]
    int layer;

    [HideInInspector]
    public bool generationComplete { get; private set; }


    [Header("Texture")]
    public Texture2D satelliteImage;
    public Texture2D colourBlendMap;
    public Material groundMat;
    [Space]
    public float DetailTransitionDistance = 5f;
    public float DetailTransitionFalloff = -0.5f;
    [Range(0,1)]
    public float BlendAlpha = 0.5f;

    [BoxGroup("Detail Textures")]
    public Texture2D detailTextureR;
    [BoxGroup("Detail Textures")]
    public Texture2D detailTextureG;
    [BoxGroup("Detail Textures")]
    public Texture2D detailTextureB;
    [BoxGroup("Detail Textures")]
    public Texture2D detailTextureA;

    //Private
    private TerrainReferenceHolder terrainReferenceHolder;
    private GameObject[] gameObjects;
    private List<MeshGenerator> generatorList;
    private int concurrentJobs;
    //#pragma warning restore CS0649

    public void Go(in TerrainReferenceHolder trf)
    {
        terrainReferenceHolder = trf;
        applyTextureMaps();
        StartCoroutine(InitGeneration());
    }

    void applyTextureMaps()
    {
        groundMat.SetTexture("_Satellite", satelliteImage);
        groundMat.SetTexture("_ColorMap1", colourBlendMap);
        groundMat.SetTexture("_DetailR", detailTextureR);
        groundMat.SetTexture("_DetailG", detailTextureG);
        groundMat.SetTexture("_DetailB", detailTextureB);
        groundMat.SetTexture("_DetailA", detailTextureA);

        groundMat.SetFloat("_DetailTransitionDistance", DetailTransitionDistance);
        groundMat.SetFloat("_DetailTransitionFalloff", DetailTransitionFalloff);
        groundMat.SetFloat("_BlendAlpha", BlendAlpha);

    }

    public void tickDownJob()
    {
        concurrentJobs--;
    }

    public void tickUpJob()
    {
        concurrentJobs++;
    }

    IEnumerator InitGeneration()
    {
        //int subdivisions = terrainReferenceHolder.mapData.mapSize / 16250;
        int subidividedSize = terrainReferenceHolder.mapData.mapSize / terrainReferenceHolder.mapData.subdivisions;

        concurrentJobs = 0;
        generationComplete = false;
        gameObjects = new GameObject[terrainReferenceHolder.mapData.subdivisions];
        generatorList = new List<MeshGenerator>();

        foreach (MeshTerrainLayer item in terrainReferenceHolder.mapData.terrainLayers)
        {
            item.Init();
            //item = new MeshTerrainLayer(item.)
            
        }

        for (int i = 0; i < terrainReferenceHolder.mapData.subdivisions; i++)
        {
            for (int j = 0; j < terrainReferenceHolder.mapData.subdivisions; j++)
            {
                gameObjects[i] = Instantiate(prefab, transform);
                gameObjects[i].layer = layer;
                MeshGenerator mGen = gameObjects[i].AddComponent<MeshGenerator>();
                gameObjects[i].transform.position = new Vector3(i * (subidividedSize) * transform.localScale.x, 0, j * (subidividedSize) * transform.localScale.z);
                mGen.Init(in terrainReferenceHolder, subidividedSize, new Vector2(subidividedSize * i, subidividedSize * j));
                generatorList.Add(mGen);
            }
        }

        foreach (MeshGenerator mGen in generatorList)
        {
            while (concurrentJobs > System.Environment.ProcessorCount - 1)
            {
                yield return null;
            }
            mGen.Go();
        }
        generationComplete = true;
        yield return null;

        
    }

    
}
