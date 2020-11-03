using UnityEngine;
using System;
using PCT;
using System.Collections.Generic;

[Serializable]
public struct MapData
{
    public int mapSize;
    public int subdivisions;
    public float density;
    public List<MeshTerrainLayer> terrainLayers; //TODO: Set up file paths to load heightmap data

    [NonSerialized]
    public Texture2D satelliteImage;
    public string satelliteFilePath;
    [NonSerialized]
    public Texture2D colourBlendMap;
    public string colourBlendFilePath;

    //public Material groundMat;

    public float DetailTransitionDistance;// = 5f;
    public float DetailTransitionFalloff;// = -0.5f;
    public float BlendAlpha;// = 0.5f;

    [NonSerialized]
    public Texture2D detailTextureR;
    public string detailRFilePath;
    [NonSerialized]
    public Texture2D detailTextureG;
    public string detailGFilePath;
    [NonSerialized]
    public Texture2D detailTextureB;
    public string detailBFilePath;
    [NonSerialized]
    public Texture2D detailTextureA;
    public string detailAFilePath;

    public string SaveToString()
    {
        return JsonUtility.ToJson(this, true);
    }

    //These methods are static so that they can be used to create the map data object
    public static MapData LoadFromString(string savedData)
    {
        MapData data = JsonUtility.FromJson<MapData>(savedData);
        LoadTextures(data);
        return data;
    }

    private static void LoadTextures(MapData data)
    {
        data.satelliteImage = FileHelper.GetTextureByPath(data.satelliteFilePath);
        data.colourBlendMap = FileHelper.GetTextureByPath(data.colourBlendFilePath);
        data.detailTextureR = FileHelper.GetTextureByPath(data.detailRFilePath);
        data.detailTextureG = FileHelper.GetTextureByPath(data.detailGFilePath);
        data.detailTextureB = FileHelper.GetTextureByPath(data.detailBFilePath);
        data.detailTextureA = FileHelper.GetTextureByPath(data.detailAFilePath);
    }
}