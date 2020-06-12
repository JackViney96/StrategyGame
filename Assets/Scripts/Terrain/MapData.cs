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
    public List<MeshTerrainLayer> terrainLayers;

    public Texture2D satelliteImage;
    public Texture2D colourBlendMap;
    public Material groundMat;

    public float DetailTransitionDistance;// = 5f;
    public float DetailTransitionFalloff;// = -0.5f;
    public float BlendAlpha;// = 0.5f;


    public Texture2D detailTextureR;
    public Texture2D detailTextureG;
    public Texture2D detailTextureB;
    public Texture2D detailTextureA;

    public string SaveToString()
    {
        return JsonUtility.ToJson(this, true);
    }

    public static MapData LoadFromString(string savedData)
    {
        return JsonUtility.FromJson<MapData>(savedData);
    }
}