using IngameDebugConsole;
using PCT;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class TerrainReferenceHolder : ScriptableObject
{
    public MapData mapData;

    public GroundGen generator;
    public NavMeshBuilderScript navBuilder;
    public Bounds terrainBounds;
}
