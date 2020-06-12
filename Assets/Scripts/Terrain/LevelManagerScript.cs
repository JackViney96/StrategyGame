using UnityEngine;
using PCT;
using IngameDebugConsole;
using System.Collections.Generic;
using System.IO;

//Script for reading in external data and feeding it to the ground generator. 
public class LevelManagerScript : MonoBehaviour
{
    //[SerializeField]
    public TerrainReferenceHolder referenceHolder;
    [SerializeField]
    private GameObject terrainObject;
    [SerializeField]
    private GameObject navObject;
    [SerializeField]
    public GroundGen gen { get; private set; }
    [SerializeField]
    public NavMeshBuilderScript nav { get; private set; }

    string jsonteststring = "{\n    \"mapSize\": 1024,\n    \"subdivisions\": 10,\n    \"density\": 0.5,\n    \"terrainLayers\": [\n        {\n            \"isTextureSampler\": true,\n            \"heightMap\": {\n                \"instanceID\": 18374\n            },\n            \"noiseScale\": 0.0,\n            \"heightScale\": 25.0\n        },\n        {\n            \"isTextureSampler\": true,\n            \"heightMap\": {\n                \"instanceID\": 18376\n            },\n            \"noiseScale\": 0.0,\n            \"heightScale\": 5.0\n        },\n        {\n            \"isTextureSampler\": false,\n            \"heightMap\": {\n                \"instanceID\": 0\n            },\n            \"noiseScale\": 100.0,\n            \"heightScale\": 0.25\n        }\n    ],\n    \"satelliteImage\": {\n        \"instanceID\": 0\n    },\n    \"colourBlendMap\": {\n        \"instanceID\": 0\n    },\n    \"groundMat\": {\n        \"instanceID\": 0\n    },\n    \"DetailTransitionDistance\": 0.0,\n    \"DetailTransitionFalloff\": 0.0,\n    \"BlendAlpha\": 0.0,\n    \"detailTextureR\": {\n        \"instanceID\": 0\n    },\n    \"detailTextureG\": {\n        \"instanceID\": 0\n    },\n    \"detailTextureB\": {\n        \"instanceID\": 0\n    },\n    \"detailTextureA\": {\n        \"instanceID\": 0\n    }\n}";

    private static string path;

    void Awake()
    {
        path = PCT.StaticDefines.dataDirectory + Path.DirectorySeparatorChar + System.Environment.MachineName + ".json";
        gen = terrainObject.GetComponent<GroundGen>();
        nav = navObject.GetComponent<NavMeshBuilderScript>();
        //TODO: Ingest JSON
        //Assign variables as appropriate from JSON
        //referenceHolder = ScriptableObject.CreateInstance<TerrainReferenceHolder>();

        referenceHolder.generator = gen;
        referenceHolder.navBuilder = nav;
        

        //gen.Constructor();

        //gen.Go();

        DebugLogConsole.AddCommandInstance("save", "Saves the map", "SaveData", this);
        DebugLogConsole.AddCommandInstance("load", "Loads the map", "LoadData", this);
        DebugLogConsole.AddCommandInstance("navmesh", "Generate Navmesh", "GenerateNavMesh", this);
    }

    public void SaveData()
    {
        jsonteststring = referenceHolder.mapData.SaveToString();
        print(jsonteststring);
        using (StreamWriter writer = new StreamWriter(File.Open(path, FileMode.Create)))
        {
            writer.Write(jsonteststring);
        }
    }

    public void LoadData()
    {
        string data;
        using (StreamReader sr = new StreamReader(path))
        {
            //This allows you to do one Read operation.
            data = sr.ReadToEnd();
        }
        referenceHolder.mapData = MapData.LoadFromString(data);
        //referenceHolder.mapData.terrainLayers.Add(new MeshTerrainLayer());
        referenceHolder.terrainBounds = generateBounds();
        print(data);
        gen.Go(trf: in referenceHolder);
    }

    void GenerateNavMesh()
    {
        nav.Go(trf: in referenceHolder);
    }

    private Bounds generateBounds()
    {
        //Map center:
        var center = referenceHolder.mapData.mapSize / 2;
        print("Bounds size: " + referenceHolder.mapData.mapSize);
        return new Bounds(new Vector3(center, 0, center), new Vector3(referenceHolder.mapData.mapSize, referenceHolder.mapData.mapSize, referenceHolder.mapData.mapSize));
    }
}
