using PCT;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class NavMeshBuilderScript : MonoBehaviour
{
    private TerrainReferenceHolder terrainReferenceHolder;
    [SerializeField]
    LayerMask layerMask;
    [SerializeField]
    List<NavMeshSurface> navMeshSurfaces = new List<NavMeshSurface>();

    public void Go(in TerrainReferenceHolder trf)
    {
        terrainReferenceHolder = trf;
        StartCoroutine(DelayStart());
    }

    public void RegisterNavMeshSurface(NavMeshSurface surf) => navMeshSurfaces.Add(surf);

    private IEnumerator DelayStart()
    {
        //Wait until it is... our time.
        while (terrainReferenceHolder.generator == null)
        {
            yield return null;
        }
        while (!terrainReferenceHolder.generator.generationComplete)
        {
            yield return null;
        }
        yield return new WaitForSeconds(5f);
        UpdateNavMesh();
    }

    private void UpdateNavMesh()
    {
        List<NavMeshBuildSource> buildSources = new List<NavMeshBuildSource>();

        /*foreach (var src in navMeshSurfaces)
        {
            src.collectObjects = CollectObjects.All;
            src.BuildNavMesh();
            //BuildNavMeshData(AI.NavMeshBuildSettings buildSettings, List < NavMeshBuildSource > sources, Bounds localBounds, Vector3.zero, Quaternion.identity);

        }*/
        NavMeshBuilder.CollectSources(null, layerMask, NavMeshCollectGeometry.PhysicsColliders, 0, new List<NavMeshBuildMarkup>(), buildSources);

        NavMeshData navData = new NavMeshData();
        NavMeshBuilder.UpdateNavMeshDataAsync(
            navData,
            NavMesh.GetSettingsByID(0),
            buildSources,
            new Bounds(Vector3.zero, new Vector3(10000, 10000, 10000))//,
            //Vector3.down,
            //Quaternion.Euler(Vector3.up)
        );
        NavMeshDataInstance navMeshDataInstance = NavMesh.AddNavMeshData(navData);
    }
}
